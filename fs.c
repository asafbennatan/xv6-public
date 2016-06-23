// File system implementation.  Five layers:
//   + Blocks: allocator for raw disk blocks.
//   + Log: crash recovery for multi-step updates.
//   + Files: inode allocator, reading, writing, metadata.
//   + Directories: inode with special contents (list of other inodes!)
//   + Names: paths like /usr/rtm/xv6/fs.c for convenient naming.
//
// This file contains the low-level file system manipulation
// routines.  The (higher-level) system call implementations
// are in sysfile.c.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "fs.h"
#include "buf.h"
#include "file.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
static void itrunc(struct inode*);
struct mbr mbrI;
int bootfrom = -1;
struct file * fstabFd;

// Read the super block.
void readsb(int dev, int partitionNumber)
{
    struct buf* bp;

    bp = bread(dev, mbrI.partitions[partitionNumber].offset);
    memmove(&(sbs[partitionNumber]), bp->data, sizeof(struct superblock));
    sbs[partitionNumber].offset=mbrI.partitions[partitionNumber].offset;
    brelse(bp);
}

void readmbr(int dev)
{
    struct buf* bp;

    bp = bread(dev, 0);
    memmove(&mbrI, bp->data, sizeof(struct mbr));
    brelse(bp);
}

// Zero a block.
static void bzero(int dev, int bno,uint partitionNumber)
{
    struct buf* bp;

    bp = bread(dev, bno);
    memset(bp->data, 0, BSIZE);
    log_write(bp,partitionNumber);
    brelse(bp);
}




// Blocks.

// Allocate a zeroed disk block.
static uint balloc(uint dev, int partitionNumber)
{
    int b, bi, m;
    struct buf* bp;

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
        bp = bread(dev, BBLOCK(b, sb));
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
            m = 1 << (bi % 8);
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
                bp->data[bi / 8] |= m;         // Mark block in use.
                log_write(bp,partitionNumber);
                brelse(bp);
                bzero(dev, sb.offset +b + bi,partitionNumber);
                return b + bi;
            }
        }
        brelse(bp);
    }
    panic("balloc: out of blocks");
}

// Free a disk block.
static void bfree(int dev, uint b, int partitionNumber)
{
      //  cprintf("bfree \n");

    struct buf* bp;
    int bi, m;
    struct superblock sb;
    sb = sbs[partitionNumber];
    bp = bread(dev, BBLOCK(b, sb));
    bi = b % BPB;
    m = 1 << (bi % 8);
    if ((bp->data[bi / 8] & m) == 0)
        panic("freeing free block");
    bp->data[bi / 8] &= ~m;
    log_write(bp,partitionNumber);
    brelse(bp);
}

// Inodes.
//
// An inode describes a single unnamed file.
// The inode disk structure holds metadata: the file's type,
// its size, the number of links referring to it, and the
// list of blocks holding the file's content.
//
// The inodes are laid out sequentially on disk at
// sb.startinode. Each inode has a number, indicating its
// position on the disk.
//
// The kernel keeps a cache of in-use inodes in memory
// to provide a place for synchronizing access
// to inodes used by multiple processes. The cached
// inodes include book-keeping information that is
// not stored on disk: ip->ref and ip->flags.
//
// An inode and its in-memory represtative go through a
// sequence of states before they can be used by the
// rest of the file system code.
//
// * Allocation: an inode is allocated if its type (on disk)
//   is non-zero. ialloc() allocates, iput() frees if
//   the link count has fallen to zero.
//
// * Referencing in cache: an entry in the inode cache
//   is free if ip->ref is zero. Otherwise ip->ref tracks
//   the number of in-memory pointers to the entry (open
//   files and current directories). iget() to find or
//   create a cache entry and increment its ref, iput()
//   to decrement ref.
//
// * Valid: the information (type, size, &c) in an inode
//   cache entry is only correct when the I_VALID bit
//   is set in ip->flags. ilock() reads the inode from
//   the disk and sets I_VALID, while iput() clears
//   I_VALID if ip->ref has fallen to zero.
//
// * Locked: file system code may only examine and modify
//   the information in an inode and its content if it
//   has first locked the inode. The I_BUSY flag indicates
//   that the inode is locked. ilock() sets I_BUSY,
//   while iunlock clears it.
//
// Thus a typical sequence is:
//   ip = iget(dev, inum)
//   ilock(ip)
//   ... examine and modify ip->xxx ...
//   iunlock(ip)
//   iput(ip)
//
// ilock() is separate from iget() so that system calls can
// get a long-term reference to an inode (as for an open file)
// and only lock it for short periods (e.g., in read()).
// The separation also helps avoid deadlock and races during
// pathname lookup. iget() increments ip->ref so that the inode
// stays cached and pointers to it remain valid.
//
// Many internal file system functions expect the caller to
// have locked the inodes involved; this lets callers create
// multi-step atomic operations.

struct
{
    struct spinlock lock;
    struct inode inode[NINODE];
} icache;

void printMBR(struct mbr* m)
{
    static char* FS_TYPE[] = {[FS_INODE] "INODE", [FS_FAT] "FAT" };


    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
    for (i = 0; i < NPARTITIONS; i++) {
        if (m->partitions[i].flags >1 && m->partitions[i].flags <4) {
            bootable = "YES";

        } else {
            bootable = "NO";
        }

        if (m->partitions[i].type >= 0 && m->partitions[i].type < NELEM(FS_TYPE) && FS_TYPE[m->partitions[i].type]) {
            type = FS_TYPE[m->partitions[i].type];

        } else {
            type = "???";
            cprintf("unknown type %d \n", m->partitions[i].type);
        }

        cprintf("partition %d: bootable %s type %s offset %d size %d \n",
                i,
                bootable,
                type,
                m->partitions[i].offset,
                m->partitions[i].size);
    }
    cprintf("magic %s \n", m->magic);
}

void initMbr(int dev)
{

   
    readmbr(dev);
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
        if (mbrI.partitions[i].flags >= PART_BOOTABLE && bootfrom == -1) {
            bootfrom = i;
            
        }
        partitions[i].dev = dev;
        partitions[i].flags = mbrI.partitions[i].flags;
        partitions[i].type = mbrI.partitions[i].type;
        partitions[i].number = i;
        partitions[i].offset = mbrI.partitions[i].offset;
        partitions[i].size = mbrI.partitions[i].size;
    }


    
}

int iinit(struct proc* p, int dev)
{
    struct inode* rootNode;
    struct superblock sb;
    // TODO: change ot iterate over all partitions

    initlock(&icache.lock, "icache");

    rootNode = p->cwd;
    // acquire(&icache.lock);

    initMbr(dev);
    printMBR(&mbrI);
    cprintf("booting from %d \n",bootfrom);
    if (bootfrom == -1) {
        panic("no bootable partition");
    }
    rootNode->part = &(partitions[bootfrom]);
    int i;
    for(i=0;i<NPARTITIONS;i++){
    readsb(dev, i);
    sb = sbs[i];
     cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
            sb.offset,
            sb.size,
            sb.nblocks,
            sb.ninodes,
            sb.nlog,
            sb.logstart,
            sb.inodestart,
            sb.bmapstart);
    }
    

    // set root inode
    
    // release(&icache.lock);

    // cprintf("root node init %d \n",rootNode->part->offset);
   
            
    
            return bootfrom;
}

static struct inode* iget(uint dev, uint inum, uint partitionNumber);

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
     //cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
        dip = (struct dinode*)bp->data + inum % IPB;
        if (dip->type == 0) { // a free inode
            memset(dip, 0, sizeof(*dip));
            dip->type = type;
            log_write(bp,partitionNumber); // mark it allocated on the disk
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
}

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{

          //  cprintf("iupdate \n");

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    dip = (struct dinode*)bp->data + ip->inum % IPB;
    dip->type = ip->type;
    dip->major = ip->major;
    dip->minor = ip->minor;
    dip->nlink = ip->nlink;
    dip->size = ip->size;
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    log_write(bp,ip->part->number);
    brelse(bp);
}

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
    struct inode* ip, *empty;

    acquire(&icache.lock);
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
            ip->ref++;
            release(&icache.lock);
            return ip;
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
        panic("iget: no inodes");

    ip = empty;
    ip->dev = dev;
    ip->inum = inum;
    ip->part = &(partitions[partitionNumber]);
    ip->ref = 1;
    ip->flags = 0;
    release(&icache.lock);

    return ip;
}

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
             //   cprintf("idup \n");

    acquire(&icache.lock);
    ip->ref++;
    release(&icache.lock);
    return ip;
}

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
    struct buf* bp;
    struct dinode* dip;
                 //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
    release(&icache.lock);

    if (!(ip->flags & I_VALID)) {
        struct superblock sb;
        sb = sbs[ip->part->number];
       // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
        dip = (struct dinode*)bp->data + ip->inum % IPB;
        ip->type = dip->type;
        ip->major = dip->major;
        ip->minor = dip->minor;
        ip->nlink = dip->nlink;
        ip->size = dip->size;
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
        brelse(bp);
        ip->flags |= I_VALID;
        if (ip->type == 0)
            panic("ilock: no type");
    }
}

// Unlock the given inode.
void iunlock(struct inode* ip)
{
                  //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
        // cprintf("iunlock ilock%d ",ip);
        panic("iunlock");
    }

    acquire(&icache.lock);
    ip->flags &= ~I_BUSY;
    wakeup(ip);
    release(&icache.lock);
}

// Drop a reference to an in-memory inode.
// If that was the last reference, the inode cache entry can
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
                       // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
            panic("iput busy");
        ip->flags |= I_BUSY;
        release(&icache.lock);
        itrunc(ip);
        ip->type = 0;
        iupdate(ip);
        acquire(&icache.lock);
        ip->flags = 0;
        wakeup(ip);
    }
    ip->ref--;
    release(&icache.lock);
}

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
    iunlock(ip);
    iput(ip);
}

// PAGEBREAK!
// Inode content
//
// The content (data) associated with each inode is stored
// in blocks on the disk. The first NDIRECT block numbers
// are listed in ip->addrs[].  The next NINDIRECT blocks are
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
                       //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
struct superblock sb;
sb=sbs[ip->part->number];
    if (bn < NDIRECT) {
        if ((addr = ip->addrs[bn]) == 0)
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
       // cprintf("addr %d \n ",addr);
        return addr;
    }
    bn -= NDIRECT;

    if (bn < NINDIRECT) {
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
        bp = bread(ip->dev, sb.offset+addr);
        a = (uint*)bp->data;
        if ((addr = a[bn]) == 0) {
            a[bn] = addr = balloc(ip->dev, ip->part->number);
            log_write(bp,ip->part->number);
        }
        brelse(bp);
        return addr;
    }

    panic("bmap: out of range");
}

// Truncate inode (discard contents).
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
                           //     cprintf("itrunc \n");

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
        if (ip->addrs[i]) {
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
        ip->addrs[NDIRECT] = 0;
    }

    ip->size = 0;
    iupdate(ip);
}

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
    st->dev = ip->dev;
    st->ino = ip->inum;
    st->type = ip->type;
    st->nlink = ip->nlink;
    st->size = ip->size;
}

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
                      //      cprintf("readi \n");
    sb=sbs[ip->part->number];
    if (ip->type == T_DEV) {
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
            return -1;
        return devsw[ip->major].read(ip, dst, n);
    }

    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
        uint bmapOut=bmap(ip, off / BSIZE);
       // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset+bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
}

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
                               // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
        sb=sbs[ip->part->number];


    if (ip->type == T_DEV) {
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
            return -1;
        return devsw[ip->major].write(ip, src, n);
    }

    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
        uint bmapOut=bmap(ip, off / BSIZE);
        bp = bread(ip->dev, sb.offset+bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp,ip->part->number);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
        ip->size = off;
        iupdate(ip);
    }
    return n;
}

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
    return strncmp(s, t, DIRSIZ);
}

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
                             //       cprintf("dirlookup \n");

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            continue;
        if (namecmp(name, de.name) == 0) {
            // entry matches path element
            if (poff)
                *poff = off;
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
}

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
                                       // cprintf("dirlink \n");

    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            break;
    }

    strncpy(de.name, name, DIRSIZ);
    de.inum = inum;
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
        panic("dirlink");

    return 0;
}

// PAGEBREAK!
// Paths

// Copy the next path element from path into name.
// Return a pointer to the element following the copied one.
// The returned path has no leading slashes,
// so the caller can check *path=='\0' to see if the name is the last one.
// If no name to remove, return 0.
//
// Examples:
//   skipelem("a/bb/c", name) = "bb/c", setting name = "a"
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
    
    char* s;
    int len;

    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
        path++;
    len = path - s;
    if (len >= DIRSIZ)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
        path++;
    return path;
}

// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, int ignoreMounts,char* name)
{
                                           // cprintf("namex \n");

    struct inode* ip, *next;
     // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
      //  cprintf("namex inode %d,part number %d \n",ip->inum,ip->part->number);
        ilock(ip);
        if (ip->type != T_DIR) {
            iunlockput(ip);
            return 0;
        }
        if (nameiparent && *path == '\0') {
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
            return ip;
        }
        if ((next = dirlookup(ip, name, 0)) == 0) {
            iunlockput(ip);
            return 0;
        }
        iunlockput(ip);
        //testing 
        if(!ignoreMounts&&next->type==T_DIR&&next->major!=0 && next->major!=MOUNTING_POINT){
            cprintf("major used ,we are fucked \n");
        }
        //handle mounting points
        if(!ignoreMounts&&!nameiparent&&next->type==T_DIR&&next->major==MOUNTING_POINT){
            
            
            uint partitionNumnber=next->minor;
            return iget(ROOTDEV,1,partitionNumnber);
        }
        ip = next;
    }
    if (nameiparent) {
        iput(ip);
        return 0;
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
}



struct inode* namei(char* path)
{
    char name[DIRSIZ];
    return namex(path, 0, 0,name);
}

struct inode* nameiIgnoreMounts(char* path)
{
    char name[DIRSIZ];
    return namex(path, 0, 1,name);
}

struct inode* nameiparent(char* path, char* name)
{
    return namex(path, 1, 0,name);
}
