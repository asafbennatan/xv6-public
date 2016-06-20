
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
8010002d:	b8 27 3f 10 80       	mov    $0x80103f27,%eax
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
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 e8 8b 10 80       	push   $0x80108be8
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 49 56 00 00       	call   80105695 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 f0 15 11 80 e4 	movl   $0x801115e4,0x801115f0
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 f4 15 11 80 e4 	movl   $0x801115e4,0x801115f4
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 14 d7 10 80 	movl   $0x8010d714,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 f4 15 11 80    	mov    0x801115f4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c e4 15 11 80 	movl   $0x801115e4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 f4 15 11 80       	mov    0x801115f4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 f4 15 11 80       	mov    %eax,0x801115f4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 e4 15 11 80       	mov    $0x801115e4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 e0 d6 10 80       	push   $0x8010d6e0
801000c1:	e8 f1 55 00 00       	call   801056b7 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 f4 15 11 80       	mov    0x801115f4,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 e0 d6 10 80       	push   $0x8010d6e0
8010010c:	e8 0d 56 00 00       	call   8010571e <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 92 52 00 00       	call   801053be <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 e4 15 11 80 	cmpl   $0x801115e4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 f0 15 11 80       	mov    0x801115f0,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 e0 d6 10 80       	push   $0x8010d6e0
80100188:	e8 91 55 00 00       	call   8010571e <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 e4 15 11 80 	cmpl   $0x801115e4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 ef 8b 10 80       	push   $0x80108bef
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 ab 2d 00 00       	call   80102f92 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 00 8c 10 80       	push   $0x80108c00
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 6a 2d 00 00       	call   80102f92 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 07 8c 10 80       	push   $0x80108c07
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 5d 54 00 00       	call   801056b7 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 f4 15 11 80    	mov    0x801115f4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c e4 15 11 80 	movl   $0x801115e4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 f4 15 11 80       	mov    0x801115f4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 f4 15 11 80       	mov    %eax,0x801115f4

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 eb 51 00 00       	call   801054a9 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 50 54 00 00       	call   8010571e <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 c5 10 80       	push   $0x8010c5c0
801003e2:	e8 d0 52 00 00       	call   801056b7 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 0e 8c 10 80       	push   $0x80108c0e
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 17 8c 10 80 	movl   $0x80108c17,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 c5 10 80       	push   $0x8010c5c0
8010055b:	e8 be 51 00 00       	call   8010571e <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 1e 8c 10 80       	push   $0x80108c1e
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 2d 8c 10 80       	push   $0x80108c2d
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 a9 51 00 00       	call   80105770 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 2f 8c 10 80       	push   $0x80108c2f
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 33 8c 10 80       	push   $0x80108c33
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 dd 52 00 00       	call   801059d9 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 f4 51 00 00       	call   8010591a <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 b5 6a 00 00       	call   80107270 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 a8 6a 00 00       	call   80107270 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 9b 6a 00 00       	call   80107270 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 8b 6a 00 00       	call   80107270 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 c5 10 80       	push   $0x8010c5c0
8010080e:	e8 a4 4e 00 00       	call   801056b7 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 e8 18 11 80       	mov    %eax,0x801118e8
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 e8 18 11 80    	mov    0x801118e8,%edx
80100870:	a1 e4 18 11 80       	mov    0x801118e4,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 60 18 11 80 	movzbl -0x7feee7a0(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 e8 18 11 80    	mov    0x801118e8,%edx
8010089e:	a1 e4 18 11 80       	mov    0x801118e4,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 e8 18 11 80       	mov    0x801118e8,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 e8 18 11 80       	mov    %eax,0x801118e8
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 e8 18 11 80    	mov    0x801118e8,%edx
801008dd:	a1 e0 18 11 80       	mov    0x801118e0,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 e8 18 11 80    	mov    %edx,0x801118e8
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 60 18 11 80    	mov    %dl,-0x7feee7a0(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100937:	8b 15 e0 18 11 80    	mov    0x801118e0,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 e8 18 11 80       	mov    0x801118e8,%eax
80100949:	a3 e4 18 11 80       	mov    %eax,0x801118e4
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 e0 18 11 80       	push   $0x801118e0
80100956:	e8 4e 4b 00 00       	call   801054a9 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 c5 10 80       	push   $0x8010c5c0
80100979:	e8 a0 4d 00 00       	call   8010571e <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 d8 4b 00 00       	call   80105564 <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;
//cprintf("consoleread \n");
  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 15 16 00 00       	call   80101fb5 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 01 4d 00 00       	call   801056b7 <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 c5 10 80       	push   $0x8010c5c0
801009d3:	e8 46 4d 00 00       	call   8010571e <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        //cprintf("cRead \n");
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 2e 14 00 00       	call   80101e14 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 e0 18 11 80       	push   $0x801118e0
80100a00:	e8 b9 49 00 00       	call   801053be <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp
//cprintf("consoleread \n");
  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 e0 18 11 80    	mov    0x801118e0,%edx
80100a0e:	a1 e4 18 11 80       	mov    0x801118e4,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 e0 18 11 80       	mov    0x801118e0,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 e0 18 11 80    	mov    %edx,0x801118e0
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 60 18 11 80 	movzbl -0x7feee7a0(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 e0 18 11 80       	mov    0x801118e0,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 e0 18 11 80       	mov    %eax,0x801118e0
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;
//cprintf("consoleread \n");
  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a7e:	e8 9b 4c 00 00       	call   8010571e <release>
80100a83:	83 c4 10             	add    $0x10,%esp
          //    cprintf("cRead2 \n");

  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 83 13 00 00       	call   80101e14 <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;
//cprintf("consolewrite \n");

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 04 15 00 00       	call   80101fb5 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 f6 4b 00 00       	call   801056b7 <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
  int i;
//cprintf("consolewrite \n");

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 c5 10 80       	push   $0x8010c5c0
80100afe:	e8 1b 4c 00 00       	call   8010571e <release>
80100b03:	83 c4 10             	add    $0x10,%esp
        //  cprintf("cWrite \n");

  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 03 13 00 00       	call   80101e14 <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 46 8c 10 80       	push   $0x80108c46
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 64 4b 00 00       	call   80105695 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 ec 21 11 80 a0 	movl   $0x80100aa0,0x801121ec
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 e8 21 11 80 8f 	movl   $0x8010098f,0x801121e8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 4a 3a 00 00       	call   801045a6 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 f4 25 00 00       	call   8010315f <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 66 30 00 00       	call   80103be5 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 03 20 00 00       	call   80102b8d <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 d6 30 00 00       	call   80103c71 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ce 03 00 00       	jmp    80100f73 <exec+0x402>
  }
           // cprintf("exec \n");

  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 64 12 00 00       	call   80101e14 <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp

  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 cb 18 00 00       	call   80102498 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 49 03 00 00    	jbe    80100f22 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3b 03 00 00    	jne    80100f25 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 d6 77 00 00       	call   801083c5 <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2c 03 00 00    	je     80100f28 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 6b 18 00 00       	call   80102498 <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f2 02 00 00    	jne    80100f2b <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d6 02 00 00    	jb     80100f2e <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 f7 7a 00 00       	call   8010876c <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ac 02 00 00    	je     80100f31 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 ed 79 00 00       	call   80108695 <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 81 02 00 00    	js     80100f34 <exec+0x3c3>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 36 14 00 00       	call   80102117 <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 88 2f 00 00       	call   80103c71 <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 55 7a 00 00       	call   8010876c <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 10 02 00 00    	je     80100f37 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 57 7c 00 00       	call   80108992 <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e0 01 00 00    	ja     80100f3a <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 f3 4d 00 00       	call   80105b67 <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 c6 4d 00 00       	call   80105b67 <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 82 7d 00 00       	call   80108b49 <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6b 01 00 00    	js     80100f3d <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 e6 7c 00 00       	call   80108b49 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d2 00 00 00    	js     80100f40 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 69 4c 00 00       	call   80105b1d <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 a2 75 00 00       	call   801084ac <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	ff 75 d0             	pushl  -0x30(%ebp)
80100f13:	e8 da 79 00 00       	call   801088f2 <freevm>
80100f18:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f20:	eb 51                	jmp    80100f73 <exec+0x402>

  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f22:	90                   	nop
80100f23:	eb 1c                	jmp    80100f41 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f25:	90                   	nop
80100f26:	eb 19                	jmp    80100f41 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f28:	90                   	nop
80100f29:	eb 16                	jmp    80100f41 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f2b:	90                   	nop
80100f2c:	eb 13                	jmp    80100f41 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f2e:	90                   	nop
80100f2f:	eb 10                	jmp    80100f41 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f31:	90                   	nop
80100f32:	eb 0d                	jmp    80100f41 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f34:	90                   	nop
80100f35:	eb 0a                	jmp    80100f41 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f37:	90                   	nop
80100f38:	eb 07                	jmp    80100f41 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f3a:	90                   	nop
80100f3b:	eb 04                	jmp    80100f41 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f3d:	90                   	nop
80100f3e:	eb 01                	jmp    80100f41 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f40:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f41:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f45:	74 0e                	je     80100f55 <exec+0x3e4>
    freevm(pgdir);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4d:	e8 a0 79 00 00       	call   801088f2 <freevm>
80100f52:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f55:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f59:	74 13                	je     80100f6e <exec+0x3fd>
    iunlockput(ip);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 d8             	pushl  -0x28(%ebp)
80100f61:	e8 b1 11 00 00       	call   80102117 <iunlockput>
80100f66:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f69:	e8 03 2d 00 00       	call   80103c71 <end_op>
  }
  return -1;
80100f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f73:	c9                   	leave  
80100f74:	c3                   	ret    

80100f75 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f75:	55                   	push   %ebp
80100f76:	89 e5                	mov    %esp,%ebp
80100f78:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f7b:	83 ec 08             	sub    $0x8,%esp
80100f7e:	68 4e 8c 10 80       	push   $0x80108c4e
80100f83:	68 00 19 11 80       	push   $0x80111900
80100f88:	e8 08 47 00 00       	call   80105695 <initlock>
80100f8d:	83 c4 10             	add    $0x10,%esp
}
80100f90:	90                   	nop
80100f91:	c9                   	leave  
80100f92:	c3                   	ret    

80100f93 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f93:	55                   	push   %ebp
80100f94:	89 e5                	mov    %esp,%ebp
80100f96:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f99:	83 ec 0c             	sub    $0xc,%esp
80100f9c:	68 00 19 11 80       	push   $0x80111900
80100fa1:	e8 11 47 00 00       	call   801056b7 <acquire>
80100fa6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa9:	c7 45 f4 34 19 11 80 	movl   $0x80111934,-0xc(%ebp)
80100fb0:	eb 2d                	jmp    80100fdf <filealloc+0x4c>
    if(f->ref == 0){
80100fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb5:	8b 40 04             	mov    0x4(%eax),%eax
80100fb8:	85 c0                	test   %eax,%eax
80100fba:	75 1f                	jne    80100fdb <filealloc+0x48>
      f->ref = 1;
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 00 19 11 80       	push   $0x80111900
80100fce:	e8 4b 47 00 00       	call   8010571e <release>
80100fd3:	83 c4 10             	add    $0x10,%esp
      return f;
80100fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd9:	eb 23                	jmp    80100ffe <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	83 45 f4 16          	addl   $0x16,-0xc(%ebp)
80100fdf:	b8 cc 21 11 80       	mov    $0x801121cc,%eax
80100fe4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe7:	72 c9                	jb     80100fb2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	68 00 19 11 80       	push   $0x80111900
80100ff1:	e8 28 47 00 00       	call   8010571e <release>
80100ff6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ffe:	c9                   	leave  
80100fff:	c3                   	ret    

80101000 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101000:	55                   	push   %ebp
80101001:	89 e5                	mov    %esp,%ebp
80101003:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101006:	83 ec 0c             	sub    $0xc,%esp
80101009:	68 00 19 11 80       	push   $0x80111900
8010100e:	e8 a4 46 00 00       	call   801056b7 <acquire>
80101013:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 40 04             	mov    0x4(%eax),%eax
8010101c:	85 c0                	test   %eax,%eax
8010101e:	7f 0d                	jg     8010102d <filedup+0x2d>
    panic("filedup");
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 55 8c 10 80       	push   $0x80108c55
80101028:	e8 39 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 40 04             	mov    0x4(%eax),%eax
80101033:	8d 50 01             	lea    0x1(%eax),%edx
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 00 19 11 80       	push   $0x80111900
80101044:	e8 d5 46 00 00       	call   8010571e <release>
80101049:	83 c4 10             	add    $0x10,%esp
  return f;
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010104f:	c9                   	leave  
80101050:	c3                   	ret    

80101051 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101051:	55                   	push   %ebp
80101052:	89 e5                	mov    %esp,%ebp
80101054:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101057:	83 ec 0c             	sub    $0xc,%esp
8010105a:	68 00 19 11 80       	push   $0x80111900
8010105f:	e8 53 46 00 00       	call   801056b7 <acquire>
80101064:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	8b 40 04             	mov    0x4(%eax),%eax
8010106d:	85 c0                	test   %eax,%eax
8010106f:	7f 0d                	jg     8010107e <fileclose+0x2d>
    panic("fileclose");
80101071:	83 ec 0c             	sub    $0xc,%esp
80101074:	68 5d 8c 10 80       	push   $0x80108c5d
80101079:	e8 e8 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
80101081:	8b 40 04             	mov    0x4(%eax),%eax
80101084:	8d 50 ff             	lea    -0x1(%eax),%edx
80101087:	8b 45 08             	mov    0x8(%ebp),%eax
8010108a:	89 50 04             	mov    %edx,0x4(%eax)
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8b 40 04             	mov    0x4(%eax),%eax
80101093:	85 c0                	test   %eax,%eax
80101095:	7e 15                	jle    801010ac <fileclose+0x5b>
    release(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 00 19 11 80       	push   $0x80111900
8010109f:	e8 7a 46 00 00       	call   8010571e <release>
801010a4:	83 c4 10             	add    $0x10,%esp
801010a7:	e9 8d 00 00 00       	jmp    80101139 <fileclose+0xe8>
    return;
  }
  ff = *f;
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 10                	mov    (%eax),%edx
801010b1:	89 55 e2             	mov    %edx,-0x1e(%ebp)
801010b4:	8b 50 04             	mov    0x4(%eax),%edx
801010b7:	89 55 e6             	mov    %edx,-0x1a(%ebp)
801010ba:	8b 50 08             	mov    0x8(%eax),%edx
801010bd:	89 55 ea             	mov    %edx,-0x16(%ebp)
801010c0:	8b 50 0c             	mov    0xc(%eax),%edx
801010c3:	89 55 ee             	mov    %edx,-0x12(%ebp)
801010c6:	8b 50 10             	mov    0x10(%eax),%edx
801010c9:	89 55 f2             	mov    %edx,-0xe(%ebp)
801010cc:	0f b7 40 14          	movzwl 0x14(%eax),%eax
801010d0:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  f->ref = 0;
801010d4:	8b 45 08             	mov    0x8(%ebp),%eax
801010d7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e7:	83 ec 0c             	sub    $0xc,%esp
801010ea:	68 00 19 11 80       	push   $0x80111900
801010ef:	e8 2a 46 00 00       	call   8010571e <release>
801010f4:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f7:	8b 45 e2             	mov    -0x1e(%ebp),%eax
801010fa:	83 f8 01             	cmp    $0x1,%eax
801010fd:	75 19                	jne    80101118 <fileclose+0xc7>
    pipeclose(ff.pipe, ff.writable);
801010ff:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
80101103:	0f be d0             	movsbl %al,%edx
80101106:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101109:	83 ec 08             	sub    $0x8,%esp
8010110c:	52                   	push   %edx
8010110d:	50                   	push   %eax
8010110e:	e8 fc 36 00 00       	call   8010480f <pipeclose>
80101113:	83 c4 10             	add    $0x10,%esp
80101116:	eb 21                	jmp    80101139 <fileclose+0xe8>
  else if(ff.type == FD_INODE){
80101118:	8b 45 e2             	mov    -0x1e(%ebp),%eax
8010111b:	83 f8 02             	cmp    $0x2,%eax
8010111e:	75 19                	jne    80101139 <fileclose+0xe8>
    begin_op();
80101120:	e8 c0 2a 00 00       	call   80103be5 <begin_op>
    iput(ff.ip);
80101125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101128:	83 ec 0c             	sub    $0xc,%esp
8010112b:	50                   	push   %eax
8010112c:	e8 f6 0e 00 00       	call   80102027 <iput>
80101131:	83 c4 10             	add    $0x10,%esp
    end_op();
80101134:	e8 38 2b 00 00       	call   80103c71 <end_op>
  }
}
80101139:	c9                   	leave  
8010113a:	c3                   	ret    

8010113b <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010113b:	55                   	push   %ebp
8010113c:	89 e5                	mov    %esp,%ebp
8010113e:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 00                	mov    (%eax),%eax
80101146:	83 f8 02             	cmp    $0x2,%eax
80101149:	75 40                	jne    8010118b <filestat+0x50>
      
    ilock(f->ip);
8010114b:	8b 45 08             	mov    0x8(%ebp),%eax
8010114e:	8b 40 0e             	mov    0xe(%eax),%eax
80101151:	83 ec 0c             	sub    $0xc,%esp
80101154:	50                   	push   %eax
80101155:	e8 ba 0c 00 00       	call   80101e14 <ilock>
8010115a:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	8b 40 0e             	mov    0xe(%eax),%eax
80101163:	83 ec 08             	sub    $0x8,%esp
80101166:	ff 75 0c             	pushl  0xc(%ebp)
80101169:	50                   	push   %eax
8010116a:	e8 e3 12 00 00       	call   80102452 <stati>
8010116f:	83 c4 10             	add    $0x10,%esp
   // cprintf("filestat \n");

    iunlock(f->ip);
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 0e             	mov    0xe(%eax),%eax
80101178:	83 ec 0c             	sub    $0xc,%esp
8010117b:	50                   	push   %eax
8010117c:	e8 34 0e 00 00       	call   80101fb5 <iunlock>
80101181:	83 c4 10             	add    $0x10,%esp
    return 0;
80101184:	b8 00 00 00 00       	mov    $0x0,%eax
80101189:	eb 05                	jmp    80101190 <filestat+0x55>
  }
  return -1;
8010118b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101190:	c9                   	leave  
80101191:	c3                   	ret    

80101192 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101192:	55                   	push   %ebp
80101193:	89 e5                	mov    %esp,%ebp
80101195:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010119f:	84 c0                	test   %al,%al
801011a1:	75 0a                	jne    801011ad <fileread+0x1b>
    return -1;
801011a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a8:	e9 9b 00 00 00       	jmp    80101248 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ad:	8b 45 08             	mov    0x8(%ebp),%eax
801011b0:	8b 00                	mov    (%eax),%eax
801011b2:	83 f8 01             	cmp    $0x1,%eax
801011b5:	75 1a                	jne    801011d1 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 40 0a             	mov    0xa(%eax),%eax
801011bd:	83 ec 04             	sub    $0x4,%esp
801011c0:	ff 75 10             	pushl  0x10(%ebp)
801011c3:	ff 75 0c             	pushl  0xc(%ebp)
801011c6:	50                   	push   %eax
801011c7:	e8 eb 37 00 00       	call   801049b7 <piperead>
801011cc:	83 c4 10             	add    $0x10,%esp
801011cf:	eb 77                	jmp    80101248 <fileread+0xb6>
  if(f->type == FD_INODE){
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	8b 00                	mov    (%eax),%eax
801011d6:	83 f8 02             	cmp    $0x2,%eax
801011d9:	75 60                	jne    8010123b <fileread+0xa9>
    ilock(f->ip);
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 40 0e             	mov    0xe(%eax),%eax
801011e1:	83 ec 0c             	sub    $0xc,%esp
801011e4:	50                   	push   %eax
801011e5:	e8 2a 0c 00 00       	call   80101e14 <ilock>
801011ea:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 50 12             	mov    0x12(%eax),%edx
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 40 0e             	mov    0xe(%eax),%eax
801011fc:	51                   	push   %ecx
801011fd:	52                   	push   %edx
801011fe:	ff 75 0c             	pushl  0xc(%ebp)
80101201:	50                   	push   %eax
80101202:	e8 91 12 00 00       	call   80102498 <readi>
80101207:	83 c4 10             	add    $0x10,%esp
8010120a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101211:	7e 11                	jle    80101224 <fileread+0x92>
      f->off += r;
80101213:	8b 45 08             	mov    0x8(%ebp),%eax
80101216:	8b 50 12             	mov    0x12(%eax),%edx
80101219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121c:	01 c2                	add    %eax,%edx
8010121e:	8b 45 08             	mov    0x8(%ebp),%eax
80101221:	89 50 12             	mov    %edx,0x12(%eax)
   // cprintf("fileread \n");

    iunlock(f->ip);
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 40 0e             	mov    0xe(%eax),%eax
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	50                   	push   %eax
8010122e:	e8 82 0d 00 00       	call   80101fb5 <iunlock>
80101233:	83 c4 10             	add    $0x10,%esp
    return r;
80101236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101239:	eb 0d                	jmp    80101248 <fileread+0xb6>
  }
  panic("fileread");
8010123b:	83 ec 0c             	sub    $0xc,%esp
8010123e:	68 67 8c 10 80       	push   $0x80108c67
80101243:	e8 1e f3 ff ff       	call   80100566 <panic>
}
80101248:	c9                   	leave  
80101249:	c3                   	ret    

8010124a <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010124a:	55                   	push   %ebp
8010124b:	89 e5                	mov    %esp,%ebp
8010124d:	53                   	push   %ebx
8010124e:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101258:	84 c0                	test   %al,%al
8010125a:	75 0a                	jne    80101266 <filewrite+0x1c>
    return -1;
8010125c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101261:	e9 1b 01 00 00       	jmp    80101381 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 00                	mov    (%eax),%eax
8010126b:	83 f8 01             	cmp    $0x1,%eax
8010126e:	75 1d                	jne    8010128d <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 40 0a             	mov    0xa(%eax),%eax
80101276:	83 ec 04             	sub    $0x4,%esp
80101279:	ff 75 10             	pushl  0x10(%ebp)
8010127c:	ff 75 0c             	pushl  0xc(%ebp)
8010127f:	50                   	push   %eax
80101280:	e8 34 36 00 00       	call   801048b9 <pipewrite>
80101285:	83 c4 10             	add    $0x10,%esp
80101288:	e9 f4 00 00 00       	jmp    80101381 <filewrite+0x137>
  if(f->type == FD_INODE){
8010128d:	8b 45 08             	mov    0x8(%ebp),%eax
80101290:	8b 00                	mov    (%eax),%eax
80101292:	83 f8 02             	cmp    $0x2,%eax
80101295:	0f 85 d9 00 00 00    	jne    80101374 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010129b:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012a9:	e9 a3 00 00 00       	jmp    80101351 <filewrite+0x107>
      int n1 = n - i;
801012ae:	8b 45 10             	mov    0x10(%ebp),%eax
801012b1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bd:	7e 06                	jle    801012c5 <filewrite+0x7b>
        n1 = max;
801012bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c2:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c5:	e8 1b 29 00 00       	call   80103be5 <begin_op>
      ilock(f->ip);
801012ca:	8b 45 08             	mov    0x8(%ebp),%eax
801012cd:	8b 40 0e             	mov    0xe(%eax),%eax
801012d0:	83 ec 0c             	sub    $0xc,%esp
801012d3:	50                   	push   %eax
801012d4:	e8 3b 0b 00 00       	call   80101e14 <ilock>
801012d9:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012dc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 50 12             	mov    0x12(%eax),%edx
801012e5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801012eb:	01 c3                	add    %eax,%ebx
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	8b 40 0e             	mov    0xe(%eax),%eax
801012f3:	51                   	push   %ecx
801012f4:	52                   	push   %edx
801012f5:	53                   	push   %ebx
801012f6:	50                   	push   %eax
801012f7:	e8 3c 13 00 00       	call   80102638 <writei>
801012fc:	83 c4 10             	add    $0x10,%esp
801012ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101302:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101306:	7e 11                	jle    80101319 <filewrite+0xcf>
        f->off += r;
80101308:	8b 45 08             	mov    0x8(%ebp),%eax
8010130b:	8b 50 12             	mov    0x12(%eax),%edx
8010130e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101311:	01 c2                	add    %eax,%edx
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	89 50 12             	mov    %edx,0x12(%eax)
       // cprintf("filewrite \n");

      iunlock(f->ip);
80101319:	8b 45 08             	mov    0x8(%ebp),%eax
8010131c:	8b 40 0e             	mov    0xe(%eax),%eax
8010131f:	83 ec 0c             	sub    $0xc,%esp
80101322:	50                   	push   %eax
80101323:	e8 8d 0c 00 00       	call   80101fb5 <iunlock>
80101328:	83 c4 10             	add    $0x10,%esp
      end_op();
8010132b:	e8 41 29 00 00       	call   80103c71 <end_op>

      if(r < 0)
80101330:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101334:	78 29                	js     8010135f <filewrite+0x115>
        break;
      if(r != n1)
80101336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101339:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133c:	74 0d                	je     8010134b <filewrite+0x101>
        panic("short filewrite");
8010133e:	83 ec 0c             	sub    $0xc,%esp
80101341:	68 70 8c 10 80       	push   $0x80108c70
80101346:	e8 1b f2 ff ff       	call   80100566 <panic>
      i += r;
8010134b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134e:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101354:	3b 45 10             	cmp    0x10(%ebp),%eax
80101357:	0f 8c 51 ff ff ff    	jl     801012ae <filewrite+0x64>
8010135d:	eb 01                	jmp    80101360 <filewrite+0x116>

      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010135f:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101363:	3b 45 10             	cmp    0x10(%ebp),%eax
80101366:	75 05                	jne    8010136d <filewrite+0x123>
80101368:	8b 45 10             	mov    0x10(%ebp),%eax
8010136b:	eb 14                	jmp    80101381 <filewrite+0x137>
8010136d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101372:	eb 0d                	jmp    80101381 <filewrite+0x137>
  }
  panic("filewrite");
80101374:	83 ec 0c             	sub    $0xc,%esp
80101377:	68 80 8c 10 80       	push   $0x80108c80
8010137c:	e8 e5 f1 ff ff       	call   80100566 <panic>
}
80101381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101384:	c9                   	leave  
80101385:	c3                   	ret    

80101386 <readsb>:
int bootfrom = -1;
int currentPart = -1;

// Read the super block.
void readsb(int dev, int partitionNumber)
{
80101386:	55                   	push   %ebp
80101387:	89 e5                	mov    %esp,%ebp
80101389:	83 ec 18             	sub    $0x18,%esp
    struct buf* bp;

    bp = bread(dev, mbrI.partitions[partitionNumber].offset);
8010138c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138f:	83 c0 1b             	add    $0x1b,%eax
80101392:	c1 e0 04             	shl    $0x4,%eax
80101395:	05 40 22 11 80       	add    $0x80112240,%eax
8010139a:	8b 50 16             	mov    0x16(%eax),%edx
8010139d:	8b 45 08             	mov    0x8(%ebp),%eax
801013a0:	83 ec 08             	sub    $0x8,%esp
801013a3:	52                   	push   %edx
801013a4:	50                   	push   %eax
801013a5:	e8 0c ee ff ff       	call   801001b6 <bread>
801013aa:	83 c4 10             	add    $0x10,%esp
801013ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memmove(&(sbs[partitionNumber]), bp->data, sizeof(struct superblock));
801013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b3:	8d 50 18             	lea    0x18(%eax),%edx
801013b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801013b9:	c1 e0 05             	shl    $0x5,%eax
801013bc:	05 60 d6 10 80       	add    $0x8010d660,%eax
801013c1:	83 ec 04             	sub    $0x4,%esp
801013c4:	6a 20                	push   $0x20
801013c6:	52                   	push   %edx
801013c7:	50                   	push   %eax
801013c8:	e8 0c 46 00 00       	call   801059d9 <memmove>
801013cd:	83 c4 10             	add    $0x10,%esp
    sbs[partitionNumber].offset=mbrI.partitions[partitionNumber].offset;
801013d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801013d3:	83 c0 1b             	add    $0x1b,%eax
801013d6:	c1 e0 04             	shl    $0x4,%eax
801013d9:	05 40 22 11 80       	add    $0x80112240,%eax
801013de:	8b 40 16             	mov    0x16(%eax),%eax
801013e1:	8b 55 0c             	mov    0xc(%ebp),%edx
801013e4:	c1 e2 05             	shl    $0x5,%edx
801013e7:	81 c2 70 d6 10 80    	add    $0x8010d670,%edx
801013ed:	89 42 0c             	mov    %eax,0xc(%edx)
    brelse(bp);
801013f0:	83 ec 0c             	sub    $0xc,%esp
801013f3:	ff 75 f4             	pushl  -0xc(%ebp)
801013f6:	e8 33 ee ff ff       	call   8010022e <brelse>
801013fb:	83 c4 10             	add    $0x10,%esp
}
801013fe:	90                   	nop
801013ff:	c9                   	leave  
80101400:	c3                   	ret    

80101401 <readmbr>:

void readmbr(int dev)
{
80101401:	55                   	push   %ebp
80101402:	89 e5                	mov    %esp,%ebp
80101404:	83 ec 18             	sub    $0x18,%esp
    struct buf* bp;

    bp = bread(dev, 0);
80101407:	8b 45 08             	mov    0x8(%ebp),%eax
8010140a:	83 ec 08             	sub    $0x8,%esp
8010140d:	6a 00                	push   $0x0
8010140f:	50                   	push   %eax
80101410:	e8 a1 ed ff ff       	call   801001b6 <bread>
80101415:	83 c4 10             	add    $0x10,%esp
80101418:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memmove(&mbrI, bp->data, sizeof(struct mbr));
8010141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141e:	83 c0 18             	add    $0x18,%eax
80101421:	83 ec 04             	sub    $0x4,%esp
80101424:	68 00 02 00 00       	push   $0x200
80101429:	50                   	push   %eax
8010142a:	68 40 22 11 80       	push   $0x80112240
8010142f:	e8 a5 45 00 00       	call   801059d9 <memmove>
80101434:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101437:	83 ec 0c             	sub    $0xc,%esp
8010143a:	ff 75 f4             	pushl  -0xc(%ebp)
8010143d:	e8 ec ed ff ff       	call   8010022e <brelse>
80101442:	83 c4 10             	add    $0x10,%esp
}
80101445:	90                   	nop
80101446:	c9                   	leave  
80101447:	c3                   	ret    

80101448 <bzero>:

// Zero a block.
static void bzero(int dev, int bno)
{
80101448:	55                   	push   %ebp
80101449:	89 e5                	mov    %esp,%ebp
8010144b:	83 ec 18             	sub    $0x18,%esp
    struct buf* bp;

    bp = bread(dev, bno);
8010144e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101451:	8b 45 08             	mov    0x8(%ebp),%eax
80101454:	83 ec 08             	sub    $0x8,%esp
80101457:	52                   	push   %edx
80101458:	50                   	push   %eax
80101459:	e8 58 ed ff ff       	call   801001b6 <bread>
8010145e:	83 c4 10             	add    $0x10,%esp
80101461:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(bp->data, 0, BSIZE);
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	83 c0 18             	add    $0x18,%eax
8010146a:	83 ec 04             	sub    $0x4,%esp
8010146d:	68 00 02 00 00       	push   $0x200
80101472:	6a 00                	push   $0x0
80101474:	50                   	push   %eax
80101475:	e8 a0 44 00 00       	call   8010591a <memset>
8010147a:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010147d:	83 ec 0c             	sub    $0xc,%esp
80101480:	ff 75 f4             	pushl  -0xc(%ebp)
80101483:	e8 95 29 00 00       	call   80103e1d <log_write>
80101488:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010148b:	83 ec 0c             	sub    $0xc,%esp
8010148e:	ff 75 f4             	pushl  -0xc(%ebp)
80101491:	e8 98 ed ff ff       	call   8010022e <brelse>
80101496:	83 c4 10             	add    $0x10,%esp
}
80101499:	90                   	nop
8010149a:	c9                   	leave  
8010149b:	c3                   	ret    

8010149c <balloc>:

// Blocks.

// Allocate a zeroed disk block.
static uint balloc(uint dev, int partitionNumber)
{
8010149c:	55                   	push   %ebp
8010149d:	89 e5                	mov    %esp,%ebp
8010149f:	83 ec 38             	sub    $0x38,%esp
    int b, bi, m;
    struct buf* bp;

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
801014a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801014a5:	c1 e0 05             	shl    $0x5,%eax
801014a8:	05 60 d6 10 80       	add    $0x8010d660,%eax
801014ad:	8b 10                	mov    (%eax),%edx
801014af:	89 55 c8             	mov    %edx,-0x38(%ebp)
801014b2:	8b 50 04             	mov    0x4(%eax),%edx
801014b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
801014b8:	8b 50 08             	mov    0x8(%eax),%edx
801014bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
801014be:	8b 50 0c             	mov    0xc(%eax),%edx
801014c1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801014c4:	8b 50 10             	mov    0x10(%eax),%edx
801014c7:	89 55 d8             	mov    %edx,-0x28(%ebp)
801014ca:	8b 50 14             	mov    0x14(%eax),%edx
801014cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
801014d0:	8b 50 18             	mov    0x18(%eax),%edx
801014d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801014d6:	8b 40 1c             	mov    0x1c(%eax),%eax
801014d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    bp = 0;
801014dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for (b = 0; b < sb.size; b += BPB) {
801014e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014ea:	e9 1b 01 00 00       	jmp    8010160a <balloc+0x16e>
        bp = bread(dev, BBLOCK(b, sb));
801014ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014f5:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c1             	cmovs  %ecx,%eax
80101500:	c1 f8 0c             	sar    $0xc,%eax
80101503:	89 c1                	mov    %eax,%ecx
80101505:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101508:	01 c8                	add    %ecx,%eax
8010150a:	01 d0                	add    %edx,%eax
8010150c:	83 ec 08             	sub    $0x8,%esp
8010150f:	50                   	push   %eax
80101510:	ff 75 08             	pushl  0x8(%ebp)
80101513:	e8 9e ec ff ff       	call   801001b6 <bread>
80101518:	83 c4 10             	add    $0x10,%esp
8010151b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
8010151e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101525:	e9 ad 00 00 00       	jmp    801015d7 <balloc+0x13b>
            m = 1 << (bi % 8);
8010152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152d:	99                   	cltd   
8010152e:	c1 ea 1d             	shr    $0x1d,%edx
80101531:	01 d0                	add    %edx,%eax
80101533:	83 e0 07             	and    $0x7,%eax
80101536:	29 d0                	sub    %edx,%eax
80101538:	ba 01 00 00 00       	mov    $0x1,%edx
8010153d:	89 c1                	mov    %eax,%ecx
8010153f:	d3 e2                	shl    %cl,%edx
80101541:	89 d0                	mov    %edx,%eax
80101543:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
80101546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101549:	8d 50 07             	lea    0x7(%eax),%edx
8010154c:	85 c0                	test   %eax,%eax
8010154e:	0f 48 c2             	cmovs  %edx,%eax
80101551:	c1 f8 03             	sar    $0x3,%eax
80101554:	89 c2                	mov    %eax,%edx
80101556:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101559:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010155e:	0f b6 c0             	movzbl %al,%eax
80101561:	23 45 e8             	and    -0x18(%ebp),%eax
80101564:	85 c0                	test   %eax,%eax
80101566:	75 6b                	jne    801015d3 <balloc+0x137>
                bp->data[bi / 8] |= m;         // Mark block in use.
80101568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156b:	8d 50 07             	lea    0x7(%eax),%edx
8010156e:	85 c0                	test   %eax,%eax
80101570:	0f 48 c2             	cmovs  %edx,%eax
80101573:	c1 f8 03             	sar    $0x3,%eax
80101576:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101579:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010157e:	89 d1                	mov    %edx,%ecx
80101580:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101583:	09 ca                	or     %ecx,%edx
80101585:	89 d1                	mov    %edx,%ecx
80101587:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010158a:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
                log_write(bp);
8010158e:	83 ec 0c             	sub    $0xc,%esp
80101591:	ff 75 ec             	pushl  -0x14(%ebp)
80101594:	e8 84 28 00 00       	call   80103e1d <log_write>
80101599:	83 c4 10             	add    $0x10,%esp
                brelse(bp);
8010159c:	83 ec 0c             	sub    $0xc,%esp
8010159f:	ff 75 ec             	pushl  -0x14(%ebp)
801015a2:	e8 87 ec ff ff       	call   8010022e <brelse>
801015a7:	83 c4 10             	add    $0x10,%esp
                bzero(dev, sb.offset +b + bi);
801015aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b0:	01 c2                	add    %eax,%edx
801015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b5:	01 d0                	add    %edx,%eax
801015b7:	89 c2                	mov    %eax,%edx
801015b9:	8b 45 08             	mov    0x8(%ebp),%eax
801015bc:	83 ec 08             	sub    $0x8,%esp
801015bf:	52                   	push   %edx
801015c0:	50                   	push   %eax
801015c1:	e8 82 fe ff ff       	call   80101448 <bzero>
801015c6:	83 c4 10             	add    $0x10,%esp
                return b + bi;
801015c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cf:	01 d0                	add    %edx,%eax
801015d1:	eb 52                	jmp    80101625 <balloc+0x189>
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
        bp = bread(dev, BBLOCK(b, sb));
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
801015d3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015d7:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015de:	7f 15                	jg     801015f5 <balloc+0x159>
801015e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e6:	01 d0                	add    %edx,%eax
801015e8:	89 c2                	mov    %eax,%edx
801015ea:	8b 45 c8             	mov    -0x38(%ebp),%eax
801015ed:	39 c2                	cmp    %eax,%edx
801015ef:	0f 82 35 ff ff ff    	jb     8010152a <balloc+0x8e>
                brelse(bp);
                bzero(dev, sb.offset +b + bi);
                return b + bi;
            }
        }
        brelse(bp);
801015f5:	83 ec 0c             	sub    $0xc,%esp
801015f8:	ff 75 ec             	pushl  -0x14(%ebp)
801015fb:	e8 2e ec ff ff       	call   8010022e <brelse>
80101600:	83 c4 10             	add    $0x10,%esp

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
80101603:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010160a:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010160d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101610:	39 c2                	cmp    %eax,%edx
80101612:	0f 87 d7 fe ff ff    	ja     801014ef <balloc+0x53>
                return b + bi;
            }
        }
        brelse(bp);
    }
    panic("balloc: out of blocks");
80101618:	83 ec 0c             	sub    $0xc,%esp
8010161b:	68 8c 8c 10 80       	push   $0x80108c8c
80101620:	e8 41 ef ff ff       	call   80100566 <panic>
}
80101625:	c9                   	leave  
80101626:	c3                   	ret    

80101627 <bfree>:

// Free a disk block.
static void bfree(int dev, uint b, int partitionNumber)
{
80101627:	55                   	push   %ebp
80101628:	89 e5                	mov    %esp,%ebp
8010162a:	83 ec 38             	sub    $0x38,%esp
      //  cprintf("bfree \n");

    struct buf* bp;
    int bi, m;
    struct superblock sb;
    sb = sbs[partitionNumber];
8010162d:	8b 45 10             	mov    0x10(%ebp),%eax
80101630:	c1 e0 05             	shl    $0x5,%eax
80101633:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101638:	8b 10                	mov    (%eax),%edx
8010163a:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010163d:	8b 50 04             	mov    0x4(%eax),%edx
80101640:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101643:	8b 50 08             	mov    0x8(%eax),%edx
80101646:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101649:	8b 50 0c             	mov    0xc(%eax),%edx
8010164c:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010164f:	8b 50 10             	mov    0x10(%eax),%edx
80101652:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101655:	8b 50 14             	mov    0x14(%eax),%edx
80101658:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010165b:	8b 50 18             	mov    0x18(%eax),%edx
8010165e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101661:	8b 40 1c             	mov    0x1c(%eax),%eax
80101664:	89 45 e8             	mov    %eax,-0x18(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101667:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010166a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010166d:	89 d1                	mov    %edx,%ecx
8010166f:	c1 e9 0c             	shr    $0xc,%ecx
80101672:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101675:	01 ca                	add    %ecx,%edx
80101677:	01 c2                	add    %eax,%edx
80101679:	8b 45 08             	mov    0x8(%ebp),%eax
8010167c:	83 ec 08             	sub    $0x8,%esp
8010167f:	52                   	push   %edx
80101680:	50                   	push   %eax
80101681:	e8 30 eb ff ff       	call   801001b6 <bread>
80101686:	83 c4 10             	add    $0x10,%esp
80101689:	89 45 f4             	mov    %eax,-0xc(%ebp)
    bi = b % BPB;
8010168c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010168f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101694:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = 1 << (bi % 8);
80101697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010169a:	99                   	cltd   
8010169b:	c1 ea 1d             	shr    $0x1d,%edx
8010169e:	01 d0                	add    %edx,%eax
801016a0:	83 e0 07             	and    $0x7,%eax
801016a3:	29 d0                	sub    %edx,%eax
801016a5:	ba 01 00 00 00       	mov    $0x1,%edx
801016aa:	89 c1                	mov    %eax,%ecx
801016ac:	d3 e2                	shl    %cl,%edx
801016ae:	89 d0                	mov    %edx,%eax
801016b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if ((bp->data[bi / 8] & m) == 0)
801016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b6:	8d 50 07             	lea    0x7(%eax),%edx
801016b9:	85 c0                	test   %eax,%eax
801016bb:	0f 48 c2             	cmovs  %edx,%eax
801016be:	c1 f8 03             	sar    $0x3,%eax
801016c1:	89 c2                	mov    %eax,%edx
801016c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c6:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801016cb:	0f b6 c0             	movzbl %al,%eax
801016ce:	23 45 ec             	and    -0x14(%ebp),%eax
801016d1:	85 c0                	test   %eax,%eax
801016d3:	75 0d                	jne    801016e2 <bfree+0xbb>
        panic("freeing free block");
801016d5:	83 ec 0c             	sub    $0xc,%esp
801016d8:	68 a2 8c 10 80       	push   $0x80108ca2
801016dd:	e8 84 ee ff ff       	call   80100566 <panic>
    bp->data[bi / 8] &= ~m;
801016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e5:	8d 50 07             	lea    0x7(%eax),%edx
801016e8:	85 c0                	test   %eax,%eax
801016ea:	0f 48 c2             	cmovs  %edx,%eax
801016ed:	c1 f8 03             	sar    $0x3,%eax
801016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f3:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016f8:	89 d1                	mov    %edx,%ecx
801016fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016fd:	f7 d2                	not    %edx
801016ff:	21 ca                	and    %ecx,%edx
80101701:	89 d1                	mov    %edx,%ecx
80101703:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101706:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
    log_write(bp);
8010170a:	83 ec 0c             	sub    $0xc,%esp
8010170d:	ff 75 f4             	pushl  -0xc(%ebp)
80101710:	e8 08 27 00 00       	call   80103e1d <log_write>
80101715:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101718:	83 ec 0c             	sub    $0xc,%esp
8010171b:	ff 75 f4             	pushl  -0xc(%ebp)
8010171e:	e8 0b eb ff ff       	call   8010022e <brelse>
80101723:	83 c4 10             	add    $0x10,%esp
}
80101726:	90                   	nop
80101727:	c9                   	leave  
80101728:	c3                   	ret    

80101729 <printMBR>:
    struct spinlock lock;
    struct inode inode[NINODE];
} icache;

void printMBR(struct mbr* m)
{
80101729:	55                   	push   %ebp
8010172a:	89 e5                	mov    %esp,%ebp
8010172c:	83 ec 18             	sub    $0x18,%esp


    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
8010172f:	83 ec 0c             	sub    $0xc,%esp
80101732:	68 b5 8c 10 80       	push   $0x80108cb5
80101737:	e8 8a ec ff ff       	call   801003c6 <cprintf>
8010173c:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPARTITIONS; i++) {
8010173f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101746:	e9 f5 00 00 00       	jmp    80101840 <printMBR+0x117>
        if (m->partitions[i].flags >1 && m->partitions[i].flags <4) {
8010174b:	8b 45 08             	mov    0x8(%ebp),%eax
8010174e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101751:	83 c2 1b             	add    $0x1b,%edx
80101754:	c1 e2 04             	shl    $0x4,%edx
80101757:	01 d0                	add    %edx,%eax
80101759:	8b 40 0e             	mov    0xe(%eax),%eax
8010175c:	83 f8 01             	cmp    $0x1,%eax
8010175f:	76 1f                	jbe    80101780 <printMBR+0x57>
80101761:	8b 45 08             	mov    0x8(%ebp),%eax
80101764:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101767:	83 c2 1b             	add    $0x1b,%edx
8010176a:	c1 e2 04             	shl    $0x4,%edx
8010176d:	01 d0                	add    %edx,%eax
8010176f:	8b 40 0e             	mov    0xe(%eax),%eax
80101772:	83 f8 03             	cmp    $0x3,%eax
80101775:	77 09                	ja     80101780 <printMBR+0x57>
            bootable = "YES";
80101777:	c7 45 f0 c0 8c 10 80 	movl   $0x80108cc0,-0x10(%ebp)
8010177e:	eb 07                	jmp    80101787 <printMBR+0x5e>

        } else {
            bootable = "NO";
80101780:	c7 45 f0 c4 8c 10 80 	movl   $0x80108cc4,-0x10(%ebp)
        }

        if (m->partitions[i].type >= 0 && m->partitions[i].type < NELEM(FS_TYPE) && FS_TYPE[m->partitions[i].type]) {
80101787:	8b 45 08             	mov    0x8(%ebp),%eax
8010178a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010178d:	83 c2 1b             	add    $0x1b,%edx
80101790:	c1 e2 04             	shl    $0x4,%edx
80101793:	01 d0                	add    %edx,%eax
80101795:	8b 40 12             	mov    0x12(%eax),%eax
80101798:	83 f8 01             	cmp    $0x1,%eax
8010179b:	77 39                	ja     801017d6 <printMBR+0xad>
8010179d:	8b 45 08             	mov    0x8(%ebp),%eax
801017a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017a3:	83 c2 1b             	add    $0x1b,%edx
801017a6:	c1 e2 04             	shl    $0x4,%edx
801017a9:	01 d0                	add    %edx,%eax
801017ab:	8b 40 12             	mov    0x12(%eax),%eax
801017ae:	8b 04 85 20 a0 10 80 	mov    -0x7fef5fe0(,%eax,4),%eax
801017b5:	85 c0                	test   %eax,%eax
801017b7:	74 1d                	je     801017d6 <printMBR+0xad>
            type = FS_TYPE[m->partitions[i].type];
801017b9:	8b 45 08             	mov    0x8(%ebp),%eax
801017bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017bf:	83 c2 1b             	add    $0x1b,%edx
801017c2:	c1 e2 04             	shl    $0x4,%edx
801017c5:	01 d0                	add    %edx,%eax
801017c7:	8b 40 12             	mov    0x12(%eax),%eax
801017ca:	8b 04 85 20 a0 10 80 	mov    -0x7fef5fe0(,%eax,4),%eax
801017d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801017d4:	eb 29                	jmp    801017ff <printMBR+0xd6>

        } else {
            type = "???";
801017d6:	c7 45 ec c7 8c 10 80 	movl   $0x80108cc7,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
801017dd:	8b 45 08             	mov    0x8(%ebp),%eax
801017e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017e3:	83 c2 1b             	add    $0x1b,%edx
801017e6:	c1 e2 04             	shl    $0x4,%edx
801017e9:	01 d0                	add    %edx,%eax
801017eb:	8b 40 12             	mov    0x12(%eax),%eax
801017ee:	83 ec 08             	sub    $0x8,%esp
801017f1:	50                   	push   %eax
801017f2:	68 cb 8c 10 80       	push   $0x80108ccb
801017f7:	e8 ca eb ff ff       	call   801003c6 <cprintf>
801017fc:	83 c4 10             	add    $0x10,%esp
        }

        cprintf("partition %d: bootable %s type %s offset %d size %d \n",
801017ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101802:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101805:	83 c2 1b             	add    $0x1b,%edx
80101808:	c1 e2 04             	shl    $0x4,%edx
8010180b:	01 d0                	add    %edx,%eax
8010180d:	8b 50 1a             	mov    0x1a(%eax),%edx
80101810:	8b 45 08             	mov    0x8(%ebp),%eax
80101813:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80101816:	83 c1 1b             	add    $0x1b,%ecx
80101819:	c1 e1 04             	shl    $0x4,%ecx
8010181c:	01 c8                	add    %ecx,%eax
8010181e:	8b 40 16             	mov    0x16(%eax),%eax
80101821:	83 ec 08             	sub    $0x8,%esp
80101824:	52                   	push   %edx
80101825:	50                   	push   %eax
80101826:	ff 75 ec             	pushl  -0x14(%ebp)
80101829:	ff 75 f0             	pushl  -0x10(%ebp)
8010182c:	ff 75 f4             	pushl  -0xc(%ebp)
8010182f:	68 e0 8c 10 80       	push   $0x80108ce0
80101834:	e8 8d eb ff ff       	call   801003c6 <cprintf>
80101839:	83 c4 20             	add    $0x20,%esp

    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
    for (i = 0; i < NPARTITIONS; i++) {
8010183c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101840:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80101844:	0f 8e 01 ff ff ff    	jle    8010174b <printMBR+0x22>
                bootable,
                type,
                m->partitions[i].offset,
                m->partitions[i].size);
    }
    cprintf("magic %s \n", m->magic);
8010184a:	8b 45 08             	mov    0x8(%ebp),%eax
8010184d:	05 fe 01 00 00       	add    $0x1fe,%eax
80101852:	83 ec 08             	sub    $0x8,%esp
80101855:	50                   	push   %eax
80101856:	68 16 8d 10 80       	push   $0x80108d16
8010185b:	e8 66 eb ff ff       	call   801003c6 <cprintf>
80101860:	83 c4 10             	add    $0x10,%esp
}
80101863:	90                   	nop
80101864:	c9                   	leave  
80101865:	c3                   	ret    

80101866 <initMbr>:

void initMbr(int dev)
{
80101866:	55                   	push   %ebp
80101867:	89 e5                	mov    %esp,%ebp
80101869:	83 ec 18             	sub    $0x18,%esp

   
    readmbr(dev);
8010186c:	83 ec 0c             	sub    $0xc,%esp
8010186f:	ff 75 08             	pushl  0x8(%ebp)
80101872:	e8 8a fb ff ff       	call   80101401 <readmbr>
80101877:	83 c4 10             	add    $0x10,%esp
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
8010187a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101881:	e9 f4 00 00 00       	jmp    8010197a <initMbr+0x114>
        if (mbrI.partitions[i].flags >= PART_BOOTABLE && bootfrom == -1) {
80101886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101889:	83 c0 1b             	add    $0x1b,%eax
8010188c:	c1 e0 04             	shl    $0x4,%eax
8010188f:	05 40 22 11 80       	add    $0x80112240,%eax
80101894:	8b 40 0e             	mov    0xe(%eax),%eax
80101897:	83 f8 01             	cmp    $0x1,%eax
8010189a:	76 1a                	jbe    801018b6 <initMbr+0x50>
8010189c:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801018a1:	83 f8 ff             	cmp    $0xffffffff,%eax
801018a4:	75 10                	jne    801018b6 <initMbr+0x50>
            bootfrom = i;
801018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a9:	a3 18 a0 10 80       	mov    %eax,0x8010a018
            currentPart = i;
801018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b1:	a3 1c a0 10 80       	mov    %eax,0x8010a01c
        }
        partitions[i].dev = dev;
801018b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801018b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018bc:	89 d0                	mov    %edx,%eax
801018be:	01 c0                	add    %eax,%eax
801018c0:	01 d0                	add    %edx,%eax
801018c2:	c1 e0 03             	shl    $0x3,%eax
801018c5:	05 00 18 11 80       	add    $0x80111800,%eax
801018ca:	89 08                	mov    %ecx,(%eax)
        partitions[i].flags = mbrI.partitions[i].flags;
801018cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cf:	83 c0 1b             	add    $0x1b,%eax
801018d2:	c1 e0 04             	shl    $0x4,%eax
801018d5:	05 40 22 11 80       	add    $0x80112240,%eax
801018da:	8b 48 0e             	mov    0xe(%eax),%ecx
801018dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018e0:	89 d0                	mov    %edx,%eax
801018e2:	01 c0                	add    %eax,%eax
801018e4:	01 d0                	add    %edx,%eax
801018e6:	c1 e0 03             	shl    $0x3,%eax
801018e9:	05 00 18 11 80       	add    $0x80111800,%eax
801018ee:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].type = mbrI.partitions[i].type;
801018f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f4:	83 c0 1b             	add    $0x1b,%eax
801018f7:	c1 e0 04             	shl    $0x4,%eax
801018fa:	05 40 22 11 80       	add    $0x80112240,%eax
801018ff:	8b 48 12             	mov    0x12(%eax),%ecx
80101902:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101905:	89 d0                	mov    %edx,%eax
80101907:	01 c0                	add    %eax,%eax
80101909:	01 d0                	add    %edx,%eax
8010190b:	c1 e0 03             	shl    $0x3,%eax
8010190e:	05 00 18 11 80       	add    $0x80111800,%eax
80101913:	89 48 08             	mov    %ecx,0x8(%eax)
        partitions[i].number = i;
80101916:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80101919:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010191c:	89 d0                	mov    %edx,%eax
8010191e:	01 c0                	add    %eax,%eax
80101920:	01 d0                	add    %edx,%eax
80101922:	c1 e0 03             	shl    $0x3,%eax
80101925:	05 10 18 11 80       	add    $0x80111810,%eax
8010192a:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].offset = mbrI.partitions[i].offset;
8010192d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101930:	83 c0 1b             	add    $0x1b,%eax
80101933:	c1 e0 04             	shl    $0x4,%eax
80101936:	05 40 22 11 80       	add    $0x80112240,%eax
8010193b:	8b 48 16             	mov    0x16(%eax),%ecx
8010193e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101941:	89 d0                	mov    %edx,%eax
80101943:	01 c0                	add    %eax,%eax
80101945:	01 d0                	add    %edx,%eax
80101947:	c1 e0 03             	shl    $0x3,%eax
8010194a:	05 00 18 11 80       	add    $0x80111800,%eax
8010194f:	89 48 0c             	mov    %ecx,0xc(%eax)
        partitions[i].size = mbrI.partitions[i].size;
80101952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101955:	83 c0 1b             	add    $0x1b,%eax
80101958:	c1 e0 04             	shl    $0x4,%eax
8010195b:	05 40 22 11 80       	add    $0x80112240,%eax
80101960:	8b 48 1a             	mov    0x1a(%eax),%ecx
80101963:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101966:	89 d0                	mov    %edx,%eax
80101968:	01 c0                	add    %eax,%eax
8010196a:	01 d0                	add    %edx,%eax
8010196c:	c1 e0 03             	shl    $0x3,%eax
8010196f:	05 10 18 11 80       	add    $0x80111810,%eax
80101974:	89 08                	mov    %ecx,(%eax)

   
    readmbr(dev);
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
80101976:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010197a:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
8010197e:	0f 8e 02 ff ff ff    	jle    80101886 <initMbr+0x20>
        partitions[i].type = mbrI.partitions[i].type;
        partitions[i].number = i;
        partitions[i].offset = mbrI.partitions[i].offset;
        partitions[i].size = mbrI.partitions[i].size;
    }
}
80101984:	90                   	nop
80101985:	c9                   	leave  
80101986:	c3                   	ret    

80101987 <iinit>:

int iinit(struct proc* p, int dev)
{
80101987:	55                   	push   %ebp
80101988:	89 e5                	mov    %esp,%ebp
8010198a:	57                   	push   %edi
8010198b:	56                   	push   %esi
8010198c:	53                   	push   %ebx
8010198d:	83 ec 4c             	sub    $0x4c,%esp
    struct inode* rootNode;
    struct superblock sb;
    // TODO: change ot iterate over all partitions

    initlock(&icache.lock, "icache");
80101990:	83 ec 08             	sub    $0x8,%esp
80101993:	68 21 8d 10 80       	push   $0x80108d21
80101998:	68 40 24 11 80       	push   $0x80112440
8010199d:	e8 f3 3c 00 00       	call   80105695 <initlock>
801019a2:	83 c4 10             	add    $0x10,%esp

    rootNode = p->cwd;
801019a5:	8b 45 08             	mov    0x8(%ebp),%eax
801019a8:	8b 40 68             	mov    0x68(%eax),%eax
801019ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // acquire(&icache.lock);

    initMbr(dev);
801019ae:	83 ec 0c             	sub    $0xc,%esp
801019b1:	ff 75 0c             	pushl  0xc(%ebp)
801019b4:	e8 ad fe ff ff       	call   80101866 <initMbr>
801019b9:	83 c4 10             	add    $0x10,%esp
    printMBR(&mbrI);
801019bc:	83 ec 0c             	sub    $0xc,%esp
801019bf:	68 40 22 11 80       	push   $0x80112240
801019c4:	e8 60 fd ff ff       	call   80101729 <printMBR>
801019c9:	83 c4 10             	add    $0x10,%esp
    cprintf("booting from %d \n",bootfrom);
801019cc:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801019d1:	83 ec 08             	sub    $0x8,%esp
801019d4:	50                   	push   %eax
801019d5:	68 28 8d 10 80       	push   $0x80108d28
801019da:	e8 e7 e9 ff ff       	call   801003c6 <cprintf>
801019df:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
801019e2:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801019e7:	83 f8 ff             	cmp    $0xffffffff,%eax
801019ea:	75 0d                	jne    801019f9 <iinit+0x72>
        panic("no bootable partition");
801019ec:	83 ec 0c             	sub    $0xc,%esp
801019ef:	68 3a 8d 10 80       	push   $0x80108d3a
801019f4:	e8 6d eb ff ff       	call   80100566 <panic>
    }
    readsb(dev, bootfrom);
801019f9:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801019fe:	83 ec 08             	sub    $0x8,%esp
80101a01:	50                   	push   %eax
80101a02:	ff 75 0c             	pushl  0xc(%ebp)
80101a05:	e8 7c f9 ff ff       	call   80101386 <readsb>
80101a0a:	83 c4 10             	add    $0x10,%esp
    sb = sbs[bootfrom];
80101a0d:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a12:	c1 e0 05             	shl    $0x5,%eax
80101a15:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101a1a:	8b 10                	mov    (%eax),%edx
80101a1c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80101a1f:	8b 50 04             	mov    0x4(%eax),%edx
80101a22:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101a25:	8b 50 08             	mov    0x8(%eax),%edx
80101a28:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101a2b:	8b 50 0c             	mov    0xc(%eax),%edx
80101a2e:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101a31:	8b 50 10             	mov    0x10(%eax),%edx
80101a34:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101a37:	8b 50 14             	mov    0x14(%eax),%edx
80101a3a:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101a3d:	8b 50 18             	mov    0x18(%eax),%edx
80101a40:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101a43:	8b 40 1c             	mov    0x1c(%eax),%eax
80101a46:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // set root inode
    rootNode->part = &(partitions[bootfrom]);
80101a49:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
80101a4f:	89 d0                	mov    %edx,%eax
80101a51:	01 c0                	add    %eax,%eax
80101a53:	01 d0                	add    %edx,%eax
80101a55:	c1 e0 03             	shl    $0x3,%eax
80101a58:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a61:	89 50 50             	mov    %edx,0x50(%eax)
    // release(&icache.lock);

    // cprintf("root node init %d \n",rootNode->part->offset);
    cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
80101a64:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101a67:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101a6a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80101a6d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80101a70:	89 4d b0             	mov    %ecx,-0x50(%ebp)
80101a73:	8b 7d d0             	mov    -0x30(%ebp),%edi
80101a76:	8b 75 cc             	mov    -0x34(%ebp),%esi
80101a79:	8b 5d c8             	mov    -0x38(%ebp),%ebx
80101a7c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
80101a7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101a82:	83 ec 0c             	sub    $0xc,%esp
80101a85:	52                   	push   %edx
80101a86:	ff 75 b4             	pushl  -0x4c(%ebp)
80101a89:	ff 75 b0             	pushl  -0x50(%ebp)
80101a8c:	57                   	push   %edi
80101a8d:	56                   	push   %esi
80101a8e:	53                   	push   %ebx
80101a8f:	51                   	push   %ecx
80101a90:	50                   	push   %eax
80101a91:	68 50 8d 10 80       	push   $0x80108d50
80101a96:	e8 2b e9 ff ff       	call   801003c6 <cprintf>
80101a9b:	83 c4 30             	add    $0x30,%esp
            sb.ninodes,
            sb.nlog,
            sb.logstart,
            sb.inodestart,
            sb.bmapstart);
            return bootfrom;
80101a9e:	a1 18 a0 10 80       	mov    0x8010a018,%eax
}
80101aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aa6:	5b                   	pop    %ebx
80101aa7:	5e                   	pop    %esi
80101aa8:	5f                   	pop    %edi
80101aa9:	5d                   	pop    %ebp
80101aaa:	c3                   	ret    

80101aab <ialloc>:

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
80101aab:	55                   	push   %ebp
80101aac:	89 e5                	mov    %esp,%ebp
80101aae:	83 ec 48             	sub    $0x48,%esp
80101ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ab4:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
     //cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
80101ab8:	8b 45 10             	mov    0x10(%ebp),%eax
80101abb:	c1 e0 05             	shl    $0x5,%eax
80101abe:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101ac3:	8b 10                	mov    (%eax),%edx
80101ac5:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101ac8:	8b 50 04             	mov    0x4(%eax),%edx
80101acb:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101ace:	8b 50 08             	mov    0x8(%eax),%edx
80101ad1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101ad4:	8b 50 0c             	mov    0xc(%eax),%edx
80101ad7:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101ada:	8b 50 10             	mov    0x10(%eax),%edx
80101add:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ae0:	8b 50 14             	mov    0x14(%eax),%edx
80101ae3:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ae6:	8b 50 18             	mov    0x18(%eax),%edx
80101ae9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101aec:	8b 40 1c             	mov    0x1c(%eax),%eax
80101aef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101af2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101af9:	e9 a5 00 00 00       	jmp    80101ba3 <ialloc+0xf8>
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
80101afe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b04:	89 d1                	mov    %edx,%ecx
80101b06:	c1 e9 03             	shr    $0x3,%ecx
80101b09:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101b0c:	01 ca                	add    %ecx,%edx
80101b0e:	01 d0                	add    %edx,%eax
80101b10:	83 ec 08             	sub    $0x8,%esp
80101b13:	50                   	push   %eax
80101b14:	ff 75 08             	pushl  0x8(%ebp)
80101b17:	e8 9a e6 ff ff       	call   801001b6 <bread>
80101b1c:	83 c4 10             	add    $0x10,%esp
80101b1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        dip = (struct dinode*)bp->data + inum % IPB;
80101b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b25:	8d 50 18             	lea    0x18(%eax),%edx
80101b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2b:	83 e0 07             	and    $0x7,%eax
80101b2e:	c1 e0 06             	shl    $0x6,%eax
80101b31:	01 d0                	add    %edx,%eax
80101b33:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (dip->type == 0) { // a free inode
80101b36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b39:	0f b7 00             	movzwl (%eax),%eax
80101b3c:	66 85 c0             	test   %ax,%ax
80101b3f:	75 50                	jne    80101b91 <ialloc+0xe6>
            memset(dip, 0, sizeof(*dip));
80101b41:	83 ec 04             	sub    $0x4,%esp
80101b44:	6a 40                	push   $0x40
80101b46:	6a 00                	push   $0x0
80101b48:	ff 75 ec             	pushl  -0x14(%ebp)
80101b4b:	e8 ca 3d 00 00       	call   8010591a <memset>
80101b50:	83 c4 10             	add    $0x10,%esp
            dip->type = type;
80101b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b56:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
80101b5a:	66 89 10             	mov    %dx,(%eax)
            log_write(bp); // mark it allocated on the disk
80101b5d:	83 ec 0c             	sub    $0xc,%esp
80101b60:	ff 75 f0             	pushl  -0x10(%ebp)
80101b63:	e8 b5 22 00 00       	call   80103e1d <log_write>
80101b68:	83 c4 10             	add    $0x10,%esp
            brelse(bp);
80101b6b:	83 ec 0c             	sub    $0xc,%esp
80101b6e:	ff 75 f0             	pushl  -0x10(%ebp)
80101b71:	e8 b8 e6 ff ff       	call   8010022e <brelse>
80101b76:	83 c4 10             	add    $0x10,%esp
            return iget(dev, inum, partitionNumber);
80101b79:	8b 55 10             	mov    0x10(%ebp),%edx
80101b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7f:	83 ec 04             	sub    $0x4,%esp
80101b82:	52                   	push   %edx
80101b83:	50                   	push   %eax
80101b84:	ff 75 08             	pushl  0x8(%ebp)
80101b87:	e8 38 01 00 00       	call   80101cc4 <iget>
80101b8c:	83 c4 10             	add    $0x10,%esp
80101b8f:	eb 2d                	jmp    80101bbe <ialloc+0x113>
        }
        brelse(bp);
80101b91:	83 ec 0c             	sub    $0xc,%esp
80101b94:	ff 75 f0             	pushl  -0x10(%ebp)
80101b97:	e8 92 e6 ff ff       	call   8010022e <brelse>
80101b9c:	83 c4 10             	add    $0x10,%esp
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101b9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ba3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba9:	39 c2                	cmp    %eax,%edx
80101bab:	0f 87 4d ff ff ff    	ja     80101afe <ialloc+0x53>
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
80101bb1:	83 ec 0c             	sub    $0xc,%esp
80101bb4:	68 ad 8d 10 80       	push   $0x80108dad
80101bb9:	e8 a8 e9 ff ff       	call   80100566 <panic>
}
80101bbe:	c9                   	leave  
80101bbf:	c3                   	ret    

80101bc0 <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{
80101bc0:	55                   	push   %ebp
80101bc1:	89 e5                	mov    %esp,%ebp
80101bc3:	83 ec 38             	sub    $0x38,%esp

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
80101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc9:	8b 40 50             	mov    0x50(%eax),%eax
80101bcc:	8b 40 14             	mov    0x14(%eax),%eax
80101bcf:	c1 e0 05             	shl    $0x5,%eax
80101bd2:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101bd7:	8b 10                	mov    (%eax),%edx
80101bd9:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101bdc:	8b 50 04             	mov    0x4(%eax),%edx
80101bdf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101be2:	8b 50 08             	mov    0x8(%eax),%edx
80101be5:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101be8:	8b 50 0c             	mov    0xc(%eax),%edx
80101beb:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101bee:	8b 50 10             	mov    0x10(%eax),%edx
80101bf1:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101bf4:	8b 50 14             	mov    0x14(%eax),%edx
80101bf7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101bfa:	8b 50 18             	mov    0x18(%eax),%edx
80101bfd:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101c00:	8b 40 1c             	mov    0x1c(%eax),%eax
80101c03:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101c06:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101c09:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0c:	8b 40 04             	mov    0x4(%eax),%eax
80101c0f:	c1 e8 03             	shr    $0x3,%eax
80101c12:	89 c1                	mov    %eax,%ecx
80101c14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c17:	01 c8                	add    %ecx,%eax
80101c19:	01 c2                	add    %eax,%edx
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	8b 00                	mov    (%eax),%eax
80101c20:	83 ec 08             	sub    $0x8,%esp
80101c23:	52                   	push   %edx
80101c24:	50                   	push   %eax
80101c25:	e8 8c e5 ff ff       	call   801001b6 <bread>
80101c2a:	83 c4 10             	add    $0x10,%esp
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum % IPB;
80101c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c33:	8d 50 18             	lea    0x18(%eax),%edx
80101c36:	8b 45 08             	mov    0x8(%ebp),%eax
80101c39:	8b 40 04             	mov    0x4(%eax),%eax
80101c3c:	83 e0 07             	and    $0x7,%eax
80101c3f:	c1 e0 06             	shl    $0x6,%eax
80101c42:	01 d0                	add    %edx,%eax
80101c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip->type = ip->type;
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c51:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5e:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6c:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c7a:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 50 18             	mov    0x18(%eax),%edx
80101c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c87:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8d 50 1c             	lea    0x1c(%eax),%edx
80101c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c93:	83 c0 0c             	add    $0xc,%eax
80101c96:	83 ec 04             	sub    $0x4,%esp
80101c99:	6a 34                	push   $0x34
80101c9b:	52                   	push   %edx
80101c9c:	50                   	push   %eax
80101c9d:	e8 37 3d 00 00       	call   801059d9 <memmove>
80101ca2:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80101ca5:	83 ec 0c             	sub    $0xc,%esp
80101ca8:	ff 75 f4             	pushl  -0xc(%ebp)
80101cab:	e8 6d 21 00 00       	call   80103e1d <log_write>
80101cb0:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	ff 75 f4             	pushl  -0xc(%ebp)
80101cb9:	e8 70 e5 ff ff       	call   8010022e <brelse>
80101cbe:	83 c4 10             	add    $0x10,%esp
}
80101cc1:	90                   	nop
80101cc2:	c9                   	leave  
80101cc3:	c3                   	ret    

80101cc4 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
80101cc4:	55                   	push   %ebp
80101cc5:	89 e5                	mov    %esp,%ebp
80101cc7:	83 ec 18             	sub    $0x18,%esp
    struct inode* ip, *empty;

    acquire(&icache.lock);
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	68 40 24 11 80       	push   $0x80112440
80101cd2:	e8 e0 39 00 00       	call   801056b7 <acquire>
80101cd7:	83 c4 10             	add    $0x10,%esp
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
80101cda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101ce1:	c7 45 f4 74 24 11 80 	movl   $0x80112474,-0xc(%ebp)
80101ce8:	eb 78                	jmp    80101d62 <iget+0x9e>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
80101cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ced:	8b 40 08             	mov    0x8(%eax),%eax
80101cf0:	85 c0                	test   %eax,%eax
80101cf2:	7e 54                	jle    80101d48 <iget+0x84>
80101cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf7:	8b 00                	mov    (%eax),%eax
80101cf9:	3b 45 08             	cmp    0x8(%ebp),%eax
80101cfc:	75 4a                	jne    80101d48 <iget+0x84>
80101cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d01:	8b 40 04             	mov    0x4(%eax),%eax
80101d04:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101d07:	75 3f                	jne    80101d48 <iget+0x84>
80101d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d0c:	8b 40 50             	mov    0x50(%eax),%eax
80101d0f:	85 c0                	test   %eax,%eax
80101d11:	74 35                	je     80101d48 <iget+0x84>
80101d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d16:	8b 40 50             	mov    0x50(%eax),%eax
80101d19:	8b 40 14             	mov    0x14(%eax),%eax
80101d1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80101d1f:	75 27                	jne    80101d48 <iget+0x84>
            ip->ref++;
80101d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d24:	8b 40 08             	mov    0x8(%eax),%eax
80101d27:	8d 50 01             	lea    0x1(%eax),%edx
80101d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2d:	89 50 08             	mov    %edx,0x8(%eax)
            release(&icache.lock);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	68 40 24 11 80       	push   $0x80112440
80101d38:	e8 e1 39 00 00       	call   8010571e <release>
80101d3d:	83 c4 10             	add    $0x10,%esp
            return ip;
80101d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d43:	e9 90 00 00 00       	jmp    80101dd8 <iget+0x114>
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101d48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101d4c:	75 10                	jne    80101d5e <iget+0x9a>
80101d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d51:	8b 40 08             	mov    0x8(%eax),%eax
80101d54:	85 c0                	test   %eax,%eax
80101d56:	75 06                	jne    80101d5e <iget+0x9a>
            empty = ip;
80101d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&icache.lock);
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101d5e:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101d62:	81 7d f4 dc 34 11 80 	cmpl   $0x801134dc,-0xc(%ebp)
80101d69:	0f 82 7b ff ff ff    	jb     80101cea <iget+0x26>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
80101d6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101d73:	75 0d                	jne    80101d82 <iget+0xbe>
        panic("iget: no inodes");
80101d75:	83 ec 0c             	sub    $0xc,%esp
80101d78:	68 bf 8d 10 80       	push   $0x80108dbf
80101d7d:	e8 e4 e7 ff ff       	call   80100566 <panic>

    ip = empty;
80101d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip->dev = dev;
80101d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d8b:	8b 55 08             	mov    0x8(%ebp),%edx
80101d8e:	89 10                	mov    %edx,(%eax)
    ip->inum = inum;
80101d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d96:	89 50 04             	mov    %edx,0x4(%eax)
    ip->part = &(partitions[partitionNumber]);
80101d99:	8b 55 10             	mov    0x10(%ebp),%edx
80101d9c:	89 d0                	mov    %edx,%eax
80101d9e:	01 c0                	add    %eax,%eax
80101da0:	01 d0                	add    %edx,%eax
80101da2:	c1 e0 03             	shl    $0x3,%eax
80101da5:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dae:	89 50 50             	mov    %edx,0x50(%eax)
    ip->ref = 1;
80101db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101db4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    ip->flags = 0;
80101dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dbe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    release(&icache.lock);
80101dc5:	83 ec 0c             	sub    $0xc,%esp
80101dc8:	68 40 24 11 80       	push   $0x80112440
80101dcd:	e8 4c 39 00 00       	call   8010571e <release>
80101dd2:	83 c4 10             	add    $0x10,%esp

    return ip;
80101dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101dd8:	c9                   	leave  
80101dd9:	c3                   	ret    

80101dda <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
80101dda:	55                   	push   %ebp
80101ddb:	89 e5                	mov    %esp,%ebp
80101ddd:	83 ec 08             	sub    $0x8,%esp
             //   cprintf("idup \n");

    acquire(&icache.lock);
80101de0:	83 ec 0c             	sub    $0xc,%esp
80101de3:	68 40 24 11 80       	push   $0x80112440
80101de8:	e8 ca 38 00 00       	call   801056b7 <acquire>
80101ded:	83 c4 10             	add    $0x10,%esp
    ip->ref++;
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 40 08             	mov    0x8(%eax),%eax
80101df6:	8d 50 01             	lea    0x1(%eax),%edx
80101df9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfc:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101dff:	83 ec 0c             	sub    $0xc,%esp
80101e02:	68 40 24 11 80       	push   $0x80112440
80101e07:	e8 12 39 00 00       	call   8010571e <release>
80101e0c:	83 c4 10             	add    $0x10,%esp
    return ip;
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101e12:	c9                   	leave  
80101e13:	c3                   	ret    

80101e14 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
80101e14:	55                   	push   %ebp
80101e15:	89 e5                	mov    %esp,%ebp
80101e17:	83 ec 38             	sub    $0x38,%esp
    struct buf* bp;
    struct dinode* dip;
                 //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
80101e1a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101e1e:	74 0a                	je     80101e2a <ilock+0x16>
80101e20:	8b 45 08             	mov    0x8(%ebp),%eax
80101e23:	8b 40 08             	mov    0x8(%eax),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	7f 0d                	jg     80101e37 <ilock+0x23>
        panic("ilock");
80101e2a:	83 ec 0c             	sub    $0xc,%esp
80101e2d:	68 cf 8d 10 80       	push   $0x80108dcf
80101e32:	e8 2f e7 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101e37:	83 ec 0c             	sub    $0xc,%esp
80101e3a:	68 40 24 11 80       	push   $0x80112440
80101e3f:	e8 73 38 00 00       	call   801056b7 <acquire>
80101e44:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101e47:	eb 13                	jmp    80101e5c <ilock+0x48>
        sleep(ip, &icache.lock);
80101e49:	83 ec 08             	sub    $0x8,%esp
80101e4c:	68 40 24 11 80       	push   $0x80112440
80101e51:	ff 75 08             	pushl  0x8(%ebp)
80101e54:	e8 65 35 00 00       	call   801053be <sleep>
80101e59:	83 c4 10             	add    $0x10,%esp

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
80101e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5f:	8b 40 0c             	mov    0xc(%eax),%eax
80101e62:	83 e0 01             	and    $0x1,%eax
80101e65:	85 c0                	test   %eax,%eax
80101e67:	75 e0                	jne    80101e49 <ilock+0x35>
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
80101e69:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6c:	8b 40 0c             	mov    0xc(%eax),%eax
80101e6f:	83 c8 01             	or     $0x1,%eax
80101e72:	89 c2                	mov    %eax,%edx
80101e74:	8b 45 08             	mov    0x8(%ebp),%eax
80101e77:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101e7a:	83 ec 0c             	sub    $0xc,%esp
80101e7d:	68 40 24 11 80       	push   $0x80112440
80101e82:	e8 97 38 00 00       	call   8010571e <release>
80101e87:	83 c4 10             	add    $0x10,%esp

    if (!(ip->flags & I_VALID)) {
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	8b 40 0c             	mov    0xc(%eax),%eax
80101e90:	83 e0 02             	and    $0x2,%eax
80101e93:	85 c0                	test   %eax,%eax
80101e95:	0f 85 17 01 00 00    	jne    80101fb2 <ilock+0x19e>
        struct superblock sb;
        sb = sbs[ip->part->number];
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 40 50             	mov    0x50(%eax),%eax
80101ea1:	8b 40 14             	mov    0x14(%eax),%eax
80101ea4:	c1 e0 05             	shl    $0x5,%eax
80101ea7:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101eac:	8b 10                	mov    (%eax),%edx
80101eae:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101eb1:	8b 50 04             	mov    0x4(%eax),%edx
80101eb4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101eb7:	8b 50 08             	mov    0x8(%eax),%edx
80101eba:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101ebd:	8b 50 0c             	mov    0xc(%eax),%edx
80101ec0:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ec3:	8b 50 10             	mov    0x10(%eax),%edx
80101ec6:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ec9:	8b 50 14             	mov    0x14(%eax),%edx
80101ecc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101ecf:	8b 50 18             	mov    0x18(%eax),%edx
80101ed2:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101ed5:	8b 40 1c             	mov    0x1c(%eax),%eax
80101ed8:	89 45 ec             	mov    %eax,-0x14(%ebp)
       // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101edb:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	8b 40 04             	mov    0x4(%eax),%eax
80101ee4:	c1 e8 03             	shr    $0x3,%eax
80101ee7:	89 c1                	mov    %eax,%ecx
80101ee9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101eec:	01 c8                	add    %ecx,%eax
80101eee:	01 c2                	add    %eax,%edx
80101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef3:	8b 00                	mov    (%eax),%eax
80101ef5:	83 ec 08             	sub    $0x8,%esp
80101ef8:	52                   	push   %edx
80101ef9:	50                   	push   %eax
80101efa:	e8 b7 e2 ff ff       	call   801001b6 <bread>
80101eff:	83 c4 10             	add    $0x10,%esp
80101f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
        dip = (struct dinode*)bp->data + ip->inum % IPB;
80101f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f08:	8d 50 18             	lea    0x18(%eax),%edx
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	8b 40 04             	mov    0x4(%eax),%eax
80101f11:	83 e0 07             	and    $0x7,%eax
80101f14:	c1 e0 06             	shl    $0x6,%eax
80101f17:	01 d0                	add    %edx,%eax
80101f19:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ip->type = dip->type;
80101f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f1f:	0f b7 10             	movzwl (%eax),%edx
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	66 89 50 10          	mov    %dx,0x10(%eax)
        ip->major = dip->major;
80101f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f2c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101f30:	8b 45 08             	mov    0x8(%ebp),%eax
80101f33:	66 89 50 12          	mov    %dx,0x12(%eax)
        ip->minor = dip->minor;
80101f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f3a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f41:	66 89 50 14          	mov    %dx,0x14(%eax)
        ip->nlink = dip->nlink;
80101f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f48:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4f:	66 89 50 16          	mov    %dx,0x16(%eax)
        ip->size = dip->size;
80101f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f56:	8b 50 08             	mov    0x8(%eax),%edx
80101f59:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5c:	89 50 18             	mov    %edx,0x18(%eax)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f62:	8d 50 0c             	lea    0xc(%eax),%edx
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	83 c0 1c             	add    $0x1c,%eax
80101f6b:	83 ec 04             	sub    $0x4,%esp
80101f6e:	6a 34                	push   $0x34
80101f70:	52                   	push   %edx
80101f71:	50                   	push   %eax
80101f72:	e8 62 3a 00 00       	call   801059d9 <memmove>
80101f77:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101f7a:	83 ec 0c             	sub    $0xc,%esp
80101f7d:	ff 75 f4             	pushl  -0xc(%ebp)
80101f80:	e8 a9 e2 ff ff       	call   8010022e <brelse>
80101f85:	83 c4 10             	add    $0x10,%esp
        ip->flags |= I_VALID;
80101f88:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8b:	8b 40 0c             	mov    0xc(%eax),%eax
80101f8e:	83 c8 02             	or     $0x2,%eax
80101f91:	89 c2                	mov    %eax,%edx
80101f93:	8b 45 08             	mov    0x8(%ebp),%eax
80101f96:	89 50 0c             	mov    %edx,0xc(%eax)
        if (ip->type == 0)
80101f99:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fa0:	66 85 c0             	test   %ax,%ax
80101fa3:	75 0d                	jne    80101fb2 <ilock+0x19e>
            panic("ilock: no type");
80101fa5:	83 ec 0c             	sub    $0xc,%esp
80101fa8:	68 d5 8d 10 80       	push   $0x80108dd5
80101fad:	e8 b4 e5 ff ff       	call   80100566 <panic>
    }
}
80101fb2:	90                   	nop
80101fb3:	c9                   	leave  
80101fb4:	c3                   	ret    

80101fb5 <iunlock>:

// Unlock the given inode.
void iunlock(struct inode* ip)
{
80101fb5:	55                   	push   %ebp
80101fb6:	89 e5                	mov    %esp,%ebp
80101fb8:	83 ec 08             	sub    $0x8,%esp
                  //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
80101fbb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101fbf:	74 17                	je     80101fd8 <iunlock+0x23>
80101fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc4:	8b 40 0c             	mov    0xc(%eax),%eax
80101fc7:	83 e0 01             	and    $0x1,%eax
80101fca:	85 c0                	test   %eax,%eax
80101fcc:	74 0a                	je     80101fd8 <iunlock+0x23>
80101fce:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd1:	8b 40 08             	mov    0x8(%eax),%eax
80101fd4:	85 c0                	test   %eax,%eax
80101fd6:	7f 0d                	jg     80101fe5 <iunlock+0x30>
        // cprintf("iunlock %d ",ip);
        panic("iunlock");
80101fd8:	83 ec 0c             	sub    $0xc,%esp
80101fdb:	68 e4 8d 10 80       	push   $0x80108de4
80101fe0:	e8 81 e5 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
80101fe5:	83 ec 0c             	sub    $0xc,%esp
80101fe8:	68 40 24 11 80       	push   $0x80112440
80101fed:	e8 c5 36 00 00       	call   801056b7 <acquire>
80101ff2:	83 c4 10             	add    $0x10,%esp
    ip->flags &= ~I_BUSY;
80101ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff8:	8b 40 0c             	mov    0xc(%eax),%eax
80101ffb:	83 e0 fe             	and    $0xfffffffe,%eax
80101ffe:	89 c2                	mov    %eax,%edx
80102000:	8b 45 08             	mov    0x8(%ebp),%eax
80102003:	89 50 0c             	mov    %edx,0xc(%eax)
    wakeup(ip);
80102006:	83 ec 0c             	sub    $0xc,%esp
80102009:	ff 75 08             	pushl  0x8(%ebp)
8010200c:	e8 98 34 00 00       	call   801054a9 <wakeup>
80102011:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
80102014:	83 ec 0c             	sub    $0xc,%esp
80102017:	68 40 24 11 80       	push   $0x80112440
8010201c:	e8 fd 36 00 00       	call   8010571e <release>
80102021:	83 c4 10             	add    $0x10,%esp
}
80102024:	90                   	nop
80102025:	c9                   	leave  
80102026:	c3                   	ret    

80102027 <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
80102027:	55                   	push   %ebp
80102028:	89 e5                	mov    %esp,%ebp
8010202a:	83 ec 08             	sub    $0x8,%esp
                       // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
8010202d:	83 ec 0c             	sub    $0xc,%esp
80102030:	68 40 24 11 80       	push   $0x80112440
80102035:	e8 7d 36 00 00       	call   801056b7 <acquire>
8010203a:	83 c4 10             	add    $0x10,%esp
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
8010203d:	8b 45 08             	mov    0x8(%ebp),%eax
80102040:	8b 40 08             	mov    0x8(%eax),%eax
80102043:	83 f8 01             	cmp    $0x1,%eax
80102046:	0f 85 a9 00 00 00    	jne    801020f5 <iput+0xce>
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	8b 40 0c             	mov    0xc(%eax),%eax
80102052:	83 e0 02             	and    $0x2,%eax
80102055:	85 c0                	test   %eax,%eax
80102057:	0f 84 98 00 00 00    	je     801020f5 <iput+0xce>
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102064:	66 85 c0             	test   %ax,%ax
80102067:	0f 85 88 00 00 00    	jne    801020f5 <iput+0xce>
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
8010206d:	8b 45 08             	mov    0x8(%ebp),%eax
80102070:	8b 40 0c             	mov    0xc(%eax),%eax
80102073:	83 e0 01             	and    $0x1,%eax
80102076:	85 c0                	test   %eax,%eax
80102078:	74 0d                	je     80102087 <iput+0x60>
            panic("iput busy");
8010207a:	83 ec 0c             	sub    $0xc,%esp
8010207d:	68 ec 8d 10 80       	push   $0x80108dec
80102082:	e8 df e4 ff ff       	call   80100566 <panic>
        ip->flags |= I_BUSY;
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	8b 40 0c             	mov    0xc(%eax),%eax
8010208d:	83 c8 01             	or     $0x1,%eax
80102090:	89 c2                	mov    %eax,%edx
80102092:	8b 45 08             	mov    0x8(%ebp),%eax
80102095:	89 50 0c             	mov    %edx,0xc(%eax)
        release(&icache.lock);
80102098:	83 ec 0c             	sub    $0xc,%esp
8010209b:	68 40 24 11 80       	push   $0x80112440
801020a0:	e8 79 36 00 00       	call   8010571e <release>
801020a5:	83 c4 10             	add    $0x10,%esp
        itrunc(ip);
801020a8:	83 ec 0c             	sub    $0xc,%esp
801020ab:	ff 75 08             	pushl  0x8(%ebp)
801020ae:	e8 12 02 00 00       	call   801022c5 <itrunc>
801020b3:	83 c4 10             	add    $0x10,%esp
        ip->type = 0;
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
        iupdate(ip);
801020bf:	83 ec 0c             	sub    $0xc,%esp
801020c2:	ff 75 08             	pushl  0x8(%ebp)
801020c5:	e8 f6 fa ff ff       	call   80101bc0 <iupdate>
801020ca:	83 c4 10             	add    $0x10,%esp
        acquire(&icache.lock);
801020cd:	83 ec 0c             	sub    $0xc,%esp
801020d0:	68 40 24 11 80       	push   $0x80112440
801020d5:	e8 dd 35 00 00       	call   801056b7 <acquire>
801020da:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801020dd:	8b 45 08             	mov    0x8(%ebp),%eax
801020e0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801020e7:	83 ec 0c             	sub    $0xc,%esp
801020ea:	ff 75 08             	pushl  0x8(%ebp)
801020ed:	e8 b7 33 00 00       	call   801054a9 <wakeup>
801020f2:	83 c4 10             	add    $0x10,%esp
    }
    ip->ref--;
801020f5:	8b 45 08             	mov    0x8(%ebp),%eax
801020f8:	8b 40 08             	mov    0x8(%eax),%eax
801020fb:	8d 50 ff             	lea    -0x1(%eax),%edx
801020fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102101:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80102104:	83 ec 0c             	sub    $0xc,%esp
80102107:	68 40 24 11 80       	push   $0x80112440
8010210c:	e8 0d 36 00 00       	call   8010571e <release>
80102111:	83 c4 10             	add    $0x10,%esp
}
80102114:	90                   	nop
80102115:	c9                   	leave  
80102116:	c3                   	ret    

80102117 <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
80102117:	55                   	push   %ebp
80102118:	89 e5                	mov    %esp,%ebp
8010211a:	83 ec 08             	sub    $0x8,%esp
    iunlock(ip);
8010211d:	83 ec 0c             	sub    $0xc,%esp
80102120:	ff 75 08             	pushl  0x8(%ebp)
80102123:	e8 8d fe ff ff       	call   80101fb5 <iunlock>
80102128:	83 c4 10             	add    $0x10,%esp
    iput(ip);
8010212b:	83 ec 0c             	sub    $0xc,%esp
8010212e:	ff 75 08             	pushl  0x8(%ebp)
80102131:	e8 f1 fe ff ff       	call   80102027 <iput>
80102136:	83 c4 10             	add    $0x10,%esp
}
80102139:	90                   	nop
8010213a:	c9                   	leave  
8010213b:	c3                   	ret    

8010213c <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
8010213c:	55                   	push   %ebp
8010213d:	89 e5                	mov    %esp,%ebp
8010213f:	53                   	push   %ebx
80102140:	83 ec 34             	sub    $0x34,%esp
                       //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
struct superblock sb;
sb=sbs[ip->part->number];
80102143:	8b 45 08             	mov    0x8(%ebp),%eax
80102146:	8b 40 50             	mov    0x50(%eax),%eax
80102149:	8b 40 14             	mov    0x14(%eax),%eax
8010214c:	c1 e0 05             	shl    $0x5,%eax
8010214f:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102154:	8b 10                	mov    (%eax),%edx
80102156:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102159:	8b 50 04             	mov    0x4(%eax),%edx
8010215c:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010215f:	8b 50 08             	mov    0x8(%eax),%edx
80102162:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102165:	8b 50 0c             	mov    0xc(%eax),%edx
80102168:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010216b:	8b 50 10             	mov    0x10(%eax),%edx
8010216e:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102171:	8b 50 14             	mov    0x14(%eax),%edx
80102174:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102177:	8b 50 18             	mov    0x18(%eax),%edx
8010217a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010217d:	8b 40 1c             	mov    0x1c(%eax),%eax
80102180:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (bn < NDIRECT) {
80102183:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102187:	77 4e                	ja     801021d7 <bmap+0x9b>
        if ((addr = ip->addrs[bn]) == 0)
80102189:	8b 45 08             	mov    0x8(%ebp),%eax
8010218c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010218f:	83 c2 04             	add    $0x4,%edx
80102192:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102196:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102199:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010219d:	75 30                	jne    801021cf <bmap+0x93>
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	8b 40 50             	mov    0x50(%eax),%eax
801021a5:	8b 40 14             	mov    0x14(%eax),%eax
801021a8:	89 c2                	mov    %eax,%edx
801021aa:	8b 45 08             	mov    0x8(%ebp),%eax
801021ad:	8b 00                	mov    (%eax),%eax
801021af:	83 ec 08             	sub    $0x8,%esp
801021b2:	52                   	push   %edx
801021b3:	50                   	push   %eax
801021b4:	e8 e3 f2 ff ff       	call   8010149c <balloc>
801021b9:	83 c4 10             	add    $0x10,%esp
801021bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021bf:	8b 45 08             	mov    0x8(%ebp),%eax
801021c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801021c5:	8d 4a 04             	lea    0x4(%edx),%ecx
801021c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021cb:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
       // cprintf("addr %d \n ",addr);
        return addr;
801021cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021d2:	e9 e9 00 00 00       	jmp    801022c0 <bmap+0x184>
    }
    bn -= NDIRECT;
801021d7:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

    if (bn < NINDIRECT) {
801021db:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801021df:	0f 87 ce 00 00 00    	ja     801022b3 <bmap+0x177>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801021e5:	8b 45 08             	mov    0x8(%ebp),%eax
801021e8:	8b 40 4c             	mov    0x4c(%eax),%eax
801021eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801021f2:	75 29                	jne    8010221d <bmap+0xe1>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
801021f4:	8b 45 08             	mov    0x8(%ebp),%eax
801021f7:	8b 40 50             	mov    0x50(%eax),%eax
801021fa:	8b 40 14             	mov    0x14(%eax),%eax
801021fd:	89 c2                	mov    %eax,%edx
801021ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102202:	8b 00                	mov    (%eax),%eax
80102204:	83 ec 08             	sub    $0x8,%esp
80102207:	52                   	push   %edx
80102208:	50                   	push   %eax
80102209:	e8 8e f2 ff ff       	call   8010149c <balloc>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102214:	8b 45 08             	mov    0x8(%ebp),%eax
80102217:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010221a:	89 50 4c             	mov    %edx,0x4c(%eax)
        bp = bread(ip->dev, sb.offset+addr);
8010221d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102223:	01 c2                	add    %eax,%edx
80102225:	8b 45 08             	mov    0x8(%ebp),%eax
80102228:	8b 00                	mov    (%eax),%eax
8010222a:	83 ec 08             	sub    $0x8,%esp
8010222d:	52                   	push   %edx
8010222e:	50                   	push   %eax
8010222f:	e8 82 df ff ff       	call   801001b6 <bread>
80102234:	83 c4 10             	add    $0x10,%esp
80102237:	89 45 f0             	mov    %eax,-0x10(%ebp)
        a = (uint*)bp->data;
8010223a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010223d:	83 c0 18             	add    $0x18,%eax
80102240:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if ((addr = a[bn]) == 0) {
80102243:	8b 45 0c             	mov    0xc(%ebp),%eax
80102246:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010224d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102250:	01 d0                	add    %edx,%eax
80102252:	8b 00                	mov    (%eax),%eax
80102254:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102257:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010225b:	75 43                	jne    801022a0 <bmap+0x164>
            a[bn] = addr = balloc(ip->dev, ip->part->number);
8010225d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102267:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010226a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010226d:	8b 45 08             	mov    0x8(%ebp),%eax
80102270:	8b 40 50             	mov    0x50(%eax),%eax
80102273:	8b 40 14             	mov    0x14(%eax),%eax
80102276:	89 c2                	mov    %eax,%edx
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 00                	mov    (%eax),%eax
8010227d:	83 ec 08             	sub    $0x8,%esp
80102280:	52                   	push   %edx
80102281:	50                   	push   %eax
80102282:	e8 15 f2 ff ff       	call   8010149c <balloc>
80102287:	83 c4 10             	add    $0x10,%esp
8010228a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010228d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102290:	89 03                	mov    %eax,(%ebx)
            log_write(bp);
80102292:	83 ec 0c             	sub    $0xc,%esp
80102295:	ff 75 f0             	pushl  -0x10(%ebp)
80102298:	e8 80 1b 00 00       	call   80103e1d <log_write>
8010229d:	83 c4 10             	add    $0x10,%esp
        }
        brelse(bp);
801022a0:	83 ec 0c             	sub    $0xc,%esp
801022a3:	ff 75 f0             	pushl  -0x10(%ebp)
801022a6:	e8 83 df ff ff       	call   8010022e <brelse>
801022ab:	83 c4 10             	add    $0x10,%esp
        return addr;
801022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b1:	eb 0d                	jmp    801022c0 <bmap+0x184>
    }

    panic("bmap: out of range");
801022b3:	83 ec 0c             	sub    $0xc,%esp
801022b6:	68 f6 8d 10 80       	push   $0x80108df6
801022bb:	e8 a6 e2 ff ff       	call   80100566 <panic>
}
801022c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801022c3:	c9                   	leave  
801022c4:	c3                   	ret    

801022c5 <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
801022c5:	55                   	push   %ebp
801022c6:	89 e5                	mov    %esp,%ebp
801022c8:	83 ec 38             	sub    $0x38,%esp

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
801022cb:	8b 45 08             	mov    0x8(%ebp),%eax
801022ce:	8b 40 50             	mov    0x50(%eax),%eax
801022d1:	8b 40 14             	mov    0x14(%eax),%eax
801022d4:	c1 e0 05             	shl    $0x5,%eax
801022d7:	05 60 d6 10 80       	add    $0x8010d660,%eax
801022dc:	8b 10                	mov    (%eax),%edx
801022de:	89 55 c8             	mov    %edx,-0x38(%ebp)
801022e1:	8b 50 04             	mov    0x4(%eax),%edx
801022e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
801022e7:	8b 50 08             	mov    0x8(%eax),%edx
801022ea:	89 55 d0             	mov    %edx,-0x30(%ebp)
801022ed:	8b 50 0c             	mov    0xc(%eax),%edx
801022f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801022f3:	8b 50 10             	mov    0x10(%eax),%edx
801022f6:	89 55 d8             	mov    %edx,-0x28(%ebp)
801022f9:	8b 50 14             	mov    0x14(%eax),%edx
801022fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
801022ff:	8b 50 18             	mov    0x18(%eax),%edx
80102302:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102305:	8b 40 1c             	mov    0x1c(%eax),%eax
80102308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < NDIRECT; i++) {
8010230b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102312:	eb 51                	jmp    80102365 <itrunc+0xa0>
        if (ip->addrs[i]) {
80102314:	8b 45 08             	mov    0x8(%ebp),%eax
80102317:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010231a:	83 c2 04             	add    $0x4,%edx
8010231d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102321:	85 c0                	test   %eax,%eax
80102323:	74 3c                	je     80102361 <itrunc+0x9c>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
80102325:	8b 45 08             	mov    0x8(%ebp),%eax
80102328:	8b 40 50             	mov    0x50(%eax),%eax
8010232b:	8b 40 14             	mov    0x14(%eax),%eax
8010232e:	89 c1                	mov    %eax,%ecx
80102330:	8b 45 08             	mov    0x8(%ebp),%eax
80102333:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102336:	83 c2 04             	add    $0x4,%edx
80102339:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010233d:	8b 55 08             	mov    0x8(%ebp),%edx
80102340:	8b 12                	mov    (%edx),%edx
80102342:	83 ec 04             	sub    $0x4,%esp
80102345:	51                   	push   %ecx
80102346:	50                   	push   %eax
80102347:	52                   	push   %edx
80102348:	e8 da f2 ff ff       	call   80101627 <bfree>
8010234d:	83 c4 10             	add    $0x10,%esp
            ip->addrs[i] = 0;
80102350:	8b 45 08             	mov    0x8(%ebp),%eax
80102353:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102356:	83 c2 04             	add    $0x4,%edx
80102359:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80102360:	00 
    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
80102361:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102365:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102369:	7e a9                	jle    80102314 <itrunc+0x4f>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	8b 40 4c             	mov    0x4c(%eax),%eax
80102371:	85 c0                	test   %eax,%eax
80102373:	0f 84 be 00 00 00    	je     80102437 <itrunc+0x172>
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
80102379:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	8b 40 4c             	mov    0x4c(%eax),%eax
80102382:	01 c2                	add    %eax,%edx
80102384:	8b 45 08             	mov    0x8(%ebp),%eax
80102387:	8b 00                	mov    (%eax),%eax
80102389:	83 ec 08             	sub    $0x8,%esp
8010238c:	52                   	push   %edx
8010238d:	50                   	push   %eax
8010238e:	e8 23 de ff ff       	call   801001b6 <bread>
80102393:	83 c4 10             	add    $0x10,%esp
80102396:	89 45 ec             	mov    %eax,-0x14(%ebp)
        a = (uint*)bp->data;
80102399:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010239c:	83 c0 18             	add    $0x18,%eax
8010239f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        for (j = 0; j < NINDIRECT; j++) {
801023a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801023a9:	eb 48                	jmp    801023f3 <itrunc+0x12e>
            if (a[j])
801023ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801023b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801023b8:	01 d0                	add    %edx,%eax
801023ba:	8b 00                	mov    (%eax),%eax
801023bc:	85 c0                	test   %eax,%eax
801023be:	74 2f                	je     801023ef <itrunc+0x12a>
                bfree(ip->dev, a[j], ip->part->number);
801023c0:	8b 45 08             	mov    0x8(%ebp),%eax
801023c3:	8b 40 50             	mov    0x50(%eax),%eax
801023c6:	8b 40 14             	mov    0x14(%eax),%eax
801023c9:	89 c1                	mov    %eax,%ecx
801023cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023ce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801023d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801023d8:	01 d0                	add    %edx,%eax
801023da:	8b 00                	mov    (%eax),%eax
801023dc:	8b 55 08             	mov    0x8(%ebp),%edx
801023df:	8b 12                	mov    (%edx),%edx
801023e1:	83 ec 04             	sub    $0x4,%esp
801023e4:	51                   	push   %ecx
801023e5:	50                   	push   %eax
801023e6:	52                   	push   %edx
801023e7:	e8 3b f2 ff ff       	call   80101627 <bfree>
801023ec:	83 c4 10             	add    $0x10,%esp
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
801023ef:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801023f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023f6:	83 f8 7f             	cmp    $0x7f,%eax
801023f9:	76 b0                	jbe    801023ab <itrunc+0xe6>
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
801023fb:	83 ec 0c             	sub    $0xc,%esp
801023fe:	ff 75 ec             	pushl  -0x14(%ebp)
80102401:	e8 28 de ff ff       	call   8010022e <brelse>
80102406:	83 c4 10             	add    $0x10,%esp
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
80102409:	8b 45 08             	mov    0x8(%ebp),%eax
8010240c:	8b 40 50             	mov    0x50(%eax),%eax
8010240f:	8b 40 14             	mov    0x14(%eax),%eax
80102412:	89 c1                	mov    %eax,%ecx
80102414:	8b 45 08             	mov    0x8(%ebp),%eax
80102417:	8b 40 4c             	mov    0x4c(%eax),%eax
8010241a:	8b 55 08             	mov    0x8(%ebp),%edx
8010241d:	8b 12                	mov    (%edx),%edx
8010241f:	83 ec 04             	sub    $0x4,%esp
80102422:	51                   	push   %ecx
80102423:	50                   	push   %eax
80102424:	52                   	push   %edx
80102425:	e8 fd f1 ff ff       	call   80101627 <bfree>
8010242a:	83 c4 10             	add    $0x10,%esp
        ip->addrs[NDIRECT] = 0;
8010242d:	8b 45 08             	mov    0x8(%ebp),%eax
80102430:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }

    ip->size = 0;
80102437:	8b 45 08             	mov    0x8(%ebp),%eax
8010243a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    iupdate(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 08             	pushl  0x8(%ebp)
80102447:	e8 74 f7 ff ff       	call   80101bc0 <iupdate>
8010244c:	83 c4 10             	add    $0x10,%esp
}
8010244f:	90                   	nop
80102450:	c9                   	leave  
80102451:	c3                   	ret    

80102452 <stati>:

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
80102452:	55                   	push   %ebp
80102453:	89 e5                	mov    %esp,%ebp
    st->dev = ip->dev;
80102455:	8b 45 08             	mov    0x8(%ebp),%eax
80102458:	8b 00                	mov    (%eax),%eax
8010245a:	89 c2                	mov    %eax,%edx
8010245c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010245f:	89 50 04             	mov    %edx,0x4(%eax)
    st->ino = ip->inum;
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	8b 50 04             	mov    0x4(%eax),%edx
80102468:	8b 45 0c             	mov    0xc(%ebp),%eax
8010246b:	89 50 08             	mov    %edx,0x8(%eax)
    st->type = ip->type;
8010246e:	8b 45 08             	mov    0x8(%ebp),%eax
80102471:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102475:	8b 45 0c             	mov    0xc(%ebp),%eax
80102478:	66 89 10             	mov    %dx,(%eax)
    st->nlink = ip->nlink;
8010247b:	8b 45 08             	mov    0x8(%ebp),%eax
8010247e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102482:	8b 45 0c             	mov    0xc(%ebp),%eax
80102485:	66 89 50 0c          	mov    %dx,0xc(%eax)
    st->size = ip->size;
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	8b 50 18             	mov    0x18(%eax),%edx
8010248f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102492:	89 50 10             	mov    %edx,0x10(%eax)
}
80102495:	90                   	nop
80102496:	5d                   	pop    %ebp
80102497:	c3                   	ret    

80102498 <readi>:

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
80102498:	55                   	push   %ebp
80102499:	89 e5                	mov    %esp,%ebp
8010249b:	83 ec 38             	sub    $0x38,%esp
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
                      //      cprintf("readi \n");
    sb=sbs[ip->part->number];
8010249e:	8b 45 08             	mov    0x8(%ebp),%eax
801024a1:	8b 40 50             	mov    0x50(%eax),%eax
801024a4:	8b 40 14             	mov    0x14(%eax),%eax
801024a7:	c1 e0 05             	shl    $0x5,%eax
801024aa:	05 60 d6 10 80       	add    $0x8010d660,%eax
801024af:	8b 10                	mov    (%eax),%edx
801024b1:	89 55 c8             	mov    %edx,-0x38(%ebp)
801024b4:	8b 50 04             	mov    0x4(%eax),%edx
801024b7:	89 55 cc             	mov    %edx,-0x34(%ebp)
801024ba:	8b 50 08             	mov    0x8(%eax),%edx
801024bd:	89 55 d0             	mov    %edx,-0x30(%ebp)
801024c0:	8b 50 0c             	mov    0xc(%eax),%edx
801024c3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801024c6:	8b 50 10             	mov    0x10(%eax),%edx
801024c9:	89 55 d8             	mov    %edx,-0x28(%ebp)
801024cc:	8b 50 14             	mov    0x14(%eax),%edx
801024cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
801024d2:	8b 50 18             	mov    0x18(%eax),%edx
801024d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
801024d8:	8b 40 1c             	mov    0x1c(%eax),%eax
801024db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ip->type == T_DEV) {
801024de:	8b 45 08             	mov    0x8(%ebp),%eax
801024e1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024e5:	66 83 f8 03          	cmp    $0x3,%ax
801024e9:	75 5c                	jne    80102547 <readi+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801024eb:	8b 45 08             	mov    0x8(%ebp),%eax
801024ee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024f2:	66 85 c0             	test   %ax,%ax
801024f5:	78 20                	js     80102517 <readi+0x7f>
801024f7:	8b 45 08             	mov    0x8(%ebp),%eax
801024fa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024fe:	66 83 f8 09          	cmp    $0x9,%ax
80102502:	7f 13                	jg     80102517 <readi+0x7f>
80102504:	8b 45 08             	mov    0x8(%ebp),%eax
80102507:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010250b:	98                   	cwtl   
8010250c:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80102513:	85 c0                	test   %eax,%eax
80102515:	75 0a                	jne    80102521 <readi+0x89>
            return -1;
80102517:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010251c:	e9 15 01 00 00       	jmp    80102636 <readi+0x19e>
        return devsw[ip->major].read(ip, dst, n);
80102521:	8b 45 08             	mov    0x8(%ebp),%eax
80102524:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102528:	98                   	cwtl   
80102529:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80102530:	8b 55 14             	mov    0x14(%ebp),%edx
80102533:	83 ec 04             	sub    $0x4,%esp
80102536:	52                   	push   %edx
80102537:	ff 75 0c             	pushl  0xc(%ebp)
8010253a:	ff 75 08             	pushl  0x8(%ebp)
8010253d:	ff d0                	call   *%eax
8010253f:	83 c4 10             	add    $0x10,%esp
80102542:	e9 ef 00 00 00       	jmp    80102636 <readi+0x19e>
    }

    if (off > ip->size || off + n < off)
80102547:	8b 45 08             	mov    0x8(%ebp),%eax
8010254a:	8b 40 18             	mov    0x18(%eax),%eax
8010254d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102550:	72 0d                	jb     8010255f <readi+0xc7>
80102552:	8b 55 10             	mov    0x10(%ebp),%edx
80102555:	8b 45 14             	mov    0x14(%ebp),%eax
80102558:	01 d0                	add    %edx,%eax
8010255a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010255d:	73 0a                	jae    80102569 <readi+0xd1>
        return -1;
8010255f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102564:	e9 cd 00 00 00       	jmp    80102636 <readi+0x19e>
    if (off + n > ip->size)
80102569:	8b 55 10             	mov    0x10(%ebp),%edx
8010256c:	8b 45 14             	mov    0x14(%ebp),%eax
8010256f:	01 c2                	add    %eax,%edx
80102571:	8b 45 08             	mov    0x8(%ebp),%eax
80102574:	8b 40 18             	mov    0x18(%eax),%eax
80102577:	39 c2                	cmp    %eax,%edx
80102579:	76 0c                	jbe    80102587 <readi+0xef>
        n = ip->size - off;
8010257b:	8b 45 08             	mov    0x8(%ebp),%eax
8010257e:	8b 40 18             	mov    0x18(%eax),%eax
80102581:	2b 45 10             	sub    0x10(%ebp),%eax
80102584:	89 45 14             	mov    %eax,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102587:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010258e:	e9 94 00 00 00       	jmp    80102627 <readi+0x18f>
        uint bmapOut=bmap(ip, off / BSIZE);
80102593:	8b 45 10             	mov    0x10(%ebp),%eax
80102596:	c1 e8 09             	shr    $0x9,%eax
80102599:	83 ec 08             	sub    $0x8,%esp
8010259c:	50                   	push   %eax
8010259d:	ff 75 08             	pushl  0x8(%ebp)
801025a0:	e8 97 fb ff ff       	call   8010213c <bmap>
801025a5:	83 c4 10             	add    $0x10,%esp
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
       // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset+bmapOut);
801025ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801025ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025b1:	01 c2                	add    %eax,%edx
801025b3:	8b 45 08             	mov    0x8(%ebp),%eax
801025b6:	8b 00                	mov    (%eax),%eax
801025b8:	83 ec 08             	sub    $0x8,%esp
801025bb:	52                   	push   %edx
801025bc:	50                   	push   %eax
801025bd:	e8 f4 db ff ff       	call   801001b6 <bread>
801025c2:	83 c4 10             	add    $0x10,%esp
801025c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
801025c8:	8b 45 10             	mov    0x10(%ebp),%eax
801025cb:	25 ff 01 00 00       	and    $0x1ff,%eax
801025d0:	ba 00 02 00 00       	mov    $0x200,%edx
801025d5:	29 c2                	sub    %eax,%edx
801025d7:	8b 45 14             	mov    0x14(%ebp),%eax
801025da:	2b 45 f4             	sub    -0xc(%ebp),%eax
801025dd:	39 c2                	cmp    %eax,%edx
801025df:	0f 46 c2             	cmovbe %edx,%eax
801025e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(dst, bp->data + off % BSIZE, m);
801025e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025e8:	8d 50 18             	lea    0x18(%eax),%edx
801025eb:	8b 45 10             	mov    0x10(%ebp),%eax
801025ee:	25 ff 01 00 00       	and    $0x1ff,%eax
801025f3:	01 d0                	add    %edx,%eax
801025f5:	83 ec 04             	sub    $0x4,%esp
801025f8:	ff 75 e8             	pushl  -0x18(%ebp)
801025fb:	50                   	push   %eax
801025fc:	ff 75 0c             	pushl  0xc(%ebp)
801025ff:	e8 d5 33 00 00       	call   801059d9 <memmove>
80102604:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80102607:	83 ec 0c             	sub    $0xc,%esp
8010260a:	ff 75 ec             	pushl  -0x14(%ebp)
8010260d:	e8 1c dc ff ff       	call   8010022e <brelse>
80102612:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102615:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102618:	01 45 f4             	add    %eax,-0xc(%ebp)
8010261b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010261e:	01 45 10             	add    %eax,0x10(%ebp)
80102621:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102624:	01 45 0c             	add    %eax,0xc(%ebp)
80102627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010262d:	0f 82 60 ff ff ff    	jb     80102593 <readi+0xfb>
        bp = bread(ip->dev, sb.offset+bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
80102633:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102636:	c9                   	leave  
80102637:	c3                   	ret    

80102638 <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	83 ec 38             	sub    $0x38,%esp
                               // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
        sb=sbs[ip->part->number];
8010263e:	8b 45 08             	mov    0x8(%ebp),%eax
80102641:	8b 40 50             	mov    0x50(%eax),%eax
80102644:	8b 40 14             	mov    0x14(%eax),%eax
80102647:	c1 e0 05             	shl    $0x5,%eax
8010264a:	05 60 d6 10 80       	add    $0x8010d660,%eax
8010264f:	8b 10                	mov    (%eax),%edx
80102651:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102654:	8b 50 04             	mov    0x4(%eax),%edx
80102657:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010265a:	8b 50 08             	mov    0x8(%eax),%edx
8010265d:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102660:	8b 50 0c             	mov    0xc(%eax),%edx
80102663:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102666:	8b 50 10             	mov    0x10(%eax),%edx
80102669:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010266c:	8b 50 14             	mov    0x14(%eax),%edx
8010266f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102672:	8b 50 18             	mov    0x18(%eax),%edx
80102675:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102678:	8b 40 1c             	mov    0x1c(%eax),%eax
8010267b:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    if (ip->type == T_DEV) {
8010267e:	8b 45 08             	mov    0x8(%ebp),%eax
80102681:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102685:	66 83 f8 03          	cmp    $0x3,%ax
80102689:	75 5c                	jne    801026e7 <writei+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010268b:	8b 45 08             	mov    0x8(%ebp),%eax
8010268e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102692:	66 85 c0             	test   %ax,%ax
80102695:	78 20                	js     801026b7 <writei+0x7f>
80102697:	8b 45 08             	mov    0x8(%ebp),%eax
8010269a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010269e:	66 83 f8 09          	cmp    $0x9,%ax
801026a2:	7f 13                	jg     801026b7 <writei+0x7f>
801026a4:	8b 45 08             	mov    0x8(%ebp),%eax
801026a7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026ab:	98                   	cwtl   
801026ac:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801026b3:	85 c0                	test   %eax,%eax
801026b5:	75 0a                	jne    801026c1 <writei+0x89>
            return -1;
801026b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026bc:	e9 46 01 00 00       	jmp    80102807 <writei+0x1cf>
        return devsw[ip->major].write(ip, src, n);
801026c1:	8b 45 08             	mov    0x8(%ebp),%eax
801026c4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026c8:	98                   	cwtl   
801026c9:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801026d0:	8b 55 14             	mov    0x14(%ebp),%edx
801026d3:	83 ec 04             	sub    $0x4,%esp
801026d6:	52                   	push   %edx
801026d7:	ff 75 0c             	pushl  0xc(%ebp)
801026da:	ff 75 08             	pushl  0x8(%ebp)
801026dd:	ff d0                	call   *%eax
801026df:	83 c4 10             	add    $0x10,%esp
801026e2:	e9 20 01 00 00       	jmp    80102807 <writei+0x1cf>
    }

    if (off > ip->size || off + n < off)
801026e7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ea:	8b 40 18             	mov    0x18(%eax),%eax
801026ed:	3b 45 10             	cmp    0x10(%ebp),%eax
801026f0:	72 0d                	jb     801026ff <writei+0xc7>
801026f2:	8b 55 10             	mov    0x10(%ebp),%edx
801026f5:	8b 45 14             	mov    0x14(%ebp),%eax
801026f8:	01 d0                	add    %edx,%eax
801026fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801026fd:	73 0a                	jae    80102709 <writei+0xd1>
        return -1;
801026ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102704:	e9 fe 00 00 00       	jmp    80102807 <writei+0x1cf>
    if (off + n > MAXFILE * BSIZE)
80102709:	8b 55 10             	mov    0x10(%ebp),%edx
8010270c:	8b 45 14             	mov    0x14(%ebp),%eax
8010270f:	01 d0                	add    %edx,%eax
80102711:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102716:	76 0a                	jbe    80102722 <writei+0xea>
        return -1;
80102718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010271d:	e9 e5 00 00 00       	jmp    80102807 <writei+0x1cf>

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
80102722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102729:	e9 a2 00 00 00       	jmp    801027d0 <writei+0x198>
        uint bmapOut=bmap(ip, off / BSIZE);
8010272e:	8b 45 10             	mov    0x10(%ebp),%eax
80102731:	c1 e8 09             	shr    $0x9,%eax
80102734:	83 ec 08             	sub    $0x8,%esp
80102737:	50                   	push   %eax
80102738:	ff 75 08             	pushl  0x8(%ebp)
8010273b:	e8 fc f9 ff ff       	call   8010213c <bmap>
80102740:	83 c4 10             	add    $0x10,%esp
80102743:	89 45 f0             	mov    %eax,-0x10(%ebp)
        bp = bread(ip->dev, sb.offset+bmapOut);
80102746:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010274c:	01 c2                	add    %eax,%edx
8010274e:	8b 45 08             	mov    0x8(%ebp),%eax
80102751:	8b 00                	mov    (%eax),%eax
80102753:	83 ec 08             	sub    $0x8,%esp
80102756:	52                   	push   %edx
80102757:	50                   	push   %eax
80102758:	e8 59 da ff ff       	call   801001b6 <bread>
8010275d:	83 c4 10             	add    $0x10,%esp
80102760:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
80102763:	8b 45 10             	mov    0x10(%ebp),%eax
80102766:	25 ff 01 00 00       	and    $0x1ff,%eax
8010276b:	ba 00 02 00 00       	mov    $0x200,%edx
80102770:	29 c2                	sub    %eax,%edx
80102772:	8b 45 14             	mov    0x14(%ebp),%eax
80102775:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102778:	39 c2                	cmp    %eax,%edx
8010277a:	0f 46 c2             	cmovbe %edx,%eax
8010277d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(bp->data + off % BSIZE, src, m);
80102780:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102783:	8d 50 18             	lea    0x18(%eax),%edx
80102786:	8b 45 10             	mov    0x10(%ebp),%eax
80102789:	25 ff 01 00 00       	and    $0x1ff,%eax
8010278e:	01 d0                	add    %edx,%eax
80102790:	83 ec 04             	sub    $0x4,%esp
80102793:	ff 75 e8             	pushl  -0x18(%ebp)
80102796:	ff 75 0c             	pushl  0xc(%ebp)
80102799:	50                   	push   %eax
8010279a:	e8 3a 32 00 00       	call   801059d9 <memmove>
8010279f:	83 c4 10             	add    $0x10,%esp
        log_write(bp);
801027a2:	83 ec 0c             	sub    $0xc,%esp
801027a5:	ff 75 ec             	pushl  -0x14(%ebp)
801027a8:	e8 70 16 00 00       	call   80103e1d <log_write>
801027ad:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801027b0:	83 ec 0c             	sub    $0xc,%esp
801027b3:	ff 75 ec             	pushl  -0x14(%ebp)
801027b6:	e8 73 da ff ff       	call   8010022e <brelse>
801027bb:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801027be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027c1:	01 45 f4             	add    %eax,-0xc(%ebp)
801027c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027c7:	01 45 10             	add    %eax,0x10(%ebp)
801027ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027cd:	01 45 0c             	add    %eax,0xc(%ebp)
801027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d3:	3b 45 14             	cmp    0x14(%ebp),%eax
801027d6:	0f 82 52 ff ff ff    	jb     8010272e <writei+0xf6>
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
801027dc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801027e0:	74 22                	je     80102804 <writei+0x1cc>
801027e2:	8b 45 08             	mov    0x8(%ebp),%eax
801027e5:	8b 40 18             	mov    0x18(%eax),%eax
801027e8:	3b 45 10             	cmp    0x10(%ebp),%eax
801027eb:	73 17                	jae    80102804 <writei+0x1cc>
        ip->size = off;
801027ed:	8b 45 08             	mov    0x8(%ebp),%eax
801027f0:	8b 55 10             	mov    0x10(%ebp),%edx
801027f3:	89 50 18             	mov    %edx,0x18(%eax)
        iupdate(ip);
801027f6:	83 ec 0c             	sub    $0xc,%esp
801027f9:	ff 75 08             	pushl  0x8(%ebp)
801027fc:	e8 bf f3 ff ff       	call   80101bc0 <iupdate>
80102801:	83 c4 10             	add    $0x10,%esp
    }
    return n;
80102804:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102807:	c9                   	leave  
80102808:	c3                   	ret    

80102809 <namecmp>:

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
80102809:	55                   	push   %ebp
8010280a:	89 e5                	mov    %esp,%ebp
8010280c:	83 ec 08             	sub    $0x8,%esp
    return strncmp(s, t, DIRSIZ);
8010280f:	83 ec 04             	sub    $0x4,%esp
80102812:	6a 0e                	push   $0xe
80102814:	ff 75 0c             	pushl  0xc(%ebp)
80102817:	ff 75 08             	pushl  0x8(%ebp)
8010281a:	e8 50 32 00 00       	call   80105a6f <strncmp>
8010281f:	83 c4 10             	add    $0x10,%esp
}
80102822:	c9                   	leave  
80102823:	c3                   	ret    

80102824 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
80102824:	55                   	push   %ebp
80102825:	89 e5                	mov    %esp,%ebp
80102827:	83 ec 28             	sub    $0x28,%esp
                             //       cprintf("dirlookup \n");

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
8010282a:	8b 45 08             	mov    0x8(%ebp),%eax
8010282d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102831:	66 83 f8 01          	cmp    $0x1,%ax
80102835:	74 0d                	je     80102844 <dirlookup+0x20>
        panic("dirlookup not DIR");
80102837:	83 ec 0c             	sub    $0xc,%esp
8010283a:	68 09 8e 10 80       	push   $0x80108e09
8010283f:	e8 22 dd ff ff       	call   80100566 <panic>

    for (off = 0; off < dp->size; off += sizeof(de)) {
80102844:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010284b:	e9 85 00 00 00       	jmp    801028d5 <dirlookup+0xb1>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102850:	6a 10                	push   $0x10
80102852:	ff 75 f4             	pushl  -0xc(%ebp)
80102855:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102858:	50                   	push   %eax
80102859:	ff 75 08             	pushl  0x8(%ebp)
8010285c:	e8 37 fc ff ff       	call   80102498 <readi>
80102861:	83 c4 10             	add    $0x10,%esp
80102864:	83 f8 10             	cmp    $0x10,%eax
80102867:	74 0d                	je     80102876 <dirlookup+0x52>
            panic("dirlink read");
80102869:	83 ec 0c             	sub    $0xc,%esp
8010286c:	68 1b 8e 10 80       	push   $0x80108e1b
80102871:	e8 f0 dc ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102876:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010287a:	66 85 c0             	test   %ax,%ax
8010287d:	74 51                	je     801028d0 <dirlookup+0xac>
            continue;
        if (namecmp(name, de.name) == 0) {
8010287f:	83 ec 08             	sub    $0x8,%esp
80102882:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102885:	83 c0 02             	add    $0x2,%eax
80102888:	50                   	push   %eax
80102889:	ff 75 0c             	pushl  0xc(%ebp)
8010288c:	e8 78 ff ff ff       	call   80102809 <namecmp>
80102891:	83 c4 10             	add    $0x10,%esp
80102894:	85 c0                	test   %eax,%eax
80102896:	75 39                	jne    801028d1 <dirlookup+0xad>
            // entry matches path element
            if (poff)
80102898:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010289c:	74 08                	je     801028a6 <dirlookup+0x82>
                *poff = off;
8010289e:	8b 45 10             	mov    0x10(%ebp),%eax
801028a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028a4:	89 10                	mov    %edx,(%eax)
            inum = de.inum;
801028a6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801028aa:	0f b7 c0             	movzwl %ax,%eax
801028ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
            return iget(dp->dev, inum, dp->part->number);
801028b0:	8b 45 08             	mov    0x8(%ebp),%eax
801028b3:	8b 40 50             	mov    0x50(%eax),%eax
801028b6:	8b 50 14             	mov    0x14(%eax),%edx
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	8b 00                	mov    (%eax),%eax
801028be:	83 ec 04             	sub    $0x4,%esp
801028c1:	52                   	push   %edx
801028c2:	ff 75 f0             	pushl  -0x10(%ebp)
801028c5:	50                   	push   %eax
801028c6:	e8 f9 f3 ff ff       	call   80101cc4 <iget>
801028cb:	83 c4 10             	add    $0x10,%esp
801028ce:	eb 19                	jmp    801028e9 <dirlookup+0xc5>

    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            continue;
801028d0:	90                   	nop
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801028d1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801028d5:	8b 45 08             	mov    0x8(%ebp),%eax
801028d8:	8b 40 18             	mov    0x18(%eax),%eax
801028db:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801028de:	0f 87 6c ff ff ff    	ja     80102850 <dirlookup+0x2c>
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
801028e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
801028f1:	83 ec 04             	sub    $0x4,%esp
801028f4:	6a 00                	push   $0x0
801028f6:	ff 75 0c             	pushl  0xc(%ebp)
801028f9:	ff 75 08             	pushl  0x8(%ebp)
801028fc:	e8 23 ff ff ff       	call   80102824 <dirlookup>
80102901:	83 c4 10             	add    $0x10,%esp
80102904:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102907:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010290b:	74 18                	je     80102925 <dirlink+0x3a>
        iput(ip);
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	ff 75 f0             	pushl  -0x10(%ebp)
80102913:	e8 0f f7 ff ff       	call   80102027 <iput>
80102918:	83 c4 10             	add    $0x10,%esp
        return -1;
8010291b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102920:	e9 9c 00 00 00       	jmp    801029c1 <dirlink+0xd6>
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010292c:	eb 39                	jmp    80102967 <dirlink+0x7c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010292e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102931:	6a 10                	push   $0x10
80102933:	50                   	push   %eax
80102934:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102937:	50                   	push   %eax
80102938:	ff 75 08             	pushl  0x8(%ebp)
8010293b:	e8 58 fb ff ff       	call   80102498 <readi>
80102940:	83 c4 10             	add    $0x10,%esp
80102943:	83 f8 10             	cmp    $0x10,%eax
80102946:	74 0d                	je     80102955 <dirlink+0x6a>
            panic("dirlink read");
80102948:	83 ec 0c             	sub    $0xc,%esp
8010294b:	68 1b 8e 10 80       	push   $0x80108e1b
80102950:	e8 11 dc ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102955:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102959:	66 85 c0             	test   %ax,%ax
8010295c:	74 18                	je     80102976 <dirlink+0x8b>
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
8010295e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102961:	83 c0 10             	add    $0x10,%eax
80102964:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102967:	8b 45 08             	mov    0x8(%ebp),%eax
8010296a:	8b 50 18             	mov    0x18(%eax),%edx
8010296d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102970:	39 c2                	cmp    %eax,%edx
80102972:	77 ba                	ja     8010292e <dirlink+0x43>
80102974:	eb 01                	jmp    80102977 <dirlink+0x8c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            break;
80102976:	90                   	nop
    }

    strncpy(de.name, name, DIRSIZ);
80102977:	83 ec 04             	sub    $0x4,%esp
8010297a:	6a 0e                	push   $0xe
8010297c:	ff 75 0c             	pushl  0xc(%ebp)
8010297f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102982:	83 c0 02             	add    $0x2,%eax
80102985:	50                   	push   %eax
80102986:	e8 3a 31 00 00       	call   80105ac5 <strncpy>
8010298b:	83 c4 10             	add    $0x10,%esp
    de.inum = inum;
8010298e:	8b 45 10             	mov    0x10(%ebp),%eax
80102991:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102998:	6a 10                	push   $0x10
8010299a:	50                   	push   %eax
8010299b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010299e:	50                   	push   %eax
8010299f:	ff 75 08             	pushl  0x8(%ebp)
801029a2:	e8 91 fc ff ff       	call   80102638 <writei>
801029a7:	83 c4 10             	add    $0x10,%esp
801029aa:	83 f8 10             	cmp    $0x10,%eax
801029ad:	74 0d                	je     801029bc <dirlink+0xd1>
        panic("dirlink");
801029af:	83 ec 0c             	sub    $0xc,%esp
801029b2:	68 28 8e 10 80       	push   $0x80108e28
801029b7:	e8 aa db ff ff       	call   80100566 <panic>

    return 0;
801029bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029c1:	c9                   	leave  
801029c2:	c3                   	ret    

801029c3 <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
801029c3:	55                   	push   %ebp
801029c4:	89 e5                	mov    %esp,%ebp
801029c6:	83 ec 18             	sub    $0x18,%esp
    
    char* s;
    int len;

    while (*path == '/')
801029c9:	eb 04                	jmp    801029cf <skipelem+0xc>
        path++;
801029cb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
    
    char* s;
    int len;

    while (*path == '/')
801029cf:	8b 45 08             	mov    0x8(%ebp),%eax
801029d2:	0f b6 00             	movzbl (%eax),%eax
801029d5:	3c 2f                	cmp    $0x2f,%al
801029d7:	74 f2                	je     801029cb <skipelem+0x8>
        path++;
    if (*path == 0)
801029d9:	8b 45 08             	mov    0x8(%ebp),%eax
801029dc:	0f b6 00             	movzbl (%eax),%eax
801029df:	84 c0                	test   %al,%al
801029e1:	75 07                	jne    801029ea <skipelem+0x27>
        return 0;
801029e3:	b8 00 00 00 00       	mov    $0x0,%eax
801029e8:	eb 7b                	jmp    80102a65 <skipelem+0xa2>
    s = path;
801029ea:	8b 45 08             	mov    0x8(%ebp),%eax
801029ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (*path != '/' && *path != 0)
801029f0:	eb 04                	jmp    801029f6 <skipelem+0x33>
        path++;
801029f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
801029f6:	8b 45 08             	mov    0x8(%ebp),%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	3c 2f                	cmp    $0x2f,%al
801029fe:	74 0a                	je     80102a0a <skipelem+0x47>
80102a00:	8b 45 08             	mov    0x8(%ebp),%eax
80102a03:	0f b6 00             	movzbl (%eax),%eax
80102a06:	84 c0                	test   %al,%al
80102a08:	75 e8                	jne    801029f2 <skipelem+0x2f>
        path++;
    len = path - s;
80102a0a:	8b 55 08             	mov    0x8(%ebp),%edx
80102a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a10:	29 c2                	sub    %eax,%edx
80102a12:	89 d0                	mov    %edx,%eax
80102a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (len >= DIRSIZ)
80102a17:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102a1b:	7e 15                	jle    80102a32 <skipelem+0x6f>
        memmove(name, s, DIRSIZ);
80102a1d:	83 ec 04             	sub    $0x4,%esp
80102a20:	6a 0e                	push   $0xe
80102a22:	ff 75 f4             	pushl  -0xc(%ebp)
80102a25:	ff 75 0c             	pushl  0xc(%ebp)
80102a28:	e8 ac 2f 00 00       	call   801059d9 <memmove>
80102a2d:	83 c4 10             	add    $0x10,%esp
80102a30:	eb 26                	jmp    80102a58 <skipelem+0x95>
    else {
        memmove(name, s, len);
80102a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a35:	83 ec 04             	sub    $0x4,%esp
80102a38:	50                   	push   %eax
80102a39:	ff 75 f4             	pushl  -0xc(%ebp)
80102a3c:	ff 75 0c             	pushl  0xc(%ebp)
80102a3f:	e8 95 2f 00 00       	call   801059d9 <memmove>
80102a44:	83 c4 10             	add    $0x10,%esp
        name[len] = 0;
80102a47:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a4d:	01 d0                	add    %edx,%eax
80102a4f:	c6 00 00             	movb   $0x0,(%eax)
    }
    while (*path == '/')
80102a52:	eb 04                	jmp    80102a58 <skipelem+0x95>
        path++;
80102a54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102a58:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5b:	0f b6 00             	movzbl (%eax),%eax
80102a5e:	3c 2f                	cmp    $0x2f,%al
80102a60:	74 f2                	je     80102a54 <skipelem+0x91>
        path++;
    return path;
80102a62:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102a65:	c9                   	leave  
80102a66:	c3                   	ret    

80102a67 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, char* name)
{
80102a67:	55                   	push   %ebp
80102a68:	89 e5                	mov    %esp,%ebp
80102a6a:	83 ec 18             	sub    $0x18,%esp
                                           // cprintf("namex \n");

    struct inode* ip, *next;
     // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
80102a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a70:	0f b6 00             	movzbl (%eax),%eax
80102a73:	3c 2f                	cmp    $0x2f,%al
80102a75:	75 1d                	jne    80102a94 <namex+0x2d>
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
80102a77:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80102a7c:	83 ec 04             	sub    $0x4,%esp
80102a7f:	50                   	push   %eax
80102a80:	6a 01                	push   $0x1
80102a82:	6a 00                	push   $0x0
80102a84:	e8 3b f2 ff ff       	call   80101cc4 <iget>
80102a89:	83 c4 10             	add    $0x10,%esp
80102a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a8f:	e9 bb 00 00 00       	jmp    80102b4f <namex+0xe8>
    else
        ip = idup(proc->cwd);
80102a94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102a9a:	8b 40 68             	mov    0x68(%eax),%eax
80102a9d:	83 ec 0c             	sub    $0xc,%esp
80102aa0:	50                   	push   %eax
80102aa1:	e8 34 f3 ff ff       	call   80101dda <idup>
80102aa6:	83 c4 10             	add    $0x10,%esp
80102aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while ((path = skipelem(path, name)) != 0) {
80102aac:	e9 9e 00 00 00       	jmp    80102b4f <namex+0xe8>
      //  cprintf("namex inode %d,part number %d \n",ip->inum,ip->part->number);
        ilock(ip);
80102ab1:	83 ec 0c             	sub    $0xc,%esp
80102ab4:	ff 75 f4             	pushl  -0xc(%ebp)
80102ab7:	e8 58 f3 ff ff       	call   80101e14 <ilock>
80102abc:	83 c4 10             	add    $0x10,%esp
        if (ip->type != T_DIR) {
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102ac6:	66 83 f8 01          	cmp    $0x1,%ax
80102aca:	74 18                	je     80102ae4 <namex+0x7d>
            iunlockput(ip);
80102acc:	83 ec 0c             	sub    $0xc,%esp
80102acf:	ff 75 f4             	pushl  -0xc(%ebp)
80102ad2:	e8 40 f6 ff ff       	call   80102117 <iunlockput>
80102ad7:	83 c4 10             	add    $0x10,%esp
            return 0;
80102ada:	b8 00 00 00 00       	mov    $0x0,%eax
80102adf:	e9 a7 00 00 00       	jmp    80102b8b <namex+0x124>
        }
        if (nameiparent && *path == '\0') {
80102ae4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102ae8:	74 20                	je     80102b0a <namex+0xa3>
80102aea:	8b 45 08             	mov    0x8(%ebp),%eax
80102aed:	0f b6 00             	movzbl (%eax),%eax
80102af0:	84 c0                	test   %al,%al
80102af2:	75 16                	jne    80102b0a <namex+0xa3>
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
80102af4:	83 ec 0c             	sub    $0xc,%esp
80102af7:	ff 75 f4             	pushl  -0xc(%ebp)
80102afa:	e8 b6 f4 ff ff       	call   80101fb5 <iunlock>
80102aff:	83 c4 10             	add    $0x10,%esp
            return ip;
80102b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b05:	e9 81 00 00 00       	jmp    80102b8b <namex+0x124>
        }
        if ((next = dirlookup(ip, name, 0)) == 0) {
80102b0a:	83 ec 04             	sub    $0x4,%esp
80102b0d:	6a 00                	push   $0x0
80102b0f:	ff 75 10             	pushl  0x10(%ebp)
80102b12:	ff 75 f4             	pushl  -0xc(%ebp)
80102b15:	e8 0a fd ff ff       	call   80102824 <dirlookup>
80102b1a:	83 c4 10             	add    $0x10,%esp
80102b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102b20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102b24:	75 15                	jne    80102b3b <namex+0xd4>
            iunlockput(ip);
80102b26:	83 ec 0c             	sub    $0xc,%esp
80102b29:	ff 75 f4             	pushl  -0xc(%ebp)
80102b2c:	e8 e6 f5 ff ff       	call   80102117 <iunlockput>
80102b31:	83 c4 10             	add    $0x10,%esp
            return 0;
80102b34:	b8 00 00 00 00       	mov    $0x0,%eax
80102b39:	eb 50                	jmp    80102b8b <namex+0x124>
        }
        iunlockput(ip);
80102b3b:	83 ec 0c             	sub    $0xc,%esp
80102b3e:	ff 75 f4             	pushl  -0xc(%ebp)
80102b41:	e8 d1 f5 ff ff       	call   80102117 <iunlockput>
80102b46:	83 c4 10             	add    $0x10,%esp
        ip = next;
80102b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102b4f:	83 ec 08             	sub    $0x8,%esp
80102b52:	ff 75 10             	pushl  0x10(%ebp)
80102b55:	ff 75 08             	pushl  0x8(%ebp)
80102b58:	e8 66 fe ff ff       	call   801029c3 <skipelem>
80102b5d:	83 c4 10             	add    $0x10,%esp
80102b60:	89 45 08             	mov    %eax,0x8(%ebp)
80102b63:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102b67:	0f 85 44 ff ff ff    	jne    80102ab1 <namex+0x4a>
            return 0;
        }
        iunlockput(ip);
        ip = next;
    }
    if (nameiparent) {
80102b6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102b71:	74 15                	je     80102b88 <namex+0x121>
        iput(ip);
80102b73:	83 ec 0c             	sub    $0xc,%esp
80102b76:	ff 75 f4             	pushl  -0xc(%ebp)
80102b79:	e8 a9 f4 ff ff       	call   80102027 <iput>
80102b7e:	83 c4 10             	add    $0x10,%esp
        return 0;
80102b81:	b8 00 00 00 00       	mov    $0x0,%eax
80102b86:	eb 03                	jmp    80102b8b <namex+0x124>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b8b:	c9                   	leave  
80102b8c:	c3                   	ret    

80102b8d <namei>:

struct inode* namei(char* path)
{
80102b8d:	55                   	push   %ebp
80102b8e:	89 e5                	mov    %esp,%ebp
80102b90:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, name);
80102b93:	83 ec 04             	sub    $0x4,%esp
80102b96:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102b99:	50                   	push   %eax
80102b9a:	6a 00                	push   $0x0
80102b9c:	ff 75 08             	pushl  0x8(%ebp)
80102b9f:	e8 c3 fe ff ff       	call   80102a67 <namex>
80102ba4:	83 c4 10             	add    $0x10,%esp
}
80102ba7:	c9                   	leave  
80102ba8:	c3                   	ret    

80102ba9 <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102ba9:	55                   	push   %ebp
80102baa:	89 e5                	mov    %esp,%ebp
80102bac:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, name);
80102baf:	83 ec 04             	sub    $0x4,%esp
80102bb2:	ff 75 0c             	pushl  0xc(%ebp)
80102bb5:	6a 01                	push   $0x1
80102bb7:	ff 75 08             	pushl  0x8(%ebp)
80102bba:	e8 a8 fe ff ff       	call   80102a67 <namex>
80102bbf:	83 c4 10             	add    $0x10,%esp
}
80102bc2:	c9                   	leave  
80102bc3:	c3                   	ret    

80102bc4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bc4:	55                   	push   %ebp
80102bc5:	89 e5                	mov    %esp,%ebp
80102bc7:	83 ec 14             	sub    $0x14,%esp
80102bca:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bd1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102bd5:	89 c2                	mov    %eax,%edx
80102bd7:	ec                   	in     (%dx),%al
80102bd8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bdb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102bdf:	c9                   	leave  
80102be0:	c3                   	ret    

80102be1 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102be1:	55                   	push   %ebp
80102be2:	89 e5                	mov    %esp,%ebp
80102be4:	57                   	push   %edi
80102be5:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102be6:	8b 55 08             	mov    0x8(%ebp),%edx
80102be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102bec:	8b 45 10             	mov    0x10(%ebp),%eax
80102bef:	89 cb                	mov    %ecx,%ebx
80102bf1:	89 df                	mov    %ebx,%edi
80102bf3:	89 c1                	mov    %eax,%ecx
80102bf5:	fc                   	cld    
80102bf6:	f3 6d                	rep insl (%dx),%es:(%edi)
80102bf8:	89 c8                	mov    %ecx,%eax
80102bfa:	89 fb                	mov    %edi,%ebx
80102bfc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102bff:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102c02:	90                   	nop
80102c03:	5b                   	pop    %ebx
80102c04:	5f                   	pop    %edi
80102c05:	5d                   	pop    %ebp
80102c06:	c3                   	ret    

80102c07 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102c07:	55                   	push   %ebp
80102c08:	89 e5                	mov    %esp,%ebp
80102c0a:	83 ec 08             	sub    $0x8,%esp
80102c0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c10:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c13:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102c17:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c1a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102c1e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102c22:	ee                   	out    %al,(%dx)
}
80102c23:	90                   	nop
80102c24:	c9                   	leave  
80102c25:	c3                   	ret    

80102c26 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102c26:	55                   	push   %ebp
80102c27:	89 e5                	mov    %esp,%ebp
80102c29:	56                   	push   %esi
80102c2a:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102c2b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c31:	8b 45 10             	mov    0x10(%ebp),%eax
80102c34:	89 cb                	mov    %ecx,%ebx
80102c36:	89 de                	mov    %ebx,%esi
80102c38:	89 c1                	mov    %eax,%ecx
80102c3a:	fc                   	cld    
80102c3b:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102c3d:	89 c8                	mov    %ecx,%eax
80102c3f:	89 f3                	mov    %esi,%ebx
80102c41:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102c44:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102c47:	90                   	nop
80102c48:	5b                   	pop    %ebx
80102c49:	5e                   	pop    %esi
80102c4a:	5d                   	pop    %ebp
80102c4b:	c3                   	ret    

80102c4c <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102c4c:	55                   	push   %ebp
80102c4d:	89 e5                	mov    %esp,%ebp
80102c4f:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102c52:	90                   	nop
80102c53:	68 f7 01 00 00       	push   $0x1f7
80102c58:	e8 67 ff ff ff       	call   80102bc4 <inb>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	0f b6 c0             	movzbl %al,%eax
80102c63:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102c66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c69:	25 c0 00 00 00       	and    $0xc0,%eax
80102c6e:	83 f8 40             	cmp    $0x40,%eax
80102c71:	75 e0                	jne    80102c53 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102c73:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102c77:	74 11                	je     80102c8a <idewait+0x3e>
80102c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c7c:	83 e0 21             	and    $0x21,%eax
80102c7f:	85 c0                	test   %eax,%eax
80102c81:	74 07                	je     80102c8a <idewait+0x3e>
    return -1;
80102c83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c88:	eb 05                	jmp    80102c8f <idewait+0x43>
  return 0;
80102c8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c8f:	c9                   	leave  
80102c90:	c3                   	ret    

80102c91 <ideinit>:

void
ideinit(void)
{
80102c91:	55                   	push   %ebp
80102c92:	89 e5                	mov    %esp,%ebp
80102c94:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102c97:	83 ec 08             	sub    $0x8,%esp
80102c9a:	68 3a 8e 10 80       	push   $0x80108e3a
80102c9f:	68 00 c6 10 80       	push   $0x8010c600
80102ca4:	e8 ec 29 00 00       	call   80105695 <initlock>
80102ca9:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102cac:	83 ec 0c             	sub    $0xc,%esp
80102caf:	6a 0e                	push   $0xe
80102cb1:	e8 f0 18 00 00       	call   801045a6 <picenable>
80102cb6:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102cb9:	a1 00 3c 11 80       	mov    0x80113c00,%eax
80102cbe:	83 e8 01             	sub    $0x1,%eax
80102cc1:	83 ec 08             	sub    $0x8,%esp
80102cc4:	50                   	push   %eax
80102cc5:	6a 0e                	push   $0xe
80102cc7:	e8 93 04 00 00       	call   8010315f <ioapicenable>
80102ccc:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102ccf:	83 ec 0c             	sub    $0xc,%esp
80102cd2:	6a 00                	push   $0x0
80102cd4:	e8 73 ff ff ff       	call   80102c4c <idewait>
80102cd9:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102cdc:	83 ec 08             	sub    $0x8,%esp
80102cdf:	68 f0 00 00 00       	push   $0xf0
80102ce4:	68 f6 01 00 00       	push   $0x1f6
80102ce9:	e8 19 ff ff ff       	call   80102c07 <outb>
80102cee:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102cf1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102cf8:	eb 24                	jmp    80102d1e <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102cfa:	83 ec 0c             	sub    $0xc,%esp
80102cfd:	68 f7 01 00 00       	push   $0x1f7
80102d02:	e8 bd fe ff ff       	call   80102bc4 <inb>
80102d07:	83 c4 10             	add    $0x10,%esp
80102d0a:	84 c0                	test   %al,%al
80102d0c:	74 0c                	je     80102d1a <ideinit+0x89>
      havedisk1 = 1;
80102d0e:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102d15:	00 00 00 
      break;
80102d18:	eb 0d                	jmp    80102d27 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102d1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102d1e:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102d25:	7e d3                	jle    80102cfa <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102d27:	83 ec 08             	sub    $0x8,%esp
80102d2a:	68 e0 00 00 00       	push   $0xe0
80102d2f:	68 f6 01 00 00       	push   $0x1f6
80102d34:	e8 ce fe ff ff       	call   80102c07 <outb>
80102d39:	83 c4 10             	add    $0x10,%esp
}
80102d3c:	90                   	nop
80102d3d:	c9                   	leave  
80102d3e:	c3                   	ret    

80102d3f <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102d3f:	55                   	push   %ebp
80102d40:	89 e5                	mov    %esp,%ebp
80102d42:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102d45:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d49:	75 0d                	jne    80102d58 <idestart+0x19>
    panic("idestart");
80102d4b:	83 ec 0c             	sub    $0xc,%esp
80102d4e:	68 3e 8e 10 80       	push   $0x80108e3e
80102d53:	e8 0e d8 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102d58:	8b 45 08             	mov    0x8(%ebp),%eax
80102d5b:	8b 40 08             	mov    0x8(%eax),%eax
80102d5e:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102d63:	76 1d                	jbe    80102d82 <idestart+0x43>
      cprintf("block %d \n");
80102d65:	83 ec 0c             	sub    $0xc,%esp
80102d68:	68 47 8e 10 80       	push   $0x80108e47
80102d6d:	e8 54 d6 ff ff       	call   801003c6 <cprintf>
80102d72:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102d75:	83 ec 0c             	sub    $0xc,%esp
80102d78:	68 52 8e 10 80       	push   $0x80108e52
80102d7d:	e8 e4 d7 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102d82:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102d89:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8c:	8b 50 08             	mov    0x8(%eax),%edx
80102d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d92:	0f af c2             	imul   %edx,%eax
80102d95:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102d98:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102d9c:	7e 0d                	jle    80102dab <idestart+0x6c>
80102d9e:	83 ec 0c             	sub    $0xc,%esp
80102da1:	68 3e 8e 10 80       	push   $0x80108e3e
80102da6:	e8 bb d7 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102dab:	83 ec 0c             	sub    $0xc,%esp
80102dae:	6a 00                	push   $0x0
80102db0:	e8 97 fe ff ff       	call   80102c4c <idewait>
80102db5:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102db8:	83 ec 08             	sub    $0x8,%esp
80102dbb:	6a 00                	push   $0x0
80102dbd:	68 f6 03 00 00       	push   $0x3f6
80102dc2:	e8 40 fe ff ff       	call   80102c07 <outb>
80102dc7:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dcd:	0f b6 c0             	movzbl %al,%eax
80102dd0:	83 ec 08             	sub    $0x8,%esp
80102dd3:	50                   	push   %eax
80102dd4:	68 f2 01 00 00       	push   $0x1f2
80102dd9:	e8 29 fe ff ff       	call   80102c07 <outb>
80102dde:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102de4:	0f b6 c0             	movzbl %al,%eax
80102de7:	83 ec 08             	sub    $0x8,%esp
80102dea:	50                   	push   %eax
80102deb:	68 f3 01 00 00       	push   $0x1f3
80102df0:	e8 12 fe ff ff       	call   80102c07 <outb>
80102df5:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102dfb:	c1 f8 08             	sar    $0x8,%eax
80102dfe:	0f b6 c0             	movzbl %al,%eax
80102e01:	83 ec 08             	sub    $0x8,%esp
80102e04:	50                   	push   %eax
80102e05:	68 f4 01 00 00       	push   $0x1f4
80102e0a:	e8 f8 fd ff ff       	call   80102c07 <outb>
80102e0f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e15:	c1 f8 10             	sar    $0x10,%eax
80102e18:	0f b6 c0             	movzbl %al,%eax
80102e1b:	83 ec 08             	sub    $0x8,%esp
80102e1e:	50                   	push   %eax
80102e1f:	68 f5 01 00 00       	push   $0x1f5
80102e24:	e8 de fd ff ff       	call   80102c07 <outb>
80102e29:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2f:	8b 40 04             	mov    0x4(%eax),%eax
80102e32:	83 e0 01             	and    $0x1,%eax
80102e35:	c1 e0 04             	shl    $0x4,%eax
80102e38:	89 c2                	mov    %eax,%edx
80102e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e3d:	c1 f8 18             	sar    $0x18,%eax
80102e40:	83 e0 0f             	and    $0xf,%eax
80102e43:	09 d0                	or     %edx,%eax
80102e45:	83 c8 e0             	or     $0xffffffe0,%eax
80102e48:	0f b6 c0             	movzbl %al,%eax
80102e4b:	83 ec 08             	sub    $0x8,%esp
80102e4e:	50                   	push   %eax
80102e4f:	68 f6 01 00 00       	push   $0x1f6
80102e54:	e8 ae fd ff ff       	call   80102c07 <outb>
80102e59:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	8b 00                	mov    (%eax),%eax
80102e61:	83 e0 04             	and    $0x4,%eax
80102e64:	85 c0                	test   %eax,%eax
80102e66:	74 30                	je     80102e98 <idestart+0x159>
    outb(0x1f7, IDE_CMD_WRITE);
80102e68:	83 ec 08             	sub    $0x8,%esp
80102e6b:	6a 30                	push   $0x30
80102e6d:	68 f7 01 00 00       	push   $0x1f7
80102e72:	e8 90 fd ff ff       	call   80102c07 <outb>
80102e77:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7d:	83 c0 18             	add    $0x18,%eax
80102e80:	83 ec 04             	sub    $0x4,%esp
80102e83:	68 80 00 00 00       	push   $0x80
80102e88:	50                   	push   %eax
80102e89:	68 f0 01 00 00       	push   $0x1f0
80102e8e:	e8 93 fd ff ff       	call   80102c26 <outsl>
80102e93:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102e96:	eb 12                	jmp    80102eaa <idestart+0x16b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102e98:	83 ec 08             	sub    $0x8,%esp
80102e9b:	6a 20                	push   $0x20
80102e9d:	68 f7 01 00 00       	push   $0x1f7
80102ea2:	e8 60 fd ff ff       	call   80102c07 <outb>
80102ea7:	83 c4 10             	add    $0x10,%esp
  }
}
80102eaa:	90                   	nop
80102eab:	c9                   	leave  
80102eac:	c3                   	ret    

80102ead <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102ead:	55                   	push   %ebp
80102eae:	89 e5                	mov    %esp,%ebp
80102eb0:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102eb3:	83 ec 0c             	sub    $0xc,%esp
80102eb6:	68 00 c6 10 80       	push   $0x8010c600
80102ebb:	e8 f7 27 00 00       	call   801056b7 <acquire>
80102ec0:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102ec3:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ecb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ecf:	75 15                	jne    80102ee6 <ideintr+0x39>
    release(&idelock);
80102ed1:	83 ec 0c             	sub    $0xc,%esp
80102ed4:	68 00 c6 10 80       	push   $0x8010c600
80102ed9:	e8 40 28 00 00       	call   8010571e <release>
80102ede:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102ee1:	e9 aa 00 00 00       	jmp    80102f90 <ideintr+0xe3>
  }
  idequeue = b->qnext;
80102ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee9:	8b 40 14             	mov    0x14(%eax),%eax
80102eec:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ef4:	8b 00                	mov    (%eax),%eax
80102ef6:	83 e0 04             	and    $0x4,%eax
80102ef9:	85 c0                	test   %eax,%eax
80102efb:	75 2d                	jne    80102f2a <ideintr+0x7d>
80102efd:	83 ec 0c             	sub    $0xc,%esp
80102f00:	6a 01                	push   $0x1
80102f02:	e8 45 fd ff ff       	call   80102c4c <idewait>
80102f07:	83 c4 10             	add    $0x10,%esp
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	78 1c                	js     80102f2a <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f11:	83 c0 18             	add    $0x18,%eax
80102f14:	83 ec 04             	sub    $0x4,%esp
80102f17:	68 80 00 00 00       	push   $0x80
80102f1c:	50                   	push   %eax
80102f1d:	68 f0 01 00 00       	push   $0x1f0
80102f22:	e8 ba fc ff ff       	call   80102be1 <insl>
80102f27:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f2d:	8b 00                	mov    (%eax),%eax
80102f2f:	83 c8 02             	or     $0x2,%eax
80102f32:	89 c2                	mov    %eax,%edx
80102f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f37:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f3c:	8b 00                	mov    (%eax),%eax
80102f3e:	83 e0 fb             	and    $0xfffffffb,%eax
80102f41:	89 c2                	mov    %eax,%edx
80102f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f46:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102f48:	83 ec 0c             	sub    $0xc,%esp
80102f4b:	ff 75 f4             	pushl  -0xc(%ebp)
80102f4e:	e8 56 25 00 00       	call   801054a9 <wakeup>
80102f53:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
80102f56:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	74 21                	je     80102f80 <ideintr+0xd3>
            cprintf("ideintr \n");
80102f5f:	83 ec 0c             	sub    $0xc,%esp
80102f62:	68 64 8e 10 80       	push   $0x80108e64
80102f67:	e8 5a d4 ff ff       	call   801003c6 <cprintf>
80102f6c:	83 c4 10             	add    $0x10,%esp
                idestart(idequeue);
80102f6f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102f74:	83 ec 0c             	sub    $0xc,%esp
80102f77:	50                   	push   %eax
80102f78:	e8 c2 fd ff ff       	call   80102d3f <idestart>
80102f7d:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
80102f80:	83 ec 0c             	sub    $0xc,%esp
80102f83:	68 00 c6 10 80       	push   $0x8010c600
80102f88:	e8 91 27 00 00       	call   8010571e <release>
80102f8d:	83 c4 10             	add    $0x10,%esp
}
80102f90:	c9                   	leave  
80102f91:	c3                   	ret    

80102f92 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102f92:	55                   	push   %ebp
80102f93:	89 e5                	mov    %esp,%ebp
80102f95:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102f98:	8b 45 08             	mov    0x8(%ebp),%eax
80102f9b:	8b 00                	mov    (%eax),%eax
80102f9d:	83 e0 01             	and    $0x1,%eax
80102fa0:	85 c0                	test   %eax,%eax
80102fa2:	75 0d                	jne    80102fb1 <iderw+0x1f>
    panic("iderw: buf not busy");
80102fa4:	83 ec 0c             	sub    $0xc,%esp
80102fa7:	68 6e 8e 10 80       	push   $0x80108e6e
80102fac:	e8 b5 d5 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb4:	8b 00                	mov    (%eax),%eax
80102fb6:	83 e0 06             	and    $0x6,%eax
80102fb9:	83 f8 02             	cmp    $0x2,%eax
80102fbc:	75 0d                	jne    80102fcb <iderw+0x39>
    panic("iderw: nothing to do");
80102fbe:	83 ec 0c             	sub    $0xc,%esp
80102fc1:	68 82 8e 10 80       	push   $0x80108e82
80102fc6:	e8 9b d5 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80102fce:	8b 40 04             	mov    0x4(%eax),%eax
80102fd1:	85 c0                	test   %eax,%eax
80102fd3:	74 16                	je     80102feb <iderw+0x59>
80102fd5:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102fda:	85 c0                	test   %eax,%eax
80102fdc:	75 0d                	jne    80102feb <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102fde:	83 ec 0c             	sub    $0xc,%esp
80102fe1:	68 97 8e 10 80       	push   $0x80108e97
80102fe6:	e8 7b d5 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102feb:	83 ec 0c             	sub    $0xc,%esp
80102fee:	68 00 c6 10 80       	push   $0x8010c600
80102ff3:	e8 bf 26 00 00       	call   801056b7 <acquire>
80102ff8:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ffe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80103005:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
8010300c:	eb 0b                	jmp    80103019 <iderw+0x87>
8010300e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103011:	8b 00                	mov    (%eax),%eax
80103013:	83 c0 14             	add    $0x14,%eax
80103016:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010301c:	8b 00                	mov    (%eax),%eax
8010301e:	85 c0                	test   %eax,%eax
80103020:	75 ec                	jne    8010300e <iderw+0x7c>
    ;
  *pp = b;
80103022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103025:	8b 55 08             	mov    0x8(%ebp),%edx
80103028:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
8010302a:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010302f:	3b 45 08             	cmp    0x8(%ebp),%eax
80103032:	75 23                	jne    80103057 <iderw+0xc5>
     // cprintf("iderw \n");
          idestart(b);
80103034:	83 ec 0c             	sub    $0xc,%esp
80103037:	ff 75 08             	pushl  0x8(%ebp)
8010303a:	e8 00 fd ff ff       	call   80102d3f <idestart>
8010303f:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103042:	eb 13                	jmp    80103057 <iderw+0xc5>
    sleep(b, &idelock);
80103044:	83 ec 08             	sub    $0x8,%esp
80103047:	68 00 c6 10 80       	push   $0x8010c600
8010304c:	ff 75 08             	pushl  0x8(%ebp)
8010304f:	e8 6a 23 00 00       	call   801053be <sleep>
80103054:	83 c4 10             	add    $0x10,%esp
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103057:	8b 45 08             	mov    0x8(%ebp),%eax
8010305a:	8b 00                	mov    (%eax),%eax
8010305c:	83 e0 06             	and    $0x6,%eax
8010305f:	83 f8 02             	cmp    $0x2,%eax
80103062:	75 e0                	jne    80103044 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80103064:	83 ec 0c             	sub    $0xc,%esp
80103067:	68 00 c6 10 80       	push   $0x8010c600
8010306c:	e8 ad 26 00 00       	call   8010571e <release>
80103071:	83 c4 10             	add    $0x10,%esp
}
80103074:	90                   	nop
80103075:	c9                   	leave  
80103076:	c3                   	ret    

80103077 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103077:	55                   	push   %ebp
80103078:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010307a:	a1 dc 34 11 80       	mov    0x801134dc,%eax
8010307f:	8b 55 08             	mov    0x8(%ebp),%edx
80103082:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103084:	a1 dc 34 11 80       	mov    0x801134dc,%eax
80103089:	8b 40 10             	mov    0x10(%eax),%eax
}
8010308c:	5d                   	pop    %ebp
8010308d:	c3                   	ret    

8010308e <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010308e:	55                   	push   %ebp
8010308f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103091:	a1 dc 34 11 80       	mov    0x801134dc,%eax
80103096:	8b 55 08             	mov    0x8(%ebp),%edx
80103099:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010309b:	a1 dc 34 11 80       	mov    0x801134dc,%eax
801030a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801030a3:	89 50 10             	mov    %edx,0x10(%eax)
}
801030a6:	90                   	nop
801030a7:	5d                   	pop    %ebp
801030a8:	c3                   	ret    

801030a9 <ioapicinit>:

void
ioapicinit(void)
{
801030a9:	55                   	push   %ebp
801030aa:	89 e5                	mov    %esp,%ebp
801030ac:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
801030af:	a1 04 36 11 80       	mov    0x80113604,%eax
801030b4:	85 c0                	test   %eax,%eax
801030b6:	0f 84 a0 00 00 00    	je     8010315c <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801030bc:	c7 05 dc 34 11 80 00 	movl   $0xfec00000,0x801134dc
801030c3:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801030c6:	6a 01                	push   $0x1
801030c8:	e8 aa ff ff ff       	call   80103077 <ioapicread>
801030cd:	83 c4 04             	add    $0x4,%esp
801030d0:	c1 e8 10             	shr    $0x10,%eax
801030d3:	25 ff 00 00 00       	and    $0xff,%eax
801030d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801030db:	6a 00                	push   $0x0
801030dd:	e8 95 ff ff ff       	call   80103077 <ioapicread>
801030e2:	83 c4 04             	add    $0x4,%esp
801030e5:	c1 e8 18             	shr    $0x18,%eax
801030e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801030eb:	0f b6 05 00 36 11 80 	movzbl 0x80113600,%eax
801030f2:	0f b6 c0             	movzbl %al,%eax
801030f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801030f8:	74 10                	je     8010310a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801030fa:	83 ec 0c             	sub    $0xc,%esp
801030fd:	68 b8 8e 10 80       	push   $0x80108eb8
80103102:	e8 bf d2 ff ff       	call   801003c6 <cprintf>
80103107:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010310a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103111:	eb 3f                	jmp    80103152 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103116:	83 c0 20             	add    $0x20,%eax
80103119:	0d 00 00 01 00       	or     $0x10000,%eax
8010311e:	89 c2                	mov    %eax,%edx
80103120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103123:	83 c0 08             	add    $0x8,%eax
80103126:	01 c0                	add    %eax,%eax
80103128:	83 ec 08             	sub    $0x8,%esp
8010312b:	52                   	push   %edx
8010312c:	50                   	push   %eax
8010312d:	e8 5c ff ff ff       	call   8010308e <ioapicwrite>
80103132:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80103135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103138:	83 c0 08             	add    $0x8,%eax
8010313b:	01 c0                	add    %eax,%eax
8010313d:	83 c0 01             	add    $0x1,%eax
80103140:	83 ec 08             	sub    $0x8,%esp
80103143:	6a 00                	push   $0x0
80103145:	50                   	push   %eax
80103146:	e8 43 ff ff ff       	call   8010308e <ioapicwrite>
8010314b:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010314e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103155:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103158:	7e b9                	jle    80103113 <ioapicinit+0x6a>
8010315a:	eb 01                	jmp    8010315d <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
8010315c:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010315d:	c9                   	leave  
8010315e:	c3                   	ret    

8010315f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010315f:	55                   	push   %ebp
80103160:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80103162:	a1 04 36 11 80       	mov    0x80113604,%eax
80103167:	85 c0                	test   %eax,%eax
80103169:	74 39                	je     801031a4 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010316b:	8b 45 08             	mov    0x8(%ebp),%eax
8010316e:	83 c0 20             	add    $0x20,%eax
80103171:	89 c2                	mov    %eax,%edx
80103173:	8b 45 08             	mov    0x8(%ebp),%eax
80103176:	83 c0 08             	add    $0x8,%eax
80103179:	01 c0                	add    %eax,%eax
8010317b:	52                   	push   %edx
8010317c:	50                   	push   %eax
8010317d:	e8 0c ff ff ff       	call   8010308e <ioapicwrite>
80103182:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103185:	8b 45 0c             	mov    0xc(%ebp),%eax
80103188:	c1 e0 18             	shl    $0x18,%eax
8010318b:	89 c2                	mov    %eax,%edx
8010318d:	8b 45 08             	mov    0x8(%ebp),%eax
80103190:	83 c0 08             	add    $0x8,%eax
80103193:	01 c0                	add    %eax,%eax
80103195:	83 c0 01             	add    $0x1,%eax
80103198:	52                   	push   %edx
80103199:	50                   	push   %eax
8010319a:	e8 ef fe ff ff       	call   8010308e <ioapicwrite>
8010319f:	83 c4 08             	add    $0x8,%esp
801031a2:	eb 01                	jmp    801031a5 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801031a4:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801031a5:	c9                   	leave  
801031a6:	c3                   	ret    

801031a7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801031a7:	55                   	push   %ebp
801031a8:	89 e5                	mov    %esp,%ebp
801031aa:	8b 45 08             	mov    0x8(%ebp),%eax
801031ad:	05 00 00 00 80       	add    $0x80000000,%eax
801031b2:	5d                   	pop    %ebp
801031b3:	c3                   	ret    

801031b4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801031b4:	55                   	push   %ebp
801031b5:	89 e5                	mov    %esp,%ebp
801031b7:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801031ba:	83 ec 08             	sub    $0x8,%esp
801031bd:	68 ea 8e 10 80       	push   $0x80108eea
801031c2:	68 e0 34 11 80       	push   $0x801134e0
801031c7:	e8 c9 24 00 00       	call   80105695 <initlock>
801031cc:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801031cf:	c7 05 14 35 11 80 00 	movl   $0x0,0x80113514
801031d6:	00 00 00 
  freerange(vstart, vend);
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	ff 75 0c             	pushl  0xc(%ebp)
801031df:	ff 75 08             	pushl  0x8(%ebp)
801031e2:	e8 2a 00 00 00       	call   80103211 <freerange>
801031e7:	83 c4 10             	add    $0x10,%esp
}
801031ea:	90                   	nop
801031eb:	c9                   	leave  
801031ec:	c3                   	ret    

801031ed <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801031ed:	55                   	push   %ebp
801031ee:	89 e5                	mov    %esp,%ebp
801031f0:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801031f3:	83 ec 08             	sub    $0x8,%esp
801031f6:	ff 75 0c             	pushl  0xc(%ebp)
801031f9:	ff 75 08             	pushl  0x8(%ebp)
801031fc:	e8 10 00 00 00       	call   80103211 <freerange>
80103201:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80103204:	c7 05 14 35 11 80 01 	movl   $0x1,0x80113514
8010320b:	00 00 00 
}
8010320e:	90                   	nop
8010320f:	c9                   	leave  
80103210:	c3                   	ret    

80103211 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103211:	55                   	push   %ebp
80103212:	89 e5                	mov    %esp,%ebp
80103214:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103217:	8b 45 08             	mov    0x8(%ebp),%eax
8010321a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010321f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103227:	eb 15                	jmp    8010323e <freerange+0x2d>
    kfree(p);
80103229:	83 ec 0c             	sub    $0xc,%esp
8010322c:	ff 75 f4             	pushl  -0xc(%ebp)
8010322f:	e8 1a 00 00 00       	call   8010324e <kfree>
80103234:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103237:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103241:	05 00 10 00 00       	add    $0x1000,%eax
80103246:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103249:	76 de                	jbe    80103229 <freerange+0x18>
    kfree(p);
}
8010324b:	90                   	nop
8010324c:	c9                   	leave  
8010324d:	c3                   	ret    

8010324e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010324e:	55                   	push   %ebp
8010324f:	89 e5                	mov    %esp,%ebp
80103251:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80103254:	8b 45 08             	mov    0x8(%ebp),%eax
80103257:	25 ff 0f 00 00       	and    $0xfff,%eax
8010325c:	85 c0                	test   %eax,%eax
8010325e:	75 1b                	jne    8010327b <kfree+0x2d>
80103260:	81 7d 08 fc 63 11 80 	cmpl   $0x801163fc,0x8(%ebp)
80103267:	72 12                	jb     8010327b <kfree+0x2d>
80103269:	ff 75 08             	pushl  0x8(%ebp)
8010326c:	e8 36 ff ff ff       	call   801031a7 <v2p>
80103271:	83 c4 04             	add    $0x4,%esp
80103274:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103279:	76 0d                	jbe    80103288 <kfree+0x3a>
    panic("kfree");
8010327b:	83 ec 0c             	sub    $0xc,%esp
8010327e:	68 ef 8e 10 80       	push   $0x80108eef
80103283:	e8 de d2 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103288:	83 ec 04             	sub    $0x4,%esp
8010328b:	68 00 10 00 00       	push   $0x1000
80103290:	6a 01                	push   $0x1
80103292:	ff 75 08             	pushl  0x8(%ebp)
80103295:	e8 80 26 00 00       	call   8010591a <memset>
8010329a:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010329d:	a1 14 35 11 80       	mov    0x80113514,%eax
801032a2:	85 c0                	test   %eax,%eax
801032a4:	74 10                	je     801032b6 <kfree+0x68>
    acquire(&kmem.lock);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 e0 34 11 80       	push   $0x801134e0
801032ae:	e8 04 24 00 00       	call   801056b7 <acquire>
801032b3:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801032b6:	8b 45 08             	mov    0x8(%ebp),%eax
801032b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801032bc:	8b 15 18 35 11 80    	mov    0x80113518,%edx
801032c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c5:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801032c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ca:	a3 18 35 11 80       	mov    %eax,0x80113518
  if(kmem.use_lock)
801032cf:	a1 14 35 11 80       	mov    0x80113514,%eax
801032d4:	85 c0                	test   %eax,%eax
801032d6:	74 10                	je     801032e8 <kfree+0x9a>
    release(&kmem.lock);
801032d8:	83 ec 0c             	sub    $0xc,%esp
801032db:	68 e0 34 11 80       	push   $0x801134e0
801032e0:	e8 39 24 00 00       	call   8010571e <release>
801032e5:	83 c4 10             	add    $0x10,%esp
}
801032e8:	90                   	nop
801032e9:	c9                   	leave  
801032ea:	c3                   	ret    

801032eb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801032eb:	55                   	push   %ebp
801032ec:	89 e5                	mov    %esp,%ebp
801032ee:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801032f1:	a1 14 35 11 80       	mov    0x80113514,%eax
801032f6:	85 c0                	test   %eax,%eax
801032f8:	74 10                	je     8010330a <kalloc+0x1f>
    acquire(&kmem.lock);
801032fa:	83 ec 0c             	sub    $0xc,%esp
801032fd:	68 e0 34 11 80       	push   $0x801134e0
80103302:	e8 b0 23 00 00       	call   801056b7 <acquire>
80103307:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010330a:	a1 18 35 11 80       	mov    0x80113518,%eax
8010330f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103312:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103316:	74 0a                	je     80103322 <kalloc+0x37>
    kmem.freelist = r->next;
80103318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331b:	8b 00                	mov    (%eax),%eax
8010331d:	a3 18 35 11 80       	mov    %eax,0x80113518
  if(kmem.use_lock)
80103322:	a1 14 35 11 80       	mov    0x80113514,%eax
80103327:	85 c0                	test   %eax,%eax
80103329:	74 10                	je     8010333b <kalloc+0x50>
    release(&kmem.lock);
8010332b:	83 ec 0c             	sub    $0xc,%esp
8010332e:	68 e0 34 11 80       	push   $0x801134e0
80103333:	e8 e6 23 00 00       	call   8010571e <release>
80103338:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010333b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010333e:	c9                   	leave  
8010333f:	c3                   	ret    

80103340 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103340:	55                   	push   %ebp
80103341:	89 e5                	mov    %esp,%ebp
80103343:	83 ec 14             	sub    $0x14,%esp
80103346:	8b 45 08             	mov    0x8(%ebp),%eax
80103349:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010334d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103351:	89 c2                	mov    %eax,%edx
80103353:	ec                   	in     (%dx),%al
80103354:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103357:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010335b:	c9                   	leave  
8010335c:	c3                   	ret    

8010335d <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010335d:	55                   	push   %ebp
8010335e:	89 e5                	mov    %esp,%ebp
80103360:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103363:	6a 64                	push   $0x64
80103365:	e8 d6 ff ff ff       	call   80103340 <inb>
8010336a:	83 c4 04             	add    $0x4,%esp
8010336d:	0f b6 c0             	movzbl %al,%eax
80103370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103376:	83 e0 01             	and    $0x1,%eax
80103379:	85 c0                	test   %eax,%eax
8010337b:	75 0a                	jne    80103387 <kbdgetc+0x2a>
    return -1;
8010337d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103382:	e9 23 01 00 00       	jmp    801034aa <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103387:	6a 60                	push   $0x60
80103389:	e8 b2 ff ff ff       	call   80103340 <inb>
8010338e:	83 c4 04             	add    $0x4,%esp
80103391:	0f b6 c0             	movzbl %al,%eax
80103394:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103397:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010339e:	75 17                	jne    801033b7 <kbdgetc+0x5a>
    shift |= E0ESC;
801033a0:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801033a5:	83 c8 40             	or     $0x40,%eax
801033a8:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
801033ad:	b8 00 00 00 00       	mov    $0x0,%eax
801033b2:	e9 f3 00 00 00       	jmp    801034aa <kbdgetc+0x14d>
  } else if(data & 0x80){
801033b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033ba:	25 80 00 00 00       	and    $0x80,%eax
801033bf:	85 c0                	test   %eax,%eax
801033c1:	74 45                	je     80103408 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801033c3:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801033c8:	83 e0 40             	and    $0x40,%eax
801033cb:	85 c0                	test   %eax,%eax
801033cd:	75 08                	jne    801033d7 <kbdgetc+0x7a>
801033cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033d2:	83 e0 7f             	and    $0x7f,%eax
801033d5:	eb 03                	jmp    801033da <kbdgetc+0x7d>
801033d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801033dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033e0:	05 40 a0 10 80       	add    $0x8010a040,%eax
801033e5:	0f b6 00             	movzbl (%eax),%eax
801033e8:	83 c8 40             	or     $0x40,%eax
801033eb:	0f b6 c0             	movzbl %al,%eax
801033ee:	f7 d0                	not    %eax
801033f0:	89 c2                	mov    %eax,%edx
801033f2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801033f7:	21 d0                	and    %edx,%eax
801033f9:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
801033fe:	b8 00 00 00 00       	mov    $0x0,%eax
80103403:	e9 a2 00 00 00       	jmp    801034aa <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103408:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010340d:	83 e0 40             	and    $0x40,%eax
80103410:	85 c0                	test   %eax,%eax
80103412:	74 14                	je     80103428 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103414:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010341b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103420:	83 e0 bf             	and    $0xffffffbf,%eax
80103423:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80103428:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010342b:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103430:	0f b6 00             	movzbl (%eax),%eax
80103433:	0f b6 d0             	movzbl %al,%edx
80103436:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010343b:	09 d0                	or     %edx,%eax
8010343d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80103442:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103445:	05 40 a1 10 80       	add    $0x8010a140,%eax
8010344a:	0f b6 00             	movzbl (%eax),%eax
8010344d:	0f b6 d0             	movzbl %al,%edx
80103450:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103455:	31 d0                	xor    %edx,%eax
80103457:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
8010345c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103461:	83 e0 03             	and    $0x3,%eax
80103464:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
8010346b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010346e:	01 d0                	add    %edx,%eax
80103470:	0f b6 00             	movzbl (%eax),%eax
80103473:	0f b6 c0             	movzbl %al,%eax
80103476:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103479:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010347e:	83 e0 08             	and    $0x8,%eax
80103481:	85 c0                	test   %eax,%eax
80103483:	74 22                	je     801034a7 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103485:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103489:	76 0c                	jbe    80103497 <kbdgetc+0x13a>
8010348b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010348f:	77 06                	ja     80103497 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103491:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103495:	eb 10                	jmp    801034a7 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103497:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010349b:	76 0a                	jbe    801034a7 <kbdgetc+0x14a>
8010349d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801034a1:	77 04                	ja     801034a7 <kbdgetc+0x14a>
      c += 'a' - 'A';
801034a3:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801034a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801034aa:	c9                   	leave  
801034ab:	c3                   	ret    

801034ac <kbdintr>:

void
kbdintr(void)
{
801034ac:	55                   	push   %ebp
801034ad:	89 e5                	mov    %esp,%ebp
801034af:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801034b2:	83 ec 0c             	sub    $0xc,%esp
801034b5:	68 5d 33 10 80       	push   $0x8010335d
801034ba:	e8 3a d3 ff ff       	call   801007f9 <consoleintr>
801034bf:	83 c4 10             	add    $0x10,%esp
}
801034c2:	90                   	nop
801034c3:	c9                   	leave  
801034c4:	c3                   	ret    

801034c5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034c5:	55                   	push   %ebp
801034c6:	89 e5                	mov    %esp,%ebp
801034c8:	83 ec 14             	sub    $0x14,%esp
801034cb:	8b 45 08             	mov    0x8(%ebp),%eax
801034ce:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034d2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034d6:	89 c2                	mov    %eax,%edx
801034d8:	ec                   	in     (%dx),%al
801034d9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034dc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034e0:	c9                   	leave  
801034e1:	c3                   	ret    

801034e2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801034e2:	55                   	push   %ebp
801034e3:	89 e5                	mov    %esp,%ebp
801034e5:	83 ec 08             	sub    $0x8,%esp
801034e8:	8b 55 08             	mov    0x8(%ebp),%edx
801034eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801034ee:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801034f2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034f5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801034f9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801034fd:	ee                   	out    %al,(%dx)
}
801034fe:	90                   	nop
801034ff:	c9                   	leave  
80103500:	c3                   	ret    

80103501 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103501:	55                   	push   %ebp
80103502:	89 e5                	mov    %esp,%ebp
80103504:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103507:	9c                   	pushf  
80103508:	58                   	pop    %eax
80103509:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010350c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010350f:	c9                   	leave  
80103510:	c3                   	ret    

80103511 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103511:	55                   	push   %ebp
80103512:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103514:	a1 1c 35 11 80       	mov    0x8011351c,%eax
80103519:	8b 55 08             	mov    0x8(%ebp),%edx
8010351c:	c1 e2 02             	shl    $0x2,%edx
8010351f:	01 c2                	add    %eax,%edx
80103521:	8b 45 0c             	mov    0xc(%ebp),%eax
80103524:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103526:	a1 1c 35 11 80       	mov    0x8011351c,%eax
8010352b:	83 c0 20             	add    $0x20,%eax
8010352e:	8b 00                	mov    (%eax),%eax
}
80103530:	90                   	nop
80103531:	5d                   	pop    %ebp
80103532:	c3                   	ret    

80103533 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80103533:	55                   	push   %ebp
80103534:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80103536:	a1 1c 35 11 80       	mov    0x8011351c,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	0f 84 0b 01 00 00    	je     8010364e <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103543:	68 3f 01 00 00       	push   $0x13f
80103548:	6a 3c                	push   $0x3c
8010354a:	e8 c2 ff ff ff       	call   80103511 <lapicw>
8010354f:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103552:	6a 0b                	push   $0xb
80103554:	68 f8 00 00 00       	push   $0xf8
80103559:	e8 b3 ff ff ff       	call   80103511 <lapicw>
8010355e:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103561:	68 20 00 02 00       	push   $0x20020
80103566:	68 c8 00 00 00       	push   $0xc8
8010356b:	e8 a1 ff ff ff       	call   80103511 <lapicw>
80103570:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80103573:	68 80 96 98 00       	push   $0x989680
80103578:	68 e0 00 00 00       	push   $0xe0
8010357d:	e8 8f ff ff ff       	call   80103511 <lapicw>
80103582:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103585:	68 00 00 01 00       	push   $0x10000
8010358a:	68 d4 00 00 00       	push   $0xd4
8010358f:	e8 7d ff ff ff       	call   80103511 <lapicw>
80103594:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103597:	68 00 00 01 00       	push   $0x10000
8010359c:	68 d8 00 00 00       	push   $0xd8
801035a1:	e8 6b ff ff ff       	call   80103511 <lapicw>
801035a6:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801035a9:	a1 1c 35 11 80       	mov    0x8011351c,%eax
801035ae:	83 c0 30             	add    $0x30,%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	c1 e8 10             	shr    $0x10,%eax
801035b6:	0f b6 c0             	movzbl %al,%eax
801035b9:	83 f8 03             	cmp    $0x3,%eax
801035bc:	76 12                	jbe    801035d0 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
801035be:	68 00 00 01 00       	push   $0x10000
801035c3:	68 d0 00 00 00       	push   $0xd0
801035c8:	e8 44 ff ff ff       	call   80103511 <lapicw>
801035cd:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801035d0:	6a 33                	push   $0x33
801035d2:	68 dc 00 00 00       	push   $0xdc
801035d7:	e8 35 ff ff ff       	call   80103511 <lapicw>
801035dc:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801035df:	6a 00                	push   $0x0
801035e1:	68 a0 00 00 00       	push   $0xa0
801035e6:	e8 26 ff ff ff       	call   80103511 <lapicw>
801035eb:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
801035ee:	6a 00                	push   $0x0
801035f0:	68 a0 00 00 00       	push   $0xa0
801035f5:	e8 17 ff ff ff       	call   80103511 <lapicw>
801035fa:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801035fd:	6a 00                	push   $0x0
801035ff:	6a 2c                	push   $0x2c
80103601:	e8 0b ff ff ff       	call   80103511 <lapicw>
80103606:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103609:	6a 00                	push   $0x0
8010360b:	68 c4 00 00 00       	push   $0xc4
80103610:	e8 fc fe ff ff       	call   80103511 <lapicw>
80103615:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103618:	68 00 85 08 00       	push   $0x88500
8010361d:	68 c0 00 00 00       	push   $0xc0
80103622:	e8 ea fe ff ff       	call   80103511 <lapicw>
80103627:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010362a:	90                   	nop
8010362b:	a1 1c 35 11 80       	mov    0x8011351c,%eax
80103630:	05 00 03 00 00       	add    $0x300,%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	25 00 10 00 00       	and    $0x1000,%eax
8010363c:	85 c0                	test   %eax,%eax
8010363e:	75 eb                	jne    8010362b <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103640:	6a 00                	push   $0x0
80103642:	6a 20                	push   $0x20
80103644:	e8 c8 fe ff ff       	call   80103511 <lapicw>
80103649:	83 c4 08             	add    $0x8,%esp
8010364c:	eb 01                	jmp    8010364f <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010364e:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010364f:	c9                   	leave  
80103650:	c3                   	ret    

80103651 <cpunum>:

int
cpunum(void)
{
80103651:	55                   	push   %ebp
80103652:	89 e5                	mov    %esp,%ebp
80103654:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103657:	e8 a5 fe ff ff       	call   80103501 <readeflags>
8010365c:	25 00 02 00 00       	and    $0x200,%eax
80103661:	85 c0                	test   %eax,%eax
80103663:	74 26                	je     8010368b <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103665:	a1 40 c6 10 80       	mov    0x8010c640,%eax
8010366a:	8d 50 01             	lea    0x1(%eax),%edx
8010366d:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80103673:	85 c0                	test   %eax,%eax
80103675:	75 14                	jne    8010368b <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103677:	8b 45 04             	mov    0x4(%ebp),%eax
8010367a:	83 ec 08             	sub    $0x8,%esp
8010367d:	50                   	push   %eax
8010367e:	68 f8 8e 10 80       	push   $0x80108ef8
80103683:	e8 3e cd ff ff       	call   801003c6 <cprintf>
80103688:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010368b:	a1 1c 35 11 80       	mov    0x8011351c,%eax
80103690:	85 c0                	test   %eax,%eax
80103692:	74 0f                	je     801036a3 <cpunum+0x52>
    return lapic[ID]>>24;
80103694:	a1 1c 35 11 80       	mov    0x8011351c,%eax
80103699:	83 c0 20             	add    $0x20,%eax
8010369c:	8b 00                	mov    (%eax),%eax
8010369e:	c1 e8 18             	shr    $0x18,%eax
801036a1:	eb 05                	jmp    801036a8 <cpunum+0x57>
  return 0;
801036a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036a8:	c9                   	leave  
801036a9:	c3                   	ret    

801036aa <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801036aa:	55                   	push   %ebp
801036ab:	89 e5                	mov    %esp,%ebp
  if(lapic)
801036ad:	a1 1c 35 11 80       	mov    0x8011351c,%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	74 0c                	je     801036c2 <lapiceoi+0x18>
    lapicw(EOI, 0);
801036b6:	6a 00                	push   $0x0
801036b8:	6a 2c                	push   $0x2c
801036ba:	e8 52 fe ff ff       	call   80103511 <lapicw>
801036bf:	83 c4 08             	add    $0x8,%esp
}
801036c2:	90                   	nop
801036c3:	c9                   	leave  
801036c4:	c3                   	ret    

801036c5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801036c5:	55                   	push   %ebp
801036c6:	89 e5                	mov    %esp,%ebp
}
801036c8:	90                   	nop
801036c9:	5d                   	pop    %ebp
801036ca:	c3                   	ret    

801036cb <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801036cb:	55                   	push   %ebp
801036cc:	89 e5                	mov    %esp,%ebp
801036ce:	83 ec 14             	sub    $0x14,%esp
801036d1:	8b 45 08             	mov    0x8(%ebp),%eax
801036d4:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801036d7:	6a 0f                	push   $0xf
801036d9:	6a 70                	push   $0x70
801036db:	e8 02 fe ff ff       	call   801034e2 <outb>
801036e0:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801036e3:	6a 0a                	push   $0xa
801036e5:	6a 71                	push   $0x71
801036e7:	e8 f6 fd ff ff       	call   801034e2 <outb>
801036ec:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801036ef:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801036f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801036f9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801036fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103701:	83 c0 02             	add    $0x2,%eax
80103704:	8b 55 0c             	mov    0xc(%ebp),%edx
80103707:	c1 ea 04             	shr    $0x4,%edx
8010370a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010370d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103711:	c1 e0 18             	shl    $0x18,%eax
80103714:	50                   	push   %eax
80103715:	68 c4 00 00 00       	push   $0xc4
8010371a:	e8 f2 fd ff ff       	call   80103511 <lapicw>
8010371f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103722:	68 00 c5 00 00       	push   $0xc500
80103727:	68 c0 00 00 00       	push   $0xc0
8010372c:	e8 e0 fd ff ff       	call   80103511 <lapicw>
80103731:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103734:	68 c8 00 00 00       	push   $0xc8
80103739:	e8 87 ff ff ff       	call   801036c5 <microdelay>
8010373e:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103741:	68 00 85 00 00       	push   $0x8500
80103746:	68 c0 00 00 00       	push   $0xc0
8010374b:	e8 c1 fd ff ff       	call   80103511 <lapicw>
80103750:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103753:	6a 64                	push   $0x64
80103755:	e8 6b ff ff ff       	call   801036c5 <microdelay>
8010375a:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010375d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103764:	eb 3d                	jmp    801037a3 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103766:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010376a:	c1 e0 18             	shl    $0x18,%eax
8010376d:	50                   	push   %eax
8010376e:	68 c4 00 00 00       	push   $0xc4
80103773:	e8 99 fd ff ff       	call   80103511 <lapicw>
80103778:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010377b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010377e:	c1 e8 0c             	shr    $0xc,%eax
80103781:	80 cc 06             	or     $0x6,%ah
80103784:	50                   	push   %eax
80103785:	68 c0 00 00 00       	push   $0xc0
8010378a:	e8 82 fd ff ff       	call   80103511 <lapicw>
8010378f:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103792:	68 c8 00 00 00       	push   $0xc8
80103797:	e8 29 ff ff ff       	call   801036c5 <microdelay>
8010379c:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010379f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801037a3:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801037a7:	7e bd                	jle    80103766 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801037a9:	90                   	nop
801037aa:	c9                   	leave  
801037ab:	c3                   	ret    

801037ac <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801037ac:	55                   	push   %ebp
801037ad:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801037af:	8b 45 08             	mov    0x8(%ebp),%eax
801037b2:	0f b6 c0             	movzbl %al,%eax
801037b5:	50                   	push   %eax
801037b6:	6a 70                	push   $0x70
801037b8:	e8 25 fd ff ff       	call   801034e2 <outb>
801037bd:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801037c0:	68 c8 00 00 00       	push   $0xc8
801037c5:	e8 fb fe ff ff       	call   801036c5 <microdelay>
801037ca:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801037cd:	6a 71                	push   $0x71
801037cf:	e8 f1 fc ff ff       	call   801034c5 <inb>
801037d4:	83 c4 04             	add    $0x4,%esp
801037d7:	0f b6 c0             	movzbl %al,%eax
}
801037da:	c9                   	leave  
801037db:	c3                   	ret    

801037dc <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801037dc:	55                   	push   %ebp
801037dd:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801037df:	6a 00                	push   $0x0
801037e1:	e8 c6 ff ff ff       	call   801037ac <cmos_read>
801037e6:	83 c4 04             	add    $0x4,%esp
801037e9:	89 c2                	mov    %eax,%edx
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801037f0:	6a 02                	push   $0x2
801037f2:	e8 b5 ff ff ff       	call   801037ac <cmos_read>
801037f7:	83 c4 04             	add    $0x4,%esp
801037fa:	89 c2                	mov    %eax,%edx
801037fc:	8b 45 08             	mov    0x8(%ebp),%eax
801037ff:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103802:	6a 04                	push   $0x4
80103804:	e8 a3 ff ff ff       	call   801037ac <cmos_read>
80103809:	83 c4 04             	add    $0x4,%esp
8010380c:	89 c2                	mov    %eax,%edx
8010380e:	8b 45 08             	mov    0x8(%ebp),%eax
80103811:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103814:	6a 07                	push   $0x7
80103816:	e8 91 ff ff ff       	call   801037ac <cmos_read>
8010381b:	83 c4 04             	add    $0x4,%esp
8010381e:	89 c2                	mov    %eax,%edx
80103820:	8b 45 08             	mov    0x8(%ebp),%eax
80103823:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103826:	6a 08                	push   $0x8
80103828:	e8 7f ff ff ff       	call   801037ac <cmos_read>
8010382d:	83 c4 04             	add    $0x4,%esp
80103830:	89 c2                	mov    %eax,%edx
80103832:	8b 45 08             	mov    0x8(%ebp),%eax
80103835:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103838:	6a 09                	push   $0x9
8010383a:	e8 6d ff ff ff       	call   801037ac <cmos_read>
8010383f:	83 c4 04             	add    $0x4,%esp
80103842:	89 c2                	mov    %eax,%edx
80103844:	8b 45 08             	mov    0x8(%ebp),%eax
80103847:	89 50 14             	mov    %edx,0x14(%eax)
}
8010384a:	90                   	nop
8010384b:	c9                   	leave  
8010384c:	c3                   	ret    

8010384d <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010384d:	55                   	push   %ebp
8010384e:	89 e5                	mov    %esp,%ebp
80103850:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103853:	6a 0b                	push   $0xb
80103855:	e8 52 ff ff ff       	call   801037ac <cmos_read>
8010385a:	83 c4 04             	add    $0x4,%esp
8010385d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103863:	83 e0 04             	and    $0x4,%eax
80103866:	85 c0                	test   %eax,%eax
80103868:	0f 94 c0             	sete   %al
8010386b:	0f b6 c0             	movzbl %al,%eax
8010386e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103871:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103874:	50                   	push   %eax
80103875:	e8 62 ff ff ff       	call   801037dc <fill_rtcdate>
8010387a:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010387d:	6a 0a                	push   $0xa
8010387f:	e8 28 ff ff ff       	call   801037ac <cmos_read>
80103884:	83 c4 04             	add    $0x4,%esp
80103887:	25 80 00 00 00       	and    $0x80,%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	75 27                	jne    801038b7 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103890:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103893:	50                   	push   %eax
80103894:	e8 43 ff ff ff       	call   801037dc <fill_rtcdate>
80103899:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010389c:	83 ec 04             	sub    $0x4,%esp
8010389f:	6a 18                	push   $0x18
801038a1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801038a4:	50                   	push   %eax
801038a5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801038a8:	50                   	push   %eax
801038a9:	e8 d3 20 00 00       	call   80105981 <memcmp>
801038ae:	83 c4 10             	add    $0x10,%esp
801038b1:	85 c0                	test   %eax,%eax
801038b3:	74 05                	je     801038ba <cmostime+0x6d>
801038b5:	eb ba                	jmp    80103871 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801038b7:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801038b8:	eb b7                	jmp    80103871 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801038ba:	90                   	nop
  }

  // convert
  if (bcd) {
801038bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801038bf:	0f 84 b4 00 00 00    	je     80103979 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801038c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801038c8:	c1 e8 04             	shr    $0x4,%eax
801038cb:	89 c2                	mov    %eax,%edx
801038cd:	89 d0                	mov    %edx,%eax
801038cf:	c1 e0 02             	shl    $0x2,%eax
801038d2:	01 d0                	add    %edx,%eax
801038d4:	01 c0                	add    %eax,%eax
801038d6:	89 c2                	mov    %eax,%edx
801038d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801038db:	83 e0 0f             	and    $0xf,%eax
801038de:	01 d0                	add    %edx,%eax
801038e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801038e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801038e6:	c1 e8 04             	shr    $0x4,%eax
801038e9:	89 c2                	mov    %eax,%edx
801038eb:	89 d0                	mov    %edx,%eax
801038ed:	c1 e0 02             	shl    $0x2,%eax
801038f0:	01 d0                	add    %edx,%eax
801038f2:	01 c0                	add    %eax,%eax
801038f4:	89 c2                	mov    %eax,%edx
801038f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801038f9:	83 e0 0f             	and    $0xf,%eax
801038fc:	01 d0                	add    %edx,%eax
801038fe:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103901:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103904:	c1 e8 04             	shr    $0x4,%eax
80103907:	89 c2                	mov    %eax,%edx
80103909:	89 d0                	mov    %edx,%eax
8010390b:	c1 e0 02             	shl    $0x2,%eax
8010390e:	01 d0                	add    %edx,%eax
80103910:	01 c0                	add    %eax,%eax
80103912:	89 c2                	mov    %eax,%edx
80103914:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103917:	83 e0 0f             	and    $0xf,%eax
8010391a:	01 d0                	add    %edx,%eax
8010391c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010391f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103922:	c1 e8 04             	shr    $0x4,%eax
80103925:	89 c2                	mov    %eax,%edx
80103927:	89 d0                	mov    %edx,%eax
80103929:	c1 e0 02             	shl    $0x2,%eax
8010392c:	01 d0                	add    %edx,%eax
8010392e:	01 c0                	add    %eax,%eax
80103930:	89 c2                	mov    %eax,%edx
80103932:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103935:	83 e0 0f             	and    $0xf,%eax
80103938:	01 d0                	add    %edx,%eax
8010393a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010393d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103940:	c1 e8 04             	shr    $0x4,%eax
80103943:	89 c2                	mov    %eax,%edx
80103945:	89 d0                	mov    %edx,%eax
80103947:	c1 e0 02             	shl    $0x2,%eax
8010394a:	01 d0                	add    %edx,%eax
8010394c:	01 c0                	add    %eax,%eax
8010394e:	89 c2                	mov    %eax,%edx
80103950:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103953:	83 e0 0f             	and    $0xf,%eax
80103956:	01 d0                	add    %edx,%eax
80103958:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010395b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010395e:	c1 e8 04             	shr    $0x4,%eax
80103961:	89 c2                	mov    %eax,%edx
80103963:	89 d0                	mov    %edx,%eax
80103965:	c1 e0 02             	shl    $0x2,%eax
80103968:	01 d0                	add    %edx,%eax
8010396a:	01 c0                	add    %eax,%eax
8010396c:	89 c2                	mov    %eax,%edx
8010396e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103971:	83 e0 0f             	and    $0xf,%eax
80103974:	01 d0                	add    %edx,%eax
80103976:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103979:	8b 45 08             	mov    0x8(%ebp),%eax
8010397c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010397f:	89 10                	mov    %edx,(%eax)
80103981:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103984:	89 50 04             	mov    %edx,0x4(%eax)
80103987:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010398a:	89 50 08             	mov    %edx,0x8(%eax)
8010398d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103990:	89 50 0c             	mov    %edx,0xc(%eax)
80103993:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103996:	89 50 10             	mov    %edx,0x10(%eax)
80103999:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010399c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010399f:	8b 45 08             	mov    0x8(%ebp),%eax
801039a2:	8b 40 14             	mov    0x14(%eax),%eax
801039a5:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801039ab:	8b 45 08             	mov    0x8(%ebp),%eax
801039ae:	89 50 14             	mov    %edx,0x14(%eax)
}
801039b1:	90                   	nop
801039b2:	c9                   	leave  
801039b3:	c3                   	ret    

801039b4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev,int partitionNumber)
{
801039b4:	55                   	push   %ebp
801039b5:	89 e5                	mov    %esp,%ebp
801039b7:	83 ec 08             	sub    $0x8,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  initlock(&log.lock, "log");
801039ba:	83 ec 08             	sub    $0x8,%esp
801039bd:	68 24 8f 10 80       	push   $0x80108f24
801039c2:	68 20 35 11 80       	push   $0x80113520
801039c7:	e8 c9 1c 00 00       	call   80105695 <initlock>
801039cc:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  log.start = sbs[partitionNumber].offset+sbs[partitionNumber].logstart;
801039cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801039d2:	c1 e0 05             	shl    $0x5,%eax
801039d5:	05 70 d6 10 80       	add    $0x8010d670,%eax
801039da:	8b 50 0c             	mov    0xc(%eax),%edx
801039dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e0:	c1 e0 05             	shl    $0x5,%eax
801039e3:	05 70 d6 10 80       	add    $0x8010d670,%eax
801039e8:	8b 00                	mov    (%eax),%eax
801039ea:	01 d0                	add    %edx,%eax
801039ec:	a3 54 35 11 80       	mov    %eax,0x80113554
  log.size =  sbs[partitionNumber].nlog;
801039f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801039f4:	c1 e0 05             	shl    $0x5,%eax
801039f7:	05 60 d6 10 80       	add    $0x8010d660,%eax
801039fc:	8b 40 0c             	mov    0xc(%eax),%eax
801039ff:	a3 58 35 11 80       	mov    %eax,0x80113558
  log.dev = dev;
80103a04:	8b 45 08             	mov    0x8(%ebp),%eax
80103a07:	a3 64 35 11 80       	mov    %eax,0x80113564
  recover_from_log();
80103a0c:	e8 b2 01 00 00       	call   80103bc3 <recover_from_log>
}
80103a11:	90                   	nop
80103a12:	c9                   	leave  
80103a13:	c3                   	ret    

80103a14 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103a14:	55                   	push   %ebp
80103a15:	89 e5                	mov    %esp,%ebp
80103a17:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a21:	e9 95 00 00 00       	jmp    80103abb <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103a26:	8b 15 54 35 11 80    	mov    0x80113554,%edx
80103a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2f:	01 d0                	add    %edx,%eax
80103a31:	83 c0 01             	add    $0x1,%eax
80103a34:	89 c2                	mov    %eax,%edx
80103a36:	a1 64 35 11 80       	mov    0x80113564,%eax
80103a3b:	83 ec 08             	sub    $0x8,%esp
80103a3e:	52                   	push   %edx
80103a3f:	50                   	push   %eax
80103a40:	e8 71 c7 ff ff       	call   801001b6 <bread>
80103a45:	83 c4 10             	add    $0x10,%esp
80103a48:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4e:	83 c0 10             	add    $0x10,%eax
80103a51:	8b 04 85 2c 35 11 80 	mov    -0x7feecad4(,%eax,4),%eax
80103a58:	89 c2                	mov    %eax,%edx
80103a5a:	a1 64 35 11 80       	mov    0x80113564,%eax
80103a5f:	83 ec 08             	sub    $0x8,%esp
80103a62:	52                   	push   %edx
80103a63:	50                   	push   %eax
80103a64:	e8 4d c7 ff ff       	call   801001b6 <bread>
80103a69:	83 c4 10             	add    $0x10,%esp
80103a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a72:	8d 50 18             	lea    0x18(%eax),%edx
80103a75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a78:	83 c0 18             	add    $0x18,%eax
80103a7b:	83 ec 04             	sub    $0x4,%esp
80103a7e:	68 00 02 00 00       	push   $0x200
80103a83:	52                   	push   %edx
80103a84:	50                   	push   %eax
80103a85:	e8 4f 1f 00 00       	call   801059d9 <memmove>
80103a8a:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103a8d:	83 ec 0c             	sub    $0xc,%esp
80103a90:	ff 75 ec             	pushl  -0x14(%ebp)
80103a93:	e8 57 c7 ff ff       	call   801001ef <bwrite>
80103a98:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103a9b:	83 ec 0c             	sub    $0xc,%esp
80103a9e:	ff 75 f0             	pushl  -0x10(%ebp)
80103aa1:	e8 88 c7 ff ff       	call   8010022e <brelse>
80103aa6:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103aa9:	83 ec 0c             	sub    $0xc,%esp
80103aac:	ff 75 ec             	pushl  -0x14(%ebp)
80103aaf:	e8 7a c7 ff ff       	call   8010022e <brelse>
80103ab4:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103ab7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103abb:	a1 68 35 11 80       	mov    0x80113568,%eax
80103ac0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ac3:	0f 8f 5d ff ff ff    	jg     80103a26 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103ac9:	90                   	nop
80103aca:	c9                   	leave  
80103acb:	c3                   	ret    

80103acc <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103acc:	55                   	push   %ebp
80103acd:	89 e5                	mov    %esp,%ebp
80103acf:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103ad2:	a1 54 35 11 80       	mov    0x80113554,%eax
80103ad7:	89 c2                	mov    %eax,%edx
80103ad9:	a1 64 35 11 80       	mov    0x80113564,%eax
80103ade:	83 ec 08             	sub    $0x8,%esp
80103ae1:	52                   	push   %edx
80103ae2:	50                   	push   %eax
80103ae3:	e8 ce c6 ff ff       	call   801001b6 <bread>
80103ae8:	83 c4 10             	add    $0x10,%esp
80103aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af1:	83 c0 18             	add    $0x18,%eax
80103af4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103afa:	8b 00                	mov    (%eax),%eax
80103afc:	a3 68 35 11 80       	mov    %eax,0x80113568
  for (i = 0; i < log.lh.n; i++) {
80103b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b08:	eb 1b                	jmp    80103b25 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b10:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b17:	83 c2 10             	add    $0x10,%edx
80103b1a:	89 04 95 2c 35 11 80 	mov    %eax,-0x7feecad4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103b21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b25:	a1 68 35 11 80       	mov    0x80113568,%eax
80103b2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b2d:	7f db                	jg     80103b0a <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103b2f:	83 ec 0c             	sub    $0xc,%esp
80103b32:	ff 75 f0             	pushl  -0x10(%ebp)
80103b35:	e8 f4 c6 ff ff       	call   8010022e <brelse>
80103b3a:	83 c4 10             	add    $0x10,%esp
}
80103b3d:	90                   	nop
80103b3e:	c9                   	leave  
80103b3f:	c3                   	ret    

80103b40 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103b46:	a1 54 35 11 80       	mov    0x80113554,%eax
80103b4b:	89 c2                	mov    %eax,%edx
80103b4d:	a1 64 35 11 80       	mov    0x80113564,%eax
80103b52:	83 ec 08             	sub    $0x8,%esp
80103b55:	52                   	push   %edx
80103b56:	50                   	push   %eax
80103b57:	e8 5a c6 ff ff       	call   801001b6 <bread>
80103b5c:	83 c4 10             	add    $0x10,%esp
80103b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b65:	83 c0 18             	add    $0x18,%eax
80103b68:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103b6b:	8b 15 68 35 11 80    	mov    0x80113568,%edx
80103b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b74:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b7d:	eb 1b                	jmp    80103b9a <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b82:	83 c0 10             	add    $0x10,%eax
80103b85:	8b 0c 85 2c 35 11 80 	mov    -0x7feecad4(,%eax,4),%ecx
80103b8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b92:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103b96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b9a:	a1 68 35 11 80       	mov    0x80113568,%eax
80103b9f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ba2:	7f db                	jg     80103b7f <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103ba4:	83 ec 0c             	sub    $0xc,%esp
80103ba7:	ff 75 f0             	pushl  -0x10(%ebp)
80103baa:	e8 40 c6 ff ff       	call   801001ef <bwrite>
80103baf:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103bb2:	83 ec 0c             	sub    $0xc,%esp
80103bb5:	ff 75 f0             	pushl  -0x10(%ebp)
80103bb8:	e8 71 c6 ff ff       	call   8010022e <brelse>
80103bbd:	83 c4 10             	add    $0x10,%esp
}
80103bc0:	90                   	nop
80103bc1:	c9                   	leave  
80103bc2:	c3                   	ret    

80103bc3 <recover_from_log>:

static void
recover_from_log(void)
{
80103bc3:	55                   	push   %ebp
80103bc4:	89 e5                	mov    %esp,%ebp
80103bc6:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103bc9:	e8 fe fe ff ff       	call   80103acc <read_head>
  install_trans(); // if committed, copy from log to disk
80103bce:	e8 41 fe ff ff       	call   80103a14 <install_trans>
  log.lh.n = 0;
80103bd3:	c7 05 68 35 11 80 00 	movl   $0x0,0x80113568
80103bda:	00 00 00 
  write_head(); // clear the log
80103bdd:	e8 5e ff ff ff       	call   80103b40 <write_head>
}
80103be2:	90                   	nop
80103be3:	c9                   	leave  
80103be4:	c3                   	ret    

80103be5 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103be5:	55                   	push   %ebp
80103be6:	89 e5                	mov    %esp,%ebp
80103be8:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103beb:	83 ec 0c             	sub    $0xc,%esp
80103bee:	68 20 35 11 80       	push   $0x80113520
80103bf3:	e8 bf 1a 00 00       	call   801056b7 <acquire>
80103bf8:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103bfb:	a1 60 35 11 80       	mov    0x80113560,%eax
80103c00:	85 c0                	test   %eax,%eax
80103c02:	74 17                	je     80103c1b <begin_op+0x36>
      sleep(&log, &log.lock);
80103c04:	83 ec 08             	sub    $0x8,%esp
80103c07:	68 20 35 11 80       	push   $0x80113520
80103c0c:	68 20 35 11 80       	push   $0x80113520
80103c11:	e8 a8 17 00 00       	call   801053be <sleep>
80103c16:	83 c4 10             	add    $0x10,%esp
80103c19:	eb e0                	jmp    80103bfb <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103c1b:	8b 0d 68 35 11 80    	mov    0x80113568,%ecx
80103c21:	a1 5c 35 11 80       	mov    0x8011355c,%eax
80103c26:	8d 50 01             	lea    0x1(%eax),%edx
80103c29:	89 d0                	mov    %edx,%eax
80103c2b:	c1 e0 02             	shl    $0x2,%eax
80103c2e:	01 d0                	add    %edx,%eax
80103c30:	01 c0                	add    %eax,%eax
80103c32:	01 c8                	add    %ecx,%eax
80103c34:	83 f8 1e             	cmp    $0x1e,%eax
80103c37:	7e 17                	jle    80103c50 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103c39:	83 ec 08             	sub    $0x8,%esp
80103c3c:	68 20 35 11 80       	push   $0x80113520
80103c41:	68 20 35 11 80       	push   $0x80113520
80103c46:	e8 73 17 00 00       	call   801053be <sleep>
80103c4b:	83 c4 10             	add    $0x10,%esp
80103c4e:	eb ab                	jmp    80103bfb <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103c50:	a1 5c 35 11 80       	mov    0x8011355c,%eax
80103c55:	83 c0 01             	add    $0x1,%eax
80103c58:	a3 5c 35 11 80       	mov    %eax,0x8011355c
      release(&log.lock);
80103c5d:	83 ec 0c             	sub    $0xc,%esp
80103c60:	68 20 35 11 80       	push   $0x80113520
80103c65:	e8 b4 1a 00 00       	call   8010571e <release>
80103c6a:	83 c4 10             	add    $0x10,%esp
      break;
80103c6d:	90                   	nop
    }
  }
}
80103c6e:	90                   	nop
80103c6f:	c9                   	leave  
80103c70:	c3                   	ret    

80103c71 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103c71:	55                   	push   %ebp
80103c72:	89 e5                	mov    %esp,%ebp
80103c74:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103c77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103c7e:	83 ec 0c             	sub    $0xc,%esp
80103c81:	68 20 35 11 80       	push   $0x80113520
80103c86:	e8 2c 1a 00 00       	call   801056b7 <acquire>
80103c8b:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103c8e:	a1 5c 35 11 80       	mov    0x8011355c,%eax
80103c93:	83 e8 01             	sub    $0x1,%eax
80103c96:	a3 5c 35 11 80       	mov    %eax,0x8011355c
  if(log.committing)
80103c9b:	a1 60 35 11 80       	mov    0x80113560,%eax
80103ca0:	85 c0                	test   %eax,%eax
80103ca2:	74 0d                	je     80103cb1 <end_op+0x40>
    panic("log.committing");
80103ca4:	83 ec 0c             	sub    $0xc,%esp
80103ca7:	68 28 8f 10 80       	push   $0x80108f28
80103cac:	e8 b5 c8 ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103cb1:	a1 5c 35 11 80       	mov    0x8011355c,%eax
80103cb6:	85 c0                	test   %eax,%eax
80103cb8:	75 13                	jne    80103ccd <end_op+0x5c>
    do_commit = 1;
80103cba:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103cc1:	c7 05 60 35 11 80 01 	movl   $0x1,0x80113560
80103cc8:	00 00 00 
80103ccb:	eb 10                	jmp    80103cdd <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103ccd:	83 ec 0c             	sub    $0xc,%esp
80103cd0:	68 20 35 11 80       	push   $0x80113520
80103cd5:	e8 cf 17 00 00       	call   801054a9 <wakeup>
80103cda:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103cdd:	83 ec 0c             	sub    $0xc,%esp
80103ce0:	68 20 35 11 80       	push   $0x80113520
80103ce5:	e8 34 1a 00 00       	call   8010571e <release>
80103cea:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103ced:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cf1:	74 3f                	je     80103d32 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103cf3:	e8 f5 00 00 00       	call   80103ded <commit>
    acquire(&log.lock);
80103cf8:	83 ec 0c             	sub    $0xc,%esp
80103cfb:	68 20 35 11 80       	push   $0x80113520
80103d00:	e8 b2 19 00 00       	call   801056b7 <acquire>
80103d05:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103d08:	c7 05 60 35 11 80 00 	movl   $0x0,0x80113560
80103d0f:	00 00 00 
    wakeup(&log);
80103d12:	83 ec 0c             	sub    $0xc,%esp
80103d15:	68 20 35 11 80       	push   $0x80113520
80103d1a:	e8 8a 17 00 00       	call   801054a9 <wakeup>
80103d1f:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103d22:	83 ec 0c             	sub    $0xc,%esp
80103d25:	68 20 35 11 80       	push   $0x80113520
80103d2a:	e8 ef 19 00 00       	call   8010571e <release>
80103d2f:	83 c4 10             	add    $0x10,%esp
  }
}
80103d32:	90                   	nop
80103d33:	c9                   	leave  
80103d34:	c3                   	ret    

80103d35 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103d35:	55                   	push   %ebp
80103d36:	89 e5                	mov    %esp,%ebp
80103d38:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103d3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d42:	e9 95 00 00 00       	jmp    80103ddc <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103d47:	8b 15 54 35 11 80    	mov    0x80113554,%edx
80103d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d50:	01 d0                	add    %edx,%eax
80103d52:	83 c0 01             	add    $0x1,%eax
80103d55:	89 c2                	mov    %eax,%edx
80103d57:	a1 64 35 11 80       	mov    0x80113564,%eax
80103d5c:	83 ec 08             	sub    $0x8,%esp
80103d5f:	52                   	push   %edx
80103d60:	50                   	push   %eax
80103d61:	e8 50 c4 ff ff       	call   801001b6 <bread>
80103d66:	83 c4 10             	add    $0x10,%esp
80103d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6f:	83 c0 10             	add    $0x10,%eax
80103d72:	8b 04 85 2c 35 11 80 	mov    -0x7feecad4(,%eax,4),%eax
80103d79:	89 c2                	mov    %eax,%edx
80103d7b:	a1 64 35 11 80       	mov    0x80113564,%eax
80103d80:	83 ec 08             	sub    $0x8,%esp
80103d83:	52                   	push   %edx
80103d84:	50                   	push   %eax
80103d85:	e8 2c c4 ff ff       	call   801001b6 <bread>
80103d8a:	83 c4 10             	add    $0x10,%esp
80103d8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d93:	8d 50 18             	lea    0x18(%eax),%edx
80103d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d99:	83 c0 18             	add    $0x18,%eax
80103d9c:	83 ec 04             	sub    $0x4,%esp
80103d9f:	68 00 02 00 00       	push   $0x200
80103da4:	52                   	push   %edx
80103da5:	50                   	push   %eax
80103da6:	e8 2e 1c 00 00       	call   801059d9 <memmove>
80103dab:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103dae:	83 ec 0c             	sub    $0xc,%esp
80103db1:	ff 75 f0             	pushl  -0x10(%ebp)
80103db4:	e8 36 c4 ff ff       	call   801001ef <bwrite>
80103db9:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103dbc:	83 ec 0c             	sub    $0xc,%esp
80103dbf:	ff 75 ec             	pushl  -0x14(%ebp)
80103dc2:	e8 67 c4 ff ff       	call   8010022e <brelse>
80103dc7:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103dca:	83 ec 0c             	sub    $0xc,%esp
80103dcd:	ff 75 f0             	pushl  -0x10(%ebp)
80103dd0:	e8 59 c4 ff ff       	call   8010022e <brelse>
80103dd5:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103dd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ddc:	a1 68 35 11 80       	mov    0x80113568,%eax
80103de1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103de4:	0f 8f 5d ff ff ff    	jg     80103d47 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103dea:	90                   	nop
80103deb:	c9                   	leave  
80103dec:	c3                   	ret    

80103ded <commit>:

static void
commit()
{
80103ded:	55                   	push   %ebp
80103dee:	89 e5                	mov    %esp,%ebp
80103df0:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103df3:	a1 68 35 11 80       	mov    0x80113568,%eax
80103df8:	85 c0                	test   %eax,%eax
80103dfa:	7e 1e                	jle    80103e1a <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103dfc:	e8 34 ff ff ff       	call   80103d35 <write_log>
    write_head();    // Write header to disk -- the real commit
80103e01:	e8 3a fd ff ff       	call   80103b40 <write_head>
    install_trans(); // Now install writes to home locations
80103e06:	e8 09 fc ff ff       	call   80103a14 <install_trans>
    log.lh.n = 0; 
80103e0b:	c7 05 68 35 11 80 00 	movl   $0x0,0x80113568
80103e12:	00 00 00 
    write_head();    // Erase the transaction from the log
80103e15:	e8 26 fd ff ff       	call   80103b40 <write_head>
  }
}
80103e1a:	90                   	nop
80103e1b:	c9                   	leave  
80103e1c:	c3                   	ret    

80103e1d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103e1d:	55                   	push   %ebp
80103e1e:	89 e5                	mov    %esp,%ebp
80103e20:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103e23:	a1 68 35 11 80       	mov    0x80113568,%eax
80103e28:	83 f8 1d             	cmp    $0x1d,%eax
80103e2b:	7f 12                	jg     80103e3f <log_write+0x22>
80103e2d:	a1 68 35 11 80       	mov    0x80113568,%eax
80103e32:	8b 15 58 35 11 80    	mov    0x80113558,%edx
80103e38:	83 ea 01             	sub    $0x1,%edx
80103e3b:	39 d0                	cmp    %edx,%eax
80103e3d:	7c 0d                	jl     80103e4c <log_write+0x2f>
    panic("too big a transaction");
80103e3f:	83 ec 0c             	sub    $0xc,%esp
80103e42:	68 37 8f 10 80       	push   $0x80108f37
80103e47:	e8 1a c7 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103e4c:	a1 5c 35 11 80       	mov    0x8011355c,%eax
80103e51:	85 c0                	test   %eax,%eax
80103e53:	7f 0d                	jg     80103e62 <log_write+0x45>
    panic("log_write outside of trans");
80103e55:	83 ec 0c             	sub    $0xc,%esp
80103e58:	68 4d 8f 10 80       	push   $0x80108f4d
80103e5d:	e8 04 c7 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103e62:	83 ec 0c             	sub    $0xc,%esp
80103e65:	68 20 35 11 80       	push   $0x80113520
80103e6a:	e8 48 18 00 00       	call   801056b7 <acquire>
80103e6f:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e79:	eb 1d                	jmp    80103e98 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7e:	83 c0 10             	add    $0x10,%eax
80103e81:	8b 04 85 2c 35 11 80 	mov    -0x7feecad4(,%eax,4),%eax
80103e88:	89 c2                	mov    %eax,%edx
80103e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8d:	8b 40 08             	mov    0x8(%eax),%eax
80103e90:	39 c2                	cmp    %eax,%edx
80103e92:	74 10                	je     80103ea4 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103e94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e98:	a1 68 35 11 80       	mov    0x80113568,%eax
80103e9d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ea0:	7f d9                	jg     80103e7b <log_write+0x5e>
80103ea2:	eb 01                	jmp    80103ea5 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103ea4:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea8:	8b 40 08             	mov    0x8(%eax),%eax
80103eab:	89 c2                	mov    %eax,%edx
80103ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb0:	83 c0 10             	add    $0x10,%eax
80103eb3:	89 14 85 2c 35 11 80 	mov    %edx,-0x7feecad4(,%eax,4)
  if (i == log.lh.n)
80103eba:	a1 68 35 11 80       	mov    0x80113568,%eax
80103ebf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ec2:	75 0d                	jne    80103ed1 <log_write+0xb4>
    log.lh.n++;
80103ec4:	a1 68 35 11 80       	mov    0x80113568,%eax
80103ec9:	83 c0 01             	add    $0x1,%eax
80103ecc:	a3 68 35 11 80       	mov    %eax,0x80113568
  b->flags |= B_DIRTY; // prevent eviction
80103ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed4:	8b 00                	mov    (%eax),%eax
80103ed6:	83 c8 04             	or     $0x4,%eax
80103ed9:	89 c2                	mov    %eax,%edx
80103edb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ede:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103ee0:	83 ec 0c             	sub    $0xc,%esp
80103ee3:	68 20 35 11 80       	push   $0x80113520
80103ee8:	e8 31 18 00 00       	call   8010571e <release>
80103eed:	83 c4 10             	add    $0x10,%esp
}
80103ef0:	90                   	nop
80103ef1:	c9                   	leave  
80103ef2:	c3                   	ret    

80103ef3 <v2p>:
80103ef3:	55                   	push   %ebp
80103ef4:	89 e5                	mov    %esp,%ebp
80103ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef9:	05 00 00 00 80       	add    $0x80000000,%eax
80103efe:	5d                   	pop    %ebp
80103eff:	c3                   	ret    

80103f00 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103f00:	55                   	push   %ebp
80103f01:	89 e5                	mov    %esp,%ebp
80103f03:	8b 45 08             	mov    0x8(%ebp),%eax
80103f06:	05 00 00 00 80       	add    $0x80000000,%eax
80103f0b:	5d                   	pop    %ebp
80103f0c:	c3                   	ret    

80103f0d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103f0d:	55                   	push   %ebp
80103f0e:	89 e5                	mov    %esp,%ebp
80103f10:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103f13:	8b 55 08             	mov    0x8(%ebp),%edx
80103f16:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f1c:	f0 87 02             	lock xchg %eax,(%edx)
80103f1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103f25:	c9                   	leave  
80103f26:	c3                   	ret    

80103f27 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103f27:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103f2b:	83 e4 f0             	and    $0xfffffff0,%esp
80103f2e:	ff 71 fc             	pushl  -0x4(%ecx)
80103f31:	55                   	push   %ebp
80103f32:	89 e5                	mov    %esp,%ebp
80103f34:	51                   	push   %ecx
80103f35:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103f38:	83 ec 08             	sub    $0x8,%esp
80103f3b:	68 00 00 40 80       	push   $0x80400000
80103f40:	68 fc 63 11 80       	push   $0x801163fc
80103f45:	e8 6a f2 ff ff       	call   801031b4 <kinit1>
80103f4a:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103f4d:	e8 25 45 00 00       	call   80108477 <kvmalloc>
  mpinit();        // collect info about this machine
80103f52:	e8 26 04 00 00       	call   8010437d <mpinit>
  lapicinit();
80103f57:	e8 d7 f5 ff ff       	call   80103533 <lapicinit>
  seginit();       // set up segments
80103f5c:	e8 bf 3e 00 00       	call   80107e20 <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
80103f61:	e8 6d 06 00 00       	call   801045d3 <picinit>
  ioapicinit();    // another interrupt controller
80103f66:	e8 3e f1 ff ff       	call   801030a9 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103f6b:	e8 a9 cb ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103f70:	e8 07 32 00 00       	call   8010717c <uartinit>
  pinit();         // process table
80103f75:	e8 56 0b 00 00       	call   80104ad0 <pinit>
  tvinit();        // trap vectors
80103f7a:	e8 c7 2d 00 00       	call   80106d46 <tvinit>
  binit();         // buffer cache
80103f7f:	e8 b0 c0 ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80103f84:	e8 ec cf ff ff       	call   80100f75 <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
80103f89:	e8 03 ed ff ff       	call   80102c91 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
80103f8e:	a1 04 36 11 80       	mov    0x80113604,%eax
80103f93:	85 c0                	test   %eax,%eax
80103f95:	75 05                	jne    80103f9c <main+0x75>
    timerinit();   // uniprocessor timer
80103f97:	e8 07 2d 00 00       	call   80106ca3 <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80103f9c:	e8 7f 00 00 00       	call   80104020 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103fa1:	83 ec 08             	sub    $0x8,%esp
80103fa4:	68 00 00 00 8e       	push   $0x8e000000
80103fa9:	68 00 00 40 80       	push   $0x80400000
80103fae:	e8 3a f2 ff ff       	call   801031ed <kinit2>
80103fb3:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
80103fb6:	e8 39 0c 00 00       	call   80104bf4 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
80103fbb:	e8 1a 00 00 00       	call   80103fda <mpmain>

80103fc0 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103fc0:	55                   	push   %ebp
80103fc1:	89 e5                	mov    %esp,%ebp
80103fc3:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103fc6:	e8 c4 44 00 00       	call   8010848f <switchkvm>
  seginit();
80103fcb:	e8 50 3e 00 00       	call   80107e20 <seginit>
  lapicinit();
80103fd0:	e8 5e f5 ff ff       	call   80103533 <lapicinit>
  mpmain();
80103fd5:	e8 00 00 00 00       	call   80103fda <mpmain>

80103fda <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103fda:	55                   	push   %ebp
80103fdb:	89 e5                	mov    %esp,%ebp
80103fdd:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103fe0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103fe6:	0f b6 00             	movzbl (%eax),%eax
80103fe9:	0f b6 c0             	movzbl %al,%eax
80103fec:	83 ec 08             	sub    $0x8,%esp
80103fef:	50                   	push   %eax
80103ff0:	68 68 8f 10 80       	push   $0x80108f68
80103ff5:	e8 cc c3 ff ff       	call   801003c6 <cprintf>
80103ffa:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103ffd:	e8 ba 2e 00 00       	call   80106ebc <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80104002:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104008:	05 a8 00 00 00       	add    $0xa8,%eax
8010400d:	83 ec 08             	sub    $0x8,%esp
80104010:	6a 01                	push   $0x1
80104012:	50                   	push   %eax
80104013:	e8 f5 fe ff ff       	call   80103f0d <xchg>
80104018:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010401b:	e8 7f 11 00 00       	call   8010519f <scheduler>

80104020 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80104020:	55                   	push   %ebp
80104021:	89 e5                	mov    %esp,%ebp
80104023:	53                   	push   %ebx
80104024:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80104027:	68 00 70 00 00       	push   $0x7000
8010402c:	e8 cf fe ff ff       	call   80103f00 <p2v>
80104031:	83 c4 04             	add    $0x4,%esp
80104034:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80104037:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010403c:	83 ec 04             	sub    $0x4,%esp
8010403f:	50                   	push   %eax
80104040:	68 0c c5 10 80       	push   $0x8010c50c
80104045:	ff 75 f0             	pushl  -0x10(%ebp)
80104048:	e8 8c 19 00 00       	call   801059d9 <memmove>
8010404d:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80104050:	c7 45 f4 20 36 11 80 	movl   $0x80113620,-0xc(%ebp)
80104057:	e9 90 00 00 00       	jmp    801040ec <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
8010405c:	e8 f0 f5 ff ff       	call   80103651 <cpunum>
80104061:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104067:	05 20 36 11 80       	add    $0x80113620,%eax
8010406c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010406f:	74 73                	je     801040e4 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104071:	e8 75 f2 ff ff       	call   801032eb <kalloc>
80104076:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010407c:	83 e8 04             	sub    $0x4,%eax
8010407f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104082:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104088:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010408a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010408d:	83 e8 08             	sub    $0x8,%eax
80104090:	c7 00 c0 3f 10 80    	movl   $0x80103fc0,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104099:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010409c:	83 ec 0c             	sub    $0xc,%esp
8010409f:	68 00 b0 10 80       	push   $0x8010b000
801040a4:	e8 4a fe ff ff       	call   80103ef3 <v2p>
801040a9:	83 c4 10             	add    $0x10,%esp
801040ac:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801040ae:	83 ec 0c             	sub    $0xc,%esp
801040b1:	ff 75 f0             	pushl  -0x10(%ebp)
801040b4:	e8 3a fe ff ff       	call   80103ef3 <v2p>
801040b9:	83 c4 10             	add    $0x10,%esp
801040bc:	89 c2                	mov    %eax,%edx
801040be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c1:	0f b6 00             	movzbl (%eax),%eax
801040c4:	0f b6 c0             	movzbl %al,%eax
801040c7:	83 ec 08             	sub    $0x8,%esp
801040ca:	52                   	push   %edx
801040cb:	50                   	push   %eax
801040cc:	e8 fa f5 ff ff       	call   801036cb <lapicstartap>
801040d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801040d4:	90                   	nop
801040d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801040de:	85 c0                	test   %eax,%eax
801040e0:	74 f3                	je     801040d5 <startothers+0xb5>
801040e2:	eb 01                	jmp    801040e5 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801040e4:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801040e5:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801040ec:	a1 00 3c 11 80       	mov    0x80113c00,%eax
801040f1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801040f7:	05 20 36 11 80       	add    $0x80113620,%eax
801040fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801040ff:	0f 87 57 ff ff ff    	ja     8010405c <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80104105:	90                   	nop
80104106:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104109:	c9                   	leave  
8010410a:	c3                   	ret    

8010410b <p2v>:
8010410b:	55                   	push   %ebp
8010410c:	89 e5                	mov    %esp,%ebp
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	05 00 00 00 80       	add    $0x80000000,%eax
80104116:	5d                   	pop    %ebp
80104117:	c3                   	ret    

80104118 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80104118:	55                   	push   %ebp
80104119:	89 e5                	mov    %esp,%ebp
8010411b:	83 ec 14             	sub    $0x14,%esp
8010411e:	8b 45 08             	mov    0x8(%ebp),%eax
80104121:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80104125:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80104129:	89 c2                	mov    %eax,%edx
8010412b:	ec                   	in     (%dx),%al
8010412c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010412f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80104133:	c9                   	leave  
80104134:	c3                   	ret    

80104135 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104135:	55                   	push   %ebp
80104136:	89 e5                	mov    %esp,%ebp
80104138:	83 ec 08             	sub    $0x8,%esp
8010413b:	8b 55 08             	mov    0x8(%ebp),%edx
8010413e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104141:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104145:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104148:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010414c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104150:	ee                   	out    %al,(%dx)
}
80104151:	90                   	nop
80104152:	c9                   	leave  
80104153:	c3                   	ret    

80104154 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80104154:	55                   	push   %ebp
80104155:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104157:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010415c:	89 c2                	mov    %eax,%edx
8010415e:	b8 20 36 11 80       	mov    $0x80113620,%eax
80104163:	29 c2                	sub    %eax,%edx
80104165:	89 d0                	mov    %edx,%eax
80104167:	c1 f8 02             	sar    $0x2,%eax
8010416a:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104170:	5d                   	pop    %ebp
80104171:	c3                   	ret    

80104172 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104172:	55                   	push   %ebp
80104173:	89 e5                	mov    %esp,%ebp
80104175:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104178:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010417f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104186:	eb 15                	jmp    8010419d <sum+0x2b>
    sum += addr[i];
80104188:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010418b:	8b 45 08             	mov    0x8(%ebp),%eax
8010418e:	01 d0                	add    %edx,%eax
80104190:	0f b6 00             	movzbl (%eax),%eax
80104193:	0f b6 c0             	movzbl %al,%eax
80104196:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104199:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010419d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801041a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801041a3:	7c e3                	jl     80104188 <sum+0x16>
    sum += addr[i];
  return sum;
801041a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801041a8:	c9                   	leave  
801041a9:	c3                   	ret    

801041aa <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801041aa:	55                   	push   %ebp
801041ab:	89 e5                	mov    %esp,%ebp
801041ad:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801041b0:	ff 75 08             	pushl  0x8(%ebp)
801041b3:	e8 53 ff ff ff       	call   8010410b <p2v>
801041b8:	83 c4 04             	add    $0x4,%esp
801041bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801041be:	8b 55 0c             	mov    0xc(%ebp),%edx
801041c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041c4:	01 d0                	add    %edx,%eax
801041c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801041c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041cf:	eb 36                	jmp    80104207 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801041d1:	83 ec 04             	sub    $0x4,%esp
801041d4:	6a 04                	push   $0x4
801041d6:	68 7c 8f 10 80       	push   $0x80108f7c
801041db:	ff 75 f4             	pushl  -0xc(%ebp)
801041de:	e8 9e 17 00 00       	call   80105981 <memcmp>
801041e3:	83 c4 10             	add    $0x10,%esp
801041e6:	85 c0                	test   %eax,%eax
801041e8:	75 19                	jne    80104203 <mpsearch1+0x59>
801041ea:	83 ec 08             	sub    $0x8,%esp
801041ed:	6a 10                	push   $0x10
801041ef:	ff 75 f4             	pushl  -0xc(%ebp)
801041f2:	e8 7b ff ff ff       	call   80104172 <sum>
801041f7:	83 c4 10             	add    $0x10,%esp
801041fa:	84 c0                	test   %al,%al
801041fc:	75 05                	jne    80104203 <mpsearch1+0x59>
      return (struct mp*)p;
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	eb 11                	jmp    80104214 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80104203:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80104207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010420d:	72 c2                	jb     801041d1 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
8010420f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104214:	c9                   	leave  
80104215:	c3                   	ret    

80104216 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80104216:	55                   	push   %ebp
80104217:	89 e5                	mov    %esp,%ebp
80104219:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
8010421c:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80104223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104226:	83 c0 0f             	add    $0xf,%eax
80104229:	0f b6 00             	movzbl (%eax),%eax
8010422c:	0f b6 c0             	movzbl %al,%eax
8010422f:	c1 e0 08             	shl    $0x8,%eax
80104232:	89 c2                	mov    %eax,%edx
80104234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104237:	83 c0 0e             	add    $0xe,%eax
8010423a:	0f b6 00             	movzbl (%eax),%eax
8010423d:	0f b6 c0             	movzbl %al,%eax
80104240:	09 d0                	or     %edx,%eax
80104242:	c1 e0 04             	shl    $0x4,%eax
80104245:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104248:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010424c:	74 21                	je     8010426f <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010424e:	83 ec 08             	sub    $0x8,%esp
80104251:	68 00 04 00 00       	push   $0x400
80104256:	ff 75 f0             	pushl  -0x10(%ebp)
80104259:	e8 4c ff ff ff       	call   801041aa <mpsearch1>
8010425e:	83 c4 10             	add    $0x10,%esp
80104261:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104264:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104268:	74 51                	je     801042bb <mpsearch+0xa5>
      return mp;
8010426a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010426d:	eb 61                	jmp    801042d0 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010426f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104272:	83 c0 14             	add    $0x14,%eax
80104275:	0f b6 00             	movzbl (%eax),%eax
80104278:	0f b6 c0             	movzbl %al,%eax
8010427b:	c1 e0 08             	shl    $0x8,%eax
8010427e:	89 c2                	mov    %eax,%edx
80104280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104283:	83 c0 13             	add    $0x13,%eax
80104286:	0f b6 00             	movzbl (%eax),%eax
80104289:	0f b6 c0             	movzbl %al,%eax
8010428c:	09 d0                	or     %edx,%eax
8010428e:	c1 e0 0a             	shl    $0xa,%eax
80104291:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104294:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104297:	2d 00 04 00 00       	sub    $0x400,%eax
8010429c:	83 ec 08             	sub    $0x8,%esp
8010429f:	68 00 04 00 00       	push   $0x400
801042a4:	50                   	push   %eax
801042a5:	e8 00 ff ff ff       	call   801041aa <mpsearch1>
801042aa:	83 c4 10             	add    $0x10,%esp
801042ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
801042b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042b4:	74 05                	je     801042bb <mpsearch+0xa5>
      return mp;
801042b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042b9:	eb 15                	jmp    801042d0 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
801042bb:	83 ec 08             	sub    $0x8,%esp
801042be:	68 00 00 01 00       	push   $0x10000
801042c3:	68 00 00 0f 00       	push   $0xf0000
801042c8:	e8 dd fe ff ff       	call   801041aa <mpsearch1>
801042cd:	83 c4 10             	add    $0x10,%esp
}
801042d0:	c9                   	leave  
801042d1:	c3                   	ret    

801042d2 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801042d2:	55                   	push   %ebp
801042d3:	89 e5                	mov    %esp,%ebp
801042d5:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801042d8:	e8 39 ff ff ff       	call   80104216 <mpsearch>
801042dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042e4:	74 0a                	je     801042f0 <mpconfig+0x1e>
801042e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e9:	8b 40 04             	mov    0x4(%eax),%eax
801042ec:	85 c0                	test   %eax,%eax
801042ee:	75 0a                	jne    801042fa <mpconfig+0x28>
    return 0;
801042f0:	b8 00 00 00 00       	mov    $0x0,%eax
801042f5:	e9 81 00 00 00       	jmp    8010437b <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801042fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fd:	8b 40 04             	mov    0x4(%eax),%eax
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	50                   	push   %eax
80104304:	e8 02 fe ff ff       	call   8010410b <p2v>
80104309:	83 c4 10             	add    $0x10,%esp
8010430c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010430f:	83 ec 04             	sub    $0x4,%esp
80104312:	6a 04                	push   $0x4
80104314:	68 81 8f 10 80       	push   $0x80108f81
80104319:	ff 75 f0             	pushl  -0x10(%ebp)
8010431c:	e8 60 16 00 00       	call   80105981 <memcmp>
80104321:	83 c4 10             	add    $0x10,%esp
80104324:	85 c0                	test   %eax,%eax
80104326:	74 07                	je     8010432f <mpconfig+0x5d>
    return 0;
80104328:	b8 00 00 00 00       	mov    $0x0,%eax
8010432d:	eb 4c                	jmp    8010437b <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
8010432f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104332:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104336:	3c 01                	cmp    $0x1,%al
80104338:	74 12                	je     8010434c <mpconfig+0x7a>
8010433a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010433d:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104341:	3c 04                	cmp    $0x4,%al
80104343:	74 07                	je     8010434c <mpconfig+0x7a>
    return 0;
80104345:	b8 00 00 00 00       	mov    $0x0,%eax
8010434a:	eb 2f                	jmp    8010437b <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
8010434c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010434f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104353:	0f b7 c0             	movzwl %ax,%eax
80104356:	83 ec 08             	sub    $0x8,%esp
80104359:	50                   	push   %eax
8010435a:	ff 75 f0             	pushl  -0x10(%ebp)
8010435d:	e8 10 fe ff ff       	call   80104172 <sum>
80104362:	83 c4 10             	add    $0x10,%esp
80104365:	84 c0                	test   %al,%al
80104367:	74 07                	je     80104370 <mpconfig+0x9e>
    return 0;
80104369:	b8 00 00 00 00       	mov    $0x0,%eax
8010436e:	eb 0b                	jmp    8010437b <mpconfig+0xa9>
  *pmp = mp;
80104370:	8b 45 08             	mov    0x8(%ebp),%eax
80104373:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104376:	89 10                	mov    %edx,(%eax)
  return conf;
80104378:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010437b:	c9                   	leave  
8010437c:	c3                   	ret    

8010437d <mpinit>:

void
mpinit(void)
{
8010437d:	55                   	push   %ebp
8010437e:	89 e5                	mov    %esp,%ebp
80104380:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104383:	c7 05 44 c6 10 80 20 	movl   $0x80113620,0x8010c644
8010438a:	36 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010438d:	83 ec 0c             	sub    $0xc,%esp
80104390:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104393:	50                   	push   %eax
80104394:	e8 39 ff ff ff       	call   801042d2 <mpconfig>
80104399:	83 c4 10             	add    $0x10,%esp
8010439c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010439f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801043a3:	0f 84 96 01 00 00    	je     8010453f <mpinit+0x1c2>
    return;
  ismp = 1;
801043a9:	c7 05 04 36 11 80 01 	movl   $0x1,0x80113604
801043b0:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801043b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043b6:	8b 40 24             	mov    0x24(%eax),%eax
801043b9:	a3 1c 35 11 80       	mov    %eax,0x8011351c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801043be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c1:	83 c0 2c             	add    $0x2c,%eax
801043c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043ca:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801043ce:	0f b7 d0             	movzwl %ax,%edx
801043d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d4:	01 d0                	add    %edx,%eax
801043d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801043d9:	e9 f2 00 00 00       	jmp    801044d0 <mpinit+0x153>
    switch(*p){
801043de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e1:	0f b6 00             	movzbl (%eax),%eax
801043e4:	0f b6 c0             	movzbl %al,%eax
801043e7:	83 f8 04             	cmp    $0x4,%eax
801043ea:	0f 87 bc 00 00 00    	ja     801044ac <mpinit+0x12f>
801043f0:	8b 04 85 c4 8f 10 80 	mov    -0x7fef703c(,%eax,4),%eax
801043f7:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801043ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104402:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104406:	0f b6 d0             	movzbl %al,%edx
80104409:	a1 00 3c 11 80       	mov    0x80113c00,%eax
8010440e:	39 c2                	cmp    %eax,%edx
80104410:	74 2b                	je     8010443d <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104412:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104415:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104419:	0f b6 d0             	movzbl %al,%edx
8010441c:	a1 00 3c 11 80       	mov    0x80113c00,%eax
80104421:	83 ec 04             	sub    $0x4,%esp
80104424:	52                   	push   %edx
80104425:	50                   	push   %eax
80104426:	68 86 8f 10 80       	push   $0x80108f86
8010442b:	e8 96 bf ff ff       	call   801003c6 <cprintf>
80104430:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80104433:	c7 05 04 36 11 80 00 	movl   $0x0,0x80113604
8010443a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010443d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104440:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104444:	0f b6 c0             	movzbl %al,%eax
80104447:	83 e0 02             	and    $0x2,%eax
8010444a:	85 c0                	test   %eax,%eax
8010444c:	74 15                	je     80104463 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
8010444e:	a1 00 3c 11 80       	mov    0x80113c00,%eax
80104453:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104459:	05 20 36 11 80       	add    $0x80113620,%eax
8010445e:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104463:	a1 00 3c 11 80       	mov    0x80113c00,%eax
80104468:	8b 15 00 3c 11 80    	mov    0x80113c00,%edx
8010446e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104474:	05 20 36 11 80       	add    $0x80113620,%eax
80104479:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010447b:	a1 00 3c 11 80       	mov    0x80113c00,%eax
80104480:	83 c0 01             	add    $0x1,%eax
80104483:	a3 00 3c 11 80       	mov    %eax,0x80113c00
      p += sizeof(struct mpproc);
80104488:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010448c:	eb 42                	jmp    801044d0 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010448e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104491:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104497:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010449b:	a2 00 36 11 80       	mov    %al,0x80113600
      p += sizeof(struct mpioapic);
801044a0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801044a4:	eb 2a                	jmp    801044d0 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801044a6:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801044aa:	eb 24                	jmp    801044d0 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044af:	0f b6 00             	movzbl (%eax),%eax
801044b2:	0f b6 c0             	movzbl %al,%eax
801044b5:	83 ec 08             	sub    $0x8,%esp
801044b8:	50                   	push   %eax
801044b9:	68 a4 8f 10 80       	push   $0x80108fa4
801044be:	e8 03 bf ff ff       	call   801003c6 <cprintf>
801044c3:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
801044c6:	c7 05 04 36 11 80 00 	movl   $0x0,0x80113604
801044cd:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801044d6:	0f 82 02 ff ff ff    	jb     801043de <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801044dc:	a1 04 36 11 80       	mov    0x80113604,%eax
801044e1:	85 c0                	test   %eax,%eax
801044e3:	75 1d                	jne    80104502 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801044e5:	c7 05 00 3c 11 80 01 	movl   $0x1,0x80113c00
801044ec:	00 00 00 
    lapic = 0;
801044ef:	c7 05 1c 35 11 80 00 	movl   $0x0,0x8011351c
801044f6:	00 00 00 
    ioapicid = 0;
801044f9:	c6 05 00 36 11 80 00 	movb   $0x0,0x80113600
    return;
80104500:	eb 3e                	jmp    80104540 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80104502:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104505:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104509:	84 c0                	test   %al,%al
8010450b:	74 33                	je     80104540 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010450d:	83 ec 08             	sub    $0x8,%esp
80104510:	6a 70                	push   $0x70
80104512:	6a 22                	push   $0x22
80104514:	e8 1c fc ff ff       	call   80104135 <outb>
80104519:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010451c:	83 ec 0c             	sub    $0xc,%esp
8010451f:	6a 23                	push   $0x23
80104521:	e8 f2 fb ff ff       	call   80104118 <inb>
80104526:	83 c4 10             	add    $0x10,%esp
80104529:	83 c8 01             	or     $0x1,%eax
8010452c:	0f b6 c0             	movzbl %al,%eax
8010452f:	83 ec 08             	sub    $0x8,%esp
80104532:	50                   	push   %eax
80104533:	6a 23                	push   $0x23
80104535:	e8 fb fb ff ff       	call   80104135 <outb>
8010453a:	83 c4 10             	add    $0x10,%esp
8010453d:	eb 01                	jmp    80104540 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
8010453f:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104540:	c9                   	leave  
80104541:	c3                   	ret    

80104542 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104542:	55                   	push   %ebp
80104543:	89 e5                	mov    %esp,%ebp
80104545:	83 ec 08             	sub    $0x8,%esp
80104548:	8b 55 08             	mov    0x8(%ebp),%edx
8010454b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010454e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104552:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104555:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104559:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010455d:	ee                   	out    %al,(%dx)
}
8010455e:	90                   	nop
8010455f:	c9                   	leave  
80104560:	c3                   	ret    

80104561 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104561:	55                   	push   %ebp
80104562:	89 e5                	mov    %esp,%ebp
80104564:	83 ec 04             	sub    $0x4,%esp
80104567:	8b 45 08             	mov    0x8(%ebp),%eax
8010456a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
8010456e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104572:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104578:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010457c:	0f b6 c0             	movzbl %al,%eax
8010457f:	50                   	push   %eax
80104580:	6a 21                	push   $0x21
80104582:	e8 bb ff ff ff       	call   80104542 <outb>
80104587:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010458a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010458e:	66 c1 e8 08          	shr    $0x8,%ax
80104592:	0f b6 c0             	movzbl %al,%eax
80104595:	50                   	push   %eax
80104596:	68 a1 00 00 00       	push   $0xa1
8010459b:	e8 a2 ff ff ff       	call   80104542 <outb>
801045a0:	83 c4 08             	add    $0x8,%esp
}
801045a3:	90                   	nop
801045a4:	c9                   	leave  
801045a5:	c3                   	ret    

801045a6 <picenable>:

void
picenable(int irq)
{
801045a6:	55                   	push   %ebp
801045a7:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
801045a9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ac:	ba 01 00 00 00       	mov    $0x1,%edx
801045b1:	89 c1                	mov    %eax,%ecx
801045b3:	d3 e2                	shl    %cl,%edx
801045b5:	89 d0                	mov    %edx,%eax
801045b7:	f7 d0                	not    %eax
801045b9:	89 c2                	mov    %eax,%edx
801045bb:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801045c2:	21 d0                	and    %edx,%eax
801045c4:	0f b7 c0             	movzwl %ax,%eax
801045c7:	50                   	push   %eax
801045c8:	e8 94 ff ff ff       	call   80104561 <picsetmask>
801045cd:	83 c4 04             	add    $0x4,%esp
}
801045d0:	90                   	nop
801045d1:	c9                   	leave  
801045d2:	c3                   	ret    

801045d3 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801045d3:	55                   	push   %ebp
801045d4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801045d6:	68 ff 00 00 00       	push   $0xff
801045db:	6a 21                	push   $0x21
801045dd:	e8 60 ff ff ff       	call   80104542 <outb>
801045e2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801045e5:	68 ff 00 00 00       	push   $0xff
801045ea:	68 a1 00 00 00       	push   $0xa1
801045ef:	e8 4e ff ff ff       	call   80104542 <outb>
801045f4:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801045f7:	6a 11                	push   $0x11
801045f9:	6a 20                	push   $0x20
801045fb:	e8 42 ff ff ff       	call   80104542 <outb>
80104600:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104603:	6a 20                	push   $0x20
80104605:	6a 21                	push   $0x21
80104607:	e8 36 ff ff ff       	call   80104542 <outb>
8010460c:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
8010460f:	6a 04                	push   $0x4
80104611:	6a 21                	push   $0x21
80104613:	e8 2a ff ff ff       	call   80104542 <outb>
80104618:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010461b:	6a 03                	push   $0x3
8010461d:	6a 21                	push   $0x21
8010461f:	e8 1e ff ff ff       	call   80104542 <outb>
80104624:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104627:	6a 11                	push   $0x11
80104629:	68 a0 00 00 00       	push   $0xa0
8010462e:	e8 0f ff ff ff       	call   80104542 <outb>
80104633:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104636:	6a 28                	push   $0x28
80104638:	68 a1 00 00 00       	push   $0xa1
8010463d:	e8 00 ff ff ff       	call   80104542 <outb>
80104642:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104645:	6a 02                	push   $0x2
80104647:	68 a1 00 00 00       	push   $0xa1
8010464c:	e8 f1 fe ff ff       	call   80104542 <outb>
80104651:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104654:	6a 03                	push   $0x3
80104656:	68 a1 00 00 00       	push   $0xa1
8010465b:	e8 e2 fe ff ff       	call   80104542 <outb>
80104660:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104663:	6a 68                	push   $0x68
80104665:	6a 20                	push   $0x20
80104667:	e8 d6 fe ff ff       	call   80104542 <outb>
8010466c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
8010466f:	6a 0a                	push   $0xa
80104671:	6a 20                	push   $0x20
80104673:	e8 ca fe ff ff       	call   80104542 <outb>
80104678:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010467b:	6a 68                	push   $0x68
8010467d:	68 a0 00 00 00       	push   $0xa0
80104682:	e8 bb fe ff ff       	call   80104542 <outb>
80104687:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010468a:	6a 0a                	push   $0xa
8010468c:	68 a0 00 00 00       	push   $0xa0
80104691:	e8 ac fe ff ff       	call   80104542 <outb>
80104696:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104699:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801046a0:	66 83 f8 ff          	cmp    $0xffff,%ax
801046a4:	74 13                	je     801046b9 <picinit+0xe6>
    picsetmask(irqmask);
801046a6:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801046ad:	0f b7 c0             	movzwl %ax,%eax
801046b0:	50                   	push   %eax
801046b1:	e8 ab fe ff ff       	call   80104561 <picsetmask>
801046b6:	83 c4 04             	add    $0x4,%esp
}
801046b9:	90                   	nop
801046ba:	c9                   	leave  
801046bb:	c3                   	ret    

801046bc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801046c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801046c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801046cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801046d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801046d5:	8b 10                	mov    (%eax),%edx
801046d7:	8b 45 08             	mov    0x8(%ebp),%eax
801046da:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801046dc:	e8 b2 c8 ff ff       	call   80100f93 <filealloc>
801046e1:	89 c2                	mov    %eax,%edx
801046e3:	8b 45 08             	mov    0x8(%ebp),%eax
801046e6:	89 10                	mov    %edx,(%eax)
801046e8:	8b 45 08             	mov    0x8(%ebp),%eax
801046eb:	8b 00                	mov    (%eax),%eax
801046ed:	85 c0                	test   %eax,%eax
801046ef:	0f 84 cb 00 00 00    	je     801047c0 <pipealloc+0x104>
801046f5:	e8 99 c8 ff ff       	call   80100f93 <filealloc>
801046fa:	89 c2                	mov    %eax,%edx
801046fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801046ff:	89 10                	mov    %edx,(%eax)
80104701:	8b 45 0c             	mov    0xc(%ebp),%eax
80104704:	8b 00                	mov    (%eax),%eax
80104706:	85 c0                	test   %eax,%eax
80104708:	0f 84 b2 00 00 00    	je     801047c0 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010470e:	e8 d8 eb ff ff       	call   801032eb <kalloc>
80104713:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104716:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010471a:	0f 84 9f 00 00 00    	je     801047bf <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104723:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010472a:	00 00 00 
  p->writeopen = 1;
8010472d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104730:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104737:	00 00 00 
  p->nwrite = 0;
8010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104744:	00 00 00 
  p->nread = 0;
80104747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104751:	00 00 00 
  initlock(&p->lock, "pipe");
80104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104757:	83 ec 08             	sub    $0x8,%esp
8010475a:	68 d8 8f 10 80       	push   $0x80108fd8
8010475f:	50                   	push   %eax
80104760:	e8 30 0f 00 00       	call   80105695 <initlock>
80104765:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104768:	8b 45 08             	mov    0x8(%ebp),%eax
8010476b:	8b 00                	mov    (%eax),%eax
8010476d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104773:	8b 45 08             	mov    0x8(%ebp),%eax
80104776:	8b 00                	mov    (%eax),%eax
80104778:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010477c:	8b 45 08             	mov    0x8(%ebp),%eax
8010477f:	8b 00                	mov    (%eax),%eax
80104781:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104785:	8b 45 08             	mov    0x8(%ebp),%eax
80104788:	8b 00                	mov    (%eax),%eax
8010478a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010478d:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104790:	8b 45 0c             	mov    0xc(%ebp),%eax
80104793:	8b 00                	mov    (%eax),%eax
80104795:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010479b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010479e:	8b 00                	mov    (%eax),%eax
801047a0:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801047a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801047a7:	8b 00                	mov    (%eax),%eax
801047a9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801047ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801047b0:	8b 00                	mov    (%eax),%eax
801047b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047b5:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
801047b8:	b8 00 00 00 00       	mov    $0x0,%eax
801047bd:	eb 4e                	jmp    8010480d <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801047bf:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801047c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047c4:	74 0e                	je     801047d4 <pipealloc+0x118>
    kfree((char*)p);
801047c6:	83 ec 0c             	sub    $0xc,%esp
801047c9:	ff 75 f4             	pushl  -0xc(%ebp)
801047cc:	e8 7d ea ff ff       	call   8010324e <kfree>
801047d1:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801047d4:	8b 45 08             	mov    0x8(%ebp),%eax
801047d7:	8b 00                	mov    (%eax),%eax
801047d9:	85 c0                	test   %eax,%eax
801047db:	74 11                	je     801047ee <pipealloc+0x132>
    fileclose(*f0);
801047dd:	8b 45 08             	mov    0x8(%ebp),%eax
801047e0:	8b 00                	mov    (%eax),%eax
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	50                   	push   %eax
801047e6:	e8 66 c8 ff ff       	call   80101051 <fileclose>
801047eb:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801047ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801047f1:	8b 00                	mov    (%eax),%eax
801047f3:	85 c0                	test   %eax,%eax
801047f5:	74 11                	je     80104808 <pipealloc+0x14c>
    fileclose(*f1);
801047f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801047fa:	8b 00                	mov    (%eax),%eax
801047fc:	83 ec 0c             	sub    $0xc,%esp
801047ff:	50                   	push   %eax
80104800:	e8 4c c8 ff ff       	call   80101051 <fileclose>
80104805:	83 c4 10             	add    $0x10,%esp
  return -1;
80104808:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010480d:	c9                   	leave  
8010480e:	c3                   	ret    

8010480f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010480f:	55                   	push   %ebp
80104810:	89 e5                	mov    %esp,%ebp
80104812:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104815:	8b 45 08             	mov    0x8(%ebp),%eax
80104818:	83 ec 0c             	sub    $0xc,%esp
8010481b:	50                   	push   %eax
8010481c:	e8 96 0e 00 00       	call   801056b7 <acquire>
80104821:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104824:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104828:	74 23                	je     8010484d <pipeclose+0x3e>
    p->writeopen = 0;
8010482a:	8b 45 08             	mov    0x8(%ebp),%eax
8010482d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104834:	00 00 00 
    wakeup(&p->nread);
80104837:	8b 45 08             	mov    0x8(%ebp),%eax
8010483a:	05 34 02 00 00       	add    $0x234,%eax
8010483f:	83 ec 0c             	sub    $0xc,%esp
80104842:	50                   	push   %eax
80104843:	e8 61 0c 00 00       	call   801054a9 <wakeup>
80104848:	83 c4 10             	add    $0x10,%esp
8010484b:	eb 21                	jmp    8010486e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010484d:	8b 45 08             	mov    0x8(%ebp),%eax
80104850:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104857:	00 00 00 
    wakeup(&p->nwrite);
8010485a:	8b 45 08             	mov    0x8(%ebp),%eax
8010485d:	05 38 02 00 00       	add    $0x238,%eax
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	50                   	push   %eax
80104866:	e8 3e 0c 00 00       	call   801054a9 <wakeup>
8010486b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010486e:	8b 45 08             	mov    0x8(%ebp),%eax
80104871:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104877:	85 c0                	test   %eax,%eax
80104879:	75 2c                	jne    801048a7 <pipeclose+0x98>
8010487b:	8b 45 08             	mov    0x8(%ebp),%eax
8010487e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104884:	85 c0                	test   %eax,%eax
80104886:	75 1f                	jne    801048a7 <pipeclose+0x98>
    release(&p->lock);
80104888:	8b 45 08             	mov    0x8(%ebp),%eax
8010488b:	83 ec 0c             	sub    $0xc,%esp
8010488e:	50                   	push   %eax
8010488f:	e8 8a 0e 00 00       	call   8010571e <release>
80104894:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104897:	83 ec 0c             	sub    $0xc,%esp
8010489a:	ff 75 08             	pushl  0x8(%ebp)
8010489d:	e8 ac e9 ff ff       	call   8010324e <kfree>
801048a2:	83 c4 10             	add    $0x10,%esp
801048a5:	eb 0f                	jmp    801048b6 <pipeclose+0xa7>
  } else
    release(&p->lock);
801048a7:	8b 45 08             	mov    0x8(%ebp),%eax
801048aa:	83 ec 0c             	sub    $0xc,%esp
801048ad:	50                   	push   %eax
801048ae:	e8 6b 0e 00 00       	call   8010571e <release>
801048b3:	83 c4 10             	add    $0x10,%esp
}
801048b6:	90                   	nop
801048b7:	c9                   	leave  
801048b8:	c3                   	ret    

801048b9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801048b9:	55                   	push   %ebp
801048ba:	89 e5                	mov    %esp,%ebp
801048bc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801048bf:	8b 45 08             	mov    0x8(%ebp),%eax
801048c2:	83 ec 0c             	sub    $0xc,%esp
801048c5:	50                   	push   %eax
801048c6:	e8 ec 0d 00 00       	call   801056b7 <acquire>
801048cb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801048ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048d5:	e9 ad 00 00 00       	jmp    80104987 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801048da:	8b 45 08             	mov    0x8(%ebp),%eax
801048dd:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801048e3:	85 c0                	test   %eax,%eax
801048e5:	74 0d                	je     801048f4 <pipewrite+0x3b>
801048e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ed:	8b 40 24             	mov    0x24(%eax),%eax
801048f0:	85 c0                	test   %eax,%eax
801048f2:	74 19                	je     8010490d <pipewrite+0x54>
        release(&p->lock);
801048f4:	8b 45 08             	mov    0x8(%ebp),%eax
801048f7:	83 ec 0c             	sub    $0xc,%esp
801048fa:	50                   	push   %eax
801048fb:	e8 1e 0e 00 00       	call   8010571e <release>
80104900:	83 c4 10             	add    $0x10,%esp
        return -1;
80104903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104908:	e9 a8 00 00 00       	jmp    801049b5 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010490d:	8b 45 08             	mov    0x8(%ebp),%eax
80104910:	05 34 02 00 00       	add    $0x234,%eax
80104915:	83 ec 0c             	sub    $0xc,%esp
80104918:	50                   	push   %eax
80104919:	e8 8b 0b 00 00       	call   801054a9 <wakeup>
8010491e:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104921:	8b 45 08             	mov    0x8(%ebp),%eax
80104924:	8b 55 08             	mov    0x8(%ebp),%edx
80104927:	81 c2 38 02 00 00    	add    $0x238,%edx
8010492d:	83 ec 08             	sub    $0x8,%esp
80104930:	50                   	push   %eax
80104931:	52                   	push   %edx
80104932:	e8 87 0a 00 00       	call   801053be <sleep>
80104937:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010493a:	8b 45 08             	mov    0x8(%ebp),%eax
8010493d:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104943:	8b 45 08             	mov    0x8(%ebp),%eax
80104946:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010494c:	05 00 02 00 00       	add    $0x200,%eax
80104951:	39 c2                	cmp    %eax,%edx
80104953:	74 85                	je     801048da <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104955:	8b 45 08             	mov    0x8(%ebp),%eax
80104958:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010495e:	8d 48 01             	lea    0x1(%eax),%ecx
80104961:	8b 55 08             	mov    0x8(%ebp),%edx
80104964:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010496a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010496f:	89 c1                	mov    %eax,%ecx
80104971:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104974:	8b 45 0c             	mov    0xc(%ebp),%eax
80104977:	01 d0                	add    %edx,%eax
80104979:	0f b6 10             	movzbl (%eax),%edx
8010497c:	8b 45 08             	mov    0x8(%ebp),%eax
8010497f:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104983:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010498d:	7c ab                	jl     8010493a <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010498f:	8b 45 08             	mov    0x8(%ebp),%eax
80104992:	05 34 02 00 00       	add    $0x234,%eax
80104997:	83 ec 0c             	sub    $0xc,%esp
8010499a:	50                   	push   %eax
8010499b:	e8 09 0b 00 00       	call   801054a9 <wakeup>
801049a0:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
801049a6:	83 ec 0c             	sub    $0xc,%esp
801049a9:	50                   	push   %eax
801049aa:	e8 6f 0d 00 00       	call   8010571e <release>
801049af:	83 c4 10             	add    $0x10,%esp
  return n;
801049b2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801049b5:	c9                   	leave  
801049b6:	c3                   	ret    

801049b7 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801049b7:	55                   	push   %ebp
801049b8:	89 e5                	mov    %esp,%ebp
801049ba:	53                   	push   %ebx
801049bb:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801049be:	8b 45 08             	mov    0x8(%ebp),%eax
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	50                   	push   %eax
801049c5:	e8 ed 0c 00 00       	call   801056b7 <acquire>
801049ca:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801049cd:	eb 3f                	jmp    80104a0e <piperead+0x57>
    if(proc->killed){
801049cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d5:	8b 40 24             	mov    0x24(%eax),%eax
801049d8:	85 c0                	test   %eax,%eax
801049da:	74 19                	je     801049f5 <piperead+0x3e>
      release(&p->lock);
801049dc:	8b 45 08             	mov    0x8(%ebp),%eax
801049df:	83 ec 0c             	sub    $0xc,%esp
801049e2:	50                   	push   %eax
801049e3:	e8 36 0d 00 00       	call   8010571e <release>
801049e8:	83 c4 10             	add    $0x10,%esp
      return -1;
801049eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049f0:	e9 bf 00 00 00       	jmp    80104ab4 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	8b 55 08             	mov    0x8(%ebp),%edx
801049fb:	81 c2 34 02 00 00    	add    $0x234,%edx
80104a01:	83 ec 08             	sub    $0x8,%esp
80104a04:	50                   	push   %eax
80104a05:	52                   	push   %edx
80104a06:	e8 b3 09 00 00       	call   801053be <sleep>
80104a0b:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a11:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104a17:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104a20:	39 c2                	cmp    %eax,%edx
80104a22:	75 0d                	jne    80104a31 <piperead+0x7a>
80104a24:	8b 45 08             	mov    0x8(%ebp),%eax
80104a27:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104a2d:	85 c0                	test   %eax,%eax
80104a2f:	75 9e                	jne    801049cf <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104a31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a38:	eb 49                	jmp    80104a83 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104a43:	8b 45 08             	mov    0x8(%ebp),%eax
80104a46:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104a4c:	39 c2                	cmp    %eax,%edx
80104a4e:	74 3d                	je     80104a8d <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104a50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a53:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a56:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104a59:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104a62:	8d 48 01             	lea    0x1(%eax),%ecx
80104a65:	8b 55 08             	mov    0x8(%ebp),%edx
80104a68:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104a6e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104a73:	89 c2                	mov    %eax,%edx
80104a75:	8b 45 08             	mov    0x8(%ebp),%eax
80104a78:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104a7d:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104a7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a86:	3b 45 10             	cmp    0x10(%ebp),%eax
80104a89:	7c af                	jl     80104a3a <piperead+0x83>
80104a8b:	eb 01                	jmp    80104a8e <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104a8d:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a91:	05 38 02 00 00       	add    $0x238,%eax
80104a96:	83 ec 0c             	sub    $0xc,%esp
80104a99:	50                   	push   %eax
80104a9a:	e8 0a 0a 00 00       	call   801054a9 <wakeup>
80104a9f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa5:	83 ec 0c             	sub    $0xc,%esp
80104aa8:	50                   	push   %eax
80104aa9:	e8 70 0c 00 00       	call   8010571e <release>
80104aae:	83 c4 10             	add    $0x10,%esp
  return i;
80104ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ab7:	c9                   	leave  
80104ab8:	c3                   	ret    

80104ab9 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ab9:	55                   	push   %ebp
80104aba:	89 e5                	mov    %esp,%ebp
80104abc:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104abf:	9c                   	pushf  
80104ac0:	58                   	pop    %eax
80104ac1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ac4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ac7:	c9                   	leave  
80104ac8:	c3                   	ret    

80104ac9 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104ac9:	55                   	push   %ebp
80104aca:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104acc:	fb                   	sti    
}
80104acd:	90                   	nop
80104ace:	5d                   	pop    %ebp
80104acf:	c3                   	ret    

80104ad0 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104ad6:	83 ec 08             	sub    $0x8,%esp
80104ad9:	68 dd 8f 10 80       	push   $0x80108fdd
80104ade:	68 20 3c 11 80       	push   $0x80113c20
80104ae3:	e8 ad 0b 00 00       	call   80105695 <initlock>
80104ae8:	83 c4 10             	add    $0x10,%esp
}
80104aeb:	90                   	nop
80104aec:	c9                   	leave  
80104aed:	c3                   	ret    

80104aee <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104aee:	55                   	push   %ebp
80104aef:	89 e5                	mov    %esp,%ebp
80104af1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104af4:	83 ec 0c             	sub    $0xc,%esp
80104af7:	68 20 3c 11 80       	push   $0x80113c20
80104afc:	e8 b6 0b 00 00       	call   801056b7 <acquire>
80104b01:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b04:	c7 45 f4 54 3c 11 80 	movl   $0x80113c54,-0xc(%ebp)
80104b0b:	eb 0e                	jmp    80104b1b <allocproc+0x2d>
    if(p->state == UNUSED)
80104b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b10:	8b 40 0c             	mov    0xc(%eax),%eax
80104b13:	85 c0                	test   %eax,%eax
80104b15:	74 27                	je     80104b3e <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b17:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b1b:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
80104b22:	72 e9                	jb     80104b0d <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104b24:	83 ec 0c             	sub    $0xc,%esp
80104b27:	68 20 3c 11 80       	push   $0x80113c20
80104b2c:	e8 ed 0b 00 00       	call   8010571e <release>
80104b31:	83 c4 10             	add    $0x10,%esp
  return 0;
80104b34:	b8 00 00 00 00       	mov    $0x0,%eax
80104b39:	e9 b4 00 00 00       	jmp    80104bf2 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104b3e:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b42:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104b49:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b4e:	8d 50 01             	lea    0x1(%eax),%edx
80104b51:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b5a:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104b5d:	83 ec 0c             	sub    $0xc,%esp
80104b60:	68 20 3c 11 80       	push   $0x80113c20
80104b65:	e8 b4 0b 00 00       	call   8010571e <release>
80104b6a:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104b6d:	e8 79 e7 ff ff       	call   801032eb <kalloc>
80104b72:	89 c2                	mov    %eax,%edx
80104b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b77:	89 50 08             	mov    %edx,0x8(%eax)
80104b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7d:	8b 40 08             	mov    0x8(%eax),%eax
80104b80:	85 c0                	test   %eax,%eax
80104b82:	75 11                	jne    80104b95 <allocproc+0xa7>
    p->state = UNUSED;
80104b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b87:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104b8e:	b8 00 00 00 00       	mov    $0x0,%eax
80104b93:	eb 5d                	jmp    80104bf2 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80104b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b98:	8b 40 08             	mov    0x8(%eax),%eax
80104b9b:	05 00 10 00 00       	add    $0x1000,%eax
80104ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104ba3:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104baa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bad:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104bb0:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104bb4:	ba 00 6d 10 80       	mov    $0x80106d00,%edx
80104bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bbc:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104bbe:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bc8:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bce:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bd1:	83 ec 04             	sub    $0x4,%esp
80104bd4:	6a 14                	push   $0x14
80104bd6:	6a 00                	push   $0x0
80104bd8:	50                   	push   %eax
80104bd9:	e8 3c 0d 00 00       	call   8010591a <memset>
80104bde:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be4:	8b 40 1c             	mov    0x1c(%eax),%eax
80104be7:	ba 3b 53 10 80       	mov    $0x8010533b,%edx
80104bec:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bf2:	c9                   	leave  
80104bf3:	c3                   	ret    

80104bf4 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104bf4:	55                   	push   %ebp
80104bf5:	89 e5                	mov    %esp,%ebp
80104bf7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104bfa:	e8 ef fe ff ff       	call   80104aee <allocproc>
80104bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c05:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80104c0a:	e8 b6 37 00 00       	call   801083c5 <setupkvm>
80104c0f:	89 c2                	mov    %eax,%edx
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	89 50 04             	mov    %edx,0x4(%eax)
80104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1a:	8b 40 04             	mov    0x4(%eax),%eax
80104c1d:	85 c0                	test   %eax,%eax
80104c1f:	75 0d                	jne    80104c2e <userinit+0x3a>
    panic("userinit: out of memory?");
80104c21:	83 ec 0c             	sub    $0xc,%esp
80104c24:	68 e4 8f 10 80       	push   $0x80108fe4
80104c29:	e8 38 b9 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104c2e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c36:	8b 40 04             	mov    0x4(%eax),%eax
80104c39:	83 ec 04             	sub    $0x4,%esp
80104c3c:	52                   	push   %edx
80104c3d:	68 e0 c4 10 80       	push   $0x8010c4e0
80104c42:	50                   	push   %eax
80104c43:	e8 d7 39 00 00       	call   8010861f <inituvm>
80104c48:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c57:	8b 40 18             	mov    0x18(%eax),%eax
80104c5a:	83 ec 04             	sub    $0x4,%esp
80104c5d:	6a 4c                	push   $0x4c
80104c5f:	6a 00                	push   $0x0
80104c61:	50                   	push   %eax
80104c62:	e8 b3 0c 00 00       	call   8010591a <memset>
80104c67:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6d:	8b 40 18             	mov    0x18(%eax),%eax
80104c70:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c79:	8b 40 18             	mov    0x18(%eax),%eax
80104c7c:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	8b 40 18             	mov    0x18(%eax),%eax
80104c88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c8b:	8b 52 18             	mov    0x18(%edx),%edx
80104c8e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104c92:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c99:	8b 40 18             	mov    0x18(%eax),%eax
80104c9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c9f:	8b 52 18             	mov    0x18(%edx),%edx
80104ca2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ca6:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cad:	8b 40 18             	mov    0x18(%eax),%eax
80104cb0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cba:	8b 40 18             	mov    0x18(%eax),%eax
80104cbd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc7:	8b 40 18             	mov    0x18(%eax),%eax
80104cca:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd4:	83 c0 6c             	add    $0x6c,%eax
80104cd7:	83 ec 04             	sub    $0x4,%esp
80104cda:	6a 10                	push   $0x10
80104cdc:	68 fd 8f 10 80       	push   $0x80108ffd
80104ce1:	50                   	push   %eax
80104ce2:	e8 36 0e 00 00       	call   80105b1d <safestrcpy>
80104ce7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104cea:	83 ec 0c             	sub    $0xc,%esp
80104ced:	68 06 90 10 80       	push   $0x80109006
80104cf2:	e8 96 de ff ff       	call   80102b8d <namei>
80104cf7:	83 c4 10             	add    $0x10,%esp
80104cfa:	89 c2                	mov    %eax,%edx
80104cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cff:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
80104d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d05:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104d0c:	90                   	nop
80104d0d:	c9                   	leave  
80104d0e:	c3                   	ret    

80104d0f <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104d0f:	55                   	push   %ebp
80104d10:	89 e5                	mov    %esp,%ebp
80104d12:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104d15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1b:	8b 00                	mov    (%eax),%eax
80104d1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104d20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d24:	7e 31                	jle    80104d57 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d26:	8b 55 08             	mov    0x8(%ebp),%edx
80104d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2c:	01 c2                	add    %eax,%edx
80104d2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d34:	8b 40 04             	mov    0x4(%eax),%eax
80104d37:	83 ec 04             	sub    $0x4,%esp
80104d3a:	52                   	push   %edx
80104d3b:	ff 75 f4             	pushl  -0xc(%ebp)
80104d3e:	50                   	push   %eax
80104d3f:	e8 28 3a 00 00       	call   8010876c <allocuvm>
80104d44:	83 c4 10             	add    $0x10,%esp
80104d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d4e:	75 3e                	jne    80104d8e <growproc+0x7f>
      return -1;
80104d50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d55:	eb 59                	jmp    80104db0 <growproc+0xa1>
  } else if(n < 0){
80104d57:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d5b:	79 31                	jns    80104d8e <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d5d:	8b 55 08             	mov    0x8(%ebp),%edx
80104d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d63:	01 c2                	add    %eax,%edx
80104d65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d6b:	8b 40 04             	mov    0x4(%eax),%eax
80104d6e:	83 ec 04             	sub    $0x4,%esp
80104d71:	52                   	push   %edx
80104d72:	ff 75 f4             	pushl  -0xc(%ebp)
80104d75:	50                   	push   %eax
80104d76:	e8 ba 3a 00 00       	call   80108835 <deallocuvm>
80104d7b:	83 c4 10             	add    $0x10,%esp
80104d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d85:	75 07                	jne    80104d8e <growproc+0x7f>
      return -1;
80104d87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d8c:	eb 22                	jmp    80104db0 <growproc+0xa1>
  }
  proc->sz = sz;
80104d8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d97:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104d99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d9f:	83 ec 0c             	sub    $0xc,%esp
80104da2:	50                   	push   %eax
80104da3:	e8 04 37 00 00       	call   801084ac <switchuvm>
80104da8:	83 c4 10             	add    $0x10,%esp
  return 0;
80104dab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104db0:	c9                   	leave  
80104db1:	c3                   	ret    

80104db2 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104db2:	55                   	push   %ebp
80104db3:	89 e5                	mov    %esp,%ebp
80104db5:	57                   	push   %edi
80104db6:	56                   	push   %esi
80104db7:	53                   	push   %ebx
80104db8:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104dbb:	e8 2e fd ff ff       	call   80104aee <allocproc>
80104dc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104dc3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104dc7:	75 0a                	jne    80104dd3 <fork+0x21>
    return -1;
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dce:	e9 68 01 00 00       	jmp    80104f3b <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104dd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd9:	8b 10                	mov    (%eax),%edx
80104ddb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de1:	8b 40 04             	mov    0x4(%eax),%eax
80104de4:	83 ec 08             	sub    $0x8,%esp
80104de7:	52                   	push   %edx
80104de8:	50                   	push   %eax
80104de9:	e8 e5 3b 00 00       	call   801089d3 <copyuvm>
80104dee:	83 c4 10             	add    $0x10,%esp
80104df1:	89 c2                	mov    %eax,%edx
80104df3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104df6:	89 50 04             	mov    %edx,0x4(%eax)
80104df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dfc:	8b 40 04             	mov    0x4(%eax),%eax
80104dff:	85 c0                	test   %eax,%eax
80104e01:	75 30                	jne    80104e33 <fork+0x81>
    kfree(np->kstack);
80104e03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e06:	8b 40 08             	mov    0x8(%eax),%eax
80104e09:	83 ec 0c             	sub    $0xc,%esp
80104e0c:	50                   	push   %eax
80104e0d:	e8 3c e4 ff ff       	call   8010324e <kfree>
80104e12:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e22:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e2e:	e9 08 01 00 00       	jmp    80104f3b <fork+0x189>
  }
  np->sz = proc->sz;
80104e33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e39:	8b 10                	mov    (%eax),%edx
80104e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e3e:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104e40:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e4a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104e4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e50:	8b 50 18             	mov    0x18(%eax),%edx
80104e53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e59:	8b 40 18             	mov    0x18(%eax),%eax
80104e5c:	89 c3                	mov    %eax,%ebx
80104e5e:	b8 13 00 00 00       	mov    $0x13,%eax
80104e63:	89 d7                	mov    %edx,%edi
80104e65:	89 de                	mov    %ebx,%esi
80104e67:	89 c1                	mov    %eax,%ecx
80104e69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e6e:	8b 40 18             	mov    0x18(%eax),%eax
80104e71:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104e78:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104e7f:	eb 43                	jmp    80104ec4 <fork+0x112>
    if(proc->ofile[i])
80104e81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e8a:	83 c2 08             	add    $0x8,%edx
80104e8d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e91:	85 c0                	test   %eax,%eax
80104e93:	74 2b                	je     80104ec0 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e9e:	83 c2 08             	add    $0x8,%edx
80104ea1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ea5:	83 ec 0c             	sub    $0xc,%esp
80104ea8:	50                   	push   %eax
80104ea9:	e8 52 c1 ff ff       	call   80101000 <filedup>
80104eae:	83 c4 10             	add    $0x10,%esp
80104eb1:	89 c1                	mov    %eax,%ecx
80104eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104eb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104eb9:	83 c2 08             	add    $0x8,%edx
80104ebc:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104ec0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104ec4:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104ec8:	7e b7                	jle    80104e81 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104eca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ed0:	8b 40 68             	mov    0x68(%eax),%eax
80104ed3:	83 ec 0c             	sub    $0xc,%esp
80104ed6:	50                   	push   %eax
80104ed7:	e8 fe ce ff ff       	call   80101dda <idup>
80104edc:	83 c4 10             	add    $0x10,%esp
80104edf:	89 c2                	mov    %eax,%edx
80104ee1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ee4:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104ee7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eed:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ef3:	83 c0 6c             	add    $0x6c,%eax
80104ef6:	83 ec 04             	sub    $0x4,%esp
80104ef9:	6a 10                	push   $0x10
80104efb:	52                   	push   %edx
80104efc:	50                   	push   %eax
80104efd:	e8 1b 0c 00 00       	call   80105b1d <safestrcpy>
80104f02:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f08:	8b 40 10             	mov    0x10(%eax),%eax
80104f0b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104f0e:	83 ec 0c             	sub    $0xc,%esp
80104f11:	68 20 3c 11 80       	push   $0x80113c20
80104f16:	e8 9c 07 00 00       	call   801056b7 <acquire>
80104f1b:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104f1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f21:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104f28:	83 ec 0c             	sub    $0xc,%esp
80104f2b:	68 20 3c 11 80       	push   $0x80113c20
80104f30:	e8 e9 07 00 00       	call   8010571e <release>
80104f35:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104f38:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104f3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f3e:	5b                   	pop    %ebx
80104f3f:	5e                   	pop    %esi
80104f40:	5f                   	pop    %edi
80104f41:	5d                   	pop    %ebp
80104f42:	c3                   	ret    

80104f43 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104f43:	55                   	push   %ebp
80104f44:	89 e5                	mov    %esp,%ebp
80104f46:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104f49:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f50:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104f55:	39 c2                	cmp    %eax,%edx
80104f57:	75 0d                	jne    80104f66 <exit+0x23>
    panic("init exiting");
80104f59:	83 ec 0c             	sub    $0xc,%esp
80104f5c:	68 08 90 10 80       	push   $0x80109008
80104f61:	e8 00 b6 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104f66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f6d:	eb 48                	jmp    80104fb7 <exit+0x74>
    if(proc->ofile[fd]){
80104f6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f78:	83 c2 08             	add    $0x8,%edx
80104f7b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f7f:	85 c0                	test   %eax,%eax
80104f81:	74 30                	je     80104fb3 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104f83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f89:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f8c:	83 c2 08             	add    $0x8,%edx
80104f8f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f93:	83 ec 0c             	sub    $0xc,%esp
80104f96:	50                   	push   %eax
80104f97:	e8 b5 c0 ff ff       	call   80101051 <fileclose>
80104f9c:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104f9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fa8:	83 c2 08             	add    $0x8,%edx
80104fab:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104fb2:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104fb3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104fb7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104fbb:	7e b2                	jle    80104f6f <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104fbd:	e8 23 ec ff ff       	call   80103be5 <begin_op>
  iput(proc->cwd);
80104fc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc8:	8b 40 68             	mov    0x68(%eax),%eax
80104fcb:	83 ec 0c             	sub    $0xc,%esp
80104fce:	50                   	push   %eax
80104fcf:	e8 53 d0 ff ff       	call   80102027 <iput>
80104fd4:	83 c4 10             	add    $0x10,%esp
  end_op();
80104fd7:	e8 95 ec ff ff       	call   80103c71 <end_op>
  proc->cwd = 0;
80104fdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104fe9:	83 ec 0c             	sub    $0xc,%esp
80104fec:	68 20 3c 11 80       	push   $0x80113c20
80104ff1:	e8 c1 06 00 00       	call   801056b7 <acquire>
80104ff6:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104ff9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fff:	8b 40 14             	mov    0x14(%eax),%eax
80105002:	83 ec 0c             	sub    $0xc,%esp
80105005:	50                   	push   %eax
80105006:	e8 5f 04 00 00       	call   8010546a <wakeup1>
8010500b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010500e:	c7 45 f4 54 3c 11 80 	movl   $0x80113c54,-0xc(%ebp)
80105015:	eb 3c                	jmp    80105053 <exit+0x110>
    if(p->parent == proc){
80105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501a:	8b 50 14             	mov    0x14(%eax),%edx
8010501d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105023:	39 c2                	cmp    %eax,%edx
80105025:	75 28                	jne    8010504f <exit+0x10c>
      p->parent = initproc;
80105027:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
8010502d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105030:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 40 0c             	mov    0xc(%eax),%eax
80105039:	83 f8 05             	cmp    $0x5,%eax
8010503c:	75 11                	jne    8010504f <exit+0x10c>
        wakeup1(initproc);
8010503e:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105043:	83 ec 0c             	sub    $0xc,%esp
80105046:	50                   	push   %eax
80105047:	e8 1e 04 00 00       	call   8010546a <wakeup1>
8010504c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010504f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105053:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
8010505a:	72 bb                	jb     80105017 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010505c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105062:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105069:	e8 d6 01 00 00       	call   80105244 <sched>
  panic("zombie exit");
8010506e:	83 ec 0c             	sub    $0xc,%esp
80105071:	68 15 90 10 80       	push   $0x80109015
80105076:	e8 eb b4 ff ff       	call   80100566 <panic>

8010507b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010507b:	55                   	push   %ebp
8010507c:	89 e5                	mov    %esp,%ebp
8010507e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105081:	83 ec 0c             	sub    $0xc,%esp
80105084:	68 20 3c 11 80       	push   $0x80113c20
80105089:	e8 29 06 00 00       	call   801056b7 <acquire>
8010508e:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105091:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105098:	c7 45 f4 54 3c 11 80 	movl   $0x80113c54,-0xc(%ebp)
8010509f:	e9 a6 00 00 00       	jmp    8010514a <wait+0xcf>
      if(p->parent != proc)
801050a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a7:	8b 50 14             	mov    0x14(%eax),%edx
801050aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b0:	39 c2                	cmp    %eax,%edx
801050b2:	0f 85 8d 00 00 00    	jne    80105145 <wait+0xca>
        continue;
      havekids = 1;
801050b8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801050bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c2:	8b 40 0c             	mov    0xc(%eax),%eax
801050c5:	83 f8 05             	cmp    $0x5,%eax
801050c8:	75 7c                	jne    80105146 <wait+0xcb>
        // Found one.
        pid = p->pid;
801050ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cd:	8b 40 10             	mov    0x10(%eax),%eax
801050d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801050d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d6:	8b 40 08             	mov    0x8(%eax),%eax
801050d9:	83 ec 0c             	sub    $0xc,%esp
801050dc:	50                   	push   %eax
801050dd:	e8 6c e1 ff ff       	call   8010324e <kfree>
801050e2:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801050e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801050ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f2:	8b 40 04             	mov    0x4(%eax),%eax
801050f5:	83 ec 0c             	sub    $0xc,%esp
801050f8:	50                   	push   %eax
801050f9:	e8 f4 37 00 00       	call   801088f2 <freevm>
801050fe:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105104:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010510b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105118:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010511f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105122:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105129:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105130:	83 ec 0c             	sub    $0xc,%esp
80105133:	68 20 3c 11 80       	push   $0x80113c20
80105138:	e8 e1 05 00 00       	call   8010571e <release>
8010513d:	83 c4 10             	add    $0x10,%esp
        return pid;
80105140:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105143:	eb 58                	jmp    8010519d <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105145:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105146:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010514a:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
80105151:	0f 82 4d ff ff ff    	jb     801050a4 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105157:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010515b:	74 0d                	je     8010516a <wait+0xef>
8010515d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105163:	8b 40 24             	mov    0x24(%eax),%eax
80105166:	85 c0                	test   %eax,%eax
80105168:	74 17                	je     80105181 <wait+0x106>
      release(&ptable.lock);
8010516a:	83 ec 0c             	sub    $0xc,%esp
8010516d:	68 20 3c 11 80       	push   $0x80113c20
80105172:	e8 a7 05 00 00       	call   8010571e <release>
80105177:	83 c4 10             	add    $0x10,%esp
      return -1;
8010517a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517f:	eb 1c                	jmp    8010519d <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105181:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105187:	83 ec 08             	sub    $0x8,%esp
8010518a:	68 20 3c 11 80       	push   $0x80113c20
8010518f:	50                   	push   %eax
80105190:	e8 29 02 00 00       	call   801053be <sleep>
80105195:	83 c4 10             	add    $0x10,%esp
  }
80105198:	e9 f4 fe ff ff       	jmp    80105091 <wait+0x16>
}
8010519d:	c9                   	leave  
8010519e:	c3                   	ret    

8010519f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010519f:	55                   	push   %ebp
801051a0:	89 e5                	mov    %esp,%ebp
801051a2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801051a5:	e8 1f f9 ff ff       	call   80104ac9 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801051aa:	83 ec 0c             	sub    $0xc,%esp
801051ad:	68 20 3c 11 80       	push   $0x80113c20
801051b2:	e8 00 05 00 00       	call   801056b7 <acquire>
801051b7:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051ba:	c7 45 f4 54 3c 11 80 	movl   $0x80113c54,-0xc(%ebp)
801051c1:	eb 63                	jmp    80105226 <scheduler+0x87>
      if(p->state != RUNNABLE)
801051c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c6:	8b 40 0c             	mov    0xc(%eax),%eax
801051c9:	83 f8 03             	cmp    $0x3,%eax
801051cc:	75 53                	jne    80105221 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801051ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d1:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801051d7:	83 ec 0c             	sub    $0xc,%esp
801051da:	ff 75 f4             	pushl  -0xc(%ebp)
801051dd:	e8 ca 32 00 00       	call   801084ac <switchuvm>
801051e2:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801051e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e8:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801051ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801051f8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051ff:	83 c2 04             	add    $0x4,%edx
80105202:	83 ec 08             	sub    $0x8,%esp
80105205:	50                   	push   %eax
80105206:	52                   	push   %edx
80105207:	e8 82 09 00 00       	call   80105b8e <swtch>
8010520c:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010520f:	e8 7b 32 00 00       	call   8010848f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105214:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010521b:	00 00 00 00 
8010521f:	eb 01                	jmp    80105222 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105221:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105222:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105226:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
8010522d:	72 94                	jb     801051c3 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010522f:	83 ec 0c             	sub    $0xc,%esp
80105232:	68 20 3c 11 80       	push   $0x80113c20
80105237:	e8 e2 04 00 00       	call   8010571e <release>
8010523c:	83 c4 10             	add    $0x10,%esp

  }
8010523f:	e9 61 ff ff ff       	jmp    801051a5 <scheduler+0x6>

80105244 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105244:	55                   	push   %ebp
80105245:	89 e5                	mov    %esp,%ebp
80105247:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010524a:	83 ec 0c             	sub    $0xc,%esp
8010524d:	68 20 3c 11 80       	push   $0x80113c20
80105252:	e8 93 05 00 00       	call   801057ea <holding>
80105257:	83 c4 10             	add    $0x10,%esp
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 0d                	jne    8010526b <sched+0x27>
    panic("sched ptable.lock");
8010525e:	83 ec 0c             	sub    $0xc,%esp
80105261:	68 21 90 10 80       	push   $0x80109021
80105266:	e8 fb b2 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010526b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105271:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105277:	83 f8 01             	cmp    $0x1,%eax
8010527a:	74 0d                	je     80105289 <sched+0x45>
   panic("sched locks");
8010527c:	83 ec 0c             	sub    $0xc,%esp
8010527f:	68 33 90 10 80       	push   $0x80109033
80105284:	e8 dd b2 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105289:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528f:	8b 40 0c             	mov    0xc(%eax),%eax
80105292:	83 f8 04             	cmp    $0x4,%eax
80105295:	75 0d                	jne    801052a4 <sched+0x60>
    panic("sched running");
80105297:	83 ec 0c             	sub    $0xc,%esp
8010529a:	68 3f 90 10 80       	push   $0x8010903f
8010529f:	e8 c2 b2 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801052a4:	e8 10 f8 ff ff       	call   80104ab9 <readeflags>
801052a9:	25 00 02 00 00       	and    $0x200,%eax
801052ae:	85 c0                	test   %eax,%eax
801052b0:	74 0d                	je     801052bf <sched+0x7b>
    panic("sched interruptible");
801052b2:	83 ec 0c             	sub    $0xc,%esp
801052b5:	68 4d 90 10 80       	push   $0x8010904d
801052ba:	e8 a7 b2 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801052bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052c5:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801052ce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052d4:	8b 40 04             	mov    0x4(%eax),%eax
801052d7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052de:	83 c2 1c             	add    $0x1c,%edx
801052e1:	83 ec 08             	sub    $0x8,%esp
801052e4:	50                   	push   %eax
801052e5:	52                   	push   %edx
801052e6:	e8 a3 08 00 00       	call   80105b8e <swtch>
801052eb:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801052ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052f7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801052fd:	90                   	nop
801052fe:	c9                   	leave  
801052ff:	c3                   	ret    

80105300 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105300:	55                   	push   %ebp
80105301:	89 e5                	mov    %esp,%ebp
80105303:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105306:	83 ec 0c             	sub    $0xc,%esp
80105309:	68 20 3c 11 80       	push   $0x80113c20
8010530e:	e8 a4 03 00 00       	call   801056b7 <acquire>
80105313:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105316:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010531c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105323:	e8 1c ff ff ff       	call   80105244 <sched>
  release(&ptable.lock);
80105328:	83 ec 0c             	sub    $0xc,%esp
8010532b:	68 20 3c 11 80       	push   $0x80113c20
80105330:	e8 e9 03 00 00       	call   8010571e <release>
80105335:	83 c4 10             	add    $0x10,%esp
}
80105338:	90                   	nop
80105339:	c9                   	leave  
8010533a:	c3                   	ret    

8010533b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010533b:	55                   	push   %ebp
8010533c:	89 e5                	mov    %esp,%ebp
8010533e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105341:	83 ec 0c             	sub    $0xc,%esp
80105344:	68 20 3c 11 80       	push   $0x80113c20
80105349:	e8 d0 03 00 00       	call   8010571e <release>
8010534e:	83 c4 10             	add    $0x10,%esp


  if (first) {
80105351:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105356:	85 c0                	test   %eax,%eax
80105358:	74 61                	je     801053bb <forkret+0x80>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010535a:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105361:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
80105364:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010536a:	0f b6 00             	movzbl (%eax),%eax
8010536d:	0f b6 c0             	movzbl %al,%eax
80105370:	83 ec 08             	sub    $0x8,%esp
80105373:	50                   	push   %eax
80105374:	68 61 90 10 80       	push   $0x80109061
80105379:	e8 48 b0 ff ff       	call   801003c6 <cprintf>
8010537e:	83 c4 10             	add    $0x10,%esp
    int bootfrom=iinit(proc,ROOTDEV);
80105381:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105387:	83 ec 08             	sub    $0x8,%esp
8010538a:	6a 00                	push   $0x0
8010538c:	50                   	push   %eax
8010538d:	e8 f5 c5 ff ff       	call   80101987 <iinit>
80105392:	83 c4 10             	add    $0x10,%esp
80105395:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // iinitDone=1;
    cprintf("boot from after iinit is %d \n",bootfrom);
80105398:	83 ec 08             	sub    $0x8,%esp
8010539b:	ff 75 f4             	pushl  -0xc(%ebp)
8010539e:	68 70 90 10 80       	push   $0x80109070
801053a3:	e8 1e b0 ff ff       	call   801003c6 <cprintf>
801053a8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV,bootfrom);
801053ab:	83 ec 08             	sub    $0x8,%esp
801053ae:	ff 75 f4             	pushl  -0xc(%ebp)
801053b1:	6a 00                	push   $0x0
801053b3:	e8 fc e5 ff ff       	call   801039b4 <initlog>
801053b8:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
801053bb:	90                   	nop
801053bc:	c9                   	leave  
801053bd:	c3                   	ret    

801053be <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801053be:	55                   	push   %ebp
801053bf:	89 e5                	mov    %esp,%ebp
801053c1:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801053c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ca:	85 c0                	test   %eax,%eax
801053cc:	75 0d                	jne    801053db <sleep+0x1d>
    panic("sleep");
801053ce:	83 ec 0c             	sub    $0xc,%esp
801053d1:	68 8e 90 10 80       	push   $0x8010908e
801053d6:	e8 8b b1 ff ff       	call   80100566 <panic>

  if(lk == 0)
801053db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801053df:	75 0d                	jne    801053ee <sleep+0x30>
    panic("sleep without lk");
801053e1:	83 ec 0c             	sub    $0xc,%esp
801053e4:	68 94 90 10 80       	push   $0x80109094
801053e9:	e8 78 b1 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801053ee:	81 7d 0c 20 3c 11 80 	cmpl   $0x80113c20,0xc(%ebp)
801053f5:	74 1e                	je     80105415 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801053f7:	83 ec 0c             	sub    $0xc,%esp
801053fa:	68 20 3c 11 80       	push   $0x80113c20
801053ff:	e8 b3 02 00 00       	call   801056b7 <acquire>
80105404:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105407:	83 ec 0c             	sub    $0xc,%esp
8010540a:	ff 75 0c             	pushl  0xc(%ebp)
8010540d:	e8 0c 03 00 00       	call   8010571e <release>
80105412:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105415:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541b:	8b 55 08             	mov    0x8(%ebp),%edx
8010541e:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105421:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105427:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010542e:	e8 11 fe ff ff       	call   80105244 <sched>

  // Tidy up.
  proc->chan = 0;
80105433:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105439:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105440:	81 7d 0c 20 3c 11 80 	cmpl   $0x80113c20,0xc(%ebp)
80105447:	74 1e                	je     80105467 <sleep+0xa9>
    release(&ptable.lock);
80105449:	83 ec 0c             	sub    $0xc,%esp
8010544c:	68 20 3c 11 80       	push   $0x80113c20
80105451:	e8 c8 02 00 00       	call   8010571e <release>
80105456:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105459:	83 ec 0c             	sub    $0xc,%esp
8010545c:	ff 75 0c             	pushl  0xc(%ebp)
8010545f:	e8 53 02 00 00       	call   801056b7 <acquire>
80105464:	83 c4 10             	add    $0x10,%esp
  }
}
80105467:	90                   	nop
80105468:	c9                   	leave  
80105469:	c3                   	ret    

8010546a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010546a:	55                   	push   %ebp
8010546b:	89 e5                	mov    %esp,%ebp
8010546d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105470:	c7 45 fc 54 3c 11 80 	movl   $0x80113c54,-0x4(%ebp)
80105477:	eb 24                	jmp    8010549d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010547c:	8b 40 0c             	mov    0xc(%eax),%eax
8010547f:	83 f8 02             	cmp    $0x2,%eax
80105482:	75 15                	jne    80105499 <wakeup1+0x2f>
80105484:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105487:	8b 40 20             	mov    0x20(%eax),%eax
8010548a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010548d:	75 0a                	jne    80105499 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010548f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105492:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105499:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010549d:	81 7d fc 54 5b 11 80 	cmpl   $0x80115b54,-0x4(%ebp)
801054a4:	72 d3                	jb     80105479 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801054a6:	90                   	nop
801054a7:	c9                   	leave  
801054a8:	c3                   	ret    

801054a9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801054a9:	55                   	push   %ebp
801054aa:	89 e5                	mov    %esp,%ebp
801054ac:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801054af:	83 ec 0c             	sub    $0xc,%esp
801054b2:	68 20 3c 11 80       	push   $0x80113c20
801054b7:	e8 fb 01 00 00       	call   801056b7 <acquire>
801054bc:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801054bf:	83 ec 0c             	sub    $0xc,%esp
801054c2:	ff 75 08             	pushl  0x8(%ebp)
801054c5:	e8 a0 ff ff ff       	call   8010546a <wakeup1>
801054ca:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801054cd:	83 ec 0c             	sub    $0xc,%esp
801054d0:	68 20 3c 11 80       	push   $0x80113c20
801054d5:	e8 44 02 00 00       	call   8010571e <release>
801054da:	83 c4 10             	add    $0x10,%esp
}
801054dd:	90                   	nop
801054de:	c9                   	leave  
801054df:	c3                   	ret    

801054e0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801054e0:	55                   	push   %ebp
801054e1:	89 e5                	mov    %esp,%ebp
801054e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801054e6:	83 ec 0c             	sub    $0xc,%esp
801054e9:	68 20 3c 11 80       	push   $0x80113c20
801054ee:	e8 c4 01 00 00       	call   801056b7 <acquire>
801054f3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054f6:	c7 45 f4 54 3c 11 80 	movl   $0x80113c54,-0xc(%ebp)
801054fd:	eb 45                	jmp    80105544 <kill+0x64>
    if(p->pid == pid){
801054ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105502:	8b 40 10             	mov    0x10(%eax),%eax
80105505:	3b 45 08             	cmp    0x8(%ebp),%eax
80105508:	75 36                	jne    80105540 <kill+0x60>
      p->killed = 1;
8010550a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105517:	8b 40 0c             	mov    0xc(%eax),%eax
8010551a:	83 f8 02             	cmp    $0x2,%eax
8010551d:	75 0a                	jne    80105529 <kill+0x49>
        p->state = RUNNABLE;
8010551f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105522:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105529:	83 ec 0c             	sub    $0xc,%esp
8010552c:	68 20 3c 11 80       	push   $0x80113c20
80105531:	e8 e8 01 00 00       	call   8010571e <release>
80105536:	83 c4 10             	add    $0x10,%esp
      return 0;
80105539:	b8 00 00 00 00       	mov    $0x0,%eax
8010553e:	eb 22                	jmp    80105562 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105540:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105544:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
8010554b:	72 b2                	jb     801054ff <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010554d:	83 ec 0c             	sub    $0xc,%esp
80105550:	68 20 3c 11 80       	push   $0x80113c20
80105555:	e8 c4 01 00 00       	call   8010571e <release>
8010555a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010555d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105562:	c9                   	leave  
80105563:	c3                   	ret    

80105564 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105564:	55                   	push   %ebp
80105565:	89 e5                	mov    %esp,%ebp
80105567:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010556a:	c7 45 f0 54 3c 11 80 	movl   $0x80113c54,-0x10(%ebp)
80105571:	e9 d7 00 00 00       	jmp    8010564d <procdump+0xe9>
    if(p->state == UNUSED)
80105576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105579:	8b 40 0c             	mov    0xc(%eax),%eax
8010557c:	85 c0                	test   %eax,%eax
8010557e:	0f 84 c4 00 00 00    	je     80105648 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105587:	8b 40 0c             	mov    0xc(%eax),%eax
8010558a:	83 f8 05             	cmp    $0x5,%eax
8010558d:	77 23                	ja     801055b2 <procdump+0x4e>
8010558f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105592:	8b 40 0c             	mov    0xc(%eax),%eax
80105595:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010559c:	85 c0                	test   %eax,%eax
8010559e:	74 12                	je     801055b2 <procdump+0x4e>
      state = states[p->state];
801055a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a3:	8b 40 0c             	mov    0xc(%eax),%eax
801055a6:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801055ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
801055b0:	eb 07                	jmp    801055b9 <procdump+0x55>
    else
      state = "???";
801055b2:	c7 45 ec a5 90 10 80 	movl   $0x801090a5,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801055b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055bc:	8d 50 6c             	lea    0x6c(%eax),%edx
801055bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c2:	8b 40 10             	mov    0x10(%eax),%eax
801055c5:	52                   	push   %edx
801055c6:	ff 75 ec             	pushl  -0x14(%ebp)
801055c9:	50                   	push   %eax
801055ca:	68 a9 90 10 80       	push   $0x801090a9
801055cf:	e8 f2 ad ff ff       	call   801003c6 <cprintf>
801055d4:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801055d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055da:	8b 40 0c             	mov    0xc(%eax),%eax
801055dd:	83 f8 02             	cmp    $0x2,%eax
801055e0:	75 54                	jne    80105636 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801055e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801055e8:	8b 40 0c             	mov    0xc(%eax),%eax
801055eb:	83 c0 08             	add    $0x8,%eax
801055ee:	89 c2                	mov    %eax,%edx
801055f0:	83 ec 08             	sub    $0x8,%esp
801055f3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801055f6:	50                   	push   %eax
801055f7:	52                   	push   %edx
801055f8:	e8 73 01 00 00       	call   80105770 <getcallerpcs>
801055fd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105607:	eb 1c                	jmp    80105625 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105610:	83 ec 08             	sub    $0x8,%esp
80105613:	50                   	push   %eax
80105614:	68 b2 90 10 80       	push   $0x801090b2
80105619:	e8 a8 ad ff ff       	call   801003c6 <cprintf>
8010561e:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105621:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105625:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105629:	7f 0b                	jg     80105636 <procdump+0xd2>
8010562b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105632:	85 c0                	test   %eax,%eax
80105634:	75 d3                	jne    80105609 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105636:	83 ec 0c             	sub    $0xc,%esp
80105639:	68 b6 90 10 80       	push   $0x801090b6
8010563e:	e8 83 ad ff ff       	call   801003c6 <cprintf>
80105643:	83 c4 10             	add    $0x10,%esp
80105646:	eb 01                	jmp    80105649 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105648:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105649:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010564d:	81 7d f0 54 5b 11 80 	cmpl   $0x80115b54,-0x10(%ebp)
80105654:	0f 82 1c ff ff ff    	jb     80105576 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010565a:	90                   	nop
8010565b:	c9                   	leave  
8010565c:	c3                   	ret    

8010565d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010565d:	55                   	push   %ebp
8010565e:	89 e5                	mov    %esp,%ebp
80105660:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105663:	9c                   	pushf  
80105664:	58                   	pop    %eax
80105665:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105668:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010566b:	c9                   	leave  
8010566c:	c3                   	ret    

8010566d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010566d:	55                   	push   %ebp
8010566e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105670:	fa                   	cli    
}
80105671:	90                   	nop
80105672:	5d                   	pop    %ebp
80105673:	c3                   	ret    

80105674 <sti>:

static inline void
sti(void)
{
80105674:	55                   	push   %ebp
80105675:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105677:	fb                   	sti    
}
80105678:	90                   	nop
80105679:	5d                   	pop    %ebp
8010567a:	c3                   	ret    

8010567b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010567b:	55                   	push   %ebp
8010567c:	89 e5                	mov    %esp,%ebp
8010567e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105681:	8b 55 08             	mov    0x8(%ebp),%edx
80105684:	8b 45 0c             	mov    0xc(%ebp),%eax
80105687:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010568a:	f0 87 02             	lock xchg %eax,(%edx)
8010568d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105690:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105693:	c9                   	leave  
80105694:	c3                   	ret    

80105695 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105695:	55                   	push   %ebp
80105696:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105698:	8b 45 08             	mov    0x8(%ebp),%eax
8010569b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010569e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801056a1:	8b 45 08             	mov    0x8(%ebp),%eax
801056a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801056aa:	8b 45 08             	mov    0x8(%ebp),%eax
801056ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801056b4:	90                   	nop
801056b5:	5d                   	pop    %ebp
801056b6:	c3                   	ret    

801056b7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801056bd:	e8 52 01 00 00       	call   80105814 <pushcli>
  if(holding(lk))
801056c2:	8b 45 08             	mov    0x8(%ebp),%eax
801056c5:	83 ec 0c             	sub    $0xc,%esp
801056c8:	50                   	push   %eax
801056c9:	e8 1c 01 00 00       	call   801057ea <holding>
801056ce:	83 c4 10             	add    $0x10,%esp
801056d1:	85 c0                	test   %eax,%eax
801056d3:	74 0d                	je     801056e2 <acquire+0x2b>
    panic("acquire");
801056d5:	83 ec 0c             	sub    $0xc,%esp
801056d8:	68 e2 90 10 80       	push   $0x801090e2
801056dd:	e8 84 ae ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801056e2:	90                   	nop
801056e3:	8b 45 08             	mov    0x8(%ebp),%eax
801056e6:	83 ec 08             	sub    $0x8,%esp
801056e9:	6a 01                	push   $0x1
801056eb:	50                   	push   %eax
801056ec:	e8 8a ff ff ff       	call   8010567b <xchg>
801056f1:	83 c4 10             	add    $0x10,%esp
801056f4:	85 c0                	test   %eax,%eax
801056f6:	75 eb                	jne    801056e3 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801056f8:	8b 45 08             	mov    0x8(%ebp),%eax
801056fb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105702:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105705:	8b 45 08             	mov    0x8(%ebp),%eax
80105708:	83 c0 0c             	add    $0xc,%eax
8010570b:	83 ec 08             	sub    $0x8,%esp
8010570e:	50                   	push   %eax
8010570f:	8d 45 08             	lea    0x8(%ebp),%eax
80105712:	50                   	push   %eax
80105713:	e8 58 00 00 00       	call   80105770 <getcallerpcs>
80105718:	83 c4 10             	add    $0x10,%esp
}
8010571b:	90                   	nop
8010571c:	c9                   	leave  
8010571d:	c3                   	ret    

8010571e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010571e:	55                   	push   %ebp
8010571f:	89 e5                	mov    %esp,%ebp
80105721:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105724:	83 ec 0c             	sub    $0xc,%esp
80105727:	ff 75 08             	pushl  0x8(%ebp)
8010572a:	e8 bb 00 00 00       	call   801057ea <holding>
8010572f:	83 c4 10             	add    $0x10,%esp
80105732:	85 c0                	test   %eax,%eax
80105734:	75 0d                	jne    80105743 <release+0x25>
    panic("release");
80105736:	83 ec 0c             	sub    $0xc,%esp
80105739:	68 ea 90 10 80       	push   $0x801090ea
8010573e:	e8 23 ae ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105743:	8b 45 08             	mov    0x8(%ebp),%eax
80105746:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010574d:	8b 45 08             	mov    0x8(%ebp),%eax
80105750:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105757:	8b 45 08             	mov    0x8(%ebp),%eax
8010575a:	83 ec 08             	sub    $0x8,%esp
8010575d:	6a 00                	push   $0x0
8010575f:	50                   	push   %eax
80105760:	e8 16 ff ff ff       	call   8010567b <xchg>
80105765:	83 c4 10             	add    $0x10,%esp

  popcli();
80105768:	e8 ec 00 00 00       	call   80105859 <popcli>
}
8010576d:	90                   	nop
8010576e:	c9                   	leave  
8010576f:	c3                   	ret    

80105770 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105770:	55                   	push   %ebp
80105771:	89 e5                	mov    %esp,%ebp
80105773:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105776:	8b 45 08             	mov    0x8(%ebp),%eax
80105779:	83 e8 08             	sub    $0x8,%eax
8010577c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010577f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105786:	eb 38                	jmp    801057c0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105788:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010578c:	74 53                	je     801057e1 <getcallerpcs+0x71>
8010578e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105795:	76 4a                	jbe    801057e1 <getcallerpcs+0x71>
80105797:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010579b:	74 44                	je     801057e1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010579d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801057a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057aa:	01 c2                	add    %eax,%edx
801057ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057af:	8b 40 04             	mov    0x4(%eax),%eax
801057b2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801057b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057b7:	8b 00                	mov    (%eax),%eax
801057b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801057bc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801057c0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801057c4:	7e c2                	jle    80105788 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801057c6:	eb 19                	jmp    801057e1 <getcallerpcs+0x71>
    pcs[i] = 0;
801057c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801057d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d5:	01 d0                	add    %edx,%eax
801057d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801057dd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801057e1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801057e5:	7e e1                	jle    801057c8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801057e7:	90                   	nop
801057e8:	c9                   	leave  
801057e9:	c3                   	ret    

801057ea <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801057ea:	55                   	push   %ebp
801057eb:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801057ed:	8b 45 08             	mov    0x8(%ebp),%eax
801057f0:	8b 00                	mov    (%eax),%eax
801057f2:	85 c0                	test   %eax,%eax
801057f4:	74 17                	je     8010580d <holding+0x23>
801057f6:	8b 45 08             	mov    0x8(%ebp),%eax
801057f9:	8b 50 08             	mov    0x8(%eax),%edx
801057fc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105802:	39 c2                	cmp    %eax,%edx
80105804:	75 07                	jne    8010580d <holding+0x23>
80105806:	b8 01 00 00 00       	mov    $0x1,%eax
8010580b:	eb 05                	jmp    80105812 <holding+0x28>
8010580d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105812:	5d                   	pop    %ebp
80105813:	c3                   	ret    

80105814 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105814:	55                   	push   %ebp
80105815:	89 e5                	mov    %esp,%ebp
80105817:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010581a:	e8 3e fe ff ff       	call   8010565d <readeflags>
8010581f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105822:	e8 46 fe ff ff       	call   8010566d <cli>
  if(cpu->ncli++ == 0)
80105827:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010582e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105834:	8d 48 01             	lea    0x1(%eax),%ecx
80105837:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010583d:	85 c0                	test   %eax,%eax
8010583f:	75 15                	jne    80105856 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105841:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105847:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010584a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105850:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105856:	90                   	nop
80105857:	c9                   	leave  
80105858:	c3                   	ret    

80105859 <popcli>:

void
popcli(void)
{
80105859:	55                   	push   %ebp
8010585a:	89 e5                	mov    %esp,%ebp
8010585c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010585f:	e8 f9 fd ff ff       	call   8010565d <readeflags>
80105864:	25 00 02 00 00       	and    $0x200,%eax
80105869:	85 c0                	test   %eax,%eax
8010586b:	74 0d                	je     8010587a <popcli+0x21>
    panic("popcli - interruptible");
8010586d:	83 ec 0c             	sub    $0xc,%esp
80105870:	68 f2 90 10 80       	push   $0x801090f2
80105875:	e8 ec ac ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010587a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105880:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105886:	83 ea 01             	sub    $0x1,%edx
80105889:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010588f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105895:	85 c0                	test   %eax,%eax
80105897:	79 0d                	jns    801058a6 <popcli+0x4d>
    panic("popcli");
80105899:	83 ec 0c             	sub    $0xc,%esp
8010589c:	68 09 91 10 80       	push   $0x80109109
801058a1:	e8 c0 ac ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801058a6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801058ac:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801058b2:	85 c0                	test   %eax,%eax
801058b4:	75 15                	jne    801058cb <popcli+0x72>
801058b6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801058bc:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801058c2:	85 c0                	test   %eax,%eax
801058c4:	74 05                	je     801058cb <popcli+0x72>
    sti();
801058c6:	e8 a9 fd ff ff       	call   80105674 <sti>
}
801058cb:	90                   	nop
801058cc:	c9                   	leave  
801058cd:	c3                   	ret    

801058ce <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801058ce:	55                   	push   %ebp
801058cf:	89 e5                	mov    %esp,%ebp
801058d1:	57                   	push   %edi
801058d2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801058d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801058d6:	8b 55 10             	mov    0x10(%ebp),%edx
801058d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801058dc:	89 cb                	mov    %ecx,%ebx
801058de:	89 df                	mov    %ebx,%edi
801058e0:	89 d1                	mov    %edx,%ecx
801058e2:	fc                   	cld    
801058e3:	f3 aa                	rep stos %al,%es:(%edi)
801058e5:	89 ca                	mov    %ecx,%edx
801058e7:	89 fb                	mov    %edi,%ebx
801058e9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801058ec:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801058ef:	90                   	nop
801058f0:	5b                   	pop    %ebx
801058f1:	5f                   	pop    %edi
801058f2:	5d                   	pop    %ebp
801058f3:	c3                   	ret    

801058f4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801058f4:	55                   	push   %ebp
801058f5:	89 e5                	mov    %esp,%ebp
801058f7:	57                   	push   %edi
801058f8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801058f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801058fc:	8b 55 10             	mov    0x10(%ebp),%edx
801058ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105902:	89 cb                	mov    %ecx,%ebx
80105904:	89 df                	mov    %ebx,%edi
80105906:	89 d1                	mov    %edx,%ecx
80105908:	fc                   	cld    
80105909:	f3 ab                	rep stos %eax,%es:(%edi)
8010590b:	89 ca                	mov    %ecx,%edx
8010590d:	89 fb                	mov    %edi,%ebx
8010590f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105912:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105915:	90                   	nop
80105916:	5b                   	pop    %ebx
80105917:	5f                   	pop    %edi
80105918:	5d                   	pop    %ebp
80105919:	c3                   	ret    

8010591a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010591a:	55                   	push   %ebp
8010591b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010591d:	8b 45 08             	mov    0x8(%ebp),%eax
80105920:	83 e0 03             	and    $0x3,%eax
80105923:	85 c0                	test   %eax,%eax
80105925:	75 43                	jne    8010596a <memset+0x50>
80105927:	8b 45 10             	mov    0x10(%ebp),%eax
8010592a:	83 e0 03             	and    $0x3,%eax
8010592d:	85 c0                	test   %eax,%eax
8010592f:	75 39                	jne    8010596a <memset+0x50>
    c &= 0xFF;
80105931:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105938:	8b 45 10             	mov    0x10(%ebp),%eax
8010593b:	c1 e8 02             	shr    $0x2,%eax
8010593e:	89 c1                	mov    %eax,%ecx
80105940:	8b 45 0c             	mov    0xc(%ebp),%eax
80105943:	c1 e0 18             	shl    $0x18,%eax
80105946:	89 c2                	mov    %eax,%edx
80105948:	8b 45 0c             	mov    0xc(%ebp),%eax
8010594b:	c1 e0 10             	shl    $0x10,%eax
8010594e:	09 c2                	or     %eax,%edx
80105950:	8b 45 0c             	mov    0xc(%ebp),%eax
80105953:	c1 e0 08             	shl    $0x8,%eax
80105956:	09 d0                	or     %edx,%eax
80105958:	0b 45 0c             	or     0xc(%ebp),%eax
8010595b:	51                   	push   %ecx
8010595c:	50                   	push   %eax
8010595d:	ff 75 08             	pushl  0x8(%ebp)
80105960:	e8 8f ff ff ff       	call   801058f4 <stosl>
80105965:	83 c4 0c             	add    $0xc,%esp
80105968:	eb 12                	jmp    8010597c <memset+0x62>
  } else
    stosb(dst, c, n);
8010596a:	8b 45 10             	mov    0x10(%ebp),%eax
8010596d:	50                   	push   %eax
8010596e:	ff 75 0c             	pushl  0xc(%ebp)
80105971:	ff 75 08             	pushl  0x8(%ebp)
80105974:	e8 55 ff ff ff       	call   801058ce <stosb>
80105979:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010597c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010597f:	c9                   	leave  
80105980:	c3                   	ret    

80105981 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105981:	55                   	push   %ebp
80105982:	89 e5                	mov    %esp,%ebp
80105984:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105987:	8b 45 08             	mov    0x8(%ebp),%eax
8010598a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010598d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105990:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105993:	eb 30                	jmp    801059c5 <memcmp+0x44>
    if(*s1 != *s2)
80105995:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105998:	0f b6 10             	movzbl (%eax),%edx
8010599b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010599e:	0f b6 00             	movzbl (%eax),%eax
801059a1:	38 c2                	cmp    %al,%dl
801059a3:	74 18                	je     801059bd <memcmp+0x3c>
      return *s1 - *s2;
801059a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059a8:	0f b6 00             	movzbl (%eax),%eax
801059ab:	0f b6 d0             	movzbl %al,%edx
801059ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059b1:	0f b6 00             	movzbl (%eax),%eax
801059b4:	0f b6 c0             	movzbl %al,%eax
801059b7:	29 c2                	sub    %eax,%edx
801059b9:	89 d0                	mov    %edx,%eax
801059bb:	eb 1a                	jmp    801059d7 <memcmp+0x56>
    s1++, s2++;
801059bd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059c1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801059c5:	8b 45 10             	mov    0x10(%ebp),%eax
801059c8:	8d 50 ff             	lea    -0x1(%eax),%edx
801059cb:	89 55 10             	mov    %edx,0x10(%ebp)
801059ce:	85 c0                	test   %eax,%eax
801059d0:	75 c3                	jne    80105995 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801059d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059d7:	c9                   	leave  
801059d8:	c3                   	ret    

801059d9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801059d9:	55                   	push   %ebp
801059da:	89 e5                	mov    %esp,%ebp
801059dc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801059df:	8b 45 0c             	mov    0xc(%ebp),%eax
801059e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801059e5:	8b 45 08             	mov    0x8(%ebp),%eax
801059e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801059eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059f1:	73 54                	jae    80105a47 <memmove+0x6e>
801059f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059f6:	8b 45 10             	mov    0x10(%ebp),%eax
801059f9:	01 d0                	add    %edx,%eax
801059fb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059fe:	76 47                	jbe    80105a47 <memmove+0x6e>
    s += n;
80105a00:	8b 45 10             	mov    0x10(%ebp),%eax
80105a03:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105a06:	8b 45 10             	mov    0x10(%ebp),%eax
80105a09:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105a0c:	eb 13                	jmp    80105a21 <memmove+0x48>
      *--d = *--s;
80105a0e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105a12:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105a16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a19:	0f b6 10             	movzbl (%eax),%edx
80105a1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a1f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105a21:	8b 45 10             	mov    0x10(%ebp),%eax
80105a24:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a27:	89 55 10             	mov    %edx,0x10(%ebp)
80105a2a:	85 c0                	test   %eax,%eax
80105a2c:	75 e0                	jne    80105a0e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105a2e:	eb 24                	jmp    80105a54 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105a30:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a33:	8d 50 01             	lea    0x1(%eax),%edx
80105a36:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105a39:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a3c:	8d 4a 01             	lea    0x1(%edx),%ecx
80105a3f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105a42:	0f b6 12             	movzbl (%edx),%edx
80105a45:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105a47:	8b 45 10             	mov    0x10(%ebp),%eax
80105a4a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a4d:	89 55 10             	mov    %edx,0x10(%ebp)
80105a50:	85 c0                	test   %eax,%eax
80105a52:	75 dc                	jne    80105a30 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105a54:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a57:	c9                   	leave  
80105a58:	c3                   	ret    

80105a59 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105a5c:	ff 75 10             	pushl  0x10(%ebp)
80105a5f:	ff 75 0c             	pushl  0xc(%ebp)
80105a62:	ff 75 08             	pushl  0x8(%ebp)
80105a65:	e8 6f ff ff ff       	call   801059d9 <memmove>
80105a6a:	83 c4 0c             	add    $0xc,%esp
}
80105a6d:	c9                   	leave  
80105a6e:	c3                   	ret    

80105a6f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105a6f:	55                   	push   %ebp
80105a70:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105a72:	eb 0c                	jmp    80105a80 <strncmp+0x11>
    n--, p++, q++;
80105a74:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105a78:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105a7c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105a80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a84:	74 1a                	je     80105aa0 <strncmp+0x31>
80105a86:	8b 45 08             	mov    0x8(%ebp),%eax
80105a89:	0f b6 00             	movzbl (%eax),%eax
80105a8c:	84 c0                	test   %al,%al
80105a8e:	74 10                	je     80105aa0 <strncmp+0x31>
80105a90:	8b 45 08             	mov    0x8(%ebp),%eax
80105a93:	0f b6 10             	movzbl (%eax),%edx
80105a96:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a99:	0f b6 00             	movzbl (%eax),%eax
80105a9c:	38 c2                	cmp    %al,%dl
80105a9e:	74 d4                	je     80105a74 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105aa0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105aa4:	75 07                	jne    80105aad <strncmp+0x3e>
    return 0;
80105aa6:	b8 00 00 00 00       	mov    $0x0,%eax
80105aab:	eb 16                	jmp    80105ac3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105aad:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab0:	0f b6 00             	movzbl (%eax),%eax
80105ab3:	0f b6 d0             	movzbl %al,%edx
80105ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab9:	0f b6 00             	movzbl (%eax),%eax
80105abc:	0f b6 c0             	movzbl %al,%eax
80105abf:	29 c2                	sub    %eax,%edx
80105ac1:	89 d0                	mov    %edx,%eax
}
80105ac3:	5d                   	pop    %ebp
80105ac4:	c3                   	ret    

80105ac5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105ac5:	55                   	push   %ebp
80105ac6:	89 e5                	mov    %esp,%ebp
80105ac8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105acb:	8b 45 08             	mov    0x8(%ebp),%eax
80105ace:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105ad1:	90                   	nop
80105ad2:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ad8:	89 55 10             	mov    %edx,0x10(%ebp)
80105adb:	85 c0                	test   %eax,%eax
80105add:	7e 2c                	jle    80105b0b <strncpy+0x46>
80105adf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae2:	8d 50 01             	lea    0x1(%eax),%edx
80105ae5:	89 55 08             	mov    %edx,0x8(%ebp)
80105ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
80105aeb:	8d 4a 01             	lea    0x1(%edx),%ecx
80105aee:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105af1:	0f b6 12             	movzbl (%edx),%edx
80105af4:	88 10                	mov    %dl,(%eax)
80105af6:	0f b6 00             	movzbl (%eax),%eax
80105af9:	84 c0                	test   %al,%al
80105afb:	75 d5                	jne    80105ad2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105afd:	eb 0c                	jmp    80105b0b <strncpy+0x46>
    *s++ = 0;
80105aff:	8b 45 08             	mov    0x8(%ebp),%eax
80105b02:	8d 50 01             	lea    0x1(%eax),%edx
80105b05:	89 55 08             	mov    %edx,0x8(%ebp)
80105b08:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105b0b:	8b 45 10             	mov    0x10(%ebp),%eax
80105b0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b11:	89 55 10             	mov    %edx,0x10(%ebp)
80105b14:	85 c0                	test   %eax,%eax
80105b16:	7f e7                	jg     80105aff <strncpy+0x3a>
    *s++ = 0;
  return os;
80105b18:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b1b:	c9                   	leave  
80105b1c:	c3                   	ret    

80105b1d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105b1d:	55                   	push   %ebp
80105b1e:	89 e5                	mov    %esp,%ebp
80105b20:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105b23:	8b 45 08             	mov    0x8(%ebp),%eax
80105b26:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105b29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b2d:	7f 05                	jg     80105b34 <safestrcpy+0x17>
    return os;
80105b2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b32:	eb 31                	jmp    80105b65 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105b34:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105b38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b3c:	7e 1e                	jle    80105b5c <safestrcpy+0x3f>
80105b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b41:	8d 50 01             	lea    0x1(%eax),%edx
80105b44:	89 55 08             	mov    %edx,0x8(%ebp)
80105b47:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b4a:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b4d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105b50:	0f b6 12             	movzbl (%edx),%edx
80105b53:	88 10                	mov    %dl,(%eax)
80105b55:	0f b6 00             	movzbl (%eax),%eax
80105b58:	84 c0                	test   %al,%al
80105b5a:	75 d8                	jne    80105b34 <safestrcpy+0x17>
    ;
  *s = 0;
80105b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b5f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105b62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b65:	c9                   	leave  
80105b66:	c3                   	ret    

80105b67 <strlen>:

int
strlen(const char *s)
{
80105b67:	55                   	push   %ebp
80105b68:	89 e5                	mov    %esp,%ebp
80105b6a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105b6d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b74:	eb 04                	jmp    80105b7a <strlen+0x13>
80105b76:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b7a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105b80:	01 d0                	add    %edx,%eax
80105b82:	0f b6 00             	movzbl (%eax),%eax
80105b85:	84 c0                	test   %al,%al
80105b87:	75 ed                	jne    80105b76 <strlen+0xf>
    ;
  return n;
80105b89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b8c:	c9                   	leave  
80105b8d:	c3                   	ret    

80105b8e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105b8e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105b92:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105b96:	55                   	push   %ebp
  pushl %ebx
80105b97:	53                   	push   %ebx
  pushl %esi
80105b98:	56                   	push   %esi
  pushl %edi
80105b99:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105b9a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105b9c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105b9e:	5f                   	pop    %edi
  popl %esi
80105b9f:	5e                   	pop    %esi
  popl %ebx
80105ba0:	5b                   	pop    %ebx
  popl %ebp
80105ba1:	5d                   	pop    %ebp
  ret
80105ba2:	c3                   	ret    

80105ba3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105ba3:	55                   	push   %ebp
80105ba4:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105ba6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bac:	8b 00                	mov    (%eax),%eax
80105bae:	3b 45 08             	cmp    0x8(%ebp),%eax
80105bb1:	76 12                	jbe    80105bc5 <fetchint+0x22>
80105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb6:	8d 50 04             	lea    0x4(%eax),%edx
80105bb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bbf:	8b 00                	mov    (%eax),%eax
80105bc1:	39 c2                	cmp    %eax,%edx
80105bc3:	76 07                	jbe    80105bcc <fetchint+0x29>
    return -1;
80105bc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bca:	eb 0f                	jmp    80105bdb <fetchint+0x38>
  *ip = *(int*)(addr);
80105bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcf:	8b 10                	mov    (%eax),%edx
80105bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd4:	89 10                	mov    %edx,(%eax)
  return 0;
80105bd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bdb:	5d                   	pop    %ebp
80105bdc:	c3                   	ret    

80105bdd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105bdd:	55                   	push   %ebp
80105bde:	89 e5                	mov    %esp,%ebp
80105be0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105be3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105be9:	8b 00                	mov    (%eax),%eax
80105beb:	3b 45 08             	cmp    0x8(%ebp),%eax
80105bee:	77 07                	ja     80105bf7 <fetchstr+0x1a>
    return -1;
80105bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf5:	eb 46                	jmp    80105c3d <fetchstr+0x60>
  *pp = (char*)addr;
80105bf7:	8b 55 08             	mov    0x8(%ebp),%edx
80105bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bfd:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105bff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c05:	8b 00                	mov    (%eax),%eax
80105c07:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c0d:	8b 00                	mov    (%eax),%eax
80105c0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105c12:	eb 1c                	jmp    80105c30 <fetchstr+0x53>
    if(*s == 0)
80105c14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c17:	0f b6 00             	movzbl (%eax),%eax
80105c1a:	84 c0                	test   %al,%al
80105c1c:	75 0e                	jne    80105c2c <fetchstr+0x4f>
      return s - *pp;
80105c1e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c21:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c24:	8b 00                	mov    (%eax),%eax
80105c26:	29 c2                	sub    %eax,%edx
80105c28:	89 d0                	mov    %edx,%eax
80105c2a:	eb 11                	jmp    80105c3d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105c2c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c33:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c36:	72 dc                	jb     80105c14 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105c38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c3d:	c9                   	leave  
80105c3e:	c3                   	ret    

80105c3f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105c3f:	55                   	push   %ebp
80105c40:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105c42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c48:	8b 40 18             	mov    0x18(%eax),%eax
80105c4b:	8b 40 44             	mov    0x44(%eax),%eax
80105c4e:	8b 55 08             	mov    0x8(%ebp),%edx
80105c51:	c1 e2 02             	shl    $0x2,%edx
80105c54:	01 d0                	add    %edx,%eax
80105c56:	83 c0 04             	add    $0x4,%eax
80105c59:	ff 75 0c             	pushl  0xc(%ebp)
80105c5c:	50                   	push   %eax
80105c5d:	e8 41 ff ff ff       	call   80105ba3 <fetchint>
80105c62:	83 c4 08             	add    $0x8,%esp
}
80105c65:	c9                   	leave  
80105c66:	c3                   	ret    

80105c67 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105c67:	55                   	push   %ebp
80105c68:	89 e5                	mov    %esp,%ebp
80105c6a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105c6d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105c70:	50                   	push   %eax
80105c71:	ff 75 08             	pushl  0x8(%ebp)
80105c74:	e8 c6 ff ff ff       	call   80105c3f <argint>
80105c79:	83 c4 08             	add    $0x8,%esp
80105c7c:	85 c0                	test   %eax,%eax
80105c7e:	79 07                	jns    80105c87 <argptr+0x20>
    return -1;
80105c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c85:	eb 3b                	jmp    80105cc2 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105c87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c8d:	8b 00                	mov    (%eax),%eax
80105c8f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c92:	39 d0                	cmp    %edx,%eax
80105c94:	76 16                	jbe    80105cac <argptr+0x45>
80105c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c99:	89 c2                	mov    %eax,%edx
80105c9b:	8b 45 10             	mov    0x10(%ebp),%eax
80105c9e:	01 c2                	add    %eax,%edx
80105ca0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ca6:	8b 00                	mov    (%eax),%eax
80105ca8:	39 c2                	cmp    %eax,%edx
80105caa:	76 07                	jbe    80105cb3 <argptr+0x4c>
    return -1;
80105cac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb1:	eb 0f                	jmp    80105cc2 <argptr+0x5b>
  *pp = (char*)i;
80105cb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cb6:	89 c2                	mov    %eax,%edx
80105cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cbb:	89 10                	mov    %edx,(%eax)
  return 0;
80105cbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cc2:	c9                   	leave  
80105cc3:	c3                   	ret    

80105cc4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105cc4:	55                   	push   %ebp
80105cc5:	89 e5                	mov    %esp,%ebp
80105cc7:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105cca:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105ccd:	50                   	push   %eax
80105cce:	ff 75 08             	pushl  0x8(%ebp)
80105cd1:	e8 69 ff ff ff       	call   80105c3f <argint>
80105cd6:	83 c4 08             	add    $0x8,%esp
80105cd9:	85 c0                	test   %eax,%eax
80105cdb:	79 07                	jns    80105ce4 <argstr+0x20>
    return -1;
80105cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce2:	eb 0f                	jmp    80105cf3 <argstr+0x2f>
  return fetchstr(addr, pp);
80105ce4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ce7:	ff 75 0c             	pushl  0xc(%ebp)
80105cea:	50                   	push   %eax
80105ceb:	e8 ed fe ff ff       	call   80105bdd <fetchstr>
80105cf0:	83 c4 08             	add    $0x8,%esp
}
80105cf3:	c9                   	leave  
80105cf4:	c3                   	ret    

80105cf5 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105cf5:	55                   	push   %ebp
80105cf6:	89 e5                	mov    %esp,%ebp
80105cf8:	53                   	push   %ebx
80105cf9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105cfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d02:	8b 40 18             	mov    0x18(%eax),%eax
80105d05:	8b 40 1c             	mov    0x1c(%eax),%eax
80105d08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105d0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d0f:	7e 30                	jle    80105d41 <syscall+0x4c>
80105d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d14:	83 f8 15             	cmp    $0x15,%eax
80105d17:	77 28                	ja     80105d41 <syscall+0x4c>
80105d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105d23:	85 c0                	test   %eax,%eax
80105d25:	74 1a                	je     80105d41 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105d27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d2d:	8b 58 18             	mov    0x18(%eax),%ebx
80105d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d33:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105d3a:	ff d0                	call   *%eax
80105d3c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105d3f:	eb 34                	jmp    80105d75 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105d41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d47:	8d 50 6c             	lea    0x6c(%eax),%edx
80105d4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105d50:	8b 40 10             	mov    0x10(%eax),%eax
80105d53:	ff 75 f4             	pushl  -0xc(%ebp)
80105d56:	52                   	push   %edx
80105d57:	50                   	push   %eax
80105d58:	68 10 91 10 80       	push   $0x80109110
80105d5d:	e8 64 a6 ff ff       	call   801003c6 <cprintf>
80105d62:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105d65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d6b:	8b 40 18             	mov    0x18(%eax),%eax
80105d6e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105d75:	90                   	nop
80105d76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d79:	c9                   	leave  
80105d7a:	c3                   	ret    

80105d7b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105d7b:	55                   	push   %ebp
80105d7c:	89 e5                	mov    %esp,%ebp
80105d7e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105d81:	83 ec 08             	sub    $0x8,%esp
80105d84:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d87:	50                   	push   %eax
80105d88:	ff 75 08             	pushl  0x8(%ebp)
80105d8b:	e8 af fe ff ff       	call   80105c3f <argint>
80105d90:	83 c4 10             	add    $0x10,%esp
80105d93:	85 c0                	test   %eax,%eax
80105d95:	79 07                	jns    80105d9e <argfd+0x23>
    return -1;
80105d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9c:	eb 50                	jmp    80105dee <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da1:	85 c0                	test   %eax,%eax
80105da3:	78 21                	js     80105dc6 <argfd+0x4b>
80105da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da8:	83 f8 0f             	cmp    $0xf,%eax
80105dab:	7f 19                	jg     80105dc6 <argfd+0x4b>
80105dad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105db3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105db6:	83 c2 08             	add    $0x8,%edx
80105db9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc4:	75 07                	jne    80105dcd <argfd+0x52>
    return -1;
80105dc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dcb:	eb 21                	jmp    80105dee <argfd+0x73>
  if(pfd)
80105dcd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105dd1:	74 08                	je     80105ddb <argfd+0x60>
    *pfd = fd;
80105dd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd9:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ddb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ddf:	74 08                	je     80105de9 <argfd+0x6e>
    *pf = f;
80105de1:	8b 45 10             	mov    0x10(%ebp),%eax
80105de4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105de7:	89 10                	mov    %edx,(%eax)
  return 0;
80105de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dee:	c9                   	leave  
80105def:	c3                   	ret    

80105df0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105df0:	55                   	push   %ebp
80105df1:	89 e5                	mov    %esp,%ebp
80105df3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105df6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105dfd:	eb 30                	jmp    80105e2f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105dff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e05:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e08:	83 c2 08             	add    $0x8,%edx
80105e0b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105e0f:	85 c0                	test   %eax,%eax
80105e11:	75 18                	jne    80105e2b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105e13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e19:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e1c:	8d 4a 08             	lea    0x8(%edx),%ecx
80105e1f:	8b 55 08             	mov    0x8(%ebp),%edx
80105e22:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105e26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e29:	eb 0f                	jmp    80105e3a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105e2b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e2f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105e33:	7e ca                	jle    80105dff <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105e35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e3a:	c9                   	leave  
80105e3b:	c3                   	ret    

80105e3c <sys_dup>:

int
sys_dup(void)
{
80105e3c:	55                   	push   %ebp
80105e3d:	89 e5                	mov    %esp,%ebp
80105e3f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105e42:	83 ec 04             	sub    $0x4,%esp
80105e45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e48:	50                   	push   %eax
80105e49:	6a 00                	push   $0x0
80105e4b:	6a 00                	push   $0x0
80105e4d:	e8 29 ff ff ff       	call   80105d7b <argfd>
80105e52:	83 c4 10             	add    $0x10,%esp
80105e55:	85 c0                	test   %eax,%eax
80105e57:	79 07                	jns    80105e60 <sys_dup+0x24>
    return -1;
80105e59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5e:	eb 31                	jmp    80105e91 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e63:	83 ec 0c             	sub    $0xc,%esp
80105e66:	50                   	push   %eax
80105e67:	e8 84 ff ff ff       	call   80105df0 <fdalloc>
80105e6c:	83 c4 10             	add    $0x10,%esp
80105e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e76:	79 07                	jns    80105e7f <sys_dup+0x43>
    return -1;
80105e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7d:	eb 12                	jmp    80105e91 <sys_dup+0x55>
  filedup(f);
80105e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e82:	83 ec 0c             	sub    $0xc,%esp
80105e85:	50                   	push   %eax
80105e86:	e8 75 b1 ff ff       	call   80101000 <filedup>
80105e8b:	83 c4 10             	add    $0x10,%esp
  return fd;
80105e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e91:	c9                   	leave  
80105e92:	c3                   	ret    

80105e93 <sys_read>:

int
sys_read(void)
{
80105e93:	55                   	push   %ebp
80105e94:	89 e5                	mov    %esp,%ebp
80105e96:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105e99:	83 ec 04             	sub    $0x4,%esp
80105e9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e9f:	50                   	push   %eax
80105ea0:	6a 00                	push   $0x0
80105ea2:	6a 00                	push   $0x0
80105ea4:	e8 d2 fe ff ff       	call   80105d7b <argfd>
80105ea9:	83 c4 10             	add    $0x10,%esp
80105eac:	85 c0                	test   %eax,%eax
80105eae:	78 2e                	js     80105ede <sys_read+0x4b>
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	6a 02                	push   $0x2
80105eb9:	e8 81 fd ff ff       	call   80105c3f <argint>
80105ebe:	83 c4 10             	add    $0x10,%esp
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	78 19                	js     80105ede <sys_read+0x4b>
80105ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec8:	83 ec 04             	sub    $0x4,%esp
80105ecb:	50                   	push   %eax
80105ecc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ecf:	50                   	push   %eax
80105ed0:	6a 01                	push   $0x1
80105ed2:	e8 90 fd ff ff       	call   80105c67 <argptr>
80105ed7:	83 c4 10             	add    $0x10,%esp
80105eda:	85 c0                	test   %eax,%eax
80105edc:	79 07                	jns    80105ee5 <sys_read+0x52>
    return -1;
80105ede:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee3:	eb 17                	jmp    80105efc <sys_read+0x69>
  return fileread(f, p, n);
80105ee5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ee8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eee:	83 ec 04             	sub    $0x4,%esp
80105ef1:	51                   	push   %ecx
80105ef2:	52                   	push   %edx
80105ef3:	50                   	push   %eax
80105ef4:	e8 99 b2 ff ff       	call   80101192 <fileread>
80105ef9:	83 c4 10             	add    $0x10,%esp
}
80105efc:	c9                   	leave  
80105efd:	c3                   	ret    

80105efe <sys_write>:

int
sys_write(void)
{
80105efe:	55                   	push   %ebp
80105eff:	89 e5                	mov    %esp,%ebp
80105f01:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105f04:	83 ec 04             	sub    $0x4,%esp
80105f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f0a:	50                   	push   %eax
80105f0b:	6a 00                	push   $0x0
80105f0d:	6a 00                	push   $0x0
80105f0f:	e8 67 fe ff ff       	call   80105d7b <argfd>
80105f14:	83 c4 10             	add    $0x10,%esp
80105f17:	85 c0                	test   %eax,%eax
80105f19:	78 2e                	js     80105f49 <sys_write+0x4b>
80105f1b:	83 ec 08             	sub    $0x8,%esp
80105f1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f21:	50                   	push   %eax
80105f22:	6a 02                	push   $0x2
80105f24:	e8 16 fd ff ff       	call   80105c3f <argint>
80105f29:	83 c4 10             	add    $0x10,%esp
80105f2c:	85 c0                	test   %eax,%eax
80105f2e:	78 19                	js     80105f49 <sys_write+0x4b>
80105f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f33:	83 ec 04             	sub    $0x4,%esp
80105f36:	50                   	push   %eax
80105f37:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f3a:	50                   	push   %eax
80105f3b:	6a 01                	push   $0x1
80105f3d:	e8 25 fd ff ff       	call   80105c67 <argptr>
80105f42:	83 c4 10             	add    $0x10,%esp
80105f45:	85 c0                	test   %eax,%eax
80105f47:	79 07                	jns    80105f50 <sys_write+0x52>
    return -1;
80105f49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f4e:	eb 17                	jmp    80105f67 <sys_write+0x69>
  return filewrite(f, p, n);
80105f50:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105f53:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f59:	83 ec 04             	sub    $0x4,%esp
80105f5c:	51                   	push   %ecx
80105f5d:	52                   	push   %edx
80105f5e:	50                   	push   %eax
80105f5f:	e8 e6 b2 ff ff       	call   8010124a <filewrite>
80105f64:	83 c4 10             	add    $0x10,%esp
}
80105f67:	c9                   	leave  
80105f68:	c3                   	ret    

80105f69 <sys_close>:

int
sys_close(void)
{
80105f69:	55                   	push   %ebp
80105f6a:	89 e5                	mov    %esp,%ebp
80105f6c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105f6f:	83 ec 04             	sub    $0x4,%esp
80105f72:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f75:	50                   	push   %eax
80105f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f79:	50                   	push   %eax
80105f7a:	6a 00                	push   $0x0
80105f7c:	e8 fa fd ff ff       	call   80105d7b <argfd>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	85 c0                	test   %eax,%eax
80105f86:	79 07                	jns    80105f8f <sys_close+0x26>
    return -1;
80105f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8d:	eb 28                	jmp    80105fb7 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105f8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f98:	83 c2 08             	add    $0x8,%edx
80105f9b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fa2:	00 
  fileclose(f);
80105fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa6:	83 ec 0c             	sub    $0xc,%esp
80105fa9:	50                   	push   %eax
80105faa:	e8 a2 b0 ff ff       	call   80101051 <fileclose>
80105faf:	83 c4 10             	add    $0x10,%esp
  return 0;
80105fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fb7:	c9                   	leave  
80105fb8:	c3                   	ret    

80105fb9 <sys_fstat>:

int
sys_fstat(void)
{
80105fb9:	55                   	push   %ebp
80105fba:	89 e5                	mov    %esp,%ebp
80105fbc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105fbf:	83 ec 04             	sub    $0x4,%esp
80105fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fc5:	50                   	push   %eax
80105fc6:	6a 00                	push   $0x0
80105fc8:	6a 00                	push   $0x0
80105fca:	e8 ac fd ff ff       	call   80105d7b <argfd>
80105fcf:	83 c4 10             	add    $0x10,%esp
80105fd2:	85 c0                	test   %eax,%eax
80105fd4:	78 17                	js     80105fed <sys_fstat+0x34>
80105fd6:	83 ec 04             	sub    $0x4,%esp
80105fd9:	6a 14                	push   $0x14
80105fdb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fde:	50                   	push   %eax
80105fdf:	6a 01                	push   $0x1
80105fe1:	e8 81 fc ff ff       	call   80105c67 <argptr>
80105fe6:	83 c4 10             	add    $0x10,%esp
80105fe9:	85 c0                	test   %eax,%eax
80105feb:	79 07                	jns    80105ff4 <sys_fstat+0x3b>
    return -1;
80105fed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff2:	eb 13                	jmp    80106007 <sys_fstat+0x4e>
  return filestat(f, st);
80105ff4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffa:	83 ec 08             	sub    $0x8,%esp
80105ffd:	52                   	push   %edx
80105ffe:	50                   	push   %eax
80105fff:	e8 37 b1 ff ff       	call   8010113b <filestat>
80106004:	83 c4 10             	add    $0x10,%esp
}
80106007:	c9                   	leave  
80106008:	c3                   	ret    

80106009 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106009:	55                   	push   %ebp
8010600a:	89 e5                	mov    %esp,%ebp
8010600c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010600f:	83 ec 08             	sub    $0x8,%esp
80106012:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106015:	50                   	push   %eax
80106016:	6a 00                	push   $0x0
80106018:	e8 a7 fc ff ff       	call   80105cc4 <argstr>
8010601d:	83 c4 10             	add    $0x10,%esp
80106020:	85 c0                	test   %eax,%eax
80106022:	78 15                	js     80106039 <sys_link+0x30>
80106024:	83 ec 08             	sub    $0x8,%esp
80106027:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010602a:	50                   	push   %eax
8010602b:	6a 01                	push   $0x1
8010602d:	e8 92 fc ff ff       	call   80105cc4 <argstr>
80106032:	83 c4 10             	add    $0x10,%esp
80106035:	85 c0                	test   %eax,%eax
80106037:	79 0a                	jns    80106043 <sys_link+0x3a>
    return -1;
80106039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603e:	e9 68 01 00 00       	jmp    801061ab <sys_link+0x1a2>

  begin_op();
80106043:	e8 9d db ff ff       	call   80103be5 <begin_op>
  if((ip = namei(old)) == 0){
80106048:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010604b:	83 ec 0c             	sub    $0xc,%esp
8010604e:	50                   	push   %eax
8010604f:	e8 39 cb ff ff       	call   80102b8d <namei>
80106054:	83 c4 10             	add    $0x10,%esp
80106057:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010605a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010605e:	75 0f                	jne    8010606f <sys_link+0x66>
    end_op();
80106060:	e8 0c dc ff ff       	call   80103c71 <end_op>
    return -1;
80106065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606a:	e9 3c 01 00 00       	jmp    801061ab <sys_link+0x1a2>
  }

  ilock(ip);
8010606f:	83 ec 0c             	sub    $0xc,%esp
80106072:	ff 75 f4             	pushl  -0xc(%ebp)
80106075:	e8 9a bd ff ff       	call   80101e14 <ilock>
8010607a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010607d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106080:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106084:	66 83 f8 01          	cmp    $0x1,%ax
80106088:	75 1d                	jne    801060a7 <sys_link+0x9e>
    iunlockput(ip);
8010608a:	83 ec 0c             	sub    $0xc,%esp
8010608d:	ff 75 f4             	pushl  -0xc(%ebp)
80106090:	e8 82 c0 ff ff       	call   80102117 <iunlockput>
80106095:	83 c4 10             	add    $0x10,%esp
    end_op();
80106098:	e8 d4 db ff ff       	call   80103c71 <end_op>
    return -1;
8010609d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a2:	e9 04 01 00 00       	jmp    801061ab <sys_link+0x1a2>
  }

  ip->nlink++;
801060a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060aa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060ae:	83 c0 01             	add    $0x1,%eax
801060b1:	89 c2                	mov    %eax,%edx
801060b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b6:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801060ba:	83 ec 0c             	sub    $0xc,%esp
801060bd:	ff 75 f4             	pushl  -0xc(%ebp)
801060c0:	e8 fb ba ff ff       	call   80101bc0 <iupdate>
801060c5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801060c8:	83 ec 0c             	sub    $0xc,%esp
801060cb:	ff 75 f4             	pushl  -0xc(%ebp)
801060ce:	e8 e2 be ff ff       	call   80101fb5 <iunlock>
801060d3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801060d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801060d9:	83 ec 08             	sub    $0x8,%esp
801060dc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801060df:	52                   	push   %edx
801060e0:	50                   	push   %eax
801060e1:	e8 c3 ca ff ff       	call   80102ba9 <nameiparent>
801060e6:	83 c4 10             	add    $0x10,%esp
801060e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060f0:	74 71                	je     80106163 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801060f2:	83 ec 0c             	sub    $0xc,%esp
801060f5:	ff 75 f0             	pushl  -0x10(%ebp)
801060f8:	e8 17 bd ff ff       	call   80101e14 <ilock>
801060fd:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106103:	8b 10                	mov    (%eax),%edx
80106105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106108:	8b 00                	mov    (%eax),%eax
8010610a:	39 c2                	cmp    %eax,%edx
8010610c:	75 1d                	jne    8010612b <sys_link+0x122>
8010610e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106111:	8b 40 04             	mov    0x4(%eax),%eax
80106114:	83 ec 04             	sub    $0x4,%esp
80106117:	50                   	push   %eax
80106118:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010611b:	50                   	push   %eax
8010611c:	ff 75 f0             	pushl  -0x10(%ebp)
8010611f:	e8 c7 c7 ff ff       	call   801028eb <dirlink>
80106124:	83 c4 10             	add    $0x10,%esp
80106127:	85 c0                	test   %eax,%eax
80106129:	79 10                	jns    8010613b <sys_link+0x132>
    iunlockput(dp);
8010612b:	83 ec 0c             	sub    $0xc,%esp
8010612e:	ff 75 f0             	pushl  -0x10(%ebp)
80106131:	e8 e1 bf ff ff       	call   80102117 <iunlockput>
80106136:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106139:	eb 29                	jmp    80106164 <sys_link+0x15b>
  }
  iunlockput(dp);
8010613b:	83 ec 0c             	sub    $0xc,%esp
8010613e:	ff 75 f0             	pushl  -0x10(%ebp)
80106141:	e8 d1 bf ff ff       	call   80102117 <iunlockput>
80106146:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106149:	83 ec 0c             	sub    $0xc,%esp
8010614c:	ff 75 f4             	pushl  -0xc(%ebp)
8010614f:	e8 d3 be ff ff       	call   80102027 <iput>
80106154:	83 c4 10             	add    $0x10,%esp

  end_op();
80106157:	e8 15 db ff ff       	call   80103c71 <end_op>

  return 0;
8010615c:	b8 00 00 00 00       	mov    $0x0,%eax
80106161:	eb 48                	jmp    801061ab <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106163:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106164:	83 ec 0c             	sub    $0xc,%esp
80106167:	ff 75 f4             	pushl  -0xc(%ebp)
8010616a:	e8 a5 bc ff ff       	call   80101e14 <ilock>
8010616f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106175:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106179:	83 e8 01             	sub    $0x1,%eax
8010617c:	89 c2                	mov    %eax,%edx
8010617e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106181:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106185:	83 ec 0c             	sub    $0xc,%esp
80106188:	ff 75 f4             	pushl  -0xc(%ebp)
8010618b:	e8 30 ba ff ff       	call   80101bc0 <iupdate>
80106190:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106193:	83 ec 0c             	sub    $0xc,%esp
80106196:	ff 75 f4             	pushl  -0xc(%ebp)
80106199:	e8 79 bf ff ff       	call   80102117 <iunlockput>
8010619e:	83 c4 10             	add    $0x10,%esp
  end_op();
801061a1:	e8 cb da ff ff       	call   80103c71 <end_op>
  return -1;
801061a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061ab:	c9                   	leave  
801061ac:	c3                   	ret    

801061ad <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801061ad:	55                   	push   %ebp
801061ae:	89 e5                	mov    %esp,%ebp
801061b0:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801061b3:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801061ba:	eb 40                	jmp    801061fc <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801061bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bf:	6a 10                	push   $0x10
801061c1:	50                   	push   %eax
801061c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061c5:	50                   	push   %eax
801061c6:	ff 75 08             	pushl  0x8(%ebp)
801061c9:	e8 ca c2 ff ff       	call   80102498 <readi>
801061ce:	83 c4 10             	add    $0x10,%esp
801061d1:	83 f8 10             	cmp    $0x10,%eax
801061d4:	74 0d                	je     801061e3 <isdirempty+0x36>
      panic("isdirempty: readi");
801061d6:	83 ec 0c             	sub    $0xc,%esp
801061d9:	68 2c 91 10 80       	push   $0x8010912c
801061de:	e8 83 a3 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801061e3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801061e7:	66 85 c0             	test   %ax,%ax
801061ea:	74 07                	je     801061f3 <isdirempty+0x46>
      return 0;
801061ec:	b8 00 00 00 00       	mov    $0x0,%eax
801061f1:	eb 1b                	jmp    8010620e <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801061f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f6:	83 c0 10             	add    $0x10,%eax
801061f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061fc:	8b 45 08             	mov    0x8(%ebp),%eax
801061ff:	8b 50 18             	mov    0x18(%eax),%edx
80106202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106205:	39 c2                	cmp    %eax,%edx
80106207:	77 b3                	ja     801061bc <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106209:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010620e:	c9                   	leave  
8010620f:	c3                   	ret    

80106210 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106210:	55                   	push   %ebp
80106211:	89 e5                	mov    %esp,%ebp
80106213:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106216:	83 ec 08             	sub    $0x8,%esp
80106219:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010621c:	50                   	push   %eax
8010621d:	6a 00                	push   $0x0
8010621f:	e8 a0 fa ff ff       	call   80105cc4 <argstr>
80106224:	83 c4 10             	add    $0x10,%esp
80106227:	85 c0                	test   %eax,%eax
80106229:	79 0a                	jns    80106235 <sys_unlink+0x25>
    return -1;
8010622b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106230:	e9 bc 01 00 00       	jmp    801063f1 <sys_unlink+0x1e1>

  begin_op();
80106235:	e8 ab d9 ff ff       	call   80103be5 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010623a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010623d:	83 ec 08             	sub    $0x8,%esp
80106240:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106243:	52                   	push   %edx
80106244:	50                   	push   %eax
80106245:	e8 5f c9 ff ff       	call   80102ba9 <nameiparent>
8010624a:	83 c4 10             	add    $0x10,%esp
8010624d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106250:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106254:	75 0f                	jne    80106265 <sys_unlink+0x55>
    end_op();
80106256:	e8 16 da ff ff       	call   80103c71 <end_op>
    return -1;
8010625b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106260:	e9 8c 01 00 00       	jmp    801063f1 <sys_unlink+0x1e1>
  }

  ilock(dp);
80106265:	83 ec 0c             	sub    $0xc,%esp
80106268:	ff 75 f4             	pushl  -0xc(%ebp)
8010626b:	e8 a4 bb ff ff       	call   80101e14 <ilock>
80106270:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106273:	83 ec 08             	sub    $0x8,%esp
80106276:	68 3e 91 10 80       	push   $0x8010913e
8010627b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010627e:	50                   	push   %eax
8010627f:	e8 85 c5 ff ff       	call   80102809 <namecmp>
80106284:	83 c4 10             	add    $0x10,%esp
80106287:	85 c0                	test   %eax,%eax
80106289:	0f 84 4a 01 00 00    	je     801063d9 <sys_unlink+0x1c9>
8010628f:	83 ec 08             	sub    $0x8,%esp
80106292:	68 40 91 10 80       	push   $0x80109140
80106297:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010629a:	50                   	push   %eax
8010629b:	e8 69 c5 ff ff       	call   80102809 <namecmp>
801062a0:	83 c4 10             	add    $0x10,%esp
801062a3:	85 c0                	test   %eax,%eax
801062a5:	0f 84 2e 01 00 00    	je     801063d9 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801062ab:	83 ec 04             	sub    $0x4,%esp
801062ae:	8d 45 c8             	lea    -0x38(%ebp),%eax
801062b1:	50                   	push   %eax
801062b2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801062b5:	50                   	push   %eax
801062b6:	ff 75 f4             	pushl  -0xc(%ebp)
801062b9:	e8 66 c5 ff ff       	call   80102824 <dirlookup>
801062be:	83 c4 10             	add    $0x10,%esp
801062c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062c8:	0f 84 0a 01 00 00    	je     801063d8 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801062ce:	83 ec 0c             	sub    $0xc,%esp
801062d1:	ff 75 f0             	pushl  -0x10(%ebp)
801062d4:	e8 3b bb ff ff       	call   80101e14 <ilock>
801062d9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801062dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062df:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062e3:	66 85 c0             	test   %ax,%ax
801062e6:	7f 0d                	jg     801062f5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801062e8:	83 ec 0c             	sub    $0xc,%esp
801062eb:	68 43 91 10 80       	push   $0x80109143
801062f0:	e8 71 a2 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801062f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062fc:	66 83 f8 01          	cmp    $0x1,%ax
80106300:	75 25                	jne    80106327 <sys_unlink+0x117>
80106302:	83 ec 0c             	sub    $0xc,%esp
80106305:	ff 75 f0             	pushl  -0x10(%ebp)
80106308:	e8 a0 fe ff ff       	call   801061ad <isdirempty>
8010630d:	83 c4 10             	add    $0x10,%esp
80106310:	85 c0                	test   %eax,%eax
80106312:	75 13                	jne    80106327 <sys_unlink+0x117>
    iunlockput(ip);
80106314:	83 ec 0c             	sub    $0xc,%esp
80106317:	ff 75 f0             	pushl  -0x10(%ebp)
8010631a:	e8 f8 bd ff ff       	call   80102117 <iunlockput>
8010631f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106322:	e9 b2 00 00 00       	jmp    801063d9 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106327:	83 ec 04             	sub    $0x4,%esp
8010632a:	6a 10                	push   $0x10
8010632c:	6a 00                	push   $0x0
8010632e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106331:	50                   	push   %eax
80106332:	e8 e3 f5 ff ff       	call   8010591a <memset>
80106337:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010633a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010633d:	6a 10                	push   $0x10
8010633f:	50                   	push   %eax
80106340:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106343:	50                   	push   %eax
80106344:	ff 75 f4             	pushl  -0xc(%ebp)
80106347:	e8 ec c2 ff ff       	call   80102638 <writei>
8010634c:	83 c4 10             	add    $0x10,%esp
8010634f:	83 f8 10             	cmp    $0x10,%eax
80106352:	74 0d                	je     80106361 <sys_unlink+0x151>
    panic("unlink: writei");
80106354:	83 ec 0c             	sub    $0xc,%esp
80106357:	68 55 91 10 80       	push   $0x80109155
8010635c:	e8 05 a2 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106361:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106364:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106368:	66 83 f8 01          	cmp    $0x1,%ax
8010636c:	75 21                	jne    8010638f <sys_unlink+0x17f>
    dp->nlink--;
8010636e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106371:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106375:	83 e8 01             	sub    $0x1,%eax
80106378:	89 c2                	mov    %eax,%edx
8010637a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106381:	83 ec 0c             	sub    $0xc,%esp
80106384:	ff 75 f4             	pushl  -0xc(%ebp)
80106387:	e8 34 b8 ff ff       	call   80101bc0 <iupdate>
8010638c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010638f:	83 ec 0c             	sub    $0xc,%esp
80106392:	ff 75 f4             	pushl  -0xc(%ebp)
80106395:	e8 7d bd ff ff       	call   80102117 <iunlockput>
8010639a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010639d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801063a4:	83 e8 01             	sub    $0x1,%eax
801063a7:	89 c2                	mov    %eax,%edx
801063a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ac:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801063b0:	83 ec 0c             	sub    $0xc,%esp
801063b3:	ff 75 f0             	pushl  -0x10(%ebp)
801063b6:	e8 05 b8 ff ff       	call   80101bc0 <iupdate>
801063bb:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801063be:	83 ec 0c             	sub    $0xc,%esp
801063c1:	ff 75 f0             	pushl  -0x10(%ebp)
801063c4:	e8 4e bd ff ff       	call   80102117 <iunlockput>
801063c9:	83 c4 10             	add    $0x10,%esp

  end_op();
801063cc:	e8 a0 d8 ff ff       	call   80103c71 <end_op>

  return 0;
801063d1:	b8 00 00 00 00       	mov    $0x0,%eax
801063d6:	eb 19                	jmp    801063f1 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801063d8:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801063d9:	83 ec 0c             	sub    $0xc,%esp
801063dc:	ff 75 f4             	pushl  -0xc(%ebp)
801063df:	e8 33 bd ff ff       	call   80102117 <iunlockput>
801063e4:	83 c4 10             	add    $0x10,%esp
  end_op();
801063e7:	e8 85 d8 ff ff       	call   80103c71 <end_op>
  return -1;
801063ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801063f1:	c9                   	leave  
801063f2:	c3                   	ret    

801063f3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801063f3:	55                   	push   %ebp
801063f4:	89 e5                	mov    %esp,%ebp
801063f6:	83 ec 38             	sub    $0x38,%esp
801063f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801063fc:	8b 55 10             	mov    0x10(%ebp),%edx
801063ff:	8b 45 14             	mov    0x14(%ebp),%eax
80106402:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106406:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010640a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];
//cprintf("path %d  \n",path);
  if((dp = nameiparent(path, name)) == 0)
8010640e:	83 ec 08             	sub    $0x8,%esp
80106411:	8d 45 de             	lea    -0x22(%ebp),%eax
80106414:	50                   	push   %eax
80106415:	ff 75 08             	pushl  0x8(%ebp)
80106418:	e8 8c c7 ff ff       	call   80102ba9 <nameiparent>
8010641d:	83 c4 10             	add    $0x10,%esp
80106420:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106423:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106427:	75 0a                	jne    80106433 <create+0x40>
    return 0;
80106429:	b8 00 00 00 00       	mov    $0x0,%eax
8010642e:	e9 9c 01 00 00       	jmp    801065cf <create+0x1dc>
  ilock(dp);
80106433:	83 ec 0c             	sub    $0xc,%esp
80106436:	ff 75 f4             	pushl  -0xc(%ebp)
80106439:	e8 d6 b9 ff ff       	call   80101e14 <ilock>
8010643e:	83 c4 10             	add    $0x10,%esp
  

  if((ip = dirlookup(dp, name, &off)) != 0){
80106441:	83 ec 04             	sub    $0x4,%esp
80106444:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106447:	50                   	push   %eax
80106448:	8d 45 de             	lea    -0x22(%ebp),%eax
8010644b:	50                   	push   %eax
8010644c:	ff 75 f4             	pushl  -0xc(%ebp)
8010644f:	e8 d0 c3 ff ff       	call   80102824 <dirlookup>
80106454:	83 c4 10             	add    $0x10,%esp
80106457:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010645a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010645e:	74 50                	je     801064b0 <create+0xbd>
    iunlockput(dp);
80106460:	83 ec 0c             	sub    $0xc,%esp
80106463:	ff 75 f4             	pushl  -0xc(%ebp)
80106466:	e8 ac bc ff ff       	call   80102117 <iunlockput>
8010646b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010646e:	83 ec 0c             	sub    $0xc,%esp
80106471:	ff 75 f0             	pushl  -0x10(%ebp)
80106474:	e8 9b b9 ff ff       	call   80101e14 <ilock>
80106479:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010647c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106481:	75 15                	jne    80106498 <create+0xa5>
80106483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106486:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010648a:	66 83 f8 02          	cmp    $0x2,%ax
8010648e:	75 08                	jne    80106498 <create+0xa5>
      return ip;
80106490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106493:	e9 37 01 00 00       	jmp    801065cf <create+0x1dc>
    iunlockput(ip);
80106498:	83 ec 0c             	sub    $0xc,%esp
8010649b:	ff 75 f0             	pushl  -0x10(%ebp)
8010649e:	e8 74 bc ff ff       	call   80102117 <iunlockput>
801064a3:	83 c4 10             	add    $0x10,%esp
    return 0;
801064a6:	b8 00 00 00 00       	mov    $0x0,%eax
801064ab:	e9 1f 01 00 00       	jmp    801065cf <create+0x1dc>
  }
  if((ip = ialloc(dp->dev, type,dp->part->number)) == 0)
801064b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b3:	8b 40 50             	mov    0x50(%eax),%eax
801064b6:	8b 40 14             	mov    0x14(%eax),%eax
801064b9:	89 c1                	mov    %eax,%ecx
801064bb:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801064bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c2:	8b 00                	mov    (%eax),%eax
801064c4:	83 ec 04             	sub    $0x4,%esp
801064c7:	51                   	push   %ecx
801064c8:	52                   	push   %edx
801064c9:	50                   	push   %eax
801064ca:	e8 dc b5 ff ff       	call   80101aab <ialloc>
801064cf:	83 c4 10             	add    $0x10,%esp
801064d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064d9:	75 0d                	jne    801064e8 <create+0xf5>
    panic("create: ialloc");
801064db:	83 ec 0c             	sub    $0xc,%esp
801064de:	68 64 91 10 80       	push   $0x80109164
801064e3:	e8 7e a0 ff ff       	call   80100566 <panic>

  ilock(ip);
801064e8:	83 ec 0c             	sub    $0xc,%esp
801064eb:	ff 75 f0             	pushl  -0x10(%ebp)
801064ee:	e8 21 b9 ff ff       	call   80101e14 <ilock>
801064f3:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801064f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f9:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801064fd:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106501:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106504:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106508:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010650c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106515:	83 ec 0c             	sub    $0xc,%esp
80106518:	ff 75 f0             	pushl  -0x10(%ebp)
8010651b:	e8 a0 b6 ff ff       	call   80101bc0 <iupdate>
80106520:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106523:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106528:	75 6a                	jne    80106594 <create+0x1a1>
    dp->nlink++;  // for ".."
8010652a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106531:	83 c0 01             	add    $0x1,%eax
80106534:	89 c2                	mov    %eax,%edx
80106536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106539:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010653d:	83 ec 0c             	sub    $0xc,%esp
80106540:	ff 75 f4             	pushl  -0xc(%ebp)
80106543:	e8 78 b6 ff ff       	call   80101bc0 <iupdate>
80106548:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010654b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010654e:	8b 40 04             	mov    0x4(%eax),%eax
80106551:	83 ec 04             	sub    $0x4,%esp
80106554:	50                   	push   %eax
80106555:	68 3e 91 10 80       	push   $0x8010913e
8010655a:	ff 75 f0             	pushl  -0x10(%ebp)
8010655d:	e8 89 c3 ff ff       	call   801028eb <dirlink>
80106562:	83 c4 10             	add    $0x10,%esp
80106565:	85 c0                	test   %eax,%eax
80106567:	78 1e                	js     80106587 <create+0x194>
80106569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656c:	8b 40 04             	mov    0x4(%eax),%eax
8010656f:	83 ec 04             	sub    $0x4,%esp
80106572:	50                   	push   %eax
80106573:	68 40 91 10 80       	push   $0x80109140
80106578:	ff 75 f0             	pushl  -0x10(%ebp)
8010657b:	e8 6b c3 ff ff       	call   801028eb <dirlink>
80106580:	83 c4 10             	add    $0x10,%esp
80106583:	85 c0                	test   %eax,%eax
80106585:	79 0d                	jns    80106594 <create+0x1a1>
      panic("create dots");
80106587:	83 ec 0c             	sub    $0xc,%esp
8010658a:	68 73 91 10 80       	push   $0x80109173
8010658f:	e8 d2 9f ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106597:	8b 40 04             	mov    0x4(%eax),%eax
8010659a:	83 ec 04             	sub    $0x4,%esp
8010659d:	50                   	push   %eax
8010659e:	8d 45 de             	lea    -0x22(%ebp),%eax
801065a1:	50                   	push   %eax
801065a2:	ff 75 f4             	pushl  -0xc(%ebp)
801065a5:	e8 41 c3 ff ff       	call   801028eb <dirlink>
801065aa:	83 c4 10             	add    $0x10,%esp
801065ad:	85 c0                	test   %eax,%eax
801065af:	79 0d                	jns    801065be <create+0x1cb>
    panic("create: dirlink");
801065b1:	83 ec 0c             	sub    $0xc,%esp
801065b4:	68 7f 91 10 80       	push   $0x8010917f
801065b9:	e8 a8 9f ff ff       	call   80100566 <panic>

  iunlockput(dp);
801065be:	83 ec 0c             	sub    $0xc,%esp
801065c1:	ff 75 f4             	pushl  -0xc(%ebp)
801065c4:	e8 4e bb ff ff       	call   80102117 <iunlockput>
801065c9:	83 c4 10             	add    $0x10,%esp

  return ip;
801065cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801065cf:	c9                   	leave  
801065d0:	c3                   	ret    

801065d1 <sys_open>:

int
sys_open(void)
{
801065d1:	55                   	push   %ebp
801065d2:	89 e5                	mov    %esp,%ebp
801065d4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801065d7:	83 ec 08             	sub    $0x8,%esp
801065da:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065dd:	50                   	push   %eax
801065de:	6a 00                	push   $0x0
801065e0:	e8 df f6 ff ff       	call   80105cc4 <argstr>
801065e5:	83 c4 10             	add    $0x10,%esp
801065e8:	85 c0                	test   %eax,%eax
801065ea:	78 15                	js     80106601 <sys_open+0x30>
801065ec:	83 ec 08             	sub    $0x8,%esp
801065ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065f2:	50                   	push   %eax
801065f3:	6a 01                	push   $0x1
801065f5:	e8 45 f6 ff ff       	call   80105c3f <argint>
801065fa:	83 c4 10             	add    $0x10,%esp
801065fd:	85 c0                	test   %eax,%eax
801065ff:	79 0a                	jns    8010660b <sys_open+0x3a>
    return -1;
80106601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106606:	e9 61 01 00 00       	jmp    8010676c <sys_open+0x19b>

  begin_op();
8010660b:	e8 d5 d5 ff ff       	call   80103be5 <begin_op>

  if(omode & O_CREATE){
80106610:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106613:	25 00 02 00 00       	and    $0x200,%eax
80106618:	85 c0                	test   %eax,%eax
8010661a:	74 2a                	je     80106646 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010661c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010661f:	6a 00                	push   $0x0
80106621:	6a 00                	push   $0x0
80106623:	6a 02                	push   $0x2
80106625:	50                   	push   %eax
80106626:	e8 c8 fd ff ff       	call   801063f3 <create>
8010662b:	83 c4 10             	add    $0x10,%esp
8010662e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106631:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106635:	75 75                	jne    801066ac <sys_open+0xdb>
      end_op();
80106637:	e8 35 d6 ff ff       	call   80103c71 <end_op>
      return -1;
8010663c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106641:	e9 26 01 00 00       	jmp    8010676c <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106646:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106649:	83 ec 0c             	sub    $0xc,%esp
8010664c:	50                   	push   %eax
8010664d:	e8 3b c5 ff ff       	call   80102b8d <namei>
80106652:	83 c4 10             	add    $0x10,%esp
80106655:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106658:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010665c:	75 0f                	jne    8010666d <sys_open+0x9c>
      end_op();
8010665e:	e8 0e d6 ff ff       	call   80103c71 <end_op>
      return -1;
80106663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106668:	e9 ff 00 00 00       	jmp    8010676c <sys_open+0x19b>
    }
    ilock(ip);
8010666d:	83 ec 0c             	sub    $0xc,%esp
80106670:	ff 75 f4             	pushl  -0xc(%ebp)
80106673:	e8 9c b7 ff ff       	call   80101e14 <ilock>
80106678:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010667b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106682:	66 83 f8 01          	cmp    $0x1,%ax
80106686:	75 24                	jne    801066ac <sys_open+0xdb>
80106688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010668b:	85 c0                	test   %eax,%eax
8010668d:	74 1d                	je     801066ac <sys_open+0xdb>
      iunlockput(ip);
8010668f:	83 ec 0c             	sub    $0xc,%esp
80106692:	ff 75 f4             	pushl  -0xc(%ebp)
80106695:	e8 7d ba ff ff       	call   80102117 <iunlockput>
8010669a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010669d:	e8 cf d5 ff ff       	call   80103c71 <end_op>
      return -1;
801066a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a7:	e9 c0 00 00 00       	jmp    8010676c <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801066ac:	e8 e2 a8 ff ff       	call   80100f93 <filealloc>
801066b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066b8:	74 17                	je     801066d1 <sys_open+0x100>
801066ba:	83 ec 0c             	sub    $0xc,%esp
801066bd:	ff 75 f0             	pushl  -0x10(%ebp)
801066c0:	e8 2b f7 ff ff       	call   80105df0 <fdalloc>
801066c5:	83 c4 10             	add    $0x10,%esp
801066c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801066cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801066cf:	79 2e                	jns    801066ff <sys_open+0x12e>
    if(f)
801066d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066d5:	74 0e                	je     801066e5 <sys_open+0x114>
      fileclose(f);
801066d7:	83 ec 0c             	sub    $0xc,%esp
801066da:	ff 75 f0             	pushl  -0x10(%ebp)
801066dd:	e8 6f a9 ff ff       	call   80101051 <fileclose>
801066e2:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066e5:	83 ec 0c             	sub    $0xc,%esp
801066e8:	ff 75 f4             	pushl  -0xc(%ebp)
801066eb:	e8 27 ba ff ff       	call   80102117 <iunlockput>
801066f0:	83 c4 10             	add    $0x10,%esp
    end_op();
801066f3:	e8 79 d5 ff ff       	call   80103c71 <end_op>
    return -1;
801066f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fd:	eb 6d                	jmp    8010676c <sys_open+0x19b>
  }
  iunlock(ip);
801066ff:	83 ec 0c             	sub    $0xc,%esp
80106702:	ff 75 f4             	pushl  -0xc(%ebp)
80106705:	e8 ab b8 ff ff       	call   80101fb5 <iunlock>
8010670a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010670d:	e8 5f d5 ff ff       	call   80103c71 <end_op>

  f->type = FD_INODE;
80106712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106715:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010671b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010671e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106721:	89 50 0e             	mov    %edx,0xe(%eax)
  f->off = 0;
80106724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106727:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
  f->readable = !(omode & O_WRONLY);
8010672e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106731:	83 e0 01             	and    $0x1,%eax
80106734:	85 c0                	test   %eax,%eax
80106736:	0f 94 c0             	sete   %al
80106739:	89 c2                	mov    %eax,%edx
8010673b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106741:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106744:	83 e0 01             	and    $0x1,%eax
80106747:	85 c0                	test   %eax,%eax
80106749:	75 0a                	jne    80106755 <sys_open+0x184>
8010674b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010674e:	83 e0 02             	and    $0x2,%eax
80106751:	85 c0                	test   %eax,%eax
80106753:	74 07                	je     8010675c <sys_open+0x18b>
80106755:	b8 01 00 00 00       	mov    $0x1,%eax
8010675a:	eb 05                	jmp    80106761 <sys_open+0x190>
8010675c:	b8 00 00 00 00       	mov    $0x0,%eax
80106761:	89 c2                	mov    %eax,%edx
80106763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106766:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106769:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010676c:	c9                   	leave  
8010676d:	c3                   	ret    

8010676e <sys_mkdir>:

int
sys_mkdir(void)
{
8010676e:	55                   	push   %ebp
8010676f:	89 e5                	mov    %esp,%ebp
80106771:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106774:	e8 6c d4 ff ff       	call   80103be5 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106779:	83 ec 08             	sub    $0x8,%esp
8010677c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010677f:	50                   	push   %eax
80106780:	6a 00                	push   $0x0
80106782:	e8 3d f5 ff ff       	call   80105cc4 <argstr>
80106787:	83 c4 10             	add    $0x10,%esp
8010678a:	85 c0                	test   %eax,%eax
8010678c:	78 1b                	js     801067a9 <sys_mkdir+0x3b>
8010678e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106791:	6a 00                	push   $0x0
80106793:	6a 00                	push   $0x0
80106795:	6a 01                	push   $0x1
80106797:	50                   	push   %eax
80106798:	e8 56 fc ff ff       	call   801063f3 <create>
8010679d:	83 c4 10             	add    $0x10,%esp
801067a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a7:	75 0c                	jne    801067b5 <sys_mkdir+0x47>
    end_op();
801067a9:	e8 c3 d4 ff ff       	call   80103c71 <end_op>
    return -1;
801067ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b3:	eb 18                	jmp    801067cd <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801067b5:	83 ec 0c             	sub    $0xc,%esp
801067b8:	ff 75 f4             	pushl  -0xc(%ebp)
801067bb:	e8 57 b9 ff ff       	call   80102117 <iunlockput>
801067c0:	83 c4 10             	add    $0x10,%esp
  end_op();
801067c3:	e8 a9 d4 ff ff       	call   80103c71 <end_op>
  return 0;
801067c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067cd:	c9                   	leave  
801067ce:	c3                   	ret    

801067cf <sys_mknod>:

int
sys_mknod(void)
{
801067cf:	55                   	push   %ebp
801067d0:	89 e5                	mov    %esp,%ebp
801067d2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801067d5:	e8 0b d4 ff ff       	call   80103be5 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801067da:	83 ec 08             	sub    $0x8,%esp
801067dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067e0:	50                   	push   %eax
801067e1:	6a 00                	push   $0x0
801067e3:	e8 dc f4 ff ff       	call   80105cc4 <argstr>
801067e8:	83 c4 10             	add    $0x10,%esp
801067eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067f2:	78 4f                	js     80106843 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801067f4:	83 ec 08             	sub    $0x8,%esp
801067f7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801067fa:	50                   	push   %eax
801067fb:	6a 01                	push   $0x1
801067fd:	e8 3d f4 ff ff       	call   80105c3f <argint>
80106802:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106805:	85 c0                	test   %eax,%eax
80106807:	78 3a                	js     80106843 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106809:	83 ec 08             	sub    $0x8,%esp
8010680c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010680f:	50                   	push   %eax
80106810:	6a 02                	push   $0x2
80106812:	e8 28 f4 ff ff       	call   80105c3f <argint>
80106817:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010681a:	85 c0                	test   %eax,%eax
8010681c:	78 25                	js     80106843 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010681e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106821:	0f bf c8             	movswl %ax,%ecx
80106824:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106827:	0f bf d0             	movswl %ax,%edx
8010682a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010682d:	51                   	push   %ecx
8010682e:	52                   	push   %edx
8010682f:	6a 03                	push   $0x3
80106831:	50                   	push   %eax
80106832:	e8 bc fb ff ff       	call   801063f3 <create>
80106837:	83 c4 10             	add    $0x10,%esp
8010683a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010683d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106841:	75 0c                	jne    8010684f <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106843:	e8 29 d4 ff ff       	call   80103c71 <end_op>
    return -1;
80106848:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010684d:	eb 18                	jmp    80106867 <sys_mknod+0x98>
  }
  iunlockput(ip);
8010684f:	83 ec 0c             	sub    $0xc,%esp
80106852:	ff 75 f0             	pushl  -0x10(%ebp)
80106855:	e8 bd b8 ff ff       	call   80102117 <iunlockput>
8010685a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010685d:	e8 0f d4 ff ff       	call   80103c71 <end_op>
  return 0;
80106862:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106867:	c9                   	leave  
80106868:	c3                   	ret    

80106869 <sys_chdir>:

int
sys_chdir(void)
{
80106869:	55                   	push   %ebp
8010686a:	89 e5                	mov    %esp,%ebp
8010686c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010686f:	e8 71 d3 ff ff       	call   80103be5 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106874:	83 ec 08             	sub    $0x8,%esp
80106877:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010687a:	50                   	push   %eax
8010687b:	6a 00                	push   $0x0
8010687d:	e8 42 f4 ff ff       	call   80105cc4 <argstr>
80106882:	83 c4 10             	add    $0x10,%esp
80106885:	85 c0                	test   %eax,%eax
80106887:	78 18                	js     801068a1 <sys_chdir+0x38>
80106889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010688c:	83 ec 0c             	sub    $0xc,%esp
8010688f:	50                   	push   %eax
80106890:	e8 f8 c2 ff ff       	call   80102b8d <namei>
80106895:	83 c4 10             	add    $0x10,%esp
80106898:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010689b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010689f:	75 0c                	jne    801068ad <sys_chdir+0x44>
    end_op();
801068a1:	e8 cb d3 ff ff       	call   80103c71 <end_op>
    return -1;
801068a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ab:	eb 6e                	jmp    8010691b <sys_chdir+0xb2>
  }
  ilock(ip);
801068ad:	83 ec 0c             	sub    $0xc,%esp
801068b0:	ff 75 f4             	pushl  -0xc(%ebp)
801068b3:	e8 5c b5 ff ff       	call   80101e14 <ilock>
801068b8:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801068bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068be:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068c2:	66 83 f8 01          	cmp    $0x1,%ax
801068c6:	74 1a                	je     801068e2 <sys_chdir+0x79>
    iunlockput(ip);
801068c8:	83 ec 0c             	sub    $0xc,%esp
801068cb:	ff 75 f4             	pushl  -0xc(%ebp)
801068ce:	e8 44 b8 ff ff       	call   80102117 <iunlockput>
801068d3:	83 c4 10             	add    $0x10,%esp
    end_op();
801068d6:	e8 96 d3 ff ff       	call   80103c71 <end_op>
    return -1;
801068db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e0:	eb 39                	jmp    8010691b <sys_chdir+0xb2>
  }
  iunlock(ip);
801068e2:	83 ec 0c             	sub    $0xc,%esp
801068e5:	ff 75 f4             	pushl  -0xc(%ebp)
801068e8:	e8 c8 b6 ff ff       	call   80101fb5 <iunlock>
801068ed:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801068f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068f6:	8b 40 68             	mov    0x68(%eax),%eax
801068f9:	83 ec 0c             	sub    $0xc,%esp
801068fc:	50                   	push   %eax
801068fd:	e8 25 b7 ff ff       	call   80102027 <iput>
80106902:	83 c4 10             	add    $0x10,%esp
  end_op();
80106905:	e8 67 d3 ff ff       	call   80103c71 <end_op>
  proc->cwd = ip;
8010690a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106910:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106913:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106916:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010691b:	c9                   	leave  
8010691c:	c3                   	ret    

8010691d <sys_exec>:

int
sys_exec(void)
{
8010691d:	55                   	push   %ebp
8010691e:	89 e5                	mov    %esp,%ebp
80106920:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106926:	83 ec 08             	sub    $0x8,%esp
80106929:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010692c:	50                   	push   %eax
8010692d:	6a 00                	push   $0x0
8010692f:	e8 90 f3 ff ff       	call   80105cc4 <argstr>
80106934:	83 c4 10             	add    $0x10,%esp
80106937:	85 c0                	test   %eax,%eax
80106939:	78 18                	js     80106953 <sys_exec+0x36>
8010693b:	83 ec 08             	sub    $0x8,%esp
8010693e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106944:	50                   	push   %eax
80106945:	6a 01                	push   $0x1
80106947:	e8 f3 f2 ff ff       	call   80105c3f <argint>
8010694c:	83 c4 10             	add    $0x10,%esp
8010694f:	85 c0                	test   %eax,%eax
80106951:	79 0a                	jns    8010695d <sys_exec+0x40>
    return -1;
80106953:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106958:	e9 c6 00 00 00       	jmp    80106a23 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010695d:	83 ec 04             	sub    $0x4,%esp
80106960:	68 80 00 00 00       	push   $0x80
80106965:	6a 00                	push   $0x0
80106967:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010696d:	50                   	push   %eax
8010696e:	e8 a7 ef ff ff       	call   8010591a <memset>
80106973:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106976:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010697d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106980:	83 f8 1f             	cmp    $0x1f,%eax
80106983:	76 0a                	jbe    8010698f <sys_exec+0x72>
      return -1;
80106985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698a:	e9 94 00 00 00       	jmp    80106a23 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010698f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106992:	c1 e0 02             	shl    $0x2,%eax
80106995:	89 c2                	mov    %eax,%edx
80106997:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010699d:	01 c2                	add    %eax,%edx
8010699f:	83 ec 08             	sub    $0x8,%esp
801069a2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801069a8:	50                   	push   %eax
801069a9:	52                   	push   %edx
801069aa:	e8 f4 f1 ff ff       	call   80105ba3 <fetchint>
801069af:	83 c4 10             	add    $0x10,%esp
801069b2:	85 c0                	test   %eax,%eax
801069b4:	79 07                	jns    801069bd <sys_exec+0xa0>
      return -1;
801069b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bb:	eb 66                	jmp    80106a23 <sys_exec+0x106>
    if(uarg == 0){
801069bd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801069c3:	85 c0                	test   %eax,%eax
801069c5:	75 27                	jne    801069ee <sys_exec+0xd1>
      argv[i] = 0;
801069c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ca:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801069d1:	00 00 00 00 
      break;
801069d5:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801069d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d9:	83 ec 08             	sub    $0x8,%esp
801069dc:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801069e2:	52                   	push   %edx
801069e3:	50                   	push   %eax
801069e4:	e8 88 a1 ff ff       	call   80100b71 <exec>
801069e9:	83 c4 10             	add    $0x10,%esp
801069ec:	eb 35                	jmp    80106a23 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801069ee:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801069f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069f7:	c1 e2 02             	shl    $0x2,%edx
801069fa:	01 c2                	add    %eax,%edx
801069fc:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106a02:	83 ec 08             	sub    $0x8,%esp
80106a05:	52                   	push   %edx
80106a06:	50                   	push   %eax
80106a07:	e8 d1 f1 ff ff       	call   80105bdd <fetchstr>
80106a0c:	83 c4 10             	add    $0x10,%esp
80106a0f:	85 c0                	test   %eax,%eax
80106a11:	79 07                	jns    80106a1a <sys_exec+0xfd>
      return -1;
80106a13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a18:	eb 09                	jmp    80106a23 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106a1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106a1e:	e9 5a ff ff ff       	jmp    8010697d <sys_exec+0x60>
  return exec(path, argv);
}
80106a23:	c9                   	leave  
80106a24:	c3                   	ret    

80106a25 <sys_pipe>:

int
sys_pipe(void)
{
80106a25:	55                   	push   %ebp
80106a26:	89 e5                	mov    %esp,%ebp
80106a28:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106a2b:	83 ec 04             	sub    $0x4,%esp
80106a2e:	6a 08                	push   $0x8
80106a30:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a33:	50                   	push   %eax
80106a34:	6a 00                	push   $0x0
80106a36:	e8 2c f2 ff ff       	call   80105c67 <argptr>
80106a3b:	83 c4 10             	add    $0x10,%esp
80106a3e:	85 c0                	test   %eax,%eax
80106a40:	79 0a                	jns    80106a4c <sys_pipe+0x27>
    return -1;
80106a42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a47:	e9 af 00 00 00       	jmp    80106afb <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106a4c:	83 ec 08             	sub    $0x8,%esp
80106a4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a52:	50                   	push   %eax
80106a53:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a56:	50                   	push   %eax
80106a57:	e8 60 dc ff ff       	call   801046bc <pipealloc>
80106a5c:	83 c4 10             	add    $0x10,%esp
80106a5f:	85 c0                	test   %eax,%eax
80106a61:	79 0a                	jns    80106a6d <sys_pipe+0x48>
    return -1;
80106a63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a68:	e9 8e 00 00 00       	jmp    80106afb <sys_pipe+0xd6>
  fd0 = -1;
80106a6d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106a74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a77:	83 ec 0c             	sub    $0xc,%esp
80106a7a:	50                   	push   %eax
80106a7b:	e8 70 f3 ff ff       	call   80105df0 <fdalloc>
80106a80:	83 c4 10             	add    $0x10,%esp
80106a83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a8a:	78 18                	js     80106aa4 <sys_pipe+0x7f>
80106a8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a8f:	83 ec 0c             	sub    $0xc,%esp
80106a92:	50                   	push   %eax
80106a93:	e8 58 f3 ff ff       	call   80105df0 <fdalloc>
80106a98:	83 c4 10             	add    $0x10,%esp
80106a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aa2:	79 3f                	jns    80106ae3 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106aa4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106aa8:	78 14                	js     80106abe <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106aaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ab3:	83 c2 08             	add    $0x8,%edx
80106ab6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106abd:	00 
    fileclose(rf);
80106abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ac1:	83 ec 0c             	sub    $0xc,%esp
80106ac4:	50                   	push   %eax
80106ac5:	e8 87 a5 ff ff       	call   80101051 <fileclose>
80106aca:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106acd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ad0:	83 ec 0c             	sub    $0xc,%esp
80106ad3:	50                   	push   %eax
80106ad4:	e8 78 a5 ff ff       	call   80101051 <fileclose>
80106ad9:	83 c4 10             	add    $0x10,%esp
    return -1;
80106adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ae1:	eb 18                	jmp    80106afb <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ae9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106aee:	8d 50 04             	lea    0x4(%eax),%edx
80106af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af4:	89 02                	mov    %eax,(%edx)
  return 0;
80106af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106afb:	c9                   	leave  
80106afc:	c3                   	ret    

80106afd <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106afd:	55                   	push   %ebp
80106afe:	89 e5                	mov    %esp,%ebp
80106b00:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106b03:	e8 aa e2 ff ff       	call   80104db2 <fork>
}
80106b08:	c9                   	leave  
80106b09:	c3                   	ret    

80106b0a <sys_exit>:

int
sys_exit(void)
{
80106b0a:	55                   	push   %ebp
80106b0b:	89 e5                	mov    %esp,%ebp
80106b0d:	83 ec 08             	sub    $0x8,%esp
  exit();
80106b10:	e8 2e e4 ff ff       	call   80104f43 <exit>
  return 0;  // not reached
80106b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b1a:	c9                   	leave  
80106b1b:	c3                   	ret    

80106b1c <sys_wait>:

int
sys_wait(void)
{
80106b1c:	55                   	push   %ebp
80106b1d:	89 e5                	mov    %esp,%ebp
80106b1f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106b22:	e8 54 e5 ff ff       	call   8010507b <wait>
}
80106b27:	c9                   	leave  
80106b28:	c3                   	ret    

80106b29 <sys_kill>:

int
sys_kill(void)
{
80106b29:	55                   	push   %ebp
80106b2a:	89 e5                	mov    %esp,%ebp
80106b2c:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106b2f:	83 ec 08             	sub    $0x8,%esp
80106b32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b35:	50                   	push   %eax
80106b36:	6a 00                	push   $0x0
80106b38:	e8 02 f1 ff ff       	call   80105c3f <argint>
80106b3d:	83 c4 10             	add    $0x10,%esp
80106b40:	85 c0                	test   %eax,%eax
80106b42:	79 07                	jns    80106b4b <sys_kill+0x22>
    return -1;
80106b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b49:	eb 0f                	jmp    80106b5a <sys_kill+0x31>
  return kill(pid);
80106b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4e:	83 ec 0c             	sub    $0xc,%esp
80106b51:	50                   	push   %eax
80106b52:	e8 89 e9 ff ff       	call   801054e0 <kill>
80106b57:	83 c4 10             	add    $0x10,%esp
}
80106b5a:	c9                   	leave  
80106b5b:	c3                   	ret    

80106b5c <sys_getpid>:

int
sys_getpid(void)
{
80106b5c:	55                   	push   %ebp
80106b5d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106b5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b65:	8b 40 10             	mov    0x10(%eax),%eax
}
80106b68:	5d                   	pop    %ebp
80106b69:	c3                   	ret    

80106b6a <sys_sbrk>:

int
sys_sbrk(void)
{
80106b6a:	55                   	push   %ebp
80106b6b:	89 e5                	mov    %esp,%ebp
80106b6d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106b70:	83 ec 08             	sub    $0x8,%esp
80106b73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b76:	50                   	push   %eax
80106b77:	6a 00                	push   $0x0
80106b79:	e8 c1 f0 ff ff       	call   80105c3f <argint>
80106b7e:	83 c4 10             	add    $0x10,%esp
80106b81:	85 c0                	test   %eax,%eax
80106b83:	79 07                	jns    80106b8c <sys_sbrk+0x22>
    return -1;
80106b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8a:	eb 28                	jmp    80106bb4 <sys_sbrk+0x4a>
  addr = proc->sz;
80106b8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b92:	8b 00                	mov    (%eax),%eax
80106b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b9a:	83 ec 0c             	sub    $0xc,%esp
80106b9d:	50                   	push   %eax
80106b9e:	e8 6c e1 ff ff       	call   80104d0f <growproc>
80106ba3:	83 c4 10             	add    $0x10,%esp
80106ba6:	85 c0                	test   %eax,%eax
80106ba8:	79 07                	jns    80106bb1 <sys_sbrk+0x47>
    return -1;
80106baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106baf:	eb 03                	jmp    80106bb4 <sys_sbrk+0x4a>
  return addr;
80106bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106bb4:	c9                   	leave  
80106bb5:	c3                   	ret    

80106bb6 <sys_sleep>:

int
sys_sleep(void)
{
80106bb6:	55                   	push   %ebp
80106bb7:	89 e5                	mov    %esp,%ebp
80106bb9:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106bbc:	83 ec 08             	sub    $0x8,%esp
80106bbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bc2:	50                   	push   %eax
80106bc3:	6a 00                	push   $0x0
80106bc5:	e8 75 f0 ff ff       	call   80105c3f <argint>
80106bca:	83 c4 10             	add    $0x10,%esp
80106bcd:	85 c0                	test   %eax,%eax
80106bcf:	79 07                	jns    80106bd8 <sys_sleep+0x22>
    return -1;
80106bd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bd6:	eb 77                	jmp    80106c4f <sys_sleep+0x99>
  acquire(&tickslock);
80106bd8:	83 ec 0c             	sub    $0xc,%esp
80106bdb:	68 60 5b 11 80       	push   $0x80115b60
80106be0:	e8 d2 ea ff ff       	call   801056b7 <acquire>
80106be5:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106be8:	a1 a0 63 11 80       	mov    0x801163a0,%eax
80106bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106bf0:	eb 39                	jmp    80106c2b <sys_sleep+0x75>
    if(proc->killed){
80106bf2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf8:	8b 40 24             	mov    0x24(%eax),%eax
80106bfb:	85 c0                	test   %eax,%eax
80106bfd:	74 17                	je     80106c16 <sys_sleep+0x60>
      release(&tickslock);
80106bff:	83 ec 0c             	sub    $0xc,%esp
80106c02:	68 60 5b 11 80       	push   $0x80115b60
80106c07:	e8 12 eb ff ff       	call   8010571e <release>
80106c0c:	83 c4 10             	add    $0x10,%esp
      return -1;
80106c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c14:	eb 39                	jmp    80106c4f <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106c16:	83 ec 08             	sub    $0x8,%esp
80106c19:	68 60 5b 11 80       	push   $0x80115b60
80106c1e:	68 a0 63 11 80       	push   $0x801163a0
80106c23:	e8 96 e7 ff ff       	call   801053be <sleep>
80106c28:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106c2b:	a1 a0 63 11 80       	mov    0x801163a0,%eax
80106c30:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106c33:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c36:	39 d0                	cmp    %edx,%eax
80106c38:	72 b8                	jb     80106bf2 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106c3a:	83 ec 0c             	sub    $0xc,%esp
80106c3d:	68 60 5b 11 80       	push   $0x80115b60
80106c42:	e8 d7 ea ff ff       	call   8010571e <release>
80106c47:	83 c4 10             	add    $0x10,%esp
  return 0;
80106c4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c4f:	c9                   	leave  
80106c50:	c3                   	ret    

80106c51 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106c51:	55                   	push   %ebp
80106c52:	89 e5                	mov    %esp,%ebp
80106c54:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106c57:	83 ec 0c             	sub    $0xc,%esp
80106c5a:	68 60 5b 11 80       	push   $0x80115b60
80106c5f:	e8 53 ea ff ff       	call   801056b7 <acquire>
80106c64:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106c67:	a1 a0 63 11 80       	mov    0x801163a0,%eax
80106c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106c6f:	83 ec 0c             	sub    $0xc,%esp
80106c72:	68 60 5b 11 80       	push   $0x80115b60
80106c77:	e8 a2 ea ff ff       	call   8010571e <release>
80106c7c:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106c82:	c9                   	leave  
80106c83:	c3                   	ret    

80106c84 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c84:	55                   	push   %ebp
80106c85:	89 e5                	mov    %esp,%ebp
80106c87:	83 ec 08             	sub    $0x8,%esp
80106c8a:	8b 55 08             	mov    0x8(%ebp),%edx
80106c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c90:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c94:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c97:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c9b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c9f:	ee                   	out    %al,(%dx)
}
80106ca0:	90                   	nop
80106ca1:	c9                   	leave  
80106ca2:	c3                   	ret    

80106ca3 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106ca3:	55                   	push   %ebp
80106ca4:	89 e5                	mov    %esp,%ebp
80106ca6:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106ca9:	6a 34                	push   $0x34
80106cab:	6a 43                	push   $0x43
80106cad:	e8 d2 ff ff ff       	call   80106c84 <outb>
80106cb2:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106cb5:	68 9c 00 00 00       	push   $0x9c
80106cba:	6a 40                	push   $0x40
80106cbc:	e8 c3 ff ff ff       	call   80106c84 <outb>
80106cc1:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106cc4:	6a 2e                	push   $0x2e
80106cc6:	6a 40                	push   $0x40
80106cc8:	e8 b7 ff ff ff       	call   80106c84 <outb>
80106ccd:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106cd0:	83 ec 0c             	sub    $0xc,%esp
80106cd3:	6a 00                	push   $0x0
80106cd5:	e8 cc d8 ff ff       	call   801045a6 <picenable>
80106cda:	83 c4 10             	add    $0x10,%esp
}
80106cdd:	90                   	nop
80106cde:	c9                   	leave  
80106cdf:	c3                   	ret    

80106ce0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ce0:	1e                   	push   %ds
  pushl %es
80106ce1:	06                   	push   %es
  pushl %fs
80106ce2:	0f a0                	push   %fs
  pushl %gs
80106ce4:	0f a8                	push   %gs
  pushal
80106ce6:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106ce7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106ceb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106ced:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106cef:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106cf3:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106cf5:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106cf7:	54                   	push   %esp
  call trap
80106cf8:	e8 d7 01 00 00       	call   80106ed4 <trap>
  addl $4, %esp
80106cfd:	83 c4 04             	add    $0x4,%esp

80106d00 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106d00:	61                   	popa   
  popl %gs
80106d01:	0f a9                	pop    %gs
  popl %fs
80106d03:	0f a1                	pop    %fs
  popl %es
80106d05:	07                   	pop    %es
  popl %ds
80106d06:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106d07:	83 c4 08             	add    $0x8,%esp
  iret
80106d0a:	cf                   	iret   

80106d0b <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106d0b:	55                   	push   %ebp
80106d0c:	89 e5                	mov    %esp,%ebp
80106d0e:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d14:	83 e8 01             	sub    $0x1,%eax
80106d17:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106d22:	8b 45 08             	mov    0x8(%ebp),%eax
80106d25:	c1 e8 10             	shr    $0x10,%eax
80106d28:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106d2c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106d2f:	0f 01 18             	lidtl  (%eax)
}
80106d32:	90                   	nop
80106d33:	c9                   	leave  
80106d34:	c3                   	ret    

80106d35 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106d35:	55                   	push   %ebp
80106d36:	89 e5                	mov    %esp,%ebp
80106d38:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106d3b:	0f 20 d0             	mov    %cr2,%eax
80106d3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106d41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d44:	c9                   	leave  
80106d45:	c3                   	ret    

80106d46 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106d46:	55                   	push   %ebp
80106d47:	89 e5                	mov    %esp,%ebp
80106d49:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106d4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d53:	e9 c3 00 00 00       	jmp    80106e1b <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d5b:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106d62:	89 c2                	mov    %eax,%edx
80106d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d67:	66 89 14 c5 a0 5b 11 	mov    %dx,-0x7feea460(,%eax,8)
80106d6e:	80 
80106d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d72:	66 c7 04 c5 a2 5b 11 	movw   $0x8,-0x7feea45e(,%eax,8)
80106d79:	80 08 00 
80106d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d7f:	0f b6 14 c5 a4 5b 11 	movzbl -0x7feea45c(,%eax,8),%edx
80106d86:	80 
80106d87:	83 e2 e0             	and    $0xffffffe0,%edx
80106d8a:	88 14 c5 a4 5b 11 80 	mov    %dl,-0x7feea45c(,%eax,8)
80106d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d94:	0f b6 14 c5 a4 5b 11 	movzbl -0x7feea45c(,%eax,8),%edx
80106d9b:	80 
80106d9c:	83 e2 1f             	and    $0x1f,%edx
80106d9f:	88 14 c5 a4 5b 11 80 	mov    %dl,-0x7feea45c(,%eax,8)
80106da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106da9:	0f b6 14 c5 a5 5b 11 	movzbl -0x7feea45b(,%eax,8),%edx
80106db0:	80 
80106db1:	83 e2 f0             	and    $0xfffffff0,%edx
80106db4:	83 ca 0e             	or     $0xe,%edx
80106db7:	88 14 c5 a5 5b 11 80 	mov    %dl,-0x7feea45b(,%eax,8)
80106dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc1:	0f b6 14 c5 a5 5b 11 	movzbl -0x7feea45b(,%eax,8),%edx
80106dc8:	80 
80106dc9:	83 e2 ef             	and    $0xffffffef,%edx
80106dcc:	88 14 c5 a5 5b 11 80 	mov    %dl,-0x7feea45b(,%eax,8)
80106dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd6:	0f b6 14 c5 a5 5b 11 	movzbl -0x7feea45b(,%eax,8),%edx
80106ddd:	80 
80106dde:	83 e2 9f             	and    $0xffffff9f,%edx
80106de1:	88 14 c5 a5 5b 11 80 	mov    %dl,-0x7feea45b(,%eax,8)
80106de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106deb:	0f b6 14 c5 a5 5b 11 	movzbl -0x7feea45b(,%eax,8),%edx
80106df2:	80 
80106df3:	83 ca 80             	or     $0xffffff80,%edx
80106df6:	88 14 c5 a5 5b 11 80 	mov    %dl,-0x7feea45b(,%eax,8)
80106dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e00:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106e07:	c1 e8 10             	shr    $0x10,%eax
80106e0a:	89 c2                	mov    %eax,%edx
80106e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e0f:	66 89 14 c5 a6 5b 11 	mov    %dx,-0x7feea45a(,%eax,8)
80106e16:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106e17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e1b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106e22:	0f 8e 30 ff ff ff    	jle    80106d58 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106e28:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106e2d:	66 a3 a0 5d 11 80    	mov    %ax,0x80115da0
80106e33:	66 c7 05 a2 5d 11 80 	movw   $0x8,0x80115da2
80106e3a:	08 00 
80106e3c:	0f b6 05 a4 5d 11 80 	movzbl 0x80115da4,%eax
80106e43:	83 e0 e0             	and    $0xffffffe0,%eax
80106e46:	a2 a4 5d 11 80       	mov    %al,0x80115da4
80106e4b:	0f b6 05 a4 5d 11 80 	movzbl 0x80115da4,%eax
80106e52:	83 e0 1f             	and    $0x1f,%eax
80106e55:	a2 a4 5d 11 80       	mov    %al,0x80115da4
80106e5a:	0f b6 05 a5 5d 11 80 	movzbl 0x80115da5,%eax
80106e61:	83 c8 0f             	or     $0xf,%eax
80106e64:	a2 a5 5d 11 80       	mov    %al,0x80115da5
80106e69:	0f b6 05 a5 5d 11 80 	movzbl 0x80115da5,%eax
80106e70:	83 e0 ef             	and    $0xffffffef,%eax
80106e73:	a2 a5 5d 11 80       	mov    %al,0x80115da5
80106e78:	0f b6 05 a5 5d 11 80 	movzbl 0x80115da5,%eax
80106e7f:	83 c8 60             	or     $0x60,%eax
80106e82:	a2 a5 5d 11 80       	mov    %al,0x80115da5
80106e87:	0f b6 05 a5 5d 11 80 	movzbl 0x80115da5,%eax
80106e8e:	83 c8 80             	or     $0xffffff80,%eax
80106e91:	a2 a5 5d 11 80       	mov    %al,0x80115da5
80106e96:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106e9b:	c1 e8 10             	shr    $0x10,%eax
80106e9e:	66 a3 a6 5d 11 80    	mov    %ax,0x80115da6
  
  initlock(&tickslock, "time");
80106ea4:	83 ec 08             	sub    $0x8,%esp
80106ea7:	68 90 91 10 80       	push   $0x80109190
80106eac:	68 60 5b 11 80       	push   $0x80115b60
80106eb1:	e8 df e7 ff ff       	call   80105695 <initlock>
80106eb6:	83 c4 10             	add    $0x10,%esp
}
80106eb9:	90                   	nop
80106eba:	c9                   	leave  
80106ebb:	c3                   	ret    

80106ebc <idtinit>:

void
idtinit(void)
{
80106ebc:	55                   	push   %ebp
80106ebd:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106ebf:	68 00 08 00 00       	push   $0x800
80106ec4:	68 a0 5b 11 80       	push   $0x80115ba0
80106ec9:	e8 3d fe ff ff       	call   80106d0b <lidt>
80106ece:	83 c4 08             	add    $0x8,%esp
}
80106ed1:	90                   	nop
80106ed2:	c9                   	leave  
80106ed3:	c3                   	ret    

80106ed4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ed4:	55                   	push   %ebp
80106ed5:	89 e5                	mov    %esp,%ebp
80106ed7:	57                   	push   %edi
80106ed8:	56                   	push   %esi
80106ed9:	53                   	push   %ebx
80106eda:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106edd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee0:	8b 40 30             	mov    0x30(%eax),%eax
80106ee3:	83 f8 40             	cmp    $0x40,%eax
80106ee6:	75 3e                	jne    80106f26 <trap+0x52>
    if(proc->killed)
80106ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eee:	8b 40 24             	mov    0x24(%eax),%eax
80106ef1:	85 c0                	test   %eax,%eax
80106ef3:	74 05                	je     80106efa <trap+0x26>
      exit();
80106ef5:	e8 49 e0 ff ff       	call   80104f43 <exit>
    proc->tf = tf;
80106efa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f00:	8b 55 08             	mov    0x8(%ebp),%edx
80106f03:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106f06:	e8 ea ed ff ff       	call   80105cf5 <syscall>
    if(proc->killed)
80106f0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f11:	8b 40 24             	mov    0x24(%eax),%eax
80106f14:	85 c0                	test   %eax,%eax
80106f16:	0f 84 1b 02 00 00    	je     80107137 <trap+0x263>
      exit();
80106f1c:	e8 22 e0 ff ff       	call   80104f43 <exit>
    return;
80106f21:	e9 11 02 00 00       	jmp    80107137 <trap+0x263>
  }

  switch(tf->trapno){
80106f26:	8b 45 08             	mov    0x8(%ebp),%eax
80106f29:	8b 40 30             	mov    0x30(%eax),%eax
80106f2c:	83 e8 20             	sub    $0x20,%eax
80106f2f:	83 f8 1f             	cmp    $0x1f,%eax
80106f32:	0f 87 c0 00 00 00    	ja     80106ff8 <trap+0x124>
80106f38:	8b 04 85 38 92 10 80 	mov    -0x7fef6dc8(,%eax,4),%eax
80106f3f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106f41:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f47:	0f b6 00             	movzbl (%eax),%eax
80106f4a:	84 c0                	test   %al,%al
80106f4c:	75 3d                	jne    80106f8b <trap+0xb7>
      acquire(&tickslock);
80106f4e:	83 ec 0c             	sub    $0xc,%esp
80106f51:	68 60 5b 11 80       	push   $0x80115b60
80106f56:	e8 5c e7 ff ff       	call   801056b7 <acquire>
80106f5b:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106f5e:	a1 a0 63 11 80       	mov    0x801163a0,%eax
80106f63:	83 c0 01             	add    $0x1,%eax
80106f66:	a3 a0 63 11 80       	mov    %eax,0x801163a0
      wakeup(&ticks);
80106f6b:	83 ec 0c             	sub    $0xc,%esp
80106f6e:	68 a0 63 11 80       	push   $0x801163a0
80106f73:	e8 31 e5 ff ff       	call   801054a9 <wakeup>
80106f78:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106f7b:	83 ec 0c             	sub    $0xc,%esp
80106f7e:	68 60 5b 11 80       	push   $0x80115b60
80106f83:	e8 96 e7 ff ff       	call   8010571e <release>
80106f88:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106f8b:	e8 1a c7 ff ff       	call   801036aa <lapiceoi>
    break;
80106f90:	e9 1c 01 00 00       	jmp    801070b1 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106f95:	e8 13 bf ff ff       	call   80102ead <ideintr>
    lapiceoi();
80106f9a:	e8 0b c7 ff ff       	call   801036aa <lapiceoi>
    break;
80106f9f:	e9 0d 01 00 00       	jmp    801070b1 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106fa4:	e8 03 c5 ff ff       	call   801034ac <kbdintr>
    lapiceoi();
80106fa9:	e8 fc c6 ff ff       	call   801036aa <lapiceoi>
    break;
80106fae:	e9 fe 00 00 00       	jmp    801070b1 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106fb3:	e8 60 03 00 00       	call   80107318 <uartintr>
    lapiceoi();
80106fb8:	e8 ed c6 ff ff       	call   801036aa <lapiceoi>
    break;
80106fbd:	e9 ef 00 00 00       	jmp    801070b1 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80106fc5:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80106fcb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106fcf:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106fd2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106fd8:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106fdb:	0f b6 c0             	movzbl %al,%eax
80106fde:	51                   	push   %ecx
80106fdf:	52                   	push   %edx
80106fe0:	50                   	push   %eax
80106fe1:	68 98 91 10 80       	push   $0x80109198
80106fe6:	e8 db 93 ff ff       	call   801003c6 <cprintf>
80106feb:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106fee:	e8 b7 c6 ff ff       	call   801036aa <lapiceoi>
    break;
80106ff3:	e9 b9 00 00 00       	jmp    801070b1 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106ff8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ffe:	85 c0                	test   %eax,%eax
80107000:	74 11                	je     80107013 <trap+0x13f>
80107002:	8b 45 08             	mov    0x8(%ebp),%eax
80107005:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107009:	0f b7 c0             	movzwl %ax,%eax
8010700c:	83 e0 03             	and    $0x3,%eax
8010700f:	85 c0                	test   %eax,%eax
80107011:	75 40                	jne    80107053 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107013:	e8 1d fd ff ff       	call   80106d35 <rcr2>
80107018:	89 c3                	mov    %eax,%ebx
8010701a:	8b 45 08             	mov    0x8(%ebp),%eax
8010701d:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107020:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107026:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107029:	0f b6 d0             	movzbl %al,%edx
8010702c:	8b 45 08             	mov    0x8(%ebp),%eax
8010702f:	8b 40 30             	mov    0x30(%eax),%eax
80107032:	83 ec 0c             	sub    $0xc,%esp
80107035:	53                   	push   %ebx
80107036:	51                   	push   %ecx
80107037:	52                   	push   %edx
80107038:	50                   	push   %eax
80107039:	68 bc 91 10 80       	push   $0x801091bc
8010703e:	e8 83 93 ff ff       	call   801003c6 <cprintf>
80107043:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107046:	83 ec 0c             	sub    $0xc,%esp
80107049:	68 ee 91 10 80       	push   $0x801091ee
8010704e:	e8 13 95 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107053:	e8 dd fc ff ff       	call   80106d35 <rcr2>
80107058:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010705b:	8b 45 08             	mov    0x8(%ebp),%eax
8010705e:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107061:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107067:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010706a:	0f b6 d8             	movzbl %al,%ebx
8010706d:	8b 45 08             	mov    0x8(%ebp),%eax
80107070:	8b 48 34             	mov    0x34(%eax),%ecx
80107073:	8b 45 08             	mov    0x8(%ebp),%eax
80107076:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107079:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010707f:	8d 78 6c             	lea    0x6c(%eax),%edi
80107082:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107088:	8b 40 10             	mov    0x10(%eax),%eax
8010708b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010708e:	56                   	push   %esi
8010708f:	53                   	push   %ebx
80107090:	51                   	push   %ecx
80107091:	52                   	push   %edx
80107092:	57                   	push   %edi
80107093:	50                   	push   %eax
80107094:	68 f4 91 10 80       	push   $0x801091f4
80107099:	e8 28 93 ff ff       	call   801003c6 <cprintf>
8010709e:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801070a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070a7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801070ae:	eb 01                	jmp    801070b1 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801070b0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801070b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070b7:	85 c0                	test   %eax,%eax
801070b9:	74 24                	je     801070df <trap+0x20b>
801070bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070c1:	8b 40 24             	mov    0x24(%eax),%eax
801070c4:	85 c0                	test   %eax,%eax
801070c6:	74 17                	je     801070df <trap+0x20b>
801070c8:	8b 45 08             	mov    0x8(%ebp),%eax
801070cb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801070cf:	0f b7 c0             	movzwl %ax,%eax
801070d2:	83 e0 03             	and    $0x3,%eax
801070d5:	83 f8 03             	cmp    $0x3,%eax
801070d8:	75 05                	jne    801070df <trap+0x20b>
    exit();
801070da:	e8 64 de ff ff       	call   80104f43 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801070df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070e5:	85 c0                	test   %eax,%eax
801070e7:	74 1e                	je     80107107 <trap+0x233>
801070e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070ef:	8b 40 0c             	mov    0xc(%eax),%eax
801070f2:	83 f8 04             	cmp    $0x4,%eax
801070f5:	75 10                	jne    80107107 <trap+0x233>
801070f7:	8b 45 08             	mov    0x8(%ebp),%eax
801070fa:	8b 40 30             	mov    0x30(%eax),%eax
801070fd:	83 f8 20             	cmp    $0x20,%eax
80107100:	75 05                	jne    80107107 <trap+0x233>
    yield();
80107102:	e8 f9 e1 ff ff       	call   80105300 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010710d:	85 c0                	test   %eax,%eax
8010710f:	74 27                	je     80107138 <trap+0x264>
80107111:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107117:	8b 40 24             	mov    0x24(%eax),%eax
8010711a:	85 c0                	test   %eax,%eax
8010711c:	74 1a                	je     80107138 <trap+0x264>
8010711e:	8b 45 08             	mov    0x8(%ebp),%eax
80107121:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107125:	0f b7 c0             	movzwl %ax,%eax
80107128:	83 e0 03             	and    $0x3,%eax
8010712b:	83 f8 03             	cmp    $0x3,%eax
8010712e:	75 08                	jne    80107138 <trap+0x264>
    exit();
80107130:	e8 0e de ff ff       	call   80104f43 <exit>
80107135:	eb 01                	jmp    80107138 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107137:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107138:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010713b:	5b                   	pop    %ebx
8010713c:	5e                   	pop    %esi
8010713d:	5f                   	pop    %edi
8010713e:	5d                   	pop    %ebp
8010713f:	c3                   	ret    

80107140 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107140:	55                   	push   %ebp
80107141:	89 e5                	mov    %esp,%ebp
80107143:	83 ec 14             	sub    $0x14,%esp
80107146:	8b 45 08             	mov    0x8(%ebp),%eax
80107149:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010714d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107151:	89 c2                	mov    %eax,%edx
80107153:	ec                   	in     (%dx),%al
80107154:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107157:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010715b:	c9                   	leave  
8010715c:	c3                   	ret    

8010715d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010715d:	55                   	push   %ebp
8010715e:	89 e5                	mov    %esp,%ebp
80107160:	83 ec 08             	sub    $0x8,%esp
80107163:	8b 55 08             	mov    0x8(%ebp),%edx
80107166:	8b 45 0c             	mov    0xc(%ebp),%eax
80107169:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010716d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107170:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107174:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107178:	ee                   	out    %al,(%dx)
}
80107179:	90                   	nop
8010717a:	c9                   	leave  
8010717b:	c3                   	ret    

8010717c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010717c:	55                   	push   %ebp
8010717d:	89 e5                	mov    %esp,%ebp
8010717f:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107182:	6a 00                	push   $0x0
80107184:	68 fa 03 00 00       	push   $0x3fa
80107189:	e8 cf ff ff ff       	call   8010715d <outb>
8010718e:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107191:	68 80 00 00 00       	push   $0x80
80107196:	68 fb 03 00 00       	push   $0x3fb
8010719b:	e8 bd ff ff ff       	call   8010715d <outb>
801071a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801071a3:	6a 0c                	push   $0xc
801071a5:	68 f8 03 00 00       	push   $0x3f8
801071aa:	e8 ae ff ff ff       	call   8010715d <outb>
801071af:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801071b2:	6a 00                	push   $0x0
801071b4:	68 f9 03 00 00       	push   $0x3f9
801071b9:	e8 9f ff ff ff       	call   8010715d <outb>
801071be:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801071c1:	6a 03                	push   $0x3
801071c3:	68 fb 03 00 00       	push   $0x3fb
801071c8:	e8 90 ff ff ff       	call   8010715d <outb>
801071cd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801071d0:	6a 00                	push   $0x0
801071d2:	68 fc 03 00 00       	push   $0x3fc
801071d7:	e8 81 ff ff ff       	call   8010715d <outb>
801071dc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801071df:	6a 01                	push   $0x1
801071e1:	68 f9 03 00 00       	push   $0x3f9
801071e6:	e8 72 ff ff ff       	call   8010715d <outb>
801071eb:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801071ee:	68 fd 03 00 00       	push   $0x3fd
801071f3:	e8 48 ff ff ff       	call   80107140 <inb>
801071f8:	83 c4 04             	add    $0x4,%esp
801071fb:	3c ff                	cmp    $0xff,%al
801071fd:	74 6e                	je     8010726d <uartinit+0xf1>
    return;
  uart = 1;
801071ff:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107206:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107209:	68 fa 03 00 00       	push   $0x3fa
8010720e:	e8 2d ff ff ff       	call   80107140 <inb>
80107213:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107216:	68 f8 03 00 00       	push   $0x3f8
8010721b:	e8 20 ff ff ff       	call   80107140 <inb>
80107220:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107223:	83 ec 0c             	sub    $0xc,%esp
80107226:	6a 04                	push   $0x4
80107228:	e8 79 d3 ff ff       	call   801045a6 <picenable>
8010722d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107230:	83 ec 08             	sub    $0x8,%esp
80107233:	6a 00                	push   $0x0
80107235:	6a 04                	push   $0x4
80107237:	e8 23 bf ff ff       	call   8010315f <ioapicenable>
8010723c:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010723f:	c7 45 f4 b8 92 10 80 	movl   $0x801092b8,-0xc(%ebp)
80107246:	eb 19                	jmp    80107261 <uartinit+0xe5>
    uartputc(*p);
80107248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724b:	0f b6 00             	movzbl (%eax),%eax
8010724e:	0f be c0             	movsbl %al,%eax
80107251:	83 ec 0c             	sub    $0xc,%esp
80107254:	50                   	push   %eax
80107255:	e8 16 00 00 00       	call   80107270 <uartputc>
8010725a:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010725d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107264:	0f b6 00             	movzbl (%eax),%eax
80107267:	84 c0                	test   %al,%al
80107269:	75 dd                	jne    80107248 <uartinit+0xcc>
8010726b:	eb 01                	jmp    8010726e <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010726d:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010726e:	c9                   	leave  
8010726f:	c3                   	ret    

80107270 <uartputc>:

void
uartputc(int c)
{
80107270:	55                   	push   %ebp
80107271:	89 e5                	mov    %esp,%ebp
80107273:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107276:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
8010727b:	85 c0                	test   %eax,%eax
8010727d:	74 53                	je     801072d2 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010727f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107286:	eb 11                	jmp    80107299 <uartputc+0x29>
    microdelay(10);
80107288:	83 ec 0c             	sub    $0xc,%esp
8010728b:	6a 0a                	push   $0xa
8010728d:	e8 33 c4 ff ff       	call   801036c5 <microdelay>
80107292:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107295:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107299:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010729d:	7f 1a                	jg     801072b9 <uartputc+0x49>
8010729f:	83 ec 0c             	sub    $0xc,%esp
801072a2:	68 fd 03 00 00       	push   $0x3fd
801072a7:	e8 94 fe ff ff       	call   80107140 <inb>
801072ac:	83 c4 10             	add    $0x10,%esp
801072af:	0f b6 c0             	movzbl %al,%eax
801072b2:	83 e0 20             	and    $0x20,%eax
801072b5:	85 c0                	test   %eax,%eax
801072b7:	74 cf                	je     80107288 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801072b9:	8b 45 08             	mov    0x8(%ebp),%eax
801072bc:	0f b6 c0             	movzbl %al,%eax
801072bf:	83 ec 08             	sub    $0x8,%esp
801072c2:	50                   	push   %eax
801072c3:	68 f8 03 00 00       	push   $0x3f8
801072c8:	e8 90 fe ff ff       	call   8010715d <outb>
801072cd:	83 c4 10             	add    $0x10,%esp
801072d0:	eb 01                	jmp    801072d3 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801072d2:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801072d3:	c9                   	leave  
801072d4:	c3                   	ret    

801072d5 <uartgetc>:

static int
uartgetc(void)
{
801072d5:	55                   	push   %ebp
801072d6:	89 e5                	mov    %esp,%ebp
  if(!uart)
801072d8:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801072dd:	85 c0                	test   %eax,%eax
801072df:	75 07                	jne    801072e8 <uartgetc+0x13>
    return -1;
801072e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072e6:	eb 2e                	jmp    80107316 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801072e8:	68 fd 03 00 00       	push   $0x3fd
801072ed:	e8 4e fe ff ff       	call   80107140 <inb>
801072f2:	83 c4 04             	add    $0x4,%esp
801072f5:	0f b6 c0             	movzbl %al,%eax
801072f8:	83 e0 01             	and    $0x1,%eax
801072fb:	85 c0                	test   %eax,%eax
801072fd:	75 07                	jne    80107306 <uartgetc+0x31>
    return -1;
801072ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107304:	eb 10                	jmp    80107316 <uartgetc+0x41>
  return inb(COM1+0);
80107306:	68 f8 03 00 00       	push   $0x3f8
8010730b:	e8 30 fe ff ff       	call   80107140 <inb>
80107310:	83 c4 04             	add    $0x4,%esp
80107313:	0f b6 c0             	movzbl %al,%eax
}
80107316:	c9                   	leave  
80107317:	c3                   	ret    

80107318 <uartintr>:

void
uartintr(void)
{
80107318:	55                   	push   %ebp
80107319:	89 e5                	mov    %esp,%ebp
8010731b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010731e:	83 ec 0c             	sub    $0xc,%esp
80107321:	68 d5 72 10 80       	push   $0x801072d5
80107326:	e8 ce 94 ff ff       	call   801007f9 <consoleintr>
8010732b:	83 c4 10             	add    $0x10,%esp
}
8010732e:	90                   	nop
8010732f:	c9                   	leave  
80107330:	c3                   	ret    

80107331 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $0
80107333:	6a 00                	push   $0x0
  jmp alltraps
80107335:	e9 a6 f9 ff ff       	jmp    80106ce0 <alltraps>

8010733a <vector1>:
.globl vector1
vector1:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $1
8010733c:	6a 01                	push   $0x1
  jmp alltraps
8010733e:	e9 9d f9 ff ff       	jmp    80106ce0 <alltraps>

80107343 <vector2>:
.globl vector2
vector2:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $2
80107345:	6a 02                	push   $0x2
  jmp alltraps
80107347:	e9 94 f9 ff ff       	jmp    80106ce0 <alltraps>

8010734c <vector3>:
.globl vector3
vector3:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $3
8010734e:	6a 03                	push   $0x3
  jmp alltraps
80107350:	e9 8b f9 ff ff       	jmp    80106ce0 <alltraps>

80107355 <vector4>:
.globl vector4
vector4:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $4
80107357:	6a 04                	push   $0x4
  jmp alltraps
80107359:	e9 82 f9 ff ff       	jmp    80106ce0 <alltraps>

8010735e <vector5>:
.globl vector5
vector5:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $5
80107360:	6a 05                	push   $0x5
  jmp alltraps
80107362:	e9 79 f9 ff ff       	jmp    80106ce0 <alltraps>

80107367 <vector6>:
.globl vector6
vector6:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $6
80107369:	6a 06                	push   $0x6
  jmp alltraps
8010736b:	e9 70 f9 ff ff       	jmp    80106ce0 <alltraps>

80107370 <vector7>:
.globl vector7
vector7:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $7
80107372:	6a 07                	push   $0x7
  jmp alltraps
80107374:	e9 67 f9 ff ff       	jmp    80106ce0 <alltraps>

80107379 <vector8>:
.globl vector8
vector8:
  pushl $8
80107379:	6a 08                	push   $0x8
  jmp alltraps
8010737b:	e9 60 f9 ff ff       	jmp    80106ce0 <alltraps>

80107380 <vector9>:
.globl vector9
vector9:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $9
80107382:	6a 09                	push   $0x9
  jmp alltraps
80107384:	e9 57 f9 ff ff       	jmp    80106ce0 <alltraps>

80107389 <vector10>:
.globl vector10
vector10:
  pushl $10
80107389:	6a 0a                	push   $0xa
  jmp alltraps
8010738b:	e9 50 f9 ff ff       	jmp    80106ce0 <alltraps>

80107390 <vector11>:
.globl vector11
vector11:
  pushl $11
80107390:	6a 0b                	push   $0xb
  jmp alltraps
80107392:	e9 49 f9 ff ff       	jmp    80106ce0 <alltraps>

80107397 <vector12>:
.globl vector12
vector12:
  pushl $12
80107397:	6a 0c                	push   $0xc
  jmp alltraps
80107399:	e9 42 f9 ff ff       	jmp    80106ce0 <alltraps>

8010739e <vector13>:
.globl vector13
vector13:
  pushl $13
8010739e:	6a 0d                	push   $0xd
  jmp alltraps
801073a0:	e9 3b f9 ff ff       	jmp    80106ce0 <alltraps>

801073a5 <vector14>:
.globl vector14
vector14:
  pushl $14
801073a5:	6a 0e                	push   $0xe
  jmp alltraps
801073a7:	e9 34 f9 ff ff       	jmp    80106ce0 <alltraps>

801073ac <vector15>:
.globl vector15
vector15:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $15
801073ae:	6a 0f                	push   $0xf
  jmp alltraps
801073b0:	e9 2b f9 ff ff       	jmp    80106ce0 <alltraps>

801073b5 <vector16>:
.globl vector16
vector16:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $16
801073b7:	6a 10                	push   $0x10
  jmp alltraps
801073b9:	e9 22 f9 ff ff       	jmp    80106ce0 <alltraps>

801073be <vector17>:
.globl vector17
vector17:
  pushl $17
801073be:	6a 11                	push   $0x11
  jmp alltraps
801073c0:	e9 1b f9 ff ff       	jmp    80106ce0 <alltraps>

801073c5 <vector18>:
.globl vector18
vector18:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $18
801073c7:	6a 12                	push   $0x12
  jmp alltraps
801073c9:	e9 12 f9 ff ff       	jmp    80106ce0 <alltraps>

801073ce <vector19>:
.globl vector19
vector19:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $19
801073d0:	6a 13                	push   $0x13
  jmp alltraps
801073d2:	e9 09 f9 ff ff       	jmp    80106ce0 <alltraps>

801073d7 <vector20>:
.globl vector20
vector20:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $20
801073d9:	6a 14                	push   $0x14
  jmp alltraps
801073db:	e9 00 f9 ff ff       	jmp    80106ce0 <alltraps>

801073e0 <vector21>:
.globl vector21
vector21:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $21
801073e2:	6a 15                	push   $0x15
  jmp alltraps
801073e4:	e9 f7 f8 ff ff       	jmp    80106ce0 <alltraps>

801073e9 <vector22>:
.globl vector22
vector22:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $22
801073eb:	6a 16                	push   $0x16
  jmp alltraps
801073ed:	e9 ee f8 ff ff       	jmp    80106ce0 <alltraps>

801073f2 <vector23>:
.globl vector23
vector23:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $23
801073f4:	6a 17                	push   $0x17
  jmp alltraps
801073f6:	e9 e5 f8 ff ff       	jmp    80106ce0 <alltraps>

801073fb <vector24>:
.globl vector24
vector24:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $24
801073fd:	6a 18                	push   $0x18
  jmp alltraps
801073ff:	e9 dc f8 ff ff       	jmp    80106ce0 <alltraps>

80107404 <vector25>:
.globl vector25
vector25:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $25
80107406:	6a 19                	push   $0x19
  jmp alltraps
80107408:	e9 d3 f8 ff ff       	jmp    80106ce0 <alltraps>

8010740d <vector26>:
.globl vector26
vector26:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $26
8010740f:	6a 1a                	push   $0x1a
  jmp alltraps
80107411:	e9 ca f8 ff ff       	jmp    80106ce0 <alltraps>

80107416 <vector27>:
.globl vector27
vector27:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $27
80107418:	6a 1b                	push   $0x1b
  jmp alltraps
8010741a:	e9 c1 f8 ff ff       	jmp    80106ce0 <alltraps>

8010741f <vector28>:
.globl vector28
vector28:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $28
80107421:	6a 1c                	push   $0x1c
  jmp alltraps
80107423:	e9 b8 f8 ff ff       	jmp    80106ce0 <alltraps>

80107428 <vector29>:
.globl vector29
vector29:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $29
8010742a:	6a 1d                	push   $0x1d
  jmp alltraps
8010742c:	e9 af f8 ff ff       	jmp    80106ce0 <alltraps>

80107431 <vector30>:
.globl vector30
vector30:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $30
80107433:	6a 1e                	push   $0x1e
  jmp alltraps
80107435:	e9 a6 f8 ff ff       	jmp    80106ce0 <alltraps>

8010743a <vector31>:
.globl vector31
vector31:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $31
8010743c:	6a 1f                	push   $0x1f
  jmp alltraps
8010743e:	e9 9d f8 ff ff       	jmp    80106ce0 <alltraps>

80107443 <vector32>:
.globl vector32
vector32:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $32
80107445:	6a 20                	push   $0x20
  jmp alltraps
80107447:	e9 94 f8 ff ff       	jmp    80106ce0 <alltraps>

8010744c <vector33>:
.globl vector33
vector33:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $33
8010744e:	6a 21                	push   $0x21
  jmp alltraps
80107450:	e9 8b f8 ff ff       	jmp    80106ce0 <alltraps>

80107455 <vector34>:
.globl vector34
vector34:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $34
80107457:	6a 22                	push   $0x22
  jmp alltraps
80107459:	e9 82 f8 ff ff       	jmp    80106ce0 <alltraps>

8010745e <vector35>:
.globl vector35
vector35:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $35
80107460:	6a 23                	push   $0x23
  jmp alltraps
80107462:	e9 79 f8 ff ff       	jmp    80106ce0 <alltraps>

80107467 <vector36>:
.globl vector36
vector36:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $36
80107469:	6a 24                	push   $0x24
  jmp alltraps
8010746b:	e9 70 f8 ff ff       	jmp    80106ce0 <alltraps>

80107470 <vector37>:
.globl vector37
vector37:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $37
80107472:	6a 25                	push   $0x25
  jmp alltraps
80107474:	e9 67 f8 ff ff       	jmp    80106ce0 <alltraps>

80107479 <vector38>:
.globl vector38
vector38:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $38
8010747b:	6a 26                	push   $0x26
  jmp alltraps
8010747d:	e9 5e f8 ff ff       	jmp    80106ce0 <alltraps>

80107482 <vector39>:
.globl vector39
vector39:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $39
80107484:	6a 27                	push   $0x27
  jmp alltraps
80107486:	e9 55 f8 ff ff       	jmp    80106ce0 <alltraps>

8010748b <vector40>:
.globl vector40
vector40:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $40
8010748d:	6a 28                	push   $0x28
  jmp alltraps
8010748f:	e9 4c f8 ff ff       	jmp    80106ce0 <alltraps>

80107494 <vector41>:
.globl vector41
vector41:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $41
80107496:	6a 29                	push   $0x29
  jmp alltraps
80107498:	e9 43 f8 ff ff       	jmp    80106ce0 <alltraps>

8010749d <vector42>:
.globl vector42
vector42:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $42
8010749f:	6a 2a                	push   $0x2a
  jmp alltraps
801074a1:	e9 3a f8 ff ff       	jmp    80106ce0 <alltraps>

801074a6 <vector43>:
.globl vector43
vector43:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $43
801074a8:	6a 2b                	push   $0x2b
  jmp alltraps
801074aa:	e9 31 f8 ff ff       	jmp    80106ce0 <alltraps>

801074af <vector44>:
.globl vector44
vector44:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $44
801074b1:	6a 2c                	push   $0x2c
  jmp alltraps
801074b3:	e9 28 f8 ff ff       	jmp    80106ce0 <alltraps>

801074b8 <vector45>:
.globl vector45
vector45:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $45
801074ba:	6a 2d                	push   $0x2d
  jmp alltraps
801074bc:	e9 1f f8 ff ff       	jmp    80106ce0 <alltraps>

801074c1 <vector46>:
.globl vector46
vector46:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $46
801074c3:	6a 2e                	push   $0x2e
  jmp alltraps
801074c5:	e9 16 f8 ff ff       	jmp    80106ce0 <alltraps>

801074ca <vector47>:
.globl vector47
vector47:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $47
801074cc:	6a 2f                	push   $0x2f
  jmp alltraps
801074ce:	e9 0d f8 ff ff       	jmp    80106ce0 <alltraps>

801074d3 <vector48>:
.globl vector48
vector48:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $48
801074d5:	6a 30                	push   $0x30
  jmp alltraps
801074d7:	e9 04 f8 ff ff       	jmp    80106ce0 <alltraps>

801074dc <vector49>:
.globl vector49
vector49:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $49
801074de:	6a 31                	push   $0x31
  jmp alltraps
801074e0:	e9 fb f7 ff ff       	jmp    80106ce0 <alltraps>

801074e5 <vector50>:
.globl vector50
vector50:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $50
801074e7:	6a 32                	push   $0x32
  jmp alltraps
801074e9:	e9 f2 f7 ff ff       	jmp    80106ce0 <alltraps>

801074ee <vector51>:
.globl vector51
vector51:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $51
801074f0:	6a 33                	push   $0x33
  jmp alltraps
801074f2:	e9 e9 f7 ff ff       	jmp    80106ce0 <alltraps>

801074f7 <vector52>:
.globl vector52
vector52:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $52
801074f9:	6a 34                	push   $0x34
  jmp alltraps
801074fb:	e9 e0 f7 ff ff       	jmp    80106ce0 <alltraps>

80107500 <vector53>:
.globl vector53
vector53:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $53
80107502:	6a 35                	push   $0x35
  jmp alltraps
80107504:	e9 d7 f7 ff ff       	jmp    80106ce0 <alltraps>

80107509 <vector54>:
.globl vector54
vector54:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $54
8010750b:	6a 36                	push   $0x36
  jmp alltraps
8010750d:	e9 ce f7 ff ff       	jmp    80106ce0 <alltraps>

80107512 <vector55>:
.globl vector55
vector55:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $55
80107514:	6a 37                	push   $0x37
  jmp alltraps
80107516:	e9 c5 f7 ff ff       	jmp    80106ce0 <alltraps>

8010751b <vector56>:
.globl vector56
vector56:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $56
8010751d:	6a 38                	push   $0x38
  jmp alltraps
8010751f:	e9 bc f7 ff ff       	jmp    80106ce0 <alltraps>

80107524 <vector57>:
.globl vector57
vector57:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $57
80107526:	6a 39                	push   $0x39
  jmp alltraps
80107528:	e9 b3 f7 ff ff       	jmp    80106ce0 <alltraps>

8010752d <vector58>:
.globl vector58
vector58:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $58
8010752f:	6a 3a                	push   $0x3a
  jmp alltraps
80107531:	e9 aa f7 ff ff       	jmp    80106ce0 <alltraps>

80107536 <vector59>:
.globl vector59
vector59:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $59
80107538:	6a 3b                	push   $0x3b
  jmp alltraps
8010753a:	e9 a1 f7 ff ff       	jmp    80106ce0 <alltraps>

8010753f <vector60>:
.globl vector60
vector60:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $60
80107541:	6a 3c                	push   $0x3c
  jmp alltraps
80107543:	e9 98 f7 ff ff       	jmp    80106ce0 <alltraps>

80107548 <vector61>:
.globl vector61
vector61:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $61
8010754a:	6a 3d                	push   $0x3d
  jmp alltraps
8010754c:	e9 8f f7 ff ff       	jmp    80106ce0 <alltraps>

80107551 <vector62>:
.globl vector62
vector62:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $62
80107553:	6a 3e                	push   $0x3e
  jmp alltraps
80107555:	e9 86 f7 ff ff       	jmp    80106ce0 <alltraps>

8010755a <vector63>:
.globl vector63
vector63:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $63
8010755c:	6a 3f                	push   $0x3f
  jmp alltraps
8010755e:	e9 7d f7 ff ff       	jmp    80106ce0 <alltraps>

80107563 <vector64>:
.globl vector64
vector64:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $64
80107565:	6a 40                	push   $0x40
  jmp alltraps
80107567:	e9 74 f7 ff ff       	jmp    80106ce0 <alltraps>

8010756c <vector65>:
.globl vector65
vector65:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $65
8010756e:	6a 41                	push   $0x41
  jmp alltraps
80107570:	e9 6b f7 ff ff       	jmp    80106ce0 <alltraps>

80107575 <vector66>:
.globl vector66
vector66:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $66
80107577:	6a 42                	push   $0x42
  jmp alltraps
80107579:	e9 62 f7 ff ff       	jmp    80106ce0 <alltraps>

8010757e <vector67>:
.globl vector67
vector67:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $67
80107580:	6a 43                	push   $0x43
  jmp alltraps
80107582:	e9 59 f7 ff ff       	jmp    80106ce0 <alltraps>

80107587 <vector68>:
.globl vector68
vector68:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $68
80107589:	6a 44                	push   $0x44
  jmp alltraps
8010758b:	e9 50 f7 ff ff       	jmp    80106ce0 <alltraps>

80107590 <vector69>:
.globl vector69
vector69:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $69
80107592:	6a 45                	push   $0x45
  jmp alltraps
80107594:	e9 47 f7 ff ff       	jmp    80106ce0 <alltraps>

80107599 <vector70>:
.globl vector70
vector70:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $70
8010759b:	6a 46                	push   $0x46
  jmp alltraps
8010759d:	e9 3e f7 ff ff       	jmp    80106ce0 <alltraps>

801075a2 <vector71>:
.globl vector71
vector71:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $71
801075a4:	6a 47                	push   $0x47
  jmp alltraps
801075a6:	e9 35 f7 ff ff       	jmp    80106ce0 <alltraps>

801075ab <vector72>:
.globl vector72
vector72:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $72
801075ad:	6a 48                	push   $0x48
  jmp alltraps
801075af:	e9 2c f7 ff ff       	jmp    80106ce0 <alltraps>

801075b4 <vector73>:
.globl vector73
vector73:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $73
801075b6:	6a 49                	push   $0x49
  jmp alltraps
801075b8:	e9 23 f7 ff ff       	jmp    80106ce0 <alltraps>

801075bd <vector74>:
.globl vector74
vector74:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $74
801075bf:	6a 4a                	push   $0x4a
  jmp alltraps
801075c1:	e9 1a f7 ff ff       	jmp    80106ce0 <alltraps>

801075c6 <vector75>:
.globl vector75
vector75:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $75
801075c8:	6a 4b                	push   $0x4b
  jmp alltraps
801075ca:	e9 11 f7 ff ff       	jmp    80106ce0 <alltraps>

801075cf <vector76>:
.globl vector76
vector76:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $76
801075d1:	6a 4c                	push   $0x4c
  jmp alltraps
801075d3:	e9 08 f7 ff ff       	jmp    80106ce0 <alltraps>

801075d8 <vector77>:
.globl vector77
vector77:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $77
801075da:	6a 4d                	push   $0x4d
  jmp alltraps
801075dc:	e9 ff f6 ff ff       	jmp    80106ce0 <alltraps>

801075e1 <vector78>:
.globl vector78
vector78:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $78
801075e3:	6a 4e                	push   $0x4e
  jmp alltraps
801075e5:	e9 f6 f6 ff ff       	jmp    80106ce0 <alltraps>

801075ea <vector79>:
.globl vector79
vector79:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $79
801075ec:	6a 4f                	push   $0x4f
  jmp alltraps
801075ee:	e9 ed f6 ff ff       	jmp    80106ce0 <alltraps>

801075f3 <vector80>:
.globl vector80
vector80:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $80
801075f5:	6a 50                	push   $0x50
  jmp alltraps
801075f7:	e9 e4 f6 ff ff       	jmp    80106ce0 <alltraps>

801075fc <vector81>:
.globl vector81
vector81:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $81
801075fe:	6a 51                	push   $0x51
  jmp alltraps
80107600:	e9 db f6 ff ff       	jmp    80106ce0 <alltraps>

80107605 <vector82>:
.globl vector82
vector82:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $82
80107607:	6a 52                	push   $0x52
  jmp alltraps
80107609:	e9 d2 f6 ff ff       	jmp    80106ce0 <alltraps>

8010760e <vector83>:
.globl vector83
vector83:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $83
80107610:	6a 53                	push   $0x53
  jmp alltraps
80107612:	e9 c9 f6 ff ff       	jmp    80106ce0 <alltraps>

80107617 <vector84>:
.globl vector84
vector84:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $84
80107619:	6a 54                	push   $0x54
  jmp alltraps
8010761b:	e9 c0 f6 ff ff       	jmp    80106ce0 <alltraps>

80107620 <vector85>:
.globl vector85
vector85:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $85
80107622:	6a 55                	push   $0x55
  jmp alltraps
80107624:	e9 b7 f6 ff ff       	jmp    80106ce0 <alltraps>

80107629 <vector86>:
.globl vector86
vector86:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $86
8010762b:	6a 56                	push   $0x56
  jmp alltraps
8010762d:	e9 ae f6 ff ff       	jmp    80106ce0 <alltraps>

80107632 <vector87>:
.globl vector87
vector87:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $87
80107634:	6a 57                	push   $0x57
  jmp alltraps
80107636:	e9 a5 f6 ff ff       	jmp    80106ce0 <alltraps>

8010763b <vector88>:
.globl vector88
vector88:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $88
8010763d:	6a 58                	push   $0x58
  jmp alltraps
8010763f:	e9 9c f6 ff ff       	jmp    80106ce0 <alltraps>

80107644 <vector89>:
.globl vector89
vector89:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $89
80107646:	6a 59                	push   $0x59
  jmp alltraps
80107648:	e9 93 f6 ff ff       	jmp    80106ce0 <alltraps>

8010764d <vector90>:
.globl vector90
vector90:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $90
8010764f:	6a 5a                	push   $0x5a
  jmp alltraps
80107651:	e9 8a f6 ff ff       	jmp    80106ce0 <alltraps>

80107656 <vector91>:
.globl vector91
vector91:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $91
80107658:	6a 5b                	push   $0x5b
  jmp alltraps
8010765a:	e9 81 f6 ff ff       	jmp    80106ce0 <alltraps>

8010765f <vector92>:
.globl vector92
vector92:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $92
80107661:	6a 5c                	push   $0x5c
  jmp alltraps
80107663:	e9 78 f6 ff ff       	jmp    80106ce0 <alltraps>

80107668 <vector93>:
.globl vector93
vector93:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $93
8010766a:	6a 5d                	push   $0x5d
  jmp alltraps
8010766c:	e9 6f f6 ff ff       	jmp    80106ce0 <alltraps>

80107671 <vector94>:
.globl vector94
vector94:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $94
80107673:	6a 5e                	push   $0x5e
  jmp alltraps
80107675:	e9 66 f6 ff ff       	jmp    80106ce0 <alltraps>

8010767a <vector95>:
.globl vector95
vector95:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $95
8010767c:	6a 5f                	push   $0x5f
  jmp alltraps
8010767e:	e9 5d f6 ff ff       	jmp    80106ce0 <alltraps>

80107683 <vector96>:
.globl vector96
vector96:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $96
80107685:	6a 60                	push   $0x60
  jmp alltraps
80107687:	e9 54 f6 ff ff       	jmp    80106ce0 <alltraps>

8010768c <vector97>:
.globl vector97
vector97:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $97
8010768e:	6a 61                	push   $0x61
  jmp alltraps
80107690:	e9 4b f6 ff ff       	jmp    80106ce0 <alltraps>

80107695 <vector98>:
.globl vector98
vector98:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $98
80107697:	6a 62                	push   $0x62
  jmp alltraps
80107699:	e9 42 f6 ff ff       	jmp    80106ce0 <alltraps>

8010769e <vector99>:
.globl vector99
vector99:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $99
801076a0:	6a 63                	push   $0x63
  jmp alltraps
801076a2:	e9 39 f6 ff ff       	jmp    80106ce0 <alltraps>

801076a7 <vector100>:
.globl vector100
vector100:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $100
801076a9:	6a 64                	push   $0x64
  jmp alltraps
801076ab:	e9 30 f6 ff ff       	jmp    80106ce0 <alltraps>

801076b0 <vector101>:
.globl vector101
vector101:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $101
801076b2:	6a 65                	push   $0x65
  jmp alltraps
801076b4:	e9 27 f6 ff ff       	jmp    80106ce0 <alltraps>

801076b9 <vector102>:
.globl vector102
vector102:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $102
801076bb:	6a 66                	push   $0x66
  jmp alltraps
801076bd:	e9 1e f6 ff ff       	jmp    80106ce0 <alltraps>

801076c2 <vector103>:
.globl vector103
vector103:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $103
801076c4:	6a 67                	push   $0x67
  jmp alltraps
801076c6:	e9 15 f6 ff ff       	jmp    80106ce0 <alltraps>

801076cb <vector104>:
.globl vector104
vector104:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $104
801076cd:	6a 68                	push   $0x68
  jmp alltraps
801076cf:	e9 0c f6 ff ff       	jmp    80106ce0 <alltraps>

801076d4 <vector105>:
.globl vector105
vector105:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $105
801076d6:	6a 69                	push   $0x69
  jmp alltraps
801076d8:	e9 03 f6 ff ff       	jmp    80106ce0 <alltraps>

801076dd <vector106>:
.globl vector106
vector106:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $106
801076df:	6a 6a                	push   $0x6a
  jmp alltraps
801076e1:	e9 fa f5 ff ff       	jmp    80106ce0 <alltraps>

801076e6 <vector107>:
.globl vector107
vector107:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $107
801076e8:	6a 6b                	push   $0x6b
  jmp alltraps
801076ea:	e9 f1 f5 ff ff       	jmp    80106ce0 <alltraps>

801076ef <vector108>:
.globl vector108
vector108:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $108
801076f1:	6a 6c                	push   $0x6c
  jmp alltraps
801076f3:	e9 e8 f5 ff ff       	jmp    80106ce0 <alltraps>

801076f8 <vector109>:
.globl vector109
vector109:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $109
801076fa:	6a 6d                	push   $0x6d
  jmp alltraps
801076fc:	e9 df f5 ff ff       	jmp    80106ce0 <alltraps>

80107701 <vector110>:
.globl vector110
vector110:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $110
80107703:	6a 6e                	push   $0x6e
  jmp alltraps
80107705:	e9 d6 f5 ff ff       	jmp    80106ce0 <alltraps>

8010770a <vector111>:
.globl vector111
vector111:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $111
8010770c:	6a 6f                	push   $0x6f
  jmp alltraps
8010770e:	e9 cd f5 ff ff       	jmp    80106ce0 <alltraps>

80107713 <vector112>:
.globl vector112
vector112:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $112
80107715:	6a 70                	push   $0x70
  jmp alltraps
80107717:	e9 c4 f5 ff ff       	jmp    80106ce0 <alltraps>

8010771c <vector113>:
.globl vector113
vector113:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $113
8010771e:	6a 71                	push   $0x71
  jmp alltraps
80107720:	e9 bb f5 ff ff       	jmp    80106ce0 <alltraps>

80107725 <vector114>:
.globl vector114
vector114:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $114
80107727:	6a 72                	push   $0x72
  jmp alltraps
80107729:	e9 b2 f5 ff ff       	jmp    80106ce0 <alltraps>

8010772e <vector115>:
.globl vector115
vector115:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $115
80107730:	6a 73                	push   $0x73
  jmp alltraps
80107732:	e9 a9 f5 ff ff       	jmp    80106ce0 <alltraps>

80107737 <vector116>:
.globl vector116
vector116:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $116
80107739:	6a 74                	push   $0x74
  jmp alltraps
8010773b:	e9 a0 f5 ff ff       	jmp    80106ce0 <alltraps>

80107740 <vector117>:
.globl vector117
vector117:
  pushl $0
80107740:	6a 00                	push   $0x0
  pushl $117
80107742:	6a 75                	push   $0x75
  jmp alltraps
80107744:	e9 97 f5 ff ff       	jmp    80106ce0 <alltraps>

80107749 <vector118>:
.globl vector118
vector118:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $118
8010774b:	6a 76                	push   $0x76
  jmp alltraps
8010774d:	e9 8e f5 ff ff       	jmp    80106ce0 <alltraps>

80107752 <vector119>:
.globl vector119
vector119:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $119
80107754:	6a 77                	push   $0x77
  jmp alltraps
80107756:	e9 85 f5 ff ff       	jmp    80106ce0 <alltraps>

8010775b <vector120>:
.globl vector120
vector120:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $120
8010775d:	6a 78                	push   $0x78
  jmp alltraps
8010775f:	e9 7c f5 ff ff       	jmp    80106ce0 <alltraps>

80107764 <vector121>:
.globl vector121
vector121:
  pushl $0
80107764:	6a 00                	push   $0x0
  pushl $121
80107766:	6a 79                	push   $0x79
  jmp alltraps
80107768:	e9 73 f5 ff ff       	jmp    80106ce0 <alltraps>

8010776d <vector122>:
.globl vector122
vector122:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $122
8010776f:	6a 7a                	push   $0x7a
  jmp alltraps
80107771:	e9 6a f5 ff ff       	jmp    80106ce0 <alltraps>

80107776 <vector123>:
.globl vector123
vector123:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $123
80107778:	6a 7b                	push   $0x7b
  jmp alltraps
8010777a:	e9 61 f5 ff ff       	jmp    80106ce0 <alltraps>

8010777f <vector124>:
.globl vector124
vector124:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $124
80107781:	6a 7c                	push   $0x7c
  jmp alltraps
80107783:	e9 58 f5 ff ff       	jmp    80106ce0 <alltraps>

80107788 <vector125>:
.globl vector125
vector125:
  pushl $0
80107788:	6a 00                	push   $0x0
  pushl $125
8010778a:	6a 7d                	push   $0x7d
  jmp alltraps
8010778c:	e9 4f f5 ff ff       	jmp    80106ce0 <alltraps>

80107791 <vector126>:
.globl vector126
vector126:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $126
80107793:	6a 7e                	push   $0x7e
  jmp alltraps
80107795:	e9 46 f5 ff ff       	jmp    80106ce0 <alltraps>

8010779a <vector127>:
.globl vector127
vector127:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $127
8010779c:	6a 7f                	push   $0x7f
  jmp alltraps
8010779e:	e9 3d f5 ff ff       	jmp    80106ce0 <alltraps>

801077a3 <vector128>:
.globl vector128
vector128:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $128
801077a5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801077aa:	e9 31 f5 ff ff       	jmp    80106ce0 <alltraps>

801077af <vector129>:
.globl vector129
vector129:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $129
801077b1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801077b6:	e9 25 f5 ff ff       	jmp    80106ce0 <alltraps>

801077bb <vector130>:
.globl vector130
vector130:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $130
801077bd:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801077c2:	e9 19 f5 ff ff       	jmp    80106ce0 <alltraps>

801077c7 <vector131>:
.globl vector131
vector131:
  pushl $0
801077c7:	6a 00                	push   $0x0
  pushl $131
801077c9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801077ce:	e9 0d f5 ff ff       	jmp    80106ce0 <alltraps>

801077d3 <vector132>:
.globl vector132
vector132:
  pushl $0
801077d3:	6a 00                	push   $0x0
  pushl $132
801077d5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801077da:	e9 01 f5 ff ff       	jmp    80106ce0 <alltraps>

801077df <vector133>:
.globl vector133
vector133:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $133
801077e1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801077e6:	e9 f5 f4 ff ff       	jmp    80106ce0 <alltraps>

801077eb <vector134>:
.globl vector134
vector134:
  pushl $0
801077eb:	6a 00                	push   $0x0
  pushl $134
801077ed:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801077f2:	e9 e9 f4 ff ff       	jmp    80106ce0 <alltraps>

801077f7 <vector135>:
.globl vector135
vector135:
  pushl $0
801077f7:	6a 00                	push   $0x0
  pushl $135
801077f9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801077fe:	e9 dd f4 ff ff       	jmp    80106ce0 <alltraps>

80107803 <vector136>:
.globl vector136
vector136:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $136
80107805:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010780a:	e9 d1 f4 ff ff       	jmp    80106ce0 <alltraps>

8010780f <vector137>:
.globl vector137
vector137:
  pushl $0
8010780f:	6a 00                	push   $0x0
  pushl $137
80107811:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107816:	e9 c5 f4 ff ff       	jmp    80106ce0 <alltraps>

8010781b <vector138>:
.globl vector138
vector138:
  pushl $0
8010781b:	6a 00                	push   $0x0
  pushl $138
8010781d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107822:	e9 b9 f4 ff ff       	jmp    80106ce0 <alltraps>

80107827 <vector139>:
.globl vector139
vector139:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $139
80107829:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010782e:	e9 ad f4 ff ff       	jmp    80106ce0 <alltraps>

80107833 <vector140>:
.globl vector140
vector140:
  pushl $0
80107833:	6a 00                	push   $0x0
  pushl $140
80107835:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010783a:	e9 a1 f4 ff ff       	jmp    80106ce0 <alltraps>

8010783f <vector141>:
.globl vector141
vector141:
  pushl $0
8010783f:	6a 00                	push   $0x0
  pushl $141
80107841:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107846:	e9 95 f4 ff ff       	jmp    80106ce0 <alltraps>

8010784b <vector142>:
.globl vector142
vector142:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $142
8010784d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107852:	e9 89 f4 ff ff       	jmp    80106ce0 <alltraps>

80107857 <vector143>:
.globl vector143
vector143:
  pushl $0
80107857:	6a 00                	push   $0x0
  pushl $143
80107859:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010785e:	e9 7d f4 ff ff       	jmp    80106ce0 <alltraps>

80107863 <vector144>:
.globl vector144
vector144:
  pushl $0
80107863:	6a 00                	push   $0x0
  pushl $144
80107865:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010786a:	e9 71 f4 ff ff       	jmp    80106ce0 <alltraps>

8010786f <vector145>:
.globl vector145
vector145:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $145
80107871:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107876:	e9 65 f4 ff ff       	jmp    80106ce0 <alltraps>

8010787b <vector146>:
.globl vector146
vector146:
  pushl $0
8010787b:	6a 00                	push   $0x0
  pushl $146
8010787d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107882:	e9 59 f4 ff ff       	jmp    80106ce0 <alltraps>

80107887 <vector147>:
.globl vector147
vector147:
  pushl $0
80107887:	6a 00                	push   $0x0
  pushl $147
80107889:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010788e:	e9 4d f4 ff ff       	jmp    80106ce0 <alltraps>

80107893 <vector148>:
.globl vector148
vector148:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $148
80107895:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010789a:	e9 41 f4 ff ff       	jmp    80106ce0 <alltraps>

8010789f <vector149>:
.globl vector149
vector149:
  pushl $0
8010789f:	6a 00                	push   $0x0
  pushl $149
801078a1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801078a6:	e9 35 f4 ff ff       	jmp    80106ce0 <alltraps>

801078ab <vector150>:
.globl vector150
vector150:
  pushl $0
801078ab:	6a 00                	push   $0x0
  pushl $150
801078ad:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801078b2:	e9 29 f4 ff ff       	jmp    80106ce0 <alltraps>

801078b7 <vector151>:
.globl vector151
vector151:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $151
801078b9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801078be:	e9 1d f4 ff ff       	jmp    80106ce0 <alltraps>

801078c3 <vector152>:
.globl vector152
vector152:
  pushl $0
801078c3:	6a 00                	push   $0x0
  pushl $152
801078c5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801078ca:	e9 11 f4 ff ff       	jmp    80106ce0 <alltraps>

801078cf <vector153>:
.globl vector153
vector153:
  pushl $0
801078cf:	6a 00                	push   $0x0
  pushl $153
801078d1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801078d6:	e9 05 f4 ff ff       	jmp    80106ce0 <alltraps>

801078db <vector154>:
.globl vector154
vector154:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $154
801078dd:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801078e2:	e9 f9 f3 ff ff       	jmp    80106ce0 <alltraps>

801078e7 <vector155>:
.globl vector155
vector155:
  pushl $0
801078e7:	6a 00                	push   $0x0
  pushl $155
801078e9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801078ee:	e9 ed f3 ff ff       	jmp    80106ce0 <alltraps>

801078f3 <vector156>:
.globl vector156
vector156:
  pushl $0
801078f3:	6a 00                	push   $0x0
  pushl $156
801078f5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801078fa:	e9 e1 f3 ff ff       	jmp    80106ce0 <alltraps>

801078ff <vector157>:
.globl vector157
vector157:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $157
80107901:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107906:	e9 d5 f3 ff ff       	jmp    80106ce0 <alltraps>

8010790b <vector158>:
.globl vector158
vector158:
  pushl $0
8010790b:	6a 00                	push   $0x0
  pushl $158
8010790d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107912:	e9 c9 f3 ff ff       	jmp    80106ce0 <alltraps>

80107917 <vector159>:
.globl vector159
vector159:
  pushl $0
80107917:	6a 00                	push   $0x0
  pushl $159
80107919:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010791e:	e9 bd f3 ff ff       	jmp    80106ce0 <alltraps>

80107923 <vector160>:
.globl vector160
vector160:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $160
80107925:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010792a:	e9 b1 f3 ff ff       	jmp    80106ce0 <alltraps>

8010792f <vector161>:
.globl vector161
vector161:
  pushl $0
8010792f:	6a 00                	push   $0x0
  pushl $161
80107931:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107936:	e9 a5 f3 ff ff       	jmp    80106ce0 <alltraps>

8010793b <vector162>:
.globl vector162
vector162:
  pushl $0
8010793b:	6a 00                	push   $0x0
  pushl $162
8010793d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107942:	e9 99 f3 ff ff       	jmp    80106ce0 <alltraps>

80107947 <vector163>:
.globl vector163
vector163:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $163
80107949:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010794e:	e9 8d f3 ff ff       	jmp    80106ce0 <alltraps>

80107953 <vector164>:
.globl vector164
vector164:
  pushl $0
80107953:	6a 00                	push   $0x0
  pushl $164
80107955:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010795a:	e9 81 f3 ff ff       	jmp    80106ce0 <alltraps>

8010795f <vector165>:
.globl vector165
vector165:
  pushl $0
8010795f:	6a 00                	push   $0x0
  pushl $165
80107961:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107966:	e9 75 f3 ff ff       	jmp    80106ce0 <alltraps>

8010796b <vector166>:
.globl vector166
vector166:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $166
8010796d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107972:	e9 69 f3 ff ff       	jmp    80106ce0 <alltraps>

80107977 <vector167>:
.globl vector167
vector167:
  pushl $0
80107977:	6a 00                	push   $0x0
  pushl $167
80107979:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010797e:	e9 5d f3 ff ff       	jmp    80106ce0 <alltraps>

80107983 <vector168>:
.globl vector168
vector168:
  pushl $0
80107983:	6a 00                	push   $0x0
  pushl $168
80107985:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010798a:	e9 51 f3 ff ff       	jmp    80106ce0 <alltraps>

8010798f <vector169>:
.globl vector169
vector169:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $169
80107991:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107996:	e9 45 f3 ff ff       	jmp    80106ce0 <alltraps>

8010799b <vector170>:
.globl vector170
vector170:
  pushl $0
8010799b:	6a 00                	push   $0x0
  pushl $170
8010799d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801079a2:	e9 39 f3 ff ff       	jmp    80106ce0 <alltraps>

801079a7 <vector171>:
.globl vector171
vector171:
  pushl $0
801079a7:	6a 00                	push   $0x0
  pushl $171
801079a9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801079ae:	e9 2d f3 ff ff       	jmp    80106ce0 <alltraps>

801079b3 <vector172>:
.globl vector172
vector172:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $172
801079b5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801079ba:	e9 21 f3 ff ff       	jmp    80106ce0 <alltraps>

801079bf <vector173>:
.globl vector173
vector173:
  pushl $0
801079bf:	6a 00                	push   $0x0
  pushl $173
801079c1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801079c6:	e9 15 f3 ff ff       	jmp    80106ce0 <alltraps>

801079cb <vector174>:
.globl vector174
vector174:
  pushl $0
801079cb:	6a 00                	push   $0x0
  pushl $174
801079cd:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801079d2:	e9 09 f3 ff ff       	jmp    80106ce0 <alltraps>

801079d7 <vector175>:
.globl vector175
vector175:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $175
801079d9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801079de:	e9 fd f2 ff ff       	jmp    80106ce0 <alltraps>

801079e3 <vector176>:
.globl vector176
vector176:
  pushl $0
801079e3:	6a 00                	push   $0x0
  pushl $176
801079e5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801079ea:	e9 f1 f2 ff ff       	jmp    80106ce0 <alltraps>

801079ef <vector177>:
.globl vector177
vector177:
  pushl $0
801079ef:	6a 00                	push   $0x0
  pushl $177
801079f1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801079f6:	e9 e5 f2 ff ff       	jmp    80106ce0 <alltraps>

801079fb <vector178>:
.globl vector178
vector178:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $178
801079fd:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107a02:	e9 d9 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a07 <vector179>:
.globl vector179
vector179:
  pushl $0
80107a07:	6a 00                	push   $0x0
  pushl $179
80107a09:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107a0e:	e9 cd f2 ff ff       	jmp    80106ce0 <alltraps>

80107a13 <vector180>:
.globl vector180
vector180:
  pushl $0
80107a13:	6a 00                	push   $0x0
  pushl $180
80107a15:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107a1a:	e9 c1 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a1f <vector181>:
.globl vector181
vector181:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $181
80107a21:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107a26:	e9 b5 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a2b <vector182>:
.globl vector182
vector182:
  pushl $0
80107a2b:	6a 00                	push   $0x0
  pushl $182
80107a2d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107a32:	e9 a9 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a37 <vector183>:
.globl vector183
vector183:
  pushl $0
80107a37:	6a 00                	push   $0x0
  pushl $183
80107a39:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107a3e:	e9 9d f2 ff ff       	jmp    80106ce0 <alltraps>

80107a43 <vector184>:
.globl vector184
vector184:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $184
80107a45:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107a4a:	e9 91 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a4f <vector185>:
.globl vector185
vector185:
  pushl $0
80107a4f:	6a 00                	push   $0x0
  pushl $185
80107a51:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107a56:	e9 85 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a5b <vector186>:
.globl vector186
vector186:
  pushl $0
80107a5b:	6a 00                	push   $0x0
  pushl $186
80107a5d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107a62:	e9 79 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a67 <vector187>:
.globl vector187
vector187:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $187
80107a69:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107a6e:	e9 6d f2 ff ff       	jmp    80106ce0 <alltraps>

80107a73 <vector188>:
.globl vector188
vector188:
  pushl $0
80107a73:	6a 00                	push   $0x0
  pushl $188
80107a75:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107a7a:	e9 61 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a7f <vector189>:
.globl vector189
vector189:
  pushl $0
80107a7f:	6a 00                	push   $0x0
  pushl $189
80107a81:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107a86:	e9 55 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a8b <vector190>:
.globl vector190
vector190:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $190
80107a8d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107a92:	e9 49 f2 ff ff       	jmp    80106ce0 <alltraps>

80107a97 <vector191>:
.globl vector191
vector191:
  pushl $0
80107a97:	6a 00                	push   $0x0
  pushl $191
80107a99:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107a9e:	e9 3d f2 ff ff       	jmp    80106ce0 <alltraps>

80107aa3 <vector192>:
.globl vector192
vector192:
  pushl $0
80107aa3:	6a 00                	push   $0x0
  pushl $192
80107aa5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107aaa:	e9 31 f2 ff ff       	jmp    80106ce0 <alltraps>

80107aaf <vector193>:
.globl vector193
vector193:
  pushl $0
80107aaf:	6a 00                	push   $0x0
  pushl $193
80107ab1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107ab6:	e9 25 f2 ff ff       	jmp    80106ce0 <alltraps>

80107abb <vector194>:
.globl vector194
vector194:
  pushl $0
80107abb:	6a 00                	push   $0x0
  pushl $194
80107abd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107ac2:	e9 19 f2 ff ff       	jmp    80106ce0 <alltraps>

80107ac7 <vector195>:
.globl vector195
vector195:
  pushl $0
80107ac7:	6a 00                	push   $0x0
  pushl $195
80107ac9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107ace:	e9 0d f2 ff ff       	jmp    80106ce0 <alltraps>

80107ad3 <vector196>:
.globl vector196
vector196:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $196
80107ad5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107ada:	e9 01 f2 ff ff       	jmp    80106ce0 <alltraps>

80107adf <vector197>:
.globl vector197
vector197:
  pushl $0
80107adf:	6a 00                	push   $0x0
  pushl $197
80107ae1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107ae6:	e9 f5 f1 ff ff       	jmp    80106ce0 <alltraps>

80107aeb <vector198>:
.globl vector198
vector198:
  pushl $0
80107aeb:	6a 00                	push   $0x0
  pushl $198
80107aed:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107af2:	e9 e9 f1 ff ff       	jmp    80106ce0 <alltraps>

80107af7 <vector199>:
.globl vector199
vector199:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $199
80107af9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107afe:	e9 dd f1 ff ff       	jmp    80106ce0 <alltraps>

80107b03 <vector200>:
.globl vector200
vector200:
  pushl $0
80107b03:	6a 00                	push   $0x0
  pushl $200
80107b05:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107b0a:	e9 d1 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b0f <vector201>:
.globl vector201
vector201:
  pushl $0
80107b0f:	6a 00                	push   $0x0
  pushl $201
80107b11:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107b16:	e9 c5 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b1b <vector202>:
.globl vector202
vector202:
  pushl $0
80107b1b:	6a 00                	push   $0x0
  pushl $202
80107b1d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107b22:	e9 b9 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b27 <vector203>:
.globl vector203
vector203:
  pushl $0
80107b27:	6a 00                	push   $0x0
  pushl $203
80107b29:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107b2e:	e9 ad f1 ff ff       	jmp    80106ce0 <alltraps>

80107b33 <vector204>:
.globl vector204
vector204:
  pushl $0
80107b33:	6a 00                	push   $0x0
  pushl $204
80107b35:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107b3a:	e9 a1 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b3f <vector205>:
.globl vector205
vector205:
  pushl $0
80107b3f:	6a 00                	push   $0x0
  pushl $205
80107b41:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107b46:	e9 95 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b4b <vector206>:
.globl vector206
vector206:
  pushl $0
80107b4b:	6a 00                	push   $0x0
  pushl $206
80107b4d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107b52:	e9 89 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b57 <vector207>:
.globl vector207
vector207:
  pushl $0
80107b57:	6a 00                	push   $0x0
  pushl $207
80107b59:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107b5e:	e9 7d f1 ff ff       	jmp    80106ce0 <alltraps>

80107b63 <vector208>:
.globl vector208
vector208:
  pushl $0
80107b63:	6a 00                	push   $0x0
  pushl $208
80107b65:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107b6a:	e9 71 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b6f <vector209>:
.globl vector209
vector209:
  pushl $0
80107b6f:	6a 00                	push   $0x0
  pushl $209
80107b71:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107b76:	e9 65 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b7b <vector210>:
.globl vector210
vector210:
  pushl $0
80107b7b:	6a 00                	push   $0x0
  pushl $210
80107b7d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107b82:	e9 59 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b87 <vector211>:
.globl vector211
vector211:
  pushl $0
80107b87:	6a 00                	push   $0x0
  pushl $211
80107b89:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107b8e:	e9 4d f1 ff ff       	jmp    80106ce0 <alltraps>

80107b93 <vector212>:
.globl vector212
vector212:
  pushl $0
80107b93:	6a 00                	push   $0x0
  pushl $212
80107b95:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107b9a:	e9 41 f1 ff ff       	jmp    80106ce0 <alltraps>

80107b9f <vector213>:
.globl vector213
vector213:
  pushl $0
80107b9f:	6a 00                	push   $0x0
  pushl $213
80107ba1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107ba6:	e9 35 f1 ff ff       	jmp    80106ce0 <alltraps>

80107bab <vector214>:
.globl vector214
vector214:
  pushl $0
80107bab:	6a 00                	push   $0x0
  pushl $214
80107bad:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107bb2:	e9 29 f1 ff ff       	jmp    80106ce0 <alltraps>

80107bb7 <vector215>:
.globl vector215
vector215:
  pushl $0
80107bb7:	6a 00                	push   $0x0
  pushl $215
80107bb9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107bbe:	e9 1d f1 ff ff       	jmp    80106ce0 <alltraps>

80107bc3 <vector216>:
.globl vector216
vector216:
  pushl $0
80107bc3:	6a 00                	push   $0x0
  pushl $216
80107bc5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107bca:	e9 11 f1 ff ff       	jmp    80106ce0 <alltraps>

80107bcf <vector217>:
.globl vector217
vector217:
  pushl $0
80107bcf:	6a 00                	push   $0x0
  pushl $217
80107bd1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107bd6:	e9 05 f1 ff ff       	jmp    80106ce0 <alltraps>

80107bdb <vector218>:
.globl vector218
vector218:
  pushl $0
80107bdb:	6a 00                	push   $0x0
  pushl $218
80107bdd:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107be2:	e9 f9 f0 ff ff       	jmp    80106ce0 <alltraps>

80107be7 <vector219>:
.globl vector219
vector219:
  pushl $0
80107be7:	6a 00                	push   $0x0
  pushl $219
80107be9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107bee:	e9 ed f0 ff ff       	jmp    80106ce0 <alltraps>

80107bf3 <vector220>:
.globl vector220
vector220:
  pushl $0
80107bf3:	6a 00                	push   $0x0
  pushl $220
80107bf5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107bfa:	e9 e1 f0 ff ff       	jmp    80106ce0 <alltraps>

80107bff <vector221>:
.globl vector221
vector221:
  pushl $0
80107bff:	6a 00                	push   $0x0
  pushl $221
80107c01:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107c06:	e9 d5 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c0b <vector222>:
.globl vector222
vector222:
  pushl $0
80107c0b:	6a 00                	push   $0x0
  pushl $222
80107c0d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107c12:	e9 c9 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c17 <vector223>:
.globl vector223
vector223:
  pushl $0
80107c17:	6a 00                	push   $0x0
  pushl $223
80107c19:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107c1e:	e9 bd f0 ff ff       	jmp    80106ce0 <alltraps>

80107c23 <vector224>:
.globl vector224
vector224:
  pushl $0
80107c23:	6a 00                	push   $0x0
  pushl $224
80107c25:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107c2a:	e9 b1 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c2f <vector225>:
.globl vector225
vector225:
  pushl $0
80107c2f:	6a 00                	push   $0x0
  pushl $225
80107c31:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107c36:	e9 a5 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c3b <vector226>:
.globl vector226
vector226:
  pushl $0
80107c3b:	6a 00                	push   $0x0
  pushl $226
80107c3d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107c42:	e9 99 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c47 <vector227>:
.globl vector227
vector227:
  pushl $0
80107c47:	6a 00                	push   $0x0
  pushl $227
80107c49:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107c4e:	e9 8d f0 ff ff       	jmp    80106ce0 <alltraps>

80107c53 <vector228>:
.globl vector228
vector228:
  pushl $0
80107c53:	6a 00                	push   $0x0
  pushl $228
80107c55:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107c5a:	e9 81 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c5f <vector229>:
.globl vector229
vector229:
  pushl $0
80107c5f:	6a 00                	push   $0x0
  pushl $229
80107c61:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107c66:	e9 75 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c6b <vector230>:
.globl vector230
vector230:
  pushl $0
80107c6b:	6a 00                	push   $0x0
  pushl $230
80107c6d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107c72:	e9 69 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c77 <vector231>:
.globl vector231
vector231:
  pushl $0
80107c77:	6a 00                	push   $0x0
  pushl $231
80107c79:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107c7e:	e9 5d f0 ff ff       	jmp    80106ce0 <alltraps>

80107c83 <vector232>:
.globl vector232
vector232:
  pushl $0
80107c83:	6a 00                	push   $0x0
  pushl $232
80107c85:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107c8a:	e9 51 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c8f <vector233>:
.globl vector233
vector233:
  pushl $0
80107c8f:	6a 00                	push   $0x0
  pushl $233
80107c91:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107c96:	e9 45 f0 ff ff       	jmp    80106ce0 <alltraps>

80107c9b <vector234>:
.globl vector234
vector234:
  pushl $0
80107c9b:	6a 00                	push   $0x0
  pushl $234
80107c9d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ca2:	e9 39 f0 ff ff       	jmp    80106ce0 <alltraps>

80107ca7 <vector235>:
.globl vector235
vector235:
  pushl $0
80107ca7:	6a 00                	push   $0x0
  pushl $235
80107ca9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107cae:	e9 2d f0 ff ff       	jmp    80106ce0 <alltraps>

80107cb3 <vector236>:
.globl vector236
vector236:
  pushl $0
80107cb3:	6a 00                	push   $0x0
  pushl $236
80107cb5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107cba:	e9 21 f0 ff ff       	jmp    80106ce0 <alltraps>

80107cbf <vector237>:
.globl vector237
vector237:
  pushl $0
80107cbf:	6a 00                	push   $0x0
  pushl $237
80107cc1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107cc6:	e9 15 f0 ff ff       	jmp    80106ce0 <alltraps>

80107ccb <vector238>:
.globl vector238
vector238:
  pushl $0
80107ccb:	6a 00                	push   $0x0
  pushl $238
80107ccd:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107cd2:	e9 09 f0 ff ff       	jmp    80106ce0 <alltraps>

80107cd7 <vector239>:
.globl vector239
vector239:
  pushl $0
80107cd7:	6a 00                	push   $0x0
  pushl $239
80107cd9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107cde:	e9 fd ef ff ff       	jmp    80106ce0 <alltraps>

80107ce3 <vector240>:
.globl vector240
vector240:
  pushl $0
80107ce3:	6a 00                	push   $0x0
  pushl $240
80107ce5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107cea:	e9 f1 ef ff ff       	jmp    80106ce0 <alltraps>

80107cef <vector241>:
.globl vector241
vector241:
  pushl $0
80107cef:	6a 00                	push   $0x0
  pushl $241
80107cf1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107cf6:	e9 e5 ef ff ff       	jmp    80106ce0 <alltraps>

80107cfb <vector242>:
.globl vector242
vector242:
  pushl $0
80107cfb:	6a 00                	push   $0x0
  pushl $242
80107cfd:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107d02:	e9 d9 ef ff ff       	jmp    80106ce0 <alltraps>

80107d07 <vector243>:
.globl vector243
vector243:
  pushl $0
80107d07:	6a 00                	push   $0x0
  pushl $243
80107d09:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107d0e:	e9 cd ef ff ff       	jmp    80106ce0 <alltraps>

80107d13 <vector244>:
.globl vector244
vector244:
  pushl $0
80107d13:	6a 00                	push   $0x0
  pushl $244
80107d15:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107d1a:	e9 c1 ef ff ff       	jmp    80106ce0 <alltraps>

80107d1f <vector245>:
.globl vector245
vector245:
  pushl $0
80107d1f:	6a 00                	push   $0x0
  pushl $245
80107d21:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107d26:	e9 b5 ef ff ff       	jmp    80106ce0 <alltraps>

80107d2b <vector246>:
.globl vector246
vector246:
  pushl $0
80107d2b:	6a 00                	push   $0x0
  pushl $246
80107d2d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107d32:	e9 a9 ef ff ff       	jmp    80106ce0 <alltraps>

80107d37 <vector247>:
.globl vector247
vector247:
  pushl $0
80107d37:	6a 00                	push   $0x0
  pushl $247
80107d39:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107d3e:	e9 9d ef ff ff       	jmp    80106ce0 <alltraps>

80107d43 <vector248>:
.globl vector248
vector248:
  pushl $0
80107d43:	6a 00                	push   $0x0
  pushl $248
80107d45:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107d4a:	e9 91 ef ff ff       	jmp    80106ce0 <alltraps>

80107d4f <vector249>:
.globl vector249
vector249:
  pushl $0
80107d4f:	6a 00                	push   $0x0
  pushl $249
80107d51:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107d56:	e9 85 ef ff ff       	jmp    80106ce0 <alltraps>

80107d5b <vector250>:
.globl vector250
vector250:
  pushl $0
80107d5b:	6a 00                	push   $0x0
  pushl $250
80107d5d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107d62:	e9 79 ef ff ff       	jmp    80106ce0 <alltraps>

80107d67 <vector251>:
.globl vector251
vector251:
  pushl $0
80107d67:	6a 00                	push   $0x0
  pushl $251
80107d69:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107d6e:	e9 6d ef ff ff       	jmp    80106ce0 <alltraps>

80107d73 <vector252>:
.globl vector252
vector252:
  pushl $0
80107d73:	6a 00                	push   $0x0
  pushl $252
80107d75:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107d7a:	e9 61 ef ff ff       	jmp    80106ce0 <alltraps>

80107d7f <vector253>:
.globl vector253
vector253:
  pushl $0
80107d7f:	6a 00                	push   $0x0
  pushl $253
80107d81:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107d86:	e9 55 ef ff ff       	jmp    80106ce0 <alltraps>

80107d8b <vector254>:
.globl vector254
vector254:
  pushl $0
80107d8b:	6a 00                	push   $0x0
  pushl $254
80107d8d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107d92:	e9 49 ef ff ff       	jmp    80106ce0 <alltraps>

80107d97 <vector255>:
.globl vector255
vector255:
  pushl $0
80107d97:	6a 00                	push   $0x0
  pushl $255
80107d99:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107d9e:	e9 3d ef ff ff       	jmp    80106ce0 <alltraps>

80107da3 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107da3:	55                   	push   %ebp
80107da4:	89 e5                	mov    %esp,%ebp
80107da6:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107da9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dac:	83 e8 01             	sub    $0x1,%eax
80107daf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107db3:	8b 45 08             	mov    0x8(%ebp),%eax
80107db6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107dba:	8b 45 08             	mov    0x8(%ebp),%eax
80107dbd:	c1 e8 10             	shr    $0x10,%eax
80107dc0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107dc4:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107dc7:	0f 01 10             	lgdtl  (%eax)
}
80107dca:	90                   	nop
80107dcb:	c9                   	leave  
80107dcc:	c3                   	ret    

80107dcd <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107dcd:	55                   	push   %ebp
80107dce:	89 e5                	mov    %esp,%ebp
80107dd0:	83 ec 04             	sub    $0x4,%esp
80107dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80107dd6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107dda:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107dde:	0f 00 d8             	ltr    %ax
}
80107de1:	90                   	nop
80107de2:	c9                   	leave  
80107de3:	c3                   	ret    

80107de4 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107de4:	55                   	push   %ebp
80107de5:	89 e5                	mov    %esp,%ebp
80107de7:	83 ec 04             	sub    $0x4,%esp
80107dea:	8b 45 08             	mov    0x8(%ebp),%eax
80107ded:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107df1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107df5:	8e e8                	mov    %eax,%gs
}
80107df7:	90                   	nop
80107df8:	c9                   	leave  
80107df9:	c3                   	ret    

80107dfa <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107dfa:	55                   	push   %ebp
80107dfb:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80107e00:	0f 22 d8             	mov    %eax,%cr3
}
80107e03:	90                   	nop
80107e04:	5d                   	pop    %ebp
80107e05:	c3                   	ret    

80107e06 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107e06:	55                   	push   %ebp
80107e07:	89 e5                	mov    %esp,%ebp
80107e09:	8b 45 08             	mov    0x8(%ebp),%eax
80107e0c:	05 00 00 00 80       	add    $0x80000000,%eax
80107e11:	5d                   	pop    %ebp
80107e12:	c3                   	ret    

80107e13 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107e13:	55                   	push   %ebp
80107e14:	89 e5                	mov    %esp,%ebp
80107e16:	8b 45 08             	mov    0x8(%ebp),%eax
80107e19:	05 00 00 00 80       	add    $0x80000000,%eax
80107e1e:	5d                   	pop    %ebp
80107e1f:	c3                   	ret    

80107e20 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107e20:	55                   	push   %ebp
80107e21:	89 e5                	mov    %esp,%ebp
80107e23:	53                   	push   %ebx
80107e24:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107e27:	e8 25 b8 ff ff       	call   80103651 <cpunum>
80107e2c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107e32:	05 20 36 11 80       	add    $0x80113620,%eax
80107e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e56:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e5a:	83 e2 f0             	and    $0xfffffff0,%edx
80107e5d:	83 ca 0a             	or     $0xa,%edx
80107e60:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e66:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e6a:	83 ca 10             	or     $0x10,%edx
80107e6d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e73:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e77:	83 e2 9f             	and    $0xffffff9f,%edx
80107e7a:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e84:	83 ca 80             	or     $0xffffff80,%edx
80107e87:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e91:	83 ca 0f             	or     $0xf,%edx
80107e94:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e9e:	83 e2 ef             	and    $0xffffffef,%edx
80107ea1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107eab:	83 e2 df             	and    $0xffffffdf,%edx
80107eae:	88 50 7e             	mov    %dl,0x7e(%eax)
80107eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107eb8:	83 ca 40             	or     $0x40,%edx
80107ebb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ec5:	83 ca 80             	or     $0xffffff80,%edx
80107ec8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ece:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107edc:	ff ff 
80107ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee1:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ee8:	00 00 
80107eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eed:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107efe:	83 e2 f0             	and    $0xfffffff0,%edx
80107f01:	83 ca 02             	or     $0x2,%edx
80107f04:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f14:	83 ca 10             	or     $0x10,%edx
80107f17:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f27:	83 e2 9f             	and    $0xffffff9f,%edx
80107f2a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f33:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f3a:	83 ca 80             	or     $0xffffff80,%edx
80107f3d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f4d:	83 ca 0f             	or     $0xf,%edx
80107f50:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f59:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f60:	83 e2 ef             	and    $0xffffffef,%edx
80107f63:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f73:	83 e2 df             	and    $0xffffffdf,%edx
80107f76:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f86:	83 ca 40             	or     $0x40,%edx
80107f89:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f92:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f99:	83 ca 80             	or     $0xffffff80,%edx
80107f9c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa5:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107fb6:	ff ff 
80107fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbb:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107fc2:	00 00 
80107fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc7:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fd8:	83 e2 f0             	and    $0xfffffff0,%edx
80107fdb:	83 ca 0a             	or     $0xa,%edx
80107fde:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fee:	83 ca 10             	or     $0x10,%edx
80107ff1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffa:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108001:	83 ca 60             	or     $0x60,%edx
80108004:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010800a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108014:	83 ca 80             	or     $0xffffff80,%edx
80108017:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010801d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108020:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108027:	83 ca 0f             	or     $0xf,%edx
8010802a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108033:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010803a:	83 e2 ef             	and    $0xffffffef,%edx
8010803d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108046:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010804d:	83 e2 df             	and    $0xffffffdf,%edx
80108050:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108059:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108060:	83 ca 40             	or     $0x40,%edx
80108063:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108073:	83 ca 80             	or     $0xffffff80,%edx
80108076:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010807c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807f:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108089:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108090:	ff ff 
80108092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108095:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010809c:	00 00 
8010809e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a1:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801080a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ab:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080b2:	83 e2 f0             	and    $0xfffffff0,%edx
801080b5:	83 ca 02             	or     $0x2,%edx
801080b8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080c8:	83 ca 10             	or     $0x10,%edx
801080cb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080db:	83 ca 60             	or     $0x60,%edx
801080de:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080ee:	83 ca 80             	or     $0xffffff80,%edx
801080f1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fa:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108101:	83 ca 0f             	or     $0xf,%edx
80108104:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010810a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108114:	83 e2 ef             	and    $0xffffffef,%edx
80108117:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010811d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108120:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108127:	83 e2 df             	and    $0xffffffdf,%edx
8010812a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108133:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010813a:	83 ca 40             	or     $0x40,%edx
8010813d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108146:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010814d:	83 ca 80             	or     $0xffffff80,%edx
80108150:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108159:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108163:	05 b4 00 00 00       	add    $0xb4,%eax
80108168:	89 c3                	mov    %eax,%ebx
8010816a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816d:	05 b4 00 00 00       	add    $0xb4,%eax
80108172:	c1 e8 10             	shr    $0x10,%eax
80108175:	89 c2                	mov    %eax,%edx
80108177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817a:	05 b4 00 00 00       	add    $0xb4,%eax
8010817f:	c1 e8 18             	shr    $0x18,%eax
80108182:	89 c1                	mov    %eax,%ecx
80108184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108187:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010818e:	00 00 
80108190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108193:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010819a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819d:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801081a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801081ad:	83 e2 f0             	and    $0xfffffff0,%edx
801081b0:	83 ca 02             	or     $0x2,%edx
801081b3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801081b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801081c3:	83 ca 10             	or     $0x10,%edx
801081c6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801081cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081cf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801081d6:	83 e2 9f             	and    $0xffffff9f,%edx
801081d9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801081df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801081e9:	83 ca 80             	or     $0xffffff80,%edx
801081ec:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801081fc:	83 e2 f0             	and    $0xfffffff0,%edx
801081ff:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108208:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010820f:	83 e2 ef             	and    $0xffffffef,%edx
80108212:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108222:	83 e2 df             	and    $0xffffffdf,%edx
80108225:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010822b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108235:	83 ca 40             	or     $0x40,%edx
80108238:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010823e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108241:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108248:	83 ca 80             	or     $0xffffff80,%edx
8010824b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108254:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010825a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825d:	83 c0 70             	add    $0x70,%eax
80108260:	83 ec 08             	sub    $0x8,%esp
80108263:	6a 38                	push   $0x38
80108265:	50                   	push   %eax
80108266:	e8 38 fb ff ff       	call   80107da3 <lgdt>
8010826b:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
8010826e:	83 ec 0c             	sub    $0xc,%esp
80108271:	6a 18                	push   $0x18
80108273:	e8 6c fb ff ff       	call   80107de4 <loadgs>
80108278:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
8010827b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827e:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108284:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010828b:	00 00 00 00 
}
8010828f:	90                   	nop
80108290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108293:	c9                   	leave  
80108294:	c3                   	ret    

80108295 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108295:	55                   	push   %ebp
80108296:	89 e5                	mov    %esp,%ebp
80108298:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010829b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010829e:	c1 e8 16             	shr    $0x16,%eax
801082a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082a8:	8b 45 08             	mov    0x8(%ebp),%eax
801082ab:	01 d0                	add    %edx,%eax
801082ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801082b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b3:	8b 00                	mov    (%eax),%eax
801082b5:	83 e0 01             	and    $0x1,%eax
801082b8:	85 c0                	test   %eax,%eax
801082ba:	74 18                	je     801082d4 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801082bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082bf:	8b 00                	mov    (%eax),%eax
801082c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082c6:	50                   	push   %eax
801082c7:	e8 47 fb ff ff       	call   80107e13 <p2v>
801082cc:	83 c4 04             	add    $0x4,%esp
801082cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082d2:	eb 48                	jmp    8010831c <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801082d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801082d8:	74 0e                	je     801082e8 <walkpgdir+0x53>
801082da:	e8 0c b0 ff ff       	call   801032eb <kalloc>
801082df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082e6:	75 07                	jne    801082ef <walkpgdir+0x5a>
      return 0;
801082e8:	b8 00 00 00 00       	mov    $0x0,%eax
801082ed:	eb 44                	jmp    80108333 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801082ef:	83 ec 04             	sub    $0x4,%esp
801082f2:	68 00 10 00 00       	push   $0x1000
801082f7:	6a 00                	push   $0x0
801082f9:	ff 75 f4             	pushl  -0xc(%ebp)
801082fc:	e8 19 d6 ff ff       	call   8010591a <memset>
80108301:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108304:	83 ec 0c             	sub    $0xc,%esp
80108307:	ff 75 f4             	pushl  -0xc(%ebp)
8010830a:	e8 f7 fa ff ff       	call   80107e06 <v2p>
8010830f:	83 c4 10             	add    $0x10,%esp
80108312:	83 c8 07             	or     $0x7,%eax
80108315:	89 c2                	mov    %eax,%edx
80108317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010831a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010831c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010831f:	c1 e8 0c             	shr    $0xc,%eax
80108322:	25 ff 03 00 00       	and    $0x3ff,%eax
80108327:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010832e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108331:	01 d0                	add    %edx,%eax
}
80108333:	c9                   	leave  
80108334:	c3                   	ret    

80108335 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108335:	55                   	push   %ebp
80108336:	89 e5                	mov    %esp,%ebp
80108338:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010833b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010833e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108343:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108346:	8b 55 0c             	mov    0xc(%ebp),%edx
80108349:	8b 45 10             	mov    0x10(%ebp),%eax
8010834c:	01 d0                	add    %edx,%eax
8010834e:	83 e8 01             	sub    $0x1,%eax
80108351:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108356:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108359:	83 ec 04             	sub    $0x4,%esp
8010835c:	6a 01                	push   $0x1
8010835e:	ff 75 f4             	pushl  -0xc(%ebp)
80108361:	ff 75 08             	pushl  0x8(%ebp)
80108364:	e8 2c ff ff ff       	call   80108295 <walkpgdir>
80108369:	83 c4 10             	add    $0x10,%esp
8010836c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010836f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108373:	75 07                	jne    8010837c <mappages+0x47>
      return -1;
80108375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010837a:	eb 47                	jmp    801083c3 <mappages+0x8e>
    if(*pte & PTE_P)
8010837c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010837f:	8b 00                	mov    (%eax),%eax
80108381:	83 e0 01             	and    $0x1,%eax
80108384:	85 c0                	test   %eax,%eax
80108386:	74 0d                	je     80108395 <mappages+0x60>
      panic("remap");
80108388:	83 ec 0c             	sub    $0xc,%esp
8010838b:	68 c0 92 10 80       	push   $0x801092c0
80108390:	e8 d1 81 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108395:	8b 45 18             	mov    0x18(%ebp),%eax
80108398:	0b 45 14             	or     0x14(%ebp),%eax
8010839b:	83 c8 01             	or     $0x1,%eax
8010839e:	89 c2                	mov    %eax,%edx
801083a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a3:	89 10                	mov    %edx,(%eax)
    if(a == last)
801083a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083ab:	74 10                	je     801083bd <mappages+0x88>
      break;
    a += PGSIZE;
801083ad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801083b4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801083bb:	eb 9c                	jmp    80108359 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801083bd:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801083be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083c3:	c9                   	leave  
801083c4:	c3                   	ret    

801083c5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801083c5:	55                   	push   %ebp
801083c6:	89 e5                	mov    %esp,%ebp
801083c8:	53                   	push   %ebx
801083c9:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801083cc:	e8 1a af ff ff       	call   801032eb <kalloc>
801083d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083d8:	75 0a                	jne    801083e4 <setupkvm+0x1f>
    return 0;
801083da:	b8 00 00 00 00       	mov    $0x0,%eax
801083df:	e9 8e 00 00 00       	jmp    80108472 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
801083e4:	83 ec 04             	sub    $0x4,%esp
801083e7:	68 00 10 00 00       	push   $0x1000
801083ec:	6a 00                	push   $0x0
801083ee:	ff 75 f0             	pushl  -0x10(%ebp)
801083f1:	e8 24 d5 ff ff       	call   8010591a <memset>
801083f6:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801083f9:	83 ec 0c             	sub    $0xc,%esp
801083fc:	68 00 00 00 0e       	push   $0xe000000
80108401:	e8 0d fa ff ff       	call   80107e13 <p2v>
80108406:	83 c4 10             	add    $0x10,%esp
80108409:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010840e:	76 0d                	jbe    8010841d <setupkvm+0x58>
    panic("PHYSTOP too high");
80108410:	83 ec 0c             	sub    $0xc,%esp
80108413:	68 c6 92 10 80       	push   $0x801092c6
80108418:	e8 49 81 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010841d:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108424:	eb 40                	jmp    80108466 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108429:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010842c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842f:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108435:	8b 58 08             	mov    0x8(%eax),%ebx
80108438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843b:	8b 40 04             	mov    0x4(%eax),%eax
8010843e:	29 c3                	sub    %eax,%ebx
80108440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108443:	8b 00                	mov    (%eax),%eax
80108445:	83 ec 0c             	sub    $0xc,%esp
80108448:	51                   	push   %ecx
80108449:	52                   	push   %edx
8010844a:	53                   	push   %ebx
8010844b:	50                   	push   %eax
8010844c:	ff 75 f0             	pushl  -0x10(%ebp)
8010844f:	e8 e1 fe ff ff       	call   80108335 <mappages>
80108454:	83 c4 20             	add    $0x20,%esp
80108457:	85 c0                	test   %eax,%eax
80108459:	79 07                	jns    80108462 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
8010845b:	b8 00 00 00 00       	mov    $0x0,%eax
80108460:	eb 10                	jmp    80108472 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108462:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108466:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
8010846d:	72 b7                	jb     80108426 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010846f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108475:	c9                   	leave  
80108476:	c3                   	ret    

80108477 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108477:	55                   	push   %ebp
80108478:	89 e5                	mov    %esp,%ebp
8010847a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010847d:	e8 43 ff ff ff       	call   801083c5 <setupkvm>
80108482:	a3 f8 63 11 80       	mov    %eax,0x801163f8
  switchkvm();
80108487:	e8 03 00 00 00       	call   8010848f <switchkvm>
}
8010848c:	90                   	nop
8010848d:	c9                   	leave  
8010848e:	c3                   	ret    

8010848f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010848f:	55                   	push   %ebp
80108490:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108492:	a1 f8 63 11 80       	mov    0x801163f8,%eax
80108497:	50                   	push   %eax
80108498:	e8 69 f9 ff ff       	call   80107e06 <v2p>
8010849d:	83 c4 04             	add    $0x4,%esp
801084a0:	50                   	push   %eax
801084a1:	e8 54 f9 ff ff       	call   80107dfa <lcr3>
801084a6:	83 c4 04             	add    $0x4,%esp
}
801084a9:	90                   	nop
801084aa:	c9                   	leave  
801084ab:	c3                   	ret    

801084ac <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801084ac:	55                   	push   %ebp
801084ad:	89 e5                	mov    %esp,%ebp
801084af:	56                   	push   %esi
801084b0:	53                   	push   %ebx
  pushcli();
801084b1:	e8 5e d3 ff ff       	call   80105814 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801084b6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084bc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084c3:	83 c2 08             	add    $0x8,%edx
801084c6:	89 d6                	mov    %edx,%esi
801084c8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084cf:	83 c2 08             	add    $0x8,%edx
801084d2:	c1 ea 10             	shr    $0x10,%edx
801084d5:	89 d3                	mov    %edx,%ebx
801084d7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084de:	83 c2 08             	add    $0x8,%edx
801084e1:	c1 ea 18             	shr    $0x18,%edx
801084e4:	89 d1                	mov    %edx,%ecx
801084e6:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801084ed:	67 00 
801084ef:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
801084f6:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
801084fc:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108503:	83 e2 f0             	and    $0xfffffff0,%edx
80108506:	83 ca 09             	or     $0x9,%edx
80108509:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010850f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108516:	83 ca 10             	or     $0x10,%edx
80108519:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010851f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108526:	83 e2 9f             	and    $0xffffff9f,%edx
80108529:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010852f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108536:	83 ca 80             	or     $0xffffff80,%edx
80108539:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010853f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108546:	83 e2 f0             	and    $0xfffffff0,%edx
80108549:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010854f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108556:	83 e2 ef             	and    $0xffffffef,%edx
80108559:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010855f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108566:	83 e2 df             	and    $0xffffffdf,%edx
80108569:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010856f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108576:	83 ca 40             	or     $0x40,%edx
80108579:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010857f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108586:	83 e2 7f             	and    $0x7f,%edx
80108589:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010858f:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108595:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010859b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801085a2:	83 e2 ef             	and    $0xffffffef,%edx
801085a5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801085ab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085b1:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801085b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085bd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801085c4:	8b 52 08             	mov    0x8(%edx),%edx
801085c7:	81 c2 00 10 00 00    	add    $0x1000,%edx
801085cd:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801085d0:	83 ec 0c             	sub    $0xc,%esp
801085d3:	6a 30                	push   $0x30
801085d5:	e8 f3 f7 ff ff       	call   80107dcd <ltr>
801085da:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
801085dd:	8b 45 08             	mov    0x8(%ebp),%eax
801085e0:	8b 40 04             	mov    0x4(%eax),%eax
801085e3:	85 c0                	test   %eax,%eax
801085e5:	75 0d                	jne    801085f4 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
801085e7:	83 ec 0c             	sub    $0xc,%esp
801085ea:	68 d7 92 10 80       	push   $0x801092d7
801085ef:	e8 72 7f ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801085f4:	8b 45 08             	mov    0x8(%ebp),%eax
801085f7:	8b 40 04             	mov    0x4(%eax),%eax
801085fa:	83 ec 0c             	sub    $0xc,%esp
801085fd:	50                   	push   %eax
801085fe:	e8 03 f8 ff ff       	call   80107e06 <v2p>
80108603:	83 c4 10             	add    $0x10,%esp
80108606:	83 ec 0c             	sub    $0xc,%esp
80108609:	50                   	push   %eax
8010860a:	e8 eb f7 ff ff       	call   80107dfa <lcr3>
8010860f:	83 c4 10             	add    $0x10,%esp
  popcli();
80108612:	e8 42 d2 ff ff       	call   80105859 <popcli>
}
80108617:	90                   	nop
80108618:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010861b:	5b                   	pop    %ebx
8010861c:	5e                   	pop    %esi
8010861d:	5d                   	pop    %ebp
8010861e:	c3                   	ret    

8010861f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010861f:	55                   	push   %ebp
80108620:	89 e5                	mov    %esp,%ebp
80108622:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108625:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010862c:	76 0d                	jbe    8010863b <inituvm+0x1c>
    panic("inituvm: more than a page");
8010862e:	83 ec 0c             	sub    $0xc,%esp
80108631:	68 eb 92 10 80       	push   $0x801092eb
80108636:	e8 2b 7f ff ff       	call   80100566 <panic>
  mem = kalloc();
8010863b:	e8 ab ac ff ff       	call   801032eb <kalloc>
80108640:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108643:	83 ec 04             	sub    $0x4,%esp
80108646:	68 00 10 00 00       	push   $0x1000
8010864b:	6a 00                	push   $0x0
8010864d:	ff 75 f4             	pushl  -0xc(%ebp)
80108650:	e8 c5 d2 ff ff       	call   8010591a <memset>
80108655:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108658:	83 ec 0c             	sub    $0xc,%esp
8010865b:	ff 75 f4             	pushl  -0xc(%ebp)
8010865e:	e8 a3 f7 ff ff       	call   80107e06 <v2p>
80108663:	83 c4 10             	add    $0x10,%esp
80108666:	83 ec 0c             	sub    $0xc,%esp
80108669:	6a 06                	push   $0x6
8010866b:	50                   	push   %eax
8010866c:	68 00 10 00 00       	push   $0x1000
80108671:	6a 00                	push   $0x0
80108673:	ff 75 08             	pushl  0x8(%ebp)
80108676:	e8 ba fc ff ff       	call   80108335 <mappages>
8010867b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010867e:	83 ec 04             	sub    $0x4,%esp
80108681:	ff 75 10             	pushl  0x10(%ebp)
80108684:	ff 75 0c             	pushl  0xc(%ebp)
80108687:	ff 75 f4             	pushl  -0xc(%ebp)
8010868a:	e8 4a d3 ff ff       	call   801059d9 <memmove>
8010868f:	83 c4 10             	add    $0x10,%esp
}
80108692:	90                   	nop
80108693:	c9                   	leave  
80108694:	c3                   	ret    

80108695 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108695:	55                   	push   %ebp
80108696:	89 e5                	mov    %esp,%ebp
80108698:	53                   	push   %ebx
80108699:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010869c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010869f:	25 ff 0f 00 00       	and    $0xfff,%eax
801086a4:	85 c0                	test   %eax,%eax
801086a6:	74 0d                	je     801086b5 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801086a8:	83 ec 0c             	sub    $0xc,%esp
801086ab:	68 08 93 10 80       	push   $0x80109308
801086b0:	e8 b1 7e ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801086b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086bc:	e9 95 00 00 00       	jmp    80108756 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801086c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801086c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c7:	01 d0                	add    %edx,%eax
801086c9:	83 ec 04             	sub    $0x4,%esp
801086cc:	6a 00                	push   $0x0
801086ce:	50                   	push   %eax
801086cf:	ff 75 08             	pushl  0x8(%ebp)
801086d2:	e8 be fb ff ff       	call   80108295 <walkpgdir>
801086d7:	83 c4 10             	add    $0x10,%esp
801086da:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086e1:	75 0d                	jne    801086f0 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801086e3:	83 ec 0c             	sub    $0xc,%esp
801086e6:	68 2b 93 10 80       	push   $0x8010932b
801086eb:	e8 76 7e ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801086f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f3:	8b 00                	mov    (%eax),%eax
801086f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801086fd:	8b 45 18             	mov    0x18(%ebp),%eax
80108700:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108703:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108708:	77 0b                	ja     80108715 <loaduvm+0x80>
      n = sz - i;
8010870a:	8b 45 18             	mov    0x18(%ebp),%eax
8010870d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108710:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108713:	eb 07                	jmp    8010871c <loaduvm+0x87>
    else
      n = PGSIZE;
80108715:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010871c:	8b 55 14             	mov    0x14(%ebp),%edx
8010871f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108722:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108725:	83 ec 0c             	sub    $0xc,%esp
80108728:	ff 75 e8             	pushl  -0x18(%ebp)
8010872b:	e8 e3 f6 ff ff       	call   80107e13 <p2v>
80108730:	83 c4 10             	add    $0x10,%esp
80108733:	ff 75 f0             	pushl  -0x10(%ebp)
80108736:	53                   	push   %ebx
80108737:	50                   	push   %eax
80108738:	ff 75 10             	pushl  0x10(%ebp)
8010873b:	e8 58 9d ff ff       	call   80102498 <readi>
80108740:	83 c4 10             	add    $0x10,%esp
80108743:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108746:	74 07                	je     8010874f <loaduvm+0xba>
      return -1;
80108748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010874d:	eb 18                	jmp    80108767 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010874f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108759:	3b 45 18             	cmp    0x18(%ebp),%eax
8010875c:	0f 82 5f ff ff ff    	jb     801086c1 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108762:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010876a:	c9                   	leave  
8010876b:	c3                   	ret    

8010876c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010876c:	55                   	push   %ebp
8010876d:	89 e5                	mov    %esp,%ebp
8010876f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108772:	8b 45 10             	mov    0x10(%ebp),%eax
80108775:	85 c0                	test   %eax,%eax
80108777:	79 0a                	jns    80108783 <allocuvm+0x17>
    return 0;
80108779:	b8 00 00 00 00       	mov    $0x0,%eax
8010877e:	e9 b0 00 00 00       	jmp    80108833 <allocuvm+0xc7>
  if(newsz < oldsz)
80108783:	8b 45 10             	mov    0x10(%ebp),%eax
80108786:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108789:	73 08                	jae    80108793 <allocuvm+0x27>
    return oldsz;
8010878b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010878e:	e9 a0 00 00 00       	jmp    80108833 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108793:	8b 45 0c             	mov    0xc(%ebp),%eax
80108796:	05 ff 0f 00 00       	add    $0xfff,%eax
8010879b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801087a3:	eb 7f                	jmp    80108824 <allocuvm+0xb8>
    mem = kalloc();
801087a5:	e8 41 ab ff ff       	call   801032eb <kalloc>
801087aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801087ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087b1:	75 2b                	jne    801087de <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801087b3:	83 ec 0c             	sub    $0xc,%esp
801087b6:	68 49 93 10 80       	push   $0x80109349
801087bb:	e8 06 7c ff ff       	call   801003c6 <cprintf>
801087c0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801087c3:	83 ec 04             	sub    $0x4,%esp
801087c6:	ff 75 0c             	pushl  0xc(%ebp)
801087c9:	ff 75 10             	pushl  0x10(%ebp)
801087cc:	ff 75 08             	pushl  0x8(%ebp)
801087cf:	e8 61 00 00 00       	call   80108835 <deallocuvm>
801087d4:	83 c4 10             	add    $0x10,%esp
      return 0;
801087d7:	b8 00 00 00 00       	mov    $0x0,%eax
801087dc:	eb 55                	jmp    80108833 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801087de:	83 ec 04             	sub    $0x4,%esp
801087e1:	68 00 10 00 00       	push   $0x1000
801087e6:	6a 00                	push   $0x0
801087e8:	ff 75 f0             	pushl  -0x10(%ebp)
801087eb:	e8 2a d1 ff ff       	call   8010591a <memset>
801087f0:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801087f3:	83 ec 0c             	sub    $0xc,%esp
801087f6:	ff 75 f0             	pushl  -0x10(%ebp)
801087f9:	e8 08 f6 ff ff       	call   80107e06 <v2p>
801087fe:	83 c4 10             	add    $0x10,%esp
80108801:	89 c2                	mov    %eax,%edx
80108803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108806:	83 ec 0c             	sub    $0xc,%esp
80108809:	6a 06                	push   $0x6
8010880b:	52                   	push   %edx
8010880c:	68 00 10 00 00       	push   $0x1000
80108811:	50                   	push   %eax
80108812:	ff 75 08             	pushl  0x8(%ebp)
80108815:	e8 1b fb ff ff       	call   80108335 <mappages>
8010881a:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010881d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108827:	3b 45 10             	cmp    0x10(%ebp),%eax
8010882a:	0f 82 75 ff ff ff    	jb     801087a5 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108830:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108833:	c9                   	leave  
80108834:	c3                   	ret    

80108835 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108835:	55                   	push   %ebp
80108836:	89 e5                	mov    %esp,%ebp
80108838:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010883b:	8b 45 10             	mov    0x10(%ebp),%eax
8010883e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108841:	72 08                	jb     8010884b <deallocuvm+0x16>
    return oldsz;
80108843:	8b 45 0c             	mov    0xc(%ebp),%eax
80108846:	e9 a5 00 00 00       	jmp    801088f0 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
8010884b:	8b 45 10             	mov    0x10(%ebp),%eax
8010884e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108853:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108858:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010885b:	e9 81 00 00 00       	jmp    801088e1 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108863:	83 ec 04             	sub    $0x4,%esp
80108866:	6a 00                	push   $0x0
80108868:	50                   	push   %eax
80108869:	ff 75 08             	pushl  0x8(%ebp)
8010886c:	e8 24 fa ff ff       	call   80108295 <walkpgdir>
80108871:	83 c4 10             	add    $0x10,%esp
80108874:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108877:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010887b:	75 09                	jne    80108886 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010887d:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108884:	eb 54                	jmp    801088da <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108889:	8b 00                	mov    (%eax),%eax
8010888b:	83 e0 01             	and    $0x1,%eax
8010888e:	85 c0                	test   %eax,%eax
80108890:	74 48                	je     801088da <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108895:	8b 00                	mov    (%eax),%eax
80108897:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010889c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010889f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088a3:	75 0d                	jne    801088b2 <deallocuvm+0x7d>
        panic("kfree");
801088a5:	83 ec 0c             	sub    $0xc,%esp
801088a8:	68 61 93 10 80       	push   $0x80109361
801088ad:	e8 b4 7c ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801088b2:	83 ec 0c             	sub    $0xc,%esp
801088b5:	ff 75 ec             	pushl  -0x14(%ebp)
801088b8:	e8 56 f5 ff ff       	call   80107e13 <p2v>
801088bd:	83 c4 10             	add    $0x10,%esp
801088c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801088c3:	83 ec 0c             	sub    $0xc,%esp
801088c6:	ff 75 e8             	pushl  -0x18(%ebp)
801088c9:	e8 80 a9 ff ff       	call   8010324e <kfree>
801088ce:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801088d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801088da:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088e7:	0f 82 73 ff ff ff    	jb     80108860 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801088ed:	8b 45 10             	mov    0x10(%ebp),%eax
}
801088f0:	c9                   	leave  
801088f1:	c3                   	ret    

801088f2 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801088f2:	55                   	push   %ebp
801088f3:	89 e5                	mov    %esp,%ebp
801088f5:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801088f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801088fc:	75 0d                	jne    8010890b <freevm+0x19>
    panic("freevm: no pgdir");
801088fe:	83 ec 0c             	sub    $0xc,%esp
80108901:	68 67 93 10 80       	push   $0x80109367
80108906:	e8 5b 7c ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010890b:	83 ec 04             	sub    $0x4,%esp
8010890e:	6a 00                	push   $0x0
80108910:	68 00 00 00 80       	push   $0x80000000
80108915:	ff 75 08             	pushl  0x8(%ebp)
80108918:	e8 18 ff ff ff       	call   80108835 <deallocuvm>
8010891d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108927:	eb 4f                	jmp    80108978 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108933:	8b 45 08             	mov    0x8(%ebp),%eax
80108936:	01 d0                	add    %edx,%eax
80108938:	8b 00                	mov    (%eax),%eax
8010893a:	83 e0 01             	and    $0x1,%eax
8010893d:	85 c0                	test   %eax,%eax
8010893f:	74 33                	je     80108974 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108944:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010894b:	8b 45 08             	mov    0x8(%ebp),%eax
8010894e:	01 d0                	add    %edx,%eax
80108950:	8b 00                	mov    (%eax),%eax
80108952:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108957:	83 ec 0c             	sub    $0xc,%esp
8010895a:	50                   	push   %eax
8010895b:	e8 b3 f4 ff ff       	call   80107e13 <p2v>
80108960:	83 c4 10             	add    $0x10,%esp
80108963:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108966:	83 ec 0c             	sub    $0xc,%esp
80108969:	ff 75 f0             	pushl  -0x10(%ebp)
8010896c:	e8 dd a8 ff ff       	call   8010324e <kfree>
80108971:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108974:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108978:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010897f:	76 a8                	jbe    80108929 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108981:	83 ec 0c             	sub    $0xc,%esp
80108984:	ff 75 08             	pushl  0x8(%ebp)
80108987:	e8 c2 a8 ff ff       	call   8010324e <kfree>
8010898c:	83 c4 10             	add    $0x10,%esp
}
8010898f:	90                   	nop
80108990:	c9                   	leave  
80108991:	c3                   	ret    

80108992 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108992:	55                   	push   %ebp
80108993:	89 e5                	mov    %esp,%ebp
80108995:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108998:	83 ec 04             	sub    $0x4,%esp
8010899b:	6a 00                	push   $0x0
8010899d:	ff 75 0c             	pushl  0xc(%ebp)
801089a0:	ff 75 08             	pushl  0x8(%ebp)
801089a3:	e8 ed f8 ff ff       	call   80108295 <walkpgdir>
801089a8:	83 c4 10             	add    $0x10,%esp
801089ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801089ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089b2:	75 0d                	jne    801089c1 <clearpteu+0x2f>
    panic("clearpteu");
801089b4:	83 ec 0c             	sub    $0xc,%esp
801089b7:	68 78 93 10 80       	push   $0x80109378
801089bc:	e8 a5 7b ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801089c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c4:	8b 00                	mov    (%eax),%eax
801089c6:	83 e0 fb             	and    $0xfffffffb,%eax
801089c9:	89 c2                	mov    %eax,%edx
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	89 10                	mov    %edx,(%eax)
}
801089d0:	90                   	nop
801089d1:	c9                   	leave  
801089d2:	c3                   	ret    

801089d3 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801089d3:	55                   	push   %ebp
801089d4:	89 e5                	mov    %esp,%ebp
801089d6:	53                   	push   %ebx
801089d7:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801089da:	e8 e6 f9 ff ff       	call   801083c5 <setupkvm>
801089df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801089e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089e6:	75 0a                	jne    801089f2 <copyuvm+0x1f>
    return 0;
801089e8:	b8 00 00 00 00       	mov    $0x0,%eax
801089ed:	e9 f8 00 00 00       	jmp    80108aea <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801089f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089f9:	e9 c4 00 00 00       	jmp    80108ac2 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801089fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a01:	83 ec 04             	sub    $0x4,%esp
80108a04:	6a 00                	push   $0x0
80108a06:	50                   	push   %eax
80108a07:	ff 75 08             	pushl  0x8(%ebp)
80108a0a:	e8 86 f8 ff ff       	call   80108295 <walkpgdir>
80108a0f:	83 c4 10             	add    $0x10,%esp
80108a12:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a19:	75 0d                	jne    80108a28 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108a1b:	83 ec 0c             	sub    $0xc,%esp
80108a1e:	68 82 93 10 80       	push   $0x80109382
80108a23:	e8 3e 7b ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2b:	8b 00                	mov    (%eax),%eax
80108a2d:	83 e0 01             	and    $0x1,%eax
80108a30:	85 c0                	test   %eax,%eax
80108a32:	75 0d                	jne    80108a41 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108a34:	83 ec 0c             	sub    $0xc,%esp
80108a37:	68 9c 93 10 80       	push   $0x8010939c
80108a3c:	e8 25 7b ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108a41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a44:	8b 00                	mov    (%eax),%eax
80108a46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a51:	8b 00                	mov    (%eax),%eax
80108a53:	25 ff 0f 00 00       	and    $0xfff,%eax
80108a58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108a5b:	e8 8b a8 ff ff       	call   801032eb <kalloc>
80108a60:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108a63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108a67:	74 6a                	je     80108ad3 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108a69:	83 ec 0c             	sub    $0xc,%esp
80108a6c:	ff 75 e8             	pushl  -0x18(%ebp)
80108a6f:	e8 9f f3 ff ff       	call   80107e13 <p2v>
80108a74:	83 c4 10             	add    $0x10,%esp
80108a77:	83 ec 04             	sub    $0x4,%esp
80108a7a:	68 00 10 00 00       	push   $0x1000
80108a7f:	50                   	push   %eax
80108a80:	ff 75 e0             	pushl  -0x20(%ebp)
80108a83:	e8 51 cf ff ff       	call   801059d9 <memmove>
80108a88:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108a8b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108a8e:	83 ec 0c             	sub    $0xc,%esp
80108a91:	ff 75 e0             	pushl  -0x20(%ebp)
80108a94:	e8 6d f3 ff ff       	call   80107e06 <v2p>
80108a99:	83 c4 10             	add    $0x10,%esp
80108a9c:	89 c2                	mov    %eax,%edx
80108a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa1:	83 ec 0c             	sub    $0xc,%esp
80108aa4:	53                   	push   %ebx
80108aa5:	52                   	push   %edx
80108aa6:	68 00 10 00 00       	push   $0x1000
80108aab:	50                   	push   %eax
80108aac:	ff 75 f0             	pushl  -0x10(%ebp)
80108aaf:	e8 81 f8 ff ff       	call   80108335 <mappages>
80108ab4:	83 c4 20             	add    $0x20,%esp
80108ab7:	85 c0                	test   %eax,%eax
80108ab9:	78 1b                	js     80108ad6 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108abb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ac8:	0f 82 30 ff ff ff    	jb     801089fe <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad1:	eb 17                	jmp    80108aea <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108ad3:	90                   	nop
80108ad4:	eb 01                	jmp    80108ad7 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108ad6:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108ad7:	83 ec 0c             	sub    $0xc,%esp
80108ada:	ff 75 f0             	pushl  -0x10(%ebp)
80108add:	e8 10 fe ff ff       	call   801088f2 <freevm>
80108ae2:	83 c4 10             	add    $0x10,%esp
  return 0;
80108ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108aed:	c9                   	leave  
80108aee:	c3                   	ret    

80108aef <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108aef:	55                   	push   %ebp
80108af0:	89 e5                	mov    %esp,%ebp
80108af2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108af5:	83 ec 04             	sub    $0x4,%esp
80108af8:	6a 00                	push   $0x0
80108afa:	ff 75 0c             	pushl  0xc(%ebp)
80108afd:	ff 75 08             	pushl  0x8(%ebp)
80108b00:	e8 90 f7 ff ff       	call   80108295 <walkpgdir>
80108b05:	83 c4 10             	add    $0x10,%esp
80108b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0e:	8b 00                	mov    (%eax),%eax
80108b10:	83 e0 01             	and    $0x1,%eax
80108b13:	85 c0                	test   %eax,%eax
80108b15:	75 07                	jne    80108b1e <uva2ka+0x2f>
    return 0;
80108b17:	b8 00 00 00 00       	mov    $0x0,%eax
80108b1c:	eb 29                	jmp    80108b47 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b21:	8b 00                	mov    (%eax),%eax
80108b23:	83 e0 04             	and    $0x4,%eax
80108b26:	85 c0                	test   %eax,%eax
80108b28:	75 07                	jne    80108b31 <uva2ka+0x42>
    return 0;
80108b2a:	b8 00 00 00 00       	mov    $0x0,%eax
80108b2f:	eb 16                	jmp    80108b47 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b34:	8b 00                	mov    (%eax),%eax
80108b36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b3b:	83 ec 0c             	sub    $0xc,%esp
80108b3e:	50                   	push   %eax
80108b3f:	e8 cf f2 ff ff       	call   80107e13 <p2v>
80108b44:	83 c4 10             	add    $0x10,%esp
}
80108b47:	c9                   	leave  
80108b48:	c3                   	ret    

80108b49 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108b49:	55                   	push   %ebp
80108b4a:	89 e5                	mov    %esp,%ebp
80108b4c:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108b4f:	8b 45 10             	mov    0x10(%ebp),%eax
80108b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108b55:	eb 7f                	jmp    80108bd6 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108b57:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b65:	83 ec 08             	sub    $0x8,%esp
80108b68:	50                   	push   %eax
80108b69:	ff 75 08             	pushl  0x8(%ebp)
80108b6c:	e8 7e ff ff ff       	call   80108aef <uva2ka>
80108b71:	83 c4 10             	add    $0x10,%esp
80108b74:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108b77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108b7b:	75 07                	jne    80108b84 <copyout+0x3b>
      return -1;
80108b7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b82:	eb 61                	jmp    80108be5 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b87:	2b 45 0c             	sub    0xc(%ebp),%eax
80108b8a:	05 00 10 00 00       	add    $0x1000,%eax
80108b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b95:	3b 45 14             	cmp    0x14(%ebp),%eax
80108b98:	76 06                	jbe    80108ba0 <copyout+0x57>
      n = len;
80108b9a:	8b 45 14             	mov    0x14(%ebp),%eax
80108b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba3:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108ba6:	89 c2                	mov    %eax,%edx
80108ba8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bab:	01 d0                	add    %edx,%eax
80108bad:	83 ec 04             	sub    $0x4,%esp
80108bb0:	ff 75 f0             	pushl  -0x10(%ebp)
80108bb3:	ff 75 f4             	pushl  -0xc(%ebp)
80108bb6:	50                   	push   %eax
80108bb7:	e8 1d ce ff ff       	call   801059d9 <memmove>
80108bbc:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bc2:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bc8:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bce:	05 00 10 00 00       	add    $0x1000,%eax
80108bd3:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108bd6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108bda:	0f 85 77 ff ff ff    	jne    80108b57 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108be0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108be5:	c9                   	leave  
80108be6:	c3                   	ret    
