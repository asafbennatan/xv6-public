// On-disk file system format. 
// Both the kernel and user programs use this header file.
#include "mbr.h"

#define ROOTINO 1  // root i-number
#define BSIZE 512  // block size
#define MOUNTING_POINT 1

// Disk layout:
// [ boot block | super block | log | inode blocks | free bit map | data blocks ]
//
// mkfs computes the super block and builds an initial file system. The super describes
// the disk layout:
struct superblock {
  uint size;         // Size of file system image (blocks)
  uint nblocks;      // Number of data blocks
  uint ninodes;      // Number of inodes.
  uint nlog;         // Number of log blocks
  uint logstart;     // Block number of first log block
  uint inodestart;   // Block number of first inode block
  uint bmapstart;    // Block number of first free map block
    uint offset;       // starting offset
};

#define NDIRECT 12
#define NINDIRECT (BSIZE / sizeof(uint))
#define MAXFILE (NDIRECT + NINDIRECT)

// On-disk inode structure
struct dinode {
  short type;           // File type
  short major;          // Major device number (T_DEV only)
  short minor;          // Minor device number (T_DEV only)
  short nlink;          // Number of links to inode in file system
  uint size;            // Size of file (bytes)
  uint addrs[NDIRECT+1];   // Data block addresses
};

// Inodes per block.
#define IPB           (BSIZE / sizeof(struct dinode))

// Block containing inode i
#define IBLOCK(i, sb)    (sb.offset+ ((i) / IPB + sb.inodestart) )

// Bitmap bits per block
#define BPB           (BSIZE*8)

// Block of free map containing bit for block b
#define BBLOCK(b, sb) (sb.offset+ (b/BPB + sb.bmapstart))

// Directory is a file containing a sequence of dirent structures.
#define DIRSIZ 14

struct dirent {
  ushort inum;
  char name[DIRSIZ];
};

struct superblock sbs[NPARTITIONS];   // there should be one per dev, but we run with one dev
struct partition partitions[NPARTITIONS];


