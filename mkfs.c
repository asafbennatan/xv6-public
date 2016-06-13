#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <assert.h>

#define stat xv6_stat // avoid clash with host struct stat
#include "types.h"
#include "fs.h"
#include "stat.h"
#include "param.h"

#ifndef static_assert
#define static_assert(a, b) do { switch (0) case 0 : case(a) :; } while (0)
#endif

#define NELEM(x) (sizeof(x) / sizeof((x)[0]))

#define NINODES 200

// Disk layout:
// [ boot block | sb block | log | inode blocks | free bit map | data blocks ]

int nbitmap = FSSIZE / (BSIZE * 8) + 1;
int ninodeblocks = NINODES / IPB + 1;
int nlog = LOGSIZE;
int nmeta;   // Number of meta blocks (boot, sb, nlog, inode, bitmap)
int nblocks; // Number of data blocks

int fsfd;
int bootblockfd;
int kernelfd;
struct superblock sb;
char zeroes[BSIZE];
uint freeinode = 1;
uint freeblock;

void balloc(int);
void wsect(uint, void*);
void winode(uint, struct dinode*);
void rinode(uint inum, struct dinode* ip);
void rsect(uint sec, void* buf);
uint ialloc(ushort type);
void iappend(uint inum, void* p, int n);
void readmbr(void* buf);
void printMBR(struct mbr* m);

// convert to intel byte order
ushort xshort(ushort x)
{
    ushort y;
    uchar* a = (uchar*)&y;
    a[0] = x;
    a[1] = x >> 8;
    return y;
}

uint xint(uint x)
{
    uint y;
    uchar* a = (uchar*)&y;
    a[0] = x;
    a[1] = x >> 8;
    a[2] = x >> 16;
    a[3] = x >> 24;
    return y;
}

int main(int argc, char* argv[])
{
    int i, cc, fd;
    uint rootino, inum, off;
    struct dirent de;
    char buf[BSIZE];
    struct dinode din;
    struct mbr mbrI;

    static_assert(sizeof(int) == 4, "Integers must be 4 bytes!");

    if (argc < 4) {
        fprintf(stderr, "Usage: mkfs fs.img bootblock kernel files...\n");
        exit(1);
    }

    assert((BSIZE % sizeof(struct dinode)) == 0);
    assert((BSIZE % sizeof(struct dirent)) == 0);

    fsfd = open(argv[1], O_RDWR | O_CREAT | O_TRUNC, 0666);
    if (fsfd < 0) {
        perror(argv[1]);
        exit(1);
    }
    // set MBR
    bootblockfd = open(argv[2], O_RDONLY, 0666);
    if (bootblockfd < 0) {
        perror(argv[2]);
        exit(1);
    }
    kernelfd = open(argv[3], O_RDONLY, 0666);
    if (kernelfd < 0) {
        perror(argv[3]);
        exit(1);
    }
    
     if (read(bootblockfd, &mbrI, BSIZE) < 0) {
        perror(argv[2]);
        exit(1);
    }
    
      memset(buf, 0, sizeof(buf));
    i = 0;
    while (read(kernelfd, buf, BSIZE) > 0) {
        i++;
        wsect(i, buf);
        memset(buf, 0, sizeof(buf));
        
    }
    close(bootblockfd);
    close(kernelfd);
    
    // 1 fs block = 1 disk sector
    nmeta = 1+i + nlog + ninodeblocks + nbitmap;
    nblocks = FSSIZE - nmeta;
   
    mbrI.partitions[0].offset = i;
    mbrI.partitions[0].size = nblocks;
    mbrI.partitions[0].type = FS_INODE;
    mbrI.partitions[0].number = 0;

    sb.offset = xint(mbrI.partitions[0].offset);
    sb.size = xint(FSSIZE);
    sb.nblocks = xint(nblocks);
    sb.ninodes = xint(NINODES);
    sb.nlog = xint(nlog);
    sb.logstart = xint(mbrI.partitions[0].offset);
    sb.inodestart = xint(mbrI.partitions[0].offset + nlog);
    sb.bmapstart = xint(mbrI.partitions[0].offset + nlog + ninodeblocks);

    printf("nmeta %d (boot, super, log blocks %u inode blocks %u, bitmap blocks %u) blocks %d total %d\n",
           nmeta,
           nlog,
           ninodeblocks,
           nbitmap,
           nblocks,
           FSSIZE);

    freeblock = nmeta; // the first free block that we can allocate

    for (i = 0; i < FSSIZE; i++)
        wsect(i, zeroes);

    memset(buf, 0, sizeof(buf));
    memmove(buf, &sb, sizeof(sb));
    wsect(mbrI.partitions[0].offset, buf);

  

    rootino = ialloc(T_DIR);
    assert(rootino == ROOTINO);

    bzero(&de, sizeof(de));
    de.inum = xshort(rootino);
    strcpy(de.name, ".");
    iappend(rootino, &de, sizeof(de));

    bzero(&de, sizeof(de));
    de.inum = xshort(rootino);
    strcpy(de.name, "..");
    iappend(rootino, &de, sizeof(de));
    int hasSh = 0;
    int hasInit = 0;

    for (i = 4; i < argc; i++) {
        assert(index(argv[i], '/') == 0);

        if ((fd = open(argv[i], 0)) < 0) {
            perror(argv[i]);
            exit(1);
        }

        // Skip leading _ in name when writing to file system.
        // The binaries are named _rm, _cat, etc. to keep the
        // build operating system from trying to execute them
        // in place of system binaries like rm and cat.
        if (argv[i][0] == '_')
            ++argv[i];

        if (strcmp("sh", argv[i]) == 0) {
            hasSh = 1;
        }

        if (strcmp("init", argv[i]) == 0) {
            hasInit = 1;
        }
        inum = ialloc(T_FILE);
        printf("appending %s \n",argv[i]);
        bzero(&de, sizeof(de));
        de.inum = xshort(inum);
        strncpy(de.name, argv[i], DIRSIZ);
        iappend(rootino, &de, sizeof(de));

        while ((cc = read(fd, buf, sizeof(buf))) > 0)
            iappend(inum, buf, cc);

        close(fd);
            printf("finished appending \n");

    }
    // fix size of root inode dir
    rinode(rootino, &din);
    off = xint(din.size);
    off = ((off / BSIZE) + 1) * BSIZE;
    din.size = xint(off);
    winode(rootino, &din);

    balloc(freeblock);

    if (hasInit && hasSh) {
        mbrI.partitions[0].flags = PART_BOOTABLE;
    } else {
        mbrI.partitions[0].flags = PART_ALLOCATED;
    }
    // write MBR
    memset(buf, 0, sizeof(buf));
    memmove(buf, &mbrI, sizeof(struct mbr));
    wsect(0, buf);

    // read and print MBR
    memset(buf, 0, sizeof(buf));
    readmbr(buf);
    struct mbr* rmbr = (struct mbr*)buf;
    printMBR(rmbr);

    exit(0);
}

void wsect(uint sec, void* buf)
{
    if (lseek(fsfd, sec * BSIZE, 0) != sec * BSIZE) {
        perror("lseek");
        exit(1);
    }
    if (write(fsfd, buf, BSIZE) != BSIZE) {
        perror("write");
        exit(1);
    }
}

void winode(uint inum, struct dinode* ip)
{
    char buf[BSIZE];
    uint bn;
    struct dinode* dip;

    bn = IBLOCK(inum, sb);
    rsect(bn, buf);
    dip = ((struct dinode*)buf) + (inum % IPB);
    *dip = *ip;
    wsect(bn, buf);
}

void rinode(uint inum, struct dinode* ip)
{
    char buf[BSIZE];
    uint bn;
    struct dinode* dip;

    bn = IBLOCK(inum, sb);
    rsect(bn, buf);
    dip = ((struct dinode*)buf) + (inum % IPB);
    *ip = *dip;
}

void rsect(uint sec, void* buf)
{
    if (lseek(fsfd, sec * BSIZE, 0) != sec * BSIZE) {
        perror("lseek");
        exit(1);
    }
    if (read(fsfd, buf, BSIZE) != BSIZE) {
        perror("read");
        exit(1);
    }
}

void readmbr(void* buf)
{
    rsect(0, buf);
}

void printMBR(struct mbr* m)
{
    static char* FS_TYPE[] = {[FS_INODE] "INODE", [FS_FAT] "FAT" };

    static char* BOOTABLE[] = {[PART_BOOTABLE] "YES" };

    int i;
    char* bootable;
    char* type;
    printf("MBR Dump \n");
    for (i = 0; i < NPARTITIONS; i++) {
        if (m->partitions[i].flags >= 0 && m->partitions[i].flags < NELEM(BOOTABLE) &&
            BOOTABLE[m->partitions[i].flags]) {
            bootable = BOOTABLE[m->partitions[i].flags];

        } else {
            bootable = "NO";
        }

        if (m->partitions[i].type >= 0 && m->partitions[i].type < NELEM(FS_TYPE) && FS_TYPE[m->partitions[i].type]) {
            type = FS_TYPE[m->partitions[i].type];

        } else {
            type = "???";
            printf("unknown type %d \n", m->partitions[i].type);
        }

        printf("partition %d: bootable %s type %s offset %d size %d \n",
               i,
               bootable,
               type,
               m->partitions[i].offset,
               m->partitions[i].size);
    }
    printf("magic %s \n", m->magic);
}

uint ialloc(ushort type)
{
    uint inum = freeinode++;
    struct dinode din;

    bzero(&din, sizeof(din));
    din.type = xshort(type);
    din.nlink = xshort(1);
    din.size = xint(0);
    winode(inum, &din);
    return inum;
}

void balloc(int used)
{
    uchar buf[BSIZE];
    int i;

    printf("balloc: first %d blocks have been allocated\n", used);
    assert(used < BSIZE * 8);
    bzero(buf, BSIZE);
    for (i = 0; i < used; i++) {
        buf[i / 8] = buf[i / 8] | (0x1 << (i % 8));
    }
    printf("balloc: write bitmap block at sector %d\n", sb.bmapstart);
    wsect(sb.bmapstart, buf);
}

#define min(a, b) ((a) < (b) ? (a) : (b))

void iappend(uint inum, void* xp, int n)
{
    char* p = (char*)xp;
    uint fbn, off, n1;
    struct dinode din;
    char buf[BSIZE];
    uint indirect[NINDIRECT];
    uint x;

    rinode(inum, &din);
    off = xint(din.size);
    // printf("append inum %d at off %d sz %d\n", inum, off, n);
    while (n > 0) {
        fbn = off / BSIZE;
        assert(fbn < MAXFILE);
        if (fbn < NDIRECT) {
            if (xint(din.addrs[fbn]) == 0) {
                din.addrs[fbn] = xint(freeblock++);
            }
            x = xint(din.addrs[fbn]);
        } else {
            if (xint(din.addrs[NDIRECT]) == 0) {
                din.addrs[NDIRECT] = xint(freeblock++);
            }
            rsect(xint(din.addrs[NDIRECT]), (char*)indirect);
            if (indirect[fbn - NDIRECT] == 0) {
                indirect[fbn - NDIRECT] = xint(freeblock++);
                wsect(xint(din.addrs[NDIRECT]), (char*)indirect);
            }
            x = xint(indirect[fbn - NDIRECT]);
        }
        n1 = min(n, (fbn + 1) * BSIZE - off);
        rsect(x, buf);
        bcopy(p, buf + off - (fbn * BSIZE), n1);
        wsect(x, buf);
        n -= n1;
        off += n1;
        p += n1;
    }
    din.size = xint(off);
    winode(inum, &din);
}
