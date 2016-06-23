
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 02 43 10 80       	mov    $0x80104302,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 70 92 10 	movl   $0x80109270,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 e0 d6 10 80 	movl   $0x8010d6e0,(%esp)
80100049:	e8 b8 59 00 00       	call   80105a06 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 f0 15 11 80 e4 	movl   $0x801115e4,0x801115f0
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 f4 15 11 80 e4 	movl   $0x801115e4,0x801115f4
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 14 d7 10 80 	movl   $0x8010d714,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 f4 15 11 80    	mov    0x801115f4,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c e4 15 11 80 	movl   $0x801115e4,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 f4 15 11 80       	mov    0x801115f4,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 f4 15 11 80       	mov    %eax,0x801115f4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 e4 15 11 80 	cmpl   $0x801115e4,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 e0 d6 10 80 	movl   $0x8010d6e0,(%esp)
801000bd:	e8 65 59 00 00       	call   80105a27 <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 f4 15 11 80       	mov    0x801115f4,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 e0 d6 10 80 	movl   $0x8010d6e0,(%esp)
80100104:	e8 80 59 00 00       	call   80105a89 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 e0 d6 10 	movl   $0x8010d6e0,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 39 56 00 00       	call   8010575d <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 e4 15 11 80 	cmpl   $0x801115e4,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 f0 15 11 80       	mov    0x801115f0,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 e0 d6 10 80 	movl   $0x8010d6e0,(%esp)
8010017c:	e8 08 59 00 00       	call   80105a89 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 e4 15 11 80 	cmpl   $0x801115e4,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 77 92 10 80 	movl   $0x80109277,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 a9 2e 00 00       	call   80103081 <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 88 92 10 80 	movl   $0x80109288,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 6c 2e 00 00       	call   80103081 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 8f 92 10 80 	movl   $0x8010928f,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 e0 d6 10 80 	movl   $0x8010d6e0,(%esp)
8010023c:	e8 e6 57 00 00       	call   80105a27 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 f4 15 11 80    	mov    0x801115f4,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c e4 15 11 80 	movl   $0x801115e4,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 f4 15 11 80       	mov    0x801115f4,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 f4 15 11 80       	mov    %eax,0x801115f4

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 94 55 00 00       	call   80105836 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 e0 d6 10 80 	movl   $0x8010d6e0,(%esp)
801002a9:	e8 db 57 00 00       	call   80105a89 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 dc 03 00 00       	call   8010076b <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bb:	e8 67 56 00 00       	call   80105a27 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 96 92 10 80 	movl   $0x80109296,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 75 03 00 00       	call   8010076b <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 9f 92 10 80 	movl   $0x8010929f,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9f 02 00 00       	call   8010076b <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 83 02 00 00       	call   8010076b <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 75 02 00 00       	call   8010076b <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 6a 02 00 00       	call   8010076b <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100533:	e8 51 55 00 00       	call   80105a89 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 a6 92 10 80 	movl   $0x801092a6,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 b5 92 10 80 	movl   $0x801092b5,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 44 55 00 00       	call   80105ad8 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 b7 92 10 80 	movl   $0x801092b7,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068e:	78 09                	js     80100699 <cgaputc+0xcf>
80100690:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100697:	7e 0c                	jle    801006a5 <cgaputc+0xdb>
    panic("pos under/overflow");
80100699:	c7 04 24 bb 92 10 80 	movl   $0x801092bb,(%esp)
801006a0:	e8 95 fe ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006a5:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ac:	7e 53                	jle    80100701 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006ae:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006b3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b9:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c5:	00 
801006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ca:	89 04 24             	mov    %eax,(%esp)
801006cd:	e8 78 56 00 00       	call   80105d4a <memmove>
    pos -= 80;
801006d2:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d6:	b8 80 07 00 00       	mov    $0x780,%eax
801006db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006de:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006e9:	01 c9                	add    %ecx,%ecx
801006eb:	01 c8                	add    %ecx,%eax
801006ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801006f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f8:	00 
801006f9:	89 04 24             	mov    %eax,(%esp)
801006fc:	e8 7a 55 00 00       	call   80105c7b <memset>
  }
  
  outb(CRTPORT, 14);
80100701:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100708:	00 
80100709:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100710:	e8 b8 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100722:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100729:	e8 9f fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
8010072e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100735:	00 
80100736:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073d:	e8 8b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100745:	0f b6 c0             	movzbl %al,%eax
80100748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100753:	e8 75 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100771:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 6c fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 26                	jne    801007b0 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100791:	e8 1a 71 00 00       	call   801078b0 <uartputc>
80100796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079d:	e8 0e 71 00 00       	call   801078b0 <uartputc>
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 02 71 00 00       	call   801078b0 <uartputc>
801007ae:	eb 0b                	jmp    801007bb <consputc+0x50>
  } else
    uartputc(c);
801007b0:	8b 45 08             	mov    0x8(%ebp),%eax
801007b3:	89 04 24             	mov    %eax,(%esp)
801007b6:	e8 f5 70 00 00       	call   801078b0 <uartputc>
  cgaputc(c);
801007bb:	8b 45 08             	mov    0x8(%ebp),%eax
801007be:	89 04 24             	mov    %eax,(%esp)
801007c1:	e8 04 fe ff ff       	call   801005ca <cgaputc>
}
801007c6:	c9                   	leave  
801007c7:	c3                   	ret    

801007c8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007c8:	55                   	push   %ebp
801007c9:	89 e5                	mov    %esp,%ebp
801007cb:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d5:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801007dc:	e8 46 52 00 00       	call   80105a27 <acquire>
  while((c = getc()) >= 0){
801007e1:	e9 39 01 00 00       	jmp    8010091f <consoleintr+0x157>
    switch(c){
801007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007e9:	83 f8 10             	cmp    $0x10,%eax
801007ec:	74 1e                	je     8010080c <consoleintr+0x44>
801007ee:	83 f8 10             	cmp    $0x10,%eax
801007f1:	7f 0a                	jg     801007fd <consoleintr+0x35>
801007f3:	83 f8 08             	cmp    $0x8,%eax
801007f6:	74 66                	je     8010085e <consoleintr+0x96>
801007f8:	e9 93 00 00 00       	jmp    80100890 <consoleintr+0xc8>
801007fd:	83 f8 15             	cmp    $0x15,%eax
80100800:	74 31                	je     80100833 <consoleintr+0x6b>
80100802:	83 f8 7f             	cmp    $0x7f,%eax
80100805:	74 57                	je     8010085e <consoleintr+0x96>
80100807:	e9 84 00 00 00       	jmp    80100890 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 07 01 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 e8 18 11 80       	mov    0x801118e8,%eax
8010081d:	83 e8 01             	sub    $0x1,%eax
80100820:	a3 e8 18 11 80       	mov    %eax,0x801118e8
        consputc(BACKSPACE);
80100825:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082c:	e8 3a ff ff ff       	call   8010076b <consputc>
80100831:	eb 01                	jmp    80100834 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100833:	90                   	nop
80100834:	8b 15 e8 18 11 80    	mov    0x801118e8,%edx
8010083a:	a1 e4 18 11 80       	mov    0x801118e4,%eax
8010083f:	39 c2                	cmp    %eax,%edx
80100841:	74 16                	je     80100859 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100843:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100848:	83 e8 01             	sub    $0x1,%eax
8010084b:	83 e0 7f             	and    $0x7f,%eax
8010084e:	0f b6 80 60 18 11 80 	movzbl -0x7feee7a0(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100855:	3c 0a                	cmp    $0xa,%al
80100857:	75 bf                	jne    80100818 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100859:	e9 c1 00 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010085e:	8b 15 e8 18 11 80    	mov    0x801118e8,%edx
80100864:	a1 e4 18 11 80       	mov    0x801118e4,%eax
80100869:	39 c2                	cmp    %eax,%edx
8010086b:	74 1e                	je     8010088b <consoleintr+0xc3>
        input.e--;
8010086d:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100872:	83 e8 01             	sub    $0x1,%eax
80100875:	a3 e8 18 11 80       	mov    %eax,0x801118e8
        consputc(BACKSPACE);
8010087a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100881:	e8 e5 fe ff ff       	call   8010076b <consputc>
      }
      break;
80100886:	e9 94 00 00 00       	jmp    8010091f <consoleintr+0x157>
8010088b:	e9 8f 00 00 00       	jmp    8010091f <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100894:	0f 84 84 00 00 00    	je     8010091e <consoleintr+0x156>
8010089a:	8b 15 e8 18 11 80    	mov    0x801118e8,%edx
801008a0:	a1 e0 18 11 80       	mov    0x801118e0,%eax
801008a5:	29 c2                	sub    %eax,%edx
801008a7:	89 d0                	mov    %edx,%eax
801008a9:	83 f8 7f             	cmp    $0x7f,%eax
801008ac:	77 70                	ja     8010091e <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008b2:	74 05                	je     801008b9 <consoleintr+0xf1>
801008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b7:	eb 05                	jmp    801008be <consoleintr+0xf6>
801008b9:	b8 0a 00 00 00       	mov    $0xa,%eax
801008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c1:	a1 e8 18 11 80       	mov    0x801118e8,%eax
801008c6:	8d 50 01             	lea    0x1(%eax),%edx
801008c9:	89 15 e8 18 11 80    	mov    %edx,0x801118e8
801008cf:	83 e0 7f             	and    $0x7f,%eax
801008d2:	89 c2                	mov    %eax,%edx
801008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d7:	88 82 60 18 11 80    	mov    %al,-0x7feee7a0(%edx)
        consputc(c);
801008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008e0:	89 04 24             	mov    %eax,(%esp)
801008e3:	e8 83 fe ff ff       	call   8010076b <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008ec:	74 18                	je     80100906 <consoleintr+0x13e>
801008ee:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008f2:	74 12                	je     80100906 <consoleintr+0x13e>
801008f4:	a1 e8 18 11 80       	mov    0x801118e8,%eax
801008f9:	8b 15 e0 18 11 80    	mov    0x801118e0,%edx
801008ff:	83 ea 80             	sub    $0xffffff80,%edx
80100902:	39 d0                	cmp    %edx,%eax
80100904:	75 18                	jne    8010091e <consoleintr+0x156>
          input.w = input.e;
80100906:	a1 e8 18 11 80       	mov    0x801118e8,%eax
8010090b:	a3 e4 18 11 80       	mov    %eax,0x801118e4
          wakeup(&input.r);
80100910:	c7 04 24 e0 18 11 80 	movl   $0x801118e0,(%esp)
80100917:	e8 1a 4f 00 00       	call   80105836 <wakeup>
        }
      }
      break;
8010091c:	eb 00                	jmp    8010091e <consoleintr+0x156>
8010091e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010091f:	8b 45 08             	mov    0x8(%ebp),%eax
80100922:	ff d0                	call   *%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010092b:	0f 89 b5 fe ff ff    	jns    801007e6 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100931:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100938:	e8 4c 51 00 00       	call   80105a89 <release>
  if(doprocdump) {
8010093d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100941:	74 05                	je     80100948 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100943:	e8 91 4f 00 00       	call   801058d9 <procdump>
  }
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;
//cprintf("consoleread \n");
  iunlock(ip);
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	89 04 24             	mov    %eax,(%esp)
80100956:	e8 72 16 00 00       	call   80101fcd <iunlock>
  target = n;
8010095b:	8b 45 10             	mov    0x10(%ebp),%eax
8010095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100961:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100968:	e8 ba 50 00 00       	call   80105a27 <acquire>
  while(n > 0){
8010096d:	e9 aa 00 00 00       	jmp    80100a1c <consoleread+0xd2>
    while(input.r == input.w){
80100972:	eb 42                	jmp    801009b6 <consoleread+0x6c>
      if(proc->killed){
80100974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010097a:	8b 40 24             	mov    0x24(%eax),%eax
8010097d:	85 c0                	test   %eax,%eax
8010097f:	74 21                	je     801009a2 <consoleread+0x58>
        release(&cons.lock);
80100981:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100988:	e8 fc 50 00 00       	call   80105a89 <release>
        //cprintf("cRead \n");
        ilock(ip);
8010098d:	8b 45 08             	mov    0x8(%ebp),%eax
80100990:	89 04 24             	mov    %eax,(%esp)
80100993:	e8 9e 14 00 00       	call   80101e36 <ilock>
        return -1;
80100998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099d:	e9 a5 00 00 00       	jmp    80100a47 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801009a2:	c7 44 24 04 c0 c5 10 	movl   $0x8010c5c0,0x4(%esp)
801009a9:	80 
801009aa:	c7 04 24 e0 18 11 80 	movl   $0x801118e0,(%esp)
801009b1:	e8 a7 4d 00 00       	call   8010575d <sleep>
//cprintf("consoleread \n");
  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009b6:	8b 15 e0 18 11 80    	mov    0x801118e0,%edx
801009bc:	a1 e4 18 11 80       	mov    0x801118e4,%eax
801009c1:	39 c2                	cmp    %eax,%edx
801009c3:	74 af                	je     80100974 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009c5:	a1 e0 18 11 80       	mov    0x801118e0,%eax
801009ca:	8d 50 01             	lea    0x1(%eax),%edx
801009cd:	89 15 e0 18 11 80    	mov    %edx,0x801118e0
801009d3:	83 e0 7f             	and    $0x7f,%eax
801009d6:	0f b6 80 60 18 11 80 	movzbl -0x7feee7a0(%eax),%eax
801009dd:	0f be c0             	movsbl %al,%eax
801009e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009e7:	75 19                	jne    80100a02 <consoleread+0xb8>
      if(n < target){
801009e9:	8b 45 10             	mov    0x10(%ebp),%eax
801009ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009ef:	73 0f                	jae    80100a00 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009f1:	a1 e0 18 11 80       	mov    0x801118e0,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 e0 18 11 80       	mov    %eax,0x801118e0
      }
      break;
801009fe:	eb 26                	jmp    80100a26 <consoleread+0xdc>
80100a00:	eb 24                	jmp    80100a26 <consoleread+0xdc>
    }
    *dst++ = c;
80100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a05:	8d 50 01             	lea    0x1(%eax),%edx
80100a08:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a0e:	88 10                	mov    %dl,(%eax)
    --n;
80100a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a14:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a18:	75 02                	jne    80100a1c <consoleread+0xd2>
      break;
80100a1a:	eb 0a                	jmp    80100a26 <consoleread+0xdc>
  int c;
//cprintf("consoleread \n");
  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a20:	0f 8f 4c ff ff ff    	jg     80100972 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a26:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a2d:	e8 57 50 00 00       	call   80105a89 <release>
          //    cprintf("cRead2 \n");

  ilock(ip);
80100a32:	8b 45 08             	mov    0x8(%ebp),%eax
80100a35:	89 04 24             	mov    %eax,(%esp)
80100a38:	e8 f9 13 00 00       	call   80101e36 <ilock>

  return target - n;
80100a3d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	29 c2                	sub    %eax,%edx
80100a45:	89 d0                	mov    %edx,%eax
}
80100a47:	c9                   	leave  
80100a48:	c3                   	ret    

80100a49 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a49:	55                   	push   %ebp
80100a4a:	89 e5                	mov    %esp,%ebp
80100a4c:	83 ec 28             	sub    $0x28,%esp
  int i;
//cprintf("consolewrite \n");

  iunlock(ip);
80100a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a52:	89 04 24             	mov    %eax,(%esp)
80100a55:	e8 73 15 00 00       	call   80101fcd <iunlock>
  acquire(&cons.lock);
80100a5a:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a61:	e8 c1 4f 00 00       	call   80105a27 <acquire>
  for(i = 0; i < n; i++)
80100a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a6d:	eb 1d                	jmp    80100a8c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a75:	01 d0                	add    %edx,%eax
80100a77:	0f b6 00             	movzbl (%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	0f b6 c0             	movzbl %al,%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e3 fc ff ff       	call   8010076b <consputc>
  int i;
//cprintf("consolewrite \n");

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a92:	7c db                	jl     80100a6f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a94:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a9b:	e8 e9 4f 00 00       	call   80105a89 <release>
        //  cprintf("cWrite \n");

  ilock(ip);
80100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 8b 13 00 00       	call   80101e36 <ilock>

  return n;
80100aab:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aae:	c9                   	leave  
80100aaf:	c3                   	ret    

80100ab0 <consoleinit>:

void
consoleinit(void)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ab6:	c7 44 24 04 ce 92 10 	movl   $0x801092ce,0x4(%esp)
80100abd:	80 
80100abe:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100ac5:	e8 3c 4f 00 00       	call   80105a06 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aca:	c7 05 ec 21 11 80 49 	movl   $0x80100a49,0x801121ec
80100ad1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad4:	c7 05 e8 21 11 80 4a 	movl   $0x8010094a,0x801121e8
80100adb:	09 10 80 
  cons.locking = 1;
80100ade:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100ae5:	00 00 00 

  picenable(IRQ_KBD);
80100ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aef:	e8 8a 3e 00 00       	call   8010497e <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afb:	00 
80100afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b03:	e8 35 27 00 00       	call   8010323d <ioapicenable>
}
80100b08:	c9                   	leave  
80100b09:	c3                   	ret    

80100b0a <exec>:
  struct partition *part;  //partition
};

int
exec(char *path, char **argv)
{
80100b0a:	55                   	push   %ebp
80100b0b:	89 e5                	mov    %esp,%ebp
80100b0d:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op(proc->cwd->part->number);
80100b13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100b19:	8b 40 68             	mov    0x68(%eax),%eax
80100b1c:	8b 40 50             	mov    0x50(%eax),%eax
80100b1f:	8b 40 14             	mov    0x14(%eax),%eax
80100b22:	89 04 24             	mov    %eax,(%esp)
80100b25:	e8 e4 32 00 00       	call   80103e0e <begin_op>
  if((ip = namei(path)) == 0){
80100b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80100b2d:	89 04 24             	mov    %eax,(%esp)
80100b30:	e8 28 21 00 00       	call   80102c5d <namei>
80100b35:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b38:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b3c:	75 21                	jne    80100b5f <exec+0x55>
    end_op(proc->cwd->part->number);
80100b3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100b44:	8b 40 68             	mov    0x68(%eax),%eax
80100b47:	8b 40 50             	mov    0x50(%eax),%eax
80100b4a:	8b 40 14             	mov    0x14(%eax),%eax
80100b4d:	89 04 24             	mov    %eax,(%esp)
80100b50:	e8 bb 33 00 00       	call   80103f10 <end_op>
    return -1;
80100b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b5a:	e9 0c 04 00 00       	jmp    80100f6b <exec+0x461>
  }
           // cprintf("exec \n");

  ilock(ip);
80100b5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b62:	89 04 24             	mov    %eax,(%esp)
80100b65:	e8 cc 12 00 00       	call   80101e36 <ilock>

  pgdir = 0;
80100b6a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b71:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b78:	00 
80100b79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b80:	00 
80100b81:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b8e:	89 04 24             	mov    %eax,(%esp)
80100b91:	e8 e7 18 00 00       	call   8010247d <readi>
80100b96:	83 f8 33             	cmp    $0x33,%eax
80100b99:	77 05                	ja     80100ba0 <exec+0x96>
    goto bad;
80100b9b:	e9 8d 03 00 00       	jmp    80100f2d <exec+0x423>
  if(elf.magic != ELF_MAGIC)
80100ba0:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ba6:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bab:	74 05                	je     80100bb2 <exec+0xa8>
    goto bad;
80100bad:	e9 7b 03 00 00       	jmp    80100f2d <exec+0x423>

  if((pgdir = setupkvm()) == 0)
80100bb2:	e8 4a 7e 00 00       	call   80108a01 <setupkvm>
80100bb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bbe:	75 05                	jne    80100bc5 <exec+0xbb>
    goto bad;
80100bc0:	e9 68 03 00 00       	jmp    80100f2d <exec+0x423>

  // Load program into memory.
  sz = 0;
80100bc5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bcc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bd3:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bdc:	e9 cb 00 00 00       	jmp    80100cac <exec+0x1a2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100be1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100be4:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100beb:	00 
80100bec:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bf0:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bfa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bfd:	89 04 24             	mov    %eax,(%esp)
80100c00:	e8 78 18 00 00       	call   8010247d <readi>
80100c05:	83 f8 20             	cmp    $0x20,%eax
80100c08:	74 05                	je     80100c0f <exec+0x105>
      goto bad;
80100c0a:	e9 1e 03 00 00       	jmp    80100f2d <exec+0x423>
    if(ph.type != ELF_PROG_LOAD)
80100c0f:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c15:	83 f8 01             	cmp    $0x1,%eax
80100c18:	74 05                	je     80100c1f <exec+0x115>
      continue;
80100c1a:	e9 80 00 00 00       	jmp    80100c9f <exec+0x195>
    if(ph.memsz < ph.filesz)
80100c1f:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c25:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c2b:	39 c2                	cmp    %eax,%edx
80100c2d:	73 05                	jae    80100c34 <exec+0x12a>
      goto bad;
80100c2f:	e9 f9 02 00 00       	jmp    80100f2d <exec+0x423>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c34:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c3a:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c40:	01 d0                	add    %edx,%eax
80100c42:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c49:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c50:	89 04 24             	mov    %eax,(%esp)
80100c53:	e8 77 81 00 00       	call   80108dcf <allocuvm>
80100c58:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c5b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c5f:	75 05                	jne    80100c66 <exec+0x15c>
      goto bad;
80100c61:	e9 c7 02 00 00       	jmp    80100f2d <exec+0x423>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c66:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c6c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c72:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c78:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c80:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c83:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c8e:	89 04 24             	mov    %eax,(%esp)
80100c91:	e8 4e 80 00 00       	call   80108ce4 <loaduvm>
80100c96:	85 c0                	test   %eax,%eax
80100c98:	79 05                	jns    80100c9f <exec+0x195>
      goto bad;
80100c9a:	e9 8e 02 00 00       	jmp    80100f2d <exec+0x423>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ca3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca6:	83 c0 20             	add    $0x20,%eax
80100ca9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cac:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cb3:	0f b7 c0             	movzwl %ax,%eax
80100cb6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb9:	0f 8f 22 ff ff ff    	jg     80100be1 <exec+0xd7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbf:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cc2:	89 04 24             	mov    %eax,(%esp)
80100cc5:	e8 39 14 00 00       	call   80102103 <iunlockput>
  end_op(proc->cwd->part->number);
80100cca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cd0:	8b 40 68             	mov    0x68(%eax),%eax
80100cd3:	8b 40 50             	mov    0x50(%eax),%eax
80100cd6:	8b 40 14             	mov    0x14(%eax),%eax
80100cd9:	89 04 24             	mov    %eax,(%esp)
80100cdc:	e8 2f 32 00 00       	call   80103f10 <end_op>
  ip = 0;
80100ce1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100ce8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ceb:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cf5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cfb:	05 00 20 00 00       	add    $0x2000,%eax
80100d00:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d07:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d0e:	89 04 24             	mov    %eax,(%esp)
80100d11:	e8 b9 80 00 00       	call   80108dcf <allocuvm>
80100d16:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d1d:	75 05                	jne    80100d24 <exec+0x21a>
    goto bad;
80100d1f:	e9 09 02 00 00       	jmp    80100f2d <exec+0x423>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d24:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d27:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d33:	89 04 24             	mov    %eax,(%esp)
80100d36:	e8 c4 82 00 00       	call   80108fff <clearpteu>
  sp = sz;
80100d3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d3e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d41:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d48:	e9 9a 00 00 00       	jmp    80100de7 <exec+0x2dd>
    if(argc >= MAXARG)
80100d4d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d51:	76 05                	jbe    80100d58 <exec+0x24e>
      goto bad;
80100d53:	e9 d5 01 00 00       	jmp    80100f2d <exec+0x423>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d65:	01 d0                	add    %edx,%eax
80100d67:	8b 00                	mov    (%eax),%eax
80100d69:	89 04 24             	mov    %eax,(%esp)
80100d6c:	e8 74 51 00 00       	call   80105ee5 <strlen>
80100d71:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d74:	29 c2                	sub    %eax,%edx
80100d76:	89 d0                	mov    %edx,%eax
80100d78:	83 e8 01             	sub    $0x1,%eax
80100d7b:	83 e0 fc             	and    $0xfffffffc,%eax
80100d7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d8e:	01 d0                	add    %edx,%eax
80100d90:	8b 00                	mov    (%eax),%eax
80100d92:	89 04 24             	mov    %eax,(%esp)
80100d95:	e8 4b 51 00 00       	call   80105ee5 <strlen>
80100d9a:	83 c0 01             	add    $0x1,%eax
80100d9d:	89 c2                	mov    %eax,%edx
80100d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100da9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dac:	01 c8                	add    %ecx,%eax
80100dae:	8b 00                	mov    (%eax),%eax
80100db0:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100db4:	89 44 24 08          	mov    %eax,0x8(%esp)
80100db8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dbf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dc2:	89 04 24             	mov    %eax,(%esp)
80100dc5:	e8 fa 83 00 00       	call   801091c4 <copyout>
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	79 05                	jns    80100dd3 <exec+0x2c9>
      goto bad;
80100dce:	e9 5a 01 00 00       	jmp    80100f2d <exec+0x423>
    ustack[3+argc] = sp;
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	8d 50 03             	lea    0x3(%eax),%edx
80100dd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddc:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df4:	01 d0                	add    %edx,%eax
80100df6:	8b 00                	mov    (%eax),%eax
80100df8:	85 c0                	test   %eax,%eax
80100dfa:	0f 85 4d ff ff ff    	jne    80100d4d <exec+0x243>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e03:	83 c0 03             	add    $0x3,%eax
80100e06:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0d:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e11:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e18:	ff ff ff 
  ustack[1] = argc;
80100e1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1e:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	83 c0 01             	add    $0x1,%eax
80100e2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e34:	29 d0                	sub    %edx,%eax
80100e36:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3f:	83 c0 04             	add    $0x4,%eax
80100e42:	c1 e0 02             	shl    $0x2,%eax
80100e45:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4b:	83 c0 04             	add    $0x4,%eax
80100e4e:	c1 e0 02             	shl    $0x2,%eax
80100e51:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e55:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e5b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e62:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e69:	89 04 24             	mov    %eax,(%esp)
80100e6c:	e8 53 83 00 00       	call   801091c4 <copyout>
80100e71:	85 c0                	test   %eax,%eax
80100e73:	79 05                	jns    80100e7a <exec+0x370>
    goto bad;
80100e75:	e9 b3 00 00 00       	jmp    80100f2d <exec+0x423>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80100e7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e86:	eb 17                	jmp    80100e9f <exec+0x395>
    if(*s == '/')
80100e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e8b:	0f b6 00             	movzbl (%eax),%eax
80100e8e:	3c 2f                	cmp    $0x2f,%al
80100e90:	75 09                	jne    80100e9b <exec+0x391>
      last = s+1;
80100e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e95:	83 c0 01             	add    $0x1,%eax
80100e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea2:	0f b6 00             	movzbl (%eax),%eax
80100ea5:	84 c0                	test   %al,%al
80100ea7:	75 df                	jne    80100e88 <exec+0x37e>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100ea9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eaf:	8d 50 6c             	lea    0x6c(%eax),%edx
80100eb2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100eb9:	00 
80100eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ec1:	89 14 24             	mov    %edx,(%esp)
80100ec4:	e8 d2 4f 00 00       	call   80105e9b <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecf:	8b 40 04             	mov    0x4(%eax),%eax
80100ed2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ed5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ede:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eea:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100efb:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100efe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f04:	8b 40 18             	mov    0x18(%eax),%eax
80100f07:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f0a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f13:	89 04 24             	mov    %eax,(%esp)
80100f16:	e8 d7 7b 00 00       	call   80108af2 <switchuvm>
  freevm(oldpgdir);
80100f1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1e:	89 04 24             	mov    %eax,(%esp)
80100f21:	e8 3f 80 00 00       	call   80108f65 <freevm>
  return 0;
80100f26:	b8 00 00 00 00       	mov    $0x0,%eax
80100f2b:	eb 3e                	jmp    80100f6b <exec+0x461>

 bad:
  if(pgdir)
80100f2d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f31:	74 0b                	je     80100f3e <exec+0x434>
    freevm(pgdir);
80100f33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f36:	89 04 24             	mov    %eax,(%esp)
80100f39:	e8 27 80 00 00       	call   80108f65 <freevm>
  if(ip){
80100f3e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f42:	74 22                	je     80100f66 <exec+0x45c>
    iunlockput(ip);
80100f44:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f47:	89 04 24             	mov    %eax,(%esp)
80100f4a:	e8 b4 11 00 00       	call   80102103 <iunlockput>
    end_op(proc->cwd->part->number);
80100f4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f55:	8b 40 68             	mov    0x68(%eax),%eax
80100f58:	8b 40 50             	mov    0x50(%eax),%eax
80100f5b:	8b 40 14             	mov    0x14(%eax),%eax
80100f5e:	89 04 24             	mov    %eax,(%esp)
80100f61:	e8 aa 2f 00 00       	call   80103f10 <end_op>
  }
  return -1;
80100f66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f6b:	c9                   	leave  
80100f6c:	c3                   	ret    

80100f6d <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f6d:	55                   	push   %ebp
80100f6e:	89 e5                	mov    %esp,%ebp
80100f70:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f73:	c7 44 24 04 d6 92 10 	movl   $0x801092d6,0x4(%esp)
80100f7a:	80 
80100f7b:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80100f82:	e8 7f 4a 00 00       	call   80105a06 <initlock>
}
80100f87:	c9                   	leave  
80100f88:	c3                   	ret    

80100f89 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f89:	55                   	push   %ebp
80100f8a:	89 e5                	mov    %esp,%ebp
80100f8c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f8f:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80100f96:	e8 8c 4a 00 00       	call   80105a27 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f9b:	c7 45 f4 34 19 11 80 	movl   $0x80111934,-0xc(%ebp)
80100fa2:	eb 29                	jmp    80100fcd <filealloc+0x44>
    if(f->ref == 0){
80100fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa7:	8b 40 04             	mov    0x4(%eax),%eax
80100faa:	85 c0                	test   %eax,%eax
80100fac:	75 1b                	jne    80100fc9 <filealloc+0x40>
      f->ref = 1;
80100fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb1:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fb8:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80100fbf:	e8 c5 4a 00 00       	call   80105a89 <release>
      return f;
80100fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc7:	eb 1e                	jmp    80100fe7 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc9:	83 45 f4 16          	addl   $0x16,-0xc(%ebp)
80100fcd:	81 7d f4 cc 21 11 80 	cmpl   $0x801121cc,-0xc(%ebp)
80100fd4:	72 ce                	jb     80100fa4 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fd6:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80100fdd:	e8 a7 4a 00 00       	call   80105a89 <release>
  return 0;
80100fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fe7:	c9                   	leave  
80100fe8:	c3                   	ret    

80100fe9 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fe9:	55                   	push   %ebp
80100fea:	89 e5                	mov    %esp,%ebp
80100fec:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fef:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80100ff6:	e8 2c 4a 00 00       	call   80105a27 <acquire>
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0c                	jg     80101011 <filedup+0x28>
    panic("filedup");
80101005:	c7 04 24 dd 92 10 80 	movl   $0x801092dd,(%esp)
8010100c:	e8 29 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80101011:	8b 45 08             	mov    0x8(%ebp),%eax
80101014:	8b 40 04             	mov    0x4(%eax),%eax
80101017:	8d 50 01             	lea    0x1(%eax),%edx
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101020:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80101027:	e8 5d 4a 00 00       	call   80105a89 <release>
  return f;
8010102c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010102f:	c9                   	leave  
80101030:	c3                   	ret    

80101031 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101031:	55                   	push   %ebp
80101032:	89 e5                	mov    %esp,%ebp
80101034:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101037:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
8010103e:	e8 e4 49 00 00       	call   80105a27 <acquire>
  if(f->ref < 1)
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	8b 40 04             	mov    0x4(%eax),%eax
80101049:	85 c0                	test   %eax,%eax
8010104b:	7f 0c                	jg     80101059 <fileclose+0x28>
    panic("fileclose");
8010104d:	c7 04 24 e5 92 10 80 	movl   $0x801092e5,(%esp)
80101054:	e8 e1 f4 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101059:	8b 45 08             	mov    0x8(%ebp),%eax
8010105c:	8b 40 04             	mov    0x4(%eax),%eax
8010105f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101062:	8b 45 08             	mov    0x8(%ebp),%eax
80101065:	89 50 04             	mov    %edx,0x4(%eax)
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	8b 40 04             	mov    0x4(%eax),%eax
8010106e:	85 c0                	test   %eax,%eax
80101070:	7e 11                	jle    80101083 <fileclose+0x52>
    release(&ftable.lock);
80101072:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
80101079:	e8 0b 4a 00 00       	call   80105a89 <release>
8010107e:	e9 a2 00 00 00       	jmp    80101125 <fileclose+0xf4>
    return;
  }
  ff = *f;
80101083:	8b 45 08             	mov    0x8(%ebp),%eax
80101086:	8b 10                	mov    (%eax),%edx
80101088:	89 55 e2             	mov    %edx,-0x1e(%ebp)
8010108b:	8b 50 04             	mov    0x4(%eax),%edx
8010108e:	89 55 e6             	mov    %edx,-0x1a(%ebp)
80101091:	8b 50 08             	mov    0x8(%eax),%edx
80101094:	89 55 ea             	mov    %edx,-0x16(%ebp)
80101097:	8b 50 0c             	mov    0xc(%eax),%edx
8010109a:	89 55 ee             	mov    %edx,-0x12(%ebp)
8010109d:	8b 50 10             	mov    0x10(%eax),%edx
801010a0:	89 55 f2             	mov    %edx,-0xe(%ebp)
801010a3:	0f b7 40 14          	movzwl 0x14(%eax),%eax
801010a7:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  f->ref = 0;
801010ab:	8b 45 08             	mov    0x8(%ebp),%eax
801010ae:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010b5:	8b 45 08             	mov    0x8(%ebp),%eax
801010b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010be:	c7 04 24 00 19 11 80 	movl   $0x80111900,(%esp)
801010c5:	e8 bf 49 00 00       	call   80105a89 <release>
  
  if(ff.type == FD_PIPE)
801010ca:	8b 45 e2             	mov    -0x1e(%ebp),%eax
801010cd:	83 f8 01             	cmp    $0x1,%eax
801010d0:	75 18                	jne    801010ea <fileclose+0xb9>
    pipeclose(ff.pipe, ff.writable);
801010d2:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
801010d6:	0f be d0             	movsbl %al,%edx
801010d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801010e0:	89 04 24             	mov    %eax,(%esp)
801010e3:	e8 46 3b 00 00       	call   80104c2e <pipeclose>
801010e8:	eb 3b                	jmp    80101125 <fileclose+0xf4>
  else if(ff.type == FD_INODE){
801010ea:	8b 45 e2             	mov    -0x1e(%ebp),%eax
801010ed:	83 f8 02             	cmp    $0x2,%eax
801010f0:	75 33                	jne    80101125 <fileclose+0xf4>
    begin_op(f->ip->part->number);
801010f2:	8b 45 08             	mov    0x8(%ebp),%eax
801010f5:	8b 40 0e             	mov    0xe(%eax),%eax
801010f8:	8b 40 50             	mov    0x50(%eax),%eax
801010fb:	8b 40 14             	mov    0x14(%eax),%eax
801010fe:	89 04 24             	mov    %eax,(%esp)
80101101:	e8 08 2d 00 00       	call   80103e0e <begin_op>
    iput(ff.ip);
80101106:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101109:	89 04 24             	mov    %eax,(%esp)
8010110c:	e8 21 0f 00 00       	call   80102032 <iput>
    end_op(f->ip->part->number);
80101111:	8b 45 08             	mov    0x8(%ebp),%eax
80101114:	8b 40 0e             	mov    0xe(%eax),%eax
80101117:	8b 40 50             	mov    0x50(%eax),%eax
8010111a:	8b 40 14             	mov    0x14(%eax),%eax
8010111d:	89 04 24             	mov    %eax,(%esp)
80101120:	e8 eb 2d 00 00       	call   80103f10 <end_op>
  }
}
80101125:	c9                   	leave  
80101126:	c3                   	ret    

80101127 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101127:	55                   	push   %ebp
80101128:	89 e5                	mov    %esp,%ebp
8010112a:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010112d:	8b 45 08             	mov    0x8(%ebp),%eax
80101130:	8b 00                	mov    (%eax),%eax
80101132:	83 f8 02             	cmp    $0x2,%eax
80101135:	75 38                	jne    8010116f <filestat+0x48>
      
    ilock(f->ip);
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 40 0e             	mov    0xe(%eax),%eax
8010113d:	89 04 24             	mov    %eax,(%esp)
80101140:	e8 f1 0c 00 00       	call   80101e36 <ilock>
    stati(f->ip, st);
80101145:	8b 45 08             	mov    0x8(%ebp),%eax
80101148:	8b 40 0e             	mov    0xe(%eax),%eax
8010114b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010114e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101152:	89 04 24             	mov    %eax,(%esp)
80101155:	e8 de 12 00 00       	call   80102438 <stati>
   // cprintf("filestat \n");

    iunlock(f->ip);
8010115a:	8b 45 08             	mov    0x8(%ebp),%eax
8010115d:	8b 40 0e             	mov    0xe(%eax),%eax
80101160:	89 04 24             	mov    %eax,(%esp)
80101163:	e8 65 0e 00 00       	call   80101fcd <iunlock>
    return 0;
80101168:	b8 00 00 00 00       	mov    $0x0,%eax
8010116d:	eb 05                	jmp    80101174 <filestat+0x4d>
  }
  return -1;
8010116f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101174:	c9                   	leave  
80101175:	c3                   	ret    

80101176 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101176:	55                   	push   %ebp
80101177:	89 e5                	mov    %esp,%ebp
80101179:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101183:	84 c0                	test   %al,%al
80101185:	75 0a                	jne    80101191 <fileread+0x1b>
    return -1;
80101187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010118c:	e9 9f 00 00 00       	jmp    80101230 <fileread+0xba>
  if(f->type == FD_PIPE)
80101191:	8b 45 08             	mov    0x8(%ebp),%eax
80101194:	8b 00                	mov    (%eax),%eax
80101196:	83 f8 01             	cmp    $0x1,%eax
80101199:	75 1e                	jne    801011b9 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010119b:	8b 45 08             	mov    0x8(%ebp),%eax
8010119e:	8b 40 0a             	mov    0xa(%eax),%eax
801011a1:	8b 55 10             	mov    0x10(%ebp),%edx
801011a4:	89 54 24 08          	mov    %edx,0x8(%esp)
801011a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801011ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801011af:	89 04 24             	mov    %eax,(%esp)
801011b2:	e8 f8 3b 00 00       	call   80104daf <piperead>
801011b7:	eb 77                	jmp    80101230 <fileread+0xba>
  if(f->type == FD_INODE){
801011b9:	8b 45 08             	mov    0x8(%ebp),%eax
801011bc:	8b 00                	mov    (%eax),%eax
801011be:	83 f8 02             	cmp    $0x2,%eax
801011c1:	75 61                	jne    80101224 <fileread+0xae>
    ilock(f->ip);
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	8b 40 0e             	mov    0xe(%eax),%eax
801011c9:	89 04 24             	mov    %eax,(%esp)
801011cc:	e8 65 0c 00 00       	call   80101e36 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011d4:	8b 45 08             	mov    0x8(%ebp),%eax
801011d7:	8b 50 12             	mov    0x12(%eax),%edx
801011da:	8b 45 08             	mov    0x8(%ebp),%eax
801011dd:	8b 40 0e             	mov    0xe(%eax),%eax
801011e0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801011e4:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801011eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801011ef:	89 04 24             	mov    %eax,(%esp)
801011f2:	e8 86 12 00 00       	call   8010247d <readi>
801011f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011fe:	7e 11                	jle    80101211 <fileread+0x9b>
      f->off += r;
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 50 12             	mov    0x12(%eax),%edx
80101206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101209:	01 c2                	add    %eax,%edx
8010120b:	8b 45 08             	mov    0x8(%ebp),%eax
8010120e:	89 50 12             	mov    %edx,0x12(%eax)
   // cprintf("fileread \n");

    iunlock(f->ip);
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 40 0e             	mov    0xe(%eax),%eax
80101217:	89 04 24             	mov    %eax,(%esp)
8010121a:	e8 ae 0d 00 00       	call   80101fcd <iunlock>
    return r;
8010121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101222:	eb 0c                	jmp    80101230 <fileread+0xba>
  }
  panic("fileread");
80101224:	c7 04 24 ef 92 10 80 	movl   $0x801092ef,(%esp)
8010122b:	e8 0a f3 ff ff       	call   8010053a <panic>
}
80101230:	c9                   	leave  
80101231:	c3                   	ret    

80101232 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101232:	55                   	push   %ebp
80101233:	89 e5                	mov    %esp,%ebp
80101235:	53                   	push   %ebx
80101236:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101239:	8b 45 08             	mov    0x8(%ebp),%eax
8010123c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101240:	84 c0                	test   %al,%al
80101242:	75 0a                	jne    8010124e <filewrite+0x1c>
    return -1;
80101244:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101249:	e9 3e 01 00 00       	jmp    8010138c <filewrite+0x15a>
  if(f->type == FD_PIPE)
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	8b 00                	mov    (%eax),%eax
80101253:	83 f8 01             	cmp    $0x1,%eax
80101256:	75 21                	jne    80101279 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101258:	8b 45 08             	mov    0x8(%ebp),%eax
8010125b:	8b 40 0a             	mov    0xa(%eax),%eax
8010125e:	8b 55 10             	mov    0x10(%ebp),%edx
80101261:	89 54 24 08          	mov    %edx,0x8(%esp)
80101265:	8b 55 0c             	mov    0xc(%ebp),%edx
80101268:	89 54 24 04          	mov    %edx,0x4(%esp)
8010126c:	89 04 24             	mov    %eax,(%esp)
8010126f:	e8 4c 3a 00 00       	call   80104cc0 <pipewrite>
80101274:	e9 13 01 00 00       	jmp    8010138c <filewrite+0x15a>
  if(f->type == FD_INODE){
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 00                	mov    (%eax),%eax
8010127e:	83 f8 02             	cmp    $0x2,%eax
80101281:	0f 85 f9 00 00 00    	jne    80101380 <filewrite+0x14e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101287:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010128e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101295:	e9 c6 00 00 00       	jmp    80101360 <filewrite+0x12e>
      int n1 = n - i;
8010129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010129d:	8b 55 10             	mov    0x10(%ebp),%edx
801012a0:	29 c2                	sub    %eax,%edx
801012a2:	89 d0                	mov    %edx,%eax
801012a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012aa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ad:	7e 06                	jle    801012b5 <filewrite+0x83>
        n1 = max;
801012af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012b2:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op(f->ip->part->number);
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 40 0e             	mov    0xe(%eax),%eax
801012bb:	8b 40 50             	mov    0x50(%eax),%eax
801012be:	8b 40 14             	mov    0x14(%eax),%eax
801012c1:	89 04 24             	mov    %eax,(%esp)
801012c4:	e8 45 2b 00 00       	call   80103e0e <begin_op>
      ilock(f->ip);
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8b 40 0e             	mov    0xe(%eax),%eax
801012cf:	89 04 24             	mov    %eax,(%esp)
801012d2:	e8 5f 0b 00 00       	call   80101e36 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012d7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012da:	8b 45 08             	mov    0x8(%ebp),%eax
801012dd:	8b 50 12             	mov    0x12(%eax),%edx
801012e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801012e6:	01 c3                	add    %eax,%ebx
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 40 0e             	mov    0xe(%eax),%eax
801012ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801012f2:	89 54 24 08          	mov    %edx,0x8(%esp)
801012f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801012fa:	89 04 24             	mov    %eax,(%esp)
801012fd:	e8 2a 13 00 00       	call   8010262c <writei>
80101302:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101305:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101309:	7e 11                	jle    8010131c <filewrite+0xea>
        f->off += r;
8010130b:	8b 45 08             	mov    0x8(%ebp),%eax
8010130e:	8b 50 12             	mov    0x12(%eax),%edx
80101311:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101314:	01 c2                	add    %eax,%edx
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	89 50 12             	mov    %edx,0x12(%eax)
       // cprintf("filewrite \n");

      iunlock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 0e             	mov    0xe(%eax),%eax
80101322:	89 04 24             	mov    %eax,(%esp)
80101325:	e8 a3 0c 00 00       	call   80101fcd <iunlock>
      end_op(f->ip->part->number);
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	8b 40 0e             	mov    0xe(%eax),%eax
80101330:	8b 40 50             	mov    0x50(%eax),%eax
80101333:	8b 40 14             	mov    0x14(%eax),%eax
80101336:	89 04 24             	mov    %eax,(%esp)
80101339:	e8 d2 2b 00 00       	call   80103f10 <end_op>

      if(r < 0)
8010133e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101342:	79 02                	jns    80101346 <filewrite+0x114>
        break;
80101344:	eb 26                	jmp    8010136c <filewrite+0x13a>
      if(r != n1)
80101346:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101349:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010134c:	74 0c                	je     8010135a <filewrite+0x128>
        panic("short filewrite");
8010134e:	c7 04 24 f8 92 10 80 	movl   $0x801092f8,(%esp)
80101355:	e8 e0 f1 ff ff       	call   8010053a <panic>
      i += r;
8010135a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010135d:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101363:	3b 45 10             	cmp    0x10(%ebp),%eax
80101366:	0f 8c 2e ff ff ff    	jl     8010129a <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101372:	75 05                	jne    80101379 <filewrite+0x147>
80101374:	8b 45 10             	mov    0x10(%ebp),%eax
80101377:	eb 05                	jmp    8010137e <filewrite+0x14c>
80101379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010137e:	eb 0c                	jmp    8010138c <filewrite+0x15a>
  }
  panic("filewrite");
80101380:	c7 04 24 08 93 10 80 	movl   $0x80109308,(%esp)
80101387:	e8 ae f1 ff ff       	call   8010053a <panic>
}
8010138c:	83 c4 24             	add    $0x24,%esp
8010138f:	5b                   	pop    %ebx
80101390:	5d                   	pop    %ebp
80101391:	c3                   	ret    

80101392 <readsb>:
int bootfrom = -1;
struct file * fstabFd;

// Read the super block.
void readsb(int dev, int partitionNumber)
{
80101392:	55                   	push   %ebp
80101393:	89 e5                	mov    %esp,%ebp
80101395:	83 ec 28             	sub    $0x28,%esp
    struct buf* bp;

    bp = bread(dev, mbrI.partitions[partitionNumber].offset);
80101398:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139b:	83 c0 1b             	add    $0x1b,%eax
8010139e:	c1 e0 04             	shl    $0x4,%eax
801013a1:	05 60 22 11 80       	add    $0x80112260,%eax
801013a6:	8b 50 16             	mov    0x16(%eax),%edx
801013a9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801013b0:	89 04 24             	mov    %eax,(%esp)
801013b3:	e8 ee ed ff ff       	call   801001a6 <bread>
801013b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memmove(&(sbs[partitionNumber]), bp->data, sizeof(struct superblock));
801013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013be:	8d 50 18             	lea    0x18(%eax),%edx
801013c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801013c4:	c1 e0 05             	shl    $0x5,%eax
801013c7:	05 60 d6 10 80       	add    $0x8010d660,%eax
801013cc:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
801013d3:	00 
801013d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801013d8:	89 04 24             	mov    %eax,(%esp)
801013db:	e8 6a 49 00 00       	call   80105d4a <memmove>
    sbs[partitionNumber].offset=mbrI.partitions[partitionNumber].offset;
801013e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801013e3:	83 c0 1b             	add    $0x1b,%eax
801013e6:	c1 e0 04             	shl    $0x4,%eax
801013e9:	05 60 22 11 80       	add    $0x80112260,%eax
801013ee:	8b 40 16             	mov    0x16(%eax),%eax
801013f1:	8b 55 0c             	mov    0xc(%ebp),%edx
801013f4:	c1 e2 05             	shl    $0x5,%edx
801013f7:	81 c2 70 d6 10 80    	add    $0x8010d670,%edx
801013fd:	89 42 0c             	mov    %eax,0xc(%edx)
    brelse(bp);
80101400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101403:	89 04 24             	mov    %eax,(%esp)
80101406:	e8 0c ee ff ff       	call   80100217 <brelse>
}
8010140b:	c9                   	leave  
8010140c:	c3                   	ret    

8010140d <readmbr>:

void readmbr(int dev)
{
8010140d:	55                   	push   %ebp
8010140e:	89 e5                	mov    %esp,%ebp
80101410:	83 ec 28             	sub    $0x28,%esp
    struct buf* bp;

    bp = bread(dev, 0);
80101413:	8b 45 08             	mov    0x8(%ebp),%eax
80101416:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010141d:	00 
8010141e:	89 04 24             	mov    %eax,(%esp)
80101421:	e8 80 ed ff ff       	call   801001a6 <bread>
80101426:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memmove(&mbrI, bp->data, sizeof(struct mbr));
80101429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142c:	83 c0 18             	add    $0x18,%eax
8010142f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101436:	00 
80101437:	89 44 24 04          	mov    %eax,0x4(%esp)
8010143b:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101442:	e8 03 49 00 00       	call   80105d4a <memmove>
    brelse(bp);
80101447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144a:	89 04 24             	mov    %eax,(%esp)
8010144d:	e8 c5 ed ff ff       	call   80100217 <brelse>
}
80101452:	c9                   	leave  
80101453:	c3                   	ret    

80101454 <bzero>:

// Zero a block.
static void bzero(int dev, int bno,uint partitionNumber)
{
80101454:	55                   	push   %ebp
80101455:	89 e5                	mov    %esp,%ebp
80101457:	83 ec 28             	sub    $0x28,%esp
    struct buf* bp;

    bp = bread(dev, bno);
8010145a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010145d:	8b 45 08             	mov    0x8(%ebp),%eax
80101460:	89 54 24 04          	mov    %edx,0x4(%esp)
80101464:	89 04 24             	mov    %eax,(%esp)
80101467:	e8 3a ed ff ff       	call   801001a6 <bread>
8010146c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(bp->data, 0, BSIZE);
8010146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101472:	83 c0 18             	add    $0x18,%eax
80101475:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010147c:	00 
8010147d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101484:	00 
80101485:	89 04 24             	mov    %eax,(%esp)
80101488:	e8 ee 47 00 00       	call   80105c7b <memset>
    log_write(bp,partitionNumber);
8010148d:	8b 45 10             	mov    0x10(%ebp),%eax
80101490:	89 44 24 04          	mov    %eax,0x4(%esp)
80101494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101497:	89 04 24             	mov    %eax,(%esp)
8010149a:	e8 e3 2c 00 00       	call   80104182 <log_write>
    brelse(bp);
8010149f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a2:	89 04 24             	mov    %eax,(%esp)
801014a5:	e8 6d ed ff ff       	call   80100217 <brelse>
}
801014aa:	c9                   	leave  
801014ab:	c3                   	ret    

801014ac <balloc>:

// Blocks.

// Allocate a zeroed disk block.
static uint balloc(uint dev, int partitionNumber)
{
801014ac:	55                   	push   %ebp
801014ad:	89 e5                	mov    %esp,%ebp
801014af:	83 ec 48             	sub    $0x48,%esp
    int b, bi, m;
    struct buf* bp;

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
801014b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801014b5:	c1 e0 05             	shl    $0x5,%eax
801014b8:	05 60 d6 10 80       	add    $0x8010d660,%eax
801014bd:	8b 10                	mov    (%eax),%edx
801014bf:	89 55 c8             	mov    %edx,-0x38(%ebp)
801014c2:	8b 50 04             	mov    0x4(%eax),%edx
801014c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
801014c8:	8b 50 08             	mov    0x8(%eax),%edx
801014cb:	89 55 d0             	mov    %edx,-0x30(%ebp)
801014ce:	8b 50 0c             	mov    0xc(%eax),%edx
801014d1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801014d4:	8b 50 10             	mov    0x10(%eax),%edx
801014d7:	89 55 d8             	mov    %edx,-0x28(%ebp)
801014da:	8b 50 14             	mov    0x14(%eax),%edx
801014dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
801014e0:	8b 50 18             	mov    0x18(%eax),%edx
801014e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801014e6:	8b 40 1c             	mov    0x1c(%eax),%eax
801014e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    bp = 0;
801014ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for (b = 0; b < sb.size; b += BPB) {
801014f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014fa:	e9 1d 01 00 00       	jmp    8010161c <balloc+0x170>
        bp = bread(dev, BBLOCK(b, sb));
801014ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101505:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
8010150b:	85 c0                	test   %eax,%eax
8010150d:	0f 48 c1             	cmovs  %ecx,%eax
80101510:	c1 f8 0c             	sar    $0xc,%eax
80101513:	89 c1                	mov    %eax,%ecx
80101515:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101518:	01 c8                	add    %ecx,%eax
8010151a:	01 d0                	add    %edx,%eax
8010151c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101520:	8b 45 08             	mov    0x8(%ebp),%eax
80101523:	89 04 24             	mov    %eax,(%esp)
80101526:	e8 7b ec ff ff       	call   801001a6 <bread>
8010152b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
8010152e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101535:	e9 b2 00 00 00       	jmp    801015ec <balloc+0x140>
            m = 1 << (bi % 8);
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	99                   	cltd   
8010153e:	c1 ea 1d             	shr    $0x1d,%edx
80101541:	01 d0                	add    %edx,%eax
80101543:	83 e0 07             	and    $0x7,%eax
80101546:	29 d0                	sub    %edx,%eax
80101548:	ba 01 00 00 00       	mov    $0x1,%edx
8010154d:	89 c1                	mov    %eax,%ecx
8010154f:	d3 e2                	shl    %cl,%edx
80101551:	89 d0                	mov    %edx,%eax
80101553:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
80101556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101559:	8d 50 07             	lea    0x7(%eax),%edx
8010155c:	85 c0                	test   %eax,%eax
8010155e:	0f 48 c2             	cmovs  %edx,%eax
80101561:	c1 f8 03             	sar    $0x3,%eax
80101564:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101567:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010156c:	0f b6 c0             	movzbl %al,%eax
8010156f:	23 45 e8             	and    -0x18(%ebp),%eax
80101572:	85 c0                	test   %eax,%eax
80101574:	75 72                	jne    801015e8 <balloc+0x13c>
                bp->data[bi / 8] |= m;         // Mark block in use.
80101576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101579:	8d 50 07             	lea    0x7(%eax),%edx
8010157c:	85 c0                	test   %eax,%eax
8010157e:	0f 48 c2             	cmovs  %edx,%eax
80101581:	c1 f8 03             	sar    $0x3,%eax
80101584:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101587:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010158c:	89 d1                	mov    %edx,%ecx
8010158e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101591:	09 ca                	or     %ecx,%edx
80101593:	89 d1                	mov    %edx,%ecx
80101595:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101598:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
                log_write(bp,partitionNumber);
8010159c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010159f:	89 44 24 04          	mov    %eax,0x4(%esp)
801015a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015a6:	89 04 24             	mov    %eax,(%esp)
801015a9:	e8 d4 2b 00 00       	call   80104182 <log_write>
                brelse(bp);
801015ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015b1:	89 04 24             	mov    %eax,(%esp)
801015b4:	e8 5e ec ff ff       	call   80100217 <brelse>
                bzero(dev, sb.offset +b + bi,partitionNumber);
801015b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801015bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c2:	01 c2                	add    %eax,%edx
801015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c7:	01 d0                	add    %edx,%eax
801015c9:	89 c2                	mov    %eax,%edx
801015cb:	8b 45 08             	mov    0x8(%ebp),%eax
801015ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801015d6:	89 04 24             	mov    %eax,(%esp)
801015d9:	e8 76 fe ff ff       	call   80101454 <bzero>
                return b + bi;
801015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e4:	01 d0                	add    %edx,%eax
801015e6:	eb 4e                	jmp    80101636 <balloc+0x18a>
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
        bp = bread(dev, BBLOCK(b, sb));
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
801015e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015ec:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015f3:	7f 15                	jg     8010160a <balloc+0x15e>
801015f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015fb:	01 d0                	add    %edx,%eax
801015fd:	89 c2                	mov    %eax,%edx
801015ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101602:	39 c2                	cmp    %eax,%edx
80101604:	0f 82 30 ff ff ff    	jb     8010153a <balloc+0x8e>
                brelse(bp);
                bzero(dev, sb.offset +b + bi,partitionNumber);
                return b + bi;
            }
        }
        brelse(bp);
8010160a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010160d:	89 04 24             	mov    %eax,(%esp)
80101610:	e8 02 ec ff ff       	call   80100217 <brelse>

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
80101615:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101622:	39 c2                	cmp    %eax,%edx
80101624:	0f 82 d5 fe ff ff    	jb     801014ff <balloc+0x53>
                return b + bi;
            }
        }
        brelse(bp);
    }
    panic("balloc: out of blocks");
8010162a:	c7 04 24 14 93 10 80 	movl   $0x80109314,(%esp)
80101631:	e8 04 ef ff ff       	call   8010053a <panic>
}
80101636:	c9                   	leave  
80101637:	c3                   	ret    

80101638 <bfree>:

// Free a disk block.
static void bfree(int dev, uint b, int partitionNumber)
{
80101638:	55                   	push   %ebp
80101639:	89 e5                	mov    %esp,%ebp
8010163b:	83 ec 48             	sub    $0x48,%esp
      //  cprintf("bfree \n");

    struct buf* bp;
    int bi, m;
    struct superblock sb;
    sb = sbs[partitionNumber];
8010163e:	8b 45 10             	mov    0x10(%ebp),%eax
80101641:	c1 e0 05             	shl    $0x5,%eax
80101644:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101649:	8b 10                	mov    (%eax),%edx
8010164b:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010164e:	8b 50 04             	mov    0x4(%eax),%edx
80101651:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101654:	8b 50 08             	mov    0x8(%eax),%edx
80101657:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010165a:	8b 50 0c             	mov    0xc(%eax),%edx
8010165d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101660:	8b 50 10             	mov    0x10(%eax),%edx
80101663:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101666:	8b 50 14             	mov    0x14(%eax),%edx
80101669:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010166c:	8b 50 18             	mov    0x18(%eax),%edx
8010166f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101672:	8b 40 1c             	mov    0x1c(%eax),%eax
80101675:	89 45 e8             	mov    %eax,-0x18(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101678:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010167b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010167e:	89 d1                	mov    %edx,%ecx
80101680:	c1 e9 0c             	shr    $0xc,%ecx
80101683:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101686:	01 ca                	add    %ecx,%edx
80101688:	01 c2                	add    %eax,%edx
8010168a:	8b 45 08             	mov    0x8(%ebp),%eax
8010168d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101691:	89 04 24             	mov    %eax,(%esp)
80101694:	e8 0d eb ff ff       	call   801001a6 <bread>
80101699:	89 45 f4             	mov    %eax,-0xc(%ebp)
    bi = b % BPB;
8010169c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010169f:	25 ff 0f 00 00       	and    $0xfff,%eax
801016a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = 1 << (bi % 8);
801016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016aa:	99                   	cltd   
801016ab:	c1 ea 1d             	shr    $0x1d,%edx
801016ae:	01 d0                	add    %edx,%eax
801016b0:	83 e0 07             	and    $0x7,%eax
801016b3:	29 d0                	sub    %edx,%eax
801016b5:	ba 01 00 00 00       	mov    $0x1,%edx
801016ba:	89 c1                	mov    %eax,%ecx
801016bc:	d3 e2                	shl    %cl,%edx
801016be:	89 d0                	mov    %edx,%eax
801016c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if ((bp->data[bi / 8] & m) == 0)
801016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c6:	8d 50 07             	lea    0x7(%eax),%edx
801016c9:	85 c0                	test   %eax,%eax
801016cb:	0f 48 c2             	cmovs  %edx,%eax
801016ce:	c1 f8 03             	sar    $0x3,%eax
801016d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d4:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801016d9:	0f b6 c0             	movzbl %al,%eax
801016dc:	23 45 ec             	and    -0x14(%ebp),%eax
801016df:	85 c0                	test   %eax,%eax
801016e1:	75 0c                	jne    801016ef <bfree+0xb7>
        panic("freeing free block");
801016e3:	c7 04 24 2a 93 10 80 	movl   $0x8010932a,(%esp)
801016ea:	e8 4b ee ff ff       	call   8010053a <panic>
    bp->data[bi / 8] &= ~m;
801016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f2:	8d 50 07             	lea    0x7(%eax),%edx
801016f5:	85 c0                	test   %eax,%eax
801016f7:	0f 48 c2             	cmovs  %edx,%eax
801016fa:	c1 f8 03             	sar    $0x3,%eax
801016fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101700:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101705:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101708:	f7 d1                	not    %ecx
8010170a:	21 ca                	and    %ecx,%edx
8010170c:	89 d1                	mov    %edx,%ecx
8010170e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101711:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
    log_write(bp,partitionNumber);
80101715:	8b 45 10             	mov    0x10(%ebp),%eax
80101718:	89 44 24 04          	mov    %eax,0x4(%esp)
8010171c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171f:	89 04 24             	mov    %eax,(%esp)
80101722:	e8 5b 2a 00 00       	call   80104182 <log_write>
    brelse(bp);
80101727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010172a:	89 04 24             	mov    %eax,(%esp)
8010172d:	e8 e5 ea ff ff       	call   80100217 <brelse>
}
80101732:	c9                   	leave  
80101733:	c3                   	ret    

80101734 <printMBR>:
    struct spinlock lock;
    struct inode inode[NINODE];
} icache;

void printMBR(struct mbr* m)
{
80101734:	55                   	push   %ebp
80101735:	89 e5                	mov    %esp,%ebp
80101737:	83 ec 38             	sub    $0x38,%esp


    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
8010173a:	c7 04 24 3d 93 10 80 	movl   $0x8010933d,(%esp)
80101741:	e8 5a ec ff ff       	call   801003a0 <cprintf>
    for (i = 0; i < NPARTITIONS; i++) {
80101746:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010174d:	e9 02 01 00 00       	jmp    80101854 <printMBR+0x120>
        if (m->partitions[i].flags >1 && m->partitions[i].flags <4) {
80101752:	8b 45 08             	mov    0x8(%ebp),%eax
80101755:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101758:	83 c2 1b             	add    $0x1b,%edx
8010175b:	c1 e2 04             	shl    $0x4,%edx
8010175e:	01 d0                	add    %edx,%eax
80101760:	8b 40 0e             	mov    0xe(%eax),%eax
80101763:	83 f8 01             	cmp    $0x1,%eax
80101766:	76 1f                	jbe    80101787 <printMBR+0x53>
80101768:	8b 45 08             	mov    0x8(%ebp),%eax
8010176b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010176e:	83 c2 1b             	add    $0x1b,%edx
80101771:	c1 e2 04             	shl    $0x4,%edx
80101774:	01 d0                	add    %edx,%eax
80101776:	8b 40 0e             	mov    0xe(%eax),%eax
80101779:	83 f8 03             	cmp    $0x3,%eax
8010177c:	77 09                	ja     80101787 <printMBR+0x53>
            bootable = "YES";
8010177e:	c7 45 f0 48 93 10 80 	movl   $0x80109348,-0x10(%ebp)
80101785:	eb 07                	jmp    8010178e <printMBR+0x5a>

        } else {
            bootable = "NO";
80101787:	c7 45 f0 4c 93 10 80 	movl   $0x8010934c,-0x10(%ebp)
        }

        if (m->partitions[i].type >= 0 && m->partitions[i].type < NELEM(FS_TYPE) && FS_TYPE[m->partitions[i].type]) {
8010178e:	8b 45 08             	mov    0x8(%ebp),%eax
80101791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101794:	83 c2 1b             	add    $0x1b,%edx
80101797:	c1 e2 04             	shl    $0x4,%edx
8010179a:	01 d0                	add    %edx,%eax
8010179c:	8b 40 12             	mov    0x12(%eax),%eax
8010179f:	83 f8 01             	cmp    $0x1,%eax
801017a2:	77 39                	ja     801017dd <printMBR+0xa9>
801017a4:	8b 45 08             	mov    0x8(%ebp),%eax
801017a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017aa:	83 c2 1b             	add    $0x1b,%edx
801017ad:	c1 e2 04             	shl    $0x4,%edx
801017b0:	01 d0                	add    %edx,%eax
801017b2:	8b 40 12             	mov    0x12(%eax),%eax
801017b5:	8b 04 85 1c a0 10 80 	mov    -0x7fef5fe4(,%eax,4),%eax
801017bc:	85 c0                	test   %eax,%eax
801017be:	74 1d                	je     801017dd <printMBR+0xa9>
            type = FS_TYPE[m->partitions[i].type];
801017c0:	8b 45 08             	mov    0x8(%ebp),%eax
801017c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c6:	83 c2 1b             	add    $0x1b,%edx
801017c9:	c1 e2 04             	shl    $0x4,%edx
801017cc:	01 d0                	add    %edx,%eax
801017ce:	8b 40 12             	mov    0x12(%eax),%eax
801017d1:	8b 04 85 1c a0 10 80 	mov    -0x7fef5fe4(,%eax,4),%eax
801017d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801017db:	eb 28                	jmp    80101805 <printMBR+0xd1>

        } else {
            type = "???";
801017dd:	c7 45 ec 4f 93 10 80 	movl   $0x8010934f,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
801017e4:	8b 45 08             	mov    0x8(%ebp),%eax
801017e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017ea:	83 c2 1b             	add    $0x1b,%edx
801017ed:	c1 e2 04             	shl    $0x4,%edx
801017f0:	01 d0                	add    %edx,%eax
801017f2:	8b 40 12             	mov    0x12(%eax),%eax
801017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801017f9:	c7 04 24 53 93 10 80 	movl   $0x80109353,(%esp)
80101800:	e8 9b eb ff ff       	call   801003a0 <cprintf>
        }

        cprintf("partition %d: bootable %s type %s offset %d size %d \n",
80101805:	8b 45 08             	mov    0x8(%ebp),%eax
80101808:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010180b:	83 c2 1b             	add    $0x1b,%edx
8010180e:	c1 e2 04             	shl    $0x4,%edx
80101811:	01 d0                	add    %edx,%eax
80101813:	8b 50 1a             	mov    0x1a(%eax),%edx
80101816:	8b 45 08             	mov    0x8(%ebp),%eax
80101819:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010181c:	83 c1 1b             	add    $0x1b,%ecx
8010181f:	c1 e1 04             	shl    $0x4,%ecx
80101822:	01 c8                	add    %ecx,%eax
80101824:	8b 40 16             	mov    0x16(%eax),%eax
80101827:	89 54 24 14          	mov    %edx,0x14(%esp)
8010182b:	89 44 24 10          	mov    %eax,0x10(%esp)
8010182f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101832:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101836:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101839:	89 44 24 08          	mov    %eax,0x8(%esp)
8010183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101840:	89 44 24 04          	mov    %eax,0x4(%esp)
80101844:	c7 04 24 68 93 10 80 	movl   $0x80109368,(%esp)
8010184b:	e8 50 eb ff ff       	call   801003a0 <cprintf>

    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
    for (i = 0; i < NPARTITIONS; i++) {
80101850:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101854:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80101858:	0f 8e f4 fe ff ff    	jle    80101752 <printMBR+0x1e>
                bootable,
                type,
                m->partitions[i].offset,
                m->partitions[i].size);
    }
    cprintf("magic %s \n", m->magic);
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	05 fe 01 00 00       	add    $0x1fe,%eax
80101866:	89 44 24 04          	mov    %eax,0x4(%esp)
8010186a:	c7 04 24 9e 93 10 80 	movl   $0x8010939e,(%esp)
80101871:	e8 2a eb ff ff       	call   801003a0 <cprintf>
}
80101876:	c9                   	leave  
80101877:	c3                   	ret    

80101878 <initMbr>:

void initMbr(int dev)
{
80101878:	55                   	push   %ebp
80101879:	89 e5                	mov    %esp,%ebp
8010187b:	83 ec 28             	sub    $0x28,%esp

   
    readmbr(dev);
8010187e:	8b 45 08             	mov    0x8(%ebp),%eax
80101881:	89 04 24             	mov    %eax,(%esp)
80101884:	e8 84 fb ff ff       	call   8010140d <readmbr>
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
80101889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101890:	e9 ec 00 00 00       	jmp    80101981 <initMbr+0x109>
        if (mbrI.partitions[i].flags >= PART_BOOTABLE && bootfrom == -1) {
80101895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101898:	83 c0 1b             	add    $0x1b,%eax
8010189b:	c1 e0 04             	shl    $0x4,%eax
8010189e:	05 60 22 11 80       	add    $0x80112260,%eax
801018a3:	8b 40 0e             	mov    0xe(%eax),%eax
801018a6:	83 f8 01             	cmp    $0x1,%eax
801018a9:	76 12                	jbe    801018bd <initMbr+0x45>
801018ab:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801018b0:	83 f8 ff             	cmp    $0xffffffff,%eax
801018b3:	75 08                	jne    801018bd <initMbr+0x45>
            bootfrom = i;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	a3 18 a0 10 80       	mov    %eax,0x8010a018
            
        }
        partitions[i].dev = dev;
801018bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801018c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018c3:	89 d0                	mov    %edx,%eax
801018c5:	01 c0                	add    %eax,%eax
801018c7:	01 d0                	add    %edx,%eax
801018c9:	c1 e0 03             	shl    $0x3,%eax
801018cc:	05 00 18 11 80       	add    $0x80111800,%eax
801018d1:	89 08                	mov    %ecx,(%eax)
        partitions[i].flags = mbrI.partitions[i].flags;
801018d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d6:	83 c0 1b             	add    $0x1b,%eax
801018d9:	c1 e0 04             	shl    $0x4,%eax
801018dc:	05 60 22 11 80       	add    $0x80112260,%eax
801018e1:	8b 48 0e             	mov    0xe(%eax),%ecx
801018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018e7:	89 d0                	mov    %edx,%eax
801018e9:	01 c0                	add    %eax,%eax
801018eb:	01 d0                	add    %edx,%eax
801018ed:	c1 e0 03             	shl    $0x3,%eax
801018f0:	05 00 18 11 80       	add    $0x80111800,%eax
801018f5:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].type = mbrI.partitions[i].type;
801018f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fb:	83 c0 1b             	add    $0x1b,%eax
801018fe:	c1 e0 04             	shl    $0x4,%eax
80101901:	05 60 22 11 80       	add    $0x80112260,%eax
80101906:	8b 48 12             	mov    0x12(%eax),%ecx
80101909:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010190c:	89 d0                	mov    %edx,%eax
8010190e:	01 c0                	add    %eax,%eax
80101910:	01 d0                	add    %edx,%eax
80101912:	c1 e0 03             	shl    $0x3,%eax
80101915:	05 00 18 11 80       	add    $0x80111800,%eax
8010191a:	89 48 08             	mov    %ecx,0x8(%eax)
        partitions[i].number = i;
8010191d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80101920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101923:	89 d0                	mov    %edx,%eax
80101925:	01 c0                	add    %eax,%eax
80101927:	01 d0                	add    %edx,%eax
80101929:	c1 e0 03             	shl    $0x3,%eax
8010192c:	05 10 18 11 80       	add    $0x80111810,%eax
80101931:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].offset = mbrI.partitions[i].offset;
80101934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101937:	83 c0 1b             	add    $0x1b,%eax
8010193a:	c1 e0 04             	shl    $0x4,%eax
8010193d:	05 60 22 11 80       	add    $0x80112260,%eax
80101942:	8b 48 16             	mov    0x16(%eax),%ecx
80101945:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101948:	89 d0                	mov    %edx,%eax
8010194a:	01 c0                	add    %eax,%eax
8010194c:	01 d0                	add    %edx,%eax
8010194e:	c1 e0 03             	shl    $0x3,%eax
80101951:	05 00 18 11 80       	add    $0x80111800,%eax
80101956:	89 48 0c             	mov    %ecx,0xc(%eax)
        partitions[i].size = mbrI.partitions[i].size;
80101959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195c:	83 c0 1b             	add    $0x1b,%eax
8010195f:	c1 e0 04             	shl    $0x4,%eax
80101962:	05 60 22 11 80       	add    $0x80112260,%eax
80101967:	8b 48 1a             	mov    0x1a(%eax),%ecx
8010196a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010196d:	89 d0                	mov    %edx,%eax
8010196f:	01 c0                	add    %eax,%eax
80101971:	01 d0                	add    %edx,%eax
80101973:	c1 e0 03             	shl    $0x3,%eax
80101976:	05 10 18 11 80       	add    $0x80111810,%eax
8010197b:	89 08                	mov    %ecx,(%eax)

   
    readmbr(dev);
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
8010197d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101981:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80101985:	0f 8e 0a ff ff ff    	jle    80101895 <initMbr+0x1d>
        partitions[i].size = mbrI.partitions[i].size;
    }


    
}
8010198b:	c9                   	leave  
8010198c:	c3                   	ret    

8010198d <iinit>:

int iinit(struct proc* p, int dev)
{
8010198d:	55                   	push   %ebp
8010198e:	89 e5                	mov    %esp,%ebp
80101990:	57                   	push   %edi
80101991:	56                   	push   %esi
80101992:	53                   	push   %ebx
80101993:	83 ec 6c             	sub    $0x6c,%esp
    struct inode* rootNode;
    struct superblock sb;
    // TODO: change ot iterate over all partitions

    initlock(&icache.lock, "icache");
80101996:	c7 44 24 04 a9 93 10 	movl   $0x801093a9,0x4(%esp)
8010199d:	80 
8010199e:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
801019a5:	e8 5c 40 00 00       	call   80105a06 <initlock>

    rootNode = p->cwd;
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	8b 40 68             	mov    0x68(%eax),%eax
801019b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // acquire(&icache.lock);

    initMbr(dev);
801019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801019b6:	89 04 24             	mov    %eax,(%esp)
801019b9:	e8 ba fe ff ff       	call   80101878 <initMbr>
    printMBR(&mbrI);
801019be:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019c5:	e8 6a fd ff ff       	call   80101734 <printMBR>
    cprintf("booting from %d \n",bootfrom);
801019ca:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801019cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801019d3:	c7 04 24 b0 93 10 80 	movl   $0x801093b0,(%esp)
801019da:	e8 c1 e9 ff ff       	call   801003a0 <cprintf>
    if (bootfrom == -1) {
801019df:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801019e4:	83 f8 ff             	cmp    $0xffffffff,%eax
801019e7:	75 0c                	jne    801019f5 <iinit+0x68>
        panic("no bootable partition");
801019e9:	c7 04 24 c2 93 10 80 	movl   $0x801093c2,(%esp)
801019f0:	e8 45 eb ff ff       	call   8010053a <panic>
    }
    rootNode->part = &(partitions[bootfrom]);
801019f5:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
801019fb:	89 d0                	mov    %edx,%eax
801019fd:	01 c0                	add    %eax,%eax
801019ff:	01 d0                	add    %edx,%eax
80101a01:	c1 e0 03             	shl    $0x3,%eax
80101a04:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101a0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101a0d:	89 50 50             	mov    %edx,0x50(%eax)
    int i;
    for(i=0;i<NPARTITIONS;i++){
80101a10:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101a17:	e9 a0 00 00 00       	jmp    80101abc <iinit+0x12f>
    readsb(dev, i);
80101a1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a23:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a26:	89 04 24             	mov    %eax,(%esp)
80101a29:	e8 64 f9 ff ff       	call   80101392 <readsb>
    sb = sbs[i];
80101a2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a31:	c1 e0 05             	shl    $0x5,%eax
80101a34:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101a39:	8b 10                	mov    (%eax),%edx
80101a3b:	89 55 c0             	mov    %edx,-0x40(%ebp)
80101a3e:	8b 50 04             	mov    0x4(%eax),%edx
80101a41:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80101a44:	8b 50 08             	mov    0x8(%eax),%edx
80101a47:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101a4a:	8b 50 0c             	mov    0xc(%eax),%edx
80101a4d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101a50:	8b 50 10             	mov    0x10(%eax),%edx
80101a53:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101a56:	8b 50 14             	mov    0x14(%eax),%edx
80101a59:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101a5c:	8b 50 18             	mov    0x18(%eax),%edx
80101a5f:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101a62:	8b 40 1c             	mov    0x1c(%eax),%eax
80101a65:	89 45 dc             	mov    %eax,-0x24(%ebp)
     cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
80101a68:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101a6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101a6e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80101a71:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80101a74:	89 4d b0             	mov    %ecx,-0x50(%ebp)
80101a77:	8b 7d cc             	mov    -0x34(%ebp),%edi
80101a7a:	8b 75 c8             	mov    -0x38(%ebp),%esi
80101a7d:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
80101a80:	8b 4d c0             	mov    -0x40(%ebp),%ecx
80101a83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101a86:	89 54 24 20          	mov    %edx,0x20(%esp)
80101a8a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
80101a8d:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80101a91:	8b 55 b0             	mov    -0x50(%ebp),%edx
80101a94:	89 54 24 18          	mov    %edx,0x18(%esp)
80101a98:	89 7c 24 14          	mov    %edi,0x14(%esp)
80101a9c:	89 74 24 10          	mov    %esi,0x10(%esp)
80101aa0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101aa4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
80101aac:	c7 04 24 d8 93 10 80 	movl   $0x801093d8,(%esp)
80101ab3:	e8 e8 e8 ff ff       	call   801003a0 <cprintf>
    if (bootfrom == -1) {
        panic("no bootable partition");
    }
    rootNode->part = &(partitions[bootfrom]);
    int i;
    for(i=0;i<NPARTITIONS;i++){
80101ab8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101abc:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80101ac0:	0f 8e 56 ff ff ff    	jle    80101a1c <iinit+0x8f>

    // cprintf("root node init %d \n",rootNode->part->offset);
   
            
    
            return bootfrom;
80101ac6:	a1 18 a0 10 80       	mov    0x8010a018,%eax
}
80101acb:	83 c4 6c             	add    $0x6c,%esp
80101ace:	5b                   	pop    %ebx
80101acf:	5e                   	pop    %esi
80101ad0:	5f                   	pop    %edi
80101ad1:	5d                   	pop    %ebp
80101ad2:	c3                   	ret    

80101ad3 <ialloc>:

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
80101ad3:	55                   	push   %ebp
80101ad4:	89 e5                	mov    %esp,%ebp
80101ad6:	83 ec 48             	sub    $0x48,%esp
80101ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101adc:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
     //cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
80101ae0:	8b 45 10             	mov    0x10(%ebp),%eax
80101ae3:	c1 e0 05             	shl    $0x5,%eax
80101ae6:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101aeb:	8b 10                	mov    (%eax),%edx
80101aed:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101af0:	8b 50 04             	mov    0x4(%eax),%edx
80101af3:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101af6:	8b 50 08             	mov    0x8(%eax),%edx
80101af9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101afc:	8b 50 0c             	mov    0xc(%eax),%edx
80101aff:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101b02:	8b 50 10             	mov    0x10(%eax),%edx
80101b05:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101b08:	8b 50 14             	mov    0x14(%eax),%edx
80101b0b:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101b0e:	8b 50 18             	mov    0x18(%eax),%edx
80101b11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101b14:	8b 40 1c             	mov    0x1c(%eax),%eax
80101b17:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101b1a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101b21:	e9 af 00 00 00       	jmp    80101bd5 <ialloc+0x102>
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
80101b26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b2c:	89 d1                	mov    %edx,%ecx
80101b2e:	c1 e9 03             	shr    $0x3,%ecx
80101b31:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101b34:	01 ca                	add    %ecx,%edx
80101b36:	01 d0                	add    %edx,%eax
80101b38:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	89 04 24             	mov    %eax,(%esp)
80101b42:	e8 5f e6 ff ff       	call   801001a6 <bread>
80101b47:	89 45 f0             	mov    %eax,-0x10(%ebp)
        dip = (struct dinode*)bp->data + inum % IPB;
80101b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b4d:	8d 50 18             	lea    0x18(%eax),%edx
80101b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b53:	83 e0 07             	and    $0x7,%eax
80101b56:	c1 e0 06             	shl    $0x6,%eax
80101b59:	01 d0                	add    %edx,%eax
80101b5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (dip->type == 0) { // a free inode
80101b5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b61:	0f b7 00             	movzwl (%eax),%eax
80101b64:	66 85 c0             	test   %ax,%ax
80101b67:	75 5d                	jne    80101bc6 <ialloc+0xf3>
            memset(dip, 0, sizeof(*dip));
80101b69:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101b70:	00 
80101b71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101b78:	00 
80101b79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b7c:	89 04 24             	mov    %eax,(%esp)
80101b7f:	e8 f7 40 00 00       	call   80105c7b <memset>
            dip->type = type;
80101b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b87:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
80101b8b:	66 89 10             	mov    %dx,(%eax)
            log_write(bp,partitionNumber); // mark it allocated on the disk
80101b8e:	8b 45 10             	mov    0x10(%ebp),%eax
80101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b98:	89 04 24             	mov    %eax,(%esp)
80101b9b:	e8 e2 25 00 00       	call   80104182 <log_write>
            brelse(bp);
80101ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba3:	89 04 24             	mov    %eax,(%esp)
80101ba6:	e8 6c e6 ff ff       	call   80100217 <brelse>
            return iget(dev, inum, partitionNumber);
80101bab:	8b 55 10             	mov    0x10(%ebp),%edx
80101bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb1:	89 54 24 08          	mov    %edx,0x8(%esp)
80101bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	89 04 24             	mov    %eax,(%esp)
80101bbf:	e8 3b 01 00 00       	call   80101cff <iget>
80101bc4:	eb 29                	jmp    80101bef <ialloc+0x11c>
        }
        brelse(bp);
80101bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc9:	89 04 24             	mov    %eax,(%esp)
80101bcc:	e8 46 e6 ff ff       	call   80100217 <brelse>
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101bd1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101bd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101bdb:	39 c2                	cmp    %eax,%edx
80101bdd:	0f 82 43 ff ff ff    	jb     80101b26 <ialloc+0x53>
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
80101be3:	c7 04 24 35 94 10 80 	movl   $0x80109435,(%esp)
80101bea:	e8 4b e9 ff ff       	call   8010053a <panic>
}
80101bef:	c9                   	leave  
80101bf0:	c3                   	ret    

80101bf1 <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{
80101bf1:	55                   	push   %ebp
80101bf2:	89 e5                	mov    %esp,%ebp
80101bf4:	83 ec 48             	sub    $0x48,%esp

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	8b 40 50             	mov    0x50(%eax),%eax
80101bfd:	8b 40 14             	mov    0x14(%eax),%eax
80101c00:	c1 e0 05             	shl    $0x5,%eax
80101c03:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101c08:	8b 10                	mov    (%eax),%edx
80101c0a:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101c0d:	8b 50 04             	mov    0x4(%eax),%edx
80101c10:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101c13:	8b 50 08             	mov    0x8(%eax),%edx
80101c16:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101c19:	8b 50 0c             	mov    0xc(%eax),%edx
80101c1c:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101c1f:	8b 50 10             	mov    0x10(%eax),%edx
80101c22:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101c25:	8b 50 14             	mov    0x14(%eax),%edx
80101c28:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101c2b:	8b 50 18             	mov    0x18(%eax),%edx
80101c2e:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101c31:	8b 40 1c             	mov    0x1c(%eax),%eax
80101c34:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101c37:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 40 04             	mov    0x4(%eax),%eax
80101c40:	c1 e8 03             	shr    $0x3,%eax
80101c43:	89 c1                	mov    %eax,%ecx
80101c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c48:	01 c8                	add    %ecx,%eax
80101c4a:	01 c2                	add    %eax,%edx
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 00                	mov    (%eax),%eax
80101c51:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c55:	89 04 24             	mov    %eax,(%esp)
80101c58:	e8 49 e5 ff ff       	call   801001a6 <bread>
80101c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum % IPB;
80101c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c63:	8d 50 18             	lea    0x18(%eax),%edx
80101c66:	8b 45 08             	mov    0x8(%ebp),%eax
80101c69:	8b 40 04             	mov    0x4(%eax),%eax
80101c6c:	83 e0 07             	and    $0x7,%eax
80101c6f:	c1 e0 06             	shl    $0x6,%eax
80101c72:	01 d0                	add    %edx,%eax
80101c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip->type = ip->type;
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c81:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8e:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9c:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101caa:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 50 18             	mov    0x18(%eax),%edx
80101cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb7:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	8d 50 1c             	lea    0x1c(%eax),%edx
80101cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc3:	83 c0 0c             	add    $0xc,%eax
80101cc6:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101ccd:	00 
80101cce:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cd2:	89 04 24             	mov    %eax,(%esp)
80101cd5:	e8 70 40 00 00       	call   80105d4a <memmove>
    log_write(bp,ip->part->number);
80101cda:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdd:	8b 40 50             	mov    0x50(%eax),%eax
80101ce0:	8b 40 14             	mov    0x14(%eax),%eax
80101ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cea:	89 04 24             	mov    %eax,(%esp)
80101ced:	e8 90 24 00 00       	call   80104182 <log_write>
    brelse(bp);
80101cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf5:	89 04 24             	mov    %eax,(%esp)
80101cf8:	e8 1a e5 ff ff       	call   80100217 <brelse>
}
80101cfd:	c9                   	leave  
80101cfe:	c3                   	ret    

80101cff <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
80101cff:	55                   	push   %ebp
80101d00:	89 e5                	mov    %esp,%ebp
80101d02:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip, *empty;

    acquire(&icache.lock);
80101d05:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101d0c:	e8 16 3d 00 00       	call   80105a27 <acquire>
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
80101d11:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101d18:	c7 45 f4 94 24 11 80 	movl   $0x80112494,-0xc(%ebp)
80101d1f:	eb 74                	jmp    80101d95 <iget+0x96>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
80101d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d24:	8b 40 08             	mov    0x8(%eax),%eax
80101d27:	85 c0                	test   %eax,%eax
80101d29:	7e 50                	jle    80101d7b <iget+0x7c>
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	8b 00                	mov    (%eax),%eax
80101d30:	3b 45 08             	cmp    0x8(%ebp),%eax
80101d33:	75 46                	jne    80101d7b <iget+0x7c>
80101d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d38:	8b 40 04             	mov    0x4(%eax),%eax
80101d3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101d3e:	75 3b                	jne    80101d7b <iget+0x7c>
80101d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d43:	8b 40 50             	mov    0x50(%eax),%eax
80101d46:	85 c0                	test   %eax,%eax
80101d48:	74 31                	je     80101d7b <iget+0x7c>
80101d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4d:	8b 40 50             	mov    0x50(%eax),%eax
80101d50:	8b 40 14             	mov    0x14(%eax),%eax
80101d53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101d56:	75 23                	jne    80101d7b <iget+0x7c>
            ip->ref++;
80101d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5b:	8b 40 08             	mov    0x8(%eax),%eax
80101d5e:	8d 50 01             	lea    0x1(%eax),%edx
80101d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d64:	89 50 08             	mov    %edx,0x8(%eax)
            release(&icache.lock);
80101d67:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101d6e:	e8 16 3d 00 00       	call   80105a89 <release>
            return ip;
80101d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d76:	e9 87 00 00 00       	jmp    80101e02 <iget+0x103>
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101d7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101d7f:	75 10                	jne    80101d91 <iget+0x92>
80101d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d84:	8b 40 08             	mov    0x8(%eax),%eax
80101d87:	85 c0                	test   %eax,%eax
80101d89:	75 06                	jne    80101d91 <iget+0x92>
            empty = ip;
80101d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&icache.lock);
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101d91:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101d95:	81 7d f4 fc 34 11 80 	cmpl   $0x801134fc,-0xc(%ebp)
80101d9c:	72 83                	jb     80101d21 <iget+0x22>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
80101d9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101da2:	75 0c                	jne    80101db0 <iget+0xb1>
        panic("iget: no inodes");
80101da4:	c7 04 24 47 94 10 80 	movl   $0x80109447,(%esp)
80101dab:	e8 8a e7 ff ff       	call   8010053a <panic>

    ip = empty;
80101db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101db3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip->dev = dev;
80101db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101db9:	8b 55 08             	mov    0x8(%ebp),%edx
80101dbc:	89 10                	mov    %edx,(%eax)
    ip->inum = inum;
80101dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dc4:	89 50 04             	mov    %edx,0x4(%eax)
    ip->part = &(partitions[partitionNumber]);
80101dc7:	8b 55 10             	mov    0x10(%ebp),%edx
80101dca:	89 d0                	mov    %edx,%eax
80101dcc:	01 c0                	add    %eax,%eax
80101dce:	01 d0                	add    %edx,%eax
80101dd0:	c1 e0 03             	shl    $0x3,%eax
80101dd3:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ddc:	89 50 50             	mov    %edx,0x50(%eax)
    ip->ref = 1;
80101ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    ip->flags = 0;
80101de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dec:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    release(&icache.lock);
80101df3:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101dfa:	e8 8a 3c 00 00       	call   80105a89 <release>

    return ip;
80101dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101e02:	c9                   	leave  
80101e03:	c3                   	ret    

80101e04 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
80101e04:	55                   	push   %ebp
80101e05:	89 e5                	mov    %esp,%ebp
80101e07:	83 ec 18             	sub    $0x18,%esp
             //   cprintf("idup \n");

    acquire(&icache.lock);
80101e0a:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101e11:	e8 11 3c 00 00       	call   80105a27 <acquire>
    ip->ref++;
80101e16:	8b 45 08             	mov    0x8(%ebp),%eax
80101e19:	8b 40 08             	mov    0x8(%eax),%eax
80101e1c:	8d 50 01             	lea    0x1(%eax),%edx
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101e25:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101e2c:	e8 58 3c 00 00       	call   80105a89 <release>
    return ip;
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101e34:	c9                   	leave  
80101e35:	c3                   	ret    

80101e36 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
80101e36:	55                   	push   %ebp
80101e37:	89 e5                	mov    %esp,%ebp
80101e39:	83 ec 48             	sub    $0x48,%esp
    struct buf* bp;
    struct dinode* dip;
                 //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
80101e3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101e40:	74 0a                	je     80101e4c <ilock+0x16>
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	8b 40 08             	mov    0x8(%eax),%eax
80101e48:	85 c0                	test   %eax,%eax
80101e4a:	7f 0c                	jg     80101e58 <ilock+0x22>
        panic("ilock");
80101e4c:	c7 04 24 57 94 10 80 	movl   $0x80109457,(%esp)
80101e53:	e8 e2 e6 ff ff       	call   8010053a <panic>

    acquire(&icache.lock);
80101e58:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101e5f:	e8 c3 3b 00 00       	call   80105a27 <acquire>
    while (ip->flags & I_BUSY)
80101e64:	eb 13                	jmp    80101e79 <ilock+0x43>
        sleep(ip, &icache.lock);
80101e66:	c7 44 24 04 60 24 11 	movl   $0x80112460,0x4(%esp)
80101e6d:	80 
80101e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e71:	89 04 24             	mov    %eax,(%esp)
80101e74:	e8 e4 38 00 00       	call   8010575d <sleep>

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
80101e79:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7c:	8b 40 0c             	mov    0xc(%eax),%eax
80101e7f:	83 e0 01             	and    $0x1,%eax
80101e82:	85 c0                	test   %eax,%eax
80101e84:	75 e0                	jne    80101e66 <ilock+0x30>
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	8b 40 0c             	mov    0xc(%eax),%eax
80101e8c:	83 c8 01             	or     $0x1,%eax
80101e8f:	89 c2                	mov    %eax,%edx
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101e97:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80101e9e:	e8 e6 3b 00 00       	call   80105a89 <release>

    if (!(ip->flags & I_VALID)) {
80101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea6:	8b 40 0c             	mov    0xc(%eax),%eax
80101ea9:	83 e0 02             	and    $0x2,%eax
80101eac:	85 c0                	test   %eax,%eax
80101eae:	0f 85 17 01 00 00    	jne    80101fcb <ilock+0x195>
        struct superblock sb;
        sb = sbs[ip->part->number];
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	8b 40 50             	mov    0x50(%eax),%eax
80101eba:	8b 40 14             	mov    0x14(%eax),%eax
80101ebd:	c1 e0 05             	shl    $0x5,%eax
80101ec0:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101ec5:	8b 10                	mov    (%eax),%edx
80101ec7:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101eca:	8b 50 04             	mov    0x4(%eax),%edx
80101ecd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101ed0:	8b 50 08             	mov    0x8(%eax),%edx
80101ed3:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101ed6:	8b 50 0c             	mov    0xc(%eax),%edx
80101ed9:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101edc:	8b 50 10             	mov    0x10(%eax),%edx
80101edf:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ee2:	8b 50 14             	mov    0x14(%eax),%edx
80101ee5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101ee8:	8b 50 18             	mov    0x18(%eax),%edx
80101eeb:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101eee:	8b 40 1c             	mov    0x1c(%eax),%eax
80101ef1:	89 45 ec             	mov    %eax,-0x14(%ebp)
       // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ef4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 40 04             	mov    0x4(%eax),%eax
80101efd:	c1 e8 03             	shr    $0x3,%eax
80101f00:	89 c1                	mov    %eax,%ecx
80101f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101f05:	01 c8                	add    %ecx,%eax
80101f07:	01 c2                	add    %eax,%edx
80101f09:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0c:	8b 00                	mov    (%eax),%eax
80101f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f12:	89 04 24             	mov    %eax,(%esp)
80101f15:	e8 8c e2 ff ff       	call   801001a6 <bread>
80101f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        dip = (struct dinode*)bp->data + ip->inum % IPB;
80101f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f20:	8d 50 18             	lea    0x18(%eax),%edx
80101f23:	8b 45 08             	mov    0x8(%ebp),%eax
80101f26:	8b 40 04             	mov    0x4(%eax),%eax
80101f29:	83 e0 07             	and    $0x7,%eax
80101f2c:	c1 e0 06             	shl    $0x6,%eax
80101f2f:	01 d0                	add    %edx,%eax
80101f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ip->type = dip->type;
80101f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f37:	0f b7 10             	movzwl (%eax),%edx
80101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3d:	66 89 50 10          	mov    %dx,0x10(%eax)
        ip->major = dip->major;
80101f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f44:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101f48:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4b:	66 89 50 12          	mov    %dx,0x12(%eax)
        ip->minor = dip->minor;
80101f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f52:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	66 89 50 14          	mov    %dx,0x14(%eax)
        ip->nlink = dip->nlink;
80101f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f60:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101f64:	8b 45 08             	mov    0x8(%ebp),%eax
80101f67:	66 89 50 16          	mov    %dx,0x16(%eax)
        ip->size = dip->size;
80101f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f6e:	8b 50 08             	mov    0x8(%eax),%edx
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	89 50 18             	mov    %edx,0x18(%eax)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f7a:	8d 50 0c             	lea    0xc(%eax),%edx
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	83 c0 1c             	add    $0x1c,%eax
80101f83:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101f8a:	00 
80101f8b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f8f:	89 04 24             	mov    %eax,(%esp)
80101f92:	e8 b3 3d 00 00       	call   80105d4a <memmove>
        brelse(bp);
80101f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f9a:	89 04 24             	mov    %eax,(%esp)
80101f9d:	e8 75 e2 ff ff       	call   80100217 <brelse>
        ip->flags |= I_VALID;
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	8b 40 0c             	mov    0xc(%eax),%eax
80101fa8:	83 c8 02             	or     $0x2,%eax
80101fab:	89 c2                	mov    %eax,%edx
80101fad:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb0:	89 50 0c             	mov    %edx,0xc(%eax)
        if (ip->type == 0)
80101fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fba:	66 85 c0             	test   %ax,%ax
80101fbd:	75 0c                	jne    80101fcb <ilock+0x195>
            panic("ilock: no type");
80101fbf:	c7 04 24 5d 94 10 80 	movl   $0x8010945d,(%esp)
80101fc6:	e8 6f e5 ff ff       	call   8010053a <panic>
    }
}
80101fcb:	c9                   	leave  
80101fcc:	c3                   	ret    

80101fcd <iunlock>:

// Unlock the given inode.
void iunlock(struct inode* ip)
{
80101fcd:	55                   	push   %ebp
80101fce:	89 e5                	mov    %esp,%ebp
80101fd0:	83 ec 18             	sub    $0x18,%esp
                  //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
80101fd3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101fd7:	74 17                	je     80101ff0 <iunlock+0x23>
80101fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdc:	8b 40 0c             	mov    0xc(%eax),%eax
80101fdf:	83 e0 01             	and    $0x1,%eax
80101fe2:	85 c0                	test   %eax,%eax
80101fe4:	74 0a                	je     80101ff0 <iunlock+0x23>
80101fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe9:	8b 40 08             	mov    0x8(%eax),%eax
80101fec:	85 c0                	test   %eax,%eax
80101fee:	7f 0c                	jg     80101ffc <iunlock+0x2f>
        // cprintf("iunlock ilock%d ",ip);
        panic("iunlock");
80101ff0:	c7 04 24 6c 94 10 80 	movl   $0x8010946c,(%esp)
80101ff7:	e8 3e e5 ff ff       	call   8010053a <panic>
    }

    acquire(&icache.lock);
80101ffc:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
80102003:	e8 1f 3a 00 00       	call   80105a27 <acquire>
    ip->flags &= ~I_BUSY;
80102008:	8b 45 08             	mov    0x8(%ebp),%eax
8010200b:	8b 40 0c             	mov    0xc(%eax),%eax
8010200e:	83 e0 fe             	and    $0xfffffffe,%eax
80102011:	89 c2                	mov    %eax,%edx
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	89 50 0c             	mov    %edx,0xc(%eax)
    wakeup(ip);
80102019:	8b 45 08             	mov    0x8(%ebp),%eax
8010201c:	89 04 24             	mov    %eax,(%esp)
8010201f:	e8 12 38 00 00       	call   80105836 <wakeup>
    release(&icache.lock);
80102024:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
8010202b:	e8 59 3a 00 00       	call   80105a89 <release>
}
80102030:	c9                   	leave  
80102031:	c3                   	ret    

80102032 <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
80102032:	55                   	push   %ebp
80102033:	89 e5                	mov    %esp,%ebp
80102035:	83 ec 18             	sub    $0x18,%esp
                       // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
80102038:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
8010203f:	e8 e3 39 00 00       	call   80105a27 <acquire>
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	8b 40 08             	mov    0x8(%eax),%eax
8010204a:	83 f8 01             	cmp    $0x1,%eax
8010204d:	0f 85 93 00 00 00    	jne    801020e6 <iput+0xb4>
80102053:	8b 45 08             	mov    0x8(%ebp),%eax
80102056:	8b 40 0c             	mov    0xc(%eax),%eax
80102059:	83 e0 02             	and    $0x2,%eax
8010205c:	85 c0                	test   %eax,%eax
8010205e:	0f 84 82 00 00 00    	je     801020e6 <iput+0xb4>
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010206b:	66 85 c0             	test   %ax,%ax
8010206e:	75 76                	jne    801020e6 <iput+0xb4>
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	8b 40 0c             	mov    0xc(%eax),%eax
80102076:	83 e0 01             	and    $0x1,%eax
80102079:	85 c0                	test   %eax,%eax
8010207b:	74 0c                	je     80102089 <iput+0x57>
            panic("iput busy");
8010207d:	c7 04 24 74 94 10 80 	movl   $0x80109474,(%esp)
80102084:	e8 b1 e4 ff ff       	call   8010053a <panic>
        ip->flags |= I_BUSY;
80102089:	8b 45 08             	mov    0x8(%ebp),%eax
8010208c:	8b 40 0c             	mov    0xc(%eax),%eax
8010208f:	83 c8 01             	or     $0x1,%eax
80102092:	89 c2                	mov    %eax,%edx
80102094:	8b 45 08             	mov    0x8(%ebp),%eax
80102097:	89 50 0c             	mov    %edx,0xc(%eax)
        release(&icache.lock);
8010209a:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
801020a1:	e8 e3 39 00 00       	call   80105a89 <release>
        itrunc(ip);
801020a6:	8b 45 08             	mov    0x8(%ebp),%eax
801020a9:	89 04 24             	mov    %eax,(%esp)
801020ac:	e8 fc 01 00 00       	call   801022ad <itrunc>
        ip->type = 0;
801020b1:	8b 45 08             	mov    0x8(%ebp),%eax
801020b4:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
        iupdate(ip);
801020ba:	8b 45 08             	mov    0x8(%ebp),%eax
801020bd:	89 04 24             	mov    %eax,(%esp)
801020c0:	e8 2c fb ff ff       	call   80101bf1 <iupdate>
        acquire(&icache.lock);
801020c5:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
801020cc:	e8 56 39 00 00       	call   80105a27 <acquire>
        ip->flags = 0;
801020d1:	8b 45 08             	mov    0x8(%ebp),%eax
801020d4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801020db:	8b 45 08             	mov    0x8(%ebp),%eax
801020de:	89 04 24             	mov    %eax,(%esp)
801020e1:	e8 50 37 00 00       	call   80105836 <wakeup>
    }
    ip->ref--;
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	8b 40 08             	mov    0x8(%eax),%eax
801020ec:	8d 50 ff             	lea    -0x1(%eax),%edx
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
801020f5:	c7 04 24 60 24 11 80 	movl   $0x80112460,(%esp)
801020fc:	e8 88 39 00 00       	call   80105a89 <release>
}
80102101:	c9                   	leave  
80102102:	c3                   	ret    

80102103 <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
80102103:	55                   	push   %ebp
80102104:	89 e5                	mov    %esp,%ebp
80102106:	83 ec 18             	sub    $0x18,%esp
    iunlock(ip);
80102109:	8b 45 08             	mov    0x8(%ebp),%eax
8010210c:	89 04 24             	mov    %eax,(%esp)
8010210f:	e8 b9 fe ff ff       	call   80101fcd <iunlock>
    iput(ip);
80102114:	8b 45 08             	mov    0x8(%ebp),%eax
80102117:	89 04 24             	mov    %eax,(%esp)
8010211a:	e8 13 ff ff ff       	call   80102032 <iput>
}
8010211f:	c9                   	leave  
80102120:	c3                   	ret    

80102121 <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
80102121:	55                   	push   %ebp
80102122:	89 e5                	mov    %esp,%ebp
80102124:	53                   	push   %ebx
80102125:	83 ec 44             	sub    $0x44,%esp
                       //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
struct superblock sb;
sb=sbs[ip->part->number];
80102128:	8b 45 08             	mov    0x8(%ebp),%eax
8010212b:	8b 40 50             	mov    0x50(%eax),%eax
8010212e:	8b 40 14             	mov    0x14(%eax),%eax
80102131:	c1 e0 05             	shl    $0x5,%eax
80102134:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102139:	8b 10                	mov    (%eax),%edx
8010213b:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010213e:	8b 50 04             	mov    0x4(%eax),%edx
80102141:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102144:	8b 50 08             	mov    0x8(%eax),%edx
80102147:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010214a:	8b 50 0c             	mov    0xc(%eax),%edx
8010214d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102150:	8b 50 10             	mov    0x10(%eax),%edx
80102153:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102156:	8b 50 14             	mov    0x14(%eax),%edx
80102159:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010215c:	8b 50 18             	mov    0x18(%eax),%edx
8010215f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80102162:	8b 40 1c             	mov    0x1c(%eax),%eax
80102165:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (bn < NDIRECT) {
80102168:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
8010216c:	77 4d                	ja     801021bb <bmap+0x9a>
        if ((addr = ip->addrs[bn]) == 0)
8010216e:	8b 45 08             	mov    0x8(%ebp),%eax
80102171:	8b 55 0c             	mov    0xc(%ebp),%edx
80102174:	83 c2 04             	add    $0x4,%edx
80102177:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010217b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010217e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102182:	75 2f                	jne    801021b3 <bmap+0x92>
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
80102184:	8b 45 08             	mov    0x8(%ebp),%eax
80102187:	8b 40 50             	mov    0x50(%eax),%eax
8010218a:	8b 40 14             	mov    0x14(%eax),%eax
8010218d:	89 c2                	mov    %eax,%edx
8010218f:	8b 45 08             	mov    0x8(%ebp),%eax
80102192:	8b 00                	mov    (%eax),%eax
80102194:	89 54 24 04          	mov    %edx,0x4(%esp)
80102198:	89 04 24             	mov    %eax,(%esp)
8010219b:	e8 0c f3 ff ff       	call   801014ac <balloc>
801021a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	8b 55 0c             	mov    0xc(%ebp),%edx
801021a9:	8d 4a 04             	lea    0x4(%edx),%ecx
801021ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021af:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
       // cprintf("addr %d \n ",addr);
        return addr;
801021b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b6:	e9 ec 00 00 00       	jmp    801022a7 <bmap+0x186>
    }
    bn -= NDIRECT;
801021bb:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

    if (bn < NINDIRECT) {
801021bf:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801021c3:	0f 87 d2 00 00 00    	ja     8010229b <bmap+0x17a>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801021c9:	8b 45 08             	mov    0x8(%ebp),%eax
801021cc:	8b 40 4c             	mov    0x4c(%eax),%eax
801021cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801021d6:	75 28                	jne    80102200 <bmap+0xdf>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	8b 40 50             	mov    0x50(%eax),%eax
801021de:	8b 40 14             	mov    0x14(%eax),%eax
801021e1:	89 c2                	mov    %eax,%edx
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	8b 00                	mov    (%eax),%eax
801021e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801021ec:	89 04 24             	mov    %eax,(%esp)
801021ef:	e8 b8 f2 ff ff       	call   801014ac <balloc>
801021f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021f7:	8b 45 08             	mov    0x8(%ebp),%eax
801021fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021fd:	89 50 4c             	mov    %edx,0x4c(%eax)
        bp = bread(ip->dev, sb.offset+addr);
80102200:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102206:	01 c2                	add    %eax,%edx
80102208:	8b 45 08             	mov    0x8(%ebp),%eax
8010220b:	8b 00                	mov    (%eax),%eax
8010220d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102211:	89 04 24             	mov    %eax,(%esp)
80102214:	e8 8d df ff ff       	call   801001a6 <bread>
80102219:	89 45 f0             	mov    %eax,-0x10(%ebp)
        a = (uint*)bp->data;
8010221c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010221f:	83 c0 18             	add    $0x18,%eax
80102222:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if ((addr = a[bn]) == 0) {
80102225:	8b 45 0c             	mov    0xc(%ebp),%eax
80102228:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010222f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102232:	01 d0                	add    %edx,%eax
80102234:	8b 00                	mov    (%eax),%eax
80102236:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102239:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010223d:	75 4c                	jne    8010228b <bmap+0x16a>
            a[bn] = addr = balloc(ip->dev, ip->part->number);
8010223f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102242:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102249:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010224c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010224f:	8b 45 08             	mov    0x8(%ebp),%eax
80102252:	8b 40 50             	mov    0x50(%eax),%eax
80102255:	8b 40 14             	mov    0x14(%eax),%eax
80102258:	89 c2                	mov    %eax,%edx
8010225a:	8b 45 08             	mov    0x8(%ebp),%eax
8010225d:	8b 00                	mov    (%eax),%eax
8010225f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102263:	89 04 24             	mov    %eax,(%esp)
80102266:	e8 41 f2 ff ff       	call   801014ac <balloc>
8010226b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102271:	89 03                	mov    %eax,(%ebx)
            log_write(bp,ip->part->number);
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	8b 40 50             	mov    0x50(%eax),%eax
80102279:	8b 40 14             	mov    0x14(%eax),%eax
8010227c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102280:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102283:	89 04 24             	mov    %eax,(%esp)
80102286:	e8 f7 1e 00 00       	call   80104182 <log_write>
        }
        brelse(bp);
8010228b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010228e:	89 04 24             	mov    %eax,(%esp)
80102291:	e8 81 df ff ff       	call   80100217 <brelse>
        return addr;
80102296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102299:	eb 0c                	jmp    801022a7 <bmap+0x186>
    }

    panic("bmap: out of range");
8010229b:	c7 04 24 7e 94 10 80 	movl   $0x8010947e,(%esp)
801022a2:	e8 93 e2 ff ff       	call   8010053a <panic>
}
801022a7:	83 c4 44             	add    $0x44,%esp
801022aa:	5b                   	pop    %ebx
801022ab:	5d                   	pop    %ebp
801022ac:	c3                   	ret    

801022ad <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
801022ad:	55                   	push   %ebp
801022ae:	89 e5                	mov    %esp,%ebp
801022b0:	83 ec 48             	sub    $0x48,%esp

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
801022b3:	8b 45 08             	mov    0x8(%ebp),%eax
801022b6:	8b 40 50             	mov    0x50(%eax),%eax
801022b9:	8b 40 14             	mov    0x14(%eax),%eax
801022bc:	c1 e0 05             	shl    $0x5,%eax
801022bf:	05 60 d6 10 80       	add    $0x8010d660,%eax
801022c4:	8b 10                	mov    (%eax),%edx
801022c6:	89 55 c8             	mov    %edx,-0x38(%ebp)
801022c9:	8b 50 04             	mov    0x4(%eax),%edx
801022cc:	89 55 cc             	mov    %edx,-0x34(%ebp)
801022cf:	8b 50 08             	mov    0x8(%eax),%edx
801022d2:	89 55 d0             	mov    %edx,-0x30(%ebp)
801022d5:	8b 50 0c             	mov    0xc(%eax),%edx
801022d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801022db:	8b 50 10             	mov    0x10(%eax),%edx
801022de:	89 55 d8             	mov    %edx,-0x28(%ebp)
801022e1:	8b 50 14             	mov    0x14(%eax),%edx
801022e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
801022e7:	8b 50 18             	mov    0x18(%eax),%edx
801022ea:	89 55 e0             	mov    %edx,-0x20(%ebp)
801022ed:	8b 40 1c             	mov    0x1c(%eax),%eax
801022f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < NDIRECT; i++) {
801022f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022fa:	eb 53                	jmp    8010234f <itrunc+0xa2>
        if (ip->addrs[i]) {
801022fc:	8b 45 08             	mov    0x8(%ebp),%eax
801022ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102302:	83 c2 04             	add    $0x4,%edx
80102305:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102309:	85 c0                	test   %eax,%eax
8010230b:	74 3e                	je     8010234b <itrunc+0x9e>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
8010230d:	8b 45 08             	mov    0x8(%ebp),%eax
80102310:	8b 40 50             	mov    0x50(%eax),%eax
80102313:	8b 40 14             	mov    0x14(%eax),%eax
80102316:	89 c1                	mov    %eax,%ecx
80102318:	8b 45 08             	mov    0x8(%ebp),%eax
8010231b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010231e:	83 c2 04             	add    $0x4,%edx
80102321:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80102325:	8b 45 08             	mov    0x8(%ebp),%eax
80102328:	8b 00                	mov    (%eax),%eax
8010232a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010232e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102332:	89 04 24             	mov    %eax,(%esp)
80102335:	e8 fe f2 ff ff       	call   80101638 <bfree>
            ip->addrs[i] = 0;
8010233a:	8b 45 08             	mov    0x8(%ebp),%eax
8010233d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102340:	83 c2 04             	add    $0x4,%edx
80102343:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010234a:	00 
    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
8010234b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010234f:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102353:	7e a7                	jle    801022fc <itrunc+0x4f>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
80102355:	8b 45 08             	mov    0x8(%ebp),%eax
80102358:	8b 40 4c             	mov    0x4c(%eax),%eax
8010235b:	85 c0                	test   %eax,%eax
8010235d:	0f 84 be 00 00 00    	je     80102421 <itrunc+0x174>
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
80102363:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102366:	8b 45 08             	mov    0x8(%ebp),%eax
80102369:	8b 40 4c             	mov    0x4c(%eax),%eax
8010236c:	01 c2                	add    %eax,%edx
8010236e:	8b 45 08             	mov    0x8(%ebp),%eax
80102371:	8b 00                	mov    (%eax),%eax
80102373:	89 54 24 04          	mov    %edx,0x4(%esp)
80102377:	89 04 24             	mov    %eax,(%esp)
8010237a:	e8 27 de ff ff       	call   801001a6 <bread>
8010237f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        a = (uint*)bp->data;
80102382:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102385:	83 c0 18             	add    $0x18,%eax
80102388:	89 45 e8             	mov    %eax,-0x18(%ebp)
        for (j = 0; j < NINDIRECT; j++) {
8010238b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102392:	eb 4a                	jmp    801023de <itrunc+0x131>
            if (a[j])
80102394:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102397:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010239e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801023a1:	01 d0                	add    %edx,%eax
801023a3:	8b 00                	mov    (%eax),%eax
801023a5:	85 c0                	test   %eax,%eax
801023a7:	74 31                	je     801023da <itrunc+0x12d>
                bfree(ip->dev, a[j], ip->part->number);
801023a9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ac:	8b 40 50             	mov    0x50(%eax),%eax
801023af:	8b 40 14             	mov    0x14(%eax),%eax
801023b2:	89 c1                	mov    %eax,%ecx
801023b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801023be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801023c1:	01 d0                	add    %edx,%eax
801023c3:	8b 10                	mov    (%eax),%edx
801023c5:	8b 45 08             	mov    0x8(%ebp),%eax
801023c8:	8b 00                	mov    (%eax),%eax
801023ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801023ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801023d2:	89 04 24             	mov    %eax,(%esp)
801023d5:	e8 5e f2 ff ff       	call   80101638 <bfree>
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
801023da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801023de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e1:	83 f8 7f             	cmp    $0x7f,%eax
801023e4:	76 ae                	jbe    80102394 <itrunc+0xe7>
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
801023e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023e9:	89 04 24             	mov    %eax,(%esp)
801023ec:	e8 26 de ff ff       	call   80100217 <brelse>
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
801023f1:	8b 45 08             	mov    0x8(%ebp),%eax
801023f4:	8b 40 50             	mov    0x50(%eax),%eax
801023f7:	8b 40 14             	mov    0x14(%eax),%eax
801023fa:	89 c1                	mov    %eax,%ecx
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	8b 50 4c             	mov    0x4c(%eax),%edx
80102402:	8b 45 08             	mov    0x8(%ebp),%eax
80102405:	8b 00                	mov    (%eax),%eax
80102407:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010240b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010240f:	89 04 24             	mov    %eax,(%esp)
80102412:	e8 21 f2 ff ff       	call   80101638 <bfree>
        ip->addrs[NDIRECT] = 0;
80102417:	8b 45 08             	mov    0x8(%ebp),%eax
8010241a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }

    ip->size = 0;
80102421:	8b 45 08             	mov    0x8(%ebp),%eax
80102424:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    iupdate(ip);
8010242b:	8b 45 08             	mov    0x8(%ebp),%eax
8010242e:	89 04 24             	mov    %eax,(%esp)
80102431:	e8 bb f7 ff ff       	call   80101bf1 <iupdate>
}
80102436:	c9                   	leave  
80102437:	c3                   	ret    

80102438 <stati>:

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
80102438:	55                   	push   %ebp
80102439:	89 e5                	mov    %esp,%ebp
    st->dev = ip->dev;
8010243b:	8b 45 08             	mov    0x8(%ebp),%eax
8010243e:	8b 00                	mov    (%eax),%eax
80102440:	89 c2                	mov    %eax,%edx
80102442:	8b 45 0c             	mov    0xc(%ebp),%eax
80102445:	89 50 04             	mov    %edx,0x4(%eax)
    st->ino = ip->inum;
80102448:	8b 45 08             	mov    0x8(%ebp),%eax
8010244b:	8b 50 04             	mov    0x4(%eax),%edx
8010244e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102451:	89 50 08             	mov    %edx,0x8(%eax)
    st->type = ip->type;
80102454:	8b 45 08             	mov    0x8(%ebp),%eax
80102457:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010245b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010245e:	66 89 10             	mov    %dx,(%eax)
    st->nlink = ip->nlink;
80102461:	8b 45 08             	mov    0x8(%ebp),%eax
80102464:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102468:	8b 45 0c             	mov    0xc(%ebp),%eax
8010246b:	66 89 50 0c          	mov    %dx,0xc(%eax)
    st->size = ip->size;
8010246f:	8b 45 08             	mov    0x8(%ebp),%eax
80102472:	8b 50 18             	mov    0x18(%eax),%edx
80102475:	8b 45 0c             	mov    0xc(%ebp),%eax
80102478:	89 50 10             	mov    %edx,0x10(%eax)
}
8010247b:	5d                   	pop    %ebp
8010247c:	c3                   	ret    

8010247d <readi>:

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
8010247d:	55                   	push   %ebp
8010247e:	89 e5                	mov    %esp,%ebp
80102480:	83 ec 48             	sub    $0x48,%esp
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
                      //      cprintf("readi \n");
    sb=sbs[ip->part->number];
80102483:	8b 45 08             	mov    0x8(%ebp),%eax
80102486:	8b 40 50             	mov    0x50(%eax),%eax
80102489:	8b 40 14             	mov    0x14(%eax),%eax
8010248c:	c1 e0 05             	shl    $0x5,%eax
8010248f:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102494:	8b 10                	mov    (%eax),%edx
80102496:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102499:	8b 50 04             	mov    0x4(%eax),%edx
8010249c:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010249f:	8b 50 08             	mov    0x8(%eax),%edx
801024a2:	89 55 d0             	mov    %edx,-0x30(%ebp)
801024a5:	8b 50 0c             	mov    0xc(%eax),%edx
801024a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801024ab:	8b 50 10             	mov    0x10(%eax),%edx
801024ae:	89 55 d8             	mov    %edx,-0x28(%ebp)
801024b1:	8b 50 14             	mov    0x14(%eax),%edx
801024b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
801024b7:	8b 50 18             	mov    0x18(%eax),%edx
801024ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
801024bd:	8b 40 1c             	mov    0x1c(%eax),%eax
801024c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ip->type == T_DEV) {
801024c3:	8b 45 08             	mov    0x8(%ebp),%eax
801024c6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024ca:	66 83 f8 03          	cmp    $0x3,%ax
801024ce:	75 60                	jne    80102530 <readi+0xb3>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801024d0:	8b 45 08             	mov    0x8(%ebp),%eax
801024d3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024d7:	66 85 c0             	test   %ax,%ax
801024da:	78 20                	js     801024fc <readi+0x7f>
801024dc:	8b 45 08             	mov    0x8(%ebp),%eax
801024df:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024e3:	66 83 f8 09          	cmp    $0x9,%ax
801024e7:	7f 13                	jg     801024fc <readi+0x7f>
801024e9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024f0:	98                   	cwtl   
801024f1:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
801024f8:	85 c0                	test   %eax,%eax
801024fa:	75 0a                	jne    80102506 <readi+0x89>
            return -1;
801024fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102501:	e9 24 01 00 00       	jmp    8010262a <readi+0x1ad>
        return devsw[ip->major].read(ip, dst, n);
80102506:	8b 45 08             	mov    0x8(%ebp),%eax
80102509:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010250d:	98                   	cwtl   
8010250e:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80102515:	8b 55 14             	mov    0x14(%ebp),%edx
80102518:	89 54 24 08          	mov    %edx,0x8(%esp)
8010251c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010251f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102523:	8b 55 08             	mov    0x8(%ebp),%edx
80102526:	89 14 24             	mov    %edx,(%esp)
80102529:	ff d0                	call   *%eax
8010252b:	e9 fa 00 00 00       	jmp    8010262a <readi+0x1ad>
    }

    if (off > ip->size || off + n < off)
80102530:	8b 45 08             	mov    0x8(%ebp),%eax
80102533:	8b 40 18             	mov    0x18(%eax),%eax
80102536:	3b 45 10             	cmp    0x10(%ebp),%eax
80102539:	72 0d                	jb     80102548 <readi+0xcb>
8010253b:	8b 45 14             	mov    0x14(%ebp),%eax
8010253e:	8b 55 10             	mov    0x10(%ebp),%edx
80102541:	01 d0                	add    %edx,%eax
80102543:	3b 45 10             	cmp    0x10(%ebp),%eax
80102546:	73 0a                	jae    80102552 <readi+0xd5>
        return -1;
80102548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010254d:	e9 d8 00 00 00       	jmp    8010262a <readi+0x1ad>
    if (off + n > ip->size)
80102552:	8b 45 14             	mov    0x14(%ebp),%eax
80102555:	8b 55 10             	mov    0x10(%ebp),%edx
80102558:	01 c2                	add    %eax,%edx
8010255a:	8b 45 08             	mov    0x8(%ebp),%eax
8010255d:	8b 40 18             	mov    0x18(%eax),%eax
80102560:	39 c2                	cmp    %eax,%edx
80102562:	76 0c                	jbe    80102570 <readi+0xf3>
        n = ip->size - off;
80102564:	8b 45 08             	mov    0x8(%ebp),%eax
80102567:	8b 40 18             	mov    0x18(%eax),%eax
8010256a:	2b 45 10             	sub    0x10(%ebp),%eax
8010256d:	89 45 14             	mov    %eax,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102570:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102577:	e9 9f 00 00 00       	jmp    8010261b <readi+0x19e>
        uint bmapOut=bmap(ip, off / BSIZE);
8010257c:	8b 45 10             	mov    0x10(%ebp),%eax
8010257f:	c1 e8 09             	shr    $0x9,%eax
80102582:	89 44 24 04          	mov    %eax,0x4(%esp)
80102586:	8b 45 08             	mov    0x8(%ebp),%eax
80102589:	89 04 24             	mov    %eax,(%esp)
8010258c:	e8 90 fb ff ff       	call   80102121 <bmap>
80102591:	89 45 f0             	mov    %eax,-0x10(%ebp)
       // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset+bmapOut);
80102594:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102597:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010259a:	01 c2                	add    %eax,%edx
8010259c:	8b 45 08             	mov    0x8(%ebp),%eax
8010259f:	8b 00                	mov    (%eax),%eax
801025a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801025a5:	89 04 24             	mov    %eax,(%esp)
801025a8:	e8 f9 db ff ff       	call   801001a6 <bread>
801025ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
801025b0:	8b 45 10             	mov    0x10(%ebp),%eax
801025b3:	25 ff 01 00 00       	and    $0x1ff,%eax
801025b8:	89 c2                	mov    %eax,%edx
801025ba:	b8 00 02 00 00       	mov    $0x200,%eax
801025bf:	29 d0                	sub    %edx,%eax
801025c1:	89 c2                	mov    %eax,%edx
801025c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c6:	8b 4d 14             	mov    0x14(%ebp),%ecx
801025c9:	29 c1                	sub    %eax,%ecx
801025cb:	89 c8                	mov    %ecx,%eax
801025cd:	39 c2                	cmp    %eax,%edx
801025cf:	0f 46 c2             	cmovbe %edx,%eax
801025d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(dst, bp->data + off % BSIZE, m);
801025d5:	8b 45 10             	mov    0x10(%ebp),%eax
801025d8:	25 ff 01 00 00       	and    $0x1ff,%eax
801025dd:	8d 50 10             	lea    0x10(%eax),%edx
801025e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025e3:	01 d0                	add    %edx,%eax
801025e5:	8d 50 08             	lea    0x8(%eax),%edx
801025e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801025eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801025ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801025f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801025f6:	89 04 24             	mov    %eax,(%esp)
801025f9:	e8 4c 37 00 00       	call   80105d4a <memmove>
        brelse(bp);
801025fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102601:	89 04 24             	mov    %eax,(%esp)
80102604:	e8 0e dc ff ff       	call   80100217 <brelse>
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102609:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010260c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010260f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102612:	01 45 10             	add    %eax,0x10(%ebp)
80102615:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102618:	01 45 0c             	add    %eax,0xc(%ebp)
8010261b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102621:	0f 82 55 ff ff ff    	jb     8010257c <readi+0xff>
        bp = bread(ip->dev, sb.offset+bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
80102627:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010262a:	c9                   	leave  
8010262b:	c3                   	ret    

8010262c <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
8010262c:	55                   	push   %ebp
8010262d:	89 e5                	mov    %esp,%ebp
8010262f:	83 ec 48             	sub    $0x48,%esp
                               // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
        sb=sbs[ip->part->number];
80102632:	8b 45 08             	mov    0x8(%ebp),%eax
80102635:	8b 40 50             	mov    0x50(%eax),%eax
80102638:	8b 40 14             	mov    0x14(%eax),%eax
8010263b:	c1 e0 05             	shl    $0x5,%eax
8010263e:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102643:	8b 10                	mov    (%eax),%edx
80102645:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102648:	8b 50 04             	mov    0x4(%eax),%edx
8010264b:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010264e:	8b 50 08             	mov    0x8(%eax),%edx
80102651:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102654:	8b 50 0c             	mov    0xc(%eax),%edx
80102657:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010265a:	8b 50 10             	mov    0x10(%eax),%edx
8010265d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102660:	8b 50 14             	mov    0x14(%eax),%edx
80102663:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102666:	8b 50 18             	mov    0x18(%eax),%edx
80102669:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010266c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010266f:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    if (ip->type == T_DEV) {
80102672:	8b 45 08             	mov    0x8(%ebp),%eax
80102675:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102679:	66 83 f8 03          	cmp    $0x3,%ax
8010267d:	75 60                	jne    801026df <writei+0xb3>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010267f:	8b 45 08             	mov    0x8(%ebp),%eax
80102682:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102686:	66 85 c0             	test   %ax,%ax
80102689:	78 20                	js     801026ab <writei+0x7f>
8010268b:	8b 45 08             	mov    0x8(%ebp),%eax
8010268e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102692:	66 83 f8 09          	cmp    $0x9,%ax
80102696:	7f 13                	jg     801026ab <writei+0x7f>
80102698:	8b 45 08             	mov    0x8(%ebp),%eax
8010269b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010269f:	98                   	cwtl   
801026a0:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801026a7:	85 c0                	test   %eax,%eax
801026a9:	75 0a                	jne    801026b5 <writei+0x89>
            return -1;
801026ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026b0:	e9 5c 01 00 00       	jmp    80102811 <writei+0x1e5>
        return devsw[ip->major].write(ip, src, n);
801026b5:	8b 45 08             	mov    0x8(%ebp),%eax
801026b8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026bc:	98                   	cwtl   
801026bd:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801026c4:	8b 55 14             	mov    0x14(%ebp),%edx
801026c7:	89 54 24 08          	mov    %edx,0x8(%esp)
801026cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801026ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801026d2:	8b 55 08             	mov    0x8(%ebp),%edx
801026d5:	89 14 24             	mov    %edx,(%esp)
801026d8:	ff d0                	call   *%eax
801026da:	e9 32 01 00 00       	jmp    80102811 <writei+0x1e5>
    }

    if (off > ip->size || off + n < off)
801026df:	8b 45 08             	mov    0x8(%ebp),%eax
801026e2:	8b 40 18             	mov    0x18(%eax),%eax
801026e5:	3b 45 10             	cmp    0x10(%ebp),%eax
801026e8:	72 0d                	jb     801026f7 <writei+0xcb>
801026ea:	8b 45 14             	mov    0x14(%ebp),%eax
801026ed:	8b 55 10             	mov    0x10(%ebp),%edx
801026f0:	01 d0                	add    %edx,%eax
801026f2:	3b 45 10             	cmp    0x10(%ebp),%eax
801026f5:	73 0a                	jae    80102701 <writei+0xd5>
        return -1;
801026f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026fc:	e9 10 01 00 00       	jmp    80102811 <writei+0x1e5>
    if (off + n > MAXFILE * BSIZE)
80102701:	8b 45 14             	mov    0x14(%ebp),%eax
80102704:	8b 55 10             	mov    0x10(%ebp),%edx
80102707:	01 d0                	add    %edx,%eax
80102709:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010270e:	76 0a                	jbe    8010271a <writei+0xee>
        return -1;
80102710:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102715:	e9 f7 00 00 00       	jmp    80102811 <writei+0x1e5>

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
8010271a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102721:	e9 b7 00 00 00       	jmp    801027dd <writei+0x1b1>
        uint bmapOut=bmap(ip, off / BSIZE);
80102726:	8b 45 10             	mov    0x10(%ebp),%eax
80102729:	c1 e8 09             	shr    $0x9,%eax
8010272c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102730:	8b 45 08             	mov    0x8(%ebp),%eax
80102733:	89 04 24             	mov    %eax,(%esp)
80102736:	e8 e6 f9 ff ff       	call   80102121 <bmap>
8010273b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        bp = bread(ip->dev, sb.offset+bmapOut);
8010273e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102744:	01 c2                	add    %eax,%edx
80102746:	8b 45 08             	mov    0x8(%ebp),%eax
80102749:	8b 00                	mov    (%eax),%eax
8010274b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010274f:	89 04 24             	mov    %eax,(%esp)
80102752:	e8 4f da ff ff       	call   801001a6 <bread>
80102757:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
8010275a:	8b 45 10             	mov    0x10(%ebp),%eax
8010275d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102762:	89 c2                	mov    %eax,%edx
80102764:	b8 00 02 00 00       	mov    $0x200,%eax
80102769:	29 d0                	sub    %edx,%eax
8010276b:	89 c2                	mov    %eax,%edx
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102773:	29 c1                	sub    %eax,%ecx
80102775:	89 c8                	mov    %ecx,%eax
80102777:	39 c2                	cmp    %eax,%edx
80102779:	0f 46 c2             	cmovbe %edx,%eax
8010277c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(bp->data + off % BSIZE, src, m);
8010277f:	8b 45 10             	mov    0x10(%ebp),%eax
80102782:	25 ff 01 00 00       	and    $0x1ff,%eax
80102787:	8d 50 10             	lea    0x10(%eax),%edx
8010278a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010278d:	01 d0                	add    %edx,%eax
8010278f:	8d 50 08             	lea    0x8(%eax),%edx
80102792:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102795:	89 44 24 08          	mov    %eax,0x8(%esp)
80102799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010279c:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a0:	89 14 24             	mov    %edx,(%esp)
801027a3:	e8 a2 35 00 00       	call   80105d4a <memmove>
        log_write(bp,ip->part->number);
801027a8:	8b 45 08             	mov    0x8(%ebp),%eax
801027ab:	8b 40 50             	mov    0x50(%eax),%eax
801027ae:	8b 40 14             	mov    0x14(%eax),%eax
801027b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801027b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027b8:	89 04 24             	mov    %eax,(%esp)
801027bb:	e8 c2 19 00 00       	call   80104182 <log_write>
        brelse(bp);
801027c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027c3:	89 04 24             	mov    %eax,(%esp)
801027c6:	e8 4c da ff ff       	call   80100217 <brelse>
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801027cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027ce:	01 45 f4             	add    %eax,-0xc(%ebp)
801027d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027d4:	01 45 10             	add    %eax,0x10(%ebp)
801027d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027da:	01 45 0c             	add    %eax,0xc(%ebp)
801027dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e0:	3b 45 14             	cmp    0x14(%ebp),%eax
801027e3:	0f 82 3d ff ff ff    	jb     80102726 <writei+0xfa>
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp,ip->part->number);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
801027e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801027ed:	74 1f                	je     8010280e <writei+0x1e2>
801027ef:	8b 45 08             	mov    0x8(%ebp),%eax
801027f2:	8b 40 18             	mov    0x18(%eax),%eax
801027f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801027f8:	73 14                	jae    8010280e <writei+0x1e2>
        ip->size = off;
801027fa:	8b 45 08             	mov    0x8(%ebp),%eax
801027fd:	8b 55 10             	mov    0x10(%ebp),%edx
80102800:	89 50 18             	mov    %edx,0x18(%eax)
        iupdate(ip);
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	89 04 24             	mov    %eax,(%esp)
80102809:	e8 e3 f3 ff ff       	call   80101bf1 <iupdate>
    }
    return n;
8010280e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102811:	c9                   	leave  
80102812:	c3                   	ret    

80102813 <namecmp>:

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
80102813:	55                   	push   %ebp
80102814:	89 e5                	mov    %esp,%ebp
80102816:	83 ec 18             	sub    $0x18,%esp
    return strncmp(s, t, DIRSIZ);
80102819:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102820:	00 
80102821:	8b 45 0c             	mov    0xc(%ebp),%eax
80102824:	89 44 24 04          	mov    %eax,0x4(%esp)
80102828:	8b 45 08             	mov    0x8(%ebp),%eax
8010282b:	89 04 24             	mov    %eax,(%esp)
8010282e:	e8 ba 35 00 00       	call   80105ded <strncmp>
}
80102833:	c9                   	leave  
80102834:	c3                   	ret    

80102835 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
80102835:	55                   	push   %ebp
80102836:	89 e5                	mov    %esp,%ebp
80102838:	83 ec 38             	sub    $0x38,%esp
                             //       cprintf("dirlookup \n");

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
8010283b:	8b 45 08             	mov    0x8(%ebp),%eax
8010283e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102842:	66 83 f8 01          	cmp    $0x1,%ax
80102846:	74 0c                	je     80102854 <dirlookup+0x1f>
        panic("dirlookup not DIR");
80102848:	c7 04 24 91 94 10 80 	movl   $0x80109491,(%esp)
8010284f:	e8 e6 dc ff ff       	call   8010053a <panic>

    for (off = 0; off < dp->size; off += sizeof(de)) {
80102854:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010285b:	e9 95 00 00 00       	jmp    801028f5 <dirlookup+0xc0>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102860:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102867:	00 
80102868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010286f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102872:	89 44 24 04          	mov    %eax,0x4(%esp)
80102876:	8b 45 08             	mov    0x8(%ebp),%eax
80102879:	89 04 24             	mov    %eax,(%esp)
8010287c:	e8 fc fb ff ff       	call   8010247d <readi>
80102881:	83 f8 10             	cmp    $0x10,%eax
80102884:	74 0c                	je     80102892 <dirlookup+0x5d>
            panic("dirlink read");
80102886:	c7 04 24 a3 94 10 80 	movl   $0x801094a3,(%esp)
8010288d:	e8 a8 dc ff ff       	call   8010053a <panic>
        if (de.inum == 0)
80102892:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102896:	66 85 c0             	test   %ax,%ax
80102899:	75 02                	jne    8010289d <dirlookup+0x68>
            continue;
8010289b:	eb 54                	jmp    801028f1 <dirlookup+0xbc>
        if (namecmp(name, de.name) == 0) {
8010289d:	8d 45 e0             	lea    -0x20(%ebp),%eax
801028a0:	83 c0 02             	add    $0x2,%eax
801028a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801028a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801028aa:	89 04 24             	mov    %eax,(%esp)
801028ad:	e8 61 ff ff ff       	call   80102813 <namecmp>
801028b2:	85 c0                	test   %eax,%eax
801028b4:	75 3b                	jne    801028f1 <dirlookup+0xbc>
            // entry matches path element
            if (poff)
801028b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801028ba:	74 08                	je     801028c4 <dirlookup+0x8f>
                *poff = off;
801028bc:	8b 45 10             	mov    0x10(%ebp),%eax
801028bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028c2:	89 10                	mov    %edx,(%eax)
            inum = de.inum;
801028c4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801028c8:	0f b7 c0             	movzwl %ax,%eax
801028cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
            return iget(dp->dev, inum, dp->part->number);
801028ce:	8b 45 08             	mov    0x8(%ebp),%eax
801028d1:	8b 40 50             	mov    0x50(%eax),%eax
801028d4:	8b 50 14             	mov    0x14(%eax),%edx
801028d7:	8b 45 08             	mov    0x8(%ebp),%eax
801028da:	8b 00                	mov    (%eax),%eax
801028dc:	89 54 24 08          	mov    %edx,0x8(%esp)
801028e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801028e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801028e7:	89 04 24             	mov    %eax,(%esp)
801028ea:	e8 10 f4 ff ff       	call   80101cff <iget>
801028ef:	eb 18                	jmp    80102909 <dirlookup+0xd4>
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801028f1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801028f5:	8b 45 08             	mov    0x8(%ebp),%eax
801028f8:	8b 40 18             	mov    0x18(%eax),%eax
801028fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801028fe:	0f 87 5c ff ff ff    	ja     80102860 <dirlookup+0x2b>
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
80102904:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102909:	c9                   	leave  
8010290a:	c3                   	ret    

8010290b <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
8010290b:	55                   	push   %ebp
8010290c:	89 e5                	mov    %esp,%ebp
8010290e:	83 ec 38             	sub    $0x38,%esp
    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
80102911:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102918:	00 
80102919:	8b 45 0c             	mov    0xc(%ebp),%eax
8010291c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102920:	8b 45 08             	mov    0x8(%ebp),%eax
80102923:	89 04 24             	mov    %eax,(%esp)
80102926:	e8 0a ff ff ff       	call   80102835 <dirlookup>
8010292b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010292e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102932:	74 15                	je     80102949 <dirlink+0x3e>
        iput(ip);
80102934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102937:	89 04 24             	mov    %eax,(%esp)
8010293a:	e8 f3 f6 ff ff       	call   80102032 <iput>
        return -1;
8010293f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102944:	e9 b7 00 00 00       	jmp    80102a00 <dirlink+0xf5>
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102949:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102950:	eb 46                	jmp    80102998 <dirlink+0x8d>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102955:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010295c:	00 
8010295d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102961:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102964:	89 44 24 04          	mov    %eax,0x4(%esp)
80102968:	8b 45 08             	mov    0x8(%ebp),%eax
8010296b:	89 04 24             	mov    %eax,(%esp)
8010296e:	e8 0a fb ff ff       	call   8010247d <readi>
80102973:	83 f8 10             	cmp    $0x10,%eax
80102976:	74 0c                	je     80102984 <dirlink+0x79>
            panic("dirlink read");
80102978:	c7 04 24 a3 94 10 80 	movl   $0x801094a3,(%esp)
8010297f:	e8 b6 db ff ff       	call   8010053a <panic>
        if (de.inum == 0)
80102984:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102988:	66 85 c0             	test   %ax,%ax
8010298b:	75 02                	jne    8010298f <dirlink+0x84>
            break;
8010298d:	eb 16                	jmp    801029a5 <dirlink+0x9a>
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
8010298f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102992:	83 c0 10             	add    $0x10,%eax
80102995:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102998:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010299b:	8b 45 08             	mov    0x8(%ebp),%eax
8010299e:	8b 40 18             	mov    0x18(%eax),%eax
801029a1:	39 c2                	cmp    %eax,%edx
801029a3:	72 ad                	jb     80102952 <dirlink+0x47>
            panic("dirlink read");
        if (de.inum == 0)
            break;
    }

    strncpy(de.name, name, DIRSIZ);
801029a5:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801029ac:	00 
801029ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801029b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801029b7:	83 c0 02             	add    $0x2,%eax
801029ba:	89 04 24             	mov    %eax,(%esp)
801029bd:	e8 81 34 00 00       	call   80105e43 <strncpy>
    de.inum = inum;
801029c2:	8b 45 10             	mov    0x10(%ebp),%eax
801029c5:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801029c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029cc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801029d3:	00 
801029d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801029d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	89 04 24             	mov    %eax,(%esp)
801029e5:	e8 42 fc ff ff       	call   8010262c <writei>
801029ea:	83 f8 10             	cmp    $0x10,%eax
801029ed:	74 0c                	je     801029fb <dirlink+0xf0>
        panic("dirlink");
801029ef:	c7 04 24 b0 94 10 80 	movl   $0x801094b0,(%esp)
801029f6:	e8 3f db ff ff       	call   8010053a <panic>

    return 0;
801029fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a00:	c9                   	leave  
80102a01:	c3                   	ret    

80102a02 <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
80102a02:	55                   	push   %ebp
80102a03:	89 e5                	mov    %esp,%ebp
80102a05:	83 ec 28             	sub    $0x28,%esp
    
    char* s;
    int len;

    while (*path == '/')
80102a08:	eb 04                	jmp    80102a0e <skipelem+0xc>
        path++;
80102a0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
    
    char* s;
    int len;

    while (*path == '/')
80102a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a11:	0f b6 00             	movzbl (%eax),%eax
80102a14:	3c 2f                	cmp    $0x2f,%al
80102a16:	74 f2                	je     80102a0a <skipelem+0x8>
        path++;
    if (*path == 0)
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	0f b6 00             	movzbl (%eax),%eax
80102a1e:	84 c0                	test   %al,%al
80102a20:	75 0a                	jne    80102a2c <skipelem+0x2a>
        return 0;
80102a22:	b8 00 00 00 00       	mov    $0x0,%eax
80102a27:	e9 86 00 00 00       	jmp    80102ab2 <skipelem+0xb0>
    s = path;
80102a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (*path != '/' && *path != 0)
80102a32:	eb 04                	jmp    80102a38 <skipelem+0x36>
        path++;
80102a34:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
80102a38:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3b:	0f b6 00             	movzbl (%eax),%eax
80102a3e:	3c 2f                	cmp    $0x2f,%al
80102a40:	74 0a                	je     80102a4c <skipelem+0x4a>
80102a42:	8b 45 08             	mov    0x8(%ebp),%eax
80102a45:	0f b6 00             	movzbl (%eax),%eax
80102a48:	84 c0                	test   %al,%al
80102a4a:	75 e8                	jne    80102a34 <skipelem+0x32>
        path++;
    len = path - s;
80102a4c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	29 c2                	sub    %eax,%edx
80102a54:	89 d0                	mov    %edx,%eax
80102a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (len >= DIRSIZ)
80102a59:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102a5d:	7e 1c                	jle    80102a7b <skipelem+0x79>
        memmove(name, s, DIRSIZ);
80102a5f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102a66:	00 
80102a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a71:	89 04 24             	mov    %eax,(%esp)
80102a74:	e8 d1 32 00 00       	call   80105d4a <memmove>
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102a79:	eb 2a                	jmp    80102aa5 <skipelem+0xa3>
        path++;
    len = path - s;
    if (len >= DIRSIZ)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
80102a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a85:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a8c:	89 04 24             	mov    %eax,(%esp)
80102a8f:	e8 b6 32 00 00       	call   80105d4a <memmove>
        name[len] = 0;
80102a94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102a97:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a9a:	01 d0                	add    %edx,%eax
80102a9c:	c6 00 00             	movb   $0x0,(%eax)
    }
    while (*path == '/')
80102a9f:	eb 04                	jmp    80102aa5 <skipelem+0xa3>
        path++;
80102aa1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa8:	0f b6 00             	movzbl (%eax),%eax
80102aab:	3c 2f                	cmp    $0x2f,%al
80102aad:	74 f2                	je     80102aa1 <skipelem+0x9f>
        path++;
    return path;
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102ab2:	c9                   	leave  
80102ab3:	c3                   	ret    

80102ab4 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, int ignoreMounts,char* name)
{
80102ab4:	55                   	push   %ebp
80102ab5:	89 e5                	mov    %esp,%ebp
80102ab7:	83 ec 28             	sub    $0x28,%esp
                                           // cprintf("namex \n");

    struct inode* ip, *next;
     // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
80102aba:	8b 45 08             	mov    0x8(%ebp),%eax
80102abd:	0f b6 00             	movzbl (%eax),%eax
80102ac0:	3c 2f                	cmp    $0x2f,%al
80102ac2:	75 25                	jne    80102ae9 <namex+0x35>
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
80102ac4:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80102ac9:	89 44 24 08          	mov    %eax,0x8(%esp)
80102acd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ad4:	00 
80102ad5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102adc:	e8 1e f2 ff ff       	call   80101cff <iget>
80102ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102ae4:	e9 38 01 00 00       	jmp    80102c21 <namex+0x16d>
    struct inode* ip, *next;
     // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);
80102ae9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102aef:	8b 40 68             	mov    0x68(%eax),%eax
80102af2:	89 04 24             	mov    %eax,(%esp)
80102af5:	e8 0a f3 ff ff       	call   80101e04 <idup>
80102afa:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while ((path = skipelem(path, name)) != 0) {
80102afd:	e9 1f 01 00 00       	jmp    80102c21 <namex+0x16d>
      //  cprintf("namex inode %d,part number %d \n",ip->inum,ip->part->number);
        ilock(ip);
80102b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b05:	89 04 24             	mov    %eax,(%esp)
80102b08:	e8 29 f3 ff ff       	call   80101e36 <ilock>
        if (ip->type != T_DIR) {
80102b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b10:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102b14:	66 83 f8 01          	cmp    $0x1,%ax
80102b18:	74 15                	je     80102b2f <namex+0x7b>
            iunlockput(ip);
80102b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1d:	89 04 24             	mov    %eax,(%esp)
80102b20:	e8 de f5 ff ff       	call   80102103 <iunlockput>
            return 0;
80102b25:	b8 00 00 00 00       	mov    $0x0,%eax
80102b2a:	e9 2c 01 00 00       	jmp    80102c5b <namex+0x1a7>
        }
        if (nameiparent && *path == '\0') {
80102b2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102b33:	74 1d                	je     80102b52 <namex+0x9e>
80102b35:	8b 45 08             	mov    0x8(%ebp),%eax
80102b38:	0f b6 00             	movzbl (%eax),%eax
80102b3b:	84 c0                	test   %al,%al
80102b3d:	75 13                	jne    80102b52 <namex+0x9e>
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
80102b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b42:	89 04 24             	mov    %eax,(%esp)
80102b45:	e8 83 f4 ff ff       	call   80101fcd <iunlock>
            return ip;
80102b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4d:	e9 09 01 00 00       	jmp    80102c5b <namex+0x1a7>
        }
        if ((next = dirlookup(ip, name, 0)) == 0) {
80102b52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102b59:	00 
80102b5a:	8b 45 14             	mov    0x14(%ebp),%eax
80102b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b64:	89 04 24             	mov    %eax,(%esp)
80102b67:	e8 c9 fc ff ff       	call   80102835 <dirlookup>
80102b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102b6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102b73:	75 15                	jne    80102b8a <namex+0xd6>
            iunlockput(ip);
80102b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b78:	89 04 24             	mov    %eax,(%esp)
80102b7b:	e8 83 f5 ff ff       	call   80102103 <iunlockput>
            return 0;
80102b80:	b8 00 00 00 00       	mov    $0x0,%eax
80102b85:	e9 d1 00 00 00       	jmp    80102c5b <namex+0x1a7>
        }
        iunlockput(ip);
80102b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8d:	89 04 24             	mov    %eax,(%esp)
80102b90:	e8 6e f5 ff ff       	call   80102103 <iunlockput>
        //testing 
        if(!ignoreMounts&&next->type==T_DIR&&next->major!=0 && next->major!=MOUNTING_POINT){
80102b95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102b99:	75 32                	jne    80102bcd <namex+0x119>
80102b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b9e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102ba2:	66 83 f8 01          	cmp    $0x1,%ax
80102ba6:	75 25                	jne    80102bcd <namex+0x119>
80102ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bab:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102baf:	66 85 c0             	test   %ax,%ax
80102bb2:	74 19                	je     80102bcd <namex+0x119>
80102bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bb7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102bbb:	66 83 f8 01          	cmp    $0x1,%ax
80102bbf:	74 0c                	je     80102bcd <namex+0x119>
            cprintf("major used ,we are fucked \n");
80102bc1:	c7 04 24 b8 94 10 80 	movl   $0x801094b8,(%esp)
80102bc8:	e8 d3 d7 ff ff       	call   801003a0 <cprintf>
        }
        //handle mounting points
        if(!ignoreMounts&&!nameiparent&&next->type==T_DIR&&next->major==MOUNTING_POINT){
80102bcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102bd1:	75 48                	jne    80102c1b <namex+0x167>
80102bd3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bd7:	75 42                	jne    80102c1b <namex+0x167>
80102bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bdc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102be0:	66 83 f8 01          	cmp    $0x1,%ax
80102be4:	75 35                	jne    80102c1b <namex+0x167>
80102be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102be9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102bed:	66 83 f8 01          	cmp    $0x1,%ax
80102bf1:	75 28                	jne    80102c1b <namex+0x167>
            
            
            uint partitionNumnber=next->minor;
80102bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bf6:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80102bfa:	98                   	cwtl   
80102bfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
            return iget(ROOTDEV,1,partitionNumnber);
80102bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102c01:	89 44 24 08          	mov    %eax,0x8(%esp)
80102c05:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c0c:	00 
80102c0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c14:	e8 e6 f0 ff ff       	call   80101cff <iget>
80102c19:	eb 40                	jmp    80102c5b <namex+0x1a7>
        }
        ip = next;
80102c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102c21:	8b 45 14             	mov    0x14(%ebp),%eax
80102c24:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c28:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2b:	89 04 24             	mov    %eax,(%esp)
80102c2e:	e8 cf fd ff ff       	call   80102a02 <skipelem>
80102c33:	89 45 08             	mov    %eax,0x8(%ebp)
80102c36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102c3a:	0f 85 c2 fe ff ff    	jne    80102b02 <namex+0x4e>
            uint partitionNumnber=next->minor;
            return iget(ROOTDEV,1,partitionNumnber);
        }
        ip = next;
    }
    if (nameiparent) {
80102c40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c44:	74 12                	je     80102c58 <namex+0x1a4>
        iput(ip);
80102c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c49:	89 04 24             	mov    %eax,(%esp)
80102c4c:	e8 e1 f3 ff ff       	call   80102032 <iput>
        return 0;
80102c51:	b8 00 00 00 00       	mov    $0x0,%eax
80102c56:	eb 03                	jmp    80102c5b <namex+0x1a7>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c5b:	c9                   	leave  
80102c5c:	c3                   	ret    

80102c5d <namei>:



struct inode* namei(char* path)
{
80102c5d:	55                   	push   %ebp
80102c5e:	89 e5                	mov    %esp,%ebp
80102c60:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ];
    return namex(path, 0, 0,name);
80102c63:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102c66:	89 44 24 0c          	mov    %eax,0xc(%esp)
80102c6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102c71:	00 
80102c72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c79:	00 
80102c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7d:	89 04 24             	mov    %eax,(%esp)
80102c80:	e8 2f fe ff ff       	call   80102ab4 <namex>
}
80102c85:	c9                   	leave  
80102c86:	c3                   	ret    

80102c87 <nameiIgnoreMounts>:

struct inode* nameiIgnoreMounts(char* path)
{
80102c87:	55                   	push   %ebp
80102c88:	89 e5                	mov    %esp,%ebp
80102c8a:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ];
    return namex(path, 0, 1,name);
80102c8d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102c90:	89 44 24 0c          	mov    %eax,0xc(%esp)
80102c94:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80102c9b:	00 
80102c9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ca3:	00 
80102ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca7:	89 04 24             	mov    %eax,(%esp)
80102caa:	e8 05 fe ff ff       	call   80102ab4 <namex>
}
80102caf:	c9                   	leave  
80102cb0:	c3                   	ret    

80102cb1 <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102cb1:	55                   	push   %ebp
80102cb2:	89 e5                	mov    %esp,%ebp
80102cb4:	83 ec 18             	sub    $0x18,%esp
    return namex(path, 1, 0,name);
80102cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cba:	89 44 24 0c          	mov    %eax,0xc(%esp)
80102cbe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102cc5:	00 
80102cc6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ccd:	00 
80102cce:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd1:	89 04 24             	mov    %eax,(%esp)
80102cd4:	e8 db fd ff ff       	call   80102ab4 <namex>
}
80102cd9:	c9                   	leave  
80102cda:	c3                   	ret    

80102cdb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cdb:	55                   	push   %ebp
80102cdc:	89 e5                	mov    %esp,%ebp
80102cde:	83 ec 14             	sub    $0x14,%esp
80102ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cec:	89 c2                	mov    %eax,%edx
80102cee:	ec                   	in     (%dx),%al
80102cef:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf6:	c9                   	leave  
80102cf7:	c3                   	ret    

80102cf8 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102cf8:	55                   	push   %ebp
80102cf9:	89 e5                	mov    %esp,%ebp
80102cfb:	57                   	push   %edi
80102cfc:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102cfd:	8b 55 08             	mov    0x8(%ebp),%edx
80102d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d03:	8b 45 10             	mov    0x10(%ebp),%eax
80102d06:	89 cb                	mov    %ecx,%ebx
80102d08:	89 df                	mov    %ebx,%edi
80102d0a:	89 c1                	mov    %eax,%ecx
80102d0c:	fc                   	cld    
80102d0d:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d0f:	89 c8                	mov    %ecx,%eax
80102d11:	89 fb                	mov    %edi,%ebx
80102d13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d16:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d19:	5b                   	pop    %ebx
80102d1a:	5f                   	pop    %edi
80102d1b:	5d                   	pop    %ebp
80102d1c:	c3                   	ret    

80102d1d <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d1d:	55                   	push   %ebp
80102d1e:	89 e5                	mov    %esp,%ebp
80102d20:	83 ec 08             	sub    $0x8,%esp
80102d23:	8b 55 08             	mov    0x8(%ebp),%edx
80102d26:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d29:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d2d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d30:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d34:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d38:	ee                   	out    %al,(%dx)
}
80102d39:	c9                   	leave  
80102d3a:	c3                   	ret    

80102d3b <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102d3b:	55                   	push   %ebp
80102d3c:	89 e5                	mov    %esp,%ebp
80102d3e:	56                   	push   %esi
80102d3f:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102d40:	8b 55 08             	mov    0x8(%ebp),%edx
80102d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d46:	8b 45 10             	mov    0x10(%ebp),%eax
80102d49:	89 cb                	mov    %ecx,%ebx
80102d4b:	89 de                	mov    %ebx,%esi
80102d4d:	89 c1                	mov    %eax,%ecx
80102d4f:	fc                   	cld    
80102d50:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102d52:	89 c8                	mov    %ecx,%eax
80102d54:	89 f3                	mov    %esi,%ebx
80102d56:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d59:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102d5c:	5b                   	pop    %ebx
80102d5d:	5e                   	pop    %esi
80102d5e:	5d                   	pop    %ebp
80102d5f:	c3                   	ret    

80102d60 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102d60:	55                   	push   %ebp
80102d61:	89 e5                	mov    %esp,%ebp
80102d63:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102d66:	90                   	nop
80102d67:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102d6e:	e8 68 ff ff ff       	call   80102cdb <inb>
80102d73:	0f b6 c0             	movzbl %al,%eax
80102d76:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7c:	25 c0 00 00 00       	and    $0xc0,%eax
80102d81:	83 f8 40             	cmp    $0x40,%eax
80102d84:	75 e1                	jne    80102d67 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d8a:	74 11                	je     80102d9d <idewait+0x3d>
80102d8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8f:	83 e0 21             	and    $0x21,%eax
80102d92:	85 c0                	test   %eax,%eax
80102d94:	74 07                	je     80102d9d <idewait+0x3d>
    return -1;
80102d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d9b:	eb 05                	jmp    80102da2 <idewait+0x42>
  return 0;
80102d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102da2:	c9                   	leave  
80102da3:	c3                   	ret    

80102da4 <ideinit>:

void
ideinit(void)
{
80102da4:	55                   	push   %ebp
80102da5:	89 e5                	mov    %esp,%ebp
80102da7:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102daa:	c7 44 24 04 de 94 10 	movl   $0x801094de,0x4(%esp)
80102db1:	80 
80102db2:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102db9:	e8 48 2c 00 00       	call   80105a06 <initlock>
  picenable(IRQ_IDE);
80102dbe:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102dc5:	e8 b4 1b 00 00       	call   8010497e <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102dca:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102dcf:	83 e8 01             	sub    $0x1,%eax
80102dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dd6:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102ddd:	e8 5b 04 00 00       	call   8010323d <ioapicenable>
  idewait(0);
80102de2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102de9:	e8 72 ff ff ff       	call   80102d60 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102dee:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102df5:	00 
80102df6:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102dfd:	e8 1b ff ff ff       	call   80102d1d <outb>
  for(i=0; i<1000; i++){
80102e02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e09:	eb 20                	jmp    80102e2b <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102e0b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102e12:	e8 c4 fe ff ff       	call   80102cdb <inb>
80102e17:	84 c0                	test   %al,%al
80102e19:	74 0c                	je     80102e27 <ideinit+0x83>
      havedisk1 = 1;
80102e1b:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102e22:	00 00 00 
      break;
80102e25:	eb 0d                	jmp    80102e34 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102e27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e2b:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102e32:	7e d7                	jle    80102e0b <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102e34:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102e3b:	00 
80102e3c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102e43:	e8 d5 fe ff ff       	call   80102d1d <outb>
}
80102e48:	c9                   	leave  
80102e49:	c3                   	ret    

80102e4a <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102e4a:	55                   	push   %ebp
80102e4b:	89 e5                	mov    %esp,%ebp
80102e4d:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102e50:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e54:	75 0c                	jne    80102e62 <idestart+0x18>
    panic("idestart");
80102e56:	c7 04 24 e2 94 10 80 	movl   $0x801094e2,(%esp)
80102e5d:	e8 d8 d6 ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE){
80102e62:	8b 45 08             	mov    0x8(%ebp),%eax
80102e65:	8b 40 08             	mov    0x8(%eax),%eax
80102e68:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102e6d:	76 18                	jbe    80102e87 <idestart+0x3d>
      cprintf("block %d \n");
80102e6f:	c7 04 24 eb 94 10 80 	movl   $0x801094eb,(%esp)
80102e76:	e8 25 d5 ff ff       	call   801003a0 <cprintf>
          panic("incorrect blockno");
80102e7b:	c7 04 24 f6 94 10 80 	movl   $0x801094f6,(%esp)
80102e82:	e8 b3 d6 ff ff       	call   8010053a <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e87:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e91:	8b 50 08             	mov    0x8(%eax),%edx
80102e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e97:	0f af c2             	imul   %edx,%eax
80102e9a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102e9d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102ea1:	7e 0c                	jle    80102eaf <idestart+0x65>
80102ea3:	c7 04 24 e2 94 10 80 	movl   $0x801094e2,(%esp)
80102eaa:	e8 8b d6 ff ff       	call   8010053a <panic>
  
  idewait(0);
80102eaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102eb6:	e8 a5 fe ff ff       	call   80102d60 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102ebb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ec2:	00 
80102ec3:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102eca:	e8 4e fe ff ff       	call   80102d1d <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ed2:	0f b6 c0             	movzbl %al,%eax
80102ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ed9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102ee0:	e8 38 fe ff ff       	call   80102d1d <outb>
  outb(0x1f3, sector & 0xff);
80102ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ee8:	0f b6 c0             	movzbl %al,%eax
80102eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eef:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102ef6:	e8 22 fe ff ff       	call   80102d1d <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102efe:	c1 f8 08             	sar    $0x8,%eax
80102f01:	0f b6 c0             	movzbl %al,%eax
80102f04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f08:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102f0f:	e8 09 fe ff ff       	call   80102d1d <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f17:	c1 f8 10             	sar    $0x10,%eax
80102f1a:	0f b6 c0             	movzbl %al,%eax
80102f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f21:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102f28:	e8 f0 fd ff ff       	call   80102d1d <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102f30:	8b 40 04             	mov    0x4(%eax),%eax
80102f33:	83 e0 01             	and    $0x1,%eax
80102f36:	c1 e0 04             	shl    $0x4,%eax
80102f39:	89 c2                	mov    %eax,%edx
80102f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f3e:	c1 f8 18             	sar    $0x18,%eax
80102f41:	83 e0 0f             	and    $0xf,%eax
80102f44:	09 d0                	or     %edx,%eax
80102f46:	83 c8 e0             	or     $0xffffffe0,%eax
80102f49:	0f b6 c0             	movzbl %al,%eax
80102f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f50:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102f57:	e8 c1 fd ff ff       	call   80102d1d <outb>
  if(b->flags & B_DIRTY){
80102f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102f5f:	8b 00                	mov    (%eax),%eax
80102f61:	83 e0 04             	and    $0x4,%eax
80102f64:	85 c0                	test   %eax,%eax
80102f66:	74 34                	je     80102f9c <idestart+0x152>
    outb(0x1f7, IDE_CMD_WRITE);
80102f68:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102f6f:	00 
80102f70:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102f77:	e8 a1 fd ff ff       	call   80102d1d <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102f7f:	83 c0 18             	add    $0x18,%eax
80102f82:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102f89:	00 
80102f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f8e:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102f95:	e8 a1 fd ff ff       	call   80102d3b <outsl>
80102f9a:	eb 14                	jmp    80102fb0 <idestart+0x166>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102f9c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102fa3:	00 
80102fa4:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102fab:	e8 6d fd ff ff       	call   80102d1d <outb>
  }
}
80102fb0:	c9                   	leave  
80102fb1:	c3                   	ret    

80102fb2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102fb2:	55                   	push   %ebp
80102fb3:	89 e5                	mov    %esp,%ebp
80102fb5:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102fb8:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102fbf:	e8 63 2a 00 00       	call   80105a27 <acquire>
  if((b = idequeue) == 0){
80102fc4:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102fcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102fd0:	75 11                	jne    80102fe3 <ideintr+0x31>
    release(&idelock);
80102fd2:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102fd9:	e8 ab 2a 00 00       	call   80105a89 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102fde:	e9 9c 00 00 00       	jmp    8010307f <ideintr+0xcd>
  }
  idequeue = b->qnext;
80102fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe6:	8b 40 14             	mov    0x14(%eax),%eax
80102fe9:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ff1:	8b 00                	mov    (%eax),%eax
80102ff3:	83 e0 04             	and    $0x4,%eax
80102ff6:	85 c0                	test   %eax,%eax
80102ff8:	75 2e                	jne    80103028 <ideintr+0x76>
80102ffa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103001:	e8 5a fd ff ff       	call   80102d60 <idewait>
80103006:	85 c0                	test   %eax,%eax
80103008:	78 1e                	js     80103028 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
8010300a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010300d:	83 c0 18             	add    $0x18,%eax
80103010:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80103017:	00 
80103018:	89 44 24 04          	mov    %eax,0x4(%esp)
8010301c:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80103023:	e8 d0 fc ff ff       	call   80102cf8 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80103028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010302b:	8b 00                	mov    (%eax),%eax
8010302d:	83 c8 02             	or     $0x2,%eax
80103030:	89 c2                	mov    %eax,%edx
80103032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103035:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80103037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303a:	8b 00                	mov    (%eax),%eax
8010303c:	83 e0 fb             	and    $0xfffffffb,%eax
8010303f:	89 c2                	mov    %eax,%edx
80103041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103044:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80103046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103049:	89 04 24             	mov    %eax,(%esp)
8010304c:	e8 e5 27 00 00       	call   80105836 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
80103051:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103056:	85 c0                	test   %eax,%eax
80103058:	74 19                	je     80103073 <ideintr+0xc1>
            cprintf("ideintr \n");
8010305a:	c7 04 24 08 95 10 80 	movl   $0x80109508,(%esp)
80103061:	e8 3a d3 ff ff       	call   801003a0 <cprintf>
                idestart(idequeue);
80103066:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010306b:	89 04 24             	mov    %eax,(%esp)
8010306e:	e8 d7 fd ff ff       	call   80102e4a <idestart>


  }

  release(&idelock);
80103073:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010307a:	e8 0a 2a 00 00       	call   80105a89 <release>
}
8010307f:	c9                   	leave  
80103080:	c3                   	ret    

80103081 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103081:	55                   	push   %ebp
80103082:	89 e5                	mov    %esp,%ebp
80103084:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103087:	8b 45 08             	mov    0x8(%ebp),%eax
8010308a:	8b 00                	mov    (%eax),%eax
8010308c:	83 e0 01             	and    $0x1,%eax
8010308f:	85 c0                	test   %eax,%eax
80103091:	75 0c                	jne    8010309f <iderw+0x1e>
    panic("iderw: buf not busy");
80103093:	c7 04 24 12 95 10 80 	movl   $0x80109512,(%esp)
8010309a:	e8 9b d4 ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010309f:	8b 45 08             	mov    0x8(%ebp),%eax
801030a2:	8b 00                	mov    (%eax),%eax
801030a4:	83 e0 06             	and    $0x6,%eax
801030a7:	83 f8 02             	cmp    $0x2,%eax
801030aa:	75 0c                	jne    801030b8 <iderw+0x37>
    panic("iderw: nothing to do");
801030ac:	c7 04 24 26 95 10 80 	movl   $0x80109526,(%esp)
801030b3:	e8 82 d4 ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801030b8:	8b 45 08             	mov    0x8(%ebp),%eax
801030bb:	8b 40 04             	mov    0x4(%eax),%eax
801030be:	85 c0                	test   %eax,%eax
801030c0:	74 15                	je     801030d7 <iderw+0x56>
801030c2:	a1 38 c6 10 80       	mov    0x8010c638,%eax
801030c7:	85 c0                	test   %eax,%eax
801030c9:	75 0c                	jne    801030d7 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801030cb:	c7 04 24 3b 95 10 80 	movl   $0x8010953b,(%esp)
801030d2:	e8 63 d4 ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801030d7:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801030de:	e8 44 29 00 00       	call   80105a27 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801030e3:	8b 45 08             	mov    0x8(%ebp),%eax
801030e6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801030ed:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
801030f4:	eb 0b                	jmp    80103101 <iderw+0x80>
801030f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030f9:	8b 00                	mov    (%eax),%eax
801030fb:	83 c0 14             	add    $0x14,%eax
801030fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103104:	8b 00                	mov    (%eax),%eax
80103106:	85 c0                	test   %eax,%eax
80103108:	75 ec                	jne    801030f6 <iderw+0x75>
    ;
  *pp = b;
8010310a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310d:	8b 55 08             	mov    0x8(%ebp),%edx
80103110:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
80103112:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103117:	3b 45 08             	cmp    0x8(%ebp),%eax
8010311a:	75 0d                	jne    80103129 <iderw+0xa8>
     // cprintf("iderw \n");
          idestart(b);
8010311c:	8b 45 08             	mov    0x8(%ebp),%eax
8010311f:	89 04 24             	mov    %eax,(%esp)
80103122:	e8 23 fd ff ff       	call   80102e4a <idestart>

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103127:	eb 15                	jmp    8010313e <iderw+0xbd>
80103129:	eb 13                	jmp    8010313e <iderw+0xbd>
    sleep(b, &idelock);
8010312b:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
80103132:	80 
80103133:	8b 45 08             	mov    0x8(%ebp),%eax
80103136:	89 04 24             	mov    %eax,(%esp)
80103139:	e8 1f 26 00 00       	call   8010575d <sleep>
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010313e:	8b 45 08             	mov    0x8(%ebp),%eax
80103141:	8b 00                	mov    (%eax),%eax
80103143:	83 e0 06             	and    $0x6,%eax
80103146:	83 f8 02             	cmp    $0x2,%eax
80103149:	75 e0                	jne    8010312b <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010314b:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80103152:	e8 32 29 00 00       	call   80105a89 <release>
}
80103157:	c9                   	leave  
80103158:	c3                   	ret    

80103159 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103159:	55                   	push   %ebp
8010315a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010315c:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103166:	a1 fc 34 11 80       	mov    0x801134fc,%eax
8010316b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010316e:	5d                   	pop    %ebp
8010316f:	c3                   	ret    

80103170 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80103170:	55                   	push   %ebp
80103171:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103173:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103178:	8b 55 08             	mov    0x8(%ebp),%edx
8010317b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010317d:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103182:	8b 55 0c             	mov    0xc(%ebp),%edx
80103185:	89 50 10             	mov    %edx,0x10(%eax)
}
80103188:	5d                   	pop    %ebp
80103189:	c3                   	ret    

8010318a <ioapicinit>:

void
ioapicinit(void)
{
8010318a:	55                   	push   %ebp
8010318b:	89 e5                	mov    %esp,%ebp
8010318d:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80103190:	a1 64 38 11 80       	mov    0x80113864,%eax
80103195:	85 c0                	test   %eax,%eax
80103197:	75 05                	jne    8010319e <ioapicinit+0x14>
    return;
80103199:	e9 9d 00 00 00       	jmp    8010323b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
8010319e:	c7 05 fc 34 11 80 00 	movl   $0xfec00000,0x801134fc
801031a5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801031a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031af:	e8 a5 ff ff ff       	call   80103159 <ioapicread>
801031b4:	c1 e8 10             	shr    $0x10,%eax
801031b7:	25 ff 00 00 00       	and    $0xff,%eax
801031bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801031bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801031c6:	e8 8e ff ff ff       	call   80103159 <ioapicread>
801031cb:	c1 e8 18             	shr    $0x18,%eax
801031ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801031d1:	0f b6 05 60 38 11 80 	movzbl 0x80113860,%eax
801031d8:	0f b6 c0             	movzbl %al,%eax
801031db:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801031de:	74 0c                	je     801031ec <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801031e0:	c7 04 24 5c 95 10 80 	movl   $0x8010955c,(%esp)
801031e7:	e8 b4 d1 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031f3:	eb 3e                	jmp    80103233 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801031f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031f8:	83 c0 20             	add    $0x20,%eax
801031fb:	0d 00 00 01 00       	or     $0x10000,%eax
80103200:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103203:	83 c2 08             	add    $0x8,%edx
80103206:	01 d2                	add    %edx,%edx
80103208:	89 44 24 04          	mov    %eax,0x4(%esp)
8010320c:	89 14 24             	mov    %edx,(%esp)
8010320f:	e8 5c ff ff ff       	call   80103170 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80103214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103217:	83 c0 08             	add    $0x8,%eax
8010321a:	01 c0                	add    %eax,%eax
8010321c:	83 c0 01             	add    $0x1,%eax
8010321f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103226:	00 
80103227:	89 04 24             	mov    %eax,(%esp)
8010322a:	e8 41 ff ff ff       	call   80103170 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103236:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103239:	7e ba                	jle    801031f5 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010323b:	c9                   	leave  
8010323c:	c3                   	ret    

8010323d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010323d:	55                   	push   %ebp
8010323e:	89 e5                	mov    %esp,%ebp
80103240:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80103243:	a1 64 38 11 80       	mov    0x80113864,%eax
80103248:	85 c0                	test   %eax,%eax
8010324a:	75 02                	jne    8010324e <ioapicenable+0x11>
    return;
8010324c:	eb 37                	jmp    80103285 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010324e:	8b 45 08             	mov    0x8(%ebp),%eax
80103251:	83 c0 20             	add    $0x20,%eax
80103254:	8b 55 08             	mov    0x8(%ebp),%edx
80103257:	83 c2 08             	add    $0x8,%edx
8010325a:	01 d2                	add    %edx,%edx
8010325c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103260:	89 14 24             	mov    %edx,(%esp)
80103263:	e8 08 ff ff ff       	call   80103170 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103268:	8b 45 0c             	mov    0xc(%ebp),%eax
8010326b:	c1 e0 18             	shl    $0x18,%eax
8010326e:	8b 55 08             	mov    0x8(%ebp),%edx
80103271:	83 c2 08             	add    $0x8,%edx
80103274:	01 d2                	add    %edx,%edx
80103276:	83 c2 01             	add    $0x1,%edx
80103279:	89 44 24 04          	mov    %eax,0x4(%esp)
8010327d:	89 14 24             	mov    %edx,(%esp)
80103280:	e8 eb fe ff ff       	call   80103170 <ioapicwrite>
}
80103285:	c9                   	leave  
80103286:	c3                   	ret    

80103287 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103287:	55                   	push   %ebp
80103288:	89 e5                	mov    %esp,%ebp
8010328a:	8b 45 08             	mov    0x8(%ebp),%eax
8010328d:	05 00 00 00 80       	add    $0x80000000,%eax
80103292:	5d                   	pop    %ebp
80103293:	c3                   	ret    

80103294 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103294:	55                   	push   %ebp
80103295:	89 e5                	mov    %esp,%ebp
80103297:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
8010329a:	c7 44 24 04 8e 95 10 	movl   $0x8010958e,0x4(%esp)
801032a1:	80 
801032a2:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
801032a9:	e8 58 27 00 00       	call   80105a06 <initlock>
  kmem.use_lock = 0;
801032ae:	c7 05 34 35 11 80 00 	movl   $0x0,0x80113534
801032b5:	00 00 00 
  freerange(vstart, vend);
801032b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801032bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801032bf:	8b 45 08             	mov    0x8(%ebp),%eax
801032c2:	89 04 24             	mov    %eax,(%esp)
801032c5:	e8 26 00 00 00       	call   801032f0 <freerange>
}
801032ca:	c9                   	leave  
801032cb:	c3                   	ret    

801032cc <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801032cc:	55                   	push   %ebp
801032cd:	89 e5                	mov    %esp,%ebp
801032cf:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801032d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801032d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	89 04 24             	mov    %eax,(%esp)
801032df:	e8 0c 00 00 00       	call   801032f0 <freerange>
  kmem.use_lock = 1;
801032e4:	c7 05 34 35 11 80 01 	movl   $0x1,0x80113534
801032eb:	00 00 00 
}
801032ee:	c9                   	leave  
801032ef:	c3                   	ret    

801032f0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801032f0:	55                   	push   %ebp
801032f1:	89 e5                	mov    %esp,%ebp
801032f3:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801032f6:	8b 45 08             	mov    0x8(%ebp),%eax
801032f9:	05 ff 0f 00 00       	add    $0xfff,%eax
801032fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103303:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103306:	eb 12                	jmp    8010331a <freerange+0x2a>
    kfree(p);
80103308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330b:	89 04 24             	mov    %eax,(%esp)
8010330e:	e8 16 00 00 00       	call   80103329 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103313:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010331a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331d:	05 00 10 00 00       	add    $0x1000,%eax
80103322:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103325:	76 e1                	jbe    80103308 <freerange+0x18>
    kfree(p);
}
80103327:	c9                   	leave  
80103328:	c3                   	ret    

80103329 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80103329:	55                   	push   %ebp
8010332a:	89 e5                	mov    %esp,%ebp
8010332c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
8010332f:	8b 45 08             	mov    0x8(%ebp),%eax
80103332:	25 ff 0f 00 00       	and    $0xfff,%eax
80103337:	85 c0                	test   %eax,%eax
80103339:	75 1b                	jne    80103356 <kfree+0x2d>
8010333b:	81 7d 08 5c 66 11 80 	cmpl   $0x8011665c,0x8(%ebp)
80103342:	72 12                	jb     80103356 <kfree+0x2d>
80103344:	8b 45 08             	mov    0x8(%ebp),%eax
80103347:	89 04 24             	mov    %eax,(%esp)
8010334a:	e8 38 ff ff ff       	call   80103287 <v2p>
8010334f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103354:	76 0c                	jbe    80103362 <kfree+0x39>
    panic("kfree");
80103356:	c7 04 24 93 95 10 80 	movl   $0x80109593,(%esp)
8010335d:	e8 d8 d1 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103362:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80103369:	00 
8010336a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103371:	00 
80103372:	8b 45 08             	mov    0x8(%ebp),%eax
80103375:	89 04 24             	mov    %eax,(%esp)
80103378:	e8 fe 28 00 00       	call   80105c7b <memset>

  if(kmem.use_lock)
8010337d:	a1 34 35 11 80       	mov    0x80113534,%eax
80103382:	85 c0                	test   %eax,%eax
80103384:	74 0c                	je     80103392 <kfree+0x69>
    acquire(&kmem.lock);
80103386:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
8010338d:	e8 95 26 00 00       	call   80105a27 <acquire>
  r = (struct run*)v;
80103392:	8b 45 08             	mov    0x8(%ebp),%eax
80103395:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103398:	8b 15 38 35 11 80    	mov    0x80113538,%edx
8010339e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a6:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
801033ab:	a1 34 35 11 80       	mov    0x80113534,%eax
801033b0:	85 c0                	test   %eax,%eax
801033b2:	74 0c                	je     801033c0 <kfree+0x97>
    release(&kmem.lock);
801033b4:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
801033bb:	e8 c9 26 00 00       	call   80105a89 <release>
}
801033c0:	c9                   	leave  
801033c1:	c3                   	ret    

801033c2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801033c2:	55                   	push   %ebp
801033c3:	89 e5                	mov    %esp,%ebp
801033c5:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
801033c8:	a1 34 35 11 80       	mov    0x80113534,%eax
801033cd:	85 c0                	test   %eax,%eax
801033cf:	74 0c                	je     801033dd <kalloc+0x1b>
    acquire(&kmem.lock);
801033d1:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
801033d8:	e8 4a 26 00 00       	call   80105a27 <acquire>
  r = kmem.freelist;
801033dd:	a1 38 35 11 80       	mov    0x80113538,%eax
801033e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801033e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801033e9:	74 0a                	je     801033f5 <kalloc+0x33>
    kmem.freelist = r->next;
801033eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ee:	8b 00                	mov    (%eax),%eax
801033f0:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
801033f5:	a1 34 35 11 80       	mov    0x80113534,%eax
801033fa:	85 c0                	test   %eax,%eax
801033fc:	74 0c                	je     8010340a <kalloc+0x48>
    release(&kmem.lock);
801033fe:	c7 04 24 00 35 11 80 	movl   $0x80113500,(%esp)
80103405:	e8 7f 26 00 00       	call   80105a89 <release>
  return (char*)r;
8010340a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010340d:	c9                   	leave  
8010340e:	c3                   	ret    

8010340f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010340f:	55                   	push   %ebp
80103410:	89 e5                	mov    %esp,%ebp
80103412:	83 ec 14             	sub    $0x14,%esp
80103415:	8b 45 08             	mov    0x8(%ebp),%eax
80103418:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010341c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103420:	89 c2                	mov    %eax,%edx
80103422:	ec                   	in     (%dx),%al
80103423:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103426:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010342a:	c9                   	leave  
8010342b:	c3                   	ret    

8010342c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010342c:	55                   	push   %ebp
8010342d:	89 e5                	mov    %esp,%ebp
8010342f:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103432:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103439:	e8 d1 ff ff ff       	call   8010340f <inb>
8010343e:	0f b6 c0             	movzbl %al,%eax
80103441:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103447:	83 e0 01             	and    $0x1,%eax
8010344a:	85 c0                	test   %eax,%eax
8010344c:	75 0a                	jne    80103458 <kbdgetc+0x2c>
    return -1;
8010344e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103453:	e9 25 01 00 00       	jmp    8010357d <kbdgetc+0x151>
  data = inb(KBDATAP);
80103458:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
8010345f:	e8 ab ff ff ff       	call   8010340f <inb>
80103464:	0f b6 c0             	movzbl %al,%eax
80103467:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010346a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103471:	75 17                	jne    8010348a <kbdgetc+0x5e>
    shift |= E0ESC;
80103473:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103478:	83 c8 40             	or     $0x40,%eax
8010347b:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103480:	b8 00 00 00 00       	mov    $0x0,%eax
80103485:	e9 f3 00 00 00       	jmp    8010357d <kbdgetc+0x151>
  } else if(data & 0x80){
8010348a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010348d:	25 80 00 00 00       	and    $0x80,%eax
80103492:	85 c0                	test   %eax,%eax
80103494:	74 45                	je     801034db <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103496:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010349b:	83 e0 40             	and    $0x40,%eax
8010349e:	85 c0                	test   %eax,%eax
801034a0:	75 08                	jne    801034aa <kbdgetc+0x7e>
801034a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034a5:	83 e0 7f             	and    $0x7f,%eax
801034a8:	eb 03                	jmp    801034ad <kbdgetc+0x81>
801034aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801034b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034b3:	05 40 a0 10 80       	add    $0x8010a040,%eax
801034b8:	0f b6 00             	movzbl (%eax),%eax
801034bb:	83 c8 40             	or     $0x40,%eax
801034be:	0f b6 c0             	movzbl %al,%eax
801034c1:	f7 d0                	not    %eax
801034c3:	89 c2                	mov    %eax,%edx
801034c5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034ca:	21 d0                	and    %edx,%eax
801034cc:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
801034d1:	b8 00 00 00 00       	mov    $0x0,%eax
801034d6:	e9 a2 00 00 00       	jmp    8010357d <kbdgetc+0x151>
  } else if(shift & E0ESC){
801034db:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034e0:	83 e0 40             	and    $0x40,%eax
801034e3:	85 c0                	test   %eax,%eax
801034e5:	74 14                	je     801034fb <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801034e7:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801034ee:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034f3:	83 e0 bf             	and    $0xffffffbf,%eax
801034f6:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
801034fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034fe:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103503:	0f b6 00             	movzbl (%eax),%eax
80103506:	0f b6 d0             	movzbl %al,%edx
80103509:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010350e:	09 d0                	or     %edx,%eax
80103510:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80103515:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103518:	05 40 a1 10 80       	add    $0x8010a140,%eax
8010351d:	0f b6 00             	movzbl (%eax),%eax
80103520:	0f b6 d0             	movzbl %al,%edx
80103523:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103528:	31 d0                	xor    %edx,%eax
8010352a:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
8010352f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103534:	83 e0 03             	and    $0x3,%eax
80103537:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
8010353e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103541:	01 d0                	add    %edx,%eax
80103543:	0f b6 00             	movzbl (%eax),%eax
80103546:	0f b6 c0             	movzbl %al,%eax
80103549:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010354c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103551:	83 e0 08             	and    $0x8,%eax
80103554:	85 c0                	test   %eax,%eax
80103556:	74 22                	je     8010357a <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103558:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010355c:	76 0c                	jbe    8010356a <kbdgetc+0x13e>
8010355e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103562:	77 06                	ja     8010356a <kbdgetc+0x13e>
      c += 'A' - 'a';
80103564:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103568:	eb 10                	jmp    8010357a <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
8010356a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010356e:	76 0a                	jbe    8010357a <kbdgetc+0x14e>
80103570:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103574:	77 04                	ja     8010357a <kbdgetc+0x14e>
      c += 'a' - 'A';
80103576:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010357a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010357d:	c9                   	leave  
8010357e:	c3                   	ret    

8010357f <kbdintr>:

void
kbdintr(void)
{
8010357f:	55                   	push   %ebp
80103580:	89 e5                	mov    %esp,%ebp
80103582:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103585:	c7 04 24 2c 34 10 80 	movl   $0x8010342c,(%esp)
8010358c:	e8 37 d2 ff ff       	call   801007c8 <consoleintr>
}
80103591:	c9                   	leave  
80103592:	c3                   	ret    

80103593 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103593:	55                   	push   %ebp
80103594:	89 e5                	mov    %esp,%ebp
80103596:	83 ec 14             	sub    $0x14,%esp
80103599:	8b 45 08             	mov    0x8(%ebp),%eax
8010359c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035a0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801035a4:	89 c2                	mov    %eax,%edx
801035a6:	ec                   	in     (%dx),%al
801035a7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801035aa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801035ae:	c9                   	leave  
801035af:	c3                   	ret    

801035b0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801035b0:	55                   	push   %ebp
801035b1:	89 e5                	mov    %esp,%ebp
801035b3:	83 ec 08             	sub    $0x8,%esp
801035b6:	8b 55 08             	mov    0x8(%ebp),%edx
801035b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801035bc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801035c0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035c3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801035c7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801035cb:	ee                   	out    %al,(%dx)
}
801035cc:	c9                   	leave  
801035cd:	c3                   	ret    

801035ce <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035d4:	9c                   	pushf  
801035d5:	58                   	pop    %eax
801035d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801035d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801035dc:	c9                   	leave  
801035dd:	c3                   	ret    

801035de <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801035de:	55                   	push   %ebp
801035df:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801035e1:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801035e6:	8b 55 08             	mov    0x8(%ebp),%edx
801035e9:	c1 e2 02             	shl    $0x2,%edx
801035ec:	01 c2                	add    %eax,%edx
801035ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801035f1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801035f3:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801035f8:	83 c0 20             	add    $0x20,%eax
801035fb:	8b 00                	mov    (%eax),%eax
}
801035fd:	5d                   	pop    %ebp
801035fe:	c3                   	ret    

801035ff <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801035ff:	55                   	push   %ebp
80103600:	89 e5                	mov    %esp,%ebp
80103602:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103605:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010360a:	85 c0                	test   %eax,%eax
8010360c:	75 05                	jne    80103613 <lapicinit+0x14>
    return;
8010360e:	e9 43 01 00 00       	jmp    80103756 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103613:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010361a:	00 
8010361b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103622:	e8 b7 ff ff ff       	call   801035de <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103627:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010362e:	00 
8010362f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103636:	e8 a3 ff ff ff       	call   801035de <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010363b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103642:	00 
80103643:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010364a:	e8 8f ff ff ff       	call   801035de <lapicw>
  lapicw(TICR, 10000000); 
8010364f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103656:	00 
80103657:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010365e:	e8 7b ff ff ff       	call   801035de <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103663:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010366a:	00 
8010366b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103672:	e8 67 ff ff ff       	call   801035de <lapicw>
  lapicw(LINT1, MASKED);
80103677:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010367e:	00 
8010367f:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103686:	e8 53 ff ff ff       	call   801035de <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010368b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103690:	83 c0 30             	add    $0x30,%eax
80103693:	8b 00                	mov    (%eax),%eax
80103695:	c1 e8 10             	shr    $0x10,%eax
80103698:	0f b6 c0             	movzbl %al,%eax
8010369b:	83 f8 03             	cmp    $0x3,%eax
8010369e:	76 14                	jbe    801036b4 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801036a0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801036a7:	00 
801036a8:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801036af:	e8 2a ff ff ff       	call   801035de <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801036b4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801036bb:	00 
801036bc:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801036c3:	e8 16 ff ff ff       	call   801035de <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801036c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801036cf:	00 
801036d0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801036d7:	e8 02 ff ff ff       	call   801035de <lapicw>
  lapicw(ESR, 0);
801036dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801036e3:	00 
801036e4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801036eb:	e8 ee fe ff ff       	call   801035de <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801036f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801036f7:	00 
801036f8:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801036ff:	e8 da fe ff ff       	call   801035de <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103704:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010370b:	00 
8010370c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103713:	e8 c6 fe ff ff       	call   801035de <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103718:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010371f:	00 
80103720:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103727:	e8 b2 fe ff ff       	call   801035de <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010372c:	90                   	nop
8010372d:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103732:	05 00 03 00 00       	add    $0x300,%eax
80103737:	8b 00                	mov    (%eax),%eax
80103739:	25 00 10 00 00       	and    $0x1000,%eax
8010373e:	85 c0                	test   %eax,%eax
80103740:	75 eb                	jne    8010372d <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103742:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103749:	00 
8010374a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103751:	e8 88 fe ff ff       	call   801035de <lapicw>
}
80103756:	c9                   	leave  
80103757:	c3                   	ret    

80103758 <cpunum>:

int
cpunum(void)
{
80103758:	55                   	push   %ebp
80103759:	89 e5                	mov    %esp,%ebp
8010375b:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010375e:	e8 6b fe ff ff       	call   801035ce <readeflags>
80103763:	25 00 02 00 00       	and    $0x200,%eax
80103768:	85 c0                	test   %eax,%eax
8010376a:	74 25                	je     80103791 <cpunum+0x39>
    static int n;
    if(n++ == 0)
8010376c:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80103771:	8d 50 01             	lea    0x1(%eax),%edx
80103774:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
8010377a:	85 c0                	test   %eax,%eax
8010377c:	75 13                	jne    80103791 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
8010377e:	8b 45 04             	mov    0x4(%ebp),%eax
80103781:	89 44 24 04          	mov    %eax,0x4(%esp)
80103785:	c7 04 24 9c 95 10 80 	movl   $0x8010959c,(%esp)
8010378c:	e8 0f cc ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103791:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103796:	85 c0                	test   %eax,%eax
80103798:	74 0f                	je     801037a9 <cpunum+0x51>
    return lapic[ID]>>24;
8010379a:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010379f:	83 c0 20             	add    $0x20,%eax
801037a2:	8b 00                	mov    (%eax),%eax
801037a4:	c1 e8 18             	shr    $0x18,%eax
801037a7:	eb 05                	jmp    801037ae <cpunum+0x56>
  return 0;
801037a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801037ae:	c9                   	leave  
801037af:	c3                   	ret    

801037b0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801037b0:	55                   	push   %ebp
801037b1:	89 e5                	mov    %esp,%ebp
801037b3:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801037b6:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801037bb:	85 c0                	test   %eax,%eax
801037bd:	74 14                	je     801037d3 <lapiceoi+0x23>
    lapicw(EOI, 0);
801037bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801037c6:	00 
801037c7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801037ce:	e8 0b fe ff ff       	call   801035de <lapicw>
}
801037d3:	c9                   	leave  
801037d4:	c3                   	ret    

801037d5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801037d5:	55                   	push   %ebp
801037d6:	89 e5                	mov    %esp,%ebp
}
801037d8:	5d                   	pop    %ebp
801037d9:	c3                   	ret    

801037da <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801037da:	55                   	push   %ebp
801037db:	89 e5                	mov    %esp,%ebp
801037dd:	83 ec 1c             	sub    $0x1c,%esp
801037e0:	8b 45 08             	mov    0x8(%ebp),%eax
801037e3:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801037e6:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801037ed:	00 
801037ee:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801037f5:	e8 b6 fd ff ff       	call   801035b0 <outb>
  outb(CMOS_PORT+1, 0x0A);
801037fa:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103801:	00 
80103802:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103809:	e8 a2 fd ff ff       	call   801035b0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010380e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103815:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103818:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010381d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103820:	8d 50 02             	lea    0x2(%eax),%edx
80103823:	8b 45 0c             	mov    0xc(%ebp),%eax
80103826:	c1 e8 04             	shr    $0x4,%eax
80103829:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010382c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103830:	c1 e0 18             	shl    $0x18,%eax
80103833:	89 44 24 04          	mov    %eax,0x4(%esp)
80103837:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010383e:	e8 9b fd ff ff       	call   801035de <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103843:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010384a:	00 
8010384b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103852:	e8 87 fd ff ff       	call   801035de <lapicw>
  microdelay(200);
80103857:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010385e:	e8 72 ff ff ff       	call   801037d5 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103863:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010386a:	00 
8010386b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103872:	e8 67 fd ff ff       	call   801035de <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103877:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010387e:	e8 52 ff ff ff       	call   801037d5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103883:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010388a:	eb 40                	jmp    801038cc <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010388c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103890:	c1 e0 18             	shl    $0x18,%eax
80103893:	89 44 24 04          	mov    %eax,0x4(%esp)
80103897:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010389e:	e8 3b fd ff ff       	call   801035de <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801038a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801038a6:	c1 e8 0c             	shr    $0xc,%eax
801038a9:	80 cc 06             	or     $0x6,%ah
801038ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801038b0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801038b7:	e8 22 fd ff ff       	call   801035de <lapicw>
    microdelay(200);
801038bc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801038c3:	e8 0d ff ff ff       	call   801037d5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801038cc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801038d0:	7e ba                	jle    8010388c <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801038d2:	c9                   	leave  
801038d3:	c3                   	ret    

801038d4 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801038d4:	55                   	push   %ebp
801038d5:	89 e5                	mov    %esp,%ebp
801038d7:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	0f b6 c0             	movzbl %al,%eax
801038e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801038e4:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801038eb:	e8 c0 fc ff ff       	call   801035b0 <outb>
  microdelay(200);
801038f0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801038f7:	e8 d9 fe ff ff       	call   801037d5 <microdelay>

  return inb(CMOS_RETURN);
801038fc:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103903:	e8 8b fc ff ff       	call   80103593 <inb>
80103908:	0f b6 c0             	movzbl %al,%eax
}
8010390b:	c9                   	leave  
8010390c:	c3                   	ret    

8010390d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010390d:	55                   	push   %ebp
8010390e:	89 e5                	mov    %esp,%ebp
80103910:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103913:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010391a:	e8 b5 ff ff ff       	call   801038d4 <cmos_read>
8010391f:	8b 55 08             	mov    0x8(%ebp),%edx
80103922:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103924:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010392b:	e8 a4 ff ff ff       	call   801038d4 <cmos_read>
80103930:	8b 55 08             	mov    0x8(%ebp),%edx
80103933:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103936:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010393d:	e8 92 ff ff ff       	call   801038d4 <cmos_read>
80103942:	8b 55 08             	mov    0x8(%ebp),%edx
80103945:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103948:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010394f:	e8 80 ff ff ff       	call   801038d4 <cmos_read>
80103954:	8b 55 08             	mov    0x8(%ebp),%edx
80103957:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010395a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103961:	e8 6e ff ff ff       	call   801038d4 <cmos_read>
80103966:	8b 55 08             	mov    0x8(%ebp),%edx
80103969:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010396c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103973:	e8 5c ff ff ff       	call   801038d4 <cmos_read>
80103978:	8b 55 08             	mov    0x8(%ebp),%edx
8010397b:	89 42 14             	mov    %eax,0x14(%edx)
}
8010397e:	c9                   	leave  
8010397f:	c3                   	ret    

80103980 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103980:	55                   	push   %ebp
80103981:	89 e5                	mov    %esp,%ebp
80103983:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103986:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010398d:	e8 42 ff ff ff       	call   801038d4 <cmos_read>
80103992:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103998:	83 e0 04             	and    $0x4,%eax
8010399b:	85 c0                	test   %eax,%eax
8010399d:	0f 94 c0             	sete   %al
801039a0:	0f b6 c0             	movzbl %al,%eax
801039a3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039a6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039a9:	89 04 24             	mov    %eax,(%esp)
801039ac:	e8 5c ff ff ff       	call   8010390d <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801039b1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801039b8:	e8 17 ff ff ff       	call   801038d4 <cmos_read>
801039bd:	25 80 00 00 00       	and    $0x80,%eax
801039c2:	85 c0                	test   %eax,%eax
801039c4:	74 02                	je     801039c8 <cmostime+0x48>
        continue;
801039c6:	eb 36                	jmp    801039fe <cmostime+0x7e>
    fill_rtcdate(&t2);
801039c8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801039cb:	89 04 24             	mov    %eax,(%esp)
801039ce:	e8 3a ff ff ff       	call   8010390d <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801039d3:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801039da:	00 
801039db:	8d 45 c0             	lea    -0x40(%ebp),%eax
801039de:	89 44 24 04          	mov    %eax,0x4(%esp)
801039e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039e5:	89 04 24             	mov    %eax,(%esp)
801039e8:	e8 05 23 00 00       	call   80105cf2 <memcmp>
801039ed:	85 c0                	test   %eax,%eax
801039ef:	75 0d                	jne    801039fe <cmostime+0x7e>
      break;
801039f1:	90                   	nop
  }

  // convert
  if (bcd) {
801039f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801039f6:	0f 84 ac 00 00 00    	je     80103aa8 <cmostime+0x128>
801039fc:	eb 02                	jmp    80103a00 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801039fe:	eb a6                	jmp    801039a6 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a00:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a03:	c1 e8 04             	shr    $0x4,%eax
80103a06:	89 c2                	mov    %eax,%edx
80103a08:	89 d0                	mov    %edx,%eax
80103a0a:	c1 e0 02             	shl    $0x2,%eax
80103a0d:	01 d0                	add    %edx,%eax
80103a0f:	01 c0                	add    %eax,%eax
80103a11:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103a14:	83 e2 0f             	and    $0xf,%edx
80103a17:	01 d0                	add    %edx,%eax
80103a19:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a1f:	c1 e8 04             	shr    $0x4,%eax
80103a22:	89 c2                	mov    %eax,%edx
80103a24:	89 d0                	mov    %edx,%eax
80103a26:	c1 e0 02             	shl    $0x2,%eax
80103a29:	01 d0                	add    %edx,%eax
80103a2b:	01 c0                	add    %eax,%eax
80103a2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103a30:	83 e2 0f             	and    $0xf,%edx
80103a33:	01 d0                	add    %edx,%eax
80103a35:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a3b:	c1 e8 04             	shr    $0x4,%eax
80103a3e:	89 c2                	mov    %eax,%edx
80103a40:	89 d0                	mov    %edx,%eax
80103a42:	c1 e0 02             	shl    $0x2,%eax
80103a45:	01 d0                	add    %edx,%eax
80103a47:	01 c0                	add    %eax,%eax
80103a49:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103a4c:	83 e2 0f             	and    $0xf,%edx
80103a4f:	01 d0                	add    %edx,%eax
80103a51:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103a54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a57:	c1 e8 04             	shr    $0x4,%eax
80103a5a:	89 c2                	mov    %eax,%edx
80103a5c:	89 d0                	mov    %edx,%eax
80103a5e:	c1 e0 02             	shl    $0x2,%eax
80103a61:	01 d0                	add    %edx,%eax
80103a63:	01 c0                	add    %eax,%eax
80103a65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103a68:	83 e2 0f             	and    $0xf,%edx
80103a6b:	01 d0                	add    %edx,%eax
80103a6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103a70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a73:	c1 e8 04             	shr    $0x4,%eax
80103a76:	89 c2                	mov    %eax,%edx
80103a78:	89 d0                	mov    %edx,%eax
80103a7a:	c1 e0 02             	shl    $0x2,%eax
80103a7d:	01 d0                	add    %edx,%eax
80103a7f:	01 c0                	add    %eax,%eax
80103a81:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103a84:	83 e2 0f             	and    $0xf,%edx
80103a87:	01 d0                	add    %edx,%eax
80103a89:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a8f:	c1 e8 04             	shr    $0x4,%eax
80103a92:	89 c2                	mov    %eax,%edx
80103a94:	89 d0                	mov    %edx,%eax
80103a96:	c1 e0 02             	shl    $0x2,%eax
80103a99:	01 d0                	add    %edx,%eax
80103a9b:	01 c0                	add    %eax,%eax
80103a9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103aa0:	83 e2 0f             	and    $0xf,%edx
80103aa3:	01 d0                	add    %edx,%eax
80103aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80103aab:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103aae:	89 10                	mov    %edx,(%eax)
80103ab0:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ab3:	89 50 04             	mov    %edx,0x4(%eax)
80103ab6:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103ab9:	89 50 08             	mov    %edx,0x8(%eax)
80103abc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103abf:	89 50 0c             	mov    %edx,0xc(%eax)
80103ac2:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103ac5:	89 50 10             	mov    %edx,0x10(%eax)
80103ac8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103acb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103ace:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad1:	8b 40 14             	mov    0x14(%eax),%eax
80103ad4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103ada:	8b 45 08             	mov    0x8(%ebp),%eax
80103add:	89 50 14             	mov    %edx,0x14(%eax)
}
80103ae0:	c9                   	leave  
80103ae1:	c3                   	ret    

80103ae2 <initlog>:
static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
80103ae2:	55                   	push   %ebp
80103ae3:	89 e5                	mov    %esp,%ebp
80103ae5:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103ae8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aef:	e9 91 00 00 00       	jmp    80103b85 <initlog+0xa3>
     initlock(&logs[i].lock, "log");
80103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103afd:	05 40 35 11 80       	add    $0x80113540,%eax
80103b02:	c7 44 24 04 c8 95 10 	movl   $0x801095c8,0x4(%esp)
80103b09:	80 
80103b0a:	89 04 24             	mov    %eax,(%esp)
80103b0d:	e8 f4 1e 00 00       	call   80105a06 <initlock>
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b15:	c1 e0 05             	shl    $0x5,%eax
80103b18:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b1d:	8b 50 0c             	mov    0xc(%eax),%edx
80103b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b23:	c1 e0 05             	shl    $0x5,%eax
80103b26:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b2b:	8b 00                	mov    (%eax),%eax
80103b2d:	01 d0                	add    %edx,%eax
80103b2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b32:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103b38:	81 c2 70 35 11 80    	add    $0x80113570,%edx
80103b3e:	89 42 04             	mov    %eax,0x4(%edx)
  logs[i].size =  sbs[i].nlog;
80103b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b44:	c1 e0 05             	shl    $0x5,%eax
80103b47:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103b4c:	8b 40 0c             	mov    0xc(%eax),%eax
80103b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b52:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103b58:	81 c2 70 35 11 80    	add    $0x80113570,%edx
80103b5e:	89 42 08             	mov    %eax,0x8(%edx)
  logs[i].dev = dev;
80103b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b64:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b6a:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103b70:	8b 45 08             	mov    0x8(%ebp),%eax
80103b73:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	89 04 24             	mov    %eax,(%esp)
80103b7c:	e8 4f 02 00 00       	call   80103dd0 <recover_from_log>
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103b81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b85:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103b89:	0f 8e 65 ff ff ff    	jle    80103af4 <initlog+0x12>
  logs[i].size =  sbs[i].nlog;
  logs[i].dev = dev;
  recover_from_log(i);
}
 
}
80103b8f:	c9                   	leave  
80103b90:	c3                   	ret    

80103b91 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103b91:	55                   	push   %ebp
80103b92:	89 e5                	mov    %esp,%ebp
80103b94:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103b97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b9e:	e9 b7 00 00 00       	jmp    80103c5a <install_trans+0xc9>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bac:	05 70 35 11 80       	add    $0x80113570,%eax
80103bb1:	8b 50 04             	mov    0x4(%eax),%edx
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb7:	01 d0                	add    %edx,%eax
80103bb9:	83 c0 01             	add    $0x1,%eax
80103bbc:	89 c2                	mov    %eax,%edx
80103bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bc7:	05 80 35 11 80       	add    $0x80113580,%eax
80103bcc:	8b 40 04             	mov    0x4(%eax),%eax
80103bcf:	89 54 24 04          	mov    %edx,0x4(%esp)
80103bd3:	89 04 24             	mov    %eax,(%esp)
80103bd6:	e8 cb c5 ff ff       	call   801001a6 <bread>
80103bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103bde:	8b 45 08             	mov    0x8(%ebp),%eax
80103be1:	6b d0 31             	imul   $0x31,%eax,%edx
80103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be7:	01 d0                	add    %edx,%eax
80103be9:	83 c0 10             	add    $0x10,%eax
80103bec:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103bf3:	89 c2                	mov    %eax,%edx
80103bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bfe:	05 80 35 11 80       	add    $0x80113580,%eax
80103c03:	8b 40 04             	mov    0x4(%eax),%eax
80103c06:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c0a:	89 04 24             	mov    %eax,(%esp)
80103c0d:	e8 94 c5 ff ff       	call   801001a6 <bread>
80103c12:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c18:	8d 50 18             	lea    0x18(%eax),%edx
80103c1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c1e:	83 c0 18             	add    $0x18,%eax
80103c21:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103c28:	00 
80103c29:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c2d:	89 04 24             	mov    %eax,(%esp)
80103c30:	e8 15 21 00 00       	call   80105d4a <memmove>
    bwrite(dbuf);  // write dst to disk
80103c35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c38:	89 04 24             	mov    %eax,(%esp)
80103c3b:	e8 9d c5 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c43:	89 04 24             	mov    %eax,(%esp)
80103c46:	e8 cc c5 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103c4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c4e:	89 04 24             	mov    %eax,(%esp)
80103c51:	e8 c1 c5 ff ff       	call   80100217 <brelse>
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103c56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c63:	05 80 35 11 80       	add    $0x80113580,%eax
80103c68:	8b 40 08             	mov    0x8(%eax),%eax
80103c6b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c6e:	0f 8f 2f ff ff ff    	jg     80103ba3 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103c74:	c9                   	leave  
80103c75:	c3                   	ret    

80103c76 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103c76:	55                   	push   %ebp
80103c77:	89 e5                	mov    %esp,%ebp
80103c79:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c85:	05 70 35 11 80       	add    $0x80113570,%eax
80103c8a:	8b 40 04             	mov    0x4(%eax),%eax
80103c8d:	89 c2                	mov    %eax,%edx
80103c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c92:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c98:	05 80 35 11 80       	add    $0x80113580,%eax
80103c9d:	8b 40 04             	mov    0x4(%eax),%eax
80103ca0:	89 54 24 04          	mov    %edx,0x4(%esp)
80103ca4:	89 04 24             	mov    %eax,(%esp)
80103ca7:	e8 fa c4 ff ff       	call   801001a6 <bread>
80103cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb2:	83 c0 18             	add    $0x18,%eax
80103cb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cbb:	8b 00                	mov    (%eax),%eax
80103cbd:	8b 55 08             	mov    0x8(%ebp),%edx
80103cc0:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103cc6:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103ccc:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103ccf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103cd6:	eb 23                	jmp    80103cfb <read_head+0x85>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103cd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cde:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103ce2:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce5:	6b ca 31             	imul   $0x31,%edx,%ecx
80103ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ceb:	01 ca                	add    %ecx,%edx
80103ced:	83 c2 10             	add    $0x10,%edx
80103cf0:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103cf7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfe:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d04:	05 80 35 11 80       	add    $0x80113580,%eax
80103d09:	8b 40 08             	mov    0x8(%eax),%eax
80103d0c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d0f:	7f c7                	jg     80103cd8 <read_head+0x62>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d14:	89 04 24             	mov    %eax,(%esp)
80103d17:	e8 fb c4 ff ff       	call   80100217 <brelse>
}
80103d1c:	c9                   	leave  
80103d1d:	c3                   	ret    

80103d1e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103d1e:	55                   	push   %ebp
80103d1f:	89 e5                	mov    %esp,%ebp
80103d21:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d24:	8b 45 08             	mov    0x8(%ebp),%eax
80103d27:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d2d:	05 70 35 11 80       	add    $0x80113570,%eax
80103d32:	8b 40 04             	mov    0x4(%eax),%eax
80103d35:	89 c2                	mov    %eax,%edx
80103d37:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d40:	05 80 35 11 80       	add    $0x80113580,%eax
80103d45:	8b 40 04             	mov    0x4(%eax),%eax
80103d48:	89 54 24 04          	mov    %edx,0x4(%esp)
80103d4c:	89 04 24             	mov    %eax,(%esp)
80103d4f:	e8 52 c4 ff ff       	call   801001a6 <bread>
80103d54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5a:	83 c0 18             	add    $0x18,%eax
80103d5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103d60:	8b 45 08             	mov    0x8(%ebp),%eax
80103d63:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d69:	05 80 35 11 80       	add    $0x80113580,%eax
80103d6e:	8b 50 08             	mov    0x8(%eax),%edx
80103d71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d74:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d7d:	eb 23                	jmp    80103da2 <write_head+0x84>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d82:	6b d0 31             	imul   $0x31,%eax,%edx
80103d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d88:	01 d0                	add    %edx,%eax
80103d8a:	83 c0 10             	add    $0x10,%eax
80103d8d:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103d94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d9a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103da2:	8b 45 08             	mov    0x8(%ebp),%eax
80103da5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dab:	05 80 35 11 80       	add    $0x80113580,%eax
80103db0:	8b 40 08             	mov    0x8(%eax),%eax
80103db3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103db6:	7f c7                	jg     80103d7f <write_head+0x61>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dbb:	89 04 24             	mov    %eax,(%esp)
80103dbe:	e8 1a c4 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc6:	89 04 24             	mov    %eax,(%esp)
80103dc9:	e8 49 c4 ff ff       	call   80100217 <brelse>
}
80103dce:	c9                   	leave  
80103dcf:	c3                   	ret    

80103dd0 <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103dd0:	55                   	push   %ebp
80103dd1:	89 e5                	mov    %esp,%ebp
80103dd3:	83 ec 18             	sub    $0x18,%esp
  read_head(partitionNumber);      
80103dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd9:	89 04 24             	mov    %eax,(%esp)
80103ddc:	e8 95 fe ff ff       	call   80103c76 <read_head>
  install_trans(partitionNumber); // if committed, copy from log to disk
80103de1:	8b 45 08             	mov    0x8(%ebp),%eax
80103de4:	89 04 24             	mov    %eax,(%esp)
80103de7:	e8 a5 fd ff ff       	call   80103b91 <install_trans>
  logs[partitionNumber].lh.n = 0;
80103dec:	8b 45 08             	mov    0x8(%ebp),%eax
80103def:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103df5:	05 80 35 11 80       	add    $0x80113580,%eax
80103dfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103e01:	8b 45 08             	mov    0x8(%ebp),%eax
80103e04:	89 04 24             	mov    %eax,(%esp)
80103e07:	e8 12 ff ff ff       	call   80103d1e <write_head>
}
80103e0c:	c9                   	leave  
80103e0d:	c3                   	ret    

80103e0e <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103e0e:	55                   	push   %ebp
80103e0f:	89 e5                	mov    %esp,%ebp
80103e11:	83 ec 18             	sub    $0x18,%esp
  acquire(&logs[partitionNumber].lock);
80103e14:	8b 45 08             	mov    0x8(%ebp),%eax
80103e17:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e1d:	05 40 35 11 80       	add    $0x80113540,%eax
80103e22:	89 04 24             	mov    %eax,(%esp)
80103e25:	e8 fd 1b 00 00       	call   80105a27 <acquire>
  while(1){
    if(logs[partitionNumber].committing){
80103e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e33:	05 80 35 11 80       	add    $0x80113580,%eax
80103e38:	8b 00                	mov    (%eax),%eax
80103e3a:	85 c0                	test   %eax,%eax
80103e3c:	74 2e                	je     80103e6c <begin_op+0x5e>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e41:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e47:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e50:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e56:	05 40 35 11 80       	add    $0x80113540,%eax
80103e5b:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e5f:	89 04 24             	mov    %eax,(%esp)
80103e62:	e8 f6 18 00 00       	call   8010575d <sleep>
80103e67:	e9 9d 00 00 00       	jmp    80103f09 <begin_op+0xfb>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e75:	05 80 35 11 80       	add    $0x80113580,%eax
80103e7a:	8b 48 08             	mov    0x8(%eax),%ecx
80103e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e80:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e86:	05 70 35 11 80       	add    $0x80113570,%eax
80103e8b:	8b 40 0c             	mov    0xc(%eax),%eax
80103e8e:	8d 50 01             	lea    0x1(%eax),%edx
80103e91:	89 d0                	mov    %edx,%eax
80103e93:	c1 e0 02             	shl    $0x2,%eax
80103e96:	01 d0                	add    %edx,%eax
80103e98:	01 c0                	add    %eax,%eax
80103e9a:	01 c8                	add    %ecx,%eax
80103e9c:	83 f8 1e             	cmp    $0x1e,%eax
80103e9f:	7e 2b                	jle    80103ecc <begin_op+0xbe>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eaa:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eb9:	05 40 35 11 80       	add    $0x80113540,%eax
80103ebe:	89 54 24 04          	mov    %edx,0x4(%esp)
80103ec2:	89 04 24             	mov    %eax,(%esp)
80103ec5:	e8 93 18 00 00       	call   8010575d <sleep>
80103eca:	eb 3d                	jmp    80103f09 <begin_op+0xfb>
    } else {
      logs[partitionNumber].outstanding += 1;
80103ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecf:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ed5:	05 70 35 11 80       	add    $0x80113570,%eax
80103eda:	8b 40 0c             	mov    0xc(%eax),%eax
80103edd:	8d 50 01             	lea    0x1(%eax),%edx
80103ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ee9:	05 70 35 11 80       	add    $0x80113570,%eax
80103eee:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103efa:	05 40 35 11 80       	add    $0x80113540,%eax
80103eff:	89 04 24             	mov    %eax,(%esp)
80103f02:	e8 82 1b 00 00       	call   80105a89 <release>
      break;
80103f07:	eb 05                	jmp    80103f0e <begin_op+0x100>
    }
  }
80103f09:	e9 1c ff ff ff       	jmp    80103e2a <begin_op+0x1c>
}
80103f0e:	c9                   	leave  
80103f0f:	c3                   	ret    

80103f10 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103f10:	55                   	push   %ebp
80103f11:	89 e5                	mov    %esp,%ebp
80103f13:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103f16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f20:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f26:	05 40 35 11 80       	add    $0x80113540,%eax
80103f2b:	89 04 24             	mov    %eax,(%esp)
80103f2e:	e8 f4 1a 00 00       	call   80105a27 <acquire>
  logs[partitionNumber].outstanding -= 1;
80103f33:	8b 45 08             	mov    0x8(%ebp),%eax
80103f36:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f3c:	05 70 35 11 80       	add    $0x80113570,%eax
80103f41:	8b 40 0c             	mov    0xc(%eax),%eax
80103f44:	8d 50 ff             	lea    -0x1(%eax),%edx
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f50:	05 70 35 11 80       	add    $0x80113570,%eax
80103f55:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80103f58:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f61:	05 80 35 11 80       	add    $0x80113580,%eax
80103f66:	8b 00                	mov    (%eax),%eax
80103f68:	85 c0                	test   %eax,%eax
80103f6a:	74 0c                	je     80103f78 <end_op+0x68>
    panic("log.committing");
80103f6c:	c7 04 24 cc 95 10 80 	movl   $0x801095cc,(%esp)
80103f73:	e8 c2 c5 ff ff       	call   8010053a <panic>
  if(logs[partitionNumber].outstanding == 0){
80103f78:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f81:	05 70 35 11 80       	add    $0x80113570,%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	85 c0                	test   %eax,%eax
80103f8b:	75 1d                	jne    80103faa <end_op+0x9a>
    do_commit = 1;
80103f8d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80103f94:	8b 45 08             	mov    0x8(%ebp),%eax
80103f97:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f9d:	05 80 35 11 80       	add    $0x80113580,%eax
80103fa2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80103fa8:	eb 16                	jmp    80103fc0 <end_op+0xb0>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
80103faa:	8b 45 08             	mov    0x8(%ebp),%eax
80103fad:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fb3:	05 40 35 11 80       	add    $0x80113540,%eax
80103fb8:	89 04 24             	mov    %eax,(%esp)
80103fbb:	e8 76 18 00 00       	call   80105836 <wakeup>
  }
  release(&logs[partitionNumber].lock);
80103fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fc9:	05 40 35 11 80       	add    $0x80113540,%eax
80103fce:	89 04 24             	mov    %eax,(%esp)
80103fd1:	e8 b3 1a 00 00       	call   80105a89 <release>

  if(do_commit){
80103fd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fda:	74 61                	je     8010403d <end_op+0x12d>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80103fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdf:	89 04 24             	mov    %eax,(%esp)
80103fe2:	e8 3d 01 00 00       	call   80104124 <commit>
    acquire(&logs[partitionNumber].lock);
80103fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fea:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ff0:	05 40 35 11 80       	add    $0x80113540,%eax
80103ff5:	89 04 24             	mov    %eax,(%esp)
80103ff8:	e8 2a 1a 00 00       	call   80105a27 <acquire>
    logs[partitionNumber].committing = 0;
80103ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80104000:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104006:	05 80 35 11 80       	add    $0x80113580,%eax
8010400b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
80104011:	8b 45 08             	mov    0x8(%ebp),%eax
80104014:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010401a:	05 40 35 11 80       	add    $0x80113540,%eax
8010401f:	89 04 24             	mov    %eax,(%esp)
80104022:	e8 0f 18 00 00       	call   80105836 <wakeup>
    release(&logs[partitionNumber].lock);
80104027:	8b 45 08             	mov    0x8(%ebp),%eax
8010402a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104030:	05 40 35 11 80       	add    $0x80113540,%eax
80104035:	89 04 24             	mov    %eax,(%esp)
80104038:	e8 4c 1a 00 00       	call   80105a89 <release>
  }
}
8010403d:	c9                   	leave  
8010403e:	c3                   	ret    

8010403f <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
8010403f:	55                   	push   %ebp
80104040:	89 e5                	mov    %esp,%ebp
80104042:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80104045:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010404c:	e9 b7 00 00 00       	jmp    80104108 <write_log+0xc9>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
80104051:	8b 45 08             	mov    0x8(%ebp),%eax
80104054:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010405a:	05 70 35 11 80       	add    $0x80113570,%eax
8010405f:	8b 50 04             	mov    0x4(%eax),%edx
80104062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104065:	01 d0                	add    %edx,%eax
80104067:	83 c0 01             	add    $0x1,%eax
8010406a:	89 c2                	mov    %eax,%edx
8010406c:	8b 45 08             	mov    0x8(%ebp),%eax
8010406f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104075:	05 80 35 11 80       	add    $0x80113580,%eax
8010407a:	8b 40 04             	mov    0x4(%eax),%eax
8010407d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104081:	89 04 24             	mov    %eax,(%esp)
80104084:	e8 1d c1 ff ff       	call   801001a6 <bread>
80104089:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
8010408c:	8b 45 08             	mov    0x8(%ebp),%eax
8010408f:	6b d0 31             	imul   $0x31,%eax,%edx
80104092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104095:	01 d0                	add    %edx,%eax
80104097:	83 c0 10             	add    $0x10,%eax
8010409a:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
801040a1:	89 c2                	mov    %eax,%edx
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040ac:	05 80 35 11 80       	add    $0x80113580,%eax
801040b1:	8b 40 04             	mov    0x4(%eax),%eax
801040b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801040b8:	89 04 24             	mov    %eax,(%esp)
801040bb:	e8 e6 c0 ff ff       	call   801001a6 <bread>
801040c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801040c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040c6:	8d 50 18             	lea    0x18(%eax),%edx
801040c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040cc:	83 c0 18             	add    $0x18,%eax
801040cf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801040d6:	00 
801040d7:	89 54 24 04          	mov    %edx,0x4(%esp)
801040db:	89 04 24             	mov    %eax,(%esp)
801040de:	e8 67 1c 00 00       	call   80105d4a <memmove>
    bwrite(to);  // write the log
801040e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 ef c0 ff ff       	call   801001dd <bwrite>
    brelse(from); 
801040ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f1:	89 04 24             	mov    %eax,(%esp)
801040f4:	e8 1e c1 ff ff       	call   80100217 <brelse>
    brelse(to);
801040f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 13 c1 ff ff       	call   80100217 <brelse>
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80104104:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104108:	8b 45 08             	mov    0x8(%ebp),%eax
8010410b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104111:	05 80 35 11 80       	add    $0x80113580,%eax
80104116:	8b 40 08             	mov    0x8(%eax),%eax
80104119:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010411c:	0f 8f 2f ff ff ff    	jg     80104051 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80104122:	c9                   	leave  
80104123:	c3                   	ret    

80104124 <commit>:

static void
commit(uint partitionNumber)
{
80104124:	55                   	push   %ebp
80104125:	89 e5                	mov    %esp,%ebp
80104127:	83 ec 18             	sub    $0x18,%esp
  if (logs[partitionNumber].lh.n > 0) {
8010412a:	8b 45 08             	mov    0x8(%ebp),%eax
8010412d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104133:	05 80 35 11 80       	add    $0x80113580,%eax
80104138:	8b 40 08             	mov    0x8(%eax),%eax
8010413b:	85 c0                	test   %eax,%eax
8010413d:	7e 41                	jle    80104180 <commit+0x5c>
    write_log(partitionNumber);     // Write modified blocks from cache to log
8010413f:	8b 45 08             	mov    0x8(%ebp),%eax
80104142:	89 04 24             	mov    %eax,(%esp)
80104145:	e8 f5 fe ff ff       	call   8010403f <write_log>
    write_head(partitionNumber);    // Write header to disk -- the real commit
8010414a:	8b 45 08             	mov    0x8(%ebp),%eax
8010414d:	89 04 24             	mov    %eax,(%esp)
80104150:	e8 c9 fb ff ff       	call   80103d1e <write_head>
    install_trans(partitionNumber); // Now install writes to home locations
80104155:	8b 45 08             	mov    0x8(%ebp),%eax
80104158:	89 04 24             	mov    %eax,(%esp)
8010415b:	e8 31 fa ff ff       	call   80103b91 <install_trans>
    logs[partitionNumber].lh.n = 0; 
80104160:	8b 45 08             	mov    0x8(%ebp),%eax
80104163:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104169:	05 80 35 11 80       	add    $0x80113580,%eax
8010416e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	89 04 24             	mov    %eax,(%esp)
8010417b:	e8 9e fb ff ff       	call   80103d1e <write_head>
  }
}
80104180:	c9                   	leave  
80104181:	c3                   	ret    

80104182 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
80104182:	55                   	push   %ebp
80104183:	89 e5                	mov    %esp,%ebp
80104185:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
80104188:	8b 45 0c             	mov    0xc(%ebp),%eax
8010418b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104191:	05 80 35 11 80       	add    $0x80113580,%eax
80104196:	8b 40 08             	mov    0x8(%eax),%eax
80104199:	83 f8 1d             	cmp    $0x1d,%eax
8010419c:	7f 2a                	jg     801041c8 <log_write+0x46>
8010419e:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041a7:	05 80 35 11 80       	add    $0x80113580,%eax
801041ac:	8b 40 08             	mov    0x8(%eax),%eax
801041af:	8b 55 0c             	mov    0xc(%ebp),%edx
801041b2:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
801041b8:	81 c2 70 35 11 80    	add    $0x80113570,%edx
801041be:	8b 52 08             	mov    0x8(%edx),%edx
801041c1:	83 ea 01             	sub    $0x1,%edx
801041c4:	39 d0                	cmp    %edx,%eax
801041c6:	7c 0c                	jl     801041d4 <log_write+0x52>
    panic("too big a transaction");
801041c8:	c7 04 24 db 95 10 80 	movl   $0x801095db,(%esp)
801041cf:	e8 66 c3 ff ff       	call   8010053a <panic>
  if (logs[partitionNumber].outstanding < 1)
801041d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041dd:	05 70 35 11 80       	add    $0x80113570,%eax
801041e2:	8b 40 0c             	mov    0xc(%eax),%eax
801041e5:	85 c0                	test   %eax,%eax
801041e7:	7f 0c                	jg     801041f5 <log_write+0x73>
    panic("log_write outside of trans");
801041e9:	c7 04 24 f1 95 10 80 	movl   $0x801095f1,(%esp)
801041f0:	e8 45 c3 ff ff       	call   8010053a <panic>

  acquire(&logs[partitionNumber].lock);
801041f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801041f8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041fe:	05 40 35 11 80       	add    $0x80113540,%eax
80104203:	89 04 24             	mov    %eax,(%esp)
80104206:	e8 1c 18 00 00       	call   80105a27 <acquire>
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
8010420b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104212:	eb 27                	jmp    8010423b <log_write+0xb9>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
80104214:	8b 45 0c             	mov    0xc(%ebp),%eax
80104217:	6b d0 31             	imul   $0x31,%eax,%edx
8010421a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421d:	01 d0                	add    %edx,%eax
8010421f:	83 c0 10             	add    $0x10,%eax
80104222:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104229:	89 c2                	mov    %eax,%edx
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	8b 40 08             	mov    0x8(%eax),%eax
80104231:	39 c2                	cmp    %eax,%edx
80104233:	75 02                	jne    80104237 <log_write+0xb5>
      break;
80104235:	eb 1a                	jmp    80104251 <log_write+0xcf>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80104237:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010423b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010423e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104244:	05 80 35 11 80       	add    $0x80113580,%eax
80104249:	8b 40 08             	mov    0x8(%eax),%eax
8010424c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010424f:	7f c3                	jg     80104214 <log_write+0x92>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
80104251:	8b 45 08             	mov    0x8(%ebp),%eax
80104254:	8b 40 08             	mov    0x8(%eax),%eax
80104257:	8b 55 0c             	mov    0xc(%ebp),%edx
8010425a:	6b ca 31             	imul   $0x31,%edx,%ecx
8010425d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104260:	01 ca                	add    %ecx,%edx
80104262:	83 c2 10             	add    $0x10,%edx
80104265:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
  if (i == logs[partitionNumber].lh.n)
8010426c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104275:	05 80 35 11 80       	add    $0x80113580,%eax
8010427a:	8b 40 08             	mov    0x8(%eax),%eax
8010427d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104280:	75 25                	jne    801042a7 <log_write+0x125>
    logs[partitionNumber].lh.n++;
80104282:	8b 45 0c             	mov    0xc(%ebp),%eax
80104285:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010428b:	05 80 35 11 80       	add    $0x80113580,%eax
80104290:	8b 40 08             	mov    0x8(%eax),%eax
80104293:	8d 50 01             	lea    0x1(%eax),%edx
80104296:	8b 45 0c             	mov    0xc(%ebp),%eax
80104299:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010429f:	05 80 35 11 80       	add    $0x80113580,%eax
801042a4:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	8b 00                	mov    (%eax),%eax
801042ac:	83 c8 04             	or     $0x4,%eax
801042af:	89 c2                	mov    %eax,%edx
801042b1:	8b 45 08             	mov    0x8(%ebp),%eax
801042b4:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
801042b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801042b9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042bf:	05 40 35 11 80       	add    $0x80113540,%eax
801042c4:	89 04 24             	mov    %eax,(%esp)
801042c7:	e8 bd 17 00 00       	call   80105a89 <release>
}
801042cc:	c9                   	leave  
801042cd:	c3                   	ret    

801042ce <v2p>:
801042ce:	55                   	push   %ebp
801042cf:	89 e5                	mov    %esp,%ebp
801042d1:	8b 45 08             	mov    0x8(%ebp),%eax
801042d4:	05 00 00 00 80       	add    $0x80000000,%eax
801042d9:	5d                   	pop    %ebp
801042da:	c3                   	ret    

801042db <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801042db:	55                   	push   %ebp
801042dc:	89 e5                	mov    %esp,%ebp
801042de:	8b 45 08             	mov    0x8(%ebp),%eax
801042e1:	05 00 00 00 80       	add    $0x80000000,%eax
801042e6:	5d                   	pop    %ebp
801042e7:	c3                   	ret    

801042e8 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801042e8:	55                   	push   %ebp
801042e9:	89 e5                	mov    %esp,%ebp
801042eb:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801042ee:	8b 55 08             	mov    0x8(%ebp),%edx
801042f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801042f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801042f7:	f0 87 02             	lock xchg %eax,(%edx)
801042fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801042fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104300:	c9                   	leave  
80104301:	c3                   	ret    

80104302 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80104302:	55                   	push   %ebp
80104303:	89 e5                	mov    %esp,%ebp
80104305:	83 e4 f0             	and    $0xfffffff0,%esp
80104308:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010430b:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80104312:	80 
80104313:	c7 04 24 5c 66 11 80 	movl   $0x8011665c,(%esp)
8010431a:	e8 75 ef ff ff       	call   80103294 <kinit1>
  kvmalloc();      // kernel page table
8010431f:	e8 9a 47 00 00       	call   80108abe <kvmalloc>
  mpinit();        // collect info about this machine
80104324:	e8 25 04 00 00       	call   8010474e <mpinit>
  lapicinit();
80104329:	e8 d1 f2 ff ff       	call   801035ff <lapicinit>
  seginit();       // set up segments
8010432e:	e8 1e 41 00 00       	call   80108451 <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
80104333:	e8 74 06 00 00       	call   801049ac <picinit>
  ioapicinit();    // another interrupt controller
80104338:	e8 4d ee ff ff       	call   8010318a <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010433d:	e8 6e c7 ff ff       	call   80100ab0 <consoleinit>
  uartinit();      // serial port
80104342:	e8 59 34 00 00       	call   801077a0 <uartinit>
  pinit();         // process table
80104347:	e8 6a 0b 00 00       	call   80104eb6 <pinit>
  tvinit();        // trap vectors
8010434c:	e8 01 30 00 00       	call   80107352 <tvinit>
  binit();         // buffer cache
80104351:	e8 de bc ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80104356:	e8 12 cc ff ff       	call   80100f6d <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
8010435b:	e8 44 ea ff ff       	call   80102da4 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
80104360:	a1 64 38 11 80       	mov    0x80113864,%eax
80104365:	85 c0                	test   %eax,%eax
80104367:	75 05                	jne    8010436e <main+0x6c>
    timerinit();   // uniprocessor timer
80104369:	e8 2f 2f 00 00       	call   8010729d <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
8010436e:	e8 7f 00 00 00       	call   801043f2 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104373:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010437a:	8e 
8010437b:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80104382:	e8 45 ef ff ff       	call   801032cc <kinit2>

  userinit();      // first user process
80104387:	e8 45 0c 00 00       	call   80104fd1 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
8010438c:	e8 1a 00 00 00       	call   801043ab <mpmain>

80104391 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104391:	55                   	push   %ebp
80104392:	89 e5                	mov    %esp,%ebp
80104394:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104397:	e8 39 47 00 00       	call   80108ad5 <switchkvm>
  seginit();
8010439c:	e8 b0 40 00 00       	call   80108451 <seginit>
  lapicinit();
801043a1:	e8 59 f2 ff ff       	call   801035ff <lapicinit>
  mpmain();
801043a6:	e8 00 00 00 00       	call   801043ab <mpmain>

801043ab <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801043ab:	55                   	push   %ebp
801043ac:	89 e5                	mov    %esp,%ebp
801043ae:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801043b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801043b7:	0f b6 00             	movzbl (%eax),%eax
801043ba:	0f b6 c0             	movzbl %al,%eax
801043bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801043c1:	c7 04 24 0c 96 10 80 	movl   $0x8010960c,(%esp)
801043c8:	e8 d3 bf ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801043cd:	e8 f4 30 00 00       	call   801074c6 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801043d2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801043d8:	05 a8 00 00 00       	add    $0xa8,%eax
801043dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801043e4:	00 
801043e5:	89 04 24             	mov    %eax,(%esp)
801043e8:	e8 fb fe ff ff       	call   801042e8 <xchg>
  scheduler();     // start running processes
801043ed:	e8 74 11 00 00       	call   80105566 <scheduler>

801043f2 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801043f2:	55                   	push   %ebp
801043f3:	89 e5                	mov    %esp,%ebp
801043f5:	53                   	push   %ebx
801043f6:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801043f9:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80104400:	e8 d6 fe ff ff       	call   801042db <p2v>
80104405:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80104408:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010440d:	89 44 24 08          	mov    %eax,0x8(%esp)
80104411:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
80104418:	80 
80104419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441c:	89 04 24             	mov    %eax,(%esp)
8010441f:	e8 26 19 00 00       	call   80105d4a <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80104424:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
8010442b:	e9 85 00 00 00       	jmp    801044b5 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80104430:	e8 23 f3 ff ff       	call   80103758 <cpunum>
80104435:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010443b:	05 80 38 11 80       	add    $0x80113880,%eax
80104440:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104443:	75 02                	jne    80104447 <startothers+0x55>
      continue;
80104445:	eb 67                	jmp    801044ae <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104447:	e8 76 ef ff ff       	call   801033c2 <kalloc>
8010444c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010444f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104452:	83 e8 04             	sub    $0x4,%eax
80104455:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104458:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010445e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104460:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104463:	83 e8 08             	sub    $0x8,%eax
80104466:	c7 00 91 43 10 80    	movl   $0x80104391,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010446c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010446f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104472:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80104479:	e8 50 fe ff ff       	call   801042ce <v2p>
8010447e:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104483:	89 04 24             	mov    %eax,(%esp)
80104486:	e8 43 fe ff ff       	call   801042ce <v2p>
8010448b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010448e:	0f b6 12             	movzbl (%edx),%edx
80104491:	0f b6 d2             	movzbl %dl,%edx
80104494:	89 44 24 04          	mov    %eax,0x4(%esp)
80104498:	89 14 24             	mov    %edx,(%esp)
8010449b:	e8 3a f3 ff ff       	call   801037da <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801044a0:	90                   	nop
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801044aa:	85 c0                	test   %eax,%eax
801044ac:	74 f3                	je     801044a1 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801044ae:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801044b5:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801044ba:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801044c0:	05 80 38 11 80       	add    $0x80113880,%eax
801044c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801044c8:	0f 87 62 ff ff ff    	ja     80104430 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801044ce:	83 c4 24             	add    $0x24,%esp
801044d1:	5b                   	pop    %ebx
801044d2:	5d                   	pop    %ebp
801044d3:	c3                   	ret    

801044d4 <p2v>:
801044d4:	55                   	push   %ebp
801044d5:	89 e5                	mov    %esp,%ebp
801044d7:	8b 45 08             	mov    0x8(%ebp),%eax
801044da:	05 00 00 00 80       	add    $0x80000000,%eax
801044df:	5d                   	pop    %ebp
801044e0:	c3                   	ret    

801044e1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801044e1:	55                   	push   %ebp
801044e2:	89 e5                	mov    %esp,%ebp
801044e4:	83 ec 14             	sub    $0x14,%esp
801044e7:	8b 45 08             	mov    0x8(%ebp),%eax
801044ea:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801044ee:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801044f2:	89 c2                	mov    %eax,%edx
801044f4:	ec                   	in     (%dx),%al
801044f5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801044f8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801044fc:	c9                   	leave  
801044fd:	c3                   	ret    

801044fe <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801044fe:	55                   	push   %ebp
801044ff:	89 e5                	mov    %esp,%ebp
80104501:	83 ec 08             	sub    $0x8,%esp
80104504:	8b 55 08             	mov    0x8(%ebp),%edx
80104507:	8b 45 0c             	mov    0xc(%ebp),%eax
8010450a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010450e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104511:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104515:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104519:	ee                   	out    %al,(%dx)
}
8010451a:	c9                   	leave  
8010451b:	c3                   	ret    

8010451c <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010451c:	55                   	push   %ebp
8010451d:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010451f:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104524:	89 c2                	mov    %eax,%edx
80104526:	b8 80 38 11 80       	mov    $0x80113880,%eax
8010452b:	29 c2                	sub    %eax,%edx
8010452d:	89 d0                	mov    %edx,%eax
8010452f:	c1 f8 02             	sar    $0x2,%eax
80104532:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104538:	5d                   	pop    %ebp
80104539:	c3                   	ret    

8010453a <sum>:

static uchar
sum(uchar *addr, int len)
{
8010453a:	55                   	push   %ebp
8010453b:	89 e5                	mov    %esp,%ebp
8010453d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104540:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104547:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010454e:	eb 15                	jmp    80104565 <sum+0x2b>
    sum += addr[i];
80104550:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104553:	8b 45 08             	mov    0x8(%ebp),%eax
80104556:	01 d0                	add    %edx,%eax
80104558:	0f b6 00             	movzbl (%eax),%eax
8010455b:	0f b6 c0             	movzbl %al,%eax
8010455e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104561:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104565:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104568:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010456b:	7c e3                	jl     80104550 <sum+0x16>
    sum += addr[i];
  return sum;
8010456d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104570:	c9                   	leave  
80104571:	c3                   	ret    

80104572 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104572:	55                   	push   %ebp
80104573:	89 e5                	mov    %esp,%ebp
80104575:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104578:	8b 45 08             	mov    0x8(%ebp),%eax
8010457b:	89 04 24             	mov    %eax,(%esp)
8010457e:	e8 51 ff ff ff       	call   801044d4 <p2v>
80104583:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104586:	8b 55 0c             	mov    0xc(%ebp),%edx
80104589:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010458c:	01 d0                	add    %edx,%eax
8010458e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104594:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104597:	eb 3f                	jmp    801045d8 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104599:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801045a0:	00 
801045a1:	c7 44 24 04 20 96 10 	movl   $0x80109620,0x4(%esp)
801045a8:	80 
801045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ac:	89 04 24             	mov    %eax,(%esp)
801045af:	e8 3e 17 00 00       	call   80105cf2 <memcmp>
801045b4:	85 c0                	test   %eax,%eax
801045b6:	75 1c                	jne    801045d4 <mpsearch1+0x62>
801045b8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801045bf:	00 
801045c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c3:	89 04 24             	mov    %eax,(%esp)
801045c6:	e8 6f ff ff ff       	call   8010453a <sum>
801045cb:	84 c0                	test   %al,%al
801045cd:	75 05                	jne    801045d4 <mpsearch1+0x62>
      return (struct mp*)p;
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	eb 11                	jmp    801045e5 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801045d4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801045d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045db:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801045de:	72 b9                	jb     80104599 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801045e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045e5:	c9                   	leave  
801045e6:	c3                   	ret    

801045e7 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801045e7:	55                   	push   %ebp
801045e8:	89 e5                	mov    %esp,%ebp
801045ea:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801045ed:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801045f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f7:	83 c0 0f             	add    $0xf,%eax
801045fa:	0f b6 00             	movzbl (%eax),%eax
801045fd:	0f b6 c0             	movzbl %al,%eax
80104600:	c1 e0 08             	shl    $0x8,%eax
80104603:	89 c2                	mov    %eax,%edx
80104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104608:	83 c0 0e             	add    $0xe,%eax
8010460b:	0f b6 00             	movzbl (%eax),%eax
8010460e:	0f b6 c0             	movzbl %al,%eax
80104611:	09 d0                	or     %edx,%eax
80104613:	c1 e0 04             	shl    $0x4,%eax
80104616:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104619:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010461d:	74 21                	je     80104640 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010461f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80104626:	00 
80104627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010462a:	89 04 24             	mov    %eax,(%esp)
8010462d:	e8 40 ff ff ff       	call   80104572 <mpsearch1>
80104632:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104635:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104639:	74 50                	je     8010468b <mpsearch+0xa4>
      return mp;
8010463b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010463e:	eb 5f                	jmp    8010469f <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104643:	83 c0 14             	add    $0x14,%eax
80104646:	0f b6 00             	movzbl (%eax),%eax
80104649:	0f b6 c0             	movzbl %al,%eax
8010464c:	c1 e0 08             	shl    $0x8,%eax
8010464f:	89 c2                	mov    %eax,%edx
80104651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104654:	83 c0 13             	add    $0x13,%eax
80104657:	0f b6 00             	movzbl (%eax),%eax
8010465a:	0f b6 c0             	movzbl %al,%eax
8010465d:	09 d0                	or     %edx,%eax
8010465f:	c1 e0 0a             	shl    $0xa,%eax
80104662:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104668:	2d 00 04 00 00       	sub    $0x400,%eax
8010466d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80104674:	00 
80104675:	89 04 24             	mov    %eax,(%esp)
80104678:	e8 f5 fe ff ff       	call   80104572 <mpsearch1>
8010467d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104680:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104684:	74 05                	je     8010468b <mpsearch+0xa4>
      return mp;
80104686:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104689:	eb 14                	jmp    8010469f <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
8010468b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80104692:	00 
80104693:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
8010469a:	e8 d3 fe ff ff       	call   80104572 <mpsearch1>
}
8010469f:	c9                   	leave  
801046a0:	c3                   	ret    

801046a1 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801046a1:	55                   	push   %ebp
801046a2:	89 e5                	mov    %esp,%ebp
801046a4:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801046a7:	e8 3b ff ff ff       	call   801045e7 <mpsearch>
801046ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046b3:	74 0a                	je     801046bf <mpconfig+0x1e>
801046b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b8:	8b 40 04             	mov    0x4(%eax),%eax
801046bb:	85 c0                	test   %eax,%eax
801046bd:	75 0a                	jne    801046c9 <mpconfig+0x28>
    return 0;
801046bf:	b8 00 00 00 00       	mov    $0x0,%eax
801046c4:	e9 83 00 00 00       	jmp    8010474c <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801046c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cc:	8b 40 04             	mov    0x4(%eax),%eax
801046cf:	89 04 24             	mov    %eax,(%esp)
801046d2:	e8 fd fd ff ff       	call   801044d4 <p2v>
801046d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801046da:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801046e1:	00 
801046e2:	c7 44 24 04 25 96 10 	movl   $0x80109625,0x4(%esp)
801046e9:	80 
801046ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ed:	89 04 24             	mov    %eax,(%esp)
801046f0:	e8 fd 15 00 00       	call   80105cf2 <memcmp>
801046f5:	85 c0                	test   %eax,%eax
801046f7:	74 07                	je     80104700 <mpconfig+0x5f>
    return 0;
801046f9:	b8 00 00 00 00       	mov    $0x0,%eax
801046fe:	eb 4c                	jmp    8010474c <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80104700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104703:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104707:	3c 01                	cmp    $0x1,%al
80104709:	74 12                	je     8010471d <mpconfig+0x7c>
8010470b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010470e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104712:	3c 04                	cmp    $0x4,%al
80104714:	74 07                	je     8010471d <mpconfig+0x7c>
    return 0;
80104716:	b8 00 00 00 00       	mov    $0x0,%eax
8010471b:	eb 2f                	jmp    8010474c <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
8010471d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104720:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104724:	0f b7 c0             	movzwl %ax,%eax
80104727:	89 44 24 04          	mov    %eax,0x4(%esp)
8010472b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010472e:	89 04 24             	mov    %eax,(%esp)
80104731:	e8 04 fe ff ff       	call   8010453a <sum>
80104736:	84 c0                	test   %al,%al
80104738:	74 07                	je     80104741 <mpconfig+0xa0>
    return 0;
8010473a:	b8 00 00 00 00       	mov    $0x0,%eax
8010473f:	eb 0b                	jmp    8010474c <mpconfig+0xab>
  *pmp = mp;
80104741:	8b 45 08             	mov    0x8(%ebp),%eax
80104744:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104747:	89 10                	mov    %edx,(%eax)
  return conf;
80104749:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010474c:	c9                   	leave  
8010474d:	c3                   	ret    

8010474e <mpinit>:

void
mpinit(void)
{
8010474e:	55                   	push   %ebp
8010474f:	89 e5                	mov    %esp,%ebp
80104751:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104754:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
8010475b:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010475e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104761:	89 04 24             	mov    %eax,(%esp)
80104764:	e8 38 ff ff ff       	call   801046a1 <mpconfig>
80104769:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010476c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104770:	75 05                	jne    80104777 <mpinit+0x29>
    return;
80104772:	e9 9c 01 00 00       	jmp    80104913 <mpinit+0x1c5>
  ismp = 1;
80104777:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
8010477e:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104784:	8b 40 24             	mov    0x24(%eax),%eax
80104787:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010478c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010478f:	83 c0 2c             	add    $0x2c,%eax
80104792:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104798:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010479c:	0f b7 d0             	movzwl %ax,%edx
8010479f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047a2:	01 d0                	add    %edx,%eax
801047a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801047a7:	e9 f4 00 00 00       	jmp    801048a0 <mpinit+0x152>
    switch(*p){
801047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047af:	0f b6 00             	movzbl (%eax),%eax
801047b2:	0f b6 c0             	movzbl %al,%eax
801047b5:	83 f8 04             	cmp    $0x4,%eax
801047b8:	0f 87 bf 00 00 00    	ja     8010487d <mpinit+0x12f>
801047be:	8b 04 85 68 96 10 80 	mov    -0x7fef6998(,%eax,4),%eax
801047c5:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801047c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801047cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047d0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801047d4:	0f b6 d0             	movzbl %al,%edx
801047d7:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801047dc:	39 c2                	cmp    %eax,%edx
801047de:	74 2d                	je     8010480d <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801047e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047e3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801047e7:	0f b6 d0             	movzbl %al,%edx
801047ea:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801047ef:	89 54 24 08          	mov    %edx,0x8(%esp)
801047f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801047f7:	c7 04 24 2a 96 10 80 	movl   $0x8010962a,(%esp)
801047fe:	e8 9d bb ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80104803:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
8010480a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010480d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104810:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104814:	0f b6 c0             	movzbl %al,%eax
80104817:	83 e0 02             	and    $0x2,%eax
8010481a:	85 c0                	test   %eax,%eax
8010481c:	74 15                	je     80104833 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
8010481e:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104823:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104829:	05 80 38 11 80       	add    $0x80113880,%eax
8010482e:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104833:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
80104839:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010483e:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80104844:	81 c2 80 38 11 80    	add    $0x80113880,%edx
8010484a:	88 02                	mov    %al,(%edx)
      ncpu++;
8010484c:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104851:	83 c0 01             	add    $0x1,%eax
80104854:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
80104859:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010485d:	eb 41                	jmp    801048a0 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010485f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104862:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104865:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104868:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010486c:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
80104871:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104875:	eb 29                	jmp    801048a0 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104877:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010487b:	eb 23                	jmp    801048a0 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010487d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104880:	0f b6 00             	movzbl (%eax),%eax
80104883:	0f b6 c0             	movzbl %al,%eax
80104886:	89 44 24 04          	mov    %eax,0x4(%esp)
8010488a:	c7 04 24 48 96 10 80 	movl   $0x80109648,(%esp)
80104891:	e8 0a bb ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80104896:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
8010489d:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801048a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048a6:	0f 82 00 ff ff ff    	jb     801047ac <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801048ac:	a1 64 38 11 80       	mov    0x80113864,%eax
801048b1:	85 c0                	test   %eax,%eax
801048b3:	75 1d                	jne    801048d2 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801048b5:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
801048bc:	00 00 00 
    lapic = 0;
801048bf:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
801048c6:	00 00 00 
    ioapicid = 0;
801048c9:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
801048d0:	eb 41                	jmp    80104913 <mpinit+0x1c5>
  }

  if(mp->imcrp){
801048d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801048d9:	84 c0                	test   %al,%al
801048db:	74 36                	je     80104913 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801048dd:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801048e4:	00 
801048e5:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801048ec:	e8 0d fc ff ff       	call   801044fe <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801048f1:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801048f8:	e8 e4 fb ff ff       	call   801044e1 <inb>
801048fd:	83 c8 01             	or     $0x1,%eax
80104900:	0f b6 c0             	movzbl %al,%eax
80104903:	89 44 24 04          	mov    %eax,0x4(%esp)
80104907:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010490e:	e8 eb fb ff ff       	call   801044fe <outb>
  }
}
80104913:	c9                   	leave  
80104914:	c3                   	ret    

80104915 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104915:	55                   	push   %ebp
80104916:	89 e5                	mov    %esp,%ebp
80104918:	83 ec 08             	sub    $0x8,%esp
8010491b:	8b 55 08             	mov    0x8(%ebp),%edx
8010491e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104921:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104925:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104928:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010492c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104930:	ee                   	out    %al,(%dx)
}
80104931:	c9                   	leave  
80104932:	c3                   	ret    

80104933 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104933:	55                   	push   %ebp
80104934:	89 e5                	mov    %esp,%ebp
80104936:	83 ec 0c             	sub    $0xc,%esp
80104939:	8b 45 08             	mov    0x8(%ebp),%eax
8010493c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104940:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104944:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
8010494a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010494e:	0f b6 c0             	movzbl %al,%eax
80104951:	89 44 24 04          	mov    %eax,0x4(%esp)
80104955:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010495c:	e8 b4 ff ff ff       	call   80104915 <outb>
  outb(IO_PIC2+1, mask >> 8);
80104961:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104965:	66 c1 e8 08          	shr    $0x8,%ax
80104969:	0f b6 c0             	movzbl %al,%eax
8010496c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104970:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104977:	e8 99 ff ff ff       	call   80104915 <outb>
}
8010497c:	c9                   	leave  
8010497d:	c3                   	ret    

8010497e <picenable>:

void
picenable(int irq)
{
8010497e:	55                   	push   %ebp
8010497f:	89 e5                	mov    %esp,%ebp
80104981:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80104984:	8b 45 08             	mov    0x8(%ebp),%eax
80104987:	ba 01 00 00 00       	mov    $0x1,%edx
8010498c:	89 c1                	mov    %eax,%ecx
8010498e:	d3 e2                	shl    %cl,%edx
80104990:	89 d0                	mov    %edx,%eax
80104992:	f7 d0                	not    %eax
80104994:	89 c2                	mov    %eax,%edx
80104996:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010499d:	21 d0                	and    %edx,%eax
8010499f:	0f b7 c0             	movzwl %ax,%eax
801049a2:	89 04 24             	mov    %eax,(%esp)
801049a5:	e8 89 ff ff ff       	call   80104933 <picsetmask>
}
801049aa:	c9                   	leave  
801049ab:	c3                   	ret    

801049ac <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801049ac:	55                   	push   %ebp
801049ad:	89 e5                	mov    %esp,%ebp
801049af:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801049b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801049b9:	00 
801049ba:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801049c1:	e8 4f ff ff ff       	call   80104915 <outb>
  outb(IO_PIC2+1, 0xFF);
801049c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801049cd:	00 
801049ce:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801049d5:	e8 3b ff ff ff       	call   80104915 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801049da:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
801049e1:	00 
801049e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801049e9:	e8 27 ff ff ff       	call   80104915 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801049ee:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801049f5:	00 
801049f6:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801049fd:	e8 13 ff ff ff       	call   80104915 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104a02:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104a09:	00 
80104a0a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104a11:	e8 ff fe ff ff       	call   80104915 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104a16:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104a1d:	00 
80104a1e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104a25:	e8 eb fe ff ff       	call   80104915 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104a2a:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80104a31:	00 
80104a32:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104a39:	e8 d7 fe ff ff       	call   80104915 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104a3e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80104a45:	00 
80104a46:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104a4d:	e8 c3 fe ff ff       	call   80104915 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104a52:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80104a59:	00 
80104a5a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104a61:	e8 af fe ff ff       	call   80104915 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104a66:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104a6d:	00 
80104a6e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104a75:	e8 9b fe ff ff       	call   80104915 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104a7a:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104a81:	00 
80104a82:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104a89:	e8 87 fe ff ff       	call   80104915 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104a8e:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80104a95:	00 
80104a96:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104a9d:	e8 73 fe ff ff       	call   80104915 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104aa2:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104aa9:	00 
80104aaa:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104ab1:	e8 5f fe ff ff       	call   80104915 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104ab6:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80104abd:	00 
80104abe:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104ac5:	e8 4b fe ff ff       	call   80104915 <outb>

  if(irqmask != 0xFFFF)
80104aca:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104ad1:	66 83 f8 ff          	cmp    $0xffff,%ax
80104ad5:	74 12                	je     80104ae9 <picinit+0x13d>
    picsetmask(irqmask);
80104ad7:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104ade:	0f b7 c0             	movzwl %ax,%eax
80104ae1:	89 04 24             	mov    %eax,(%esp)
80104ae4:	e8 4a fe ff ff       	call   80104933 <picsetmask>
}
80104ae9:	c9                   	leave  
80104aea:	c3                   	ret    

80104aeb <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104aeb:	55                   	push   %ebp
80104aec:	89 e5                	mov    %esp,%ebp
80104aee:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104af8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b04:	8b 10                	mov    (%eax),%edx
80104b06:	8b 45 08             	mov    0x8(%ebp),%eax
80104b09:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104b0b:	e8 79 c4 ff ff       	call   80100f89 <filealloc>
80104b10:	8b 55 08             	mov    0x8(%ebp),%edx
80104b13:	89 02                	mov    %eax,(%edx)
80104b15:	8b 45 08             	mov    0x8(%ebp),%eax
80104b18:	8b 00                	mov    (%eax),%eax
80104b1a:	85 c0                	test   %eax,%eax
80104b1c:	0f 84 c8 00 00 00    	je     80104bea <pipealloc+0xff>
80104b22:	e8 62 c4 ff ff       	call   80100f89 <filealloc>
80104b27:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b2a:	89 02                	mov    %eax,(%edx)
80104b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b2f:	8b 00                	mov    (%eax),%eax
80104b31:	85 c0                	test   %eax,%eax
80104b33:	0f 84 b1 00 00 00    	je     80104bea <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104b39:	e8 84 e8 ff ff       	call   801033c2 <kalloc>
80104b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104b41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b45:	75 05                	jne    80104b4c <pipealloc+0x61>
    goto bad;
80104b47:	e9 9e 00 00 00       	jmp    80104bea <pipealloc+0xff>
  p->readopen = 1;
80104b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104b56:	00 00 00 
  p->writeopen = 1;
80104b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104b63:	00 00 00 
  p->nwrite = 0;
80104b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b69:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104b70:	00 00 00 
  p->nread = 0;
80104b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b76:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104b7d:	00 00 00 
  initlock(&p->lock, "pipe");
80104b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b83:	c7 44 24 04 7c 96 10 	movl   $0x8010967c,0x4(%esp)
80104b8a:	80 
80104b8b:	89 04 24             	mov    %eax,(%esp)
80104b8e:	e8 73 0e 00 00       	call   80105a06 <initlock>
  (*f0)->type = FD_PIPE;
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
80104b96:	8b 00                	mov    (%eax),%eax
80104b98:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba1:	8b 00                	mov    (%eax),%eax
80104ba3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80104baa:	8b 00                	mov    (%eax),%eax
80104bac:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb3:	8b 00                	mov    (%eax),%eax
80104bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bb8:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bbe:	8b 00                	mov    (%eax),%eax
80104bc0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc9:	8b 00                	mov    (%eax),%eax
80104bcb:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd2:	8b 00                	mov    (%eax),%eax
80104bd4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bdb:	8b 00                	mov    (%eax),%eax
80104bdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104be0:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104be3:	b8 00 00 00 00       	mov    $0x0,%eax
80104be8:	eb 42                	jmp    80104c2c <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104bea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bee:	74 0b                	je     80104bfb <pipealloc+0x110>
    kfree((char*)p);
80104bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf3:	89 04 24             	mov    %eax,(%esp)
80104bf6:	e8 2e e7 ff ff       	call   80103329 <kfree>
  if(*f0)
80104bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfe:	8b 00                	mov    (%eax),%eax
80104c00:	85 c0                	test   %eax,%eax
80104c02:	74 0d                	je     80104c11 <pipealloc+0x126>
    fileclose(*f0);
80104c04:	8b 45 08             	mov    0x8(%ebp),%eax
80104c07:	8b 00                	mov    (%eax),%eax
80104c09:	89 04 24             	mov    %eax,(%esp)
80104c0c:	e8 20 c4 ff ff       	call   80101031 <fileclose>
  if(*f1)
80104c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c14:	8b 00                	mov    (%eax),%eax
80104c16:	85 c0                	test   %eax,%eax
80104c18:	74 0d                	je     80104c27 <pipealloc+0x13c>
    fileclose(*f1);
80104c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c1d:	8b 00                	mov    (%eax),%eax
80104c1f:	89 04 24             	mov    %eax,(%esp)
80104c22:	e8 0a c4 ff ff       	call   80101031 <fileclose>
  return -1;
80104c27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c2c:	c9                   	leave  
80104c2d:	c3                   	ret    

80104c2e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104c2e:	55                   	push   %ebp
80104c2f:	89 e5                	mov    %esp,%ebp
80104c31:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	89 04 24             	mov    %eax,(%esp)
80104c3a:	e8 e8 0d 00 00       	call   80105a27 <acquire>
  if(writable){
80104c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c43:	74 1f                	je     80104c64 <pipeclose+0x36>
    p->writeopen = 0;
80104c45:	8b 45 08             	mov    0x8(%ebp),%eax
80104c48:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104c4f:	00 00 00 
    wakeup(&p->nread);
80104c52:	8b 45 08             	mov    0x8(%ebp),%eax
80104c55:	05 34 02 00 00       	add    $0x234,%eax
80104c5a:	89 04 24             	mov    %eax,(%esp)
80104c5d:	e8 d4 0b 00 00       	call   80105836 <wakeup>
80104c62:	eb 1d                	jmp    80104c81 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104c64:	8b 45 08             	mov    0x8(%ebp),%eax
80104c67:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104c6e:	00 00 00 
    wakeup(&p->nwrite);
80104c71:	8b 45 08             	mov    0x8(%ebp),%eax
80104c74:	05 38 02 00 00       	add    $0x238,%eax
80104c79:	89 04 24             	mov    %eax,(%esp)
80104c7c:	e8 b5 0b 00 00       	call   80105836 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104c81:	8b 45 08             	mov    0x8(%ebp),%eax
80104c84:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104c8a:	85 c0                	test   %eax,%eax
80104c8c:	75 25                	jne    80104cb3 <pipeclose+0x85>
80104c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c91:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104c97:	85 c0                	test   %eax,%eax
80104c99:	75 18                	jne    80104cb3 <pipeclose+0x85>
    release(&p->lock);
80104c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9e:	89 04 24             	mov    %eax,(%esp)
80104ca1:	e8 e3 0d 00 00       	call   80105a89 <release>
    kfree((char*)p);
80104ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca9:	89 04 24             	mov    %eax,(%esp)
80104cac:	e8 78 e6 ff ff       	call   80103329 <kfree>
80104cb1:	eb 0b                	jmp    80104cbe <pipeclose+0x90>
  } else
    release(&p->lock);
80104cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb6:	89 04 24             	mov    %eax,(%esp)
80104cb9:	e8 cb 0d 00 00       	call   80105a89 <release>
}
80104cbe:	c9                   	leave  
80104cbf:	c3                   	ret    

80104cc0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104cc0:	55                   	push   %ebp
80104cc1:	89 e5                	mov    %esp,%ebp
80104cc3:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc9:	89 04 24             	mov    %eax,(%esp)
80104ccc:	e8 56 0d 00 00       	call   80105a27 <acquire>
  for(i = 0; i < n; i++){
80104cd1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cd8:	e9 a6 00 00 00       	jmp    80104d83 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104cdd:	eb 57                	jmp    80104d36 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104ce8:	85 c0                	test   %eax,%eax
80104cea:	74 0d                	je     80104cf9 <pipewrite+0x39>
80104cec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf2:	8b 40 24             	mov    0x24(%eax),%eax
80104cf5:	85 c0                	test   %eax,%eax
80104cf7:	74 15                	je     80104d0e <pipewrite+0x4e>
        release(&p->lock);
80104cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfc:	89 04 24             	mov    %eax,(%esp)
80104cff:	e8 85 0d 00 00       	call   80105a89 <release>
        return -1;
80104d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d09:	e9 9f 00 00 00       	jmp    80104dad <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d11:	05 34 02 00 00       	add    $0x234,%eax
80104d16:	89 04 24             	mov    %eax,(%esp)
80104d19:	e8 18 0b 00 00       	call   80105836 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d21:	8b 55 08             	mov    0x8(%ebp),%edx
80104d24:	81 c2 38 02 00 00    	add    $0x238,%edx
80104d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d2e:	89 14 24             	mov    %edx,(%esp)
80104d31:	e8 27 0a 00 00       	call   8010575d <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104d36:	8b 45 08             	mov    0x8(%ebp),%eax
80104d39:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d42:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104d48:	05 00 02 00 00       	add    $0x200,%eax
80104d4d:	39 c2                	cmp    %eax,%edx
80104d4f:	74 8e                	je     80104cdf <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104d51:	8b 45 08             	mov    0x8(%ebp),%eax
80104d54:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104d5a:	8d 48 01             	lea    0x1(%eax),%ecx
80104d5d:	8b 55 08             	mov    0x8(%ebp),%edx
80104d60:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104d66:	25 ff 01 00 00       	and    $0x1ff,%eax
80104d6b:	89 c1                	mov    %eax,%ecx
80104d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d70:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d73:	01 d0                	add    %edx,%eax
80104d75:	0f b6 10             	movzbl (%eax),%edx
80104d78:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7b:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104d7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d86:	3b 45 10             	cmp    0x10(%ebp),%eax
80104d89:	0f 8c 4e ff ff ff    	jl     80104cdd <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d92:	05 34 02 00 00       	add    $0x234,%eax
80104d97:	89 04 24             	mov    %eax,(%esp)
80104d9a:	e8 97 0a 00 00       	call   80105836 <wakeup>
  release(&p->lock);
80104d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104da2:	89 04 24             	mov    %eax,(%esp)
80104da5:	e8 df 0c 00 00       	call   80105a89 <release>
  return n;
80104daa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104dad:	c9                   	leave  
80104dae:	c3                   	ret    

80104daf <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104daf:	55                   	push   %ebp
80104db0:	89 e5                	mov    %esp,%ebp
80104db2:	53                   	push   %ebx
80104db3:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104db6:	8b 45 08             	mov    0x8(%ebp),%eax
80104db9:	89 04 24             	mov    %eax,(%esp)
80104dbc:	e8 66 0c 00 00       	call   80105a27 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104dc1:	eb 3a                	jmp    80104dfd <piperead+0x4e>
    if(proc->killed){
80104dc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc9:	8b 40 24             	mov    0x24(%eax),%eax
80104dcc:	85 c0                	test   %eax,%eax
80104dce:	74 15                	je     80104de5 <piperead+0x36>
      release(&p->lock);
80104dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd3:	89 04 24             	mov    %eax,(%esp)
80104dd6:	e8 ae 0c 00 00       	call   80105a89 <release>
      return -1;
80104ddb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de0:	e9 b5 00 00 00       	jmp    80104e9a <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104de5:	8b 45 08             	mov    0x8(%ebp),%eax
80104de8:	8b 55 08             	mov    0x8(%ebp),%edx
80104deb:	81 c2 34 02 00 00    	add    $0x234,%edx
80104df1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104df5:	89 14 24             	mov    %edx,(%esp)
80104df8:	e8 60 09 00 00       	call   8010575d <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104e00:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104e06:	8b 45 08             	mov    0x8(%ebp),%eax
80104e09:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e0f:	39 c2                	cmp    %eax,%edx
80104e11:	75 0d                	jne    80104e20 <piperead+0x71>
80104e13:	8b 45 08             	mov    0x8(%ebp),%eax
80104e16:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104e1c:	85 c0                	test   %eax,%eax
80104e1e:	75 a3                	jne    80104dc3 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104e20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e27:	eb 4b                	jmp    80104e74 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104e29:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104e32:	8b 45 08             	mov    0x8(%ebp),%eax
80104e35:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e3b:	39 c2                	cmp    %eax,%edx
80104e3d:	75 02                	jne    80104e41 <piperead+0x92>
      break;
80104e3f:	eb 3b                	jmp    80104e7c <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104e41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e44:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e47:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104e53:	8d 48 01             	lea    0x1(%eax),%ecx
80104e56:	8b 55 08             	mov    0x8(%ebp),%edx
80104e59:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104e5f:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e64:	89 c2                	mov    %eax,%edx
80104e66:	8b 45 08             	mov    0x8(%ebp),%eax
80104e69:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104e6e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104e70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e77:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e7a:	7c ad                	jl     80104e29 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7f:	05 38 02 00 00       	add    $0x238,%eax
80104e84:	89 04 24             	mov    %eax,(%esp)
80104e87:	e8 aa 09 00 00       	call   80105836 <wakeup>
  release(&p->lock);
80104e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8f:	89 04 24             	mov    %eax,(%esp)
80104e92:	e8 f2 0b 00 00       	call   80105a89 <release>
  return i;
80104e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104e9a:	83 c4 24             	add    $0x24,%esp
80104e9d:	5b                   	pop    %ebx
80104e9e:	5d                   	pop    %ebp
80104e9f:	c3                   	ret    

80104ea0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ea6:	9c                   	pushf  
80104ea7:	58                   	pop    %eax
80104ea8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104eab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104eae:	c9                   	leave  
80104eaf:	c3                   	ret    

80104eb0 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104eb0:	55                   	push   %ebp
80104eb1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104eb3:	fb                   	sti    
}
80104eb4:	5d                   	pop    %ebp
80104eb5:	c3                   	ret    

80104eb6 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104eb6:	55                   	push   %ebp
80104eb7:	89 e5                	mov    %esp,%ebp
80104eb9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104ebc:	c7 44 24 04 81 96 10 	movl   $0x80109681,0x4(%esp)
80104ec3:	80 
80104ec4:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104ecb:	e8 36 0b 00 00       	call   80105a06 <initlock>
}
80104ed0:	c9                   	leave  
80104ed1:	c3                   	ret    

80104ed2 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104ed2:	55                   	push   %ebp
80104ed3:	89 e5                	mov    %esp,%ebp
80104ed5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104ed8:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104edf:	e8 43 0b 00 00       	call   80105a27 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ee4:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104eeb:	eb 50                	jmp    80104f3d <allocproc+0x6b>
    if(p->state == UNUSED)
80104eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef3:	85 c0                	test   %eax,%eax
80104ef5:	75 42                	jne    80104f39 <allocproc+0x67>
      goto found;
80104ef7:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104f02:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104f07:	8d 50 01             	lea    0x1(%eax),%edx
80104f0a:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104f10:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f13:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104f16:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104f1d:	e8 67 0b 00 00       	call   80105a89 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104f22:	e8 9b e4 ff ff       	call   801033c2 <kalloc>
80104f27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f2a:	89 42 08             	mov    %eax,0x8(%edx)
80104f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f30:	8b 40 08             	mov    0x8(%eax),%eax
80104f33:	85 c0                	test   %eax,%eax
80104f35:	75 33                	jne    80104f6a <allocproc+0x98>
80104f37:	eb 20                	jmp    80104f59 <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f39:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f3d:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104f44:	72 a7                	jb     80104eed <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104f46:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104f4d:	e8 37 0b 00 00       	call   80105a89 <release>
  return 0;
80104f52:	b8 00 00 00 00       	mov    $0x0,%eax
80104f57:	eb 76                	jmp    80104fcf <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104f63:	b8 00 00 00 00       	mov    $0x0,%eax
80104f68:	eb 65                	jmp    80104fcf <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6d:	8b 40 08             	mov    0x8(%eax),%eax
80104f70:	05 00 10 00 00       	add    $0x1000,%eax
80104f75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104f78:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f82:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104f85:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104f89:	ba 0d 73 10 80       	mov    $0x8010730d,%edx
80104f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f91:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104f93:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f9d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa3:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fa6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104fad:	00 
80104fae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104fb5:	00 
80104fb6:	89 04 24             	mov    %eax,(%esp)
80104fb9:	e8 bd 0c 00 00       	call   80105c7b <memset>
  p->context->eip = (uint)forkret;
80104fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc1:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fc4:	ba e2 56 10 80       	mov    $0x801056e2,%edx
80104fc9:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fcf:	c9                   	leave  
80104fd0:	c3                   	ret    

80104fd1 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104fd1:	55                   	push   %ebp
80104fd2:	89 e5                	mov    %esp,%ebp
80104fd4:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104fd7:	e8 f6 fe ff ff       	call   80104ed2 <allocproc>
80104fdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe2:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80104fe7:	e8 15 3a 00 00       	call   80108a01 <setupkvm>
80104fec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fef:	89 42 04             	mov    %eax,0x4(%edx)
80104ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff5:	8b 40 04             	mov    0x4(%eax),%eax
80104ff8:	85 c0                	test   %eax,%eax
80104ffa:	75 0c                	jne    80105008 <userinit+0x37>
    panic("userinit: out of memory?");
80104ffc:	c7 04 24 88 96 10 80 	movl   $0x80109688,(%esp)
80105003:	e8 32 b5 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80105008:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010500d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105010:	8b 40 04             	mov    0x4(%eax),%eax
80105013:	89 54 24 08          	mov    %edx,0x8(%esp)
80105017:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
8010501e:	80 
8010501f:	89 04 24             	mov    %eax,(%esp)
80105022:	e8 32 3c 00 00       	call   80108c59 <inituvm>
  p->sz = PGSIZE;
80105027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80105030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105033:	8b 40 18             	mov    0x18(%eax),%eax
80105036:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010503d:	00 
8010503e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105045:	00 
80105046:	89 04 24             	mov    %eax,(%esp)
80105049:	e8 2d 0c 00 00       	call   80105c7b <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010504e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105051:	8b 40 18             	mov    0x18(%eax),%eax
80105054:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010505a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505d:	8b 40 18             	mov    0x18(%eax),%eax
80105060:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80105066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105069:	8b 40 18             	mov    0x18(%eax),%eax
8010506c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010506f:	8b 52 18             	mov    0x18(%edx),%edx
80105072:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105076:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010507a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507d:	8b 40 18             	mov    0x18(%eax),%eax
80105080:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105083:	8b 52 18             	mov    0x18(%edx),%edx
80105086:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010508a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010508e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105091:	8b 40 18             	mov    0x18(%eax),%eax
80105094:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010509b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509e:	8b 40 18             	mov    0x18(%eax),%eax
801050a1:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801050a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ab:	8b 40 18             	mov    0x18(%eax),%eax
801050ae:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b8:	83 c0 6c             	add    $0x6c,%eax
801050bb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801050c2:	00 
801050c3:	c7 44 24 04 a1 96 10 	movl   $0x801096a1,0x4(%esp)
801050ca:	80 
801050cb:	89 04 24             	mov    %eax,(%esp)
801050ce:	e8 c8 0d 00 00       	call   80105e9b <safestrcpy>
  p->cwd = namei("/");
801050d3:	c7 04 24 aa 96 10 80 	movl   $0x801096aa,(%esp)
801050da:	e8 7e db ff ff       	call   80102c5d <namei>
801050df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050e2:	89 42 68             	mov    %eax,0x68(%edx)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
801050e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801050ef:	c9                   	leave  
801050f0:	c3                   	ret    

801050f1 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801050f1:	55                   	push   %ebp
801050f2:	89 e5                	mov    %esp,%ebp
801050f4:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801050f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050fd:	8b 00                	mov    (%eax),%eax
801050ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80105102:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105106:	7e 34                	jle    8010513c <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80105108:	8b 55 08             	mov    0x8(%ebp),%edx
8010510b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510e:	01 c2                	add    %eax,%edx
80105110:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105116:	8b 40 04             	mov    0x4(%eax),%eax
80105119:	89 54 24 08          	mov    %edx,0x8(%esp)
8010511d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105120:	89 54 24 04          	mov    %edx,0x4(%esp)
80105124:	89 04 24             	mov    %eax,(%esp)
80105127:	e8 a3 3c 00 00       	call   80108dcf <allocuvm>
8010512c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010512f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105133:	75 41                	jne    80105176 <growproc+0x85>
      return -1;
80105135:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513a:	eb 58                	jmp    80105194 <growproc+0xa3>
  } else if(n < 0){
8010513c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105140:	79 34                	jns    80105176 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80105142:	8b 55 08             	mov    0x8(%ebp),%edx
80105145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105148:	01 c2                	add    %eax,%edx
8010514a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105150:	8b 40 04             	mov    0x4(%eax),%eax
80105153:	89 54 24 08          	mov    %edx,0x8(%esp)
80105157:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010515a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010515e:	89 04 24             	mov    %eax,(%esp)
80105161:	e8 43 3d 00 00       	call   80108ea9 <deallocuvm>
80105166:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010516d:	75 07                	jne    80105176 <growproc+0x85>
      return -1;
8010516f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105174:	eb 1e                	jmp    80105194 <growproc+0xa3>
  }
  proc->sz = sz;
80105176:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010517c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010517f:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80105181:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105187:	89 04 24             	mov    %eax,(%esp)
8010518a:	e8 63 39 00 00       	call   80108af2 <switchuvm>
  return 0;
8010518f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105194:	c9                   	leave  
80105195:	c3                   	ret    

80105196 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80105196:	55                   	push   %ebp
80105197:	89 e5                	mov    %esp,%ebp
80105199:	57                   	push   %edi
8010519a:	56                   	push   %esi
8010519b:	53                   	push   %ebx
8010519c:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010519f:	e8 2e fd ff ff       	call   80104ed2 <allocproc>
801051a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801051a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801051ab:	75 0a                	jne    801051b7 <fork+0x21>
    return -1;
801051ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051b2:	e9 52 01 00 00       	jmp    80105309 <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801051b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051bd:	8b 10                	mov    (%eax),%edx
801051bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c5:	8b 40 04             	mov    0x4(%eax),%eax
801051c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801051cc:	89 04 24             	mov    %eax,(%esp)
801051cf:	e8 71 3e 00 00       	call   80109045 <copyuvm>
801051d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801051d7:	89 42 04             	mov    %eax,0x4(%edx)
801051da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051dd:	8b 40 04             	mov    0x4(%eax),%eax
801051e0:	85 c0                	test   %eax,%eax
801051e2:	75 2c                	jne    80105210 <fork+0x7a>
    kfree(np->kstack);
801051e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051e7:	8b 40 08             	mov    0x8(%eax),%eax
801051ea:	89 04 24             	mov    %eax,(%esp)
801051ed:	e8 37 e1 ff ff       	call   80103329 <kfree>
    np->kstack = 0;
801051f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801051fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051ff:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80105206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520b:	e9 f9 00 00 00       	jmp    80105309 <fork+0x173>
  }
  np->sz = proc->sz;
80105210:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105216:	8b 10                	mov    (%eax),%edx
80105218:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010521b:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010521d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105224:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105227:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010522a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010522d:	8b 50 18             	mov    0x18(%eax),%edx
80105230:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105236:	8b 40 18             	mov    0x18(%eax),%eax
80105239:	89 c3                	mov    %eax,%ebx
8010523b:	b8 13 00 00 00       	mov    $0x13,%eax
80105240:	89 d7                	mov    %edx,%edi
80105242:	89 de                	mov    %ebx,%esi
80105244:	89 c1                	mov    %eax,%ecx
80105246:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105248:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010524b:	8b 40 18             	mov    0x18(%eax),%eax
8010524e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105255:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010525c:	eb 3d                	jmp    8010529b <fork+0x105>
    if(proc->ofile[i])
8010525e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105264:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105267:	83 c2 08             	add    $0x8,%edx
8010526a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010526e:	85 c0                	test   %eax,%eax
80105270:	74 25                	je     80105297 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80105272:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105278:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010527b:	83 c2 08             	add    $0x8,%edx
8010527e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105282:	89 04 24             	mov    %eax,(%esp)
80105285:	e8 5f bd ff ff       	call   80100fe9 <filedup>
8010528a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010528d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105290:	83 c1 08             	add    $0x8,%ecx
80105293:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105297:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010529b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010529f:	7e bd                	jle    8010525e <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801052a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052a7:	8b 40 68             	mov    0x68(%eax),%eax
801052aa:	89 04 24             	mov    %eax,(%esp)
801052ad:	e8 52 cb ff ff       	call   80101e04 <idup>
801052b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801052b5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801052b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052be:	8d 50 6c             	lea    0x6c(%eax),%edx
801052c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052c4:	83 c0 6c             	add    $0x6c,%eax
801052c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801052ce:	00 
801052cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801052d3:	89 04 24             	mov    %eax,(%esp)
801052d6:	e8 c0 0b 00 00       	call   80105e9b <safestrcpy>
 
  pid = np->pid;
801052db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052de:	8b 40 10             	mov    0x10(%eax),%eax
801052e1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801052e4:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801052eb:	e8 37 07 00 00       	call   80105a27 <acquire>
  np->state = RUNNABLE;
801052f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052f3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801052fa:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80105301:	e8 83 07 00 00       	call   80105a89 <release>
  
  return pid;
80105306:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105309:	83 c4 2c             	add    $0x2c,%esp
8010530c:	5b                   	pop    %ebx
8010530d:	5e                   	pop    %esi
8010530e:	5f                   	pop    %edi
8010530f:	5d                   	pop    %ebp
80105310:	c3                   	ret    

80105311 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105311:	55                   	push   %ebp
80105312:	89 e5                	mov    %esp,%ebp
80105314:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105317:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010531e:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105323:	39 c2                	cmp    %eax,%edx
80105325:	75 0c                	jne    80105333 <exit+0x22>
    panic("init exiting");
80105327:	c7 04 24 ac 96 10 80 	movl   $0x801096ac,(%esp)
8010532e:	e8 07 b2 ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105333:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010533a:	eb 44                	jmp    80105380 <exit+0x6f>
    if(proc->ofile[fd]){
8010533c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105342:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105345:	83 c2 08             	add    $0x8,%edx
80105348:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010534c:	85 c0                	test   %eax,%eax
8010534e:	74 2c                	je     8010537c <exit+0x6b>
      fileclose(proc->ofile[fd]);
80105350:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105356:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105359:	83 c2 08             	add    $0x8,%edx
8010535c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105360:	89 04 24             	mov    %eax,(%esp)
80105363:	e8 c9 bc ff ff       	call   80101031 <fileclose>
      proc->ofile[fd] = 0;
80105368:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010536e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105371:	83 c2 08             	add    $0x8,%edx
80105374:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010537b:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010537c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105380:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105384:	7e b6                	jle    8010533c <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
80105386:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538c:	8b 40 68             	mov    0x68(%eax),%eax
8010538f:	8b 40 50             	mov    0x50(%eax),%eax
80105392:	8b 40 14             	mov    0x14(%eax),%eax
80105395:	89 04 24             	mov    %eax,(%esp)
80105398:	e8 71 ea ff ff       	call   80103e0e <begin_op>
  iput(proc->cwd);
8010539d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a3:	8b 40 68             	mov    0x68(%eax),%eax
801053a6:	89 04 24             	mov    %eax,(%esp)
801053a9:	e8 84 cc ff ff       	call   80102032 <iput>
  end_op(proc->cwd->part->number);
801053ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b4:	8b 40 68             	mov    0x68(%eax),%eax
801053b7:	8b 40 50             	mov    0x50(%eax),%eax
801053ba:	8b 40 14             	mov    0x14(%eax),%eax
801053bd:	89 04 24             	mov    %eax,(%esp)
801053c0:	e8 4b eb ff ff       	call   80103f10 <end_op>
  proc->cwd = 0;
801053c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053cb:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801053d2:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801053d9:	e8 49 06 00 00       	call   80105a27 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801053de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053e4:	8b 40 14             	mov    0x14(%eax),%eax
801053e7:	89 04 24             	mov    %eax,(%esp)
801053ea:	e8 09 04 00 00       	call   801057f8 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053ef:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801053f6:	eb 38                	jmp    80105430 <exit+0x11f>
    if(p->parent == proc){
801053f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053fb:	8b 50 14             	mov    0x14(%eax),%edx
801053fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105404:	39 c2                	cmp    %eax,%edx
80105406:	75 24                	jne    8010542c <exit+0x11b>
      p->parent = initproc;
80105408:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
8010540e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105411:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105417:	8b 40 0c             	mov    0xc(%eax),%eax
8010541a:	83 f8 05             	cmp    $0x5,%eax
8010541d:	75 0d                	jne    8010542c <exit+0x11b>
        wakeup1(initproc);
8010541f:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105424:	89 04 24             	mov    %eax,(%esp)
80105427:	e8 cc 03 00 00       	call   801057f8 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010542c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105430:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105437:	72 bf                	jb     801053f8 <exit+0xe7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105439:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105446:	e8 b3 01 00 00       	call   801055fe <sched>
  panic("zombie exit");
8010544b:	c7 04 24 b9 96 10 80 	movl   $0x801096b9,(%esp)
80105452:	e8 e3 b0 ff ff       	call   8010053a <panic>

80105457 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105457:	55                   	push   %ebp
80105458:	89 e5                	mov    %esp,%ebp
8010545a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010545d:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80105464:	e8 be 05 00 00       	call   80105a27 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105469:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105470:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105477:	e9 9a 00 00 00       	jmp    80105516 <wait+0xbf>
      if(p->parent != proc)
8010547c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010547f:	8b 50 14             	mov    0x14(%eax),%edx
80105482:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105488:	39 c2                	cmp    %eax,%edx
8010548a:	74 05                	je     80105491 <wait+0x3a>
        continue;
8010548c:	e9 81 00 00 00       	jmp    80105512 <wait+0xbb>
      havekids = 1;
80105491:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010549b:	8b 40 0c             	mov    0xc(%eax),%eax
8010549e:	83 f8 05             	cmp    $0x5,%eax
801054a1:	75 6f                	jne    80105512 <wait+0xbb>
        // Found one.
        pid = p->pid;
801054a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a6:	8b 40 10             	mov    0x10(%eax),%eax
801054a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801054ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054af:	8b 40 08             	mov    0x8(%eax),%eax
801054b2:	89 04 24             	mov    %eax,(%esp)
801054b5:	e8 6f de ff ff       	call   80103329 <kfree>
        p->kstack = 0;
801054ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054bd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801054c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c7:	8b 40 04             	mov    0x4(%eax),%eax
801054ca:	89 04 24             	mov    %eax,(%esp)
801054cd:	e8 93 3a 00 00       	call   80108f65 <freevm>
        p->state = UNUSED;
801054d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801054dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054df:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801054e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801054f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f3:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801054f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054fa:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105501:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80105508:	e8 7c 05 00 00       	call   80105a89 <release>
        return pid;
8010550d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105510:	eb 52                	jmp    80105564 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105512:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105516:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010551d:	0f 82 59 ff ff ff    	jb     8010547c <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105523:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105527:	74 0d                	je     80105536 <wait+0xdf>
80105529:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552f:	8b 40 24             	mov    0x24(%eax),%eax
80105532:	85 c0                	test   %eax,%eax
80105534:	74 13                	je     80105549 <wait+0xf2>
      release(&ptable.lock);
80105536:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
8010553d:	e8 47 05 00 00       	call   80105a89 <release>
      return -1;
80105542:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105547:	eb 1b                	jmp    80105564 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105549:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010554f:	c7 44 24 04 80 3e 11 	movl   $0x80113e80,0x4(%esp)
80105556:	80 
80105557:	89 04 24             	mov    %eax,(%esp)
8010555a:	e8 fe 01 00 00       	call   8010575d <sleep>
  }
8010555f:	e9 05 ff ff ff       	jmp    80105469 <wait+0x12>
}
80105564:	c9                   	leave  
80105565:	c3                   	ret    

80105566 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105566:	55                   	push   %ebp
80105567:	89 e5                	mov    %esp,%ebp
80105569:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010556c:	e8 3f f9 ff ff       	call   80104eb0 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105571:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80105578:	e8 aa 04 00 00       	call   80105a27 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010557d:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105584:	eb 5e                	jmp    801055e4 <scheduler+0x7e>
      if(p->state != RUNNABLE)
80105586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105589:	8b 40 0c             	mov    0xc(%eax),%eax
8010558c:	83 f8 03             	cmp    $0x3,%eax
8010558f:	74 02                	je     80105593 <scheduler+0x2d>
        continue;
80105591:	eb 4d                	jmp    801055e0 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105596:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010559c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559f:	89 04 24             	mov    %eax,(%esp)
801055a2:	e8 4b 35 00 00       	call   80108af2 <switchuvm>
      p->state = RUNNING;
801055a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055aa:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801055b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b7:	8b 40 1c             	mov    0x1c(%eax),%eax
801055ba:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801055c1:	83 c2 04             	add    $0x4,%edx
801055c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801055c8:	89 14 24             	mov    %edx,(%esp)
801055cb:	e8 3c 09 00 00       	call   80105f0c <swtch>
      switchkvm();
801055d0:	e8 00 35 00 00       	call   80108ad5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801055d5:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801055dc:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055e0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801055e4:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801055eb:	72 99                	jb     80105586 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801055ed:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801055f4:	e8 90 04 00 00       	call   80105a89 <release>

  }
801055f9:	e9 6e ff ff ff       	jmp    8010556c <scheduler+0x6>

801055fe <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801055fe:	55                   	push   %ebp
801055ff:	89 e5                	mov    %esp,%ebp
80105601:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80105604:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
8010560b:	e8 41 05 00 00       	call   80105b51 <holding>
80105610:	85 c0                	test   %eax,%eax
80105612:	75 0c                	jne    80105620 <sched+0x22>
    panic("sched ptable.lock");
80105614:	c7 04 24 c5 96 10 80 	movl   $0x801096c5,(%esp)
8010561b:	e8 1a af ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80105620:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105626:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010562c:	83 f8 01             	cmp    $0x1,%eax
8010562f:	74 0c                	je     8010563d <sched+0x3f>
   panic("sched locks");
80105631:	c7 04 24 d7 96 10 80 	movl   $0x801096d7,(%esp)
80105638:	e8 fd ae ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
8010563d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105643:	8b 40 0c             	mov    0xc(%eax),%eax
80105646:	83 f8 04             	cmp    $0x4,%eax
80105649:	75 0c                	jne    80105657 <sched+0x59>
    panic("sched running");
8010564b:	c7 04 24 e3 96 10 80 	movl   $0x801096e3,(%esp)
80105652:	e8 e3 ae ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80105657:	e8 44 f8 ff ff       	call   80104ea0 <readeflags>
8010565c:	25 00 02 00 00       	and    $0x200,%eax
80105661:	85 c0                	test   %eax,%eax
80105663:	74 0c                	je     80105671 <sched+0x73>
    panic("sched interruptible");
80105665:	c7 04 24 f1 96 10 80 	movl   $0x801096f1,(%esp)
8010566c:	e8 c9 ae ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80105671:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105677:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010567d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105680:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105686:	8b 40 04             	mov    0x4(%eax),%eax
80105689:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105690:	83 c2 1c             	add    $0x1c,%edx
80105693:	89 44 24 04          	mov    %eax,0x4(%esp)
80105697:	89 14 24             	mov    %edx,(%esp)
8010569a:	e8 6d 08 00 00       	call   80105f0c <swtch>
  cpu->intena = intena;
8010569f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056a8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801056ae:	c9                   	leave  
801056af:	c3                   	ret    

801056b0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801056b0:	55                   	push   %ebp
801056b1:	89 e5                	mov    %esp,%ebp
801056b3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801056b6:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801056bd:	e8 65 03 00 00       	call   80105a27 <acquire>
  proc->state = RUNNABLE;
801056c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801056cf:	e8 2a ff ff ff       	call   801055fe <sched>
  release(&ptable.lock);
801056d4:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801056db:	e8 a9 03 00 00       	call   80105a89 <release>
}
801056e0:	c9                   	leave  
801056e1:	c3                   	ret    

801056e2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801056e2:	55                   	push   %ebp
801056e3:	89 e5                	mov    %esp,%ebp
801056e5:	83 ec 28             	sub    $0x28,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801056e8:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801056ef:	e8 95 03 00 00       	call   80105a89 <release>


  if (first) {
801056f4:	a1 08 c0 10 80       	mov    0x8010c008,%eax
801056f9:	85 c0                	test   %eax,%eax
801056fb:	74 5e                	je     8010575b <forkret+0x79>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801056fd:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105704:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
80105707:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010570d:	0f b6 00             	movzbl (%eax),%eax
80105710:	0f b6 c0             	movzbl %al,%eax
80105713:	89 44 24 04          	mov    %eax,0x4(%esp)
80105717:	c7 04 24 05 97 10 80 	movl   $0x80109705,(%esp)
8010571e:	e8 7d ac ff ff       	call   801003a0 <cprintf>
    int bootfrom=iinit(proc,ROOTDEV);
80105723:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105729:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105730:	00 
80105731:	89 04 24             	mov    %eax,(%esp)
80105734:	e8 54 c2 ff ff       	call   8010198d <iinit>
80105739:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // iinitDone=1;
    cprintf("boot from after iinit is %d \n",bootfrom);
8010573c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105743:	c7 04 24 14 97 10 80 	movl   $0x80109714,(%esp)
8010574a:	e8 51 ac ff ff       	call   801003a0 <cprintf>
    initlog(ROOTDEV);
8010574f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105756:	e8 87 e3 ff ff       	call   80103ae2 <initlog>
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
8010575b:	c9                   	leave  
8010575c:	c3                   	ret    

8010575d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010575d:	55                   	push   %ebp
8010575e:	89 e5                	mov    %esp,%ebp
80105760:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80105763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105769:	85 c0                	test   %eax,%eax
8010576b:	75 0c                	jne    80105779 <sleep+0x1c>
    panic("sleep");
8010576d:	c7 04 24 32 97 10 80 	movl   $0x80109732,(%esp)
80105774:	e8 c1 ad ff ff       	call   8010053a <panic>

  if(lk == 0)
80105779:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010577d:	75 0c                	jne    8010578b <sleep+0x2e>
    panic("sleep without lk");
8010577f:	c7 04 24 38 97 10 80 	movl   $0x80109738,(%esp)
80105786:	e8 af ad ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010578b:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
80105792:	74 17                	je     801057ab <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105794:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
8010579b:	e8 87 02 00 00       	call   80105a27 <acquire>
    release(lk);
801057a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a3:	89 04 24             	mov    %eax,(%esp)
801057a6:	e8 de 02 00 00       	call   80105a89 <release>
  }

  // Go to sleep.
  proc->chan = chan;
801057ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b1:	8b 55 08             	mov    0x8(%ebp),%edx
801057b4:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801057b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057bd:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801057c4:	e8 35 fe ff ff       	call   801055fe <sched>

  // Tidy up.
  proc->chan = 0;
801057c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057cf:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801057d6:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801057dd:	74 17                	je     801057f6 <sleep+0x99>
    release(&ptable.lock);
801057df:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801057e6:	e8 9e 02 00 00       	call   80105a89 <release>
    acquire(lk);
801057eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ee:	89 04 24             	mov    %eax,(%esp)
801057f1:	e8 31 02 00 00       	call   80105a27 <acquire>
  }
}
801057f6:	c9                   	leave  
801057f7:	c3                   	ret    

801057f8 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801057f8:	55                   	push   %ebp
801057f9:	89 e5                	mov    %esp,%ebp
801057fb:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801057fe:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105805:	eb 24                	jmp    8010582b <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105807:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010580a:	8b 40 0c             	mov    0xc(%eax),%eax
8010580d:	83 f8 02             	cmp    $0x2,%eax
80105810:	75 15                	jne    80105827 <wakeup1+0x2f>
80105812:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105815:	8b 40 20             	mov    0x20(%eax),%eax
80105818:	3b 45 08             	cmp    0x8(%ebp),%eax
8010581b:	75 0a                	jne    80105827 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010581d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105820:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105827:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010582b:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
80105832:	72 d3                	jb     80105807 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105834:	c9                   	leave  
80105835:	c3                   	ret    

80105836 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105836:	55                   	push   %ebp
80105837:	89 e5                	mov    %esp,%ebp
80105839:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010583c:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80105843:	e8 df 01 00 00       	call   80105a27 <acquire>
  wakeup1(chan);
80105848:	8b 45 08             	mov    0x8(%ebp),%eax
8010584b:	89 04 24             	mov    %eax,(%esp)
8010584e:	e8 a5 ff ff ff       	call   801057f8 <wakeup1>
  release(&ptable.lock);
80105853:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
8010585a:	e8 2a 02 00 00       	call   80105a89 <release>
}
8010585f:	c9                   	leave  
80105860:	c3                   	ret    

80105861 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105861:	55                   	push   %ebp
80105862:	89 e5                	mov    %esp,%ebp
80105864:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105867:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
8010586e:	e8 b4 01 00 00       	call   80105a27 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105873:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
8010587a:	eb 41                	jmp    801058bd <kill+0x5c>
    if(p->pid == pid){
8010587c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587f:	8b 40 10             	mov    0x10(%eax),%eax
80105882:	3b 45 08             	cmp    0x8(%ebp),%eax
80105885:	75 32                	jne    801058b9 <kill+0x58>
      p->killed = 1;
80105887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105891:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105894:	8b 40 0c             	mov    0xc(%eax),%eax
80105897:	83 f8 02             	cmp    $0x2,%eax
8010589a:	75 0a                	jne    801058a6 <kill+0x45>
        p->state = RUNNABLE;
8010589c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801058a6:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801058ad:	e8 d7 01 00 00       	call   80105a89 <release>
      return 0;
801058b2:	b8 00 00 00 00       	mov    $0x0,%eax
801058b7:	eb 1e                	jmp    801058d7 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801058b9:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801058bd:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801058c4:	72 b6                	jb     8010587c <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801058c6:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
801058cd:	e8 b7 01 00 00       	call   80105a89 <release>
  return -1;
801058d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058d7:	c9                   	leave  
801058d8:	c3                   	ret    

801058d9 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801058d9:	55                   	push   %ebp
801058da:	89 e5                	mov    %esp,%ebp
801058dc:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801058df:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
801058e6:	e9 d6 00 00 00       	jmp    801059c1 <procdump+0xe8>
    if(p->state == UNUSED)
801058eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ee:	8b 40 0c             	mov    0xc(%eax),%eax
801058f1:	85 c0                	test   %eax,%eax
801058f3:	75 05                	jne    801058fa <procdump+0x21>
      continue;
801058f5:	e9 c3 00 00 00       	jmp    801059bd <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801058fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fd:	8b 40 0c             	mov    0xc(%eax),%eax
80105900:	83 f8 05             	cmp    $0x5,%eax
80105903:	77 23                	ja     80105928 <procdump+0x4f>
80105905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105908:	8b 40 0c             	mov    0xc(%eax),%eax
8010590b:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105912:	85 c0                	test   %eax,%eax
80105914:	74 12                	je     80105928 <procdump+0x4f>
      state = states[p->state];
80105916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105919:	8b 40 0c             	mov    0xc(%eax),%eax
8010591c:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105923:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105926:	eb 07                	jmp    8010592f <procdump+0x56>
    else
      state = "???";
80105928:	c7 45 ec 49 97 10 80 	movl   $0x80109749,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010592f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105932:	8d 50 6c             	lea    0x6c(%eax),%edx
80105935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105938:	8b 40 10             	mov    0x10(%eax),%eax
8010593b:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010593f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105942:	89 54 24 08          	mov    %edx,0x8(%esp)
80105946:	89 44 24 04          	mov    %eax,0x4(%esp)
8010594a:	c7 04 24 4d 97 10 80 	movl   $0x8010974d,(%esp)
80105951:	e8 4a aa ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80105956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105959:	8b 40 0c             	mov    0xc(%eax),%eax
8010595c:	83 f8 02             	cmp    $0x2,%eax
8010595f:	75 50                	jne    801059b1 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105964:	8b 40 1c             	mov    0x1c(%eax),%eax
80105967:	8b 40 0c             	mov    0xc(%eax),%eax
8010596a:	83 c0 08             	add    $0x8,%eax
8010596d:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105970:	89 54 24 04          	mov    %edx,0x4(%esp)
80105974:	89 04 24             	mov    %eax,(%esp)
80105977:	e8 5c 01 00 00       	call   80105ad8 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010597c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105983:	eb 1b                	jmp    801059a0 <procdump+0xc7>
        cprintf(" %p", pc[i]);
80105985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105988:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010598c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105990:	c7 04 24 56 97 10 80 	movl   $0x80109756,(%esp)
80105997:	e8 04 aa ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010599c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801059a0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801059a4:	7f 0b                	jg     801059b1 <procdump+0xd8>
801059a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801059ad:	85 c0                	test   %eax,%eax
801059af:	75 d4                	jne    80105985 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801059b1:	c7 04 24 5a 97 10 80 	movl   $0x8010975a,(%esp)
801059b8:	e8 e3 a9 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059bd:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
801059c1:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
801059c8:	0f 82 1d ff ff ff    	jb     801058eb <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801059ce:	c9                   	leave  
801059cf:	c3                   	ret    

801059d0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801059d0:	55                   	push   %ebp
801059d1:	89 e5                	mov    %esp,%ebp
801059d3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801059d6:	9c                   	pushf  
801059d7:	58                   	pop    %eax
801059d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801059db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059de:	c9                   	leave  
801059df:	c3                   	ret    

801059e0 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801059e0:	55                   	push   %ebp
801059e1:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801059e3:	fa                   	cli    
}
801059e4:	5d                   	pop    %ebp
801059e5:	c3                   	ret    

801059e6 <sti>:

static inline void
sti(void)
{
801059e6:	55                   	push   %ebp
801059e7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801059e9:	fb                   	sti    
}
801059ea:	5d                   	pop    %ebp
801059eb:	c3                   	ret    

801059ec <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801059ec:	55                   	push   %ebp
801059ed:	89 e5                	mov    %esp,%ebp
801059ef:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801059f2:	8b 55 08             	mov    0x8(%ebp),%edx
801059f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801059f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059fb:	f0 87 02             	lock xchg %eax,(%edx)
801059fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105a01:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a04:	c9                   	leave  
80105a05:	c3                   	ret    

80105a06 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105a06:	55                   	push   %ebp
80105a07:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105a09:	8b 45 08             	mov    0x8(%ebp),%eax
80105a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a0f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105a12:	8b 45 08             	mov    0x8(%ebp),%eax
80105a15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80105a1e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105a25:	5d                   	pop    %ebp
80105a26:	c3                   	ret    

80105a27 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105a27:	55                   	push   %ebp
80105a28:	89 e5                	mov    %esp,%ebp
80105a2a:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105a2d:	e8 49 01 00 00       	call   80105b7b <pushcli>
  if(holding(lk))
80105a32:	8b 45 08             	mov    0x8(%ebp),%eax
80105a35:	89 04 24             	mov    %eax,(%esp)
80105a38:	e8 14 01 00 00       	call   80105b51 <holding>
80105a3d:	85 c0                	test   %eax,%eax
80105a3f:	74 0c                	je     80105a4d <acquire+0x26>
    panic("acquire");
80105a41:	c7 04 24 86 97 10 80 	movl   $0x80109786,(%esp)
80105a48:	e8 ed aa ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105a4d:	90                   	nop
80105a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105a58:	00 
80105a59:	89 04 24             	mov    %eax,(%esp)
80105a5c:	e8 8b ff ff ff       	call   801059ec <xchg>
80105a61:	85 c0                	test   %eax,%eax
80105a63:	75 e9                	jne    80105a4e <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105a65:	8b 45 08             	mov    0x8(%ebp),%eax
80105a68:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105a6f:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105a72:	8b 45 08             	mov    0x8(%ebp),%eax
80105a75:	83 c0 0c             	add    $0xc,%eax
80105a78:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a7c:	8d 45 08             	lea    0x8(%ebp),%eax
80105a7f:	89 04 24             	mov    %eax,(%esp)
80105a82:	e8 51 00 00 00       	call   80105ad8 <getcallerpcs>
}
80105a87:	c9                   	leave  
80105a88:	c3                   	ret    

80105a89 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105a89:	55                   	push   %ebp
80105a8a:	89 e5                	mov    %esp,%ebp
80105a8c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80105a92:	89 04 24             	mov    %eax,(%esp)
80105a95:	e8 b7 00 00 00       	call   80105b51 <holding>
80105a9a:	85 c0                	test   %eax,%eax
80105a9c:	75 0c                	jne    80105aaa <release+0x21>
    panic("release");
80105a9e:	c7 04 24 8e 97 10 80 	movl   $0x8010978e,(%esp)
80105aa5:	e8 90 aa ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80105aad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105abe:	8b 45 08             	mov    0x8(%ebp),%eax
80105ac1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ac8:	00 
80105ac9:	89 04 24             	mov    %eax,(%esp)
80105acc:	e8 1b ff ff ff       	call   801059ec <xchg>

  popcli();
80105ad1:	e8 e9 00 00 00       	call   80105bbf <popcli>
}
80105ad6:	c9                   	leave  
80105ad7:	c3                   	ret    

80105ad8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105ad8:	55                   	push   %ebp
80105ad9:	89 e5                	mov    %esp,%ebp
80105adb:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105ade:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae1:	83 e8 08             	sub    $0x8,%eax
80105ae4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105ae7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105aee:	eb 38                	jmp    80105b28 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105af0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105af4:	74 38                	je     80105b2e <getcallerpcs+0x56>
80105af6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105afd:	76 2f                	jbe    80105b2e <getcallerpcs+0x56>
80105aff:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105b03:	74 29                	je     80105b2e <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105b05:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b12:	01 c2                	add    %eax,%edx
80105b14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b17:	8b 40 04             	mov    0x4(%eax),%eax
80105b1a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105b1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b1f:	8b 00                	mov    (%eax),%eax
80105b21:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105b24:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105b28:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105b2c:	7e c2                	jle    80105af0 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105b2e:	eb 19                	jmp    80105b49 <getcallerpcs+0x71>
    pcs[i] = 0;
80105b30:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b3d:	01 d0                	add    %edx,%eax
80105b3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105b45:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105b49:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105b4d:	7e e1                	jle    80105b30 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105b4f:	c9                   	leave  
80105b50:	c3                   	ret    

80105b51 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105b51:	55                   	push   %ebp
80105b52:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105b54:	8b 45 08             	mov    0x8(%ebp),%eax
80105b57:	8b 00                	mov    (%eax),%eax
80105b59:	85 c0                	test   %eax,%eax
80105b5b:	74 17                	je     80105b74 <holding+0x23>
80105b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105b60:	8b 50 08             	mov    0x8(%eax),%edx
80105b63:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b69:	39 c2                	cmp    %eax,%edx
80105b6b:	75 07                	jne    80105b74 <holding+0x23>
80105b6d:	b8 01 00 00 00       	mov    $0x1,%eax
80105b72:	eb 05                	jmp    80105b79 <holding+0x28>
80105b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b79:	5d                   	pop    %ebp
80105b7a:	c3                   	ret    

80105b7b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105b7b:	55                   	push   %ebp
80105b7c:	89 e5                	mov    %esp,%ebp
80105b7e:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105b81:	e8 4a fe ff ff       	call   801059d0 <readeflags>
80105b86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105b89:	e8 52 fe ff ff       	call   801059e0 <cli>
  if(cpu->ncli++ == 0)
80105b8e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105b95:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105b9b:	8d 48 01             	lea    0x1(%eax),%ecx
80105b9e:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	75 15                	jne    80105bbd <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105ba8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105bae:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bb1:	81 e2 00 02 00 00    	and    $0x200,%edx
80105bb7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105bbd:	c9                   	leave  
80105bbe:	c3                   	ret    

80105bbf <popcli>:

void
popcli(void)
{
80105bbf:	55                   	push   %ebp
80105bc0:	89 e5                	mov    %esp,%ebp
80105bc2:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105bc5:	e8 06 fe ff ff       	call   801059d0 <readeflags>
80105bca:	25 00 02 00 00       	and    $0x200,%eax
80105bcf:	85 c0                	test   %eax,%eax
80105bd1:	74 0c                	je     80105bdf <popcli+0x20>
    panic("popcli - interruptible");
80105bd3:	c7 04 24 96 97 10 80 	movl   $0x80109796,(%esp)
80105bda:	e8 5b a9 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105bdf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105be5:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105beb:	83 ea 01             	sub    $0x1,%edx
80105bee:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105bf4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105bfa:	85 c0                	test   %eax,%eax
80105bfc:	79 0c                	jns    80105c0a <popcli+0x4b>
    panic("popcli");
80105bfe:	c7 04 24 ad 97 10 80 	movl   $0x801097ad,(%esp)
80105c05:	e8 30 a9 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105c0a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c10:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105c16:	85 c0                	test   %eax,%eax
80105c18:	75 15                	jne    80105c2f <popcli+0x70>
80105c1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c20:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105c26:	85 c0                	test   %eax,%eax
80105c28:	74 05                	je     80105c2f <popcli+0x70>
    sti();
80105c2a:	e8 b7 fd ff ff       	call   801059e6 <sti>
}
80105c2f:	c9                   	leave  
80105c30:	c3                   	ret    

80105c31 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105c31:	55                   	push   %ebp
80105c32:	89 e5                	mov    %esp,%ebp
80105c34:	57                   	push   %edi
80105c35:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c39:	8b 55 10             	mov    0x10(%ebp),%edx
80105c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c3f:	89 cb                	mov    %ecx,%ebx
80105c41:	89 df                	mov    %ebx,%edi
80105c43:	89 d1                	mov    %edx,%ecx
80105c45:	fc                   	cld    
80105c46:	f3 aa                	rep stos %al,%es:(%edi)
80105c48:	89 ca                	mov    %ecx,%edx
80105c4a:	89 fb                	mov    %edi,%ebx
80105c4c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105c4f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105c52:	5b                   	pop    %ebx
80105c53:	5f                   	pop    %edi
80105c54:	5d                   	pop    %ebp
80105c55:	c3                   	ret    

80105c56 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105c56:	55                   	push   %ebp
80105c57:	89 e5                	mov    %esp,%ebp
80105c59:	57                   	push   %edi
80105c5a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c5e:	8b 55 10             	mov    0x10(%ebp),%edx
80105c61:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c64:	89 cb                	mov    %ecx,%ebx
80105c66:	89 df                	mov    %ebx,%edi
80105c68:	89 d1                	mov    %edx,%ecx
80105c6a:	fc                   	cld    
80105c6b:	f3 ab                	rep stos %eax,%es:(%edi)
80105c6d:	89 ca                	mov    %ecx,%edx
80105c6f:	89 fb                	mov    %edi,%ebx
80105c71:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105c74:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105c77:	5b                   	pop    %ebx
80105c78:	5f                   	pop    %edi
80105c79:	5d                   	pop    %ebp
80105c7a:	c3                   	ret    

80105c7b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105c7b:	55                   	push   %ebp
80105c7c:	89 e5                	mov    %esp,%ebp
80105c7e:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105c81:	8b 45 08             	mov    0x8(%ebp),%eax
80105c84:	83 e0 03             	and    $0x3,%eax
80105c87:	85 c0                	test   %eax,%eax
80105c89:	75 49                	jne    80105cd4 <memset+0x59>
80105c8b:	8b 45 10             	mov    0x10(%ebp),%eax
80105c8e:	83 e0 03             	and    $0x3,%eax
80105c91:	85 c0                	test   %eax,%eax
80105c93:	75 3f                	jne    80105cd4 <memset+0x59>
    c &= 0xFF;
80105c95:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105c9c:	8b 45 10             	mov    0x10(%ebp),%eax
80105c9f:	c1 e8 02             	shr    $0x2,%eax
80105ca2:	89 c2                	mov    %eax,%edx
80105ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ca7:	c1 e0 18             	shl    $0x18,%eax
80105caa:	89 c1                	mov    %eax,%ecx
80105cac:	8b 45 0c             	mov    0xc(%ebp),%eax
80105caf:	c1 e0 10             	shl    $0x10,%eax
80105cb2:	09 c1                	or     %eax,%ecx
80105cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cb7:	c1 e0 08             	shl    $0x8,%eax
80105cba:	09 c8                	or     %ecx,%eax
80105cbc:	0b 45 0c             	or     0xc(%ebp),%eax
80105cbf:	89 54 24 08          	mov    %edx,0x8(%esp)
80105cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80105cca:	89 04 24             	mov    %eax,(%esp)
80105ccd:	e8 84 ff ff ff       	call   80105c56 <stosl>
80105cd2:	eb 19                	jmp    80105ced <memset+0x72>
  } else
    stosb(dst, c, n);
80105cd4:	8b 45 10             	mov    0x10(%ebp),%eax
80105cd7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cde:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce5:	89 04 24             	mov    %eax,(%esp)
80105ce8:	e8 44 ff ff ff       	call   80105c31 <stosb>
  return dst;
80105ced:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105cf0:	c9                   	leave  
80105cf1:	c3                   	ret    

80105cf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105cf2:	55                   	push   %ebp
80105cf3:	89 e5                	mov    %esp,%ebp
80105cf5:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80105cfb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d01:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105d04:	eb 30                	jmp    80105d36 <memcmp+0x44>
    if(*s1 != *s2)
80105d06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d09:	0f b6 10             	movzbl (%eax),%edx
80105d0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d0f:	0f b6 00             	movzbl (%eax),%eax
80105d12:	38 c2                	cmp    %al,%dl
80105d14:	74 18                	je     80105d2e <memcmp+0x3c>
      return *s1 - *s2;
80105d16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d19:	0f b6 00             	movzbl (%eax),%eax
80105d1c:	0f b6 d0             	movzbl %al,%edx
80105d1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d22:	0f b6 00             	movzbl (%eax),%eax
80105d25:	0f b6 c0             	movzbl %al,%eax
80105d28:	29 c2                	sub    %eax,%edx
80105d2a:	89 d0                	mov    %edx,%eax
80105d2c:	eb 1a                	jmp    80105d48 <memcmp+0x56>
    s1++, s2++;
80105d2e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d32:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105d36:	8b 45 10             	mov    0x10(%ebp),%eax
80105d39:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d3c:	89 55 10             	mov    %edx,0x10(%ebp)
80105d3f:	85 c0                	test   %eax,%eax
80105d41:	75 c3                	jne    80105d06 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d48:	c9                   	leave  
80105d49:	c3                   	ret    

80105d4a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105d4a:	55                   	push   %ebp
80105d4b:	89 e5                	mov    %esp,%ebp
80105d4d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105d50:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d53:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105d56:	8b 45 08             	mov    0x8(%ebp),%eax
80105d59:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d5f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d62:	73 3d                	jae    80105da1 <memmove+0x57>
80105d64:	8b 45 10             	mov    0x10(%ebp),%eax
80105d67:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d6a:	01 d0                	add    %edx,%eax
80105d6c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d6f:	76 30                	jbe    80105da1 <memmove+0x57>
    s += n;
80105d71:	8b 45 10             	mov    0x10(%ebp),%eax
80105d74:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105d77:	8b 45 10             	mov    0x10(%ebp),%eax
80105d7a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105d7d:	eb 13                	jmp    80105d92 <memmove+0x48>
      *--d = *--s;
80105d7f:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105d83:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105d87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d8a:	0f b6 10             	movzbl (%eax),%edx
80105d8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d90:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105d92:	8b 45 10             	mov    0x10(%ebp),%eax
80105d95:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d98:	89 55 10             	mov    %edx,0x10(%ebp)
80105d9b:	85 c0                	test   %eax,%eax
80105d9d:	75 e0                	jne    80105d7f <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105d9f:	eb 26                	jmp    80105dc7 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105da1:	eb 17                	jmp    80105dba <memmove+0x70>
      *d++ = *s++;
80105da3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105da6:	8d 50 01             	lea    0x1(%eax),%edx
80105da9:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105dac:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105daf:	8d 4a 01             	lea    0x1(%edx),%ecx
80105db2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105db5:	0f b6 12             	movzbl (%edx),%edx
80105db8:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105dba:	8b 45 10             	mov    0x10(%ebp),%eax
80105dbd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dc0:	89 55 10             	mov    %edx,0x10(%ebp)
80105dc3:	85 c0                	test   %eax,%eax
80105dc5:	75 dc                	jne    80105da3 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105dc7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105dca:	c9                   	leave  
80105dcb:	c3                   	ret    

80105dcc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105dcc:	55                   	push   %ebp
80105dcd:	89 e5                	mov    %esp,%ebp
80105dcf:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105dd2:	8b 45 10             	mov    0x10(%ebp),%eax
80105dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de0:	8b 45 08             	mov    0x8(%ebp),%eax
80105de3:	89 04 24             	mov    %eax,(%esp)
80105de6:	e8 5f ff ff ff       	call   80105d4a <memmove>
}
80105deb:	c9                   	leave  
80105dec:	c3                   	ret    

80105ded <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105ded:	55                   	push   %ebp
80105dee:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105df0:	eb 0c                	jmp    80105dfe <strncmp+0x11>
    n--, p++, q++;
80105df2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105df6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105dfa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105dfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e02:	74 1a                	je     80105e1e <strncmp+0x31>
80105e04:	8b 45 08             	mov    0x8(%ebp),%eax
80105e07:	0f b6 00             	movzbl (%eax),%eax
80105e0a:	84 c0                	test   %al,%al
80105e0c:	74 10                	je     80105e1e <strncmp+0x31>
80105e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e11:	0f b6 10             	movzbl (%eax),%edx
80105e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e17:	0f b6 00             	movzbl (%eax),%eax
80105e1a:	38 c2                	cmp    %al,%dl
80105e1c:	74 d4                	je     80105df2 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105e1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e22:	75 07                	jne    80105e2b <strncmp+0x3e>
    return 0;
80105e24:	b8 00 00 00 00       	mov    $0x0,%eax
80105e29:	eb 16                	jmp    80105e41 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80105e2e:	0f b6 00             	movzbl (%eax),%eax
80105e31:	0f b6 d0             	movzbl %al,%edx
80105e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e37:	0f b6 00             	movzbl (%eax),%eax
80105e3a:	0f b6 c0             	movzbl %al,%eax
80105e3d:	29 c2                	sub    %eax,%edx
80105e3f:	89 d0                	mov    %edx,%eax
}
80105e41:	5d                   	pop    %ebp
80105e42:	c3                   	ret    

80105e43 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105e43:	55                   	push   %ebp
80105e44:	89 e5                	mov    %esp,%ebp
80105e46:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105e49:	8b 45 08             	mov    0x8(%ebp),%eax
80105e4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105e4f:	90                   	nop
80105e50:	8b 45 10             	mov    0x10(%ebp),%eax
80105e53:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e56:	89 55 10             	mov    %edx,0x10(%ebp)
80105e59:	85 c0                	test   %eax,%eax
80105e5b:	7e 1e                	jle    80105e7b <strncpy+0x38>
80105e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105e60:	8d 50 01             	lea    0x1(%eax),%edx
80105e63:	89 55 08             	mov    %edx,0x8(%ebp)
80105e66:	8b 55 0c             	mov    0xc(%ebp),%edx
80105e69:	8d 4a 01             	lea    0x1(%edx),%ecx
80105e6c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105e6f:	0f b6 12             	movzbl (%edx),%edx
80105e72:	88 10                	mov    %dl,(%eax)
80105e74:	0f b6 00             	movzbl (%eax),%eax
80105e77:	84 c0                	test   %al,%al
80105e79:	75 d5                	jne    80105e50 <strncpy+0xd>
    ;
  while(n-- > 0)
80105e7b:	eb 0c                	jmp    80105e89 <strncpy+0x46>
    *s++ = 0;
80105e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105e80:	8d 50 01             	lea    0x1(%eax),%edx
80105e83:	89 55 08             	mov    %edx,0x8(%ebp)
80105e86:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105e89:	8b 45 10             	mov    0x10(%ebp),%eax
80105e8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e8f:	89 55 10             	mov    %edx,0x10(%ebp)
80105e92:	85 c0                	test   %eax,%eax
80105e94:	7f e7                	jg     80105e7d <strncpy+0x3a>
    *s++ = 0;
  return os;
80105e96:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e99:	c9                   	leave  
80105e9a:	c3                   	ret    

80105e9b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105e9b:	55                   	push   %ebp
80105e9c:	89 e5                	mov    %esp,%ebp
80105e9e:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105ea7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105eab:	7f 05                	jg     80105eb2 <safestrcpy+0x17>
    return os;
80105ead:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eb0:	eb 31                	jmp    80105ee3 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105eb2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105eb6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105eba:	7e 1e                	jle    80105eda <safestrcpy+0x3f>
80105ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80105ebf:	8d 50 01             	lea    0x1(%eax),%edx
80105ec2:	89 55 08             	mov    %edx,0x8(%ebp)
80105ec5:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ec8:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ecb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105ece:	0f b6 12             	movzbl (%edx),%edx
80105ed1:	88 10                	mov    %dl,(%eax)
80105ed3:	0f b6 00             	movzbl (%eax),%eax
80105ed6:	84 c0                	test   %al,%al
80105ed8:	75 d8                	jne    80105eb2 <safestrcpy+0x17>
    ;
  *s = 0;
80105eda:	8b 45 08             	mov    0x8(%ebp),%eax
80105edd:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105ee0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ee3:	c9                   	leave  
80105ee4:	c3                   	ret    

80105ee5 <strlen>:

int
strlen(const char *s)
{
80105ee5:	55                   	push   %ebp
80105ee6:	89 e5                	mov    %esp,%ebp
80105ee8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105eeb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105ef2:	eb 04                	jmp    80105ef8 <strlen+0x13>
80105ef4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ef8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105efb:	8b 45 08             	mov    0x8(%ebp),%eax
80105efe:	01 d0                	add    %edx,%eax
80105f00:	0f b6 00             	movzbl (%eax),%eax
80105f03:	84 c0                	test   %al,%al
80105f05:	75 ed                	jne    80105ef4 <strlen+0xf>
    ;
  return n;
80105f07:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f0a:	c9                   	leave  
80105f0b:	c3                   	ret    

80105f0c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105f0c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105f10:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105f14:	55                   	push   %ebp
  pushl %ebx
80105f15:	53                   	push   %ebx
  pushl %esi
80105f16:	56                   	push   %esi
  pushl %edi
80105f17:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105f18:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105f1a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105f1c:	5f                   	pop    %edi
  popl %esi
80105f1d:	5e                   	pop    %esi
  popl %ebx
80105f1e:	5b                   	pop    %ebx
  popl %ebp
80105f1f:	5d                   	pop    %ebp
  ret
80105f20:	c3                   	ret    

80105f21 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105f21:	55                   	push   %ebp
80105f22:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105f24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f2a:	8b 00                	mov    (%eax),%eax
80105f2c:	3b 45 08             	cmp    0x8(%ebp),%eax
80105f2f:	76 12                	jbe    80105f43 <fetchint+0x22>
80105f31:	8b 45 08             	mov    0x8(%ebp),%eax
80105f34:	8d 50 04             	lea    0x4(%eax),%edx
80105f37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f3d:	8b 00                	mov    (%eax),%eax
80105f3f:	39 c2                	cmp    %eax,%edx
80105f41:	76 07                	jbe    80105f4a <fetchint+0x29>
    return -1;
80105f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f48:	eb 0f                	jmp    80105f59 <fetchint+0x38>
  *ip = *(int*)(addr);
80105f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80105f4d:	8b 10                	mov    (%eax),%edx
80105f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f52:	89 10                	mov    %edx,(%eax)
  return 0;
80105f54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f59:	5d                   	pop    %ebp
80105f5a:	c3                   	ret    

80105f5b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105f5b:	55                   	push   %ebp
80105f5c:	89 e5                	mov    %esp,%ebp
80105f5e:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105f61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f67:	8b 00                	mov    (%eax),%eax
80105f69:	3b 45 08             	cmp    0x8(%ebp),%eax
80105f6c:	77 07                	ja     80105f75 <fetchstr+0x1a>
    return -1;
80105f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f73:	eb 46                	jmp    80105fbb <fetchstr+0x60>
  *pp = (char*)addr;
80105f75:	8b 55 08             	mov    0x8(%ebp),%edx
80105f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f7b:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105f7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f83:	8b 00                	mov    (%eax),%eax
80105f85:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105f88:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f8b:	8b 00                	mov    (%eax),%eax
80105f8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105f90:	eb 1c                	jmp    80105fae <fetchstr+0x53>
    if(*s == 0)
80105f92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f95:	0f b6 00             	movzbl (%eax),%eax
80105f98:	84 c0                	test   %al,%al
80105f9a:	75 0e                	jne    80105faa <fetchstr+0x4f>
      return s - *pp;
80105f9c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fa2:	8b 00                	mov    (%eax),%eax
80105fa4:	29 c2                	sub    %eax,%edx
80105fa6:	89 d0                	mov    %edx,%eax
80105fa8:	eb 11                	jmp    80105fbb <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105faa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fb1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105fb4:	72 dc                	jb     80105f92 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105fb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fbb:	c9                   	leave  
80105fbc:	c3                   	ret    

80105fbd <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105fbd:	55                   	push   %ebp
80105fbe:	89 e5                	mov    %esp,%ebp
80105fc0:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105fc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fc9:	8b 40 18             	mov    0x18(%eax),%eax
80105fcc:	8b 50 44             	mov    0x44(%eax),%edx
80105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd2:	c1 e0 02             	shl    $0x2,%eax
80105fd5:	01 d0                	add    %edx,%eax
80105fd7:	8d 50 04             	lea    0x4(%eax),%edx
80105fda:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fe1:	89 14 24             	mov    %edx,(%esp)
80105fe4:	e8 38 ff ff ff       	call   80105f21 <fetchint>
}
80105fe9:	c9                   	leave  
80105fea:	c3                   	ret    

80105feb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105feb:	55                   	push   %ebp
80105fec:	89 e5                	mov    %esp,%ebp
80105fee:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105ff1:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80105ffb:	89 04 24             	mov    %eax,(%esp)
80105ffe:	e8 ba ff ff ff       	call   80105fbd <argint>
80106003:	85 c0                	test   %eax,%eax
80106005:	79 07                	jns    8010600e <argptr+0x23>
    return -1;
80106007:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010600c:	eb 3d                	jmp    8010604b <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010600e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106011:	89 c2                	mov    %eax,%edx
80106013:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106019:	8b 00                	mov    (%eax),%eax
8010601b:	39 c2                	cmp    %eax,%edx
8010601d:	73 16                	jae    80106035 <argptr+0x4a>
8010601f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106022:	89 c2                	mov    %eax,%edx
80106024:	8b 45 10             	mov    0x10(%ebp),%eax
80106027:	01 c2                	add    %eax,%edx
80106029:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010602f:	8b 00                	mov    (%eax),%eax
80106031:	39 c2                	cmp    %eax,%edx
80106033:	76 07                	jbe    8010603c <argptr+0x51>
    return -1;
80106035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603a:	eb 0f                	jmp    8010604b <argptr+0x60>
  *pp = (char*)i;
8010603c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010603f:	89 c2                	mov    %eax,%edx
80106041:	8b 45 0c             	mov    0xc(%ebp),%eax
80106044:	89 10                	mov    %edx,(%eax)
  return 0;
80106046:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010604b:	c9                   	leave  
8010604c:	c3                   	ret    

8010604d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010604d:	55                   	push   %ebp
8010604e:	89 e5                	mov    %esp,%ebp
80106050:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106053:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106056:	89 44 24 04          	mov    %eax,0x4(%esp)
8010605a:	8b 45 08             	mov    0x8(%ebp),%eax
8010605d:	89 04 24             	mov    %eax,(%esp)
80106060:	e8 58 ff ff ff       	call   80105fbd <argint>
80106065:	85 c0                	test   %eax,%eax
80106067:	79 07                	jns    80106070 <argstr+0x23>
    return -1;
80106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606e:	eb 12                	jmp    80106082 <argstr+0x35>
  return fetchstr(addr, pp);
80106070:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106073:	8b 55 0c             	mov    0xc(%ebp),%edx
80106076:	89 54 24 04          	mov    %edx,0x4(%esp)
8010607a:	89 04 24             	mov    %eax,(%esp)
8010607d:	e8 d9 fe ff ff       	call   80105f5b <fetchstr>
}
80106082:	c9                   	leave  
80106083:	c3                   	ret    

80106084 <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
80106084:	55                   	push   %ebp
80106085:	89 e5                	mov    %esp,%ebp
80106087:	53                   	push   %ebx
80106088:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010608b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106091:	8b 40 18             	mov    0x18(%eax),%eax
80106094:	8b 40 1c             	mov    0x1c(%eax),%eax
80106097:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010609a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010609e:	7e 30                	jle    801060d0 <syscall+0x4c>
801060a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a3:	83 f8 16             	cmp    $0x16,%eax
801060a6:	77 28                	ja     801060d0 <syscall+0x4c>
801060a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ab:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801060b2:	85 c0                	test   %eax,%eax
801060b4:	74 1a                	je     801060d0 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801060b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060bc:	8b 58 18             	mov    0x18(%eax),%ebx
801060bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c2:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801060c9:	ff d0                	call   *%eax
801060cb:	89 43 1c             	mov    %eax,0x1c(%ebx)
801060ce:	eb 3d                	jmp    8010610d <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801060d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d6:	8d 48 6c             	lea    0x6c(%eax),%ecx
801060d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801060df:	8b 40 10             	mov    0x10(%eax),%eax
801060e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801060e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801060ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801060f1:	c7 04 24 b4 97 10 80 	movl   $0x801097b4,(%esp)
801060f8:	e8 a3 a2 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801060fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106103:	8b 40 18             	mov    0x18(%eax),%eax
80106106:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010610d:	83 c4 24             	add    $0x24,%esp
80106110:	5b                   	pop    %ebx
80106111:	5d                   	pop    %ebp
80106112:	c3                   	ret    

80106113 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
80106113:	55                   	push   %ebp
80106114:	89 e5                	mov    %esp,%ebp
80106116:	83 ec 28             	sub    $0x28,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
80106119:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010611c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106120:	8b 45 08             	mov    0x8(%ebp),%eax
80106123:	89 04 24             	mov    %eax,(%esp)
80106126:	e8 92 fe ff ff       	call   80105fbd <argint>
8010612b:	85 c0                	test   %eax,%eax
8010612d:	79 07                	jns    80106136 <argfd+0x23>
        return -1;
8010612f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106134:	eb 50                	jmp    80106186 <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
80106136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106139:	85 c0                	test   %eax,%eax
8010613b:	78 21                	js     8010615e <argfd+0x4b>
8010613d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106140:	83 f8 0f             	cmp    $0xf,%eax
80106143:	7f 19                	jg     8010615e <argfd+0x4b>
80106145:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010614b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010614e:	83 c2 08             	add    $0x8,%edx
80106151:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106155:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106158:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010615c:	75 07                	jne    80106165 <argfd+0x52>
        return -1;
8010615e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106163:	eb 21                	jmp    80106186 <argfd+0x73>
    if (pfd)
80106165:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106169:	74 08                	je     80106173 <argfd+0x60>
        *pfd = fd;
8010616b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010616e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106171:	89 10                	mov    %edx,(%eax)
    if (pf)
80106173:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106177:	74 08                	je     80106181 <argfd+0x6e>
        *pf = f;
80106179:	8b 45 10             	mov    0x10(%ebp),%eax
8010617c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010617f:	89 10                	mov    %edx,(%eax)
    return 0;
80106181:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106186:	c9                   	leave  
80106187:	c3                   	ret    

80106188 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
80106188:	55                   	push   %ebp
80106189:	89 e5                	mov    %esp,%ebp
8010618b:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
8010618e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106195:	eb 30                	jmp    801061c7 <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
80106197:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010619d:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061a0:	83 c2 08             	add    $0x8,%edx
801061a3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801061a7:	85 c0                	test   %eax,%eax
801061a9:	75 18                	jne    801061c3 <fdalloc+0x3b>
            proc->ofile[fd] = f;
801061ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061b4:	8d 4a 08             	lea    0x8(%edx),%ecx
801061b7:	8b 55 08             	mov    0x8(%ebp),%edx
801061ba:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801061be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061c1:	eb 0f                	jmp    801061d2 <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801061c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801061c7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801061cb:	7e ca                	jle    80106197 <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
801061cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061d2:	c9                   	leave  
801061d3:	c3                   	ret    

801061d4 <sys_dup>:

int sys_dup(void)
{
801061d4:	55                   	push   %ebp
801061d5:	89 e5                	mov    %esp,%ebp
801061d7:	83 ec 28             	sub    $0x28,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
801061da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801061e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061e8:	00 
801061e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061f0:	e8 1e ff ff ff       	call   80106113 <argfd>
801061f5:	85 c0                	test   %eax,%eax
801061f7:	79 07                	jns    80106200 <sys_dup+0x2c>
        return -1;
801061f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fe:	eb 29                	jmp    80106229 <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106203:	89 04 24             	mov    %eax,(%esp)
80106206:	e8 7d ff ff ff       	call   80106188 <fdalloc>
8010620b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010620e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106212:	79 07                	jns    8010621b <sys_dup+0x47>
        return -1;
80106214:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106219:	eb 0e                	jmp    80106229 <sys_dup+0x55>
    filedup(f);
8010621b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621e:	89 04 24             	mov    %eax,(%esp)
80106221:	e8 c3 ad ff ff       	call   80100fe9 <filedup>
    return fd;
80106226:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106229:	c9                   	leave  
8010622a:	c3                   	ret    

8010622b <sys_read>:

int sys_read(void)
{
8010622b:	55                   	push   %ebp
8010622c:	89 e5                	mov    %esp,%ebp
8010622e:	83 ec 28             	sub    $0x28,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106231:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106234:	89 44 24 08          	mov    %eax,0x8(%esp)
80106238:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010623f:	00 
80106240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106247:	e8 c7 fe ff ff       	call   80106113 <argfd>
8010624c:	85 c0                	test   %eax,%eax
8010624e:	78 35                	js     80106285 <sys_read+0x5a>
80106250:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106253:	89 44 24 04          	mov    %eax,0x4(%esp)
80106257:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010625e:	e8 5a fd ff ff       	call   80105fbd <argint>
80106263:	85 c0                	test   %eax,%eax
80106265:	78 1e                	js     80106285 <sys_read+0x5a>
80106267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010626e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106271:	89 44 24 04          	mov    %eax,0x4(%esp)
80106275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010627c:	e8 6a fd ff ff       	call   80105feb <argptr>
80106281:	85 c0                	test   %eax,%eax
80106283:	79 07                	jns    8010628c <sys_read+0x61>
        return -1;
80106285:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628a:	eb 19                	jmp    801062a5 <sys_read+0x7a>
    return fileread(f, p, n);
8010628c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010628f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106295:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106299:	89 54 24 04          	mov    %edx,0x4(%esp)
8010629d:	89 04 24             	mov    %eax,(%esp)
801062a0:	e8 d1 ae ff ff       	call   80101176 <fileread>
}
801062a5:	c9                   	leave  
801062a6:	c3                   	ret    

801062a7 <sys_write>:

int sys_write(void)
{
801062a7:	55                   	push   %ebp
801062a8:	89 e5                	mov    %esp,%ebp
801062aa:	83 ec 28             	sub    $0x28,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801062ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801062b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062bb:	00 
801062bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062c3:	e8 4b fe ff ff       	call   80106113 <argfd>
801062c8:	85 c0                	test   %eax,%eax
801062ca:	78 35                	js     80106301 <sys_write+0x5a>
801062cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062da:	e8 de fc ff ff       	call   80105fbd <argint>
801062df:	85 c0                	test   %eax,%eax
801062e1:	78 1e                	js     80106301 <sys_write+0x5a>
801062e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e6:	89 44 24 08          	mov    %eax,0x8(%esp)
801062ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801062f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062f8:	e8 ee fc ff ff       	call   80105feb <argptr>
801062fd:	85 c0                	test   %eax,%eax
801062ff:	79 07                	jns    80106308 <sys_write+0x61>
        return -1;
80106301:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106306:	eb 19                	jmp    80106321 <sys_write+0x7a>
    return filewrite(f, p, n);
80106308:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010630b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010630e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106311:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106315:	89 54 24 04          	mov    %edx,0x4(%esp)
80106319:	89 04 24             	mov    %eax,(%esp)
8010631c:	e8 11 af ff ff       	call   80101232 <filewrite>
}
80106321:	c9                   	leave  
80106322:	c3                   	ret    

80106323 <sys_close>:

int sys_close(void)
{
80106323:	55                   	push   %ebp
80106324:	89 e5                	mov    %esp,%ebp
80106326:	83 ec 28             	sub    $0x28,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
80106329:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010632c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106330:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106333:	89 44 24 04          	mov    %eax,0x4(%esp)
80106337:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010633e:	e8 d0 fd ff ff       	call   80106113 <argfd>
80106343:	85 c0                	test   %eax,%eax
80106345:	79 07                	jns    8010634e <sys_close+0x2b>
        return -1;
80106347:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634c:	eb 24                	jmp    80106372 <sys_close+0x4f>
    proc->ofile[fd] = 0;
8010634e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106354:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106357:	83 c2 08             	add    $0x8,%edx
8010635a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106361:	00 
    fileclose(f);
80106362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106365:	89 04 24             	mov    %eax,(%esp)
80106368:	e8 c4 ac ff ff       	call   80101031 <fileclose>
    return 0;
8010636d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106372:	c9                   	leave  
80106373:	c3                   	ret    

80106374 <sys_fstat>:

int sys_fstat(void)
{
80106374:	55                   	push   %ebp
80106375:	89 e5                	mov    %esp,%ebp
80106377:	83 ec 28             	sub    $0x28,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010637a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010637d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106381:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106388:	00 
80106389:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106390:	e8 7e fd ff ff       	call   80106113 <argfd>
80106395:	85 c0                	test   %eax,%eax
80106397:	78 1f                	js     801063b8 <sys_fstat+0x44>
80106399:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801063a0:	00 
801063a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063af:	e8 37 fc ff ff       	call   80105feb <argptr>
801063b4:	85 c0                	test   %eax,%eax
801063b6:	79 07                	jns    801063bf <sys_fstat+0x4b>
        return -1;
801063b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bd:	eb 12                	jmp    801063d1 <sys_fstat+0x5d>
    return filestat(f, st);
801063bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801063c9:	89 04 24             	mov    %eax,(%esp)
801063cc:	e8 56 ad ff ff       	call   80101127 <filestat>
}
801063d1:	c9                   	leave  
801063d2:	c3                   	ret    

801063d3 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801063d3:	55                   	push   %ebp
801063d4:	89 e5                	mov    %esp,%ebp
801063d6:	83 ec 38             	sub    $0x38,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801063d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801063dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801063e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e7:	e8 61 fc ff ff       	call   8010604d <argstr>
801063ec:	85 c0                	test   %eax,%eax
801063ee:	78 17                	js     80106407 <sys_link+0x34>
801063f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801063f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063fe:	e8 4a fc ff ff       	call   8010604d <argstr>
80106403:	85 c0                	test   %eax,%eax
80106405:	79 0a                	jns    80106411 <sys_link+0x3e>
        return -1;
80106407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640c:	e9 9c 01 00 00       	jmp    801065ad <sys_link+0x1da>

    begin_op(proc->cwd->part->number);
80106411:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106417:	8b 40 68             	mov    0x68(%eax),%eax
8010641a:	8b 40 50             	mov    0x50(%eax),%eax
8010641d:	8b 40 14             	mov    0x14(%eax),%eax
80106420:	89 04 24             	mov    %eax,(%esp)
80106423:	e8 e6 d9 ff ff       	call   80103e0e <begin_op>
    if ((ip = namei(old)) == 0) {
80106428:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010642b:	89 04 24             	mov    %eax,(%esp)
8010642e:	e8 2a c8 ff ff       	call   80102c5d <namei>
80106433:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106436:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010643a:	75 21                	jne    8010645d <sys_link+0x8a>
        end_op(proc->cwd->part->number);
8010643c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106442:	8b 40 68             	mov    0x68(%eax),%eax
80106445:	8b 40 50             	mov    0x50(%eax),%eax
80106448:	8b 40 14             	mov    0x14(%eax),%eax
8010644b:	89 04 24             	mov    %eax,(%esp)
8010644e:	e8 bd da ff ff       	call   80103f10 <end_op>
        return -1;
80106453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106458:	e9 50 01 00 00       	jmp    801065ad <sys_link+0x1da>
    }

    ilock(ip);
8010645d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106460:	89 04 24             	mov    %eax,(%esp)
80106463:	e8 ce b9 ff ff       	call   80101e36 <ilock>
    if (ip->type == T_DIR) {
80106468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010646b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010646f:	66 83 f8 01          	cmp    $0x1,%ax
80106473:	75 2c                	jne    801064a1 <sys_link+0xce>
        iunlockput(ip);
80106475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106478:	89 04 24             	mov    %eax,(%esp)
8010647b:	e8 83 bc ff ff       	call   80102103 <iunlockput>
        end_op(proc->cwd->part->number);
80106480:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106486:	8b 40 68             	mov    0x68(%eax),%eax
80106489:	8b 40 50             	mov    0x50(%eax),%eax
8010648c:	8b 40 14             	mov    0x14(%eax),%eax
8010648f:	89 04 24             	mov    %eax,(%esp)
80106492:	e8 79 da ff ff       	call   80103f10 <end_op>
        return -1;
80106497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649c:	e9 0c 01 00 00       	jmp    801065ad <sys_link+0x1da>
    }

    ip->nlink++;
801064a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064a8:	8d 50 01             	lea    0x1(%eax),%edx
801064ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ae:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801064b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b5:	89 04 24             	mov    %eax,(%esp)
801064b8:	e8 34 b7 ff ff       	call   80101bf1 <iupdate>
    iunlock(ip);
801064bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c0:	89 04 24             	mov    %eax,(%esp)
801064c3:	e8 05 bb ff ff       	call   80101fcd <iunlock>

    if ((dp = nameiparent(new, name)) == 0)
801064c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064cb:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801064ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801064d2:	89 04 24             	mov    %eax,(%esp)
801064d5:	e8 d7 c7 ff ff       	call   80102cb1 <nameiparent>
801064da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064e1:	75 02                	jne    801064e5 <sys_link+0x112>
        goto bad;
801064e3:	eb 7a                	jmp    8010655f <sys_link+0x18c>
    ilock(dp);
801064e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064e8:	89 04 24             	mov    %eax,(%esp)
801064eb:	e8 46 b9 ff ff       	call   80101e36 <ilock>
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
801064f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f3:	8b 10                	mov    (%eax),%edx
801064f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f8:	8b 00                	mov    (%eax),%eax
801064fa:	39 c2                	cmp    %eax,%edx
801064fc:	75 20                	jne    8010651e <sys_link+0x14b>
801064fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106501:	8b 40 04             	mov    0x4(%eax),%eax
80106504:	89 44 24 08          	mov    %eax,0x8(%esp)
80106508:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010650b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010650f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106512:	89 04 24             	mov    %eax,(%esp)
80106515:	e8 f1 c3 ff ff       	call   8010290b <dirlink>
8010651a:	85 c0                	test   %eax,%eax
8010651c:	79 0d                	jns    8010652b <sys_link+0x158>
        iunlockput(dp);
8010651e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106521:	89 04 24             	mov    %eax,(%esp)
80106524:	e8 da bb ff ff       	call   80102103 <iunlockput>
        goto bad;
80106529:	eb 34                	jmp    8010655f <sys_link+0x18c>
    }
    iunlockput(dp);
8010652b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010652e:	89 04 24             	mov    %eax,(%esp)
80106531:	e8 cd bb ff ff       	call   80102103 <iunlockput>
    iput(ip);
80106536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106539:	89 04 24             	mov    %eax,(%esp)
8010653c:	e8 f1 ba ff ff       	call   80102032 <iput>

    end_op(proc->cwd->part->number);
80106541:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106547:	8b 40 68             	mov    0x68(%eax),%eax
8010654a:	8b 40 50             	mov    0x50(%eax),%eax
8010654d:	8b 40 14             	mov    0x14(%eax),%eax
80106550:	89 04 24             	mov    %eax,(%esp)
80106553:	e8 b8 d9 ff ff       	call   80103f10 <end_op>

    return 0;
80106558:	b8 00 00 00 00       	mov    $0x0,%eax
8010655d:	eb 4e                	jmp    801065ad <sys_link+0x1da>

bad:
    ilock(ip);
8010655f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106562:	89 04 24             	mov    %eax,(%esp)
80106565:	e8 cc b8 ff ff       	call   80101e36 <ilock>
    ip->nlink--;
8010656a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106571:	8d 50 ff             	lea    -0x1(%eax),%edx
80106574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106577:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
8010657b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657e:	89 04 24             	mov    %eax,(%esp)
80106581:	e8 6b b6 ff ff       	call   80101bf1 <iupdate>
    iunlockput(ip);
80106586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106589:	89 04 24             	mov    %eax,(%esp)
8010658c:	e8 72 bb ff ff       	call   80102103 <iunlockput>
    end_op(proc->cwd->part->number);
80106591:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106597:	8b 40 68             	mov    0x68(%eax),%eax
8010659a:	8b 40 50             	mov    0x50(%eax),%eax
8010659d:	8b 40 14             	mov    0x14(%eax),%eax
801065a0:	89 04 24             	mov    %eax,(%esp)
801065a3:	e8 68 d9 ff ff       	call   80103f10 <end_op>
    return -1;
801065a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065ad:	c9                   	leave  
801065ae:	c3                   	ret    

801065af <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801065af:	55                   	push   %ebp
801065b0:	89 e5                	mov    %esp,%ebp
801065b2:	83 ec 38             	sub    $0x38,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801065b5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801065bc:	eb 4b                	jmp    80106609 <isdirempty+0x5a>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801065c8:	00 
801065c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801065cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d4:	8b 45 08             	mov    0x8(%ebp),%eax
801065d7:	89 04 24             	mov    %eax,(%esp)
801065da:	e8 9e be ff ff       	call   8010247d <readi>
801065df:	83 f8 10             	cmp    $0x10,%eax
801065e2:	74 0c                	je     801065f0 <isdirempty+0x41>
            panic("isdirempty: readi");
801065e4:	c7 04 24 d0 97 10 80 	movl   $0x801097d0,(%esp)
801065eb:	e8 4a 9f ff ff       	call   8010053a <panic>
        if (de.inum != 0)
801065f0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801065f4:	66 85 c0             	test   %ax,%ax
801065f7:	74 07                	je     80106600 <isdirempty+0x51>
            return 0;
801065f9:	b8 00 00 00 00       	mov    $0x0,%eax
801065fe:	eb 1b                	jmp    8010661b <isdirempty+0x6c>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80106600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106603:	83 c0 10             	add    $0x10,%eax
80106606:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106609:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010660c:	8b 45 08             	mov    0x8(%ebp),%eax
8010660f:	8b 40 18             	mov    0x18(%eax),%eax
80106612:	39 c2                	cmp    %eax,%edx
80106614:	72 a8                	jb     801065be <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
80106616:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010661b:	c9                   	leave  
8010661c:	c3                   	ret    

8010661d <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
8010661d:	55                   	push   %ebp
8010661e:	89 e5                	mov    %esp,%ebp
80106620:	83 ec 48             	sub    $0x48,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106623:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106626:	89 44 24 04          	mov    %eax,0x4(%esp)
8010662a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106631:	e8 17 fa ff ff       	call   8010604d <argstr>
80106636:	85 c0                	test   %eax,%eax
80106638:	79 0a                	jns    80106644 <sys_unlink+0x27>
        return -1;
8010663a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663f:	e9 f7 01 00 00       	jmp    8010683b <sys_unlink+0x21e>

    begin_op(proc->cwd->part->number);
80106644:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664a:	8b 40 68             	mov    0x68(%eax),%eax
8010664d:	8b 40 50             	mov    0x50(%eax),%eax
80106650:	8b 40 14             	mov    0x14(%eax),%eax
80106653:	89 04 24             	mov    %eax,(%esp)
80106656:	e8 b3 d7 ff ff       	call   80103e0e <begin_op>
    if ((dp = nameiparent(path, name)) == 0) {
8010665b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010665e:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106661:	89 54 24 04          	mov    %edx,0x4(%esp)
80106665:	89 04 24             	mov    %eax,(%esp)
80106668:	e8 44 c6 ff ff       	call   80102cb1 <nameiparent>
8010666d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106674:	75 21                	jne    80106697 <sys_unlink+0x7a>
        end_op(proc->cwd->part->number);
80106676:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667c:	8b 40 68             	mov    0x68(%eax),%eax
8010667f:	8b 40 50             	mov    0x50(%eax),%eax
80106682:	8b 40 14             	mov    0x14(%eax),%eax
80106685:	89 04 24             	mov    %eax,(%esp)
80106688:	e8 83 d8 ff ff       	call   80103f10 <end_op>
        return -1;
8010668d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106692:	e9 a4 01 00 00       	jmp    8010683b <sys_unlink+0x21e>
    }

    ilock(dp);
80106697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669a:	89 04 24             	mov    %eax,(%esp)
8010669d:	e8 94 b7 ff ff       	call   80101e36 <ilock>

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801066a2:	c7 44 24 04 e2 97 10 	movl   $0x801097e2,0x4(%esp)
801066a9:	80 
801066aa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066ad:	89 04 24             	mov    %eax,(%esp)
801066b0:	e8 5e c1 ff ff       	call   80102813 <namecmp>
801066b5:	85 c0                	test   %eax,%eax
801066b7:	0f 84 57 01 00 00    	je     80106814 <sys_unlink+0x1f7>
801066bd:	c7 44 24 04 e4 97 10 	movl   $0x801097e4,0x4(%esp)
801066c4:	80 
801066c5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066c8:	89 04 24             	mov    %eax,(%esp)
801066cb:	e8 43 c1 ff ff       	call   80102813 <namecmp>
801066d0:	85 c0                	test   %eax,%eax
801066d2:	0f 84 3c 01 00 00    	je     80106814 <sys_unlink+0x1f7>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
801066d8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801066db:	89 44 24 08          	mov    %eax,0x8(%esp)
801066df:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e9:	89 04 24             	mov    %eax,(%esp)
801066ec:	e8 44 c1 ff ff       	call   80102835 <dirlookup>
801066f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066f8:	75 05                	jne    801066ff <sys_unlink+0xe2>
        goto bad;
801066fa:	e9 15 01 00 00       	jmp    80106814 <sys_unlink+0x1f7>
    ilock(ip);
801066ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106702:	89 04 24             	mov    %eax,(%esp)
80106705:	e8 2c b7 ff ff       	call   80101e36 <ilock>

    if (ip->nlink < 1)
8010670a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106711:	66 85 c0             	test   %ax,%ax
80106714:	7f 0c                	jg     80106722 <sys_unlink+0x105>
        panic("unlink: nlink < 1");
80106716:	c7 04 24 e7 97 10 80 	movl   $0x801097e7,(%esp)
8010671d:	e8 18 9e ff ff       	call   8010053a <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
80106722:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106725:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106729:	66 83 f8 01          	cmp    $0x1,%ax
8010672d:	75 1f                	jne    8010674e <sys_unlink+0x131>
8010672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106732:	89 04 24             	mov    %eax,(%esp)
80106735:	e8 75 fe ff ff       	call   801065af <isdirempty>
8010673a:	85 c0                	test   %eax,%eax
8010673c:	75 10                	jne    8010674e <sys_unlink+0x131>
        iunlockput(ip);
8010673e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106741:	89 04 24             	mov    %eax,(%esp)
80106744:	e8 ba b9 ff ff       	call   80102103 <iunlockput>
        goto bad;
80106749:	e9 c6 00 00 00       	jmp    80106814 <sys_unlink+0x1f7>
    }

    memset(&de, 0, sizeof(de));
8010674e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106755:	00 
80106756:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010675d:	00 
8010675e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106761:	89 04 24             	mov    %eax,(%esp)
80106764:	e8 12 f5 ff ff       	call   80105c7b <memset>
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106769:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010676c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106773:	00 
80106774:	89 44 24 08          	mov    %eax,0x8(%esp)
80106778:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010677b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010677f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106782:	89 04 24             	mov    %eax,(%esp)
80106785:	e8 a2 be ff ff       	call   8010262c <writei>
8010678a:	83 f8 10             	cmp    $0x10,%eax
8010678d:	74 0c                	je     8010679b <sys_unlink+0x17e>
        panic("unlink: writei");
8010678f:	c7 04 24 f9 97 10 80 	movl   $0x801097f9,(%esp)
80106796:	e8 9f 9d ff ff       	call   8010053a <panic>
    if (ip->type == T_DIR) {
8010679b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010679e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067a2:	66 83 f8 01          	cmp    $0x1,%ax
801067a6:	75 1c                	jne    801067c4 <sys_unlink+0x1a7>
        dp->nlink--;
801067a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ab:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067af:	8d 50 ff             	lea    -0x1(%eax),%edx
801067b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b5:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801067b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bc:	89 04 24             	mov    %eax,(%esp)
801067bf:	e8 2d b4 ff ff       	call   80101bf1 <iupdate>
    }
    iunlockput(dp);
801067c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c7:	89 04 24             	mov    %eax,(%esp)
801067ca:	e8 34 b9 ff ff       	call   80102103 <iunlockput>

    ip->nlink--;
801067cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801067d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067dc:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801067e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e3:	89 04 24             	mov    %eax,(%esp)
801067e6:	e8 06 b4 ff ff       	call   80101bf1 <iupdate>
    iunlockput(ip);
801067eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ee:	89 04 24             	mov    %eax,(%esp)
801067f1:	e8 0d b9 ff ff       	call   80102103 <iunlockput>

    end_op(proc->cwd->part->number);
801067f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067fc:	8b 40 68             	mov    0x68(%eax),%eax
801067ff:	8b 40 50             	mov    0x50(%eax),%eax
80106802:	8b 40 14             	mov    0x14(%eax),%eax
80106805:	89 04 24             	mov    %eax,(%esp)
80106808:	e8 03 d7 ff ff       	call   80103f10 <end_op>

    return 0;
8010680d:	b8 00 00 00 00       	mov    $0x0,%eax
80106812:	eb 27                	jmp    8010683b <sys_unlink+0x21e>

bad:
    iunlockput(dp);
80106814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106817:	89 04 24             	mov    %eax,(%esp)
8010681a:	e8 e4 b8 ff ff       	call   80102103 <iunlockput>
    end_op(proc->cwd->part->number);
8010681f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106825:	8b 40 68             	mov    0x68(%eax),%eax
80106828:	8b 40 50             	mov    0x50(%eax),%eax
8010682b:	8b 40 14             	mov    0x14(%eax),%eax
8010682e:	89 04 24             	mov    %eax,(%esp)
80106831:	e8 da d6 ff ff       	call   80103f10 <end_op>
    return -1;
80106836:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010683b:	c9                   	leave  
8010683c:	c3                   	ret    

8010683d <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
8010683d:	55                   	push   %ebp
8010683e:	89 e5                	mov    %esp,%ebp
80106840:	83 ec 48             	sub    $0x48,%esp
80106843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106846:	8b 55 10             	mov    0x10(%ebp),%edx
80106849:	8b 45 14             	mov    0x14(%ebp),%eax
8010684c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106850:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106854:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
    // cprintf("path %d  \n",path);
    if ((dp = nameiparent(path, name)) == 0)
80106858:	8d 45 de             	lea    -0x22(%ebp),%eax
8010685b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010685f:	8b 45 08             	mov    0x8(%ebp),%eax
80106862:	89 04 24             	mov    %eax,(%esp)
80106865:	e8 47 c4 ff ff       	call   80102cb1 <nameiparent>
8010686a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010686d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106871:	75 0a                	jne    8010687d <create+0x40>
        return 0;
80106873:	b8 00 00 00 00       	mov    $0x0,%eax
80106878:	e9 8d 01 00 00       	jmp    80106a0a <create+0x1cd>
    ilock(dp);
8010687d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106880:	89 04 24             	mov    %eax,(%esp)
80106883:	e8 ae b5 ff ff       	call   80101e36 <ilock>

    if ((ip = dirlookup(dp, name, &off)) != 0) {
80106888:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010688b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010688f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106892:	89 44 24 04          	mov    %eax,0x4(%esp)
80106896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106899:	89 04 24             	mov    %eax,(%esp)
8010689c:	e8 94 bf ff ff       	call   80102835 <dirlookup>
801068a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068a8:	74 47                	je     801068f1 <create+0xb4>
        iunlockput(dp);
801068aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ad:	89 04 24             	mov    %eax,(%esp)
801068b0:	e8 4e b8 ff ff       	call   80102103 <iunlockput>
        ilock(ip);
801068b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b8:	89 04 24             	mov    %eax,(%esp)
801068bb:	e8 76 b5 ff ff       	call   80101e36 <ilock>
        if (type == T_FILE && ip->type == T_FILE)
801068c0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801068c5:	75 15                	jne    801068dc <create+0x9f>
801068c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ca:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068ce:	66 83 f8 02          	cmp    $0x2,%ax
801068d2:	75 08                	jne    801068dc <create+0x9f>
            return ip;
801068d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068d7:	e9 2e 01 00 00       	jmp    80106a0a <create+0x1cd>
        iunlockput(ip);
801068dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068df:	89 04 24             	mov    %eax,(%esp)
801068e2:	e8 1c b8 ff ff       	call   80102103 <iunlockput>
        return 0;
801068e7:	b8 00 00 00 00       	mov    $0x0,%eax
801068ec:	e9 19 01 00 00       	jmp    80106a0a <create+0x1cd>
    }
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
801068f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f4:	8b 40 50             	mov    0x50(%eax),%eax
801068f7:	8b 40 14             	mov    0x14(%eax),%eax
801068fa:	89 c1                	mov    %eax,%ecx
801068fc:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106903:	8b 00                	mov    (%eax),%eax
80106905:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106909:	89 54 24 04          	mov    %edx,0x4(%esp)
8010690d:	89 04 24             	mov    %eax,(%esp)
80106910:	e8 be b1 ff ff       	call   80101ad3 <ialloc>
80106915:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106918:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010691c:	75 0c                	jne    8010692a <create+0xed>
        panic("create: ialloc");
8010691e:	c7 04 24 08 98 10 80 	movl   $0x80109808,(%esp)
80106925:	e8 10 9c ff ff       	call   8010053a <panic>

    ilock(ip);
8010692a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010692d:	89 04 24             	mov    %eax,(%esp)
80106930:	e8 01 b5 ff ff       	call   80101e36 <ilock>
    ip->major = major;
80106935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106938:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010693c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106943:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106947:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
8010694b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010694e:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    iupdate(ip);
80106954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106957:	89 04 24             	mov    %eax,(%esp)
8010695a:	e8 92 b2 ff ff       	call   80101bf1 <iupdate>

    if (type == T_DIR) { // Create . and .. entries.
8010695f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106964:	75 6a                	jne    801069d0 <create+0x193>
        dp->nlink++;     // for ".."
80106966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106969:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010696d:	8d 50 01             	lea    0x1(%eax),%edx
80106970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106973:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697a:	89 04 24             	mov    %eax,(%esp)
8010697d:	e8 6f b2 ff ff       	call   80101bf1 <iupdate>
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106985:	8b 40 04             	mov    0x4(%eax),%eax
80106988:	89 44 24 08          	mov    %eax,0x8(%esp)
8010698c:	c7 44 24 04 e2 97 10 	movl   $0x801097e2,0x4(%esp)
80106993:	80 
80106994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106997:	89 04 24             	mov    %eax,(%esp)
8010699a:	e8 6c bf ff ff       	call   8010290b <dirlink>
8010699f:	85 c0                	test   %eax,%eax
801069a1:	78 21                	js     801069c4 <create+0x187>
801069a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a6:	8b 40 04             	mov    0x4(%eax),%eax
801069a9:	89 44 24 08          	mov    %eax,0x8(%esp)
801069ad:	c7 44 24 04 e4 97 10 	movl   $0x801097e4,0x4(%esp)
801069b4:	80 
801069b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069b8:	89 04 24             	mov    %eax,(%esp)
801069bb:	e8 4b bf ff ff       	call   8010290b <dirlink>
801069c0:	85 c0                	test   %eax,%eax
801069c2:	79 0c                	jns    801069d0 <create+0x193>
            panic("create dots");
801069c4:	c7 04 24 17 98 10 80 	movl   $0x80109817,(%esp)
801069cb:	e8 6a 9b ff ff       	call   8010053a <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
801069d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d3:	8b 40 04             	mov    0x4(%eax),%eax
801069d6:	89 44 24 08          	mov    %eax,0x8(%esp)
801069da:	8d 45 de             	lea    -0x22(%ebp),%eax
801069dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e4:	89 04 24             	mov    %eax,(%esp)
801069e7:	e8 1f bf ff ff       	call   8010290b <dirlink>
801069ec:	85 c0                	test   %eax,%eax
801069ee:	79 0c                	jns    801069fc <create+0x1bf>
        panic("create: dirlink");
801069f0:	c7 04 24 23 98 10 80 	movl   $0x80109823,(%esp)
801069f7:	e8 3e 9b ff ff       	call   8010053a <panic>

    iunlockput(dp);
801069fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ff:	89 04 24             	mov    %eax,(%esp)
80106a02:	e8 fc b6 ff ff       	call   80102103 <iunlockput>

    return ip;
80106a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106a0a:	c9                   	leave  
80106a0b:	c3                   	ret    

80106a0c <sys_open>:

int sys_open(void)
{
80106a0c:	55                   	push   %ebp
80106a0d:	89 e5                	mov    %esp,%ebp
80106a0f:	83 ec 28             	sub    $0x28,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106a12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a15:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a20:	e8 28 f6 ff ff       	call   8010604d <argstr>
80106a25:	85 c0                	test   %eax,%eax
80106a27:	78 17                	js     80106a40 <sys_open+0x34>
80106a29:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a37:	e8 81 f5 ff ff       	call   80105fbd <argint>
80106a3c:	85 c0                	test   %eax,%eax
80106a3e:	79 07                	jns    80106a47 <sys_open+0x3b>
        return -1;
80106a40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a45:	eb 12                	jmp    80106a59 <sys_open+0x4d>

    return openFile(path, omode);
80106a47:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a51:	89 04 24             	mov    %eax,(%esp)
80106a54:	e8 02 00 00 00       	call   80106a5b <openFile>
}
80106a59:	c9                   	leave  
80106a5a:	c3                   	ret    

80106a5b <openFile>:

int openFile(char* path, int omode)
{
80106a5b:	55                   	push   %ebp
80106a5c:	89 e5                	mov    %esp,%ebp
80106a5e:	83 ec 28             	sub    $0x28,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106a61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a67:	8b 40 68             	mov    0x68(%eax),%eax
80106a6a:	8b 40 50             	mov    0x50(%eax),%eax
80106a6d:	8b 40 14             	mov    0x14(%eax),%eax
80106a70:	89 04 24             	mov    %eax,(%esp)
80106a73:	e8 96 d3 ff ff       	call   80103e0e <begin_op>

    if (omode & O_CREATE) {
80106a78:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a7b:	25 00 02 00 00       	and    $0x200,%eax
80106a80:	85 c0                	test   %eax,%eax
80106a82:	74 51                	je     80106ad5 <openFile+0x7a>
        ip = create(path, T_FILE, 0, 0);
80106a84:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106a8b:	00 
80106a8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106a93:	00 
80106a94:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106a9b:	00 
80106a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9f:	89 04 24             	mov    %eax,(%esp)
80106aa2:	e8 96 fd ff ff       	call   8010683d <create>
80106aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106aaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106aae:	0f 85 a0 00 00 00    	jne    80106b54 <openFile+0xf9>
            end_op(proc->cwd->part->number);
80106ab4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aba:	8b 40 68             	mov    0x68(%eax),%eax
80106abd:	8b 40 50             	mov    0x50(%eax),%eax
80106ac0:	8b 40 14             	mov    0x14(%eax),%eax
80106ac3:	89 04 24             	mov    %eax,(%esp)
80106ac6:	e8 45 d4 ff ff       	call   80103f10 <end_op>
            return -1;
80106acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad0:	e9 57 01 00 00       	jmp    80106c2c <openFile+0x1d1>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad8:	89 04 24             	mov    %eax,(%esp)
80106adb:	e8 7d c1 ff ff       	call   80102c5d <namei>
80106ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ae3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ae7:	75 21                	jne    80106b0a <openFile+0xaf>
            end_op(proc->cwd->part->number);
80106ae9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aef:	8b 40 68             	mov    0x68(%eax),%eax
80106af2:	8b 40 50             	mov    0x50(%eax),%eax
80106af5:	8b 40 14             	mov    0x14(%eax),%eax
80106af8:	89 04 24             	mov    %eax,(%esp)
80106afb:	e8 10 d4 ff ff       	call   80103f10 <end_op>
            return -1;
80106b00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b05:	e9 22 01 00 00       	jmp    80106c2c <openFile+0x1d1>
        }
        ilock(ip);
80106b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0d:	89 04 24             	mov    %eax,(%esp)
80106b10:	e8 21 b3 ff ff       	call   80101e36 <ilock>
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b18:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b1c:	66 83 f8 01          	cmp    $0x1,%ax
80106b20:	75 32                	jne    80106b54 <openFile+0xf9>
80106b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106b26:	74 2c                	je     80106b54 <openFile+0xf9>
            iunlockput(ip);
80106b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2b:	89 04 24             	mov    %eax,(%esp)
80106b2e:	e8 d0 b5 ff ff       	call   80102103 <iunlockput>
            end_op(proc->cwd->part->number);
80106b33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b39:	8b 40 68             	mov    0x68(%eax),%eax
80106b3c:	8b 40 50             	mov    0x50(%eax),%eax
80106b3f:	8b 40 14             	mov    0x14(%eax),%eax
80106b42:	89 04 24             	mov    %eax,(%esp)
80106b45:	e8 c6 d3 ff ff       	call   80103f10 <end_op>
            return -1;
80106b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b4f:	e9 d8 00 00 00       	jmp    80106c2c <openFile+0x1d1>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106b54:	e8 30 a4 ff ff       	call   80100f89 <filealloc>
80106b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b60:	74 14                	je     80106b76 <openFile+0x11b>
80106b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b65:	89 04 24             	mov    %eax,(%esp)
80106b68:	e8 1b f6 ff ff       	call   80106188 <fdalloc>
80106b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106b70:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106b74:	79 3a                	jns    80106bb0 <openFile+0x155>
        if (f)
80106b76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b7a:	74 0b                	je     80106b87 <openFile+0x12c>
            fileclose(f);
80106b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b7f:	89 04 24             	mov    %eax,(%esp)
80106b82:	e8 aa a4 ff ff       	call   80101031 <fileclose>
        iunlockput(ip);
80106b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8a:	89 04 24             	mov    %eax,(%esp)
80106b8d:	e8 71 b5 ff ff       	call   80102103 <iunlockput>
        end_op(proc->cwd->part->number);
80106b92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b98:	8b 40 68             	mov    0x68(%eax),%eax
80106b9b:	8b 40 50             	mov    0x50(%eax),%eax
80106b9e:	8b 40 14             	mov    0x14(%eax),%eax
80106ba1:	89 04 24             	mov    %eax,(%esp)
80106ba4:	e8 67 d3 ff ff       	call   80103f10 <end_op>
        return -1;
80106ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bae:	eb 7c                	jmp    80106c2c <openFile+0x1d1>
    }
    iunlock(ip);
80106bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb3:	89 04 24             	mov    %eax,(%esp)
80106bb6:	e8 12 b4 ff ff       	call   80101fcd <iunlock>
    end_op(proc->cwd->part->number);
80106bbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc1:	8b 40 68             	mov    0x68(%eax),%eax
80106bc4:	8b 40 50             	mov    0x50(%eax),%eax
80106bc7:	8b 40 14             	mov    0x14(%eax),%eax
80106bca:	89 04 24             	mov    %eax,(%esp)
80106bcd:	e8 3e d3 ff ff       	call   80103f10 <end_op>

    f->type = FD_INODE;
80106bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bd5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106be1:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106be7:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106bee:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bf1:	83 e0 01             	and    $0x1,%eax
80106bf4:	85 c0                	test   %eax,%eax
80106bf6:	0f 94 c0             	sete   %al
80106bf9:	89 c2                	mov    %eax,%edx
80106bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bfe:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c01:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c04:	83 e0 01             	and    $0x1,%eax
80106c07:	85 c0                	test   %eax,%eax
80106c09:	75 0a                	jne    80106c15 <openFile+0x1ba>
80106c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c0e:	83 e0 02             	and    $0x2,%eax
80106c11:	85 c0                	test   %eax,%eax
80106c13:	74 07                	je     80106c1c <openFile+0x1c1>
80106c15:	b8 01 00 00 00       	mov    $0x1,%eax
80106c1a:	eb 05                	jmp    80106c21 <openFile+0x1c6>
80106c1c:	b8 00 00 00 00       	mov    $0x0,%eax
80106c21:	89 c2                	mov    %eax,%edx
80106c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c26:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106c29:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106c2c:	c9                   	leave  
80106c2d:	c3                   	ret    

80106c2e <sys_mkdir>:

int sys_mkdir(void)
{
80106c2e:	55                   	push   %ebp
80106c2f:	89 e5                	mov    %esp,%ebp
80106c31:	83 ec 28             	sub    $0x28,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106c34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c3a:	8b 40 68             	mov    0x68(%eax),%eax
80106c3d:	8b 40 50             	mov    0x50(%eax),%eax
80106c40:	8b 40 14             	mov    0x14(%eax),%eax
80106c43:	89 04 24             	mov    %eax,(%esp)
80106c46:	e8 c3 d1 ff ff       	call   80103e0e <begin_op>
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106c4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c59:	e8 ef f3 ff ff       	call   8010604d <argstr>
80106c5e:	85 c0                	test   %eax,%eax
80106c60:	78 2c                	js     80106c8e <sys_mkdir+0x60>
80106c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106c6c:	00 
80106c6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106c74:	00 
80106c75:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106c7c:	00 
80106c7d:	89 04 24             	mov    %eax,(%esp)
80106c80:	e8 b8 fb ff ff       	call   8010683d <create>
80106c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c8c:	75 1e                	jne    80106cac <sys_mkdir+0x7e>
        end_op(proc->cwd->part->number);
80106c8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c94:	8b 40 68             	mov    0x68(%eax),%eax
80106c97:	8b 40 50             	mov    0x50(%eax),%eax
80106c9a:	8b 40 14             	mov    0x14(%eax),%eax
80106c9d:	89 04 24             	mov    %eax,(%esp)
80106ca0:	e8 6b d2 ff ff       	call   80103f10 <end_op>
        return -1;
80106ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106caa:	eb 27                	jmp    80106cd3 <sys_mkdir+0xa5>
    }
    iunlockput(ip);
80106cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106caf:	89 04 24             	mov    %eax,(%esp)
80106cb2:	e8 4c b4 ff ff       	call   80102103 <iunlockput>
    end_op(proc->cwd->part->number);
80106cb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cbd:	8b 40 68             	mov    0x68(%eax),%eax
80106cc0:	8b 40 50             	mov    0x50(%eax),%eax
80106cc3:	8b 40 14             	mov    0x14(%eax),%eax
80106cc6:	89 04 24             	mov    %eax,(%esp)
80106cc9:	e8 42 d2 ff ff       	call   80103f10 <end_op>
    return 0;
80106cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cd3:	c9                   	leave  
80106cd4:	c3                   	ret    

80106cd5 <sys_mknod>:

int sys_mknod(void)
{
80106cd5:	55                   	push   %ebp
80106cd6:	89 e5                	mov    %esp,%ebp
80106cd8:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106cdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce1:	8b 40 68             	mov    0x68(%eax),%eax
80106ce4:	8b 40 50             	mov    0x50(%eax),%eax
80106ce7:	8b 40 14             	mov    0x14(%eax),%eax
80106cea:	89 04 24             	mov    %eax,(%esp)
80106ced:	e8 1c d1 ff ff       	call   80103e0e <begin_op>
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106cf2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d00:	e8 48 f3 ff ff       	call   8010604d <argstr>
80106d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d0c:	78 5e                	js     80106d6c <sys_mknod+0x97>
80106d0e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d11:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d1c:	e8 9c f2 ff ff       	call   80105fbd <argint>
80106d21:	85 c0                	test   %eax,%eax
80106d23:	78 47                	js     80106d6c <sys_mknod+0x97>
80106d25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d28:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d2c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106d33:	e8 85 f2 ff ff       	call   80105fbd <argint>
80106d38:	85 c0                	test   %eax,%eax
80106d3a:	78 30                	js     80106d6c <sys_mknod+0x97>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d3f:	0f bf c8             	movswl %ax,%ecx
80106d42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d45:	0f bf d0             	movswl %ax,%edx
80106d48:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106d4b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d4f:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d53:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106d5a:	00 
80106d5b:	89 04 24             	mov    %eax,(%esp)
80106d5e:	e8 da fa ff ff       	call   8010683d <create>
80106d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d6a:	75 1e                	jne    80106d8a <sys_mknod+0xb5>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106d6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d72:	8b 40 68             	mov    0x68(%eax),%eax
80106d75:	8b 40 50             	mov    0x50(%eax),%eax
80106d78:	8b 40 14             	mov    0x14(%eax),%eax
80106d7b:	89 04 24             	mov    %eax,(%esp)
80106d7e:	e8 8d d1 ff ff       	call   80103f10 <end_op>
        return -1;
80106d83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d88:	eb 27                	jmp    80106db1 <sys_mknod+0xdc>
    }
    iunlockput(ip);
80106d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d8d:	89 04 24             	mov    %eax,(%esp)
80106d90:	e8 6e b3 ff ff       	call   80102103 <iunlockput>
    end_op(proc->cwd->part->number);
80106d95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d9b:	8b 40 68             	mov    0x68(%eax),%eax
80106d9e:	8b 40 50             	mov    0x50(%eax),%eax
80106da1:	8b 40 14             	mov    0x14(%eax),%eax
80106da4:	89 04 24             	mov    %eax,(%esp)
80106da7:	e8 64 d1 ff ff       	call   80103f10 <end_op>
    return 0;
80106dac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106db1:	c9                   	leave  
80106db2:	c3                   	ret    

80106db3 <sys_chdir>:

int sys_chdir(void)
{
80106db3:	55                   	push   %ebp
80106db4:	89 e5                	mov    %esp,%ebp
80106db6:	83 ec 28             	sub    $0x28,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106db9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dbf:	8b 40 68             	mov    0x68(%eax),%eax
80106dc2:	8b 40 50             	mov    0x50(%eax),%eax
80106dc5:	8b 40 14             	mov    0x14(%eax),%eax
80106dc8:	89 04 24             	mov    %eax,(%esp)
80106dcb:	e8 3e d0 ff ff       	call   80103e0e <begin_op>
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106dd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dde:	e8 6a f2 ff ff       	call   8010604d <argstr>
80106de3:	85 c0                	test   %eax,%eax
80106de5:	78 14                	js     80106dfb <sys_chdir+0x48>
80106de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dea:	89 04 24             	mov    %eax,(%esp)
80106ded:	e8 6b be ff ff       	call   80102c5d <namei>
80106df2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106df5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106df9:	75 21                	jne    80106e1c <sys_chdir+0x69>
        end_op(proc->cwd->part->number);
80106dfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e01:	8b 40 68             	mov    0x68(%eax),%eax
80106e04:	8b 40 50             	mov    0x50(%eax),%eax
80106e07:	8b 40 14             	mov    0x14(%eax),%eax
80106e0a:	89 04 24             	mov    %eax,(%esp)
80106e0d:	e8 fe d0 ff ff       	call   80103f10 <end_op>
        return -1;
80106e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e17:	e9 85 00 00 00       	jmp    80106ea1 <sys_chdir+0xee>
    }
    ilock(ip);
80106e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e1f:	89 04 24             	mov    %eax,(%esp)
80106e22:	e8 0f b0 ff ff       	call   80101e36 <ilock>
    if (ip->type != T_DIR) {
80106e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e2a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106e2e:	66 83 f8 01          	cmp    $0x1,%ax
80106e32:	74 29                	je     80106e5d <sys_chdir+0xaa>
        iunlockput(ip);
80106e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e37:	89 04 24             	mov    %eax,(%esp)
80106e3a:	e8 c4 b2 ff ff       	call   80102103 <iunlockput>
        end_op(proc->cwd->part->number);
80106e3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e45:	8b 40 68             	mov    0x68(%eax),%eax
80106e48:	8b 40 50             	mov    0x50(%eax),%eax
80106e4b:	8b 40 14             	mov    0x14(%eax),%eax
80106e4e:	89 04 24             	mov    %eax,(%esp)
80106e51:	e8 ba d0 ff ff       	call   80103f10 <end_op>
        return -1;
80106e56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e5b:	eb 44                	jmp    80106ea1 <sys_chdir+0xee>
    }
    iunlock(ip);
80106e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e60:	89 04 24             	mov    %eax,(%esp)
80106e63:	e8 65 b1 ff ff       	call   80101fcd <iunlock>
    iput(proc->cwd);
80106e68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e6e:	8b 40 68             	mov    0x68(%eax),%eax
80106e71:	89 04 24             	mov    %eax,(%esp)
80106e74:	e8 b9 b1 ff ff       	call   80102032 <iput>
    end_op(proc->cwd->part->number);
80106e79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e7f:	8b 40 68             	mov    0x68(%eax),%eax
80106e82:	8b 40 50             	mov    0x50(%eax),%eax
80106e85:	8b 40 14             	mov    0x14(%eax),%eax
80106e88:	89 04 24             	mov    %eax,(%esp)
80106e8b:	e8 80 d0 ff ff       	call   80103f10 <end_op>
    proc->cwd = ip;
80106e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e99:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
80106e9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ea1:	c9                   	leave  
80106ea2:	c3                   	ret    

80106ea3 <sys_exec>:

int sys_exec(void)
{
80106ea3:	55                   	push   %ebp
80106ea4:	89 e5                	mov    %esp,%ebp
80106ea6:	81 ec a8 00 00 00    	sub    $0xa8,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
80106eac:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106eb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106eba:	e8 8e f1 ff ff       	call   8010604d <argstr>
80106ebf:	85 c0                	test   %eax,%eax
80106ec1:	78 1a                	js     80106edd <sys_exec+0x3a>
80106ec3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ecd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106ed4:	e8 e4 f0 ff ff       	call   80105fbd <argint>
80106ed9:	85 c0                	test   %eax,%eax
80106edb:	79 0a                	jns    80106ee7 <sys_exec+0x44>
        return -1;
80106edd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ee2:	e9 c8 00 00 00       	jmp    80106faf <sys_exec+0x10c>
    }
    memset(argv, 0, sizeof(argv));
80106ee7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106eee:	00 
80106eef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ef6:	00 
80106ef7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106efd:	89 04 24             	mov    %eax,(%esp)
80106f00:	e8 76 ed ff ff       	call   80105c7b <memset>
    for (i = 0;; i++) {
80106f05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
80106f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0f:	83 f8 1f             	cmp    $0x1f,%eax
80106f12:	76 0a                	jbe    80106f1e <sys_exec+0x7b>
            return -1;
80106f14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f19:	e9 91 00 00 00       	jmp    80106faf <sys_exec+0x10c>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
80106f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f21:	c1 e0 02             	shl    $0x2,%eax
80106f24:	89 c2                	mov    %eax,%edx
80106f26:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106f2c:	01 c2                	add    %eax,%edx
80106f2e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106f34:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f38:	89 14 24             	mov    %edx,(%esp)
80106f3b:	e8 e1 ef ff ff       	call   80105f21 <fetchint>
80106f40:	85 c0                	test   %eax,%eax
80106f42:	79 07                	jns    80106f4b <sys_exec+0xa8>
            return -1;
80106f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f49:	eb 64                	jmp    80106faf <sys_exec+0x10c>
        if (uarg == 0) {
80106f4b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f51:	85 c0                	test   %eax,%eax
80106f53:	75 26                	jne    80106f7b <sys_exec+0xd8>
            argv[i] = 0;
80106f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f58:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106f5f:	00 00 00 00 
            break;
80106f63:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
80106f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f67:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f6d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f71:	89 04 24             	mov    %eax,(%esp)
80106f74:	e8 91 9b ff ff       	call   80100b0a <exec>
80106f79:	eb 34                	jmp    80106faf <sys_exec+0x10c>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80106f7b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f84:	c1 e2 02             	shl    $0x2,%edx
80106f87:	01 c2                	add    %eax,%edx
80106f89:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f93:	89 04 24             	mov    %eax,(%esp)
80106f96:	e8 c0 ef ff ff       	call   80105f5b <fetchstr>
80106f9b:	85 c0                	test   %eax,%eax
80106f9d:	79 07                	jns    80106fa6 <sys_exec+0x103>
            return -1;
80106f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa4:	eb 09                	jmp    80106faf <sys_exec+0x10c>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
80106fa6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
80106faa:	e9 5d ff ff ff       	jmp    80106f0c <sys_exec+0x69>
    return exec(path, argv);
}
80106faf:	c9                   	leave  
80106fb0:	c3                   	ret    

80106fb1 <sys_pipe>:

int sys_pipe(void)
{
80106fb1:	55                   	push   %ebp
80106fb2:	89 e5                	mov    %esp,%ebp
80106fb4:	83 ec 38             	sub    $0x38,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
80106fb7:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106fbe:	00 
80106fbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fcd:	e8 19 f0 ff ff       	call   80105feb <argptr>
80106fd2:	85 c0                	test   %eax,%eax
80106fd4:	79 0a                	jns    80106fe0 <sys_pipe+0x2f>
        return -1;
80106fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fdb:	e9 9b 00 00 00       	jmp    8010707b <sys_pipe+0xca>
    if (pipealloc(&rf, &wf) < 0)
80106fe0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fe7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106fea:	89 04 24             	mov    %eax,(%esp)
80106fed:	e8 f9 da ff ff       	call   80104aeb <pipealloc>
80106ff2:	85 c0                	test   %eax,%eax
80106ff4:	79 07                	jns    80106ffd <sys_pipe+0x4c>
        return -1;
80106ff6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ffb:	eb 7e                	jmp    8010707b <sys_pipe+0xca>
    fd0 = -1;
80106ffd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80107004:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107007:	89 04 24             	mov    %eax,(%esp)
8010700a:	e8 79 f1 ff ff       	call   80106188 <fdalloc>
8010700f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107012:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107016:	78 14                	js     8010702c <sys_pipe+0x7b>
80107018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010701b:	89 04 24             	mov    %eax,(%esp)
8010701e:	e8 65 f1 ff ff       	call   80106188 <fdalloc>
80107023:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107026:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010702a:	79 37                	jns    80107063 <sys_pipe+0xb2>
        if (fd0 >= 0)
8010702c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107030:	78 14                	js     80107046 <sys_pipe+0x95>
            proc->ofile[fd0] = 0;
80107032:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107038:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010703b:	83 c2 08             	add    $0x8,%edx
8010703e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107045:	00 
        fileclose(rf);
80107046:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107049:	89 04 24             	mov    %eax,(%esp)
8010704c:	e8 e0 9f ff ff       	call   80101031 <fileclose>
        fileclose(wf);
80107051:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107054:	89 04 24             	mov    %eax,(%esp)
80107057:	e8 d5 9f ff ff       	call   80101031 <fileclose>
        return -1;
8010705c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107061:	eb 18                	jmp    8010707b <sys_pipe+0xca>
    }
    fd[0] = fd0;
80107063:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107066:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107069:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
8010706b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010706e:	8d 50 04             	lea    0x4(%eax),%edx
80107071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107074:	89 02                	mov    %eax,(%edx)
    return 0;
80107076:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010707b:	c9                   	leave  
8010707c:	c3                   	ret    

8010707d <sys_mount>:

int sys_mount(void)
{
8010707d:	55                   	push   %ebp
8010707e:	89 e5                	mov    %esp,%ebp
80107080:	83 ec 28             	sub    $0x28,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
80107083:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107086:	89 44 24 04          	mov    %eax,0x4(%esp)
8010708a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107091:	e8 b7 ef ff ff       	call   8010604d <argstr>
80107096:	85 c0                	test   %eax,%eax
80107098:	78 1f                	js     801070b9 <sys_mount+0x3c>
8010709a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010709d:	89 44 24 04          	mov    %eax,0x4(%esp)
801070a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801070a8:	e8 10 ef ff ff       	call   80105fbd <argint>
801070ad:	85 c0                	test   %eax,%eax
801070af:	78 08                	js     801070b9 <sys_mount+0x3c>
801070b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070b4:	83 f8 04             	cmp    $0x4,%eax
801070b7:	76 07                	jbe    801070c0 <sys_mount+0x43>
        return -1;
801070b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070be:	eb 4b                	jmp    8010710b <sys_mount+0x8e>
    }

    i=nameiIgnoreMounts(path);
801070c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070c3:	89 04 24             	mov    %eax,(%esp)
801070c6:	e8 bc bb ff ff       	call   80102c87 <nameiIgnoreMounts>
801070cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
801070ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070d2:	75 07                	jne    801070db <sys_mount+0x5e>
        return -1;
801070d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d9:	eb 30                	jmp    8010710b <sys_mount+0x8e>
    }
    ilock(i);
801070db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070de:	89 04 24             	mov    %eax,(%esp)
801070e1:	e8 50 ad ff ff       	call   80101e36 <ilock>
    i->major=MOUNTING_POINT;
801070e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e9:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
801070ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070f2:	89 c2                	mov    %eax,%edx
801070f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f7:	66 89 50 14          	mov    %dx,0x14(%eax)
    iunlockput(i);
801070fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fe:	89 04 24             	mov    %eax,(%esp)
80107101:	e8 fd af ff ff       	call   80102103 <iunlockput>
    return 0;
80107106:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010710b:	c9                   	leave  
8010710c:	c3                   	ret    

8010710d <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010710d:	55                   	push   %ebp
8010710e:	89 e5                	mov    %esp,%ebp
80107110:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107113:	e8 7e e0 ff ff       	call   80105196 <fork>
}
80107118:	c9                   	leave  
80107119:	c3                   	ret    

8010711a <sys_exit>:

int
sys_exit(void)
{
8010711a:	55                   	push   %ebp
8010711b:	89 e5                	mov    %esp,%ebp
8010711d:	83 ec 08             	sub    $0x8,%esp
  exit();
80107120:	e8 ec e1 ff ff       	call   80105311 <exit>
  return 0;  // not reached
80107125:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010712a:	c9                   	leave  
8010712b:	c3                   	ret    

8010712c <sys_wait>:

int
sys_wait(void)
{
8010712c:	55                   	push   %ebp
8010712d:	89 e5                	mov    %esp,%ebp
8010712f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107132:	e8 20 e3 ff ff       	call   80105457 <wait>
}
80107137:	c9                   	leave  
80107138:	c3                   	ret    

80107139 <sys_kill>:

int
sys_kill(void)
{
80107139:	55                   	push   %ebp
8010713a:	89 e5                	mov    %esp,%ebp
8010713c:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010713f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107142:	89 44 24 04          	mov    %eax,0x4(%esp)
80107146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010714d:	e8 6b ee ff ff       	call   80105fbd <argint>
80107152:	85 c0                	test   %eax,%eax
80107154:	79 07                	jns    8010715d <sys_kill+0x24>
    return -1;
80107156:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010715b:	eb 0b                	jmp    80107168 <sys_kill+0x2f>
  return kill(pid);
8010715d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107160:	89 04 24             	mov    %eax,(%esp)
80107163:	e8 f9 e6 ff ff       	call   80105861 <kill>
}
80107168:	c9                   	leave  
80107169:	c3                   	ret    

8010716a <sys_getpid>:

int
sys_getpid(void)
{
8010716a:	55                   	push   %ebp
8010716b:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010716d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107173:	8b 40 10             	mov    0x10(%eax),%eax
}
80107176:	5d                   	pop    %ebp
80107177:	c3                   	ret    

80107178 <sys_sbrk>:

int
sys_sbrk(void)
{
80107178:	55                   	push   %ebp
80107179:	89 e5                	mov    %esp,%ebp
8010717b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010717e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107181:	89 44 24 04          	mov    %eax,0x4(%esp)
80107185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010718c:	e8 2c ee ff ff       	call   80105fbd <argint>
80107191:	85 c0                	test   %eax,%eax
80107193:	79 07                	jns    8010719c <sys_sbrk+0x24>
    return -1;
80107195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010719a:	eb 24                	jmp    801071c0 <sys_sbrk+0x48>
  addr = proc->sz;
8010719c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071a2:	8b 00                	mov    (%eax),%eax
801071a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801071a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071aa:	89 04 24             	mov    %eax,(%esp)
801071ad:	e8 3f df ff ff       	call   801050f1 <growproc>
801071b2:	85 c0                	test   %eax,%eax
801071b4:	79 07                	jns    801071bd <sys_sbrk+0x45>
    return -1;
801071b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071bb:	eb 03                	jmp    801071c0 <sys_sbrk+0x48>
  return addr;
801071bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801071c0:	c9                   	leave  
801071c1:	c3                   	ret    

801071c2 <sys_sleep>:

int
sys_sleep(void)
{
801071c2:	55                   	push   %ebp
801071c3:	89 e5                	mov    %esp,%ebp
801071c5:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801071c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801071cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071d6:	e8 e2 ed ff ff       	call   80105fbd <argint>
801071db:	85 c0                	test   %eax,%eax
801071dd:	79 07                	jns    801071e6 <sys_sleep+0x24>
    return -1;
801071df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e4:	eb 6c                	jmp    80107252 <sys_sleep+0x90>
  acquire(&tickslock);
801071e6:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
801071ed:	e8 35 e8 ff ff       	call   80105a27 <acquire>
  ticks0 = ticks;
801071f2:	a1 00 66 11 80       	mov    0x80116600,%eax
801071f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801071fa:	eb 34                	jmp    80107230 <sys_sleep+0x6e>
    if(proc->killed){
801071fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107202:	8b 40 24             	mov    0x24(%eax),%eax
80107205:	85 c0                	test   %eax,%eax
80107207:	74 13                	je     8010721c <sys_sleep+0x5a>
      release(&tickslock);
80107209:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
80107210:	e8 74 e8 ff ff       	call   80105a89 <release>
      return -1;
80107215:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010721a:	eb 36                	jmp    80107252 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010721c:	c7 44 24 04 c0 5d 11 	movl   $0x80115dc0,0x4(%esp)
80107223:	80 
80107224:	c7 04 24 00 66 11 80 	movl   $0x80116600,(%esp)
8010722b:	e8 2d e5 ff ff       	call   8010575d <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107230:	a1 00 66 11 80       	mov    0x80116600,%eax
80107235:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107238:	89 c2                	mov    %eax,%edx
8010723a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010723d:	39 c2                	cmp    %eax,%edx
8010723f:	72 bb                	jb     801071fc <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107241:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
80107248:	e8 3c e8 ff ff       	call   80105a89 <release>
  return 0;
8010724d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107252:	c9                   	leave  
80107253:	c3                   	ret    

80107254 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107254:	55                   	push   %ebp
80107255:	89 e5                	mov    %esp,%ebp
80107257:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010725a:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
80107261:	e8 c1 e7 ff ff       	call   80105a27 <acquire>
  xticks = ticks;
80107266:	a1 00 66 11 80       	mov    0x80116600,%eax
8010726b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010726e:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
80107275:	e8 0f e8 ff ff       	call   80105a89 <release>
  return xticks;
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010727d:	c9                   	leave  
8010727e:	c3                   	ret    

8010727f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010727f:	55                   	push   %ebp
80107280:	89 e5                	mov    %esp,%ebp
80107282:	83 ec 08             	sub    $0x8,%esp
80107285:	8b 55 08             	mov    0x8(%ebp),%edx
80107288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010728b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010728f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107292:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107296:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010729a:	ee                   	out    %al,(%dx)
}
8010729b:	c9                   	leave  
8010729c:	c3                   	ret    

8010729d <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010729d:	55                   	push   %ebp
8010729e:	89 e5                	mov    %esp,%ebp
801072a0:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801072a3:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801072aa:	00 
801072ab:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801072b2:	e8 c8 ff ff ff       	call   8010727f <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801072b7:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801072be:	00 
801072bf:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801072c6:	e8 b4 ff ff ff       	call   8010727f <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801072cb:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801072d2:	00 
801072d3:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801072da:	e8 a0 ff ff ff       	call   8010727f <outb>
  picenable(IRQ_TIMER);
801072df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801072e6:	e8 93 d6 ff ff       	call   8010497e <picenable>
}
801072eb:	c9                   	leave  
801072ec:	c3                   	ret    

801072ed <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801072ed:	1e                   	push   %ds
  pushl %es
801072ee:	06                   	push   %es
  pushl %fs
801072ef:	0f a0                	push   %fs
  pushl %gs
801072f1:	0f a8                	push   %gs
  pushal
801072f3:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801072f4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801072f8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801072fa:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801072fc:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107300:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107302:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107304:	54                   	push   %esp
  call trap
80107305:	e8 d8 01 00 00       	call   801074e2 <trap>
  addl $4, %esp
8010730a:	83 c4 04             	add    $0x4,%esp

8010730d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010730d:	61                   	popa   
  popl %gs
8010730e:	0f a9                	pop    %gs
  popl %fs
80107310:	0f a1                	pop    %fs
  popl %es
80107312:	07                   	pop    %es
  popl %ds
80107313:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107314:	83 c4 08             	add    $0x8,%esp
  iret
80107317:	cf                   	iret   

80107318 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107318:	55                   	push   %ebp
80107319:	89 e5                	mov    %esp,%ebp
8010731b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010731e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107321:	83 e8 01             	sub    $0x1,%eax
80107324:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107328:	8b 45 08             	mov    0x8(%ebp),%eax
8010732b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010732f:	8b 45 08             	mov    0x8(%ebp),%eax
80107332:	c1 e8 10             	shr    $0x10,%eax
80107335:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107339:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010733c:	0f 01 18             	lidtl  (%eax)
}
8010733f:	c9                   	leave  
80107340:	c3                   	ret    

80107341 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107341:	55                   	push   %ebp
80107342:	89 e5                	mov    %esp,%ebp
80107344:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107347:	0f 20 d0             	mov    %cr2,%eax
8010734a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010734d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107350:	c9                   	leave  
80107351:	c3                   	ret    

80107352 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107352:	55                   	push   %ebp
80107353:	89 e5                	mov    %esp,%ebp
80107355:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107358:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010735f:	e9 c3 00 00 00       	jmp    80107427 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010736e:	89 c2                	mov    %eax,%edx
80107370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107373:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
8010737a:	80 
8010737b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737e:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
80107385:	80 08 00 
80107388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738b:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107392:	80 
80107393:	83 e2 e0             	and    $0xffffffe0,%edx
80107396:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
8010739d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a0:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
801073a7:	80 
801073a8:	83 e2 1f             	and    $0x1f,%edx
801073ab:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
801073b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b5:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801073bc:	80 
801073bd:	83 e2 f0             	and    $0xfffffff0,%edx
801073c0:	83 ca 0e             	or     $0xe,%edx
801073c3:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801073ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cd:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801073d4:	80 
801073d5:	83 e2 ef             	and    $0xffffffef,%edx
801073d8:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801073df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e2:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801073e9:	80 
801073ea:	83 e2 9f             	and    $0xffffff9f,%edx
801073ed:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801073f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f7:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801073fe:	80 
801073ff:	83 ca 80             	or     $0xffffff80,%edx
80107402:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740c:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
80107413:	c1 e8 10             	shr    $0x10,%eax
80107416:	89 c2                	mov    %eax,%edx
80107418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741b:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
80107422:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107423:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107427:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010742e:	0f 8e 30 ff ff ff    	jle    80107364 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107434:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107439:	66 a3 00 60 11 80    	mov    %ax,0x80116000
8010743f:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
80107446:	08 00 
80107448:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
8010744f:	83 e0 e0             	and    $0xffffffe0,%eax
80107452:	a2 04 60 11 80       	mov    %al,0x80116004
80107457:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
8010745e:	83 e0 1f             	and    $0x1f,%eax
80107461:	a2 04 60 11 80       	mov    %al,0x80116004
80107466:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010746d:	83 c8 0f             	or     $0xf,%eax
80107470:	a2 05 60 11 80       	mov    %al,0x80116005
80107475:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010747c:	83 e0 ef             	and    $0xffffffef,%eax
8010747f:	a2 05 60 11 80       	mov    %al,0x80116005
80107484:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010748b:	83 c8 60             	or     $0x60,%eax
8010748e:	a2 05 60 11 80       	mov    %al,0x80116005
80107493:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010749a:	83 c8 80             	or     $0xffffff80,%eax
8010749d:	a2 05 60 11 80       	mov    %al,0x80116005
801074a2:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
801074a7:	c1 e8 10             	shr    $0x10,%eax
801074aa:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
801074b0:	c7 44 24 04 34 98 10 	movl   $0x80109834,0x4(%esp)
801074b7:	80 
801074b8:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
801074bf:	e8 42 e5 ff ff       	call   80105a06 <initlock>
}
801074c4:	c9                   	leave  
801074c5:	c3                   	ret    

801074c6 <idtinit>:

void
idtinit(void)
{
801074c6:	55                   	push   %ebp
801074c7:	89 e5                	mov    %esp,%ebp
801074c9:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801074cc:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801074d3:	00 
801074d4:	c7 04 24 00 5e 11 80 	movl   $0x80115e00,(%esp)
801074db:	e8 38 fe ff ff       	call   80107318 <lidt>
}
801074e0:	c9                   	leave  
801074e1:	c3                   	ret    

801074e2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801074e2:	55                   	push   %ebp
801074e3:	89 e5                	mov    %esp,%ebp
801074e5:	57                   	push   %edi
801074e6:	56                   	push   %esi
801074e7:	53                   	push   %ebx
801074e8:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801074eb:	8b 45 08             	mov    0x8(%ebp),%eax
801074ee:	8b 40 30             	mov    0x30(%eax),%eax
801074f1:	83 f8 40             	cmp    $0x40,%eax
801074f4:	75 3f                	jne    80107535 <trap+0x53>
    if(proc->killed)
801074f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074fc:	8b 40 24             	mov    0x24(%eax),%eax
801074ff:	85 c0                	test   %eax,%eax
80107501:	74 05                	je     80107508 <trap+0x26>
      exit();
80107503:	e8 09 de ff ff       	call   80105311 <exit>
    proc->tf = tf;
80107508:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010750e:	8b 55 08             	mov    0x8(%ebp),%edx
80107511:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107514:	e8 6b eb ff ff       	call   80106084 <syscall>
    if(proc->killed)
80107519:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010751f:	8b 40 24             	mov    0x24(%eax),%eax
80107522:	85 c0                	test   %eax,%eax
80107524:	74 0a                	je     80107530 <trap+0x4e>
      exit();
80107526:	e8 e6 dd ff ff       	call   80105311 <exit>
    return;
8010752b:	e9 2d 02 00 00       	jmp    8010775d <trap+0x27b>
80107530:	e9 28 02 00 00       	jmp    8010775d <trap+0x27b>
  }

  switch(tf->trapno){
80107535:	8b 45 08             	mov    0x8(%ebp),%eax
80107538:	8b 40 30             	mov    0x30(%eax),%eax
8010753b:	83 e8 20             	sub    $0x20,%eax
8010753e:	83 f8 1f             	cmp    $0x1f,%eax
80107541:	0f 87 bc 00 00 00    	ja     80107603 <trap+0x121>
80107547:	8b 04 85 dc 98 10 80 	mov    -0x7fef6724(,%eax,4),%eax
8010754e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107550:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107556:	0f b6 00             	movzbl (%eax),%eax
80107559:	84 c0                	test   %al,%al
8010755b:	75 31                	jne    8010758e <trap+0xac>
      acquire(&tickslock);
8010755d:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
80107564:	e8 be e4 ff ff       	call   80105a27 <acquire>
      ticks++;
80107569:	a1 00 66 11 80       	mov    0x80116600,%eax
8010756e:	83 c0 01             	add    $0x1,%eax
80107571:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
80107576:	c7 04 24 00 66 11 80 	movl   $0x80116600,(%esp)
8010757d:	e8 b4 e2 ff ff       	call   80105836 <wakeup>
      release(&tickslock);
80107582:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
80107589:	e8 fb e4 ff ff       	call   80105a89 <release>
    }
    lapiceoi();
8010758e:	e8 1d c2 ff ff       	call   801037b0 <lapiceoi>
    break;
80107593:	e9 41 01 00 00       	jmp    801076d9 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107598:	e8 15 ba ff ff       	call   80102fb2 <ideintr>
    lapiceoi();
8010759d:	e8 0e c2 ff ff       	call   801037b0 <lapiceoi>
    break;
801075a2:	e9 32 01 00 00       	jmp    801076d9 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801075a7:	e8 d3 bf ff ff       	call   8010357f <kbdintr>
    lapiceoi();
801075ac:	e8 ff c1 ff ff       	call   801037b0 <lapiceoi>
    break;
801075b1:	e9 23 01 00 00       	jmp    801076d9 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075b6:	e8 97 03 00 00       	call   80107952 <uartintr>
    lapiceoi();
801075bb:	e8 f0 c1 ff ff       	call   801037b0 <lapiceoi>
    break;
801075c0:	e9 14 01 00 00       	jmp    801076d9 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075c5:	8b 45 08             	mov    0x8(%ebp),%eax
801075c8:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801075cb:	8b 45 08             	mov    0x8(%ebp),%eax
801075ce:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075d2:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801075d5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075db:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075de:	0f b6 c0             	movzbl %al,%eax
801075e1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801075e5:	89 54 24 08          	mov    %edx,0x8(%esp)
801075e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801075ed:	c7 04 24 3c 98 10 80 	movl   $0x8010983c,(%esp)
801075f4:	e8 a7 8d ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801075f9:	e8 b2 c1 ff ff       	call   801037b0 <lapiceoi>
    break;
801075fe:	e9 d6 00 00 00       	jmp    801076d9 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107603:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107609:	85 c0                	test   %eax,%eax
8010760b:	74 11                	je     8010761e <trap+0x13c>
8010760d:	8b 45 08             	mov    0x8(%ebp),%eax
80107610:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107614:	0f b7 c0             	movzwl %ax,%eax
80107617:	83 e0 03             	and    $0x3,%eax
8010761a:	85 c0                	test   %eax,%eax
8010761c:	75 46                	jne    80107664 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010761e:	e8 1e fd ff ff       	call   80107341 <rcr2>
80107623:	8b 55 08             	mov    0x8(%ebp),%edx
80107626:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107629:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107630:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107633:	0f b6 ca             	movzbl %dl,%ecx
80107636:	8b 55 08             	mov    0x8(%ebp),%edx
80107639:	8b 52 30             	mov    0x30(%edx),%edx
8010763c:	89 44 24 10          	mov    %eax,0x10(%esp)
80107640:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107644:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107648:	89 54 24 04          	mov    %edx,0x4(%esp)
8010764c:	c7 04 24 60 98 10 80 	movl   $0x80109860,(%esp)
80107653:	e8 48 8d ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107658:	c7 04 24 92 98 10 80 	movl   $0x80109892,(%esp)
8010765f:	e8 d6 8e ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107664:	e8 d8 fc ff ff       	call   80107341 <rcr2>
80107669:	89 c2                	mov    %eax,%edx
8010766b:	8b 45 08             	mov    0x8(%ebp),%eax
8010766e:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107671:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107677:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010767a:	0f b6 f0             	movzbl %al,%esi
8010767d:	8b 45 08             	mov    0x8(%ebp),%eax
80107680:	8b 58 34             	mov    0x34(%eax),%ebx
80107683:	8b 45 08             	mov    0x8(%ebp),%eax
80107686:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107689:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010768f:	83 c0 6c             	add    $0x6c,%eax
80107692:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107695:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010769b:	8b 40 10             	mov    0x10(%eax),%eax
8010769e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801076a2:	89 7c 24 18          	mov    %edi,0x18(%esp)
801076a6:	89 74 24 14          	mov    %esi,0x14(%esp)
801076aa:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801076ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801076b2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801076b5:	89 74 24 08          	mov    %esi,0x8(%esp)
801076b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801076bd:	c7 04 24 98 98 10 80 	movl   $0x80109898,(%esp)
801076c4:	e8 d7 8c ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801076c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076cf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801076d6:	eb 01                	jmp    801076d9 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801076d8:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801076d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076df:	85 c0                	test   %eax,%eax
801076e1:	74 24                	je     80107707 <trap+0x225>
801076e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076e9:	8b 40 24             	mov    0x24(%eax),%eax
801076ec:	85 c0                	test   %eax,%eax
801076ee:	74 17                	je     80107707 <trap+0x225>
801076f0:	8b 45 08             	mov    0x8(%ebp),%eax
801076f3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801076f7:	0f b7 c0             	movzwl %ax,%eax
801076fa:	83 e0 03             	and    $0x3,%eax
801076fd:	83 f8 03             	cmp    $0x3,%eax
80107700:	75 05                	jne    80107707 <trap+0x225>
    exit();
80107702:	e8 0a dc ff ff       	call   80105311 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107707:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010770d:	85 c0                	test   %eax,%eax
8010770f:	74 1e                	je     8010772f <trap+0x24d>
80107711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107717:	8b 40 0c             	mov    0xc(%eax),%eax
8010771a:	83 f8 04             	cmp    $0x4,%eax
8010771d:	75 10                	jne    8010772f <trap+0x24d>
8010771f:	8b 45 08             	mov    0x8(%ebp),%eax
80107722:	8b 40 30             	mov    0x30(%eax),%eax
80107725:	83 f8 20             	cmp    $0x20,%eax
80107728:	75 05                	jne    8010772f <trap+0x24d>
    yield();
8010772a:	e8 81 df ff ff       	call   801056b0 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010772f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107735:	85 c0                	test   %eax,%eax
80107737:	74 24                	je     8010775d <trap+0x27b>
80107739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010773f:	8b 40 24             	mov    0x24(%eax),%eax
80107742:	85 c0                	test   %eax,%eax
80107744:	74 17                	je     8010775d <trap+0x27b>
80107746:	8b 45 08             	mov    0x8(%ebp),%eax
80107749:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010774d:	0f b7 c0             	movzwl %ax,%eax
80107750:	83 e0 03             	and    $0x3,%eax
80107753:	83 f8 03             	cmp    $0x3,%eax
80107756:	75 05                	jne    8010775d <trap+0x27b>
    exit();
80107758:	e8 b4 db ff ff       	call   80105311 <exit>
}
8010775d:	83 c4 3c             	add    $0x3c,%esp
80107760:	5b                   	pop    %ebx
80107761:	5e                   	pop    %esi
80107762:	5f                   	pop    %edi
80107763:	5d                   	pop    %ebp
80107764:	c3                   	ret    

80107765 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107765:	55                   	push   %ebp
80107766:	89 e5                	mov    %esp,%ebp
80107768:	83 ec 14             	sub    $0x14,%esp
8010776b:	8b 45 08             	mov    0x8(%ebp),%eax
8010776e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107772:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107776:	89 c2                	mov    %eax,%edx
80107778:	ec                   	in     (%dx),%al
80107779:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010777c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107780:	c9                   	leave  
80107781:	c3                   	ret    

80107782 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107782:	55                   	push   %ebp
80107783:	89 e5                	mov    %esp,%ebp
80107785:	83 ec 08             	sub    $0x8,%esp
80107788:	8b 55 08             	mov    0x8(%ebp),%edx
8010778b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010778e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107792:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107795:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107799:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010779d:	ee                   	out    %al,(%dx)
}
8010779e:	c9                   	leave  
8010779f:	c3                   	ret    

801077a0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801077a0:	55                   	push   %ebp
801077a1:	89 e5                	mov    %esp,%ebp
801077a3:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801077a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077ad:	00 
801077ae:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801077b5:	e8 c8 ff ff ff       	call   80107782 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801077ba:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801077c1:	00 
801077c2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801077c9:	e8 b4 ff ff ff       	call   80107782 <outb>
  outb(COM1+0, 115200/9600);
801077ce:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801077d5:	00 
801077d6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801077dd:	e8 a0 ff ff ff       	call   80107782 <outb>
  outb(COM1+1, 0);
801077e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077e9:	00 
801077ea:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801077f1:	e8 8c ff ff ff       	call   80107782 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801077f6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801077fd:	00 
801077fe:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107805:	e8 78 ff ff ff       	call   80107782 <outb>
  outb(COM1+4, 0);
8010780a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107811:	00 
80107812:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107819:	e8 64 ff ff ff       	call   80107782 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010781e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107825:	00 
80107826:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010782d:	e8 50 ff ff ff       	call   80107782 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107832:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107839:	e8 27 ff ff ff       	call   80107765 <inb>
8010783e:	3c ff                	cmp    $0xff,%al
80107840:	75 02                	jne    80107844 <uartinit+0xa4>
    return;
80107842:	eb 6a                	jmp    801078ae <uartinit+0x10e>
  uart = 1;
80107844:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
8010784b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010784e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107855:	e8 0b ff ff ff       	call   80107765 <inb>
  inb(COM1+0);
8010785a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107861:	e8 ff fe ff ff       	call   80107765 <inb>
  picenable(IRQ_COM1);
80107866:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010786d:	e8 0c d1 ff ff       	call   8010497e <picenable>
  ioapicenable(IRQ_COM1, 0);
80107872:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107879:	00 
8010787a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107881:	e8 b7 b9 ff ff       	call   8010323d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107886:	c7 45 f4 5c 99 10 80 	movl   $0x8010995c,-0xc(%ebp)
8010788d:	eb 15                	jmp    801078a4 <uartinit+0x104>
    uartputc(*p);
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	0f b6 00             	movzbl (%eax),%eax
80107895:	0f be c0             	movsbl %al,%eax
80107898:	89 04 24             	mov    %eax,(%esp)
8010789b:	e8 10 00 00 00       	call   801078b0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	0f b6 00             	movzbl (%eax),%eax
801078aa:	84 c0                	test   %al,%al
801078ac:	75 e1                	jne    8010788f <uartinit+0xef>
    uartputc(*p);
}
801078ae:	c9                   	leave  
801078af:	c3                   	ret    

801078b0 <uartputc>:

void
uartputc(int c)
{
801078b0:	55                   	push   %ebp
801078b1:	89 e5                	mov    %esp,%ebp
801078b3:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801078b6:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801078bb:	85 c0                	test   %eax,%eax
801078bd:	75 02                	jne    801078c1 <uartputc+0x11>
    return;
801078bf:	eb 4b                	jmp    8010790c <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078c8:	eb 10                	jmp    801078da <uartputc+0x2a>
    microdelay(10);
801078ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801078d1:	e8 ff be ff ff       	call   801037d5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801078da:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801078de:	7f 16                	jg     801078f6 <uartputc+0x46>
801078e0:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801078e7:	e8 79 fe ff ff       	call   80107765 <inb>
801078ec:	0f b6 c0             	movzbl %al,%eax
801078ef:	83 e0 20             	and    $0x20,%eax
801078f2:	85 c0                	test   %eax,%eax
801078f4:	74 d4                	je     801078ca <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801078f6:	8b 45 08             	mov    0x8(%ebp),%eax
801078f9:	0f b6 c0             	movzbl %al,%eax
801078fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80107900:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107907:	e8 76 fe ff ff       	call   80107782 <outb>
}
8010790c:	c9                   	leave  
8010790d:	c3                   	ret    

8010790e <uartgetc>:

static int
uartgetc(void)
{
8010790e:	55                   	push   %ebp
8010790f:	89 e5                	mov    %esp,%ebp
80107911:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107914:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107919:	85 c0                	test   %eax,%eax
8010791b:	75 07                	jne    80107924 <uartgetc+0x16>
    return -1;
8010791d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107922:	eb 2c                	jmp    80107950 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107924:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010792b:	e8 35 fe ff ff       	call   80107765 <inb>
80107930:	0f b6 c0             	movzbl %al,%eax
80107933:	83 e0 01             	and    $0x1,%eax
80107936:	85 c0                	test   %eax,%eax
80107938:	75 07                	jne    80107941 <uartgetc+0x33>
    return -1;
8010793a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010793f:	eb 0f                	jmp    80107950 <uartgetc+0x42>
  return inb(COM1+0);
80107941:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107948:	e8 18 fe ff ff       	call   80107765 <inb>
8010794d:	0f b6 c0             	movzbl %al,%eax
}
80107950:	c9                   	leave  
80107951:	c3                   	ret    

80107952 <uartintr>:

void
uartintr(void)
{
80107952:	55                   	push   %ebp
80107953:	89 e5                	mov    %esp,%ebp
80107955:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107958:	c7 04 24 0e 79 10 80 	movl   $0x8010790e,(%esp)
8010795f:	e8 64 8e ff ff       	call   801007c8 <consoleintr>
}
80107964:	c9                   	leave  
80107965:	c3                   	ret    

80107966 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $0
80107968:	6a 00                	push   $0x0
  jmp alltraps
8010796a:	e9 7e f9 ff ff       	jmp    801072ed <alltraps>

8010796f <vector1>:
.globl vector1
vector1:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $1
80107971:	6a 01                	push   $0x1
  jmp alltraps
80107973:	e9 75 f9 ff ff       	jmp    801072ed <alltraps>

80107978 <vector2>:
.globl vector2
vector2:
  pushl $0
80107978:	6a 00                	push   $0x0
  pushl $2
8010797a:	6a 02                	push   $0x2
  jmp alltraps
8010797c:	e9 6c f9 ff ff       	jmp    801072ed <alltraps>

80107981 <vector3>:
.globl vector3
vector3:
  pushl $0
80107981:	6a 00                	push   $0x0
  pushl $3
80107983:	6a 03                	push   $0x3
  jmp alltraps
80107985:	e9 63 f9 ff ff       	jmp    801072ed <alltraps>

8010798a <vector4>:
.globl vector4
vector4:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $4
8010798c:	6a 04                	push   $0x4
  jmp alltraps
8010798e:	e9 5a f9 ff ff       	jmp    801072ed <alltraps>

80107993 <vector5>:
.globl vector5
vector5:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $5
80107995:	6a 05                	push   $0x5
  jmp alltraps
80107997:	e9 51 f9 ff ff       	jmp    801072ed <alltraps>

8010799c <vector6>:
.globl vector6
vector6:
  pushl $0
8010799c:	6a 00                	push   $0x0
  pushl $6
8010799e:	6a 06                	push   $0x6
  jmp alltraps
801079a0:	e9 48 f9 ff ff       	jmp    801072ed <alltraps>

801079a5 <vector7>:
.globl vector7
vector7:
  pushl $0
801079a5:	6a 00                	push   $0x0
  pushl $7
801079a7:	6a 07                	push   $0x7
  jmp alltraps
801079a9:	e9 3f f9 ff ff       	jmp    801072ed <alltraps>

801079ae <vector8>:
.globl vector8
vector8:
  pushl $8
801079ae:	6a 08                	push   $0x8
  jmp alltraps
801079b0:	e9 38 f9 ff ff       	jmp    801072ed <alltraps>

801079b5 <vector9>:
.globl vector9
vector9:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $9
801079b7:	6a 09                	push   $0x9
  jmp alltraps
801079b9:	e9 2f f9 ff ff       	jmp    801072ed <alltraps>

801079be <vector10>:
.globl vector10
vector10:
  pushl $10
801079be:	6a 0a                	push   $0xa
  jmp alltraps
801079c0:	e9 28 f9 ff ff       	jmp    801072ed <alltraps>

801079c5 <vector11>:
.globl vector11
vector11:
  pushl $11
801079c5:	6a 0b                	push   $0xb
  jmp alltraps
801079c7:	e9 21 f9 ff ff       	jmp    801072ed <alltraps>

801079cc <vector12>:
.globl vector12
vector12:
  pushl $12
801079cc:	6a 0c                	push   $0xc
  jmp alltraps
801079ce:	e9 1a f9 ff ff       	jmp    801072ed <alltraps>

801079d3 <vector13>:
.globl vector13
vector13:
  pushl $13
801079d3:	6a 0d                	push   $0xd
  jmp alltraps
801079d5:	e9 13 f9 ff ff       	jmp    801072ed <alltraps>

801079da <vector14>:
.globl vector14
vector14:
  pushl $14
801079da:	6a 0e                	push   $0xe
  jmp alltraps
801079dc:	e9 0c f9 ff ff       	jmp    801072ed <alltraps>

801079e1 <vector15>:
.globl vector15
vector15:
  pushl $0
801079e1:	6a 00                	push   $0x0
  pushl $15
801079e3:	6a 0f                	push   $0xf
  jmp alltraps
801079e5:	e9 03 f9 ff ff       	jmp    801072ed <alltraps>

801079ea <vector16>:
.globl vector16
vector16:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $16
801079ec:	6a 10                	push   $0x10
  jmp alltraps
801079ee:	e9 fa f8 ff ff       	jmp    801072ed <alltraps>

801079f3 <vector17>:
.globl vector17
vector17:
  pushl $17
801079f3:	6a 11                	push   $0x11
  jmp alltraps
801079f5:	e9 f3 f8 ff ff       	jmp    801072ed <alltraps>

801079fa <vector18>:
.globl vector18
vector18:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $18
801079fc:	6a 12                	push   $0x12
  jmp alltraps
801079fe:	e9 ea f8 ff ff       	jmp    801072ed <alltraps>

80107a03 <vector19>:
.globl vector19
vector19:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $19
80107a05:	6a 13                	push   $0x13
  jmp alltraps
80107a07:	e9 e1 f8 ff ff       	jmp    801072ed <alltraps>

80107a0c <vector20>:
.globl vector20
vector20:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $20
80107a0e:	6a 14                	push   $0x14
  jmp alltraps
80107a10:	e9 d8 f8 ff ff       	jmp    801072ed <alltraps>

80107a15 <vector21>:
.globl vector21
vector21:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $21
80107a17:	6a 15                	push   $0x15
  jmp alltraps
80107a19:	e9 cf f8 ff ff       	jmp    801072ed <alltraps>

80107a1e <vector22>:
.globl vector22
vector22:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $22
80107a20:	6a 16                	push   $0x16
  jmp alltraps
80107a22:	e9 c6 f8 ff ff       	jmp    801072ed <alltraps>

80107a27 <vector23>:
.globl vector23
vector23:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $23
80107a29:	6a 17                	push   $0x17
  jmp alltraps
80107a2b:	e9 bd f8 ff ff       	jmp    801072ed <alltraps>

80107a30 <vector24>:
.globl vector24
vector24:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $24
80107a32:	6a 18                	push   $0x18
  jmp alltraps
80107a34:	e9 b4 f8 ff ff       	jmp    801072ed <alltraps>

80107a39 <vector25>:
.globl vector25
vector25:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $25
80107a3b:	6a 19                	push   $0x19
  jmp alltraps
80107a3d:	e9 ab f8 ff ff       	jmp    801072ed <alltraps>

80107a42 <vector26>:
.globl vector26
vector26:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $26
80107a44:	6a 1a                	push   $0x1a
  jmp alltraps
80107a46:	e9 a2 f8 ff ff       	jmp    801072ed <alltraps>

80107a4b <vector27>:
.globl vector27
vector27:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $27
80107a4d:	6a 1b                	push   $0x1b
  jmp alltraps
80107a4f:	e9 99 f8 ff ff       	jmp    801072ed <alltraps>

80107a54 <vector28>:
.globl vector28
vector28:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $28
80107a56:	6a 1c                	push   $0x1c
  jmp alltraps
80107a58:	e9 90 f8 ff ff       	jmp    801072ed <alltraps>

80107a5d <vector29>:
.globl vector29
vector29:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $29
80107a5f:	6a 1d                	push   $0x1d
  jmp alltraps
80107a61:	e9 87 f8 ff ff       	jmp    801072ed <alltraps>

80107a66 <vector30>:
.globl vector30
vector30:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $30
80107a68:	6a 1e                	push   $0x1e
  jmp alltraps
80107a6a:	e9 7e f8 ff ff       	jmp    801072ed <alltraps>

80107a6f <vector31>:
.globl vector31
vector31:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $31
80107a71:	6a 1f                	push   $0x1f
  jmp alltraps
80107a73:	e9 75 f8 ff ff       	jmp    801072ed <alltraps>

80107a78 <vector32>:
.globl vector32
vector32:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $32
80107a7a:	6a 20                	push   $0x20
  jmp alltraps
80107a7c:	e9 6c f8 ff ff       	jmp    801072ed <alltraps>

80107a81 <vector33>:
.globl vector33
vector33:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $33
80107a83:	6a 21                	push   $0x21
  jmp alltraps
80107a85:	e9 63 f8 ff ff       	jmp    801072ed <alltraps>

80107a8a <vector34>:
.globl vector34
vector34:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $34
80107a8c:	6a 22                	push   $0x22
  jmp alltraps
80107a8e:	e9 5a f8 ff ff       	jmp    801072ed <alltraps>

80107a93 <vector35>:
.globl vector35
vector35:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $35
80107a95:	6a 23                	push   $0x23
  jmp alltraps
80107a97:	e9 51 f8 ff ff       	jmp    801072ed <alltraps>

80107a9c <vector36>:
.globl vector36
vector36:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $36
80107a9e:	6a 24                	push   $0x24
  jmp alltraps
80107aa0:	e9 48 f8 ff ff       	jmp    801072ed <alltraps>

80107aa5 <vector37>:
.globl vector37
vector37:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $37
80107aa7:	6a 25                	push   $0x25
  jmp alltraps
80107aa9:	e9 3f f8 ff ff       	jmp    801072ed <alltraps>

80107aae <vector38>:
.globl vector38
vector38:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $38
80107ab0:	6a 26                	push   $0x26
  jmp alltraps
80107ab2:	e9 36 f8 ff ff       	jmp    801072ed <alltraps>

80107ab7 <vector39>:
.globl vector39
vector39:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $39
80107ab9:	6a 27                	push   $0x27
  jmp alltraps
80107abb:	e9 2d f8 ff ff       	jmp    801072ed <alltraps>

80107ac0 <vector40>:
.globl vector40
vector40:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $40
80107ac2:	6a 28                	push   $0x28
  jmp alltraps
80107ac4:	e9 24 f8 ff ff       	jmp    801072ed <alltraps>

80107ac9 <vector41>:
.globl vector41
vector41:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $41
80107acb:	6a 29                	push   $0x29
  jmp alltraps
80107acd:	e9 1b f8 ff ff       	jmp    801072ed <alltraps>

80107ad2 <vector42>:
.globl vector42
vector42:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $42
80107ad4:	6a 2a                	push   $0x2a
  jmp alltraps
80107ad6:	e9 12 f8 ff ff       	jmp    801072ed <alltraps>

80107adb <vector43>:
.globl vector43
vector43:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $43
80107add:	6a 2b                	push   $0x2b
  jmp alltraps
80107adf:	e9 09 f8 ff ff       	jmp    801072ed <alltraps>

80107ae4 <vector44>:
.globl vector44
vector44:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $44
80107ae6:	6a 2c                	push   $0x2c
  jmp alltraps
80107ae8:	e9 00 f8 ff ff       	jmp    801072ed <alltraps>

80107aed <vector45>:
.globl vector45
vector45:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $45
80107aef:	6a 2d                	push   $0x2d
  jmp alltraps
80107af1:	e9 f7 f7 ff ff       	jmp    801072ed <alltraps>

80107af6 <vector46>:
.globl vector46
vector46:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $46
80107af8:	6a 2e                	push   $0x2e
  jmp alltraps
80107afa:	e9 ee f7 ff ff       	jmp    801072ed <alltraps>

80107aff <vector47>:
.globl vector47
vector47:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $47
80107b01:	6a 2f                	push   $0x2f
  jmp alltraps
80107b03:	e9 e5 f7 ff ff       	jmp    801072ed <alltraps>

80107b08 <vector48>:
.globl vector48
vector48:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $48
80107b0a:	6a 30                	push   $0x30
  jmp alltraps
80107b0c:	e9 dc f7 ff ff       	jmp    801072ed <alltraps>

80107b11 <vector49>:
.globl vector49
vector49:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $49
80107b13:	6a 31                	push   $0x31
  jmp alltraps
80107b15:	e9 d3 f7 ff ff       	jmp    801072ed <alltraps>

80107b1a <vector50>:
.globl vector50
vector50:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $50
80107b1c:	6a 32                	push   $0x32
  jmp alltraps
80107b1e:	e9 ca f7 ff ff       	jmp    801072ed <alltraps>

80107b23 <vector51>:
.globl vector51
vector51:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $51
80107b25:	6a 33                	push   $0x33
  jmp alltraps
80107b27:	e9 c1 f7 ff ff       	jmp    801072ed <alltraps>

80107b2c <vector52>:
.globl vector52
vector52:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $52
80107b2e:	6a 34                	push   $0x34
  jmp alltraps
80107b30:	e9 b8 f7 ff ff       	jmp    801072ed <alltraps>

80107b35 <vector53>:
.globl vector53
vector53:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $53
80107b37:	6a 35                	push   $0x35
  jmp alltraps
80107b39:	e9 af f7 ff ff       	jmp    801072ed <alltraps>

80107b3e <vector54>:
.globl vector54
vector54:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $54
80107b40:	6a 36                	push   $0x36
  jmp alltraps
80107b42:	e9 a6 f7 ff ff       	jmp    801072ed <alltraps>

80107b47 <vector55>:
.globl vector55
vector55:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $55
80107b49:	6a 37                	push   $0x37
  jmp alltraps
80107b4b:	e9 9d f7 ff ff       	jmp    801072ed <alltraps>

80107b50 <vector56>:
.globl vector56
vector56:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $56
80107b52:	6a 38                	push   $0x38
  jmp alltraps
80107b54:	e9 94 f7 ff ff       	jmp    801072ed <alltraps>

80107b59 <vector57>:
.globl vector57
vector57:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $57
80107b5b:	6a 39                	push   $0x39
  jmp alltraps
80107b5d:	e9 8b f7 ff ff       	jmp    801072ed <alltraps>

80107b62 <vector58>:
.globl vector58
vector58:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $58
80107b64:	6a 3a                	push   $0x3a
  jmp alltraps
80107b66:	e9 82 f7 ff ff       	jmp    801072ed <alltraps>

80107b6b <vector59>:
.globl vector59
vector59:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $59
80107b6d:	6a 3b                	push   $0x3b
  jmp alltraps
80107b6f:	e9 79 f7 ff ff       	jmp    801072ed <alltraps>

80107b74 <vector60>:
.globl vector60
vector60:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $60
80107b76:	6a 3c                	push   $0x3c
  jmp alltraps
80107b78:	e9 70 f7 ff ff       	jmp    801072ed <alltraps>

80107b7d <vector61>:
.globl vector61
vector61:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $61
80107b7f:	6a 3d                	push   $0x3d
  jmp alltraps
80107b81:	e9 67 f7 ff ff       	jmp    801072ed <alltraps>

80107b86 <vector62>:
.globl vector62
vector62:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $62
80107b88:	6a 3e                	push   $0x3e
  jmp alltraps
80107b8a:	e9 5e f7 ff ff       	jmp    801072ed <alltraps>

80107b8f <vector63>:
.globl vector63
vector63:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $63
80107b91:	6a 3f                	push   $0x3f
  jmp alltraps
80107b93:	e9 55 f7 ff ff       	jmp    801072ed <alltraps>

80107b98 <vector64>:
.globl vector64
vector64:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $64
80107b9a:	6a 40                	push   $0x40
  jmp alltraps
80107b9c:	e9 4c f7 ff ff       	jmp    801072ed <alltraps>

80107ba1 <vector65>:
.globl vector65
vector65:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $65
80107ba3:	6a 41                	push   $0x41
  jmp alltraps
80107ba5:	e9 43 f7 ff ff       	jmp    801072ed <alltraps>

80107baa <vector66>:
.globl vector66
vector66:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $66
80107bac:	6a 42                	push   $0x42
  jmp alltraps
80107bae:	e9 3a f7 ff ff       	jmp    801072ed <alltraps>

80107bb3 <vector67>:
.globl vector67
vector67:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $67
80107bb5:	6a 43                	push   $0x43
  jmp alltraps
80107bb7:	e9 31 f7 ff ff       	jmp    801072ed <alltraps>

80107bbc <vector68>:
.globl vector68
vector68:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $68
80107bbe:	6a 44                	push   $0x44
  jmp alltraps
80107bc0:	e9 28 f7 ff ff       	jmp    801072ed <alltraps>

80107bc5 <vector69>:
.globl vector69
vector69:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $69
80107bc7:	6a 45                	push   $0x45
  jmp alltraps
80107bc9:	e9 1f f7 ff ff       	jmp    801072ed <alltraps>

80107bce <vector70>:
.globl vector70
vector70:
  pushl $0
80107bce:	6a 00                	push   $0x0
  pushl $70
80107bd0:	6a 46                	push   $0x46
  jmp alltraps
80107bd2:	e9 16 f7 ff ff       	jmp    801072ed <alltraps>

80107bd7 <vector71>:
.globl vector71
vector71:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $71
80107bd9:	6a 47                	push   $0x47
  jmp alltraps
80107bdb:	e9 0d f7 ff ff       	jmp    801072ed <alltraps>

80107be0 <vector72>:
.globl vector72
vector72:
  pushl $0
80107be0:	6a 00                	push   $0x0
  pushl $72
80107be2:	6a 48                	push   $0x48
  jmp alltraps
80107be4:	e9 04 f7 ff ff       	jmp    801072ed <alltraps>

80107be9 <vector73>:
.globl vector73
vector73:
  pushl $0
80107be9:	6a 00                	push   $0x0
  pushl $73
80107beb:	6a 49                	push   $0x49
  jmp alltraps
80107bed:	e9 fb f6 ff ff       	jmp    801072ed <alltraps>

80107bf2 <vector74>:
.globl vector74
vector74:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $74
80107bf4:	6a 4a                	push   $0x4a
  jmp alltraps
80107bf6:	e9 f2 f6 ff ff       	jmp    801072ed <alltraps>

80107bfb <vector75>:
.globl vector75
vector75:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $75
80107bfd:	6a 4b                	push   $0x4b
  jmp alltraps
80107bff:	e9 e9 f6 ff ff       	jmp    801072ed <alltraps>

80107c04 <vector76>:
.globl vector76
vector76:
  pushl $0
80107c04:	6a 00                	push   $0x0
  pushl $76
80107c06:	6a 4c                	push   $0x4c
  jmp alltraps
80107c08:	e9 e0 f6 ff ff       	jmp    801072ed <alltraps>

80107c0d <vector77>:
.globl vector77
vector77:
  pushl $0
80107c0d:	6a 00                	push   $0x0
  pushl $77
80107c0f:	6a 4d                	push   $0x4d
  jmp alltraps
80107c11:	e9 d7 f6 ff ff       	jmp    801072ed <alltraps>

80107c16 <vector78>:
.globl vector78
vector78:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $78
80107c18:	6a 4e                	push   $0x4e
  jmp alltraps
80107c1a:	e9 ce f6 ff ff       	jmp    801072ed <alltraps>

80107c1f <vector79>:
.globl vector79
vector79:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $79
80107c21:	6a 4f                	push   $0x4f
  jmp alltraps
80107c23:	e9 c5 f6 ff ff       	jmp    801072ed <alltraps>

80107c28 <vector80>:
.globl vector80
vector80:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $80
80107c2a:	6a 50                	push   $0x50
  jmp alltraps
80107c2c:	e9 bc f6 ff ff       	jmp    801072ed <alltraps>

80107c31 <vector81>:
.globl vector81
vector81:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $81
80107c33:	6a 51                	push   $0x51
  jmp alltraps
80107c35:	e9 b3 f6 ff ff       	jmp    801072ed <alltraps>

80107c3a <vector82>:
.globl vector82
vector82:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $82
80107c3c:	6a 52                	push   $0x52
  jmp alltraps
80107c3e:	e9 aa f6 ff ff       	jmp    801072ed <alltraps>

80107c43 <vector83>:
.globl vector83
vector83:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $83
80107c45:	6a 53                	push   $0x53
  jmp alltraps
80107c47:	e9 a1 f6 ff ff       	jmp    801072ed <alltraps>

80107c4c <vector84>:
.globl vector84
vector84:
  pushl $0
80107c4c:	6a 00                	push   $0x0
  pushl $84
80107c4e:	6a 54                	push   $0x54
  jmp alltraps
80107c50:	e9 98 f6 ff ff       	jmp    801072ed <alltraps>

80107c55 <vector85>:
.globl vector85
vector85:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $85
80107c57:	6a 55                	push   $0x55
  jmp alltraps
80107c59:	e9 8f f6 ff ff       	jmp    801072ed <alltraps>

80107c5e <vector86>:
.globl vector86
vector86:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $86
80107c60:	6a 56                	push   $0x56
  jmp alltraps
80107c62:	e9 86 f6 ff ff       	jmp    801072ed <alltraps>

80107c67 <vector87>:
.globl vector87
vector87:
  pushl $0
80107c67:	6a 00                	push   $0x0
  pushl $87
80107c69:	6a 57                	push   $0x57
  jmp alltraps
80107c6b:	e9 7d f6 ff ff       	jmp    801072ed <alltraps>

80107c70 <vector88>:
.globl vector88
vector88:
  pushl $0
80107c70:	6a 00                	push   $0x0
  pushl $88
80107c72:	6a 58                	push   $0x58
  jmp alltraps
80107c74:	e9 74 f6 ff ff       	jmp    801072ed <alltraps>

80107c79 <vector89>:
.globl vector89
vector89:
  pushl $0
80107c79:	6a 00                	push   $0x0
  pushl $89
80107c7b:	6a 59                	push   $0x59
  jmp alltraps
80107c7d:	e9 6b f6 ff ff       	jmp    801072ed <alltraps>

80107c82 <vector90>:
.globl vector90
vector90:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $90
80107c84:	6a 5a                	push   $0x5a
  jmp alltraps
80107c86:	e9 62 f6 ff ff       	jmp    801072ed <alltraps>

80107c8b <vector91>:
.globl vector91
vector91:
  pushl $0
80107c8b:	6a 00                	push   $0x0
  pushl $91
80107c8d:	6a 5b                	push   $0x5b
  jmp alltraps
80107c8f:	e9 59 f6 ff ff       	jmp    801072ed <alltraps>

80107c94 <vector92>:
.globl vector92
vector92:
  pushl $0
80107c94:	6a 00                	push   $0x0
  pushl $92
80107c96:	6a 5c                	push   $0x5c
  jmp alltraps
80107c98:	e9 50 f6 ff ff       	jmp    801072ed <alltraps>

80107c9d <vector93>:
.globl vector93
vector93:
  pushl $0
80107c9d:	6a 00                	push   $0x0
  pushl $93
80107c9f:	6a 5d                	push   $0x5d
  jmp alltraps
80107ca1:	e9 47 f6 ff ff       	jmp    801072ed <alltraps>

80107ca6 <vector94>:
.globl vector94
vector94:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $94
80107ca8:	6a 5e                	push   $0x5e
  jmp alltraps
80107caa:	e9 3e f6 ff ff       	jmp    801072ed <alltraps>

80107caf <vector95>:
.globl vector95
vector95:
  pushl $0
80107caf:	6a 00                	push   $0x0
  pushl $95
80107cb1:	6a 5f                	push   $0x5f
  jmp alltraps
80107cb3:	e9 35 f6 ff ff       	jmp    801072ed <alltraps>

80107cb8 <vector96>:
.globl vector96
vector96:
  pushl $0
80107cb8:	6a 00                	push   $0x0
  pushl $96
80107cba:	6a 60                	push   $0x60
  jmp alltraps
80107cbc:	e9 2c f6 ff ff       	jmp    801072ed <alltraps>

80107cc1 <vector97>:
.globl vector97
vector97:
  pushl $0
80107cc1:	6a 00                	push   $0x0
  pushl $97
80107cc3:	6a 61                	push   $0x61
  jmp alltraps
80107cc5:	e9 23 f6 ff ff       	jmp    801072ed <alltraps>

80107cca <vector98>:
.globl vector98
vector98:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $98
80107ccc:	6a 62                	push   $0x62
  jmp alltraps
80107cce:	e9 1a f6 ff ff       	jmp    801072ed <alltraps>

80107cd3 <vector99>:
.globl vector99
vector99:
  pushl $0
80107cd3:	6a 00                	push   $0x0
  pushl $99
80107cd5:	6a 63                	push   $0x63
  jmp alltraps
80107cd7:	e9 11 f6 ff ff       	jmp    801072ed <alltraps>

80107cdc <vector100>:
.globl vector100
vector100:
  pushl $0
80107cdc:	6a 00                	push   $0x0
  pushl $100
80107cde:	6a 64                	push   $0x64
  jmp alltraps
80107ce0:	e9 08 f6 ff ff       	jmp    801072ed <alltraps>

80107ce5 <vector101>:
.globl vector101
vector101:
  pushl $0
80107ce5:	6a 00                	push   $0x0
  pushl $101
80107ce7:	6a 65                	push   $0x65
  jmp alltraps
80107ce9:	e9 ff f5 ff ff       	jmp    801072ed <alltraps>

80107cee <vector102>:
.globl vector102
vector102:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $102
80107cf0:	6a 66                	push   $0x66
  jmp alltraps
80107cf2:	e9 f6 f5 ff ff       	jmp    801072ed <alltraps>

80107cf7 <vector103>:
.globl vector103
vector103:
  pushl $0
80107cf7:	6a 00                	push   $0x0
  pushl $103
80107cf9:	6a 67                	push   $0x67
  jmp alltraps
80107cfb:	e9 ed f5 ff ff       	jmp    801072ed <alltraps>

80107d00 <vector104>:
.globl vector104
vector104:
  pushl $0
80107d00:	6a 00                	push   $0x0
  pushl $104
80107d02:	6a 68                	push   $0x68
  jmp alltraps
80107d04:	e9 e4 f5 ff ff       	jmp    801072ed <alltraps>

80107d09 <vector105>:
.globl vector105
vector105:
  pushl $0
80107d09:	6a 00                	push   $0x0
  pushl $105
80107d0b:	6a 69                	push   $0x69
  jmp alltraps
80107d0d:	e9 db f5 ff ff       	jmp    801072ed <alltraps>

80107d12 <vector106>:
.globl vector106
vector106:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $106
80107d14:	6a 6a                	push   $0x6a
  jmp alltraps
80107d16:	e9 d2 f5 ff ff       	jmp    801072ed <alltraps>

80107d1b <vector107>:
.globl vector107
vector107:
  pushl $0
80107d1b:	6a 00                	push   $0x0
  pushl $107
80107d1d:	6a 6b                	push   $0x6b
  jmp alltraps
80107d1f:	e9 c9 f5 ff ff       	jmp    801072ed <alltraps>

80107d24 <vector108>:
.globl vector108
vector108:
  pushl $0
80107d24:	6a 00                	push   $0x0
  pushl $108
80107d26:	6a 6c                	push   $0x6c
  jmp alltraps
80107d28:	e9 c0 f5 ff ff       	jmp    801072ed <alltraps>

80107d2d <vector109>:
.globl vector109
vector109:
  pushl $0
80107d2d:	6a 00                	push   $0x0
  pushl $109
80107d2f:	6a 6d                	push   $0x6d
  jmp alltraps
80107d31:	e9 b7 f5 ff ff       	jmp    801072ed <alltraps>

80107d36 <vector110>:
.globl vector110
vector110:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $110
80107d38:	6a 6e                	push   $0x6e
  jmp alltraps
80107d3a:	e9 ae f5 ff ff       	jmp    801072ed <alltraps>

80107d3f <vector111>:
.globl vector111
vector111:
  pushl $0
80107d3f:	6a 00                	push   $0x0
  pushl $111
80107d41:	6a 6f                	push   $0x6f
  jmp alltraps
80107d43:	e9 a5 f5 ff ff       	jmp    801072ed <alltraps>

80107d48 <vector112>:
.globl vector112
vector112:
  pushl $0
80107d48:	6a 00                	push   $0x0
  pushl $112
80107d4a:	6a 70                	push   $0x70
  jmp alltraps
80107d4c:	e9 9c f5 ff ff       	jmp    801072ed <alltraps>

80107d51 <vector113>:
.globl vector113
vector113:
  pushl $0
80107d51:	6a 00                	push   $0x0
  pushl $113
80107d53:	6a 71                	push   $0x71
  jmp alltraps
80107d55:	e9 93 f5 ff ff       	jmp    801072ed <alltraps>

80107d5a <vector114>:
.globl vector114
vector114:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $114
80107d5c:	6a 72                	push   $0x72
  jmp alltraps
80107d5e:	e9 8a f5 ff ff       	jmp    801072ed <alltraps>

80107d63 <vector115>:
.globl vector115
vector115:
  pushl $0
80107d63:	6a 00                	push   $0x0
  pushl $115
80107d65:	6a 73                	push   $0x73
  jmp alltraps
80107d67:	e9 81 f5 ff ff       	jmp    801072ed <alltraps>

80107d6c <vector116>:
.globl vector116
vector116:
  pushl $0
80107d6c:	6a 00                	push   $0x0
  pushl $116
80107d6e:	6a 74                	push   $0x74
  jmp alltraps
80107d70:	e9 78 f5 ff ff       	jmp    801072ed <alltraps>

80107d75 <vector117>:
.globl vector117
vector117:
  pushl $0
80107d75:	6a 00                	push   $0x0
  pushl $117
80107d77:	6a 75                	push   $0x75
  jmp alltraps
80107d79:	e9 6f f5 ff ff       	jmp    801072ed <alltraps>

80107d7e <vector118>:
.globl vector118
vector118:
  pushl $0
80107d7e:	6a 00                	push   $0x0
  pushl $118
80107d80:	6a 76                	push   $0x76
  jmp alltraps
80107d82:	e9 66 f5 ff ff       	jmp    801072ed <alltraps>

80107d87 <vector119>:
.globl vector119
vector119:
  pushl $0
80107d87:	6a 00                	push   $0x0
  pushl $119
80107d89:	6a 77                	push   $0x77
  jmp alltraps
80107d8b:	e9 5d f5 ff ff       	jmp    801072ed <alltraps>

80107d90 <vector120>:
.globl vector120
vector120:
  pushl $0
80107d90:	6a 00                	push   $0x0
  pushl $120
80107d92:	6a 78                	push   $0x78
  jmp alltraps
80107d94:	e9 54 f5 ff ff       	jmp    801072ed <alltraps>

80107d99 <vector121>:
.globl vector121
vector121:
  pushl $0
80107d99:	6a 00                	push   $0x0
  pushl $121
80107d9b:	6a 79                	push   $0x79
  jmp alltraps
80107d9d:	e9 4b f5 ff ff       	jmp    801072ed <alltraps>

80107da2 <vector122>:
.globl vector122
vector122:
  pushl $0
80107da2:	6a 00                	push   $0x0
  pushl $122
80107da4:	6a 7a                	push   $0x7a
  jmp alltraps
80107da6:	e9 42 f5 ff ff       	jmp    801072ed <alltraps>

80107dab <vector123>:
.globl vector123
vector123:
  pushl $0
80107dab:	6a 00                	push   $0x0
  pushl $123
80107dad:	6a 7b                	push   $0x7b
  jmp alltraps
80107daf:	e9 39 f5 ff ff       	jmp    801072ed <alltraps>

80107db4 <vector124>:
.globl vector124
vector124:
  pushl $0
80107db4:	6a 00                	push   $0x0
  pushl $124
80107db6:	6a 7c                	push   $0x7c
  jmp alltraps
80107db8:	e9 30 f5 ff ff       	jmp    801072ed <alltraps>

80107dbd <vector125>:
.globl vector125
vector125:
  pushl $0
80107dbd:	6a 00                	push   $0x0
  pushl $125
80107dbf:	6a 7d                	push   $0x7d
  jmp alltraps
80107dc1:	e9 27 f5 ff ff       	jmp    801072ed <alltraps>

80107dc6 <vector126>:
.globl vector126
vector126:
  pushl $0
80107dc6:	6a 00                	push   $0x0
  pushl $126
80107dc8:	6a 7e                	push   $0x7e
  jmp alltraps
80107dca:	e9 1e f5 ff ff       	jmp    801072ed <alltraps>

80107dcf <vector127>:
.globl vector127
vector127:
  pushl $0
80107dcf:	6a 00                	push   $0x0
  pushl $127
80107dd1:	6a 7f                	push   $0x7f
  jmp alltraps
80107dd3:	e9 15 f5 ff ff       	jmp    801072ed <alltraps>

80107dd8 <vector128>:
.globl vector128
vector128:
  pushl $0
80107dd8:	6a 00                	push   $0x0
  pushl $128
80107dda:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107ddf:	e9 09 f5 ff ff       	jmp    801072ed <alltraps>

80107de4 <vector129>:
.globl vector129
vector129:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $129
80107de6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107deb:	e9 fd f4 ff ff       	jmp    801072ed <alltraps>

80107df0 <vector130>:
.globl vector130
vector130:
  pushl $0
80107df0:	6a 00                	push   $0x0
  pushl $130
80107df2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107df7:	e9 f1 f4 ff ff       	jmp    801072ed <alltraps>

80107dfc <vector131>:
.globl vector131
vector131:
  pushl $0
80107dfc:	6a 00                	push   $0x0
  pushl $131
80107dfe:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e03:	e9 e5 f4 ff ff       	jmp    801072ed <alltraps>

80107e08 <vector132>:
.globl vector132
vector132:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $132
80107e0a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e0f:	e9 d9 f4 ff ff       	jmp    801072ed <alltraps>

80107e14 <vector133>:
.globl vector133
vector133:
  pushl $0
80107e14:	6a 00                	push   $0x0
  pushl $133
80107e16:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107e1b:	e9 cd f4 ff ff       	jmp    801072ed <alltraps>

80107e20 <vector134>:
.globl vector134
vector134:
  pushl $0
80107e20:	6a 00                	push   $0x0
  pushl $134
80107e22:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107e27:	e9 c1 f4 ff ff       	jmp    801072ed <alltraps>

80107e2c <vector135>:
.globl vector135
vector135:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $135
80107e2e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107e33:	e9 b5 f4 ff ff       	jmp    801072ed <alltraps>

80107e38 <vector136>:
.globl vector136
vector136:
  pushl $0
80107e38:	6a 00                	push   $0x0
  pushl $136
80107e3a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107e3f:	e9 a9 f4 ff ff       	jmp    801072ed <alltraps>

80107e44 <vector137>:
.globl vector137
vector137:
  pushl $0
80107e44:	6a 00                	push   $0x0
  pushl $137
80107e46:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107e4b:	e9 9d f4 ff ff       	jmp    801072ed <alltraps>

80107e50 <vector138>:
.globl vector138
vector138:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $138
80107e52:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107e57:	e9 91 f4 ff ff       	jmp    801072ed <alltraps>

80107e5c <vector139>:
.globl vector139
vector139:
  pushl $0
80107e5c:	6a 00                	push   $0x0
  pushl $139
80107e5e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107e63:	e9 85 f4 ff ff       	jmp    801072ed <alltraps>

80107e68 <vector140>:
.globl vector140
vector140:
  pushl $0
80107e68:	6a 00                	push   $0x0
  pushl $140
80107e6a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107e6f:	e9 79 f4 ff ff       	jmp    801072ed <alltraps>

80107e74 <vector141>:
.globl vector141
vector141:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $141
80107e76:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107e7b:	e9 6d f4 ff ff       	jmp    801072ed <alltraps>

80107e80 <vector142>:
.globl vector142
vector142:
  pushl $0
80107e80:	6a 00                	push   $0x0
  pushl $142
80107e82:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107e87:	e9 61 f4 ff ff       	jmp    801072ed <alltraps>

80107e8c <vector143>:
.globl vector143
vector143:
  pushl $0
80107e8c:	6a 00                	push   $0x0
  pushl $143
80107e8e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107e93:	e9 55 f4 ff ff       	jmp    801072ed <alltraps>

80107e98 <vector144>:
.globl vector144
vector144:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $144
80107e9a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107e9f:	e9 49 f4 ff ff       	jmp    801072ed <alltraps>

80107ea4 <vector145>:
.globl vector145
vector145:
  pushl $0
80107ea4:	6a 00                	push   $0x0
  pushl $145
80107ea6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107eab:	e9 3d f4 ff ff       	jmp    801072ed <alltraps>

80107eb0 <vector146>:
.globl vector146
vector146:
  pushl $0
80107eb0:	6a 00                	push   $0x0
  pushl $146
80107eb2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107eb7:	e9 31 f4 ff ff       	jmp    801072ed <alltraps>

80107ebc <vector147>:
.globl vector147
vector147:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $147
80107ebe:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107ec3:	e9 25 f4 ff ff       	jmp    801072ed <alltraps>

80107ec8 <vector148>:
.globl vector148
vector148:
  pushl $0
80107ec8:	6a 00                	push   $0x0
  pushl $148
80107eca:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107ecf:	e9 19 f4 ff ff       	jmp    801072ed <alltraps>

80107ed4 <vector149>:
.globl vector149
vector149:
  pushl $0
80107ed4:	6a 00                	push   $0x0
  pushl $149
80107ed6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107edb:	e9 0d f4 ff ff       	jmp    801072ed <alltraps>

80107ee0 <vector150>:
.globl vector150
vector150:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $150
80107ee2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107ee7:	e9 01 f4 ff ff       	jmp    801072ed <alltraps>

80107eec <vector151>:
.globl vector151
vector151:
  pushl $0
80107eec:	6a 00                	push   $0x0
  pushl $151
80107eee:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107ef3:	e9 f5 f3 ff ff       	jmp    801072ed <alltraps>

80107ef8 <vector152>:
.globl vector152
vector152:
  pushl $0
80107ef8:	6a 00                	push   $0x0
  pushl $152
80107efa:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107eff:	e9 e9 f3 ff ff       	jmp    801072ed <alltraps>

80107f04 <vector153>:
.globl vector153
vector153:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $153
80107f06:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f0b:	e9 dd f3 ff ff       	jmp    801072ed <alltraps>

80107f10 <vector154>:
.globl vector154
vector154:
  pushl $0
80107f10:	6a 00                	push   $0x0
  pushl $154
80107f12:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107f17:	e9 d1 f3 ff ff       	jmp    801072ed <alltraps>

80107f1c <vector155>:
.globl vector155
vector155:
  pushl $0
80107f1c:	6a 00                	push   $0x0
  pushl $155
80107f1e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107f23:	e9 c5 f3 ff ff       	jmp    801072ed <alltraps>

80107f28 <vector156>:
.globl vector156
vector156:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $156
80107f2a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107f2f:	e9 b9 f3 ff ff       	jmp    801072ed <alltraps>

80107f34 <vector157>:
.globl vector157
vector157:
  pushl $0
80107f34:	6a 00                	push   $0x0
  pushl $157
80107f36:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107f3b:	e9 ad f3 ff ff       	jmp    801072ed <alltraps>

80107f40 <vector158>:
.globl vector158
vector158:
  pushl $0
80107f40:	6a 00                	push   $0x0
  pushl $158
80107f42:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107f47:	e9 a1 f3 ff ff       	jmp    801072ed <alltraps>

80107f4c <vector159>:
.globl vector159
vector159:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $159
80107f4e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107f53:	e9 95 f3 ff ff       	jmp    801072ed <alltraps>

80107f58 <vector160>:
.globl vector160
vector160:
  pushl $0
80107f58:	6a 00                	push   $0x0
  pushl $160
80107f5a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107f5f:	e9 89 f3 ff ff       	jmp    801072ed <alltraps>

80107f64 <vector161>:
.globl vector161
vector161:
  pushl $0
80107f64:	6a 00                	push   $0x0
  pushl $161
80107f66:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107f6b:	e9 7d f3 ff ff       	jmp    801072ed <alltraps>

80107f70 <vector162>:
.globl vector162
vector162:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $162
80107f72:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107f77:	e9 71 f3 ff ff       	jmp    801072ed <alltraps>

80107f7c <vector163>:
.globl vector163
vector163:
  pushl $0
80107f7c:	6a 00                	push   $0x0
  pushl $163
80107f7e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107f83:	e9 65 f3 ff ff       	jmp    801072ed <alltraps>

80107f88 <vector164>:
.globl vector164
vector164:
  pushl $0
80107f88:	6a 00                	push   $0x0
  pushl $164
80107f8a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107f8f:	e9 59 f3 ff ff       	jmp    801072ed <alltraps>

80107f94 <vector165>:
.globl vector165
vector165:
  pushl $0
80107f94:	6a 00                	push   $0x0
  pushl $165
80107f96:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107f9b:	e9 4d f3 ff ff       	jmp    801072ed <alltraps>

80107fa0 <vector166>:
.globl vector166
vector166:
  pushl $0
80107fa0:	6a 00                	push   $0x0
  pushl $166
80107fa2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107fa7:	e9 41 f3 ff ff       	jmp    801072ed <alltraps>

80107fac <vector167>:
.globl vector167
vector167:
  pushl $0
80107fac:	6a 00                	push   $0x0
  pushl $167
80107fae:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107fb3:	e9 35 f3 ff ff       	jmp    801072ed <alltraps>

80107fb8 <vector168>:
.globl vector168
vector168:
  pushl $0
80107fb8:	6a 00                	push   $0x0
  pushl $168
80107fba:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107fbf:	e9 29 f3 ff ff       	jmp    801072ed <alltraps>

80107fc4 <vector169>:
.globl vector169
vector169:
  pushl $0
80107fc4:	6a 00                	push   $0x0
  pushl $169
80107fc6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107fcb:	e9 1d f3 ff ff       	jmp    801072ed <alltraps>

80107fd0 <vector170>:
.globl vector170
vector170:
  pushl $0
80107fd0:	6a 00                	push   $0x0
  pushl $170
80107fd2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107fd7:	e9 11 f3 ff ff       	jmp    801072ed <alltraps>

80107fdc <vector171>:
.globl vector171
vector171:
  pushl $0
80107fdc:	6a 00                	push   $0x0
  pushl $171
80107fde:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107fe3:	e9 05 f3 ff ff       	jmp    801072ed <alltraps>

80107fe8 <vector172>:
.globl vector172
vector172:
  pushl $0
80107fe8:	6a 00                	push   $0x0
  pushl $172
80107fea:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107fef:	e9 f9 f2 ff ff       	jmp    801072ed <alltraps>

80107ff4 <vector173>:
.globl vector173
vector173:
  pushl $0
80107ff4:	6a 00                	push   $0x0
  pushl $173
80107ff6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107ffb:	e9 ed f2 ff ff       	jmp    801072ed <alltraps>

80108000 <vector174>:
.globl vector174
vector174:
  pushl $0
80108000:	6a 00                	push   $0x0
  pushl $174
80108002:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108007:	e9 e1 f2 ff ff       	jmp    801072ed <alltraps>

8010800c <vector175>:
.globl vector175
vector175:
  pushl $0
8010800c:	6a 00                	push   $0x0
  pushl $175
8010800e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108013:	e9 d5 f2 ff ff       	jmp    801072ed <alltraps>

80108018 <vector176>:
.globl vector176
vector176:
  pushl $0
80108018:	6a 00                	push   $0x0
  pushl $176
8010801a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010801f:	e9 c9 f2 ff ff       	jmp    801072ed <alltraps>

80108024 <vector177>:
.globl vector177
vector177:
  pushl $0
80108024:	6a 00                	push   $0x0
  pushl $177
80108026:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010802b:	e9 bd f2 ff ff       	jmp    801072ed <alltraps>

80108030 <vector178>:
.globl vector178
vector178:
  pushl $0
80108030:	6a 00                	push   $0x0
  pushl $178
80108032:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108037:	e9 b1 f2 ff ff       	jmp    801072ed <alltraps>

8010803c <vector179>:
.globl vector179
vector179:
  pushl $0
8010803c:	6a 00                	push   $0x0
  pushl $179
8010803e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108043:	e9 a5 f2 ff ff       	jmp    801072ed <alltraps>

80108048 <vector180>:
.globl vector180
vector180:
  pushl $0
80108048:	6a 00                	push   $0x0
  pushl $180
8010804a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010804f:	e9 99 f2 ff ff       	jmp    801072ed <alltraps>

80108054 <vector181>:
.globl vector181
vector181:
  pushl $0
80108054:	6a 00                	push   $0x0
  pushl $181
80108056:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010805b:	e9 8d f2 ff ff       	jmp    801072ed <alltraps>

80108060 <vector182>:
.globl vector182
vector182:
  pushl $0
80108060:	6a 00                	push   $0x0
  pushl $182
80108062:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108067:	e9 81 f2 ff ff       	jmp    801072ed <alltraps>

8010806c <vector183>:
.globl vector183
vector183:
  pushl $0
8010806c:	6a 00                	push   $0x0
  pushl $183
8010806e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108073:	e9 75 f2 ff ff       	jmp    801072ed <alltraps>

80108078 <vector184>:
.globl vector184
vector184:
  pushl $0
80108078:	6a 00                	push   $0x0
  pushl $184
8010807a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010807f:	e9 69 f2 ff ff       	jmp    801072ed <alltraps>

80108084 <vector185>:
.globl vector185
vector185:
  pushl $0
80108084:	6a 00                	push   $0x0
  pushl $185
80108086:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010808b:	e9 5d f2 ff ff       	jmp    801072ed <alltraps>

80108090 <vector186>:
.globl vector186
vector186:
  pushl $0
80108090:	6a 00                	push   $0x0
  pushl $186
80108092:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108097:	e9 51 f2 ff ff       	jmp    801072ed <alltraps>

8010809c <vector187>:
.globl vector187
vector187:
  pushl $0
8010809c:	6a 00                	push   $0x0
  pushl $187
8010809e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801080a3:	e9 45 f2 ff ff       	jmp    801072ed <alltraps>

801080a8 <vector188>:
.globl vector188
vector188:
  pushl $0
801080a8:	6a 00                	push   $0x0
  pushl $188
801080aa:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801080af:	e9 39 f2 ff ff       	jmp    801072ed <alltraps>

801080b4 <vector189>:
.globl vector189
vector189:
  pushl $0
801080b4:	6a 00                	push   $0x0
  pushl $189
801080b6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801080bb:	e9 2d f2 ff ff       	jmp    801072ed <alltraps>

801080c0 <vector190>:
.globl vector190
vector190:
  pushl $0
801080c0:	6a 00                	push   $0x0
  pushl $190
801080c2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801080c7:	e9 21 f2 ff ff       	jmp    801072ed <alltraps>

801080cc <vector191>:
.globl vector191
vector191:
  pushl $0
801080cc:	6a 00                	push   $0x0
  pushl $191
801080ce:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801080d3:	e9 15 f2 ff ff       	jmp    801072ed <alltraps>

801080d8 <vector192>:
.globl vector192
vector192:
  pushl $0
801080d8:	6a 00                	push   $0x0
  pushl $192
801080da:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801080df:	e9 09 f2 ff ff       	jmp    801072ed <alltraps>

801080e4 <vector193>:
.globl vector193
vector193:
  pushl $0
801080e4:	6a 00                	push   $0x0
  pushl $193
801080e6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801080eb:	e9 fd f1 ff ff       	jmp    801072ed <alltraps>

801080f0 <vector194>:
.globl vector194
vector194:
  pushl $0
801080f0:	6a 00                	push   $0x0
  pushl $194
801080f2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801080f7:	e9 f1 f1 ff ff       	jmp    801072ed <alltraps>

801080fc <vector195>:
.globl vector195
vector195:
  pushl $0
801080fc:	6a 00                	push   $0x0
  pushl $195
801080fe:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108103:	e9 e5 f1 ff ff       	jmp    801072ed <alltraps>

80108108 <vector196>:
.globl vector196
vector196:
  pushl $0
80108108:	6a 00                	push   $0x0
  pushl $196
8010810a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010810f:	e9 d9 f1 ff ff       	jmp    801072ed <alltraps>

80108114 <vector197>:
.globl vector197
vector197:
  pushl $0
80108114:	6a 00                	push   $0x0
  pushl $197
80108116:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010811b:	e9 cd f1 ff ff       	jmp    801072ed <alltraps>

80108120 <vector198>:
.globl vector198
vector198:
  pushl $0
80108120:	6a 00                	push   $0x0
  pushl $198
80108122:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108127:	e9 c1 f1 ff ff       	jmp    801072ed <alltraps>

8010812c <vector199>:
.globl vector199
vector199:
  pushl $0
8010812c:	6a 00                	push   $0x0
  pushl $199
8010812e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108133:	e9 b5 f1 ff ff       	jmp    801072ed <alltraps>

80108138 <vector200>:
.globl vector200
vector200:
  pushl $0
80108138:	6a 00                	push   $0x0
  pushl $200
8010813a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010813f:	e9 a9 f1 ff ff       	jmp    801072ed <alltraps>

80108144 <vector201>:
.globl vector201
vector201:
  pushl $0
80108144:	6a 00                	push   $0x0
  pushl $201
80108146:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010814b:	e9 9d f1 ff ff       	jmp    801072ed <alltraps>

80108150 <vector202>:
.globl vector202
vector202:
  pushl $0
80108150:	6a 00                	push   $0x0
  pushl $202
80108152:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108157:	e9 91 f1 ff ff       	jmp    801072ed <alltraps>

8010815c <vector203>:
.globl vector203
vector203:
  pushl $0
8010815c:	6a 00                	push   $0x0
  pushl $203
8010815e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108163:	e9 85 f1 ff ff       	jmp    801072ed <alltraps>

80108168 <vector204>:
.globl vector204
vector204:
  pushl $0
80108168:	6a 00                	push   $0x0
  pushl $204
8010816a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010816f:	e9 79 f1 ff ff       	jmp    801072ed <alltraps>

80108174 <vector205>:
.globl vector205
vector205:
  pushl $0
80108174:	6a 00                	push   $0x0
  pushl $205
80108176:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010817b:	e9 6d f1 ff ff       	jmp    801072ed <alltraps>

80108180 <vector206>:
.globl vector206
vector206:
  pushl $0
80108180:	6a 00                	push   $0x0
  pushl $206
80108182:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108187:	e9 61 f1 ff ff       	jmp    801072ed <alltraps>

8010818c <vector207>:
.globl vector207
vector207:
  pushl $0
8010818c:	6a 00                	push   $0x0
  pushl $207
8010818e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108193:	e9 55 f1 ff ff       	jmp    801072ed <alltraps>

80108198 <vector208>:
.globl vector208
vector208:
  pushl $0
80108198:	6a 00                	push   $0x0
  pushl $208
8010819a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010819f:	e9 49 f1 ff ff       	jmp    801072ed <alltraps>

801081a4 <vector209>:
.globl vector209
vector209:
  pushl $0
801081a4:	6a 00                	push   $0x0
  pushl $209
801081a6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801081ab:	e9 3d f1 ff ff       	jmp    801072ed <alltraps>

801081b0 <vector210>:
.globl vector210
vector210:
  pushl $0
801081b0:	6a 00                	push   $0x0
  pushl $210
801081b2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801081b7:	e9 31 f1 ff ff       	jmp    801072ed <alltraps>

801081bc <vector211>:
.globl vector211
vector211:
  pushl $0
801081bc:	6a 00                	push   $0x0
  pushl $211
801081be:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801081c3:	e9 25 f1 ff ff       	jmp    801072ed <alltraps>

801081c8 <vector212>:
.globl vector212
vector212:
  pushl $0
801081c8:	6a 00                	push   $0x0
  pushl $212
801081ca:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801081cf:	e9 19 f1 ff ff       	jmp    801072ed <alltraps>

801081d4 <vector213>:
.globl vector213
vector213:
  pushl $0
801081d4:	6a 00                	push   $0x0
  pushl $213
801081d6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801081db:	e9 0d f1 ff ff       	jmp    801072ed <alltraps>

801081e0 <vector214>:
.globl vector214
vector214:
  pushl $0
801081e0:	6a 00                	push   $0x0
  pushl $214
801081e2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801081e7:	e9 01 f1 ff ff       	jmp    801072ed <alltraps>

801081ec <vector215>:
.globl vector215
vector215:
  pushl $0
801081ec:	6a 00                	push   $0x0
  pushl $215
801081ee:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801081f3:	e9 f5 f0 ff ff       	jmp    801072ed <alltraps>

801081f8 <vector216>:
.globl vector216
vector216:
  pushl $0
801081f8:	6a 00                	push   $0x0
  pushl $216
801081fa:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801081ff:	e9 e9 f0 ff ff       	jmp    801072ed <alltraps>

80108204 <vector217>:
.globl vector217
vector217:
  pushl $0
80108204:	6a 00                	push   $0x0
  pushl $217
80108206:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010820b:	e9 dd f0 ff ff       	jmp    801072ed <alltraps>

80108210 <vector218>:
.globl vector218
vector218:
  pushl $0
80108210:	6a 00                	push   $0x0
  pushl $218
80108212:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108217:	e9 d1 f0 ff ff       	jmp    801072ed <alltraps>

8010821c <vector219>:
.globl vector219
vector219:
  pushl $0
8010821c:	6a 00                	push   $0x0
  pushl $219
8010821e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108223:	e9 c5 f0 ff ff       	jmp    801072ed <alltraps>

80108228 <vector220>:
.globl vector220
vector220:
  pushl $0
80108228:	6a 00                	push   $0x0
  pushl $220
8010822a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010822f:	e9 b9 f0 ff ff       	jmp    801072ed <alltraps>

80108234 <vector221>:
.globl vector221
vector221:
  pushl $0
80108234:	6a 00                	push   $0x0
  pushl $221
80108236:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010823b:	e9 ad f0 ff ff       	jmp    801072ed <alltraps>

80108240 <vector222>:
.globl vector222
vector222:
  pushl $0
80108240:	6a 00                	push   $0x0
  pushl $222
80108242:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108247:	e9 a1 f0 ff ff       	jmp    801072ed <alltraps>

8010824c <vector223>:
.globl vector223
vector223:
  pushl $0
8010824c:	6a 00                	push   $0x0
  pushl $223
8010824e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108253:	e9 95 f0 ff ff       	jmp    801072ed <alltraps>

80108258 <vector224>:
.globl vector224
vector224:
  pushl $0
80108258:	6a 00                	push   $0x0
  pushl $224
8010825a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010825f:	e9 89 f0 ff ff       	jmp    801072ed <alltraps>

80108264 <vector225>:
.globl vector225
vector225:
  pushl $0
80108264:	6a 00                	push   $0x0
  pushl $225
80108266:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010826b:	e9 7d f0 ff ff       	jmp    801072ed <alltraps>

80108270 <vector226>:
.globl vector226
vector226:
  pushl $0
80108270:	6a 00                	push   $0x0
  pushl $226
80108272:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108277:	e9 71 f0 ff ff       	jmp    801072ed <alltraps>

8010827c <vector227>:
.globl vector227
vector227:
  pushl $0
8010827c:	6a 00                	push   $0x0
  pushl $227
8010827e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108283:	e9 65 f0 ff ff       	jmp    801072ed <alltraps>

80108288 <vector228>:
.globl vector228
vector228:
  pushl $0
80108288:	6a 00                	push   $0x0
  pushl $228
8010828a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010828f:	e9 59 f0 ff ff       	jmp    801072ed <alltraps>

80108294 <vector229>:
.globl vector229
vector229:
  pushl $0
80108294:	6a 00                	push   $0x0
  pushl $229
80108296:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010829b:	e9 4d f0 ff ff       	jmp    801072ed <alltraps>

801082a0 <vector230>:
.globl vector230
vector230:
  pushl $0
801082a0:	6a 00                	push   $0x0
  pushl $230
801082a2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801082a7:	e9 41 f0 ff ff       	jmp    801072ed <alltraps>

801082ac <vector231>:
.globl vector231
vector231:
  pushl $0
801082ac:	6a 00                	push   $0x0
  pushl $231
801082ae:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801082b3:	e9 35 f0 ff ff       	jmp    801072ed <alltraps>

801082b8 <vector232>:
.globl vector232
vector232:
  pushl $0
801082b8:	6a 00                	push   $0x0
  pushl $232
801082ba:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801082bf:	e9 29 f0 ff ff       	jmp    801072ed <alltraps>

801082c4 <vector233>:
.globl vector233
vector233:
  pushl $0
801082c4:	6a 00                	push   $0x0
  pushl $233
801082c6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801082cb:	e9 1d f0 ff ff       	jmp    801072ed <alltraps>

801082d0 <vector234>:
.globl vector234
vector234:
  pushl $0
801082d0:	6a 00                	push   $0x0
  pushl $234
801082d2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801082d7:	e9 11 f0 ff ff       	jmp    801072ed <alltraps>

801082dc <vector235>:
.globl vector235
vector235:
  pushl $0
801082dc:	6a 00                	push   $0x0
  pushl $235
801082de:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801082e3:	e9 05 f0 ff ff       	jmp    801072ed <alltraps>

801082e8 <vector236>:
.globl vector236
vector236:
  pushl $0
801082e8:	6a 00                	push   $0x0
  pushl $236
801082ea:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801082ef:	e9 f9 ef ff ff       	jmp    801072ed <alltraps>

801082f4 <vector237>:
.globl vector237
vector237:
  pushl $0
801082f4:	6a 00                	push   $0x0
  pushl $237
801082f6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801082fb:	e9 ed ef ff ff       	jmp    801072ed <alltraps>

80108300 <vector238>:
.globl vector238
vector238:
  pushl $0
80108300:	6a 00                	push   $0x0
  pushl $238
80108302:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108307:	e9 e1 ef ff ff       	jmp    801072ed <alltraps>

8010830c <vector239>:
.globl vector239
vector239:
  pushl $0
8010830c:	6a 00                	push   $0x0
  pushl $239
8010830e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108313:	e9 d5 ef ff ff       	jmp    801072ed <alltraps>

80108318 <vector240>:
.globl vector240
vector240:
  pushl $0
80108318:	6a 00                	push   $0x0
  pushl $240
8010831a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010831f:	e9 c9 ef ff ff       	jmp    801072ed <alltraps>

80108324 <vector241>:
.globl vector241
vector241:
  pushl $0
80108324:	6a 00                	push   $0x0
  pushl $241
80108326:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010832b:	e9 bd ef ff ff       	jmp    801072ed <alltraps>

80108330 <vector242>:
.globl vector242
vector242:
  pushl $0
80108330:	6a 00                	push   $0x0
  pushl $242
80108332:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108337:	e9 b1 ef ff ff       	jmp    801072ed <alltraps>

8010833c <vector243>:
.globl vector243
vector243:
  pushl $0
8010833c:	6a 00                	push   $0x0
  pushl $243
8010833e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108343:	e9 a5 ef ff ff       	jmp    801072ed <alltraps>

80108348 <vector244>:
.globl vector244
vector244:
  pushl $0
80108348:	6a 00                	push   $0x0
  pushl $244
8010834a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010834f:	e9 99 ef ff ff       	jmp    801072ed <alltraps>

80108354 <vector245>:
.globl vector245
vector245:
  pushl $0
80108354:	6a 00                	push   $0x0
  pushl $245
80108356:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010835b:	e9 8d ef ff ff       	jmp    801072ed <alltraps>

80108360 <vector246>:
.globl vector246
vector246:
  pushl $0
80108360:	6a 00                	push   $0x0
  pushl $246
80108362:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108367:	e9 81 ef ff ff       	jmp    801072ed <alltraps>

8010836c <vector247>:
.globl vector247
vector247:
  pushl $0
8010836c:	6a 00                	push   $0x0
  pushl $247
8010836e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108373:	e9 75 ef ff ff       	jmp    801072ed <alltraps>

80108378 <vector248>:
.globl vector248
vector248:
  pushl $0
80108378:	6a 00                	push   $0x0
  pushl $248
8010837a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010837f:	e9 69 ef ff ff       	jmp    801072ed <alltraps>

80108384 <vector249>:
.globl vector249
vector249:
  pushl $0
80108384:	6a 00                	push   $0x0
  pushl $249
80108386:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010838b:	e9 5d ef ff ff       	jmp    801072ed <alltraps>

80108390 <vector250>:
.globl vector250
vector250:
  pushl $0
80108390:	6a 00                	push   $0x0
  pushl $250
80108392:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108397:	e9 51 ef ff ff       	jmp    801072ed <alltraps>

8010839c <vector251>:
.globl vector251
vector251:
  pushl $0
8010839c:	6a 00                	push   $0x0
  pushl $251
8010839e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801083a3:	e9 45 ef ff ff       	jmp    801072ed <alltraps>

801083a8 <vector252>:
.globl vector252
vector252:
  pushl $0
801083a8:	6a 00                	push   $0x0
  pushl $252
801083aa:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801083af:	e9 39 ef ff ff       	jmp    801072ed <alltraps>

801083b4 <vector253>:
.globl vector253
vector253:
  pushl $0
801083b4:	6a 00                	push   $0x0
  pushl $253
801083b6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801083bb:	e9 2d ef ff ff       	jmp    801072ed <alltraps>

801083c0 <vector254>:
.globl vector254
vector254:
  pushl $0
801083c0:	6a 00                	push   $0x0
  pushl $254
801083c2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801083c7:	e9 21 ef ff ff       	jmp    801072ed <alltraps>

801083cc <vector255>:
.globl vector255
vector255:
  pushl $0
801083cc:	6a 00                	push   $0x0
  pushl $255
801083ce:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801083d3:	e9 15 ef ff ff       	jmp    801072ed <alltraps>

801083d8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801083d8:	55                   	push   %ebp
801083d9:	89 e5                	mov    %esp,%ebp
801083db:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801083de:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e1:	83 e8 01             	sub    $0x1,%eax
801083e4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801083e8:	8b 45 08             	mov    0x8(%ebp),%eax
801083eb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801083ef:	8b 45 08             	mov    0x8(%ebp),%eax
801083f2:	c1 e8 10             	shr    $0x10,%eax
801083f5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801083f9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801083fc:	0f 01 10             	lgdtl  (%eax)
}
801083ff:	c9                   	leave  
80108400:	c3                   	ret    

80108401 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108401:	55                   	push   %ebp
80108402:	89 e5                	mov    %esp,%ebp
80108404:	83 ec 04             	sub    $0x4,%esp
80108407:	8b 45 08             	mov    0x8(%ebp),%eax
8010840a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010840e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108412:	0f 00 d8             	ltr    %ax
}
80108415:	c9                   	leave  
80108416:	c3                   	ret    

80108417 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108417:	55                   	push   %ebp
80108418:	89 e5                	mov    %esp,%ebp
8010841a:	83 ec 04             	sub    $0x4,%esp
8010841d:	8b 45 08             	mov    0x8(%ebp),%eax
80108420:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108424:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108428:	8e e8                	mov    %eax,%gs
}
8010842a:	c9                   	leave  
8010842b:	c3                   	ret    

8010842c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010842c:	55                   	push   %ebp
8010842d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010842f:	8b 45 08             	mov    0x8(%ebp),%eax
80108432:	0f 22 d8             	mov    %eax,%cr3
}
80108435:	5d                   	pop    %ebp
80108436:	c3                   	ret    

80108437 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108437:	55                   	push   %ebp
80108438:	89 e5                	mov    %esp,%ebp
8010843a:	8b 45 08             	mov    0x8(%ebp),%eax
8010843d:	05 00 00 00 80       	add    $0x80000000,%eax
80108442:	5d                   	pop    %ebp
80108443:	c3                   	ret    

80108444 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108444:	55                   	push   %ebp
80108445:	89 e5                	mov    %esp,%ebp
80108447:	8b 45 08             	mov    0x8(%ebp),%eax
8010844a:	05 00 00 00 80       	add    $0x80000000,%eax
8010844f:	5d                   	pop    %ebp
80108450:	c3                   	ret    

80108451 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108451:	55                   	push   %ebp
80108452:	89 e5                	mov    %esp,%ebp
80108454:	53                   	push   %ebx
80108455:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108458:	e8 fb b2 ff ff       	call   80103758 <cpunum>
8010845d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108463:	05 80 38 11 80       	add    $0x80113880,%eax
80108468:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010846b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108477:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010847d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108480:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108487:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010848b:	83 e2 f0             	and    $0xfffffff0,%edx
8010848e:	83 ca 0a             	or     $0xa,%edx
80108491:	88 50 7d             	mov    %dl,0x7d(%eax)
80108494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108497:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010849b:	83 ca 10             	or     $0x10,%edx
8010849e:	88 50 7d             	mov    %dl,0x7d(%eax)
801084a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084a8:	83 e2 9f             	and    $0xffffff9f,%edx
801084ab:	88 50 7d             	mov    %dl,0x7d(%eax)
801084ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084b5:	83 ca 80             	or     $0xffffff80,%edx
801084b8:	88 50 7d             	mov    %dl,0x7d(%eax)
801084bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084be:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084c2:	83 ca 0f             	or     $0xf,%edx
801084c5:	88 50 7e             	mov    %dl,0x7e(%eax)
801084c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084cf:	83 e2 ef             	and    $0xffffffef,%edx
801084d2:	88 50 7e             	mov    %dl,0x7e(%eax)
801084d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084dc:	83 e2 df             	and    $0xffffffdf,%edx
801084df:	88 50 7e             	mov    %dl,0x7e(%eax)
801084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084e9:	83 ca 40             	or     $0x40,%edx
801084ec:	88 50 7e             	mov    %dl,0x7e(%eax)
801084ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084f6:	83 ca 80             	or     $0xffffff80,%edx
801084f9:	88 50 7e             	mov    %dl,0x7e(%eax)
801084fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ff:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108506:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010850d:	ff ff 
8010850f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108512:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108519:	00 00 
8010851b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108528:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010852f:	83 e2 f0             	and    $0xfffffff0,%edx
80108532:	83 ca 02             	or     $0x2,%edx
80108535:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108545:	83 ca 10             	or     $0x10,%edx
80108548:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108558:	83 e2 9f             	and    $0xffffff9f,%edx
8010855b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010856b:	83 ca 80             	or     $0xffffff80,%edx
8010856e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010857e:	83 ca 0f             	or     $0xf,%edx
80108581:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108591:	83 e2 ef             	and    $0xffffffef,%edx
80108594:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010859a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085a4:	83 e2 df             	and    $0xffffffdf,%edx
801085a7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085b7:	83 ca 40             	or     $0x40,%edx
801085ba:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085ca:	83 ca 80             	or     $0xffffff80,%edx
801085cd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801085dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801085e7:	ff ff 
801085e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ec:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801085f3:	00 00 
801085f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801085ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108602:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108609:	83 e2 f0             	and    $0xfffffff0,%edx
8010860c:	83 ca 0a             	or     $0xa,%edx
8010860f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108618:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010861f:	83 ca 10             	or     $0x10,%edx
80108622:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108632:	83 ca 60             	or     $0x60,%edx
80108635:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010863b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108645:	83 ca 80             	or     $0xffffff80,%edx
80108648:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010864e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108651:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108658:	83 ca 0f             	or     $0xf,%edx
8010865b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108664:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010866b:	83 e2 ef             	and    $0xffffffef,%edx
8010866e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010867e:	83 e2 df             	and    $0xffffffdf,%edx
80108681:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108691:	83 ca 40             	or     $0x40,%edx
80108694:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086a4:	83 ca 80             	or     $0xffffff80,%edx
801086a7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801086b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ba:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801086c1:	ff ff 
801086c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c6:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801086cd:	00 00 
801086cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801086d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801086e3:	83 e2 f0             	and    $0xfffffff0,%edx
801086e6:	83 ca 02             	or     $0x2,%edx
801086e9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801086ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801086f9:	83 ca 10             	or     $0x10,%edx
801086fc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010870c:	83 ca 60             	or     $0x60,%edx
8010870f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010871f:	83 ca 80             	or     $0xffffff80,%edx
80108722:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108732:	83 ca 0f             	or     $0xf,%edx
80108735:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108745:	83 e2 ef             	and    $0xffffffef,%edx
80108748:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108758:	83 e2 df             	and    $0xffffffdf,%edx
8010875b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108764:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010876b:	83 ca 40             	or     $0x40,%edx
8010876e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108777:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010877e:	83 ca 80             	or     $0xffffff80,%edx
80108781:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108794:	05 b4 00 00 00       	add    $0xb4,%eax
80108799:	89 c3                	mov    %eax,%ebx
8010879b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879e:	05 b4 00 00 00       	add    $0xb4,%eax
801087a3:	c1 e8 10             	shr    $0x10,%eax
801087a6:	89 c1                	mov    %eax,%ecx
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	05 b4 00 00 00       	add    $0xb4,%eax
801087b0:	c1 e8 18             	shr    $0x18,%eax
801087b3:	89 c2                	mov    %eax,%edx
801087b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b8:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801087bf:	00 00 
801087c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c4:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801087d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801087de:	83 e1 f0             	and    $0xfffffff0,%ecx
801087e1:	83 c9 02             	or     $0x2,%ecx
801087e4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801087ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ed:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801087f4:	83 c9 10             	or     $0x10,%ecx
801087f7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801087fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108800:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108807:	83 e1 9f             	and    $0xffffff9f,%ecx
8010880a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108813:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010881a:	83 c9 80             	or     $0xffffff80,%ecx
8010881d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108826:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010882d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108830:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108839:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108840:	83 e1 ef             	and    $0xffffffef,%ecx
80108843:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108853:	83 e1 df             	and    $0xffffffdf,%ecx
80108856:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108866:	83 c9 40             	or     $0x40,%ecx
80108869:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010886f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108872:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108879:	83 c9 80             	or     $0xffffff80,%ecx
8010887c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108885:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010888b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888e:	83 c0 70             	add    $0x70,%eax
80108891:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108898:	00 
80108899:	89 04 24             	mov    %eax,(%esp)
8010889c:	e8 37 fb ff ff       	call   801083d8 <lgdt>
  loadgs(SEG_KCPU << 3);
801088a1:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801088a8:	e8 6a fb ff ff       	call   80108417 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
801088ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b0:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801088b6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801088bd:	00 00 00 00 
}
801088c1:	83 c4 24             	add    $0x24,%esp
801088c4:	5b                   	pop    %ebx
801088c5:	5d                   	pop    %ebp
801088c6:	c3                   	ret    

801088c7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801088c7:	55                   	push   %ebp
801088c8:	89 e5                	mov    %esp,%ebp
801088ca:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801088cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801088d0:	c1 e8 16             	shr    $0x16,%eax
801088d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088da:	8b 45 08             	mov    0x8(%ebp),%eax
801088dd:	01 d0                	add    %edx,%eax
801088df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801088e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e5:	8b 00                	mov    (%eax),%eax
801088e7:	83 e0 01             	and    $0x1,%eax
801088ea:	85 c0                	test   %eax,%eax
801088ec:	74 17                	je     80108905 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801088ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088f1:	8b 00                	mov    (%eax),%eax
801088f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088f8:	89 04 24             	mov    %eax,(%esp)
801088fb:	e8 44 fb ff ff       	call   80108444 <p2v>
80108900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108903:	eb 4b                	jmp    80108950 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108905:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108909:	74 0e                	je     80108919 <walkpgdir+0x52>
8010890b:	e8 b2 aa ff ff       	call   801033c2 <kalloc>
80108910:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108913:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108917:	75 07                	jne    80108920 <walkpgdir+0x59>
      return 0;
80108919:	b8 00 00 00 00       	mov    $0x0,%eax
8010891e:	eb 47                	jmp    80108967 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108920:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108927:	00 
80108928:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010892f:	00 
80108930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108933:	89 04 24             	mov    %eax,(%esp)
80108936:	e8 40 d3 ff ff       	call   80105c7b <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010893b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893e:	89 04 24             	mov    %eax,(%esp)
80108941:	e8 f1 fa ff ff       	call   80108437 <v2p>
80108946:	83 c8 07             	or     $0x7,%eax
80108949:	89 c2                	mov    %eax,%edx
8010894b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010894e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108950:	8b 45 0c             	mov    0xc(%ebp),%eax
80108953:	c1 e8 0c             	shr    $0xc,%eax
80108956:	25 ff 03 00 00       	and    $0x3ff,%eax
8010895b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108965:	01 d0                	add    %edx,%eax
}
80108967:	c9                   	leave  
80108968:	c3                   	ret    

80108969 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108969:	55                   	push   %ebp
8010896a:	89 e5                	mov    %esp,%ebp
8010896c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010896f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108972:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108977:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010897a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010897d:	8b 45 10             	mov    0x10(%ebp),%eax
80108980:	01 d0                	add    %edx,%eax
80108982:	83 e8 01             	sub    $0x1,%eax
80108985:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010898a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010898d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108994:	00 
80108995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108998:	89 44 24 04          	mov    %eax,0x4(%esp)
8010899c:	8b 45 08             	mov    0x8(%ebp),%eax
8010899f:	89 04 24             	mov    %eax,(%esp)
801089a2:	e8 20 ff ff ff       	call   801088c7 <walkpgdir>
801089a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801089aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089ae:	75 07                	jne    801089b7 <mappages+0x4e>
      return -1;
801089b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089b5:	eb 48                	jmp    801089ff <mappages+0x96>
    if(*pte & PTE_P)
801089b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ba:	8b 00                	mov    (%eax),%eax
801089bc:	83 e0 01             	and    $0x1,%eax
801089bf:	85 c0                	test   %eax,%eax
801089c1:	74 0c                	je     801089cf <mappages+0x66>
      panic("remap");
801089c3:	c7 04 24 64 99 10 80 	movl   $0x80109964,(%esp)
801089ca:	e8 6b 7b ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801089cf:	8b 45 18             	mov    0x18(%ebp),%eax
801089d2:	0b 45 14             	or     0x14(%ebp),%eax
801089d5:	83 c8 01             	or     $0x1,%eax
801089d8:	89 c2                	mov    %eax,%edx
801089da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089dd:	89 10                	mov    %edx,(%eax)
    if(a == last)
801089df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801089e5:	75 08                	jne    801089ef <mappages+0x86>
      break;
801089e7:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801089e8:	b8 00 00 00 00       	mov    $0x0,%eax
801089ed:	eb 10                	jmp    801089ff <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801089ef:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801089f6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801089fd:	eb 8e                	jmp    8010898d <mappages+0x24>
  return 0;
}
801089ff:	c9                   	leave  
80108a00:	c3                   	ret    

80108a01 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108a01:	55                   	push   %ebp
80108a02:	89 e5                	mov    %esp,%ebp
80108a04:	53                   	push   %ebx
80108a05:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108a08:	e8 b5 a9 ff ff       	call   801033c2 <kalloc>
80108a0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a14:	75 0a                	jne    80108a20 <setupkvm+0x1f>
    return 0;
80108a16:	b8 00 00 00 00       	mov    $0x0,%eax
80108a1b:	e9 98 00 00 00       	jmp    80108ab8 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108a20:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a27:	00 
80108a28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108a2f:	00 
80108a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a33:	89 04 24             	mov    %eax,(%esp)
80108a36:	e8 40 d2 ff ff       	call   80105c7b <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108a3b:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108a42:	e8 fd f9 ff ff       	call   80108444 <p2v>
80108a47:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108a4c:	76 0c                	jbe    80108a5a <setupkvm+0x59>
    panic("PHYSTOP too high");
80108a4e:	c7 04 24 6a 99 10 80 	movl   $0x8010996a,(%esp)
80108a55:	e8 e0 7a ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a5a:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108a61:	eb 49                	jmp    80108aac <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a66:	8b 48 0c             	mov    0xc(%eax),%ecx
80108a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6c:	8b 50 04             	mov    0x4(%eax),%edx
80108a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a72:	8b 58 08             	mov    0x8(%eax),%ebx
80108a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a78:	8b 40 04             	mov    0x4(%eax),%eax
80108a7b:	29 c3                	sub    %eax,%ebx
80108a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a80:	8b 00                	mov    (%eax),%eax
80108a82:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108a86:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108a8a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a95:	89 04 24             	mov    %eax,(%esp)
80108a98:	e8 cc fe ff ff       	call   80108969 <mappages>
80108a9d:	85 c0                	test   %eax,%eax
80108a9f:	79 07                	jns    80108aa8 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108aa1:	b8 00 00 00 00       	mov    $0x0,%eax
80108aa6:	eb 10                	jmp    80108ab8 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108aa8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108aac:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108ab3:	72 ae                	jb     80108a63 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108ab8:	83 c4 34             	add    $0x34,%esp
80108abb:	5b                   	pop    %ebx
80108abc:	5d                   	pop    %ebp
80108abd:	c3                   	ret    

80108abe <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108abe:	55                   	push   %ebp
80108abf:	89 e5                	mov    %esp,%ebp
80108ac1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108ac4:	e8 38 ff ff ff       	call   80108a01 <setupkvm>
80108ac9:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108ace:	e8 02 00 00 00       	call   80108ad5 <switchkvm>
}
80108ad3:	c9                   	leave  
80108ad4:	c3                   	ret    

80108ad5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108ad5:	55                   	push   %ebp
80108ad6:	89 e5                	mov    %esp,%ebp
80108ad8:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108adb:	a1 58 66 11 80       	mov    0x80116658,%eax
80108ae0:	89 04 24             	mov    %eax,(%esp)
80108ae3:	e8 4f f9 ff ff       	call   80108437 <v2p>
80108ae8:	89 04 24             	mov    %eax,(%esp)
80108aeb:	e8 3c f9 ff ff       	call   8010842c <lcr3>
}
80108af0:	c9                   	leave  
80108af1:	c3                   	ret    

80108af2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108af2:	55                   	push   %ebp
80108af3:	89 e5                	mov    %esp,%ebp
80108af5:	53                   	push   %ebx
80108af6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108af9:	e8 7d d0 ff ff       	call   80105b7b <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108afe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b04:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b0b:	83 c2 08             	add    $0x8,%edx
80108b0e:	89 d3                	mov    %edx,%ebx
80108b10:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b17:	83 c2 08             	add    $0x8,%edx
80108b1a:	c1 ea 10             	shr    $0x10,%edx
80108b1d:	89 d1                	mov    %edx,%ecx
80108b1f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b26:	83 c2 08             	add    $0x8,%edx
80108b29:	c1 ea 18             	shr    $0x18,%edx
80108b2c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108b33:	67 00 
80108b35:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108b3c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108b42:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108b49:	83 e1 f0             	and    $0xfffffff0,%ecx
80108b4c:	83 c9 09             	or     $0x9,%ecx
80108b4f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108b55:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108b5c:	83 c9 10             	or     $0x10,%ecx
80108b5f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108b65:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108b6c:	83 e1 9f             	and    $0xffffff9f,%ecx
80108b6f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108b75:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108b7c:	83 c9 80             	or     $0xffffff80,%ecx
80108b7f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108b85:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108b8c:	83 e1 f0             	and    $0xfffffff0,%ecx
80108b8f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108b95:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108b9c:	83 e1 ef             	and    $0xffffffef,%ecx
80108b9f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108ba5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108bac:	83 e1 df             	and    $0xffffffdf,%ecx
80108baf:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108bb5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108bbc:	83 c9 40             	or     $0x40,%ecx
80108bbf:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108bc5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108bcc:	83 e1 7f             	and    $0x7f,%ecx
80108bcf:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108bd5:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108bdb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108be1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108be8:	83 e2 ef             	and    $0xffffffef,%edx
80108beb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108bf1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108bf7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108bfd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c03:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108c0a:	8b 52 08             	mov    0x8(%edx),%edx
80108c0d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108c13:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108c16:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108c1d:	e8 df f7 ff ff       	call   80108401 <ltr>
  if(p->pgdir == 0)
80108c22:	8b 45 08             	mov    0x8(%ebp),%eax
80108c25:	8b 40 04             	mov    0x4(%eax),%eax
80108c28:	85 c0                	test   %eax,%eax
80108c2a:	75 0c                	jne    80108c38 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108c2c:	c7 04 24 7b 99 10 80 	movl   $0x8010997b,(%esp)
80108c33:	e8 02 79 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108c38:	8b 45 08             	mov    0x8(%ebp),%eax
80108c3b:	8b 40 04             	mov    0x4(%eax),%eax
80108c3e:	89 04 24             	mov    %eax,(%esp)
80108c41:	e8 f1 f7 ff ff       	call   80108437 <v2p>
80108c46:	89 04 24             	mov    %eax,(%esp)
80108c49:	e8 de f7 ff ff       	call   8010842c <lcr3>
  popcli();
80108c4e:	e8 6c cf ff ff       	call   80105bbf <popcli>
}
80108c53:	83 c4 14             	add    $0x14,%esp
80108c56:	5b                   	pop    %ebx
80108c57:	5d                   	pop    %ebp
80108c58:	c3                   	ret    

80108c59 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108c59:	55                   	push   %ebp
80108c5a:	89 e5                	mov    %esp,%ebp
80108c5c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108c5f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108c66:	76 0c                	jbe    80108c74 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108c68:	c7 04 24 8f 99 10 80 	movl   $0x8010998f,(%esp)
80108c6f:	e8 c6 78 ff ff       	call   8010053a <panic>
  mem = kalloc();
80108c74:	e8 49 a7 ff ff       	call   801033c2 <kalloc>
80108c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108c7c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c83:	00 
80108c84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108c8b:	00 
80108c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8f:	89 04 24             	mov    %eax,(%esp)
80108c92:	e8 e4 cf ff ff       	call   80105c7b <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9a:	89 04 24             	mov    %eax,(%esp)
80108c9d:	e8 95 f7 ff ff       	call   80108437 <v2p>
80108ca2:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108ca9:	00 
80108caa:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108cae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108cb5:	00 
80108cb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108cbd:	00 
80108cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc1:	89 04 24             	mov    %eax,(%esp)
80108cc4:	e8 a0 fc ff ff       	call   80108969 <mappages>
  memmove(mem, init, sz);
80108cc9:	8b 45 10             	mov    0x10(%ebp),%eax
80108ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
80108cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cda:	89 04 24             	mov    %eax,(%esp)
80108cdd:	e8 68 d0 ff ff       	call   80105d4a <memmove>
}
80108ce2:	c9                   	leave  
80108ce3:	c3                   	ret    

80108ce4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108ce4:	55                   	push   %ebp
80108ce5:	89 e5                	mov    %esp,%ebp
80108ce7:	53                   	push   %ebx
80108ce8:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cee:	25 ff 0f 00 00       	and    $0xfff,%eax
80108cf3:	85 c0                	test   %eax,%eax
80108cf5:	74 0c                	je     80108d03 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108cf7:	c7 04 24 ac 99 10 80 	movl   $0x801099ac,(%esp)
80108cfe:	e8 37 78 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108d03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d0a:	e9 a9 00 00 00       	jmp    80108db8 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d12:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d15:	01 d0                	add    %edx,%eax
80108d17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d1e:	00 
80108d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d23:	8b 45 08             	mov    0x8(%ebp),%eax
80108d26:	89 04 24             	mov    %eax,(%esp)
80108d29:	e8 99 fb ff ff       	call   801088c7 <walkpgdir>
80108d2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d31:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d35:	75 0c                	jne    80108d43 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108d37:	c7 04 24 cf 99 10 80 	movl   $0x801099cf,(%esp)
80108d3e:	e8 f7 77 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108d43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d46:	8b 00                	mov    (%eax),%eax
80108d48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d53:	8b 55 18             	mov    0x18(%ebp),%edx
80108d56:	29 c2                	sub    %eax,%edx
80108d58:	89 d0                	mov    %edx,%eax
80108d5a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108d5f:	77 0f                	ja     80108d70 <loaduvm+0x8c>
      n = sz - i;
80108d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d64:	8b 55 18             	mov    0x18(%ebp),%edx
80108d67:	29 c2                	sub    %eax,%edx
80108d69:	89 d0                	mov    %edx,%eax
80108d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d6e:	eb 07                	jmp    80108d77 <loaduvm+0x93>
    else
      n = PGSIZE;
80108d70:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7a:	8b 55 14             	mov    0x14(%ebp),%edx
80108d7d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108d80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d83:	89 04 24             	mov    %eax,(%esp)
80108d86:	e8 b9 f6 ff ff       	call   80108444 <p2v>
80108d8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108d8e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108d92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108d96:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d9a:	8b 45 10             	mov    0x10(%ebp),%eax
80108d9d:	89 04 24             	mov    %eax,(%esp)
80108da0:	e8 d8 96 ff ff       	call   8010247d <readi>
80108da5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108da8:	74 07                	je     80108db1 <loaduvm+0xcd>
      return -1;
80108daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108daf:	eb 18                	jmp    80108dc9 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108db1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dbb:	3b 45 18             	cmp    0x18(%ebp),%eax
80108dbe:	0f 82 4b ff ff ff    	jb     80108d0f <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108dc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108dc9:	83 c4 24             	add    $0x24,%esp
80108dcc:	5b                   	pop    %ebx
80108dcd:	5d                   	pop    %ebp
80108dce:	c3                   	ret    

80108dcf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108dcf:	55                   	push   %ebp
80108dd0:	89 e5                	mov    %esp,%ebp
80108dd2:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108dd5:	8b 45 10             	mov    0x10(%ebp),%eax
80108dd8:	85 c0                	test   %eax,%eax
80108dda:	79 0a                	jns    80108de6 <allocuvm+0x17>
    return 0;
80108ddc:	b8 00 00 00 00       	mov    $0x0,%eax
80108de1:	e9 c1 00 00 00       	jmp    80108ea7 <allocuvm+0xd8>
  if(newsz < oldsz)
80108de6:	8b 45 10             	mov    0x10(%ebp),%eax
80108de9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108dec:	73 08                	jae    80108df6 <allocuvm+0x27>
    return oldsz;
80108dee:	8b 45 0c             	mov    0xc(%ebp),%eax
80108df1:	e9 b1 00 00 00       	jmp    80108ea7 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108df6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108df9:	05 ff 0f 00 00       	add    $0xfff,%eax
80108dfe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108e06:	e9 8d 00 00 00       	jmp    80108e98 <allocuvm+0xc9>
    mem = kalloc();
80108e0b:	e8 b2 a5 ff ff       	call   801033c2 <kalloc>
80108e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108e13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e17:	75 2c                	jne    80108e45 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108e19:	c7 04 24 ed 99 10 80 	movl   $0x801099ed,(%esp)
80108e20:	e8 7b 75 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e28:	89 44 24 08          	mov    %eax,0x8(%esp)
80108e2c:	8b 45 10             	mov    0x10(%ebp),%eax
80108e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e33:	8b 45 08             	mov    0x8(%ebp),%eax
80108e36:	89 04 24             	mov    %eax,(%esp)
80108e39:	e8 6b 00 00 00       	call   80108ea9 <deallocuvm>
      return 0;
80108e3e:	b8 00 00 00 00       	mov    $0x0,%eax
80108e43:	eb 62                	jmp    80108ea7 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108e45:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108e4c:	00 
80108e4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108e54:	00 
80108e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e58:	89 04 24             	mov    %eax,(%esp)
80108e5b:	e8 1b ce ff ff       	call   80105c7b <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e63:	89 04 24             	mov    %eax,(%esp)
80108e66:	e8 cc f5 ff ff       	call   80108437 <v2p>
80108e6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e6e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108e75:	00 
80108e76:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108e7a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108e81:	00 
80108e82:	89 54 24 04          	mov    %edx,0x4(%esp)
80108e86:	8b 45 08             	mov    0x8(%ebp),%eax
80108e89:	89 04 24             	mov    %eax,(%esp)
80108e8c:	e8 d8 fa ff ff       	call   80108969 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108e91:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9b:	3b 45 10             	cmp    0x10(%ebp),%eax
80108e9e:	0f 82 67 ff ff ff    	jb     80108e0b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108ea4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108ea7:	c9                   	leave  
80108ea8:	c3                   	ret    

80108ea9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108ea9:	55                   	push   %ebp
80108eaa:	89 e5                	mov    %esp,%ebp
80108eac:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108eaf:	8b 45 10             	mov    0x10(%ebp),%eax
80108eb2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108eb5:	72 08                	jb     80108ebf <deallocuvm+0x16>
    return oldsz;
80108eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eba:	e9 a4 00 00 00       	jmp    80108f63 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108ebf:	8b 45 10             	mov    0x10(%ebp),%eax
80108ec2:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ecc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108ecf:	e9 80 00 00 00       	jmp    80108f54 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ede:	00 
80108edf:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee6:	89 04 24             	mov    %eax,(%esp)
80108ee9:	e8 d9 f9 ff ff       	call   801088c7 <walkpgdir>
80108eee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108ef1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ef5:	75 09                	jne    80108f00 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108ef7:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108efe:	eb 4d                	jmp    80108f4d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f03:	8b 00                	mov    (%eax),%eax
80108f05:	83 e0 01             	and    $0x1,%eax
80108f08:	85 c0                	test   %eax,%eax
80108f0a:	74 41                	je     80108f4d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f0f:	8b 00                	mov    (%eax),%eax
80108f11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f16:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108f19:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f1d:	75 0c                	jne    80108f2b <deallocuvm+0x82>
        panic("kfree");
80108f1f:	c7 04 24 05 9a 10 80 	movl   $0x80109a05,(%esp)
80108f26:	e8 0f 76 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108f2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f2e:	89 04 24             	mov    %eax,(%esp)
80108f31:	e8 0e f5 ff ff       	call   80108444 <p2v>
80108f36:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108f39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f3c:	89 04 24             	mov    %eax,(%esp)
80108f3f:	e8 e5 a3 ff ff       	call   80103329 <kfree>
      *pte = 0;
80108f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108f4d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f57:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f5a:	0f 82 74 ff ff ff    	jb     80108ed4 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108f60:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108f63:	c9                   	leave  
80108f64:	c3                   	ret    

80108f65 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108f65:	55                   	push   %ebp
80108f66:	89 e5                	mov    %esp,%ebp
80108f68:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108f6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108f6f:	75 0c                	jne    80108f7d <freevm+0x18>
    panic("freevm: no pgdir");
80108f71:	c7 04 24 0b 9a 10 80 	movl   $0x80109a0b,(%esp)
80108f78:	e8 bd 75 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108f7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f84:	00 
80108f85:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108f8c:	80 
80108f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f90:	89 04 24             	mov    %eax,(%esp)
80108f93:	e8 11 ff ff ff       	call   80108ea9 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108f98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f9f:	eb 48                	jmp    80108fe9 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fab:	8b 45 08             	mov    0x8(%ebp),%eax
80108fae:	01 d0                	add    %edx,%eax
80108fb0:	8b 00                	mov    (%eax),%eax
80108fb2:	83 e0 01             	and    $0x1,%eax
80108fb5:	85 c0                	test   %eax,%eax
80108fb7:	74 2c                	je     80108fe5 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80108fc6:	01 d0                	add    %edx,%eax
80108fc8:	8b 00                	mov    (%eax),%eax
80108fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fcf:	89 04 24             	mov    %eax,(%esp)
80108fd2:	e8 6d f4 ff ff       	call   80108444 <p2v>
80108fd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fdd:	89 04 24             	mov    %eax,(%esp)
80108fe0:	e8 44 a3 ff ff       	call   80103329 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108fe5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fe9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ff0:	76 af                	jbe    80108fa1 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ff5:	89 04 24             	mov    %eax,(%esp)
80108ff8:	e8 2c a3 ff ff       	call   80103329 <kfree>
}
80108ffd:	c9                   	leave  
80108ffe:	c3                   	ret    

80108fff <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108fff:	55                   	push   %ebp
80109000:	89 e5                	mov    %esp,%ebp
80109002:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109005:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010900c:	00 
8010900d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109010:	89 44 24 04          	mov    %eax,0x4(%esp)
80109014:	8b 45 08             	mov    0x8(%ebp),%eax
80109017:	89 04 24             	mov    %eax,(%esp)
8010901a:	e8 a8 f8 ff ff       	call   801088c7 <walkpgdir>
8010901f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109022:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109026:	75 0c                	jne    80109034 <clearpteu+0x35>
    panic("clearpteu");
80109028:	c7 04 24 1c 9a 10 80 	movl   $0x80109a1c,(%esp)
8010902f:	e8 06 75 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80109034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109037:	8b 00                	mov    (%eax),%eax
80109039:	83 e0 fb             	and    $0xfffffffb,%eax
8010903c:	89 c2                	mov    %eax,%edx
8010903e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109041:	89 10                	mov    %edx,(%eax)
}
80109043:	c9                   	leave  
80109044:	c3                   	ret    

80109045 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109045:	55                   	push   %ebp
80109046:	89 e5                	mov    %esp,%ebp
80109048:	53                   	push   %ebx
80109049:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010904c:	e8 b0 f9 ff ff       	call   80108a01 <setupkvm>
80109051:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109054:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109058:	75 0a                	jne    80109064 <copyuvm+0x1f>
    return 0;
8010905a:	b8 00 00 00 00       	mov    $0x0,%eax
8010905f:	e9 fd 00 00 00       	jmp    80109161 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80109064:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010906b:	e9 d0 00 00 00       	jmp    80109140 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109073:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010907a:	00 
8010907b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010907f:	8b 45 08             	mov    0x8(%ebp),%eax
80109082:	89 04 24             	mov    %eax,(%esp)
80109085:	e8 3d f8 ff ff       	call   801088c7 <walkpgdir>
8010908a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010908d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109091:	75 0c                	jne    8010909f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80109093:	c7 04 24 26 9a 10 80 	movl   $0x80109a26,(%esp)
8010909a:	e8 9b 74 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
8010909f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090a2:	8b 00                	mov    (%eax),%eax
801090a4:	83 e0 01             	and    $0x1,%eax
801090a7:	85 c0                	test   %eax,%eax
801090a9:	75 0c                	jne    801090b7 <copyuvm+0x72>
      panic("copyuvm: page not present");
801090ab:	c7 04 24 40 9a 10 80 	movl   $0x80109a40,(%esp)
801090b2:	e8 83 74 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801090b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ba:	8b 00                	mov    (%eax),%eax
801090bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801090c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090c7:	8b 00                	mov    (%eax),%eax
801090c9:	25 ff 0f 00 00       	and    $0xfff,%eax
801090ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801090d1:	e8 ec a2 ff ff       	call   801033c2 <kalloc>
801090d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801090d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801090dd:	75 02                	jne    801090e1 <copyuvm+0x9c>
      goto bad;
801090df:	eb 70                	jmp    80109151 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801090e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090e4:	89 04 24             	mov    %eax,(%esp)
801090e7:	e8 58 f3 ff ff       	call   80108444 <p2v>
801090ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801090f3:	00 
801090f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801090f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090fb:	89 04 24             	mov    %eax,(%esp)
801090fe:	e8 47 cc ff ff       	call   80105d4a <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109103:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109106:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109109:	89 04 24             	mov    %eax,(%esp)
8010910c:	e8 26 f3 ff ff       	call   80108437 <v2p>
80109111:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109114:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80109118:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010911c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109123:	00 
80109124:	89 54 24 04          	mov    %edx,0x4(%esp)
80109128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912b:	89 04 24             	mov    %eax,(%esp)
8010912e:	e8 36 f8 ff ff       	call   80108969 <mappages>
80109133:	85 c0                	test   %eax,%eax
80109135:	79 02                	jns    80109139 <copyuvm+0xf4>
      goto bad;
80109137:	eb 18                	jmp    80109151 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109139:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109143:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109146:	0f 82 24 ff ff ff    	jb     80109070 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010914c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010914f:	eb 10                	jmp    80109161 <copyuvm+0x11c>

bad:
  freevm(d);
80109151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109154:	89 04 24             	mov    %eax,(%esp)
80109157:	e8 09 fe ff ff       	call   80108f65 <freevm>
  return 0;
8010915c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109161:	83 c4 44             	add    $0x44,%esp
80109164:	5b                   	pop    %ebx
80109165:	5d                   	pop    %ebp
80109166:	c3                   	ret    

80109167 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109167:	55                   	push   %ebp
80109168:	89 e5                	mov    %esp,%ebp
8010916a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010916d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109174:	00 
80109175:	8b 45 0c             	mov    0xc(%ebp),%eax
80109178:	89 44 24 04          	mov    %eax,0x4(%esp)
8010917c:	8b 45 08             	mov    0x8(%ebp),%eax
8010917f:	89 04 24             	mov    %eax,(%esp)
80109182:	e8 40 f7 ff ff       	call   801088c7 <walkpgdir>
80109187:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010918a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918d:	8b 00                	mov    (%eax),%eax
8010918f:	83 e0 01             	and    $0x1,%eax
80109192:	85 c0                	test   %eax,%eax
80109194:	75 07                	jne    8010919d <uva2ka+0x36>
    return 0;
80109196:	b8 00 00 00 00       	mov    $0x0,%eax
8010919b:	eb 25                	jmp    801091c2 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010919d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a0:	8b 00                	mov    (%eax),%eax
801091a2:	83 e0 04             	and    $0x4,%eax
801091a5:	85 c0                	test   %eax,%eax
801091a7:	75 07                	jne    801091b0 <uva2ka+0x49>
    return 0;
801091a9:	b8 00 00 00 00       	mov    $0x0,%eax
801091ae:	eb 12                	jmp    801091c2 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801091b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b3:	8b 00                	mov    (%eax),%eax
801091b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091ba:	89 04 24             	mov    %eax,(%esp)
801091bd:	e8 82 f2 ff ff       	call   80108444 <p2v>
}
801091c2:	c9                   	leave  
801091c3:	c3                   	ret    

801091c4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801091c4:	55                   	push   %ebp
801091c5:	89 e5                	mov    %esp,%ebp
801091c7:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801091ca:	8b 45 10             	mov    0x10(%ebp),%eax
801091cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801091d0:	e9 87 00 00 00       	jmp    8010925c <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801091d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801091d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801091e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801091e7:	8b 45 08             	mov    0x8(%ebp),%eax
801091ea:	89 04 24             	mov    %eax,(%esp)
801091ed:	e8 75 ff ff ff       	call   80109167 <uva2ka>
801091f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801091f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801091f9:	75 07                	jne    80109202 <copyout+0x3e>
      return -1;
801091fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109200:	eb 69                	jmp    8010926b <copyout+0xa7>
    n = PGSIZE - (va - va0);
80109202:	8b 45 0c             	mov    0xc(%ebp),%eax
80109205:	8b 55 ec             	mov    -0x14(%ebp),%edx
80109208:	29 c2                	sub    %eax,%edx
8010920a:	89 d0                	mov    %edx,%eax
8010920c:	05 00 10 00 00       	add    $0x1000,%eax
80109211:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109214:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109217:	3b 45 14             	cmp    0x14(%ebp),%eax
8010921a:	76 06                	jbe    80109222 <copyout+0x5e>
      n = len;
8010921c:	8b 45 14             	mov    0x14(%ebp),%eax
8010921f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109225:	8b 55 0c             	mov    0xc(%ebp),%edx
80109228:	29 c2                	sub    %eax,%edx
8010922a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010922d:	01 c2                	add    %eax,%edx
8010922f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109232:	89 44 24 08          	mov    %eax,0x8(%esp)
80109236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109239:	89 44 24 04          	mov    %eax,0x4(%esp)
8010923d:	89 14 24             	mov    %edx,(%esp)
80109240:	e8 05 cb ff ff       	call   80105d4a <memmove>
    len -= n;
80109245:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109248:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010924b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109251:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109254:	05 00 10 00 00       	add    $0x1000,%eax
80109259:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010925c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109260:	0f 85 6f ff ff ff    	jne    801091d5 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109266:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010926b:	c9                   	leave  
8010926c:	c3                   	ret    
