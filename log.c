#include "types.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "fs.h"
#include "buf.h"

// Simple logging that allows concurrent FS system calls.
//
// A log transaction contains the updates of multiple FS system
// calls. The logging system only commits when there are
// no FS system calls active. Thus there is never
// any reasoning required about whether a commit might
// write an uncommitted system call's updates to disk.
//
// A system call should call begin_op()/end_op() to mark
// its start and end. Usually begin_op() just increments
// the count of in-progress FS system calls and returns.
// But if it thinks the log is close to running out, it
// sleeps until the last outstanding end_op() commits.
//
// The log is a physical re-do log containing disk blocks.
// The on-disk log format:
//   header block, containing block #s for block A, B, C, ...
//   block A
//   block B
//   block C
//   ...
// Log appends are synchronous.

// Contents of the header block, used for both the on-disk header block
// and to keep track in memory of logged block# before commit.
struct logheader {
  int n;   
  int block[LOGSIZE];
};

struct log {
  struct spinlock lock;
  int start;
  int size;
  int outstanding; // how many FS sys calls are executing.
  int committing;  // in commit(), please wait.
  int dev;
  struct logheader lh;
};
struct log logs[NPARTITIONS];

static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
for(int i=0;i<NPARTITIONS;i++){
     initlock(&logs[i].lock, "log");
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
  logs[i].size =  sbs[i].nlog;
  logs[i].dev = dev;
  recover_from_log(i);
}
 
}

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
}

// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
  brelse(buf);
}

static void
recover_from_log(uint partitionNumber)
{
  read_head(partitionNumber);      
  install_trans(partitionNumber); // if committed, copy from log to disk
  logs[partitionNumber].lh.n = 0;
  write_head(partitionNumber); // clear the log
}

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
  acquire(&logs[partitionNumber].lock);
  while(1){
    if(logs[partitionNumber].committing){
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
    } else {
      logs[partitionNumber].outstanding += 1;
      release(&logs[partitionNumber].lock);
      break;
    }
  }
}

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
  int do_commit = 0;

  acquire(&logs[partitionNumber].lock);
  logs[partitionNumber].outstanding -= 1;
  if(logs[partitionNumber].committing)
    panic("log.committing");
  if(logs[partitionNumber].outstanding == 0){
    do_commit = 1;
    logs[partitionNumber].committing = 1;
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
  }
  release(&logs[partitionNumber].lock);

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
    acquire(&logs[partitionNumber].lock);
    logs[partitionNumber].committing = 0;
    wakeup(&logs[partitionNumber]);
    release(&logs[partitionNumber].lock);
  }
}

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}

static void
commit(uint partitionNumber)
{
  if (logs[partitionNumber].lh.n > 0) {
    write_log(partitionNumber);     // Write modified blocks from cache to log
    write_head(partitionNumber);    // Write header to disk -- the real commit
    install_trans(partitionNumber); // Now install writes to home locations
    logs[partitionNumber].lh.n = 0; 
    write_head(partitionNumber);    // Erase the transaction from the log
  }
}

// Caller has modified b->data and is done with the buffer.
// Record the block number and pin in the cache with B_DIRTY.
// commit()/write_log() will do the disk write.
//
// log_write() replaces bwrite(); a typical use is:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
  if (i == logs[partitionNumber].lh.n)
    logs[partitionNumber].lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
  release(&logs[partitionNumber].lock);
}

