
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
8010002d:	b8 b6 43 10 80       	mov    $0x801043b6,%eax
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
8010003d:	68 80 93 10 80       	push   $0x80109380
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 01 5b 00 00       	call   80105b4d <initlock>
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
801000c1:	e8 a9 5a 00 00       	call   80105b6f <acquire>
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
8010010c:	e8 c5 5a 00 00       	call   80105bd6 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 4a 57 00 00       	call   80105876 <sleep>
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
80100188:	e8 49 5a 00 00       	call   80105bd6 <release>
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
801001aa:	68 87 93 10 80       	push   $0x80109387
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
801001e2:	e8 1d 2f 00 00       	call   80103104 <iderw>
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
80100204:	68 98 93 10 80       	push   $0x80109398
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
80100223:	e8 dc 2e 00 00       	call   80103104 <iderw>
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
80100243:	68 9f 93 10 80       	push   $0x8010939f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 15 59 00 00       	call   80105b6f <acquire>
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
801002b9:	e8 a3 56 00 00       	call   80105961 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 08 59 00 00       	call   80105bd6 <release>
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
801003e2:	e8 88 57 00 00       	call   80105b6f <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 a6 93 10 80       	push   $0x801093a6
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
801004cd:	c7 45 ec af 93 10 80 	movl   $0x801093af,-0x14(%ebp)
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
8010055b:	e8 76 56 00 00       	call   80105bd6 <release>
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
8010058b:	68 b6 93 10 80       	push   $0x801093b6
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
801005aa:	68 c5 93 10 80       	push   $0x801093c5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 61 56 00 00       	call   80105c28 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 c7 93 10 80       	push   $0x801093c7
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
801006ca:	68 cb 93 10 80       	push   $0x801093cb
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
801006f7:	e8 95 57 00 00       	call   80105e91 <memmove>
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
80100721:	e8 ac 56 00 00       	call   80105dd2 <memset>
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
801007b6:	e8 4c 72 00 00       	call   80107a07 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 3f 72 00 00       	call   80107a07 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 32 72 00 00       	call   80107a07 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 22 72 00 00       	call   80107a07 <uartputc>
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
8010080e:	e8 5c 53 00 00       	call   80105b6f <acquire>
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
80100956:	e8 06 50 00 00       	call   80105961 <wakeup>
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
80100979:	e8 58 52 00 00       	call   80105bd6 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 90 50 00 00       	call   80105a1c <procdump>
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
8010099b:	e8 d6 16 00 00       	call   80102076 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 b9 51 00 00       	call   80105b6f <acquire>
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
801009d3:	e8 fe 51 00 00       	call   80105bd6 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        //cprintf("cRead \n");
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 ef 14 00 00       	call   80101ed5 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 e0 18 11 80       	push   $0x801118e0
80100a00:	e8 71 4e 00 00       	call   80105876 <sleep>
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
80100a7e:	e8 53 51 00 00       	call   80105bd6 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
          //    cprintf("cRead2 \n");

  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 44 14 00 00       	call   80101ed5 <ilock>
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
80100aac:	e8 c5 15 00 00       	call   80102076 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 ae 50 00 00       	call   80105b6f <acquire>
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
80100afe:	e8 d3 50 00 00       	call   80105bd6 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
        //  cprintf("cWrite \n");

  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 c4 13 00 00       	call   80101ed5 <ilock>
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
80100b22:	68 de 93 10 80       	push   $0x801093de
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 1c 50 00 00       	call   80105b4d <initlock>
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
80100b57:	e8 d9 3e 00 00       	call   80104a35 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 66 27 00 00       	call   801032d1 <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
  struct partition *part;  //partition
};

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

  begin_op(proc->cwd->part->number);
80100b7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100b80:	8b 40 68             	mov    0x68(%eax),%eax
80100b83:	8b 40 50             	mov    0x50(%eax),%eax
80100b86:	8b 40 14             	mov    0x14(%eax),%eax
80100b89:	83 ec 0c             	sub    $0xc,%esp
80100b8c:	50                   	push   %eax
80100b8d:	e8 e9 32 00 00       	call   80103e7b <begin_op>
80100b92:	83 c4 10             	add    $0x10,%esp
  if((ip = namei(path)) == 0){
80100b95:	83 ec 0c             	sub    $0xc,%esp
80100b98:	ff 75 08             	pushl  0x8(%ebp)
80100b9b:	e8 46 21 00 00       	call   80102ce6 <namei>
80100ba0:	83 c4 10             	add    $0x10,%esp
80100ba3:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100baa:	75 25                	jne    80100bd1 <exec+0x60>
    end_op(proc->cwd->part->number);
80100bac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bb2:	8b 40 68             	mov    0x68(%eax),%eax
80100bb5:	8b 40 50             	mov    0x50(%eax),%eax
80100bb8:	8b 40 14             	mov    0x14(%eax),%eax
80100bbb:	83 ec 0c             	sub    $0xc,%esp
80100bbe:	50                   	push   %eax
80100bbf:	e8 be 33 00 00       	call   80103f82 <end_op>
80100bc4:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bcc:	e9 fa 03 00 00       	jmp    80100fcb <exec+0x45a>
  }
           // cprintf("exec \n");

  ilock(ip);
80100bd1:	83 ec 0c             	sub    $0xc,%esp
80100bd4:	ff 75 d8             	pushl  -0x28(%ebp)
80100bd7:	e8 f9 12 00 00       	call   80101ed5 <ilock>
80100bdc:	83 c4 10             	add    $0x10,%esp

  pgdir = 0;
80100bdf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100be6:	6a 34                	push   $0x34
80100be8:	6a 00                	push   $0x0
80100bea:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bf0:	50                   	push   %eax
80100bf1:	ff 75 d8             	pushl  -0x28(%ebp)
80100bf4:	e8 6a 19 00 00       	call   80102563 <readi>
80100bf9:	83 c4 10             	add    $0x10,%esp
80100bfc:	83 f8 33             	cmp    $0x33,%eax
80100bff:	0f 86 5f 03 00 00    	jbe    80100f64 <exec+0x3f3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c05:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c0b:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c10:	0f 85 51 03 00 00    	jne    80100f67 <exec+0x3f6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c16:	e8 41 7f 00 00       	call   80108b5c <setupkvm>
80100c1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c1e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c22:	0f 84 42 03 00 00    	je     80100f6a <exec+0x3f9>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c28:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c36:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3f:	e9 ab 00 00 00       	jmp    80100cef <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c47:	6a 20                	push   $0x20
80100c49:	50                   	push   %eax
80100c4a:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c50:	50                   	push   %eax
80100c51:	ff 75 d8             	pushl  -0x28(%ebp)
80100c54:	e8 0a 19 00 00       	call   80102563 <readi>
80100c59:	83 c4 10             	add    $0x10,%esp
80100c5c:	83 f8 20             	cmp    $0x20,%eax
80100c5f:	0f 85 08 03 00 00    	jne    80100f6d <exec+0x3fc>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c65:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c6b:	83 f8 01             	cmp    $0x1,%eax
80100c6e:	75 71                	jne    80100ce1 <exec+0x170>
      continue;
    if(ph.memsz < ph.filesz)
80100c70:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c76:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c7c:	39 c2                	cmp    %eax,%edx
80100c7e:	0f 82 ec 02 00 00    	jb     80100f70 <exec+0x3ff>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c84:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c8a:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c90:	01 d0                	add    %edx,%eax
80100c92:	83 ec 04             	sub    $0x4,%esp
80100c95:	50                   	push   %eax
80100c96:	ff 75 e0             	pushl  -0x20(%ebp)
80100c99:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c9c:	e8 62 82 00 00       	call   80108f03 <allocuvm>
80100ca1:	83 c4 10             	add    $0x10,%esp
80100ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ca7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cab:	0f 84 c2 02 00 00    	je     80100f73 <exec+0x402>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cbd:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cc3:	83 ec 0c             	sub    $0xc,%esp
80100cc6:	52                   	push   %edx
80100cc7:	50                   	push   %eax
80100cc8:	ff 75 d8             	pushl  -0x28(%ebp)
80100ccb:	51                   	push   %ecx
80100ccc:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccf:	e8 58 81 00 00       	call   80108e2c <loaduvm>
80100cd4:	83 c4 20             	add    $0x20,%esp
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 88 97 02 00 00    	js     80100f76 <exec+0x405>
80100cdf:	eb 01                	jmp    80100ce2 <exec+0x171>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100ce1:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ce2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ce6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ce9:	83 c0 20             	add    $0x20,%eax
80100cec:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cef:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cf6:	0f b7 c0             	movzwl %ax,%eax
80100cf9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cfc:	0f 8f 42 ff ff ff    	jg     80100c44 <exec+0xd3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d02:	83 ec 0c             	sub    $0xc,%esp
80100d05:	ff 75 d8             	pushl  -0x28(%ebp)
80100d08:	e8 cb 14 00 00       	call   801021d8 <iunlockput>
80100d0d:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
80100d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d16:	8b 40 68             	mov    0x68(%eax),%eax
80100d19:	8b 40 50             	mov    0x50(%eax),%eax
80100d1c:	8b 40 14             	mov    0x14(%eax),%eax
80100d1f:	83 ec 0c             	sub    $0xc,%esp
80100d22:	50                   	push   %eax
80100d23:	e8 5a 32 00 00       	call   80103f82 <end_op>
80100d28:	83 c4 10             	add    $0x10,%esp
  ip = 0;
80100d2b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d35:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d45:	05 00 20 00 00       	add    $0x2000,%eax
80100d4a:	83 ec 04             	sub    $0x4,%esp
80100d4d:	50                   	push   %eax
80100d4e:	ff 75 e0             	pushl  -0x20(%ebp)
80100d51:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d54:	e8 aa 81 00 00       	call   80108f03 <allocuvm>
80100d59:	83 c4 10             	add    $0x10,%esp
80100d5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d5f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d63:	0f 84 10 02 00 00    	je     80100f79 <exec+0x408>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6c:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d71:	83 ec 08             	sub    $0x8,%esp
80100d74:	50                   	push   %eax
80100d75:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d78:	e8 ac 83 00 00       	call   80109129 <clearpteu>
80100d7d:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d83:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d86:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d8d:	e9 96 00 00 00       	jmp    80100e28 <exec+0x2b7>
    if(argc >= MAXARG)
80100d92:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d96:	0f 87 e0 01 00 00    	ja     80100f7c <exec+0x40b>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	8b 00                	mov    (%eax),%eax
80100dad:	83 ec 0c             	sub    $0xc,%esp
80100db0:	50                   	push   %eax
80100db1:	e8 69 52 00 00       	call   8010601f <strlen>
80100db6:	83 c4 10             	add    $0x10,%esp
80100db9:	89 c2                	mov    %eax,%edx
80100dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbe:	29 d0                	sub    %edx,%eax
80100dc0:	83 e8 01             	sub    $0x1,%eax
80100dc3:	83 e0 fc             	and    $0xfffffffc,%eax
80100dc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd6:	01 d0                	add    %edx,%eax
80100dd8:	8b 00                	mov    (%eax),%eax
80100dda:	83 ec 0c             	sub    $0xc,%esp
80100ddd:	50                   	push   %eax
80100dde:	e8 3c 52 00 00       	call   8010601f <strlen>
80100de3:	83 c4 10             	add    $0x10,%esp
80100de6:	83 c0 01             	add    $0x1,%eax
80100de9:	89 c1                	mov    %eax,%ecx
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	51                   	push   %ecx
80100dfd:	50                   	push   %eax
80100dfe:	ff 75 dc             	pushl  -0x24(%ebp)
80100e01:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e04:	e8 d7 84 00 00       	call   801092e0 <copyout>
80100e09:	83 c4 10             	add    $0x10,%esp
80100e0c:	85 c0                	test   %eax,%eax
80100e0e:	0f 88 6b 01 00 00    	js     80100f7f <exec+0x40e>
      goto bad;
    ustack[3+argc] = sp;
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	8d 50 03             	lea    0x3(%eax),%edx
80100e1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1d:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e24:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e35:	01 d0                	add    %edx,%eax
80100e37:	8b 00                	mov    (%eax),%eax
80100e39:	85 c0                	test   %eax,%eax
80100e3b:	0f 85 51 ff ff ff    	jne    80100d92 <exec+0x221>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e44:	83 c0 03             	add    $0x3,%eax
80100e47:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e4e:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e52:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e59:	ff ff ff 
  ustack[1] = argc;
80100e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e68:	83 c0 01             	add    $0x1,%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e75:	29 d0                	sub    %edx,%eax
80100e77:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 04             	add    $0x4,%eax
80100e83:	c1 e0 02             	shl    $0x2,%eax
80100e86:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8c:	83 c0 04             	add    $0x4,%eax
80100e8f:	c1 e0 02             	shl    $0x2,%eax
80100e92:	50                   	push   %eax
80100e93:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e99:	50                   	push   %eax
80100e9a:	ff 75 dc             	pushl  -0x24(%ebp)
80100e9d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ea0:	e8 3b 84 00 00       	call   801092e0 <copyout>
80100ea5:	83 c4 10             	add    $0x10,%esp
80100ea8:	85 c0                	test   %eax,%eax
80100eaa:	0f 88 d2 00 00 00    	js     80100f82 <exec+0x411>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ebc:	eb 17                	jmp    80100ed5 <exec+0x364>
    if(*s == '/')
80100ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec1:	0f b6 00             	movzbl (%eax),%eax
80100ec4:	3c 2f                	cmp    $0x2f,%al
80100ec6:	75 09                	jne    80100ed1 <exec+0x360>
      last = s+1;
80100ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ecb:	83 c0 01             	add    $0x1,%eax
80100ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed8:	0f b6 00             	movzbl (%eax),%eax
80100edb:	84 c0                	test   %al,%al
80100edd:	75 df                	jne    80100ebe <exec+0x34d>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100edf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee5:	83 c0 6c             	add    $0x6c,%eax
80100ee8:	83 ec 04             	sub    $0x4,%esp
80100eeb:	6a 10                	push   $0x10
80100eed:	ff 75 f0             	pushl  -0x10(%ebp)
80100ef0:	50                   	push   %eax
80100ef1:	e8 df 50 00 00       	call   80105fd5 <safestrcpy>
80100ef6:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eff:	8b 40 04             	mov    0x4(%eax),%eax
80100f02:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f0e:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f17:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f1a:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f22:	8b 40 18             	mov    0x18(%eax),%eax
80100f25:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f2b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f34:	8b 40 18             	mov    0x18(%eax),%eax
80100f37:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f3a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	50                   	push   %eax
80100f47:	e8 f7 7c 00 00       	call   80108c43 <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 2f 81 00 00       	call   80109089 <freevm>
80100f5a:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5d:	b8 00 00 00 00       	mov    $0x0,%eax
80100f62:	eb 67                	jmp    80100fcb <exec+0x45a>

  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f64:	90                   	nop
80100f65:	eb 1c                	jmp    80100f83 <exec+0x412>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f67:	90                   	nop
80100f68:	eb 19                	jmp    80100f83 <exec+0x412>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 16                	jmp    80100f83 <exec+0x412>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f6d:	90                   	nop
80100f6e:	eb 13                	jmp    80100f83 <exec+0x412>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f70:	90                   	nop
80100f71:	eb 10                	jmp    80100f83 <exec+0x412>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f73:	90                   	nop
80100f74:	eb 0d                	jmp    80100f83 <exec+0x412>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f76:	90                   	nop
80100f77:	eb 0a                	jmp    80100f83 <exec+0x412>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f79:	90                   	nop
80100f7a:	eb 07                	jmp    80100f83 <exec+0x412>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 04                	jmp    80100f83 <exec+0x412>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 01                	jmp    80100f83 <exec+0x412>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f82:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f83:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f87:	74 0e                	je     80100f97 <exec+0x426>
    freevm(pgdir);
80100f89:	83 ec 0c             	sub    $0xc,%esp
80100f8c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f8f:	e8 f5 80 00 00       	call   80109089 <freevm>
80100f94:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f97:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f9b:	74 29                	je     80100fc6 <exec+0x455>
    iunlockput(ip);
80100f9d:	83 ec 0c             	sub    $0xc,%esp
80100fa0:	ff 75 d8             	pushl  -0x28(%ebp)
80100fa3:	e8 30 12 00 00       	call   801021d8 <iunlockput>
80100fa8:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80100fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fb1:	8b 40 68             	mov    0x68(%eax),%eax
80100fb4:	8b 40 50             	mov    0x50(%eax),%eax
80100fb7:	8b 40 14             	mov    0x14(%eax),%eax
80100fba:	83 ec 0c             	sub    $0xc,%esp
80100fbd:	50                   	push   %eax
80100fbe:	e8 bf 2f 00 00       	call   80103f82 <end_op>
80100fc3:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fcb:	c9                   	leave  
80100fcc:	c3                   	ret    

80100fcd <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fcd:	55                   	push   %ebp
80100fce:	89 e5                	mov    %esp,%ebp
80100fd0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fd3:	83 ec 08             	sub    $0x8,%esp
80100fd6:	68 e6 93 10 80       	push   $0x801093e6
80100fdb:	68 00 19 11 80       	push   $0x80111900
80100fe0:	e8 68 4b 00 00       	call   80105b4d <initlock>
80100fe5:	83 c4 10             	add    $0x10,%esp
}
80100fe8:	90                   	nop
80100fe9:	c9                   	leave  
80100fea:	c3                   	ret    

80100feb <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100feb:	55                   	push   %ebp
80100fec:	89 e5                	mov    %esp,%ebp
80100fee:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100ff1:	83 ec 0c             	sub    $0xc,%esp
80100ff4:	68 00 19 11 80       	push   $0x80111900
80100ff9:	e8 71 4b 00 00       	call   80105b6f <acquire>
80100ffe:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101001:	c7 45 f4 34 19 11 80 	movl   $0x80111934,-0xc(%ebp)
80101008:	eb 2d                	jmp    80101037 <filealloc+0x4c>
    if(f->ref == 0){
8010100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100d:	8b 40 04             	mov    0x4(%eax),%eax
80101010:	85 c0                	test   %eax,%eax
80101012:	75 1f                	jne    80101033 <filealloc+0x48>
      f->ref = 1;
80101014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101017:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101e:	83 ec 0c             	sub    $0xc,%esp
80101021:	68 00 19 11 80       	push   $0x80111900
80101026:	e8 ab 4b 00 00       	call   80105bd6 <release>
8010102b:	83 c4 10             	add    $0x10,%esp
      return f;
8010102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101031:	eb 23                	jmp    80101056 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101033:	83 45 f4 16          	addl   $0x16,-0xc(%ebp)
80101037:	b8 cc 21 11 80       	mov    $0x801121cc,%eax
8010103c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103f:	72 c9                	jb     8010100a <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	68 00 19 11 80       	push   $0x80111900
80101049:	e8 88 4b 00 00       	call   80105bd6 <release>
8010104e:	83 c4 10             	add    $0x10,%esp
  return 0;
80101051:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101056:	c9                   	leave  
80101057:	c3                   	ret    

80101058 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101058:	55                   	push   %ebp
80101059:	89 e5                	mov    %esp,%ebp
8010105b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 00 19 11 80       	push   $0x80111900
80101066:	e8 04 4b 00 00       	call   80105b6f <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 ed 93 10 80       	push   $0x801093ed
80101080:	e8 e1 f4 ff ff       	call   80100566 <panic>
  f->ref++;
80101085:	8b 45 08             	mov    0x8(%ebp),%eax
80101088:	8b 40 04             	mov    0x4(%eax),%eax
8010108b:	8d 50 01             	lea    0x1(%eax),%edx
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101094:	83 ec 0c             	sub    $0xc,%esp
80101097:	68 00 19 11 80       	push   $0x80111900
8010109c:	e8 35 4b 00 00       	call   80105bd6 <release>
801010a1:	83 c4 10             	add    $0x10,%esp
  return f;
801010a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a7:	c9                   	leave  
801010a8:	c3                   	ret    

801010a9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a9:	55                   	push   %ebp
801010aa:	89 e5                	mov    %esp,%ebp
801010ac:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	68 00 19 11 80       	push   $0x80111900
801010b7:	e8 b3 4a 00 00       	call   80105b6f <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 f5 93 10 80       	push   $0x801093f5
801010d1:	e8 90 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	8d 50 ff             	lea    -0x1(%eax),%edx
801010df:	8b 45 08             	mov    0x8(%ebp),%eax
801010e2:	89 50 04             	mov    %edx,0x4(%eax)
801010e5:	8b 45 08             	mov    0x8(%ebp),%eax
801010e8:	8b 40 04             	mov    0x4(%eax),%eax
801010eb:	85 c0                	test   %eax,%eax
801010ed:	7e 15                	jle    80101104 <fileclose+0x5b>
    release(&ftable.lock);
801010ef:	83 ec 0c             	sub    $0xc,%esp
801010f2:	68 00 19 11 80       	push   $0x80111900
801010f7:	e8 da 4a 00 00       	call   80105bd6 <release>
801010fc:	83 c4 10             	add    $0x10,%esp
801010ff:	e9 b3 00 00 00       	jmp    801011b7 <fileclose+0x10e>
    return;
  }
  ff = *f;
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 10                	mov    (%eax),%edx
80101109:	89 55 e2             	mov    %edx,-0x1e(%ebp)
8010110c:	8b 50 04             	mov    0x4(%eax),%edx
8010110f:	89 55 e6             	mov    %edx,-0x1a(%ebp)
80101112:	8b 50 08             	mov    0x8(%eax),%edx
80101115:	89 55 ea             	mov    %edx,-0x16(%ebp)
80101118:	8b 50 0c             	mov    0xc(%eax),%edx
8010111b:	89 55 ee             	mov    %edx,-0x12(%ebp)
8010111e:	8b 50 10             	mov    0x10(%eax),%edx
80101121:	89 55 f2             	mov    %edx,-0xe(%ebp)
80101124:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80101128:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  f->ref = 0;
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010113f:	83 ec 0c             	sub    $0xc,%esp
80101142:	68 00 19 11 80       	push   $0x80111900
80101147:	e8 8a 4a 00 00       	call   80105bd6 <release>
8010114c:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010114f:	8b 45 e2             	mov    -0x1e(%ebp),%eax
80101152:	83 f8 01             	cmp    $0x1,%eax
80101155:	75 19                	jne    80101170 <fileclose+0xc7>
    pipeclose(ff.pipe, ff.writable);
80101157:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
8010115b:	0f be d0             	movsbl %al,%edx
8010115e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101161:	83 ec 08             	sub    $0x8,%esp
80101164:	52                   	push   %edx
80101165:	50                   	push   %eax
80101166:	e8 33 3b 00 00       	call   80104c9e <pipeclose>
8010116b:	83 c4 10             	add    $0x10,%esp
8010116e:	eb 47                	jmp    801011b7 <fileclose+0x10e>
  else if(ff.type == FD_INODE){
80101170:	8b 45 e2             	mov    -0x1e(%ebp),%eax
80101173:	83 f8 02             	cmp    $0x2,%eax
80101176:	75 3f                	jne    801011b7 <fileclose+0x10e>
    begin_op(f->ip->part->number);
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	8b 40 0e             	mov    0xe(%eax),%eax
8010117e:	8b 40 50             	mov    0x50(%eax),%eax
80101181:	8b 40 14             	mov    0x14(%eax),%eax
80101184:	83 ec 0c             	sub    $0xc,%esp
80101187:	50                   	push   %eax
80101188:	e8 ee 2c 00 00       	call   80103e7b <begin_op>
8010118d:	83 c4 10             	add    $0x10,%esp
    iput(ff.ip);
80101190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101193:	83 ec 0c             	sub    $0xc,%esp
80101196:	50                   	push   %eax
80101197:	e8 4c 0f 00 00       	call   801020e8 <iput>
8010119c:	83 c4 10             	add    $0x10,%esp
    end_op(f->ip->part->number);
8010119f:	8b 45 08             	mov    0x8(%ebp),%eax
801011a2:	8b 40 0e             	mov    0xe(%eax),%eax
801011a5:	8b 40 50             	mov    0x50(%eax),%eax
801011a8:	8b 40 14             	mov    0x14(%eax),%eax
801011ab:	83 ec 0c             	sub    $0xc,%esp
801011ae:	50                   	push   %eax
801011af:	e8 ce 2d 00 00       	call   80103f82 <end_op>
801011b4:	83 c4 10             	add    $0x10,%esp
  }
}
801011b7:	c9                   	leave  
801011b8:	c3                   	ret    

801011b9 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011b9:	55                   	push   %ebp
801011ba:	89 e5                	mov    %esp,%ebp
801011bc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 00                	mov    (%eax),%eax
801011c4:	83 f8 02             	cmp    $0x2,%eax
801011c7:	75 40                	jne    80101209 <filestat+0x50>
      
    ilock(f->ip);
801011c9:	8b 45 08             	mov    0x8(%ebp),%eax
801011cc:	8b 40 0e             	mov    0xe(%eax),%eax
801011cf:	83 ec 0c             	sub    $0xc,%esp
801011d2:	50                   	push   %eax
801011d3:	e8 fd 0c 00 00       	call   80101ed5 <ilock>
801011d8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 40 0e             	mov    0xe(%eax),%eax
801011e1:	83 ec 08             	sub    $0x8,%esp
801011e4:	ff 75 0c             	pushl  0xc(%ebp)
801011e7:	50                   	push   %eax
801011e8:	e8 30 13 00 00       	call   8010251d <stati>
801011ed:	83 c4 10             	add    $0x10,%esp
   // cprintf("filestat \n");

    iunlock(f->ip);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0e             	mov    0xe(%eax),%eax
801011f6:	83 ec 0c             	sub    $0xc,%esp
801011f9:	50                   	push   %eax
801011fa:	e8 77 0e 00 00       	call   80102076 <iunlock>
801011ff:	83 c4 10             	add    $0x10,%esp
    return 0;
80101202:	b8 00 00 00 00       	mov    $0x0,%eax
80101207:	eb 05                	jmp    8010120e <filestat+0x55>
  }
  return -1;
80101209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010120e:	c9                   	leave  
8010120f:	c3                   	ret    

80101210 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101210:	55                   	push   %ebp
80101211:	89 e5                	mov    %esp,%ebp
80101213:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101216:	8b 45 08             	mov    0x8(%ebp),%eax
80101219:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010121d:	84 c0                	test   %al,%al
8010121f:	75 0a                	jne    8010122b <fileread+0x1b>
    return -1;
80101221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101226:	e9 9b 00 00 00       	jmp    801012c6 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010122b:	8b 45 08             	mov    0x8(%ebp),%eax
8010122e:	8b 00                	mov    (%eax),%eax
80101230:	83 f8 01             	cmp    $0x1,%eax
80101233:	75 1a                	jne    8010124f <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 40 0a             	mov    0xa(%eax),%eax
8010123b:	83 ec 04             	sub    $0x4,%esp
8010123e:	ff 75 10             	pushl  0x10(%ebp)
80101241:	ff 75 0c             	pushl  0xc(%ebp)
80101244:	50                   	push   %eax
80101245:	e8 fc 3b 00 00       	call   80104e46 <piperead>
8010124a:	83 c4 10             	add    $0x10,%esp
8010124d:	eb 77                	jmp    801012c6 <fileread+0xb6>
  if(f->type == FD_INODE){
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 00                	mov    (%eax),%eax
80101254:	83 f8 02             	cmp    $0x2,%eax
80101257:	75 60                	jne    801012b9 <fileread+0xa9>
    ilock(f->ip);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 0e             	mov    0xe(%eax),%eax
8010125f:	83 ec 0c             	sub    $0xc,%esp
80101262:	50                   	push   %eax
80101263:	e8 6d 0c 00 00       	call   80101ed5 <ilock>
80101268:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010126b:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 50 12             	mov    0x12(%eax),%edx
80101274:	8b 45 08             	mov    0x8(%ebp),%eax
80101277:	8b 40 0e             	mov    0xe(%eax),%eax
8010127a:	51                   	push   %ecx
8010127b:	52                   	push   %edx
8010127c:	ff 75 0c             	pushl  0xc(%ebp)
8010127f:	50                   	push   %eax
80101280:	e8 de 12 00 00       	call   80102563 <readi>
80101285:	83 c4 10             	add    $0x10,%esp
80101288:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010128b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010128f:	7e 11                	jle    801012a2 <fileread+0x92>
      f->off += r;
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 50 12             	mov    0x12(%eax),%edx
80101297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010129a:	01 c2                	add    %eax,%edx
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	89 50 12             	mov    %edx,0x12(%eax)
   // cprintf("fileread \n");

    iunlock(f->ip);
801012a2:	8b 45 08             	mov    0x8(%ebp),%eax
801012a5:	8b 40 0e             	mov    0xe(%eax),%eax
801012a8:	83 ec 0c             	sub    $0xc,%esp
801012ab:	50                   	push   %eax
801012ac:	e8 c5 0d 00 00       	call   80102076 <iunlock>
801012b1:	83 c4 10             	add    $0x10,%esp
    return r;
801012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b7:	eb 0d                	jmp    801012c6 <fileread+0xb6>
  }
  panic("fileread");
801012b9:	83 ec 0c             	sub    $0xc,%esp
801012bc:	68 ff 93 10 80       	push   $0x801093ff
801012c1:	e8 a0 f2 ff ff       	call   80100566 <panic>
}
801012c6:	c9                   	leave  
801012c7:	c3                   	ret    

801012c8 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012c8:	55                   	push   %ebp
801012c9:	89 e5                	mov    %esp,%ebp
801012cb:	53                   	push   %ebx
801012cc:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012cf:	8b 45 08             	mov    0x8(%ebp),%eax
801012d2:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012d6:	84 c0                	test   %al,%al
801012d8:	75 0a                	jne    801012e4 <filewrite+0x1c>
    return -1;
801012da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012df:	e9 41 01 00 00       	jmp    80101425 <filewrite+0x15d>
  if(f->type == FD_PIPE)
801012e4:	8b 45 08             	mov    0x8(%ebp),%eax
801012e7:	8b 00                	mov    (%eax),%eax
801012e9:	83 f8 01             	cmp    $0x1,%eax
801012ec:	75 1d                	jne    8010130b <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012ee:	8b 45 08             	mov    0x8(%ebp),%eax
801012f1:	8b 40 0a             	mov    0xa(%eax),%eax
801012f4:	83 ec 04             	sub    $0x4,%esp
801012f7:	ff 75 10             	pushl  0x10(%ebp)
801012fa:	ff 75 0c             	pushl  0xc(%ebp)
801012fd:	50                   	push   %eax
801012fe:	e8 45 3a 00 00       	call   80104d48 <pipewrite>
80101303:	83 c4 10             	add    $0x10,%esp
80101306:	e9 1a 01 00 00       	jmp    80101425 <filewrite+0x15d>
  if(f->type == FD_INODE){
8010130b:	8b 45 08             	mov    0x8(%ebp),%eax
8010130e:	8b 00                	mov    (%eax),%eax
80101310:	83 f8 02             	cmp    $0x2,%eax
80101313:	0f 85 ff 00 00 00    	jne    80101418 <filewrite+0x150>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101319:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101320:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101327:	e9 c9 00 00 00       	jmp    801013f5 <filewrite+0x12d>
      int n1 = n - i;
8010132c:	8b 45 10             	mov    0x10(%ebp),%eax
8010132f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101332:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101338:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010133b:	7e 06                	jle    80101343 <filewrite+0x7b>
        n1 = max;
8010133d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101340:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op(f->ip->part->number);
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	8b 40 0e             	mov    0xe(%eax),%eax
80101349:	8b 40 50             	mov    0x50(%eax),%eax
8010134c:	8b 40 14             	mov    0x14(%eax),%eax
8010134f:	83 ec 0c             	sub    $0xc,%esp
80101352:	50                   	push   %eax
80101353:	e8 23 2b 00 00       	call   80103e7b <begin_op>
80101358:	83 c4 10             	add    $0x10,%esp
      ilock(f->ip);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 40 0e             	mov    0xe(%eax),%eax
80101361:	83 ec 0c             	sub    $0xc,%esp
80101364:	50                   	push   %eax
80101365:	e8 6b 0b 00 00       	call   80101ed5 <ilock>
8010136a:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010136d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 50 12             	mov    0x12(%eax),%edx
80101376:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101379:	8b 45 0c             	mov    0xc(%ebp),%eax
8010137c:	01 c3                	add    %eax,%ebx
8010137e:	8b 45 08             	mov    0x8(%ebp),%eax
80101381:	8b 40 0e             	mov    0xe(%eax),%eax
80101384:	51                   	push   %ecx
80101385:	52                   	push   %edx
80101386:	53                   	push   %ebx
80101387:	50                   	push   %eax
80101388:	e8 76 13 00 00       	call   80102703 <writei>
8010138d:	83 c4 10             	add    $0x10,%esp
80101390:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101393:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101397:	7e 11                	jle    801013aa <filewrite+0xe2>
        f->off += r;
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 50 12             	mov    0x12(%eax),%edx
8010139f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a2:	01 c2                	add    %eax,%edx
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	89 50 12             	mov    %edx,0x12(%eax)
       // cprintf("filewrite \n");

      iunlock(f->ip);
801013aa:	8b 45 08             	mov    0x8(%ebp),%eax
801013ad:	8b 40 0e             	mov    0xe(%eax),%eax
801013b0:	83 ec 0c             	sub    $0xc,%esp
801013b3:	50                   	push   %eax
801013b4:	e8 bd 0c 00 00       	call   80102076 <iunlock>
801013b9:	83 c4 10             	add    $0x10,%esp
      end_op(f->ip->part->number);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	8b 40 0e             	mov    0xe(%eax),%eax
801013c2:	8b 40 50             	mov    0x50(%eax),%eax
801013c5:	8b 40 14             	mov    0x14(%eax),%eax
801013c8:	83 ec 0c             	sub    $0xc,%esp
801013cb:	50                   	push   %eax
801013cc:	e8 b1 2b 00 00       	call   80103f82 <end_op>
801013d1:	83 c4 10             	add    $0x10,%esp

      if(r < 0)
801013d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013d8:	78 29                	js     80101403 <filewrite+0x13b>
        break;
      if(r != n1)
801013da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013dd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e0:	74 0d                	je     801013ef <filewrite+0x127>
        panic("short filewrite");
801013e2:	83 ec 0c             	sub    $0xc,%esp
801013e5:	68 08 94 10 80       	push   $0x80109408
801013ea:	e8 77 f1 ff ff       	call   80100566 <panic>
      i += r;
801013ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f2:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f8:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fb:	0f 8c 2b ff ff ff    	jl     8010132c <filewrite+0x64>
80101401:	eb 01                	jmp    80101404 <filewrite+0x13c>

      iunlock(f->ip);
      end_op(f->ip->part->number);

      if(r < 0)
        break;
80101403:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101407:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140a:	75 05                	jne    80101411 <filewrite+0x149>
8010140c:	8b 45 10             	mov    0x10(%ebp),%eax
8010140f:	eb 14                	jmp    80101425 <filewrite+0x15d>
80101411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101416:	eb 0d                	jmp    80101425 <filewrite+0x15d>
  }
  panic("filewrite");
80101418:	83 ec 0c             	sub    $0xc,%esp
8010141b:	68 18 94 10 80       	push   $0x80109418
80101420:	e8 41 f1 ff ff       	call   80100566 <panic>
}
80101425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101428:	c9                   	leave  
80101429:	c3                   	ret    

8010142a <readsb>:
int currentPart = -1;
struct file * fstabFd;

// Read the super block.
void readsb(int dev, int partitionNumber)
{
8010142a:	55                   	push   %ebp
8010142b:	89 e5                	mov    %esp,%ebp
8010142d:	83 ec 18             	sub    $0x18,%esp
    struct buf* bp;

    bp = bread(dev, mbrI.partitions[partitionNumber].offset);
80101430:	8b 45 0c             	mov    0xc(%ebp),%eax
80101433:	83 c0 1b             	add    $0x1b,%eax
80101436:	c1 e0 04             	shl    $0x4,%eax
80101439:	05 60 22 11 80       	add    $0x80112260,%eax
8010143e:	8b 50 16             	mov    0x16(%eax),%edx
80101441:	8b 45 08             	mov    0x8(%ebp),%eax
80101444:	83 ec 08             	sub    $0x8,%esp
80101447:	52                   	push   %edx
80101448:	50                   	push   %eax
80101449:	e8 68 ed ff ff       	call   801001b6 <bread>
8010144e:	83 c4 10             	add    $0x10,%esp
80101451:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memmove(&(sbs[partitionNumber]), bp->data, sizeof(struct superblock));
80101454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101457:	8d 50 18             	lea    0x18(%eax),%edx
8010145a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010145d:	c1 e0 05             	shl    $0x5,%eax
80101460:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101465:	83 ec 04             	sub    $0x4,%esp
80101468:	6a 20                	push   $0x20
8010146a:	52                   	push   %edx
8010146b:	50                   	push   %eax
8010146c:	e8 20 4a 00 00       	call   80105e91 <memmove>
80101471:	83 c4 10             	add    $0x10,%esp
    sbs[partitionNumber].offset=mbrI.partitions[partitionNumber].offset;
80101474:	8b 45 0c             	mov    0xc(%ebp),%eax
80101477:	83 c0 1b             	add    $0x1b,%eax
8010147a:	c1 e0 04             	shl    $0x4,%eax
8010147d:	05 60 22 11 80       	add    $0x80112260,%eax
80101482:	8b 40 16             	mov    0x16(%eax),%eax
80101485:	8b 55 0c             	mov    0xc(%ebp),%edx
80101488:	c1 e2 05             	shl    $0x5,%edx
8010148b:	81 c2 70 d6 10 80    	add    $0x8010d670,%edx
80101491:	89 42 0c             	mov    %eax,0xc(%edx)
    brelse(bp);
80101494:	83 ec 0c             	sub    $0xc,%esp
80101497:	ff 75 f4             	pushl  -0xc(%ebp)
8010149a:	e8 8f ed ff ff       	call   8010022e <brelse>
8010149f:	83 c4 10             	add    $0x10,%esp
}
801014a2:	90                   	nop
801014a3:	c9                   	leave  
801014a4:	c3                   	ret    

801014a5 <readmbr>:

void readmbr(int dev)
{
801014a5:	55                   	push   %ebp
801014a6:	89 e5                	mov    %esp,%ebp
801014a8:	83 ec 18             	sub    $0x18,%esp
    struct buf* bp;

    bp = bread(dev, 0);
801014ab:	8b 45 08             	mov    0x8(%ebp),%eax
801014ae:	83 ec 08             	sub    $0x8,%esp
801014b1:	6a 00                	push   $0x0
801014b3:	50                   	push   %eax
801014b4:	e8 fd ec ff ff       	call   801001b6 <bread>
801014b9:	83 c4 10             	add    $0x10,%esp
801014bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memmove(&mbrI, bp->data, sizeof(struct mbr));
801014bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c2:	83 c0 18             	add    $0x18,%eax
801014c5:	83 ec 04             	sub    $0x4,%esp
801014c8:	68 00 02 00 00       	push   $0x200
801014cd:	50                   	push   %eax
801014ce:	68 60 22 11 80       	push   $0x80112260
801014d3:	e8 b9 49 00 00       	call   80105e91 <memmove>
801014d8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801014db:	83 ec 0c             	sub    $0xc,%esp
801014de:	ff 75 f4             	pushl  -0xc(%ebp)
801014e1:	e8 48 ed ff ff       	call   8010022e <brelse>
801014e6:	83 c4 10             	add    $0x10,%esp
}
801014e9:	90                   	nop
801014ea:	c9                   	leave  
801014eb:	c3                   	ret    

801014ec <bzero>:

// Zero a block.
static void bzero(int dev, int bno,uint partitionNumber)
{
801014ec:	55                   	push   %ebp
801014ed:	89 e5                	mov    %esp,%ebp
801014ef:	83 ec 18             	sub    $0x18,%esp
    struct buf* bp;

    bp = bread(dev, bno);
801014f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801014f5:	8b 45 08             	mov    0x8(%ebp),%eax
801014f8:	83 ec 08             	sub    $0x8,%esp
801014fb:	52                   	push   %edx
801014fc:	50                   	push   %eax
801014fd:	e8 b4 ec ff ff       	call   801001b6 <bread>
80101502:	83 c4 10             	add    $0x10,%esp
80101505:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(bp->data, 0, BSIZE);
80101508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010150b:	83 c0 18             	add    $0x18,%eax
8010150e:	83 ec 04             	sub    $0x4,%esp
80101511:	68 00 02 00 00       	push   $0x200
80101516:	6a 00                	push   $0x0
80101518:	50                   	push   %eax
80101519:	e8 b4 48 00 00       	call   80105dd2 <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp,partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 f9 2c 00 00       	call   80104228 <log_write>
8010152f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101532:	83 ec 0c             	sub    $0xc,%esp
80101535:	ff 75 f4             	pushl  -0xc(%ebp)
80101538:	e8 f1 ec ff ff       	call   8010022e <brelse>
8010153d:	83 c4 10             	add    $0x10,%esp
}
80101540:	90                   	nop
80101541:	c9                   	leave  
80101542:	c3                   	ret    

80101543 <balloc>:

// Blocks.

// Allocate a zeroed disk block.
static uint balloc(uint dev, int partitionNumber)
{
80101543:	55                   	push   %ebp
80101544:	89 e5                	mov    %esp,%ebp
80101546:	83 ec 38             	sub    $0x38,%esp
    int b, bi, m;
    struct buf* bp;

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
80101549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010154c:	c1 e0 05             	shl    $0x5,%eax
8010154f:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101554:	8b 10                	mov    (%eax),%edx
80101556:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101559:	8b 50 04             	mov    0x4(%eax),%edx
8010155c:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010155f:	8b 50 08             	mov    0x8(%eax),%edx
80101562:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101565:	8b 50 0c             	mov    0xc(%eax),%edx
80101568:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010156b:	8b 50 10             	mov    0x10(%eax),%edx
8010156e:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101571:	8b 50 14             	mov    0x14(%eax),%edx
80101574:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101577:	8b 50 18             	mov    0x18(%eax),%edx
8010157a:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010157d:	8b 40 1c             	mov    0x1c(%eax),%eax
80101580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    bp = 0;
80101583:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for (b = 0; b < sb.size; b += BPB) {
8010158a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101591:	e9 23 01 00 00       	jmp    801016b9 <balloc+0x176>
        bp = bread(dev, BBLOCK(b, sb));
80101596:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159c:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
801015a2:	85 c0                	test   %eax,%eax
801015a4:	0f 48 c1             	cmovs  %ecx,%eax
801015a7:	c1 f8 0c             	sar    $0xc,%eax
801015aa:	89 c1                	mov    %eax,%ecx
801015ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801015af:	01 c8                	add    %ecx,%eax
801015b1:	01 d0                	add    %edx,%eax
801015b3:	83 ec 08             	sub    $0x8,%esp
801015b6:	50                   	push   %eax
801015b7:	ff 75 08             	pushl  0x8(%ebp)
801015ba:	e8 f7 eb ff ff       	call   801001b6 <bread>
801015bf:	83 c4 10             	add    $0x10,%esp
801015c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
801015c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015cc:	e9 b5 00 00 00       	jmp    80101686 <balloc+0x143>
            m = 1 << (bi % 8);
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	99                   	cltd   
801015d5:	c1 ea 1d             	shr    $0x1d,%edx
801015d8:	01 d0                	add    %edx,%eax
801015da:	83 e0 07             	and    $0x7,%eax
801015dd:	29 d0                	sub    %edx,%eax
801015df:	ba 01 00 00 00       	mov    $0x1,%edx
801015e4:	89 c1                	mov    %eax,%ecx
801015e6:	d3 e2                	shl    %cl,%edx
801015e8:	89 d0                	mov    %edx,%eax
801015ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
801015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f0:	8d 50 07             	lea    0x7(%eax),%edx
801015f3:	85 c0                	test   %eax,%eax
801015f5:	0f 48 c2             	cmovs  %edx,%eax
801015f8:	c1 f8 03             	sar    $0x3,%eax
801015fb:	89 c2                	mov    %eax,%edx
801015fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101600:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101605:	0f b6 c0             	movzbl %al,%eax
80101608:	23 45 e8             	and    -0x18(%ebp),%eax
8010160b:	85 c0                	test   %eax,%eax
8010160d:	75 73                	jne    80101682 <balloc+0x13f>
                bp->data[bi / 8] |= m;         // Mark block in use.
8010160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101612:	8d 50 07             	lea    0x7(%eax),%edx
80101615:	85 c0                	test   %eax,%eax
80101617:	0f 48 c2             	cmovs  %edx,%eax
8010161a:	c1 f8 03             	sar    $0x3,%eax
8010161d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101620:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101625:	89 d1                	mov    %edx,%ecx
80101627:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010162a:	09 ca                	or     %ecx,%edx
8010162c:	89 d1                	mov    %edx,%ecx
8010162e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101631:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
                log_write(bp,partitionNumber);
80101635:	8b 45 0c             	mov    0xc(%ebp),%eax
80101638:	83 ec 08             	sub    $0x8,%esp
8010163b:	50                   	push   %eax
8010163c:	ff 75 ec             	pushl  -0x14(%ebp)
8010163f:	e8 e4 2b 00 00       	call   80104228 <log_write>
80101644:	83 c4 10             	add    $0x10,%esp
                brelse(bp);
80101647:	83 ec 0c             	sub    $0xc,%esp
8010164a:	ff 75 ec             	pushl  -0x14(%ebp)
8010164d:	e8 dc eb ff ff       	call   8010022e <brelse>
80101652:	83 c4 10             	add    $0x10,%esp
                bzero(dev, sb.offset +b + bi,partitionNumber);
80101655:	8b 55 0c             	mov    0xc(%ebp),%edx
80101658:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010165b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165e:	01 c1                	add    %eax,%ecx
80101660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101663:	01 c8                	add    %ecx,%eax
80101665:	89 c1                	mov    %eax,%ecx
80101667:	8b 45 08             	mov    0x8(%ebp),%eax
8010166a:	83 ec 04             	sub    $0x4,%esp
8010166d:	52                   	push   %edx
8010166e:	51                   	push   %ecx
8010166f:	50                   	push   %eax
80101670:	e8 77 fe ff ff       	call   801014ec <bzero>
80101675:	83 c4 10             	add    $0x10,%esp
                return b + bi;
80101678:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167e:	01 d0                	add    %edx,%eax
80101680:	eb 52                	jmp    801016d4 <balloc+0x191>
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
        bp = bread(dev, BBLOCK(b, sb));
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
80101682:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101686:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010168d:	7f 15                	jg     801016a4 <balloc+0x161>
8010168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101695:	01 d0                	add    %edx,%eax
80101697:	89 c2                	mov    %eax,%edx
80101699:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010169c:	39 c2                	cmp    %eax,%edx
8010169e:	0f 82 2d ff ff ff    	jb     801015d1 <balloc+0x8e>
                brelse(bp);
                bzero(dev, sb.offset +b + bi,partitionNumber);
                return b + bi;
            }
        }
        brelse(bp);
801016a4:	83 ec 0c             	sub    $0xc,%esp
801016a7:	ff 75 ec             	pushl  -0x14(%ebp)
801016aa:	e8 7f eb ff ff       	call   8010022e <brelse>
801016af:	83 c4 10             	add    $0x10,%esp

    struct superblock sb;
   // cprintf("balloc \n");
    sb = sbs[partitionNumber];
    bp = 0;
    for (b = 0; b < sb.size; b += BPB) {
801016b2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016b9:	8b 55 c8             	mov    -0x38(%ebp),%edx
801016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016bf:	39 c2                	cmp    %eax,%edx
801016c1:	0f 87 cf fe ff ff    	ja     80101596 <balloc+0x53>
                return b + bi;
            }
        }
        brelse(bp);
    }
    panic("balloc: out of blocks");
801016c7:	83 ec 0c             	sub    $0xc,%esp
801016ca:	68 24 94 10 80       	push   $0x80109424
801016cf:	e8 92 ee ff ff       	call   80100566 <panic>
}
801016d4:	c9                   	leave  
801016d5:	c3                   	ret    

801016d6 <bfree>:

// Free a disk block.
static void bfree(int dev, uint b, int partitionNumber)
{
801016d6:	55                   	push   %ebp
801016d7:	89 e5                	mov    %esp,%ebp
801016d9:	83 ec 38             	sub    $0x38,%esp
      //  cprintf("bfree \n");

    struct buf* bp;
    int bi, m;
    struct superblock sb;
    sb = sbs[partitionNumber];
801016dc:	8b 45 10             	mov    0x10(%ebp),%eax
801016df:	c1 e0 05             	shl    $0x5,%eax
801016e2:	05 60 d6 10 80       	add    $0x8010d660,%eax
801016e7:	8b 10                	mov    (%eax),%edx
801016e9:	89 55 cc             	mov    %edx,-0x34(%ebp)
801016ec:	8b 50 04             	mov    0x4(%eax),%edx
801016ef:	89 55 d0             	mov    %edx,-0x30(%ebp)
801016f2:	8b 50 08             	mov    0x8(%eax),%edx
801016f5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801016f8:	8b 50 0c             	mov    0xc(%eax),%edx
801016fb:	89 55 d8             	mov    %edx,-0x28(%ebp)
801016fe:	8b 50 10             	mov    0x10(%eax),%edx
80101701:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101704:	8b 50 14             	mov    0x14(%eax),%edx
80101707:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010170a:	8b 50 18             	mov    0x18(%eax),%edx
8010170d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101710:	8b 40 1c             	mov    0x1c(%eax),%eax
80101713:	89 45 e8             	mov    %eax,-0x18(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101716:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101719:	8b 55 0c             	mov    0xc(%ebp),%edx
8010171c:	89 d1                	mov    %edx,%ecx
8010171e:	c1 e9 0c             	shr    $0xc,%ecx
80101721:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101724:	01 ca                	add    %ecx,%edx
80101726:	01 c2                	add    %eax,%edx
80101728:	8b 45 08             	mov    0x8(%ebp),%eax
8010172b:	83 ec 08             	sub    $0x8,%esp
8010172e:	52                   	push   %edx
8010172f:	50                   	push   %eax
80101730:	e8 81 ea ff ff       	call   801001b6 <bread>
80101735:	83 c4 10             	add    $0x10,%esp
80101738:	89 45 f4             	mov    %eax,-0xc(%ebp)
    bi = b % BPB;
8010173b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101743:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = 1 << (bi % 8);
80101746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101749:	99                   	cltd   
8010174a:	c1 ea 1d             	shr    $0x1d,%edx
8010174d:	01 d0                	add    %edx,%eax
8010174f:	83 e0 07             	and    $0x7,%eax
80101752:	29 d0                	sub    %edx,%eax
80101754:	ba 01 00 00 00       	mov    $0x1,%edx
80101759:	89 c1                	mov    %eax,%ecx
8010175b:	d3 e2                	shl    %cl,%edx
8010175d:	89 d0                	mov    %edx,%eax
8010175f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if ((bp->data[bi / 8] & m) == 0)
80101762:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101765:	8d 50 07             	lea    0x7(%eax),%edx
80101768:	85 c0                	test   %eax,%eax
8010176a:	0f 48 c2             	cmovs  %edx,%eax
8010176d:	c1 f8 03             	sar    $0x3,%eax
80101770:	89 c2                	mov    %eax,%edx
80101772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101775:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010177a:	0f b6 c0             	movzbl %al,%eax
8010177d:	23 45 ec             	and    -0x14(%ebp),%eax
80101780:	85 c0                	test   %eax,%eax
80101782:	75 0d                	jne    80101791 <bfree+0xbb>
        panic("freeing free block");
80101784:	83 ec 0c             	sub    $0xc,%esp
80101787:	68 3a 94 10 80       	push   $0x8010943a
8010178c:	e8 d5 ed ff ff       	call   80100566 <panic>
    bp->data[bi / 8] &= ~m;
80101791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101794:	8d 50 07             	lea    0x7(%eax),%edx
80101797:	85 c0                	test   %eax,%eax
80101799:	0f 48 c2             	cmovs  %edx,%eax
8010179c:	c1 f8 03             	sar    $0x3,%eax
8010179f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017a2:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017a7:	89 d1                	mov    %edx,%ecx
801017a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017ac:	f7 d2                	not    %edx
801017ae:	21 ca                	and    %ecx,%edx
801017b0:	89 d1                	mov    %edx,%ecx
801017b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017b5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
    log_write(bp,partitionNumber);
801017b9:	8b 45 10             	mov    0x10(%ebp),%eax
801017bc:	83 ec 08             	sub    $0x8,%esp
801017bf:	50                   	push   %eax
801017c0:	ff 75 f4             	pushl  -0xc(%ebp)
801017c3:	e8 60 2a 00 00       	call   80104228 <log_write>
801017c8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801017cb:	83 ec 0c             	sub    $0xc,%esp
801017ce:	ff 75 f4             	pushl  -0xc(%ebp)
801017d1:	e8 58 ea ff ff       	call   8010022e <brelse>
801017d6:	83 c4 10             	add    $0x10,%esp
}
801017d9:	90                   	nop
801017da:	c9                   	leave  
801017db:	c3                   	ret    

801017dc <printMBR>:
    struct spinlock lock;
    struct inode inode[NINODE];
} icache;

void printMBR(struct mbr* m)
{
801017dc:	55                   	push   %ebp
801017dd:	89 e5                	mov    %esp,%ebp
801017df:	83 ec 18             	sub    $0x18,%esp


    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
801017e2:	83 ec 0c             	sub    $0xc,%esp
801017e5:	68 4d 94 10 80       	push   $0x8010944d
801017ea:	e8 d7 eb ff ff       	call   801003c6 <cprintf>
801017ef:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPARTITIONS; i++) {
801017f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801017f9:	e9 f5 00 00 00       	jmp    801018f3 <printMBR+0x117>
        if (m->partitions[i].flags >1 && m->partitions[i].flags <4) {
801017fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101801:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101804:	83 c2 1b             	add    $0x1b,%edx
80101807:	c1 e2 04             	shl    $0x4,%edx
8010180a:	01 d0                	add    %edx,%eax
8010180c:	8b 40 0e             	mov    0xe(%eax),%eax
8010180f:	83 f8 01             	cmp    $0x1,%eax
80101812:	76 1f                	jbe    80101833 <printMBR+0x57>
80101814:	8b 45 08             	mov    0x8(%ebp),%eax
80101817:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010181a:	83 c2 1b             	add    $0x1b,%edx
8010181d:	c1 e2 04             	shl    $0x4,%edx
80101820:	01 d0                	add    %edx,%eax
80101822:	8b 40 0e             	mov    0xe(%eax),%eax
80101825:	83 f8 03             	cmp    $0x3,%eax
80101828:	77 09                	ja     80101833 <printMBR+0x57>
            bootable = "YES";
8010182a:	c7 45 f0 58 94 10 80 	movl   $0x80109458,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 5c 94 10 80 	movl   $0x8010945c,-0x10(%ebp)
        }

        if (m->partitions[i].type >= 0 && m->partitions[i].type < NELEM(FS_TYPE) && FS_TYPE[m->partitions[i].type]) {
8010183a:	8b 45 08             	mov    0x8(%ebp),%eax
8010183d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101840:	83 c2 1b             	add    $0x1b,%edx
80101843:	c1 e2 04             	shl    $0x4,%edx
80101846:	01 d0                	add    %edx,%eax
80101848:	8b 40 12             	mov    0x12(%eax),%eax
8010184b:	83 f8 01             	cmp    $0x1,%eax
8010184e:	77 39                	ja     80101889 <printMBR+0xad>
80101850:	8b 45 08             	mov    0x8(%ebp),%eax
80101853:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101856:	83 c2 1b             	add    $0x1b,%edx
80101859:	c1 e2 04             	shl    $0x4,%edx
8010185c:	01 d0                	add    %edx,%eax
8010185e:	8b 40 12             	mov    0x12(%eax),%eax
80101861:	8b 04 85 20 a0 10 80 	mov    -0x7fef5fe0(,%eax,4),%eax
80101868:	85 c0                	test   %eax,%eax
8010186a:	74 1d                	je     80101889 <printMBR+0xad>
            type = FS_TYPE[m->partitions[i].type];
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101872:	83 c2 1b             	add    $0x1b,%edx
80101875:	c1 e2 04             	shl    $0x4,%edx
80101878:	01 d0                	add    %edx,%eax
8010187a:	8b 40 12             	mov    0x12(%eax),%eax
8010187d:	8b 04 85 20 a0 10 80 	mov    -0x7fef5fe0(,%eax,4),%eax
80101884:	89 45 ec             	mov    %eax,-0x14(%ebp)
80101887:	eb 29                	jmp    801018b2 <printMBR+0xd6>

        } else {
            type = "???";
80101889:	c7 45 ec 5f 94 10 80 	movl   $0x8010945f,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 63 94 10 80       	push   $0x80109463
801018aa:	e8 17 eb ff ff       	call   801003c6 <cprintf>
801018af:	83 c4 10             	add    $0x10,%esp
        }

        cprintf("partition %d: bootable %s type %s offset %d size %d \n",
801018b2:	8b 45 08             	mov    0x8(%ebp),%eax
801018b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018b8:	83 c2 1b             	add    $0x1b,%edx
801018bb:	c1 e2 04             	shl    $0x4,%edx
801018be:	01 d0                	add    %edx,%eax
801018c0:	8b 50 1a             	mov    0x1a(%eax),%edx
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801018c9:	83 c1 1b             	add    $0x1b,%ecx
801018cc:	c1 e1 04             	shl    $0x4,%ecx
801018cf:	01 c8                	add    %ecx,%eax
801018d1:	8b 40 16             	mov    0x16(%eax),%eax
801018d4:	83 ec 08             	sub    $0x8,%esp
801018d7:	52                   	push   %edx
801018d8:	50                   	push   %eax
801018d9:	ff 75 ec             	pushl  -0x14(%ebp)
801018dc:	ff 75 f0             	pushl  -0x10(%ebp)
801018df:	ff 75 f4             	pushl  -0xc(%ebp)
801018e2:	68 78 94 10 80       	push   $0x80109478
801018e7:	e8 da ea ff ff       	call   801003c6 <cprintf>
801018ec:	83 c4 20             	add    $0x20,%esp

    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
    for (i = 0; i < NPARTITIONS; i++) {
801018ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018f3:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801018f7:	0f 8e 01 ff ff ff    	jle    801017fe <printMBR+0x22>
                bootable,
                type,
                m->partitions[i].offset,
                m->partitions[i].size);
    }
    cprintf("magic %s \n", m->magic);
801018fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101900:	05 fe 01 00 00       	add    $0x1fe,%eax
80101905:	83 ec 08             	sub    $0x8,%esp
80101908:	50                   	push   %eax
80101909:	68 ae 94 10 80       	push   $0x801094ae
8010190e:	e8 b3 ea ff ff       	call   801003c6 <cprintf>
80101913:	83 c4 10             	add    $0x10,%esp
}
80101916:	90                   	nop
80101917:	c9                   	leave  
80101918:	c3                   	ret    

80101919 <initMbr>:

void initMbr(int dev)
{
80101919:	55                   	push   %ebp
8010191a:	89 e5                	mov    %esp,%ebp
8010191c:	83 ec 18             	sub    $0x18,%esp

   
    readmbr(dev);
8010191f:	83 ec 0c             	sub    $0xc,%esp
80101922:	ff 75 08             	pushl  0x8(%ebp)
80101925:	e8 7b fb ff ff       	call   801014a5 <readmbr>
8010192a:	83 c4 10             	add    $0x10,%esp
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
8010192d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101934:	e9 f4 00 00 00       	jmp    80101a2d <initMbr+0x114>
        if (mbrI.partitions[i].flags >= PART_BOOTABLE && bootfrom == -1) {
80101939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193c:	83 c0 1b             	add    $0x1b,%eax
8010193f:	c1 e0 04             	shl    $0x4,%eax
80101942:	05 60 22 11 80       	add    $0x80112260,%eax
80101947:	8b 40 0e             	mov    0xe(%eax),%eax
8010194a:	83 f8 01             	cmp    $0x1,%eax
8010194d:	76 1a                	jbe    80101969 <initMbr+0x50>
8010194f:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101954:	83 f8 ff             	cmp    $0xffffffff,%eax
80101957:	75 10                	jne    80101969 <initMbr+0x50>
            bootfrom = i;
80101959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195c:	a3 18 a0 10 80       	mov    %eax,0x8010a018
            currentPart = i;
80101961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101964:	a3 1c a0 10 80       	mov    %eax,0x8010a01c
        }
        partitions[i].dev = dev;
80101969:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010196c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010196f:	89 d0                	mov    %edx,%eax
80101971:	01 c0                	add    %eax,%eax
80101973:	01 d0                	add    %edx,%eax
80101975:	c1 e0 03             	shl    $0x3,%eax
80101978:	05 00 18 11 80       	add    $0x80111800,%eax
8010197d:	89 08                	mov    %ecx,(%eax)
        partitions[i].flags = mbrI.partitions[i].flags;
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	83 c0 1b             	add    $0x1b,%eax
80101985:	c1 e0 04             	shl    $0x4,%eax
80101988:	05 60 22 11 80       	add    $0x80112260,%eax
8010198d:	8b 48 0e             	mov    0xe(%eax),%ecx
80101990:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101993:	89 d0                	mov    %edx,%eax
80101995:	01 c0                	add    %eax,%eax
80101997:	01 d0                	add    %edx,%eax
80101999:	c1 e0 03             	shl    $0x3,%eax
8010199c:	05 00 18 11 80       	add    $0x80111800,%eax
801019a1:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].type = mbrI.partitions[i].type;
801019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a7:	83 c0 1b             	add    $0x1b,%eax
801019aa:	c1 e0 04             	shl    $0x4,%eax
801019ad:	05 60 22 11 80       	add    $0x80112260,%eax
801019b2:	8b 48 12             	mov    0x12(%eax),%ecx
801019b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019b8:	89 d0                	mov    %edx,%eax
801019ba:	01 c0                	add    %eax,%eax
801019bc:	01 d0                	add    %edx,%eax
801019be:	c1 e0 03             	shl    $0x3,%eax
801019c1:	05 00 18 11 80       	add    $0x80111800,%eax
801019c6:	89 48 08             	mov    %ecx,0x8(%eax)
        partitions[i].number = i;
801019c9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801019cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019cf:	89 d0                	mov    %edx,%eax
801019d1:	01 c0                	add    %eax,%eax
801019d3:	01 d0                	add    %edx,%eax
801019d5:	c1 e0 03             	shl    $0x3,%eax
801019d8:	05 10 18 11 80       	add    $0x80111810,%eax
801019dd:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].offset = mbrI.partitions[i].offset;
801019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e3:	83 c0 1b             	add    $0x1b,%eax
801019e6:	c1 e0 04             	shl    $0x4,%eax
801019e9:	05 60 22 11 80       	add    $0x80112260,%eax
801019ee:	8b 48 16             	mov    0x16(%eax),%ecx
801019f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019f4:	89 d0                	mov    %edx,%eax
801019f6:	01 c0                	add    %eax,%eax
801019f8:	01 d0                	add    %edx,%eax
801019fa:	c1 e0 03             	shl    $0x3,%eax
801019fd:	05 00 18 11 80       	add    $0x80111800,%eax
80101a02:	89 48 0c             	mov    %ecx,0xc(%eax)
        partitions[i].size = mbrI.partitions[i].size;
80101a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a08:	83 c0 1b             	add    $0x1b,%eax
80101a0b:	c1 e0 04             	shl    $0x4,%eax
80101a0e:	05 60 22 11 80       	add    $0x80112260,%eax
80101a13:	8b 48 1a             	mov    0x1a(%eax),%ecx
80101a16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a19:	89 d0                	mov    %edx,%eax
80101a1b:	01 c0                	add    %eax,%eax
80101a1d:	01 d0                	add    %edx,%eax
80101a1f:	c1 e0 03             	shl    $0x3,%eax
80101a22:	05 10 18 11 80       	add    $0x80111810,%eax
80101a27:	89 08                	mov    %ecx,(%eax)

   
    readmbr(dev);
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
80101a29:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a2d:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80101a31:	0f 8e 02 ff ff ff    	jle    80101939 <initMbr+0x20>
        partitions[i].size = mbrI.partitions[i].size;
    }


    
}
80101a37:	90                   	nop
80101a38:	c9                   	leave  
80101a39:	c3                   	ret    

80101a3a <iinit>:

int iinit(struct proc* p, int dev)
{
80101a3a:	55                   	push   %ebp
80101a3b:	89 e5                	mov    %esp,%ebp
80101a3d:	57                   	push   %edi
80101a3e:	56                   	push   %esi
80101a3f:	53                   	push   %ebx
80101a40:	83 ec 4c             	sub    $0x4c,%esp
    struct inode* rootNode;
    struct superblock sb;
    // TODO: change ot iterate over all partitions

    initlock(&icache.lock, "icache");
80101a43:	83 ec 08             	sub    $0x8,%esp
80101a46:	68 b9 94 10 80       	push   $0x801094b9
80101a4b:	68 60 24 11 80       	push   $0x80112460
80101a50:	e8 f8 40 00 00       	call   80105b4d <initlock>
80101a55:	83 c4 10             	add    $0x10,%esp

    rootNode = p->cwd;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 68             	mov    0x68(%eax),%eax
80101a5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // acquire(&icache.lock);

    initMbr(dev);
80101a61:	83 ec 0c             	sub    $0xc,%esp
80101a64:	ff 75 0c             	pushl  0xc(%ebp)
80101a67:	e8 ad fe ff ff       	call   80101919 <initMbr>
80101a6c:	83 c4 10             	add    $0x10,%esp
    printMBR(&mbrI);
80101a6f:	83 ec 0c             	sub    $0xc,%esp
80101a72:	68 60 22 11 80       	push   $0x80112260
80101a77:	e8 60 fd ff ff       	call   801017dc <printMBR>
80101a7c:	83 c4 10             	add    $0x10,%esp
    cprintf("booting from %d \n",bootfrom);
80101a7f:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a84:	83 ec 08             	sub    $0x8,%esp
80101a87:	50                   	push   %eax
80101a88:	68 c0 94 10 80       	push   $0x801094c0
80101a8d:	e8 34 e9 ff ff       	call   801003c6 <cprintf>
80101a92:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a95:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a9a:	83 f8 ff             	cmp    $0xffffffff,%eax
80101a9d:	75 0d                	jne    80101aac <iinit+0x72>
        panic("no bootable partition");
80101a9f:	83 ec 0c             	sub    $0xc,%esp
80101aa2:	68 d2 94 10 80       	push   $0x801094d2
80101aa7:	e8 ba ea ff ff       	call   80100566 <panic>
    }
    readsb(dev, bootfrom);
80101aac:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101ab1:	83 ec 08             	sub    $0x8,%esp
80101ab4:	50                   	push   %eax
80101ab5:	ff 75 0c             	pushl  0xc(%ebp)
80101ab8:	e8 6d f9 ff ff       	call   8010142a <readsb>
80101abd:	83 c4 10             	add    $0x10,%esp
    sb = sbs[bootfrom];
80101ac0:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101ac5:	c1 e0 05             	shl    $0x5,%eax
80101ac8:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101acd:	8b 10                	mov    (%eax),%edx
80101acf:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80101ad2:	8b 50 04             	mov    0x4(%eax),%edx
80101ad5:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101ad8:	8b 50 08             	mov    0x8(%eax),%edx
80101adb:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101ade:	8b 50 0c             	mov    0xc(%eax),%edx
80101ae1:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101ae4:	8b 50 10             	mov    0x10(%eax),%edx
80101ae7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101aea:	8b 50 14             	mov    0x14(%eax),%edx
80101aed:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101af0:	8b 50 18             	mov    0x18(%eax),%edx
80101af3:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101af6:	8b 40 1c             	mov    0x1c(%eax),%eax
80101af9:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // set root inode
    rootNode->part = &(partitions[bootfrom]);
80101afc:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
80101b02:	89 d0                	mov    %edx,%eax
80101b04:	01 c0                	add    %eax,%eax
80101b06:	01 d0                	add    %edx,%eax
80101b08:	c1 e0 03             	shl    $0x3,%eax
80101b0b:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101b14:	89 50 50             	mov    %edx,0x50(%eax)
    // release(&icache.lock);

    // cprintf("root node init %d \n",rootNode->part->offset);
    cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
80101b17:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101b1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101b1d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80101b20:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80101b23:	89 4d b0             	mov    %ecx,-0x50(%ebp)
80101b26:	8b 7d d0             	mov    -0x30(%ebp),%edi
80101b29:	8b 75 cc             	mov    -0x34(%ebp),%esi
80101b2c:	8b 5d c8             	mov    -0x38(%ebp),%ebx
80101b2f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
80101b32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101b35:	83 ec 0c             	sub    $0xc,%esp
80101b38:	52                   	push   %edx
80101b39:	ff 75 b4             	pushl  -0x4c(%ebp)
80101b3c:	ff 75 b0             	pushl  -0x50(%ebp)
80101b3f:	57                   	push   %edi
80101b40:	56                   	push   %esi
80101b41:	53                   	push   %ebx
80101b42:	51                   	push   %ecx
80101b43:	50                   	push   %eax
80101b44:	68 e8 94 10 80       	push   $0x801094e8
80101b49:	e8 78 e8 ff ff       	call   801003c6 <cprintf>
80101b4e:	83 c4 30             	add    $0x30,%esp
            sb.logstart,
            sb.inodestart,
            sb.bmapstart);
            
    
            return bootfrom;
80101b51:	a1 18 a0 10 80       	mov    0x8010a018,%eax
}
80101b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b59:	5b                   	pop    %ebx
80101b5a:	5e                   	pop    %esi
80101b5b:	5f                   	pop    %edi
80101b5c:	5d                   	pop    %ebp
80101b5d:	c3                   	ret    

80101b5e <ialloc>:

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 48             	sub    $0x48,%esp
80101b64:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b67:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
     //cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
80101b6b:	8b 45 10             	mov    0x10(%ebp),%eax
80101b6e:	c1 e0 05             	shl    $0x5,%eax
80101b71:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101b76:	8b 10                	mov    (%eax),%edx
80101b78:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101b7b:	8b 50 04             	mov    0x4(%eax),%edx
80101b7e:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b81:	8b 50 08             	mov    0x8(%eax),%edx
80101b84:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101b87:	8b 50 0c             	mov    0xc(%eax),%edx
80101b8a:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101b8d:	8b 50 10             	mov    0x10(%eax),%edx
80101b90:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101b93:	8b 50 14             	mov    0x14(%eax),%edx
80101b96:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101b99:	8b 50 18             	mov    0x18(%eax),%edx
80101b9c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101b9f:	8b 40 1c             	mov    0x1c(%eax),%eax
80101ba2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101ba5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101bac:	e9 a9 00 00 00       	jmp    80101c5a <ialloc+0xfc>
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
80101bb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb7:	89 d1                	mov    %edx,%ecx
80101bb9:	c1 e9 03             	shr    $0x3,%ecx
80101bbc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101bbf:	01 ca                	add    %ecx,%edx
80101bc1:	01 d0                	add    %edx,%eax
80101bc3:	83 ec 08             	sub    $0x8,%esp
80101bc6:	50                   	push   %eax
80101bc7:	ff 75 08             	pushl  0x8(%ebp)
80101bca:	e8 e7 e5 ff ff       	call   801001b6 <bread>
80101bcf:	83 c4 10             	add    $0x10,%esp
80101bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        dip = (struct dinode*)bp->data + inum % IPB;
80101bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd8:	8d 50 18             	lea    0x18(%eax),%edx
80101bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bde:	83 e0 07             	and    $0x7,%eax
80101be1:	c1 e0 06             	shl    $0x6,%eax
80101be4:	01 d0                	add    %edx,%eax
80101be6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (dip->type == 0) { // a free inode
80101be9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bec:	0f b7 00             	movzwl (%eax),%eax
80101bef:	66 85 c0             	test   %ax,%ax
80101bf2:	75 54                	jne    80101c48 <ialloc+0xea>
            memset(dip, 0, sizeof(*dip));
80101bf4:	83 ec 04             	sub    $0x4,%esp
80101bf7:	6a 40                	push   $0x40
80101bf9:	6a 00                	push   $0x0
80101bfb:	ff 75 ec             	pushl  -0x14(%ebp)
80101bfe:	e8 cf 41 00 00       	call   80105dd2 <memset>
80101c03:	83 c4 10             	add    $0x10,%esp
            dip->type = type;
80101c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c09:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
80101c0d:	66 89 10             	mov    %dx,(%eax)
            log_write(bp,partitionNumber); // mark it allocated on the disk
80101c10:	8b 45 10             	mov    0x10(%ebp),%eax
80101c13:	83 ec 08             	sub    $0x8,%esp
80101c16:	50                   	push   %eax
80101c17:	ff 75 f0             	pushl  -0x10(%ebp)
80101c1a:	e8 09 26 00 00       	call   80104228 <log_write>
80101c1f:	83 c4 10             	add    $0x10,%esp
            brelse(bp);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	ff 75 f0             	pushl  -0x10(%ebp)
80101c28:	e8 01 e6 ff ff       	call   8010022e <brelse>
80101c2d:	83 c4 10             	add    $0x10,%esp
            return iget(dev, inum, partitionNumber);
80101c30:	8b 55 10             	mov    0x10(%ebp),%edx
80101c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c36:	83 ec 04             	sub    $0x4,%esp
80101c39:	52                   	push   %edx
80101c3a:	50                   	push   %eax
80101c3b:	ff 75 08             	pushl  0x8(%ebp)
80101c3e:	e8 42 01 00 00       	call   80101d85 <iget>
80101c43:	83 c4 10             	add    $0x10,%esp
80101c46:	eb 2d                	jmp    80101c75 <ialloc+0x117>
        }
        brelse(bp);
80101c48:	83 ec 0c             	sub    $0xc,%esp
80101c4b:	ff 75 f0             	pushl  -0x10(%ebp)
80101c4e:	e8 db e5 ff ff       	call   8010022e <brelse>
80101c53:	83 c4 10             	add    $0x10,%esp
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101c56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c60:	39 c2                	cmp    %eax,%edx
80101c62:	0f 87 49 ff ff ff    	ja     80101bb1 <ialloc+0x53>
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
80101c68:	83 ec 0c             	sub    $0xc,%esp
80101c6b:	68 45 95 10 80       	push   $0x80109545
80101c70:	e8 f1 e8 ff ff       	call   80100566 <panic>
}
80101c75:	c9                   	leave  
80101c76:	c3                   	ret    

80101c77 <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{
80101c77:	55                   	push   %ebp
80101c78:	89 e5                	mov    %esp,%ebp
80101c7a:	83 ec 38             	sub    $0x38,%esp

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
80101c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c80:	8b 40 50             	mov    0x50(%eax),%eax
80101c83:	8b 40 14             	mov    0x14(%eax),%eax
80101c86:	c1 e0 05             	shl    $0x5,%eax
80101c89:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101c8e:	8b 10                	mov    (%eax),%edx
80101c90:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101c93:	8b 50 04             	mov    0x4(%eax),%edx
80101c96:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101c99:	8b 50 08             	mov    0x8(%eax),%edx
80101c9c:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101c9f:	8b 50 0c             	mov    0xc(%eax),%edx
80101ca2:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ca5:	8b 50 10             	mov    0x10(%eax),%edx
80101ca8:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101cab:	8b 50 14             	mov    0x14(%eax),%edx
80101cae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101cb1:	8b 50 18             	mov    0x18(%eax),%edx
80101cb4:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101cb7:	8b 40 1c             	mov    0x1c(%eax),%eax
80101cba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101cbd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc3:	8b 40 04             	mov    0x4(%eax),%eax
80101cc6:	c1 e8 03             	shr    $0x3,%eax
80101cc9:	89 c1                	mov    %eax,%ecx
80101ccb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101cce:	01 c8                	add    %ecx,%eax
80101cd0:	01 c2                	add    %eax,%edx
80101cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd5:	8b 00                	mov    (%eax),%eax
80101cd7:	83 ec 08             	sub    $0x8,%esp
80101cda:	52                   	push   %edx
80101cdb:	50                   	push   %eax
80101cdc:	e8 d5 e4 ff ff       	call   801001b6 <bread>
80101ce1:	83 c4 10             	add    $0x10,%esp
80101ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum % IPB;
80101ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cea:	8d 50 18             	lea    0x18(%eax),%edx
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 40 04             	mov    0x4(%eax),%eax
80101cf3:	83 e0 07             	and    $0x7,%eax
80101cf6:	c1 e0 06             	shl    $0x6,%eax
80101cf9:	01 d0                	add    %edx,%eax
80101cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip->type = ip->type;
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d08:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0e:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d15:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101d19:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1c:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d23:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d31:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 50 18             	mov    0x18(%eax),%edx
80101d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d3e:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101d41:	8b 45 08             	mov    0x8(%ebp),%eax
80101d44:	8d 50 1c             	lea    0x1c(%eax),%edx
80101d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4a:	83 c0 0c             	add    $0xc,%eax
80101d4d:	83 ec 04             	sub    $0x4,%esp
80101d50:	6a 34                	push   $0x34
80101d52:	52                   	push   %edx
80101d53:	50                   	push   %eax
80101d54:	e8 38 41 00 00       	call   80105e91 <memmove>
80101d59:	83 c4 10             	add    $0x10,%esp
    log_write(bp,ip->part->number);
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	8b 40 50             	mov    0x50(%eax),%eax
80101d62:	8b 40 14             	mov    0x14(%eax),%eax
80101d65:	83 ec 08             	sub    $0x8,%esp
80101d68:	50                   	push   %eax
80101d69:	ff 75 f4             	pushl  -0xc(%ebp)
80101d6c:	e8 b7 24 00 00       	call   80104228 <log_write>
80101d71:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101d74:	83 ec 0c             	sub    $0xc,%esp
80101d77:	ff 75 f4             	pushl  -0xc(%ebp)
80101d7a:	e8 af e4 ff ff       	call   8010022e <brelse>
80101d7f:	83 c4 10             	add    $0x10,%esp
}
80101d82:	90                   	nop
80101d83:	c9                   	leave  
80101d84:	c3                   	ret    

80101d85 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
80101d85:	55                   	push   %ebp
80101d86:	89 e5                	mov    %esp,%ebp
80101d88:	83 ec 18             	sub    $0x18,%esp
    struct inode* ip, *empty;

    acquire(&icache.lock);
80101d8b:	83 ec 0c             	sub    $0xc,%esp
80101d8e:	68 60 24 11 80       	push   $0x80112460
80101d93:	e8 d7 3d 00 00       	call   80105b6f <acquire>
80101d98:	83 c4 10             	add    $0x10,%esp
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
80101d9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101da2:	c7 45 f4 94 24 11 80 	movl   $0x80112494,-0xc(%ebp)
80101da9:	eb 78                	jmp    80101e23 <iget+0x9e>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
80101dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dae:	8b 40 08             	mov    0x8(%eax),%eax
80101db1:	85 c0                	test   %eax,%eax
80101db3:	7e 54                	jle    80101e09 <iget+0x84>
80101db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101db8:	8b 00                	mov    (%eax),%eax
80101dba:	3b 45 08             	cmp    0x8(%ebp),%eax
80101dbd:	75 4a                	jne    80101e09 <iget+0x84>
80101dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc2:	8b 40 04             	mov    0x4(%eax),%eax
80101dc5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101dc8:	75 3f                	jne    80101e09 <iget+0x84>
80101dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dcd:	8b 40 50             	mov    0x50(%eax),%eax
80101dd0:	85 c0                	test   %eax,%eax
80101dd2:	74 35                	je     80101e09 <iget+0x84>
80101dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd7:	8b 40 50             	mov    0x50(%eax),%eax
80101dda:	8b 40 14             	mov    0x14(%eax),%eax
80101ddd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de0:	75 27                	jne    80101e09 <iget+0x84>
            ip->ref++;
80101de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de5:	8b 40 08             	mov    0x8(%eax),%eax
80101de8:	8d 50 01             	lea    0x1(%eax),%edx
80101deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dee:	89 50 08             	mov    %edx,0x8(%eax)
            release(&icache.lock);
80101df1:	83 ec 0c             	sub    $0xc,%esp
80101df4:	68 60 24 11 80       	push   $0x80112460
80101df9:	e8 d8 3d 00 00       	call   80105bd6 <release>
80101dfe:	83 c4 10             	add    $0x10,%esp
            return ip;
80101e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e04:	e9 90 00 00 00       	jmp    80101e99 <iget+0x114>
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101e09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e0d:	75 10                	jne    80101e1f <iget+0x9a>
80101e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e12:	8b 40 08             	mov    0x8(%eax),%eax
80101e15:	85 c0                	test   %eax,%eax
80101e17:	75 06                	jne    80101e1f <iget+0x9a>
            empty = ip;
80101e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&icache.lock);
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101e1f:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101e23:	81 7d f4 fc 34 11 80 	cmpl   $0x801134fc,-0xc(%ebp)
80101e2a:	0f 82 7b ff ff ff    	jb     80101dab <iget+0x26>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
80101e30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e34:	75 0d                	jne    80101e43 <iget+0xbe>
        panic("iget: no inodes");
80101e36:	83 ec 0c             	sub    $0xc,%esp
80101e39:	68 57 95 10 80       	push   $0x80109557
80101e3e:	e8 23 e7 ff ff       	call   80100566 <panic>

    ip = empty;
80101e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip->dev = dev;
80101e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4f:	89 10                	mov    %edx,(%eax)
    ip->inum = inum;
80101e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e54:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e57:	89 50 04             	mov    %edx,0x4(%eax)
    ip->part = &(partitions[partitionNumber]);
80101e5a:	8b 55 10             	mov    0x10(%ebp),%edx
80101e5d:	89 d0                	mov    %edx,%eax
80101e5f:	01 c0                	add    %eax,%eax
80101e61:	01 d0                	add    %edx,%eax
80101e63:	c1 e0 03             	shl    $0x3,%eax
80101e66:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e6f:	89 50 50             	mov    %edx,0x50(%eax)
    ip->ref = 1;
80101e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e75:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    ip->flags = 0;
80101e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e7f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    release(&icache.lock);
80101e86:	83 ec 0c             	sub    $0xc,%esp
80101e89:	68 60 24 11 80       	push   $0x80112460
80101e8e:	e8 43 3d 00 00       	call   80105bd6 <release>
80101e93:	83 c4 10             	add    $0x10,%esp

    return ip;
80101e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101e99:	c9                   	leave  
80101e9a:	c3                   	ret    

80101e9b <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
80101e9b:	55                   	push   %ebp
80101e9c:	89 e5                	mov    %esp,%ebp
80101e9e:	83 ec 08             	sub    $0x8,%esp
             //   cprintf("idup \n");

    acquire(&icache.lock);
80101ea1:	83 ec 0c             	sub    $0xc,%esp
80101ea4:	68 60 24 11 80       	push   $0x80112460
80101ea9:	e8 c1 3c 00 00       	call   80105b6f <acquire>
80101eae:	83 c4 10             	add    $0x10,%esp
    ip->ref++;
80101eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb4:	8b 40 08             	mov    0x8(%eax),%eax
80101eb7:	8d 50 01             	lea    0x1(%eax),%edx
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101ec0:	83 ec 0c             	sub    $0xc,%esp
80101ec3:	68 60 24 11 80       	push   $0x80112460
80101ec8:	e8 09 3d 00 00       	call   80105bd6 <release>
80101ecd:	83 c4 10             	add    $0x10,%esp
    return ip;
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ed3:	c9                   	leave  
80101ed4:	c3                   	ret    

80101ed5 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
80101ed5:	55                   	push   %ebp
80101ed6:	89 e5                	mov    %esp,%ebp
80101ed8:	83 ec 38             	sub    $0x38,%esp
    struct buf* bp;
    struct dinode* dip;
                 //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
80101edb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101edf:	74 0a                	je     80101eeb <ilock+0x16>
80101ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee4:	8b 40 08             	mov    0x8(%eax),%eax
80101ee7:	85 c0                	test   %eax,%eax
80101ee9:	7f 0d                	jg     80101ef8 <ilock+0x23>
        panic("ilock");
80101eeb:	83 ec 0c             	sub    $0xc,%esp
80101eee:	68 67 95 10 80       	push   $0x80109567
80101ef3:	e8 6e e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101ef8:	83 ec 0c             	sub    $0xc,%esp
80101efb:	68 60 24 11 80       	push   $0x80112460
80101f00:	e8 6a 3c 00 00       	call   80105b6f <acquire>
80101f05:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f08:	eb 13                	jmp    80101f1d <ilock+0x48>
        sleep(ip, &icache.lock);
80101f0a:	83 ec 08             	sub    $0x8,%esp
80101f0d:	68 60 24 11 80       	push   $0x80112460
80101f12:	ff 75 08             	pushl  0x8(%ebp)
80101f15:	e8 5c 39 00 00       	call   80105876 <sleep>
80101f1a:	83 c4 10             	add    $0x10,%esp

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
80101f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f20:	8b 40 0c             	mov    0xc(%eax),%eax
80101f23:	83 e0 01             	and    $0x1,%eax
80101f26:	85 c0                	test   %eax,%eax
80101f28:	75 e0                	jne    80101f0a <ilock+0x35>
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
80101f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2d:	8b 40 0c             	mov    0xc(%eax),%eax
80101f30:	83 c8 01             	or     $0x1,%eax
80101f33:	89 c2                	mov    %eax,%edx
80101f35:	8b 45 08             	mov    0x8(%ebp),%eax
80101f38:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101f3b:	83 ec 0c             	sub    $0xc,%esp
80101f3e:	68 60 24 11 80       	push   $0x80112460
80101f43:	e8 8e 3c 00 00       	call   80105bd6 <release>
80101f48:	83 c4 10             	add    $0x10,%esp

    if (!(ip->flags & I_VALID)) {
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 40 0c             	mov    0xc(%eax),%eax
80101f51:	83 e0 02             	and    $0x2,%eax
80101f54:	85 c0                	test   %eax,%eax
80101f56:	0f 85 17 01 00 00    	jne    80102073 <ilock+0x19e>
        struct superblock sb;
        sb = sbs[ip->part->number];
80101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5f:	8b 40 50             	mov    0x50(%eax),%eax
80101f62:	8b 40 14             	mov    0x14(%eax),%eax
80101f65:	c1 e0 05             	shl    $0x5,%eax
80101f68:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101f6d:	8b 10                	mov    (%eax),%edx
80101f6f:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101f72:	8b 50 04             	mov    0x4(%eax),%edx
80101f75:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101f78:	8b 50 08             	mov    0x8(%eax),%edx
80101f7b:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101f7e:	8b 50 0c             	mov    0xc(%eax),%edx
80101f81:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101f84:	8b 50 10             	mov    0x10(%eax),%edx
80101f87:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101f8a:	8b 50 14             	mov    0x14(%eax),%edx
80101f8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101f90:	8b 50 18             	mov    0x18(%eax),%edx
80101f93:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101f96:	8b 40 1c             	mov    0x1c(%eax),%eax
80101f99:	89 45 ec             	mov    %eax,-0x14(%ebp)
       // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101f9c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	8b 40 04             	mov    0x4(%eax),%eax
80101fa5:	c1 e8 03             	shr    $0x3,%eax
80101fa8:	89 c1                	mov    %eax,%ecx
80101faa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101fad:	01 c8                	add    %ecx,%eax
80101faf:	01 c2                	add    %eax,%edx
80101fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb4:	8b 00                	mov    (%eax),%eax
80101fb6:	83 ec 08             	sub    $0x8,%esp
80101fb9:	52                   	push   %edx
80101fba:	50                   	push   %eax
80101fbb:	e8 f6 e1 ff ff       	call   801001b6 <bread>
80101fc0:	83 c4 10             	add    $0x10,%esp
80101fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        dip = (struct dinode*)bp->data + ip->inum % IPB;
80101fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc9:	8d 50 18             	lea    0x18(%eax),%edx
80101fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcf:	8b 40 04             	mov    0x4(%eax),%eax
80101fd2:	83 e0 07             	and    $0x7,%eax
80101fd5:	c1 e0 06             	shl    $0x6,%eax
80101fd8:	01 d0                	add    %edx,%eax
80101fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ip->type = dip->type;
80101fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe0:	0f b7 10             	movzwl (%eax),%edx
80101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe6:	66 89 50 10          	mov    %dx,0x10(%eax)
        ip->major = dip->major;
80101fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fed:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	66 89 50 12          	mov    %dx,0x12(%eax)
        ip->minor = dip->minor;
80101ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ffb:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101fff:	8b 45 08             	mov    0x8(%ebp),%eax
80102002:	66 89 50 14          	mov    %dx,0x14(%eax)
        ip->nlink = dip->nlink;
80102006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102009:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
80102010:	66 89 50 16          	mov    %dx,0x16(%eax)
        ip->size = dip->size;
80102014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102017:	8b 50 08             	mov    0x8(%eax),%edx
8010201a:	8b 45 08             	mov    0x8(%ebp),%eax
8010201d:	89 50 18             	mov    %edx,0x18(%eax)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80102020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102023:	8d 50 0c             	lea    0xc(%eax),%edx
80102026:	8b 45 08             	mov    0x8(%ebp),%eax
80102029:	83 c0 1c             	add    $0x1c,%eax
8010202c:	83 ec 04             	sub    $0x4,%esp
8010202f:	6a 34                	push   $0x34
80102031:	52                   	push   %edx
80102032:	50                   	push   %eax
80102033:	e8 59 3e 00 00       	call   80105e91 <memmove>
80102038:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010203b:	83 ec 0c             	sub    $0xc,%esp
8010203e:	ff 75 f4             	pushl  -0xc(%ebp)
80102041:	e8 e8 e1 ff ff       	call   8010022e <brelse>
80102046:	83 c4 10             	add    $0x10,%esp
        ip->flags |= I_VALID;
80102049:	8b 45 08             	mov    0x8(%ebp),%eax
8010204c:	8b 40 0c             	mov    0xc(%eax),%eax
8010204f:	83 c8 02             	or     $0x2,%eax
80102052:	89 c2                	mov    %eax,%edx
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	89 50 0c             	mov    %edx,0xc(%eax)
        if (ip->type == 0)
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102061:	66 85 c0             	test   %ax,%ax
80102064:	75 0d                	jne    80102073 <ilock+0x19e>
            panic("ilock: no type");
80102066:	83 ec 0c             	sub    $0xc,%esp
80102069:	68 6d 95 10 80       	push   $0x8010956d
8010206e:	e8 f3 e4 ff ff       	call   80100566 <panic>
    }
}
80102073:	90                   	nop
80102074:	c9                   	leave  
80102075:	c3                   	ret    

80102076 <iunlock>:

// Unlock the given inode.
void iunlock(struct inode* ip)
{
80102076:	55                   	push   %ebp
80102077:	89 e5                	mov    %esp,%ebp
80102079:	83 ec 08             	sub    $0x8,%esp
                  //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
8010207c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102080:	74 17                	je     80102099 <iunlock+0x23>
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	8b 40 0c             	mov    0xc(%eax),%eax
80102088:	83 e0 01             	and    $0x1,%eax
8010208b:	85 c0                	test   %eax,%eax
8010208d:	74 0a                	je     80102099 <iunlock+0x23>
8010208f:	8b 45 08             	mov    0x8(%ebp),%eax
80102092:	8b 40 08             	mov    0x8(%eax),%eax
80102095:	85 c0                	test   %eax,%eax
80102097:	7f 0d                	jg     801020a6 <iunlock+0x30>
        // cprintf("iunlock %d ",ip);
        panic("iunlock");
80102099:	83 ec 0c             	sub    $0xc,%esp
8010209c:	68 7c 95 10 80       	push   $0x8010957c
801020a1:	e8 c0 e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020a6:	83 ec 0c             	sub    $0xc,%esp
801020a9:	68 60 24 11 80       	push   $0x80112460
801020ae:	e8 bc 3a 00 00       	call   80105b6f <acquire>
801020b3:	83 c4 10             	add    $0x10,%esp
    ip->flags &= ~I_BUSY;
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 0c             	mov    0xc(%eax),%eax
801020bc:	83 e0 fe             	and    $0xfffffffe,%eax
801020bf:	89 c2                	mov    %eax,%edx
801020c1:	8b 45 08             	mov    0x8(%ebp),%eax
801020c4:	89 50 0c             	mov    %edx,0xc(%eax)
    wakeup(ip);
801020c7:	83 ec 0c             	sub    $0xc,%esp
801020ca:	ff 75 08             	pushl  0x8(%ebp)
801020cd:	e8 8f 38 00 00       	call   80105961 <wakeup>
801020d2:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020d5:	83 ec 0c             	sub    $0xc,%esp
801020d8:	68 60 24 11 80       	push   $0x80112460
801020dd:	e8 f4 3a 00 00       	call   80105bd6 <release>
801020e2:	83 c4 10             	add    $0x10,%esp
}
801020e5:	90                   	nop
801020e6:	c9                   	leave  
801020e7:	c3                   	ret    

801020e8 <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
801020e8:	55                   	push   %ebp
801020e9:	89 e5                	mov    %esp,%ebp
801020eb:	83 ec 08             	sub    $0x8,%esp
                       // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
801020ee:	83 ec 0c             	sub    $0xc,%esp
801020f1:	68 60 24 11 80       	push   $0x80112460
801020f6:	e8 74 3a 00 00       	call   80105b6f <acquire>
801020fb:	83 c4 10             	add    $0x10,%esp
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
801020fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102101:	8b 40 08             	mov    0x8(%eax),%eax
80102104:	83 f8 01             	cmp    $0x1,%eax
80102107:	0f 85 a9 00 00 00    	jne    801021b6 <iput+0xce>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	8b 40 0c             	mov    0xc(%eax),%eax
80102113:	83 e0 02             	and    $0x2,%eax
80102116:	85 c0                	test   %eax,%eax
80102118:	0f 84 98 00 00 00    	je     801021b6 <iput+0xce>
8010211e:	8b 45 08             	mov    0x8(%ebp),%eax
80102121:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102125:	66 85 c0             	test   %ax,%ax
80102128:	0f 85 88 00 00 00    	jne    801021b6 <iput+0xce>
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
8010212e:	8b 45 08             	mov    0x8(%ebp),%eax
80102131:	8b 40 0c             	mov    0xc(%eax),%eax
80102134:	83 e0 01             	and    $0x1,%eax
80102137:	85 c0                	test   %eax,%eax
80102139:	74 0d                	je     80102148 <iput+0x60>
            panic("iput busy");
8010213b:	83 ec 0c             	sub    $0xc,%esp
8010213e:	68 84 95 10 80       	push   $0x80109584
80102143:	e8 1e e4 ff ff       	call   80100566 <panic>
        ip->flags |= I_BUSY;
80102148:	8b 45 08             	mov    0x8(%ebp),%eax
8010214b:	8b 40 0c             	mov    0xc(%eax),%eax
8010214e:	83 c8 01             	or     $0x1,%eax
80102151:	89 c2                	mov    %eax,%edx
80102153:	8b 45 08             	mov    0x8(%ebp),%eax
80102156:	89 50 0c             	mov    %edx,0xc(%eax)
        release(&icache.lock);
80102159:	83 ec 0c             	sub    $0xc,%esp
8010215c:	68 60 24 11 80       	push   $0x80112460
80102161:	e8 70 3a 00 00       	call   80105bd6 <release>
80102166:	83 c4 10             	add    $0x10,%esp
        itrunc(ip);
80102169:	83 ec 0c             	sub    $0xc,%esp
8010216c:	ff 75 08             	pushl  0x8(%ebp)
8010216f:	e8 1c 02 00 00       	call   80102390 <itrunc>
80102174:	83 c4 10             	add    $0x10,%esp
        ip->type = 0;
80102177:	8b 45 08             	mov    0x8(%ebp),%eax
8010217a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
        iupdate(ip);
80102180:	83 ec 0c             	sub    $0xc,%esp
80102183:	ff 75 08             	pushl  0x8(%ebp)
80102186:	e8 ec fa ff ff       	call   80101c77 <iupdate>
8010218b:	83 c4 10             	add    $0x10,%esp
        acquire(&icache.lock);
8010218e:	83 ec 0c             	sub    $0xc,%esp
80102191:	68 60 24 11 80       	push   $0x80112460
80102196:	e8 d4 39 00 00       	call   80105b6f <acquire>
8010219b:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
8010219e:	8b 45 08             	mov    0x8(%ebp),%eax
801021a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021a8:	83 ec 0c             	sub    $0xc,%esp
801021ab:	ff 75 08             	pushl  0x8(%ebp)
801021ae:	e8 ae 37 00 00       	call   80105961 <wakeup>
801021b3:	83 c4 10             	add    $0x10,%esp
    }
    ip->ref--;
801021b6:	8b 45 08             	mov    0x8(%ebp),%eax
801021b9:	8b 40 08             	mov    0x8(%eax),%eax
801021bc:	8d 50 ff             	lea    -0x1(%eax),%edx
801021bf:	8b 45 08             	mov    0x8(%ebp),%eax
801021c2:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
801021c5:	83 ec 0c             	sub    $0xc,%esp
801021c8:	68 60 24 11 80       	push   $0x80112460
801021cd:	e8 04 3a 00 00       	call   80105bd6 <release>
801021d2:	83 c4 10             	add    $0x10,%esp
}
801021d5:	90                   	nop
801021d6:	c9                   	leave  
801021d7:	c3                   	ret    

801021d8 <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
801021d8:	55                   	push   %ebp
801021d9:	89 e5                	mov    %esp,%ebp
801021db:	83 ec 08             	sub    $0x8,%esp
    iunlock(ip);
801021de:	83 ec 0c             	sub    $0xc,%esp
801021e1:	ff 75 08             	pushl  0x8(%ebp)
801021e4:	e8 8d fe ff ff       	call   80102076 <iunlock>
801021e9:	83 c4 10             	add    $0x10,%esp
    iput(ip);
801021ec:	83 ec 0c             	sub    $0xc,%esp
801021ef:	ff 75 08             	pushl  0x8(%ebp)
801021f2:	e8 f1 fe ff ff       	call   801020e8 <iput>
801021f7:	83 c4 10             	add    $0x10,%esp
}
801021fa:	90                   	nop
801021fb:	c9                   	leave  
801021fc:	c3                   	ret    

801021fd <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
801021fd:	55                   	push   %ebp
801021fe:	89 e5                	mov    %esp,%ebp
80102200:	53                   	push   %ebx
80102201:	83 ec 34             	sub    $0x34,%esp
                       //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
struct superblock sb;
sb=sbs[ip->part->number];
80102204:	8b 45 08             	mov    0x8(%ebp),%eax
80102207:	8b 40 50             	mov    0x50(%eax),%eax
8010220a:	8b 40 14             	mov    0x14(%eax),%eax
8010220d:	c1 e0 05             	shl    $0x5,%eax
80102210:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102215:	8b 10                	mov    (%eax),%edx
80102217:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010221a:	8b 50 04             	mov    0x4(%eax),%edx
8010221d:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102220:	8b 50 08             	mov    0x8(%eax),%edx
80102223:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102226:	8b 50 0c             	mov    0xc(%eax),%edx
80102229:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010222c:	8b 50 10             	mov    0x10(%eax),%edx
8010222f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102232:	8b 50 14             	mov    0x14(%eax),%edx
80102235:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102238:	8b 50 18             	mov    0x18(%eax),%edx
8010223b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010223e:	8b 40 1c             	mov    0x1c(%eax),%eax
80102241:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (bn < NDIRECT) {
80102244:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102248:	77 4e                	ja     80102298 <bmap+0x9b>
        if ((addr = ip->addrs[bn]) == 0)
8010224a:	8b 45 08             	mov    0x8(%ebp),%eax
8010224d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102250:	83 c2 04             	add    $0x4,%edx
80102253:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102257:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010225a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010225e:	75 30                	jne    80102290 <bmap+0x93>
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
80102260:	8b 45 08             	mov    0x8(%ebp),%eax
80102263:	8b 40 50             	mov    0x50(%eax),%eax
80102266:	8b 40 14             	mov    0x14(%eax),%eax
80102269:	89 c2                	mov    %eax,%edx
8010226b:	8b 45 08             	mov    0x8(%ebp),%eax
8010226e:	8b 00                	mov    (%eax),%eax
80102270:	83 ec 08             	sub    $0x8,%esp
80102273:	52                   	push   %edx
80102274:	50                   	push   %eax
80102275:	e8 c9 f2 ff ff       	call   80101543 <balloc>
8010227a:	83 c4 10             	add    $0x10,%esp
8010227d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102280:	8b 45 08             	mov    0x8(%ebp),%eax
80102283:	8b 55 0c             	mov    0xc(%ebp),%edx
80102286:	8d 4a 04             	lea    0x4(%edx),%ecx
80102289:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010228c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
       // cprintf("addr %d \n ",addr);
        return addr;
80102290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102293:	e9 f3 00 00 00       	jmp    8010238b <bmap+0x18e>
    }
    bn -= NDIRECT;
80102298:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

    if (bn < NINDIRECT) {
8010229c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801022a0:	0f 87 d8 00 00 00    	ja     8010237e <bmap+0x181>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801022a6:	8b 45 08             	mov    0x8(%ebp),%eax
801022a9:	8b 40 4c             	mov    0x4c(%eax),%eax
801022ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022b3:	75 29                	jne    801022de <bmap+0xe1>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
801022b5:	8b 45 08             	mov    0x8(%ebp),%eax
801022b8:	8b 40 50             	mov    0x50(%eax),%eax
801022bb:	8b 40 14             	mov    0x14(%eax),%eax
801022be:	89 c2                	mov    %eax,%edx
801022c0:	8b 45 08             	mov    0x8(%ebp),%eax
801022c3:	8b 00                	mov    (%eax),%eax
801022c5:	83 ec 08             	sub    $0x8,%esp
801022c8:	52                   	push   %edx
801022c9:	50                   	push   %eax
801022ca:	e8 74 f2 ff ff       	call   80101543 <balloc>
801022cf:	83 c4 10             	add    $0x10,%esp
801022d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022d5:	8b 45 08             	mov    0x8(%ebp),%eax
801022d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022db:	89 50 4c             	mov    %edx,0x4c(%eax)
        bp = bread(ip->dev, sb.offset+addr);
801022de:	8b 55 e8             	mov    -0x18(%ebp),%edx
801022e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e4:	01 c2                	add    %eax,%edx
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	8b 00                	mov    (%eax),%eax
801022eb:	83 ec 08             	sub    $0x8,%esp
801022ee:	52                   	push   %edx
801022ef:	50                   	push   %eax
801022f0:	e8 c1 de ff ff       	call   801001b6 <bread>
801022f5:	83 c4 10             	add    $0x10,%esp
801022f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        a = (uint*)bp->data;
801022fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022fe:	83 c0 18             	add    $0x18,%eax
80102301:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if ((addr = a[bn]) == 0) {
80102304:	8b 45 0c             	mov    0xc(%ebp),%eax
80102307:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010230e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102311:	01 d0                	add    %edx,%eax
80102313:	8b 00                	mov    (%eax),%eax
80102315:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102318:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010231c:	75 4d                	jne    8010236b <bmap+0x16e>
            a[bn] = addr = balloc(ip->dev, ip->part->number);
8010231e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102321:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010232b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	8b 40 50             	mov    0x50(%eax),%eax
80102334:	8b 40 14             	mov    0x14(%eax),%eax
80102337:	89 c2                	mov    %eax,%edx
80102339:	8b 45 08             	mov    0x8(%ebp),%eax
8010233c:	8b 00                	mov    (%eax),%eax
8010233e:	83 ec 08             	sub    $0x8,%esp
80102341:	52                   	push   %edx
80102342:	50                   	push   %eax
80102343:	e8 fb f1 ff ff       	call   80101543 <balloc>
80102348:	83 c4 10             	add    $0x10,%esp
8010234b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010234e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102351:	89 03                	mov    %eax,(%ebx)
            log_write(bp,ip->part->number);
80102353:	8b 45 08             	mov    0x8(%ebp),%eax
80102356:	8b 40 50             	mov    0x50(%eax),%eax
80102359:	8b 40 14             	mov    0x14(%eax),%eax
8010235c:	83 ec 08             	sub    $0x8,%esp
8010235f:	50                   	push   %eax
80102360:	ff 75 f0             	pushl  -0x10(%ebp)
80102363:	e8 c0 1e 00 00       	call   80104228 <log_write>
80102368:	83 c4 10             	add    $0x10,%esp
        }
        brelse(bp);
8010236b:	83 ec 0c             	sub    $0xc,%esp
8010236e:	ff 75 f0             	pushl  -0x10(%ebp)
80102371:	e8 b8 de ff ff       	call   8010022e <brelse>
80102376:	83 c4 10             	add    $0x10,%esp
        return addr;
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	eb 0d                	jmp    8010238b <bmap+0x18e>
    }

    panic("bmap: out of range");
8010237e:	83 ec 0c             	sub    $0xc,%esp
80102381:	68 8e 95 10 80       	push   $0x8010958e
80102386:	e8 db e1 ff ff       	call   80100566 <panic>
}
8010238b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010238e:	c9                   	leave  
8010238f:	c3                   	ret    

80102390 <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
80102390:	55                   	push   %ebp
80102391:	89 e5                	mov    %esp,%ebp
80102393:	83 ec 38             	sub    $0x38,%esp

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
80102396:	8b 45 08             	mov    0x8(%ebp),%eax
80102399:	8b 40 50             	mov    0x50(%eax),%eax
8010239c:	8b 40 14             	mov    0x14(%eax),%eax
8010239f:	c1 e0 05             	shl    $0x5,%eax
801023a2:	05 60 d6 10 80       	add    $0x8010d660,%eax
801023a7:	8b 10                	mov    (%eax),%edx
801023a9:	89 55 c8             	mov    %edx,-0x38(%ebp)
801023ac:	8b 50 04             	mov    0x4(%eax),%edx
801023af:	89 55 cc             	mov    %edx,-0x34(%ebp)
801023b2:	8b 50 08             	mov    0x8(%eax),%edx
801023b5:	89 55 d0             	mov    %edx,-0x30(%ebp)
801023b8:	8b 50 0c             	mov    0xc(%eax),%edx
801023bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801023be:	8b 50 10             	mov    0x10(%eax),%edx
801023c1:	89 55 d8             	mov    %edx,-0x28(%ebp)
801023c4:	8b 50 14             	mov    0x14(%eax),%edx
801023c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
801023ca:	8b 50 18             	mov    0x18(%eax),%edx
801023cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
801023d0:	8b 40 1c             	mov    0x1c(%eax),%eax
801023d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < NDIRECT; i++) {
801023d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023dd:	eb 51                	jmp    80102430 <itrunc+0xa0>
        if (ip->addrs[i]) {
801023df:	8b 45 08             	mov    0x8(%ebp),%eax
801023e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e5:	83 c2 04             	add    $0x4,%edx
801023e8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801023ec:	85 c0                	test   %eax,%eax
801023ee:	74 3c                	je     8010242c <itrunc+0x9c>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	8b 40 50             	mov    0x50(%eax),%eax
801023f6:	8b 40 14             	mov    0x14(%eax),%eax
801023f9:	89 c1                	mov    %eax,%ecx
801023fb:	8b 45 08             	mov    0x8(%ebp),%eax
801023fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102401:	83 c2 04             	add    $0x4,%edx
80102404:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102408:	8b 55 08             	mov    0x8(%ebp),%edx
8010240b:	8b 12                	mov    (%edx),%edx
8010240d:	83 ec 04             	sub    $0x4,%esp
80102410:	51                   	push   %ecx
80102411:	50                   	push   %eax
80102412:	52                   	push   %edx
80102413:	e8 be f2 ff ff       	call   801016d6 <bfree>
80102418:	83 c4 10             	add    $0x10,%esp
            ip->addrs[i] = 0;
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102421:	83 c2 04             	add    $0x4,%edx
80102424:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010242b:	00 
    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
8010242c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102430:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102434:	7e a9                	jle    801023df <itrunc+0x4f>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
80102436:	8b 45 08             	mov    0x8(%ebp),%eax
80102439:	8b 40 4c             	mov    0x4c(%eax),%eax
8010243c:	85 c0                	test   %eax,%eax
8010243e:	0f 84 be 00 00 00    	je     80102502 <itrunc+0x172>
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
80102444:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102447:	8b 45 08             	mov    0x8(%ebp),%eax
8010244a:	8b 40 4c             	mov    0x4c(%eax),%eax
8010244d:	01 c2                	add    %eax,%edx
8010244f:	8b 45 08             	mov    0x8(%ebp),%eax
80102452:	8b 00                	mov    (%eax),%eax
80102454:	83 ec 08             	sub    $0x8,%esp
80102457:	52                   	push   %edx
80102458:	50                   	push   %eax
80102459:	e8 58 dd ff ff       	call   801001b6 <bread>
8010245e:	83 c4 10             	add    $0x10,%esp
80102461:	89 45 ec             	mov    %eax,-0x14(%ebp)
        a = (uint*)bp->data;
80102464:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102467:	83 c0 18             	add    $0x18,%eax
8010246a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        for (j = 0; j < NINDIRECT; j++) {
8010246d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102474:	eb 48                	jmp    801024be <itrunc+0x12e>
            if (a[j])
80102476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102479:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102480:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102483:	01 d0                	add    %edx,%eax
80102485:	8b 00                	mov    (%eax),%eax
80102487:	85 c0                	test   %eax,%eax
80102489:	74 2f                	je     801024ba <itrunc+0x12a>
                bfree(ip->dev, a[j], ip->part->number);
8010248b:	8b 45 08             	mov    0x8(%ebp),%eax
8010248e:	8b 40 50             	mov    0x50(%eax),%eax
80102491:	8b 40 14             	mov    0x14(%eax),%eax
80102494:	89 c1                	mov    %eax,%ecx
80102496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102499:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801024a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024a3:	01 d0                	add    %edx,%eax
801024a5:	8b 00                	mov    (%eax),%eax
801024a7:	8b 55 08             	mov    0x8(%ebp),%edx
801024aa:	8b 12                	mov    (%edx),%edx
801024ac:	83 ec 04             	sub    $0x4,%esp
801024af:	51                   	push   %ecx
801024b0:	50                   	push   %eax
801024b1:	52                   	push   %edx
801024b2:	e8 1f f2 ff ff       	call   801016d6 <bfree>
801024b7:	83 c4 10             	add    $0x10,%esp
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
801024ba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801024be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c1:	83 f8 7f             	cmp    $0x7f,%eax
801024c4:	76 b0                	jbe    80102476 <itrunc+0xe6>
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
801024c6:	83 ec 0c             	sub    $0xc,%esp
801024c9:	ff 75 ec             	pushl  -0x14(%ebp)
801024cc:	e8 5d dd ff ff       	call   8010022e <brelse>
801024d1:	83 c4 10             	add    $0x10,%esp
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
801024d4:	8b 45 08             	mov    0x8(%ebp),%eax
801024d7:	8b 40 50             	mov    0x50(%eax),%eax
801024da:	8b 40 14             	mov    0x14(%eax),%eax
801024dd:	89 c1                	mov    %eax,%ecx
801024df:	8b 45 08             	mov    0x8(%ebp),%eax
801024e2:	8b 40 4c             	mov    0x4c(%eax),%eax
801024e5:	8b 55 08             	mov    0x8(%ebp),%edx
801024e8:	8b 12                	mov    (%edx),%edx
801024ea:	83 ec 04             	sub    $0x4,%esp
801024ed:	51                   	push   %ecx
801024ee:	50                   	push   %eax
801024ef:	52                   	push   %edx
801024f0:	e8 e1 f1 ff ff       	call   801016d6 <bfree>
801024f5:	83 c4 10             	add    $0x10,%esp
        ip->addrs[NDIRECT] = 0;
801024f8:	8b 45 08             	mov    0x8(%ebp),%eax
801024fb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }

    ip->size = 0;
80102502:	8b 45 08             	mov    0x8(%ebp),%eax
80102505:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    iupdate(ip);
8010250c:	83 ec 0c             	sub    $0xc,%esp
8010250f:	ff 75 08             	pushl  0x8(%ebp)
80102512:	e8 60 f7 ff ff       	call   80101c77 <iupdate>
80102517:	83 c4 10             	add    $0x10,%esp
}
8010251a:	90                   	nop
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <stati>:

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
    st->dev = ip->dev;
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	8b 00                	mov    (%eax),%eax
80102525:	89 c2                	mov    %eax,%edx
80102527:	8b 45 0c             	mov    0xc(%ebp),%eax
8010252a:	89 50 04             	mov    %edx,0x4(%eax)
    st->ino = ip->inum;
8010252d:	8b 45 08             	mov    0x8(%ebp),%eax
80102530:	8b 50 04             	mov    0x4(%eax),%edx
80102533:	8b 45 0c             	mov    0xc(%ebp),%eax
80102536:	89 50 08             	mov    %edx,0x8(%eax)
    st->type = ip->type;
80102539:	8b 45 08             	mov    0x8(%ebp),%eax
8010253c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102540:	8b 45 0c             	mov    0xc(%ebp),%eax
80102543:	66 89 10             	mov    %dx,(%eax)
    st->nlink = ip->nlink;
80102546:	8b 45 08             	mov    0x8(%ebp),%eax
80102549:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010254d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102550:	66 89 50 0c          	mov    %dx,0xc(%eax)
    st->size = ip->size;
80102554:	8b 45 08             	mov    0x8(%ebp),%eax
80102557:	8b 50 18             	mov    0x18(%eax),%edx
8010255a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010255d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102560:	90                   	nop
80102561:	5d                   	pop    %ebp
80102562:	c3                   	ret    

80102563 <readi>:

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
80102563:	55                   	push   %ebp
80102564:	89 e5                	mov    %esp,%ebp
80102566:	83 ec 38             	sub    $0x38,%esp
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
                      //      cprintf("readi \n");
    sb=sbs[ip->part->number];
80102569:	8b 45 08             	mov    0x8(%ebp),%eax
8010256c:	8b 40 50             	mov    0x50(%eax),%eax
8010256f:	8b 40 14             	mov    0x14(%eax),%eax
80102572:	c1 e0 05             	shl    $0x5,%eax
80102575:	05 60 d6 10 80       	add    $0x8010d660,%eax
8010257a:	8b 10                	mov    (%eax),%edx
8010257c:	89 55 c8             	mov    %edx,-0x38(%ebp)
8010257f:	8b 50 04             	mov    0x4(%eax),%edx
80102582:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102585:	8b 50 08             	mov    0x8(%eax),%edx
80102588:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010258b:	8b 50 0c             	mov    0xc(%eax),%edx
8010258e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102591:	8b 50 10             	mov    0x10(%eax),%edx
80102594:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102597:	8b 50 14             	mov    0x14(%eax),%edx
8010259a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010259d:	8b 50 18             	mov    0x18(%eax),%edx
801025a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
801025a3:	8b 40 1c             	mov    0x1c(%eax),%eax
801025a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ip->type == T_DEV) {
801025a9:	8b 45 08             	mov    0x8(%ebp),%eax
801025ac:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025b0:	66 83 f8 03          	cmp    $0x3,%ax
801025b4:	75 5c                	jne    80102612 <readi+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801025b6:	8b 45 08             	mov    0x8(%ebp),%eax
801025b9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025bd:	66 85 c0             	test   %ax,%ax
801025c0:	78 20                	js     801025e2 <readi+0x7f>
801025c2:	8b 45 08             	mov    0x8(%ebp),%eax
801025c5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025c9:	66 83 f8 09          	cmp    $0x9,%ax
801025cd:	7f 13                	jg     801025e2 <readi+0x7f>
801025cf:	8b 45 08             	mov    0x8(%ebp),%eax
801025d2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025d6:	98                   	cwtl   
801025d7:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
801025de:	85 c0                	test   %eax,%eax
801025e0:	75 0a                	jne    801025ec <readi+0x89>
            return -1;
801025e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025e7:	e9 15 01 00 00       	jmp    80102701 <readi+0x19e>
        return devsw[ip->major].read(ip, dst, n);
801025ec:	8b 45 08             	mov    0x8(%ebp),%eax
801025ef:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025f3:	98                   	cwtl   
801025f4:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
801025fb:	8b 55 14             	mov    0x14(%ebp),%edx
801025fe:	83 ec 04             	sub    $0x4,%esp
80102601:	52                   	push   %edx
80102602:	ff 75 0c             	pushl  0xc(%ebp)
80102605:	ff 75 08             	pushl  0x8(%ebp)
80102608:	ff d0                	call   *%eax
8010260a:	83 c4 10             	add    $0x10,%esp
8010260d:	e9 ef 00 00 00       	jmp    80102701 <readi+0x19e>
    }

    if (off > ip->size || off + n < off)
80102612:	8b 45 08             	mov    0x8(%ebp),%eax
80102615:	8b 40 18             	mov    0x18(%eax),%eax
80102618:	3b 45 10             	cmp    0x10(%ebp),%eax
8010261b:	72 0d                	jb     8010262a <readi+0xc7>
8010261d:	8b 55 10             	mov    0x10(%ebp),%edx
80102620:	8b 45 14             	mov    0x14(%ebp),%eax
80102623:	01 d0                	add    %edx,%eax
80102625:	3b 45 10             	cmp    0x10(%ebp),%eax
80102628:	73 0a                	jae    80102634 <readi+0xd1>
        return -1;
8010262a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010262f:	e9 cd 00 00 00       	jmp    80102701 <readi+0x19e>
    if (off + n > ip->size)
80102634:	8b 55 10             	mov    0x10(%ebp),%edx
80102637:	8b 45 14             	mov    0x14(%ebp),%eax
8010263a:	01 c2                	add    %eax,%edx
8010263c:	8b 45 08             	mov    0x8(%ebp),%eax
8010263f:	8b 40 18             	mov    0x18(%eax),%eax
80102642:	39 c2                	cmp    %eax,%edx
80102644:	76 0c                	jbe    80102652 <readi+0xef>
        n = ip->size - off;
80102646:	8b 45 08             	mov    0x8(%ebp),%eax
80102649:	8b 40 18             	mov    0x18(%eax),%eax
8010264c:	2b 45 10             	sub    0x10(%ebp),%eax
8010264f:	89 45 14             	mov    %eax,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102659:	e9 94 00 00 00       	jmp    801026f2 <readi+0x18f>
        uint bmapOut=bmap(ip, off / BSIZE);
8010265e:	8b 45 10             	mov    0x10(%ebp),%eax
80102661:	c1 e8 09             	shr    $0x9,%eax
80102664:	83 ec 08             	sub    $0x8,%esp
80102667:	50                   	push   %eax
80102668:	ff 75 08             	pushl  0x8(%ebp)
8010266b:	e8 8d fb ff ff       	call   801021fd <bmap>
80102670:	83 c4 10             	add    $0x10,%esp
80102673:	89 45 f0             	mov    %eax,-0x10(%ebp)
       // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset+bmapOut);
80102676:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010267c:	01 c2                	add    %eax,%edx
8010267e:	8b 45 08             	mov    0x8(%ebp),%eax
80102681:	8b 00                	mov    (%eax),%eax
80102683:	83 ec 08             	sub    $0x8,%esp
80102686:	52                   	push   %edx
80102687:	50                   	push   %eax
80102688:	e8 29 db ff ff       	call   801001b6 <bread>
8010268d:	83 c4 10             	add    $0x10,%esp
80102690:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
80102693:	8b 45 10             	mov    0x10(%ebp),%eax
80102696:	25 ff 01 00 00       	and    $0x1ff,%eax
8010269b:	ba 00 02 00 00       	mov    $0x200,%edx
801026a0:	29 c2                	sub    %eax,%edx
801026a2:	8b 45 14             	mov    0x14(%ebp),%eax
801026a5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801026a8:	39 c2                	cmp    %eax,%edx
801026aa:	0f 46 c2             	cmovbe %edx,%eax
801026ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(dst, bp->data + off % BSIZE, m);
801026b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026b3:	8d 50 18             	lea    0x18(%eax),%edx
801026b6:	8b 45 10             	mov    0x10(%ebp),%eax
801026b9:	25 ff 01 00 00       	and    $0x1ff,%eax
801026be:	01 d0                	add    %edx,%eax
801026c0:	83 ec 04             	sub    $0x4,%esp
801026c3:	ff 75 e8             	pushl  -0x18(%ebp)
801026c6:	50                   	push   %eax
801026c7:	ff 75 0c             	pushl  0xc(%ebp)
801026ca:	e8 c2 37 00 00       	call   80105e91 <memmove>
801026cf:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801026d2:	83 ec 0c             	sub    $0xc,%esp
801026d5:	ff 75 ec             	pushl  -0x14(%ebp)
801026d8:	e8 51 db ff ff       	call   8010022e <brelse>
801026dd:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
801026e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026e3:	01 45 f4             	add    %eax,-0xc(%ebp)
801026e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026e9:	01 45 10             	add    %eax,0x10(%ebp)
801026ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026ef:	01 45 0c             	add    %eax,0xc(%ebp)
801026f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f5:	3b 45 14             	cmp    0x14(%ebp),%eax
801026f8:	0f 82 60 ff ff ff    	jb     8010265e <readi+0xfb>
        bp = bread(ip->dev, sb.offset+bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
801026fe:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102701:	c9                   	leave  
80102702:	c3                   	ret    

80102703 <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
80102703:	55                   	push   %ebp
80102704:	89 e5                	mov    %esp,%ebp
80102706:	83 ec 38             	sub    $0x38,%esp
                               // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
        sb=sbs[ip->part->number];
80102709:	8b 45 08             	mov    0x8(%ebp),%eax
8010270c:	8b 40 50             	mov    0x50(%eax),%eax
8010270f:	8b 40 14             	mov    0x14(%eax),%eax
80102712:	c1 e0 05             	shl    $0x5,%eax
80102715:	05 60 d6 10 80       	add    $0x8010d660,%eax
8010271a:	8b 10                	mov    (%eax),%edx
8010271c:	89 55 c8             	mov    %edx,-0x38(%ebp)
8010271f:	8b 50 04             	mov    0x4(%eax),%edx
80102722:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102725:	8b 50 08             	mov    0x8(%eax),%edx
80102728:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010272b:	8b 50 0c             	mov    0xc(%eax),%edx
8010272e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102731:	8b 50 10             	mov    0x10(%eax),%edx
80102734:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102737:	8b 50 14             	mov    0x14(%eax),%edx
8010273a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010273d:	8b 50 18             	mov    0x18(%eax),%edx
80102740:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102743:	8b 40 1c             	mov    0x1c(%eax),%eax
80102746:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    if (ip->type == T_DEV) {
80102749:	8b 45 08             	mov    0x8(%ebp),%eax
8010274c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102750:	66 83 f8 03          	cmp    $0x3,%ax
80102754:	75 5c                	jne    801027b2 <writei+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102756:	8b 45 08             	mov    0x8(%ebp),%eax
80102759:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010275d:	66 85 c0             	test   %ax,%ax
80102760:	78 20                	js     80102782 <writei+0x7f>
80102762:	8b 45 08             	mov    0x8(%ebp),%eax
80102765:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102769:	66 83 f8 09          	cmp    $0x9,%ax
8010276d:	7f 13                	jg     80102782 <writei+0x7f>
8010276f:	8b 45 08             	mov    0x8(%ebp),%eax
80102772:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102776:	98                   	cwtl   
80102777:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010277e:	85 c0                	test   %eax,%eax
80102780:	75 0a                	jne    8010278c <writei+0x89>
            return -1;
80102782:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102787:	e9 50 01 00 00       	jmp    801028dc <writei+0x1d9>
        return devsw[ip->major].write(ip, src, n);
8010278c:	8b 45 08             	mov    0x8(%ebp),%eax
8010278f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102793:	98                   	cwtl   
80102794:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010279b:	8b 55 14             	mov    0x14(%ebp),%edx
8010279e:	83 ec 04             	sub    $0x4,%esp
801027a1:	52                   	push   %edx
801027a2:	ff 75 0c             	pushl  0xc(%ebp)
801027a5:	ff 75 08             	pushl  0x8(%ebp)
801027a8:	ff d0                	call   *%eax
801027aa:	83 c4 10             	add    $0x10,%esp
801027ad:	e9 2a 01 00 00       	jmp    801028dc <writei+0x1d9>
    }

    if (off > ip->size || off + n < off)
801027b2:	8b 45 08             	mov    0x8(%ebp),%eax
801027b5:	8b 40 18             	mov    0x18(%eax),%eax
801027b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801027bb:	72 0d                	jb     801027ca <writei+0xc7>
801027bd:	8b 55 10             	mov    0x10(%ebp),%edx
801027c0:	8b 45 14             	mov    0x14(%ebp),%eax
801027c3:	01 d0                	add    %edx,%eax
801027c5:	3b 45 10             	cmp    0x10(%ebp),%eax
801027c8:	73 0a                	jae    801027d4 <writei+0xd1>
        return -1;
801027ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027cf:	e9 08 01 00 00       	jmp    801028dc <writei+0x1d9>
    if (off + n > MAXFILE * BSIZE)
801027d4:	8b 55 10             	mov    0x10(%ebp),%edx
801027d7:	8b 45 14             	mov    0x14(%ebp),%eax
801027da:	01 d0                	add    %edx,%eax
801027dc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801027e1:	76 0a                	jbe    801027ed <writei+0xea>
        return -1;
801027e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027e8:	e9 ef 00 00 00       	jmp    801028dc <writei+0x1d9>

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801027ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027f4:	e9 ac 00 00 00       	jmp    801028a5 <writei+0x1a2>
        uint bmapOut=bmap(ip, off / BSIZE);
801027f9:	8b 45 10             	mov    0x10(%ebp),%eax
801027fc:	c1 e8 09             	shr    $0x9,%eax
801027ff:	83 ec 08             	sub    $0x8,%esp
80102802:	50                   	push   %eax
80102803:	ff 75 08             	pushl  0x8(%ebp)
80102806:	e8 f2 f9 ff ff       	call   801021fd <bmap>
8010280b:	83 c4 10             	add    $0x10,%esp
8010280e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        bp = bread(ip->dev, sb.offset+bmapOut);
80102811:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102817:	01 c2                	add    %eax,%edx
80102819:	8b 45 08             	mov    0x8(%ebp),%eax
8010281c:	8b 00                	mov    (%eax),%eax
8010281e:	83 ec 08             	sub    $0x8,%esp
80102821:	52                   	push   %edx
80102822:	50                   	push   %eax
80102823:	e8 8e d9 ff ff       	call   801001b6 <bread>
80102828:	83 c4 10             	add    $0x10,%esp
8010282b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
8010282e:	8b 45 10             	mov    0x10(%ebp),%eax
80102831:	25 ff 01 00 00       	and    $0x1ff,%eax
80102836:	ba 00 02 00 00       	mov    $0x200,%edx
8010283b:	29 c2                	sub    %eax,%edx
8010283d:	8b 45 14             	mov    0x14(%ebp),%eax
80102840:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102843:	39 c2                	cmp    %eax,%edx
80102845:	0f 46 c2             	cmovbe %edx,%eax
80102848:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(bp->data + off % BSIZE, src, m);
8010284b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010284e:	8d 50 18             	lea    0x18(%eax),%edx
80102851:	8b 45 10             	mov    0x10(%ebp),%eax
80102854:	25 ff 01 00 00       	and    $0x1ff,%eax
80102859:	01 d0                	add    %edx,%eax
8010285b:	83 ec 04             	sub    $0x4,%esp
8010285e:	ff 75 e8             	pushl  -0x18(%ebp)
80102861:	ff 75 0c             	pushl  0xc(%ebp)
80102864:	50                   	push   %eax
80102865:	e8 27 36 00 00       	call   80105e91 <memmove>
8010286a:	83 c4 10             	add    $0x10,%esp
        log_write(bp,ip->part->number);
8010286d:	8b 45 08             	mov    0x8(%ebp),%eax
80102870:	8b 40 50             	mov    0x50(%eax),%eax
80102873:	8b 40 14             	mov    0x14(%eax),%eax
80102876:	83 ec 08             	sub    $0x8,%esp
80102879:	50                   	push   %eax
8010287a:	ff 75 ec             	pushl  -0x14(%ebp)
8010287d:	e8 a6 19 00 00       	call   80104228 <log_write>
80102882:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80102885:	83 ec 0c             	sub    $0xc,%esp
80102888:	ff 75 ec             	pushl  -0x14(%ebp)
8010288b:	e8 9e d9 ff ff       	call   8010022e <brelse>
80102890:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
80102893:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102896:	01 45 f4             	add    %eax,-0xc(%ebp)
80102899:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010289c:	01 45 10             	add    %eax,0x10(%ebp)
8010289f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028a2:	01 45 0c             	add    %eax,0xc(%ebp)
801028a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a8:	3b 45 14             	cmp    0x14(%ebp),%eax
801028ab:	0f 82 48 ff ff ff    	jb     801027f9 <writei+0xf6>
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp,ip->part->number);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
801028b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801028b5:	74 22                	je     801028d9 <writei+0x1d6>
801028b7:	8b 45 08             	mov    0x8(%ebp),%eax
801028ba:	8b 40 18             	mov    0x18(%eax),%eax
801028bd:	3b 45 10             	cmp    0x10(%ebp),%eax
801028c0:	73 17                	jae    801028d9 <writei+0x1d6>
        ip->size = off;
801028c2:	8b 45 08             	mov    0x8(%ebp),%eax
801028c5:	8b 55 10             	mov    0x10(%ebp),%edx
801028c8:	89 50 18             	mov    %edx,0x18(%eax)
        iupdate(ip);
801028cb:	83 ec 0c             	sub    $0xc,%esp
801028ce:	ff 75 08             	pushl  0x8(%ebp)
801028d1:	e8 a1 f3 ff ff       	call   80101c77 <iupdate>
801028d6:	83 c4 10             	add    $0x10,%esp
    }
    return n;
801028d9:	8b 45 14             	mov    0x14(%ebp),%eax
}
801028dc:	c9                   	leave  
801028dd:	c3                   	ret    

801028de <namecmp>:

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
801028de:	55                   	push   %ebp
801028df:	89 e5                	mov    %esp,%ebp
801028e1:	83 ec 08             	sub    $0x8,%esp
    return strncmp(s, t, DIRSIZ);
801028e4:	83 ec 04             	sub    $0x4,%esp
801028e7:	6a 0e                	push   $0xe
801028e9:	ff 75 0c             	pushl  0xc(%ebp)
801028ec:	ff 75 08             	pushl  0x8(%ebp)
801028ef:	e8 33 36 00 00       	call   80105f27 <strncmp>
801028f4:	83 c4 10             	add    $0x10,%esp
}
801028f7:	c9                   	leave  
801028f8:	c3                   	ret    

801028f9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
801028f9:	55                   	push   %ebp
801028fa:	89 e5                	mov    %esp,%ebp
801028fc:	83 ec 28             	sub    $0x28,%esp
                             //       cprintf("dirlookup \n");

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
801028ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102902:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102906:	66 83 f8 01          	cmp    $0x1,%ax
8010290a:	74 0d                	je     80102919 <dirlookup+0x20>
        panic("dirlookup not DIR");
8010290c:	83 ec 0c             	sub    $0xc,%esp
8010290f:	68 a1 95 10 80       	push   $0x801095a1
80102914:	e8 4d dc ff ff       	call   80100566 <panic>

    for (off = 0; off < dp->size; off += sizeof(de)) {
80102919:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102920:	e9 85 00 00 00       	jmp    801029aa <dirlookup+0xb1>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102925:	6a 10                	push   $0x10
80102927:	ff 75 f4             	pushl  -0xc(%ebp)
8010292a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010292d:	50                   	push   %eax
8010292e:	ff 75 08             	pushl  0x8(%ebp)
80102931:	e8 2d fc ff ff       	call   80102563 <readi>
80102936:	83 c4 10             	add    $0x10,%esp
80102939:	83 f8 10             	cmp    $0x10,%eax
8010293c:	74 0d                	je     8010294b <dirlookup+0x52>
            panic("dirlink read");
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 b3 95 10 80       	push   $0x801095b3
80102946:	e8 1b dc ff ff       	call   80100566 <panic>
        if (de.inum == 0)
8010294b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010294f:	66 85 c0             	test   %ax,%ax
80102952:	74 51                	je     801029a5 <dirlookup+0xac>
            continue;
        if (namecmp(name, de.name) == 0) {
80102954:	83 ec 08             	sub    $0x8,%esp
80102957:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010295a:	83 c0 02             	add    $0x2,%eax
8010295d:	50                   	push   %eax
8010295e:	ff 75 0c             	pushl  0xc(%ebp)
80102961:	e8 78 ff ff ff       	call   801028de <namecmp>
80102966:	83 c4 10             	add    $0x10,%esp
80102969:	85 c0                	test   %eax,%eax
8010296b:	75 39                	jne    801029a6 <dirlookup+0xad>
            // entry matches path element
            if (poff)
8010296d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102971:	74 08                	je     8010297b <dirlookup+0x82>
                *poff = off;
80102973:	8b 45 10             	mov    0x10(%ebp),%eax
80102976:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102979:	89 10                	mov    %edx,(%eax)
            inum = de.inum;
8010297b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010297f:	0f b7 c0             	movzwl %ax,%eax
80102982:	89 45 f0             	mov    %eax,-0x10(%ebp)
            return iget(dp->dev, inum, dp->part->number);
80102985:	8b 45 08             	mov    0x8(%ebp),%eax
80102988:	8b 40 50             	mov    0x50(%eax),%eax
8010298b:	8b 50 14             	mov    0x14(%eax),%edx
8010298e:	8b 45 08             	mov    0x8(%ebp),%eax
80102991:	8b 00                	mov    (%eax),%eax
80102993:	83 ec 04             	sub    $0x4,%esp
80102996:	52                   	push   %edx
80102997:	ff 75 f0             	pushl  -0x10(%ebp)
8010299a:	50                   	push   %eax
8010299b:	e8 e5 f3 ff ff       	call   80101d85 <iget>
801029a0:	83 c4 10             	add    $0x10,%esp
801029a3:	eb 19                	jmp    801029be <dirlookup+0xc5>

    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            continue;
801029a5:	90                   	nop
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801029a6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801029aa:	8b 45 08             	mov    0x8(%ebp),%eax
801029ad:	8b 40 18             	mov    0x18(%eax),%eax
801029b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801029b3:	0f 87 6c ff ff ff    	ja     80102925 <dirlookup+0x2c>
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
801029b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029be:	c9                   	leave  
801029bf:	c3                   	ret    

801029c0 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
801029c0:	55                   	push   %ebp
801029c1:	89 e5                	mov    %esp,%ebp
801029c3:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
801029c6:	83 ec 04             	sub    $0x4,%esp
801029c9:	6a 00                	push   $0x0
801029cb:	ff 75 0c             	pushl  0xc(%ebp)
801029ce:	ff 75 08             	pushl  0x8(%ebp)
801029d1:	e8 23 ff ff ff       	call   801028f9 <dirlookup>
801029d6:	83 c4 10             	add    $0x10,%esp
801029d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801029dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801029e0:	74 18                	je     801029fa <dirlink+0x3a>
        iput(ip);
801029e2:	83 ec 0c             	sub    $0xc,%esp
801029e5:	ff 75 f0             	pushl  -0x10(%ebp)
801029e8:	e8 fb f6 ff ff       	call   801020e8 <iput>
801029ed:	83 c4 10             	add    $0x10,%esp
        return -1;
801029f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029f5:	e9 9c 00 00 00       	jmp    80102a96 <dirlink+0xd6>
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
801029fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a01:	eb 39                	jmp    80102a3c <dirlink+0x7c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a06:	6a 10                	push   $0x10
80102a08:	50                   	push   %eax
80102a09:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a0c:	50                   	push   %eax
80102a0d:	ff 75 08             	pushl  0x8(%ebp)
80102a10:	e8 4e fb ff ff       	call   80102563 <readi>
80102a15:	83 c4 10             	add    $0x10,%esp
80102a18:	83 f8 10             	cmp    $0x10,%eax
80102a1b:	74 0d                	je     80102a2a <dirlink+0x6a>
            panic("dirlink read");
80102a1d:	83 ec 0c             	sub    $0xc,%esp
80102a20:	68 b3 95 10 80       	push   $0x801095b3
80102a25:	e8 3c db ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102a2a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102a2e:	66 85 c0             	test   %ax,%ax
80102a31:	74 18                	je     80102a4b <dirlink+0x8b>
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a36:	83 c0 10             	add    $0x10,%eax
80102a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3f:	8b 50 18             	mov    0x18(%eax),%edx
80102a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a45:	39 c2                	cmp    %eax,%edx
80102a47:	77 ba                	ja     80102a03 <dirlink+0x43>
80102a49:	eb 01                	jmp    80102a4c <dirlink+0x8c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            break;
80102a4b:	90                   	nop
    }

    strncpy(de.name, name, DIRSIZ);
80102a4c:	83 ec 04             	sub    $0x4,%esp
80102a4f:	6a 0e                	push   $0xe
80102a51:	ff 75 0c             	pushl  0xc(%ebp)
80102a54:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a57:	83 c0 02             	add    $0x2,%eax
80102a5a:	50                   	push   %eax
80102a5b:	e8 1d 35 00 00       	call   80105f7d <strncpy>
80102a60:	83 c4 10             	add    $0x10,%esp
    de.inum = inum;
80102a63:	8b 45 10             	mov    0x10(%ebp),%eax
80102a66:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6d:	6a 10                	push   $0x10
80102a6f:	50                   	push   %eax
80102a70:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a73:	50                   	push   %eax
80102a74:	ff 75 08             	pushl  0x8(%ebp)
80102a77:	e8 87 fc ff ff       	call   80102703 <writei>
80102a7c:	83 c4 10             	add    $0x10,%esp
80102a7f:	83 f8 10             	cmp    $0x10,%eax
80102a82:	74 0d                	je     80102a91 <dirlink+0xd1>
        panic("dirlink");
80102a84:	83 ec 0c             	sub    $0xc,%esp
80102a87:	68 c0 95 10 80       	push   $0x801095c0
80102a8c:	e8 d5 da ff ff       	call   80100566 <panic>

    return 0;
80102a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a96:	c9                   	leave  
80102a97:	c3                   	ret    

80102a98 <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
80102a98:	55                   	push   %ebp
80102a99:	89 e5                	mov    %esp,%ebp
80102a9b:	83 ec 18             	sub    $0x18,%esp
    
    char* s;
    int len;

    while (*path == '/')
80102a9e:	eb 04                	jmp    80102aa4 <skipelem+0xc>
        path++;
80102aa0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
    
    char* s;
    int len;

    while (*path == '/')
80102aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa7:	0f b6 00             	movzbl (%eax),%eax
80102aaa:	3c 2f                	cmp    $0x2f,%al
80102aac:	74 f2                	je     80102aa0 <skipelem+0x8>
        path++;
    if (*path == 0)
80102aae:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab1:	0f b6 00             	movzbl (%eax),%eax
80102ab4:	84 c0                	test   %al,%al
80102ab6:	75 07                	jne    80102abf <skipelem+0x27>
        return 0;
80102ab8:	b8 00 00 00 00       	mov    $0x0,%eax
80102abd:	eb 7b                	jmp    80102b3a <skipelem+0xa2>
    s = path;
80102abf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (*path != '/' && *path != 0)
80102ac5:	eb 04                	jmp    80102acb <skipelem+0x33>
        path++;
80102ac7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
80102acb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ace:	0f b6 00             	movzbl (%eax),%eax
80102ad1:	3c 2f                	cmp    $0x2f,%al
80102ad3:	74 0a                	je     80102adf <skipelem+0x47>
80102ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad8:	0f b6 00             	movzbl (%eax),%eax
80102adb:	84 c0                	test   %al,%al
80102add:	75 e8                	jne    80102ac7 <skipelem+0x2f>
        path++;
    len = path - s;
80102adf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae5:	29 c2                	sub    %eax,%edx
80102ae7:	89 d0                	mov    %edx,%eax
80102ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (len >= DIRSIZ)
80102aec:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102af0:	7e 15                	jle    80102b07 <skipelem+0x6f>
        memmove(name, s, DIRSIZ);
80102af2:	83 ec 04             	sub    $0x4,%esp
80102af5:	6a 0e                	push   $0xe
80102af7:	ff 75 f4             	pushl  -0xc(%ebp)
80102afa:	ff 75 0c             	pushl  0xc(%ebp)
80102afd:	e8 8f 33 00 00       	call   80105e91 <memmove>
80102b02:	83 c4 10             	add    $0x10,%esp
80102b05:	eb 26                	jmp    80102b2d <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b0a:	83 ec 04             	sub    $0x4,%esp
80102b0d:	50                   	push   %eax
80102b0e:	ff 75 f4             	pushl  -0xc(%ebp)
80102b11:	ff 75 0c             	pushl  0xc(%ebp)
80102b14:	e8 78 33 00 00       	call   80105e91 <memmove>
80102b19:	83 c4 10             	add    $0x10,%esp
        name[len] = 0;
80102b1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b22:	01 d0                	add    %edx,%eax
80102b24:	c6 00 00             	movb   $0x0,(%eax)
    }
    while (*path == '/')
80102b27:	eb 04                	jmp    80102b2d <skipelem+0x95>
        path++;
80102b29:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b30:	0f b6 00             	movzbl (%eax),%eax
80102b33:	3c 2f                	cmp    $0x2f,%al
80102b35:	74 f2                	je     80102b29 <skipelem+0x91>
        path++;
    return path;
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102b3a:	c9                   	leave  
80102b3b:	c3                   	ret    

80102b3c <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, int ignoreMounts,char* name)
{
80102b3c:	55                   	push   %ebp
80102b3d:	89 e5                	mov    %esp,%ebp
80102b3f:	83 ec 18             	sub    $0x18,%esp
                                           // cprintf("namex \n");

    struct inode* ip, *next;
     // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
80102b42:	8b 45 08             	mov    0x8(%ebp),%eax
80102b45:	0f b6 00             	movzbl (%eax),%eax
80102b48:	3c 2f                	cmp    $0x2f,%al
80102b4a:	75 1d                	jne    80102b69 <namex+0x2d>
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
80102b4c:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80102b51:	83 ec 04             	sub    $0x4,%esp
80102b54:	50                   	push   %eax
80102b55:	6a 01                	push   $0x1
80102b57:	6a 00                	push   $0x0
80102b59:	e8 27 f2 ff ff       	call   80101d85 <iget>
80102b5e:	83 c4 10             	add    $0x10,%esp
80102b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b64:	e9 3f 01 00 00       	jmp    80102ca8 <namex+0x16c>
    else
        ip = idup(proc->cwd);
80102b69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102b6f:	8b 40 68             	mov    0x68(%eax),%eax
80102b72:	83 ec 0c             	sub    $0xc,%esp
80102b75:	50                   	push   %eax
80102b76:	e8 20 f3 ff ff       	call   80101e9b <idup>
80102b7b:	83 c4 10             	add    $0x10,%esp
80102b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while ((path = skipelem(path, name)) != 0) {
80102b81:	e9 22 01 00 00       	jmp    80102ca8 <namex+0x16c>
      //  cprintf("namex inode %d,part number %d \n",ip->inum,ip->part->number);
        ilock(ip);
80102b86:	83 ec 0c             	sub    $0xc,%esp
80102b89:	ff 75 f4             	pushl  -0xc(%ebp)
80102b8c:	e8 44 f3 ff ff       	call   80101ed5 <ilock>
80102b91:	83 c4 10             	add    $0x10,%esp
        if (ip->type != T_DIR) {
80102b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b97:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102b9b:	66 83 f8 01          	cmp    $0x1,%ax
80102b9f:	74 18                	je     80102bb9 <namex+0x7d>
            iunlockput(ip);
80102ba1:	83 ec 0c             	sub    $0xc,%esp
80102ba4:	ff 75 f4             	pushl  -0xc(%ebp)
80102ba7:	e8 2c f6 ff ff       	call   801021d8 <iunlockput>
80102bac:	83 c4 10             	add    $0x10,%esp
            return 0;
80102baf:	b8 00 00 00 00       	mov    $0x0,%eax
80102bb4:	e9 2b 01 00 00       	jmp    80102ce4 <namex+0x1a8>
        }
        if (nameiparent && *path == '\0') {
80102bb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bbd:	74 20                	je     80102bdf <namex+0xa3>
80102bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc2:	0f b6 00             	movzbl (%eax),%eax
80102bc5:	84 c0                	test   %al,%al
80102bc7:	75 16                	jne    80102bdf <namex+0xa3>
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
80102bc9:	83 ec 0c             	sub    $0xc,%esp
80102bcc:	ff 75 f4             	pushl  -0xc(%ebp)
80102bcf:	e8 a2 f4 ff ff       	call   80102076 <iunlock>
80102bd4:	83 c4 10             	add    $0x10,%esp
            return ip;
80102bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bda:	e9 05 01 00 00       	jmp    80102ce4 <namex+0x1a8>
        }
        if ((next = dirlookup(ip, name, 0)) == 0) {
80102bdf:	83 ec 04             	sub    $0x4,%esp
80102be2:	6a 00                	push   $0x0
80102be4:	ff 75 14             	pushl  0x14(%ebp)
80102be7:	ff 75 f4             	pushl  -0xc(%ebp)
80102bea:	e8 0a fd ff ff       	call   801028f9 <dirlookup>
80102bef:	83 c4 10             	add    $0x10,%esp
80102bf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102bf5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102bf9:	75 18                	jne    80102c13 <namex+0xd7>
            iunlockput(ip);
80102bfb:	83 ec 0c             	sub    $0xc,%esp
80102bfe:	ff 75 f4             	pushl  -0xc(%ebp)
80102c01:	e8 d2 f5 ff ff       	call   801021d8 <iunlockput>
80102c06:	83 c4 10             	add    $0x10,%esp
            return 0;
80102c09:	b8 00 00 00 00       	mov    $0x0,%eax
80102c0e:	e9 d1 00 00 00       	jmp    80102ce4 <namex+0x1a8>
        }
        iunlockput(ip);
80102c13:	83 ec 0c             	sub    $0xc,%esp
80102c16:	ff 75 f4             	pushl  -0xc(%ebp)
80102c19:	e8 ba f5 ff ff       	call   801021d8 <iunlockput>
80102c1e:	83 c4 10             	add    $0x10,%esp
        //testing 
        if(!ignoreMounts&&next->type==T_DIR&&next->major!=0 && next->major!=MOUNTING_POINT){
80102c21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c25:	75 36                	jne    80102c5d <namex+0x121>
80102c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c2a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c2e:	66 83 f8 01          	cmp    $0x1,%ax
80102c32:	75 29                	jne    80102c5d <namex+0x121>
80102c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c37:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c3b:	66 85 c0             	test   %ax,%ax
80102c3e:	74 1d                	je     80102c5d <namex+0x121>
80102c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c43:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c47:	66 83 f8 01          	cmp    $0x1,%ax
80102c4b:	74 10                	je     80102c5d <namex+0x121>
            cprintf("major used ,we are fucked \n");
80102c4d:	83 ec 0c             	sub    $0xc,%esp
80102c50:	68 c8 95 10 80       	push   $0x801095c8
80102c55:	e8 6c d7 ff ff       	call   801003c6 <cprintf>
80102c5a:	83 c4 10             	add    $0x10,%esp
        }
        //handle mounting points
        if(!ignoreMounts&&!nameiparent&&next->type==T_DIR&&next->major==MOUNTING_POINT){
80102c5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c61:	75 3f                	jne    80102ca2 <namex+0x166>
80102c63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c67:	75 39                	jne    80102ca2 <namex+0x166>
80102c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c6c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c70:	66 83 f8 01          	cmp    $0x1,%ax
80102c74:	75 2c                	jne    80102ca2 <namex+0x166>
80102c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c79:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c7d:	66 83 f8 01          	cmp    $0x1,%ax
80102c81:	75 1f                	jne    80102ca2 <namex+0x166>
            
            
            uint partitionNumnber=next->minor;
80102c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c86:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80102c8a:	98                   	cwtl   
80102c8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
            return iget(ROOTDEV,1,partitionNumnber);
80102c8e:	83 ec 04             	sub    $0x4,%esp
80102c91:	ff 75 ec             	pushl  -0x14(%ebp)
80102c94:	6a 01                	push   $0x1
80102c96:	6a 00                	push   $0x0
80102c98:	e8 e8 f0 ff ff       	call   80101d85 <iget>
80102c9d:	83 c4 10             	add    $0x10,%esp
80102ca0:	eb 42                	jmp    80102ce4 <namex+0x1a8>
        }
        ip = next;
80102ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102ca8:	83 ec 08             	sub    $0x8,%esp
80102cab:	ff 75 14             	pushl  0x14(%ebp)
80102cae:	ff 75 08             	pushl  0x8(%ebp)
80102cb1:	e8 e2 fd ff ff       	call   80102a98 <skipelem>
80102cb6:	83 c4 10             	add    $0x10,%esp
80102cb9:	89 45 08             	mov    %eax,0x8(%ebp)
80102cbc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cc0:	0f 85 c0 fe ff ff    	jne    80102b86 <namex+0x4a>
            uint partitionNumnber=next->minor;
            return iget(ROOTDEV,1,partitionNumnber);
        }
        ip = next;
    }
    if (nameiparent) {
80102cc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102cca:	74 15                	je     80102ce1 <namex+0x1a5>
        iput(ip);
80102ccc:	83 ec 0c             	sub    $0xc,%esp
80102ccf:	ff 75 f4             	pushl  -0xc(%ebp)
80102cd2:	e8 11 f4 ff ff       	call   801020e8 <iput>
80102cd7:	83 c4 10             	add    $0x10,%esp
        return 0;
80102cda:	b8 00 00 00 00       	mov    $0x0,%eax
80102cdf:	eb 03                	jmp    80102ce4 <namex+0x1a8>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce4:	c9                   	leave  
80102ce5:	c3                   	ret    

80102ce6 <namei>:



struct inode* namei(char* path)
{
80102ce6:	55                   	push   %ebp
80102ce7:	89 e5                	mov    %esp,%ebp
80102ce9:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 0,name);
80102cec:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102cef:	50                   	push   %eax
80102cf0:	6a 00                	push   $0x0
80102cf2:	6a 00                	push   $0x0
80102cf4:	ff 75 08             	pushl  0x8(%ebp)
80102cf7:	e8 40 fe ff ff       	call   80102b3c <namex>
80102cfc:	83 c4 10             	add    $0x10,%esp
}
80102cff:	c9                   	leave  
80102d00:	c3                   	ret    

80102d01 <nameiIgnoreMounts>:

struct inode* nameiIgnoreMounts(char* path)
{
80102d01:	55                   	push   %ebp
80102d02:	89 e5                	mov    %esp,%ebp
80102d04:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 1,name);
80102d07:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d0a:	50                   	push   %eax
80102d0b:	6a 01                	push   $0x1
80102d0d:	6a 00                	push   $0x0
80102d0f:	ff 75 08             	pushl  0x8(%ebp)
80102d12:	e8 25 fe ff ff       	call   80102b3c <namex>
80102d17:	83 c4 10             	add    $0x10,%esp
}
80102d1a:	c9                   	leave  
80102d1b:	c3                   	ret    

80102d1c <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102d1c:	55                   	push   %ebp
80102d1d:	89 e5                	mov    %esp,%ebp
80102d1f:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, 0,name);
80102d22:	ff 75 0c             	pushl  0xc(%ebp)
80102d25:	6a 00                	push   $0x0
80102d27:	6a 01                	push   $0x1
80102d29:	ff 75 08             	pushl  0x8(%ebp)
80102d2c:	e8 0b fe ff ff       	call   80102b3c <namex>
80102d31:	83 c4 10             	add    $0x10,%esp
}
80102d34:	c9                   	leave  
80102d35:	c3                   	ret    

80102d36 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d36:	55                   	push   %ebp
80102d37:	89 e5                	mov    %esp,%ebp
80102d39:	83 ec 14             	sub    $0x14,%esp
80102d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d43:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d47:	89 c2                	mov    %eax,%edx
80102d49:	ec                   	in     (%dx),%al
80102d4a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d4d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d51:	c9                   	leave  
80102d52:	c3                   	ret    

80102d53 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d53:	55                   	push   %ebp
80102d54:	89 e5                	mov    %esp,%ebp
80102d56:	57                   	push   %edi
80102d57:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d58:	8b 55 08             	mov    0x8(%ebp),%edx
80102d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d5e:	8b 45 10             	mov    0x10(%ebp),%eax
80102d61:	89 cb                	mov    %ecx,%ebx
80102d63:	89 df                	mov    %ebx,%edi
80102d65:	89 c1                	mov    %eax,%ecx
80102d67:	fc                   	cld    
80102d68:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d6a:	89 c8                	mov    %ecx,%eax
80102d6c:	89 fb                	mov    %edi,%ebx
80102d6e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d71:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d74:	90                   	nop
80102d75:	5b                   	pop    %ebx
80102d76:	5f                   	pop    %edi
80102d77:	5d                   	pop    %ebp
80102d78:	c3                   	ret    

80102d79 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d79:	55                   	push   %ebp
80102d7a:	89 e5                	mov    %esp,%ebp
80102d7c:	83 ec 08             	sub    $0x8,%esp
80102d7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d85:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d89:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d8c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d90:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d94:	ee                   	out    %al,(%dx)
}
80102d95:	90                   	nop
80102d96:	c9                   	leave  
80102d97:	c3                   	ret    

80102d98 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
80102d9b:	56                   	push   %esi
80102d9c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102d9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102da3:	8b 45 10             	mov    0x10(%ebp),%eax
80102da6:	89 cb                	mov    %ecx,%ebx
80102da8:	89 de                	mov    %ebx,%esi
80102daa:	89 c1                	mov    %eax,%ecx
80102dac:	fc                   	cld    
80102dad:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102daf:	89 c8                	mov    %ecx,%eax
80102db1:	89 f3                	mov    %esi,%ebx
80102db3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102db6:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102db9:	90                   	nop
80102dba:	5b                   	pop    %ebx
80102dbb:	5e                   	pop    %esi
80102dbc:	5d                   	pop    %ebp
80102dbd:	c3                   	ret    

80102dbe <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102dbe:	55                   	push   %ebp
80102dbf:	89 e5                	mov    %esp,%ebp
80102dc1:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102dc4:	90                   	nop
80102dc5:	68 f7 01 00 00       	push   $0x1f7
80102dca:	e8 67 ff ff ff       	call   80102d36 <inb>
80102dcf:	83 c4 04             	add    $0x4,%esp
80102dd2:	0f b6 c0             	movzbl %al,%eax
80102dd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102dd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ddb:	25 c0 00 00 00       	and    $0xc0,%eax
80102de0:	83 f8 40             	cmp    $0x40,%eax
80102de3:	75 e0                	jne    80102dc5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102de5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102de9:	74 11                	je     80102dfc <idewait+0x3e>
80102deb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dee:	83 e0 21             	and    $0x21,%eax
80102df1:	85 c0                	test   %eax,%eax
80102df3:	74 07                	je     80102dfc <idewait+0x3e>
    return -1;
80102df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dfa:	eb 05                	jmp    80102e01 <idewait+0x43>
  return 0;
80102dfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e01:	c9                   	leave  
80102e02:	c3                   	ret    

80102e03 <ideinit>:

void
ideinit(void)
{
80102e03:	55                   	push   %ebp
80102e04:	89 e5                	mov    %esp,%ebp
80102e06:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102e09:	83 ec 08             	sub    $0x8,%esp
80102e0c:	68 ee 95 10 80       	push   $0x801095ee
80102e11:	68 00 c6 10 80       	push   $0x8010c600
80102e16:	e8 32 2d 00 00       	call   80105b4d <initlock>
80102e1b:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e1e:	83 ec 0c             	sub    $0xc,%esp
80102e21:	6a 0e                	push   $0xe
80102e23:	e8 0d 1c 00 00       	call   80104a35 <picenable>
80102e28:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e2b:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102e30:	83 e8 01             	sub    $0x1,%eax
80102e33:	83 ec 08             	sub    $0x8,%esp
80102e36:	50                   	push   %eax
80102e37:	6a 0e                	push   $0xe
80102e39:	e8 93 04 00 00       	call   801032d1 <ioapicenable>
80102e3e:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102e41:	83 ec 0c             	sub    $0xc,%esp
80102e44:	6a 00                	push   $0x0
80102e46:	e8 73 ff ff ff       	call   80102dbe <idewait>
80102e4b:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e4e:	83 ec 08             	sub    $0x8,%esp
80102e51:	68 f0 00 00 00       	push   $0xf0
80102e56:	68 f6 01 00 00       	push   $0x1f6
80102e5b:	e8 19 ff ff ff       	call   80102d79 <outb>
80102e60:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e6a:	eb 24                	jmp    80102e90 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102e6c:	83 ec 0c             	sub    $0xc,%esp
80102e6f:	68 f7 01 00 00       	push   $0x1f7
80102e74:	e8 bd fe ff ff       	call   80102d36 <inb>
80102e79:	83 c4 10             	add    $0x10,%esp
80102e7c:	84 c0                	test   %al,%al
80102e7e:	74 0c                	je     80102e8c <ideinit+0x89>
      havedisk1 = 1;
80102e80:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102e87:	00 00 00 
      break;
80102e8a:	eb 0d                	jmp    80102e99 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102e8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e90:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102e97:	7e d3                	jle    80102e6c <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102e99:	83 ec 08             	sub    $0x8,%esp
80102e9c:	68 e0 00 00 00       	push   $0xe0
80102ea1:	68 f6 01 00 00       	push   $0x1f6
80102ea6:	e8 ce fe ff ff       	call   80102d79 <outb>
80102eab:	83 c4 10             	add    $0x10,%esp
}
80102eae:	90                   	nop
80102eaf:	c9                   	leave  
80102eb0:	c3                   	ret    

80102eb1 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102eb1:	55                   	push   %ebp
80102eb2:	89 e5                	mov    %esp,%ebp
80102eb4:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102eb7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ebb:	75 0d                	jne    80102eca <idestart+0x19>
    panic("idestart");
80102ebd:	83 ec 0c             	sub    $0xc,%esp
80102ec0:	68 f2 95 10 80       	push   $0x801095f2
80102ec5:	e8 9c d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102eca:	8b 45 08             	mov    0x8(%ebp),%eax
80102ecd:	8b 40 08             	mov    0x8(%eax),%eax
80102ed0:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102ed5:	76 1d                	jbe    80102ef4 <idestart+0x43>
      cprintf("block %d \n");
80102ed7:	83 ec 0c             	sub    $0xc,%esp
80102eda:	68 fb 95 10 80       	push   $0x801095fb
80102edf:	e8 e2 d4 ff ff       	call   801003c6 <cprintf>
80102ee4:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102ee7:	83 ec 0c             	sub    $0xc,%esp
80102eea:	68 06 96 10 80       	push   $0x80109606
80102eef:	e8 72 d6 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102ef4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102efb:	8b 45 08             	mov    0x8(%ebp),%eax
80102efe:	8b 50 08             	mov    0x8(%eax),%edx
80102f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f04:	0f af c2             	imul   %edx,%eax
80102f07:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f0a:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f0e:	7e 0d                	jle    80102f1d <idestart+0x6c>
80102f10:	83 ec 0c             	sub    $0xc,%esp
80102f13:	68 f2 95 10 80       	push   $0x801095f2
80102f18:	e8 49 d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102f1d:	83 ec 0c             	sub    $0xc,%esp
80102f20:	6a 00                	push   $0x0
80102f22:	e8 97 fe ff ff       	call   80102dbe <idewait>
80102f27:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f2a:	83 ec 08             	sub    $0x8,%esp
80102f2d:	6a 00                	push   $0x0
80102f2f:	68 f6 03 00 00       	push   $0x3f6
80102f34:	e8 40 fe ff ff       	call   80102d79 <outb>
80102f39:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f3f:	0f b6 c0             	movzbl %al,%eax
80102f42:	83 ec 08             	sub    $0x8,%esp
80102f45:	50                   	push   %eax
80102f46:	68 f2 01 00 00       	push   $0x1f2
80102f4b:	e8 29 fe ff ff       	call   80102d79 <outb>
80102f50:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f56:	0f b6 c0             	movzbl %al,%eax
80102f59:	83 ec 08             	sub    $0x8,%esp
80102f5c:	50                   	push   %eax
80102f5d:	68 f3 01 00 00       	push   $0x1f3
80102f62:	e8 12 fe ff ff       	call   80102d79 <outb>
80102f67:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f6d:	c1 f8 08             	sar    $0x8,%eax
80102f70:	0f b6 c0             	movzbl %al,%eax
80102f73:	83 ec 08             	sub    $0x8,%esp
80102f76:	50                   	push   %eax
80102f77:	68 f4 01 00 00       	push   $0x1f4
80102f7c:	e8 f8 fd ff ff       	call   80102d79 <outb>
80102f81:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f87:	c1 f8 10             	sar    $0x10,%eax
80102f8a:	0f b6 c0             	movzbl %al,%eax
80102f8d:	83 ec 08             	sub    $0x8,%esp
80102f90:	50                   	push   %eax
80102f91:	68 f5 01 00 00       	push   $0x1f5
80102f96:	e8 de fd ff ff       	call   80102d79 <outb>
80102f9b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa1:	8b 40 04             	mov    0x4(%eax),%eax
80102fa4:	83 e0 01             	and    $0x1,%eax
80102fa7:	c1 e0 04             	shl    $0x4,%eax
80102faa:	89 c2                	mov    %eax,%edx
80102fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102faf:	c1 f8 18             	sar    $0x18,%eax
80102fb2:	83 e0 0f             	and    $0xf,%eax
80102fb5:	09 d0                	or     %edx,%eax
80102fb7:	83 c8 e0             	or     $0xffffffe0,%eax
80102fba:	0f b6 c0             	movzbl %al,%eax
80102fbd:	83 ec 08             	sub    $0x8,%esp
80102fc0:	50                   	push   %eax
80102fc1:	68 f6 01 00 00       	push   $0x1f6
80102fc6:	e8 ae fd ff ff       	call   80102d79 <outb>
80102fcb:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102fce:	8b 45 08             	mov    0x8(%ebp),%eax
80102fd1:	8b 00                	mov    (%eax),%eax
80102fd3:	83 e0 04             	and    $0x4,%eax
80102fd6:	85 c0                	test   %eax,%eax
80102fd8:	74 30                	je     8010300a <idestart+0x159>
    outb(0x1f7, IDE_CMD_WRITE);
80102fda:	83 ec 08             	sub    $0x8,%esp
80102fdd:	6a 30                	push   $0x30
80102fdf:	68 f7 01 00 00       	push   $0x1f7
80102fe4:	e8 90 fd ff ff       	call   80102d79 <outb>
80102fe9:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102fec:	8b 45 08             	mov    0x8(%ebp),%eax
80102fef:	83 c0 18             	add    $0x18,%eax
80102ff2:	83 ec 04             	sub    $0x4,%esp
80102ff5:	68 80 00 00 00       	push   $0x80
80102ffa:	50                   	push   %eax
80102ffb:	68 f0 01 00 00       	push   $0x1f0
80103000:	e8 93 fd ff ff       	call   80102d98 <outsl>
80103005:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80103008:	eb 12                	jmp    8010301c <idestart+0x16b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010300a:	83 ec 08             	sub    $0x8,%esp
8010300d:	6a 20                	push   $0x20
8010300f:	68 f7 01 00 00       	push   $0x1f7
80103014:	e8 60 fd ff ff       	call   80102d79 <outb>
80103019:	83 c4 10             	add    $0x10,%esp
  }
}
8010301c:	90                   	nop
8010301d:	c9                   	leave  
8010301e:	c3                   	ret    

8010301f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010301f:	55                   	push   %ebp
80103020:	89 e5                	mov    %esp,%ebp
80103022:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80103025:	83 ec 0c             	sub    $0xc,%esp
80103028:	68 00 c6 10 80       	push   $0x8010c600
8010302d:	e8 3d 2b 00 00       	call   80105b6f <acquire>
80103032:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80103035:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010303a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010303d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103041:	75 15                	jne    80103058 <ideintr+0x39>
    release(&idelock);
80103043:	83 ec 0c             	sub    $0xc,%esp
80103046:	68 00 c6 10 80       	push   $0x8010c600
8010304b:	e8 86 2b 00 00       	call   80105bd6 <release>
80103050:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80103053:	e9 aa 00 00 00       	jmp    80103102 <ideintr+0xe3>
  }
  idequeue = b->qnext;
80103058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010305b:	8b 40 14             	mov    0x14(%eax),%eax
8010305e:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103066:	8b 00                	mov    (%eax),%eax
80103068:	83 e0 04             	and    $0x4,%eax
8010306b:	85 c0                	test   %eax,%eax
8010306d:	75 2d                	jne    8010309c <ideintr+0x7d>
8010306f:	83 ec 0c             	sub    $0xc,%esp
80103072:	6a 01                	push   $0x1
80103074:	e8 45 fd ff ff       	call   80102dbe <idewait>
80103079:	83 c4 10             	add    $0x10,%esp
8010307c:	85 c0                	test   %eax,%eax
8010307e:	78 1c                	js     8010309c <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80103080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103083:	83 c0 18             	add    $0x18,%eax
80103086:	83 ec 04             	sub    $0x4,%esp
80103089:	68 80 00 00 00       	push   $0x80
8010308e:	50                   	push   %eax
8010308f:	68 f0 01 00 00       	push   $0x1f0
80103094:	e8 ba fc ff ff       	call   80102d53 <insl>
80103099:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010309c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010309f:	8b 00                	mov    (%eax),%eax
801030a1:	83 c8 02             	or     $0x2,%eax
801030a4:	89 c2                	mov    %eax,%edx
801030a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030a9:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030ae:	8b 00                	mov    (%eax),%eax
801030b0:	83 e0 fb             	and    $0xfffffffb,%eax
801030b3:	89 c2                	mov    %eax,%edx
801030b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b8:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801030ba:	83 ec 0c             	sub    $0xc,%esp
801030bd:	ff 75 f4             	pushl  -0xc(%ebp)
801030c0:	e8 9c 28 00 00       	call   80105961 <wakeup>
801030c5:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
801030c8:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030cd:	85 c0                	test   %eax,%eax
801030cf:	74 21                	je     801030f2 <ideintr+0xd3>
            cprintf("ideintr \n");
801030d1:	83 ec 0c             	sub    $0xc,%esp
801030d4:	68 18 96 10 80       	push   $0x80109618
801030d9:	e8 e8 d2 ff ff       	call   801003c6 <cprintf>
801030de:	83 c4 10             	add    $0x10,%esp
                idestart(idequeue);
801030e1:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030e6:	83 ec 0c             	sub    $0xc,%esp
801030e9:	50                   	push   %eax
801030ea:	e8 c2 fd ff ff       	call   80102eb1 <idestart>
801030ef:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
801030f2:	83 ec 0c             	sub    $0xc,%esp
801030f5:	68 00 c6 10 80       	push   $0x8010c600
801030fa:	e8 d7 2a 00 00       	call   80105bd6 <release>
801030ff:	83 c4 10             	add    $0x10,%esp
}
80103102:	c9                   	leave  
80103103:	c3                   	ret    

80103104 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103104:	55                   	push   %ebp
80103105:	89 e5                	mov    %esp,%ebp
80103107:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010310a:	8b 45 08             	mov    0x8(%ebp),%eax
8010310d:	8b 00                	mov    (%eax),%eax
8010310f:	83 e0 01             	and    $0x1,%eax
80103112:	85 c0                	test   %eax,%eax
80103114:	75 0d                	jne    80103123 <iderw+0x1f>
    panic("iderw: buf not busy");
80103116:	83 ec 0c             	sub    $0xc,%esp
80103119:	68 22 96 10 80       	push   $0x80109622
8010311e:	e8 43 d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103123:	8b 45 08             	mov    0x8(%ebp),%eax
80103126:	8b 00                	mov    (%eax),%eax
80103128:	83 e0 06             	and    $0x6,%eax
8010312b:	83 f8 02             	cmp    $0x2,%eax
8010312e:	75 0d                	jne    8010313d <iderw+0x39>
    panic("iderw: nothing to do");
80103130:	83 ec 0c             	sub    $0xc,%esp
80103133:	68 36 96 10 80       	push   $0x80109636
80103138:	e8 29 d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010313d:	8b 45 08             	mov    0x8(%ebp),%eax
80103140:	8b 40 04             	mov    0x4(%eax),%eax
80103143:	85 c0                	test   %eax,%eax
80103145:	74 16                	je     8010315d <iderw+0x59>
80103147:	a1 38 c6 10 80       	mov    0x8010c638,%eax
8010314c:	85 c0                	test   %eax,%eax
8010314e:	75 0d                	jne    8010315d <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80103150:	83 ec 0c             	sub    $0xc,%esp
80103153:	68 4b 96 10 80       	push   $0x8010964b
80103158:	e8 09 d4 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010315d:	83 ec 0c             	sub    $0xc,%esp
80103160:	68 00 c6 10 80       	push   $0x8010c600
80103165:	e8 05 2a 00 00       	call   80105b6f <acquire>
8010316a:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010316d:	8b 45 08             	mov    0x8(%ebp),%eax
80103170:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80103177:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
8010317e:	eb 0b                	jmp    8010318b <iderw+0x87>
80103180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103183:	8b 00                	mov    (%eax),%eax
80103185:	83 c0 14             	add    $0x14,%eax
80103188:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010318b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010318e:	8b 00                	mov    (%eax),%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	75 ec                	jne    80103180 <iderw+0x7c>
    ;
  *pp = b;
80103194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103197:	8b 55 08             	mov    0x8(%ebp),%edx
8010319a:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
8010319c:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801031a1:	3b 45 08             	cmp    0x8(%ebp),%eax
801031a4:	75 23                	jne    801031c9 <iderw+0xc5>
     // cprintf("iderw \n");
          idestart(b);
801031a6:	83 ec 0c             	sub    $0xc,%esp
801031a9:	ff 75 08             	pushl  0x8(%ebp)
801031ac:	e8 00 fd ff ff       	call   80102eb1 <idestart>
801031b1:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031b4:	eb 13                	jmp    801031c9 <iderw+0xc5>
    sleep(b, &idelock);
801031b6:	83 ec 08             	sub    $0x8,%esp
801031b9:	68 00 c6 10 80       	push   $0x8010c600
801031be:	ff 75 08             	pushl  0x8(%ebp)
801031c1:	e8 b0 26 00 00       	call   80105876 <sleep>
801031c6:	83 c4 10             	add    $0x10,%esp
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031c9:	8b 45 08             	mov    0x8(%ebp),%eax
801031cc:	8b 00                	mov    (%eax),%eax
801031ce:	83 e0 06             	and    $0x6,%eax
801031d1:	83 f8 02             	cmp    $0x2,%eax
801031d4:	75 e0                	jne    801031b6 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801031d6:	83 ec 0c             	sub    $0xc,%esp
801031d9:	68 00 c6 10 80       	push   $0x8010c600
801031de:	e8 f3 29 00 00       	call   80105bd6 <release>
801031e3:	83 c4 10             	add    $0x10,%esp
}
801031e6:	90                   	nop
801031e7:	c9                   	leave  
801031e8:	c3                   	ret    

801031e9 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801031e9:	55                   	push   %ebp
801031ea:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801031ec:	a1 fc 34 11 80       	mov    0x801134fc,%eax
801031f1:	8b 55 08             	mov    0x8(%ebp),%edx
801031f4:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801031f6:	a1 fc 34 11 80       	mov    0x801134fc,%eax
801031fb:	8b 40 10             	mov    0x10(%eax),%eax
}
801031fe:	5d                   	pop    %ebp
801031ff:	c3                   	ret    

80103200 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103203:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103208:	8b 55 08             	mov    0x8(%ebp),%edx
8010320b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010320d:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103212:	8b 55 0c             	mov    0xc(%ebp),%edx
80103215:	89 50 10             	mov    %edx,0x10(%eax)
}
80103218:	90                   	nop
80103219:	5d                   	pop    %ebp
8010321a:	c3                   	ret    

8010321b <ioapicinit>:

void
ioapicinit(void)
{
8010321b:	55                   	push   %ebp
8010321c:	89 e5                	mov    %esp,%ebp
8010321e:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80103221:	a1 64 38 11 80       	mov    0x80113864,%eax
80103226:	85 c0                	test   %eax,%eax
80103228:	0f 84 a0 00 00 00    	je     801032ce <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010322e:	c7 05 fc 34 11 80 00 	movl   $0xfec00000,0x801134fc
80103235:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103238:	6a 01                	push   $0x1
8010323a:	e8 aa ff ff ff       	call   801031e9 <ioapicread>
8010323f:	83 c4 04             	add    $0x4,%esp
80103242:	c1 e8 10             	shr    $0x10,%eax
80103245:	25 ff 00 00 00       	and    $0xff,%eax
8010324a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010324d:	6a 00                	push   $0x0
8010324f:	e8 95 ff ff ff       	call   801031e9 <ioapicread>
80103254:	83 c4 04             	add    $0x4,%esp
80103257:	c1 e8 18             	shr    $0x18,%eax
8010325a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010325d:	0f b6 05 60 38 11 80 	movzbl 0x80113860,%eax
80103264:	0f b6 c0             	movzbl %al,%eax
80103267:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010326a:	74 10                	je     8010327c <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010326c:	83 ec 0c             	sub    $0xc,%esp
8010326f:	68 6c 96 10 80       	push   $0x8010966c
80103274:	e8 4d d1 ff ff       	call   801003c6 <cprintf>
80103279:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010327c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103283:	eb 3f                	jmp    801032c4 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103288:	83 c0 20             	add    $0x20,%eax
8010328b:	0d 00 00 01 00       	or     $0x10000,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103295:	83 c0 08             	add    $0x8,%eax
80103298:	01 c0                	add    %eax,%eax
8010329a:	83 ec 08             	sub    $0x8,%esp
8010329d:	52                   	push   %edx
8010329e:	50                   	push   %eax
8010329f:	e8 5c ff ff ff       	call   80103200 <ioapicwrite>
801032a4:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801032a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032aa:	83 c0 08             	add    $0x8,%eax
801032ad:	01 c0                	add    %eax,%eax
801032af:	83 c0 01             	add    $0x1,%eax
801032b2:	83 ec 08             	sub    $0x8,%esp
801032b5:	6a 00                	push   $0x0
801032b7:	50                   	push   %eax
801032b8:	e8 43 ff ff ff       	call   80103200 <ioapicwrite>
801032bd:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801032ca:	7e b9                	jle    80103285 <ioapicinit+0x6a>
801032cc:	eb 01                	jmp    801032cf <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801032ce:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801032cf:	c9                   	leave  
801032d0:	c3                   	ret    

801032d1 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801032d1:	55                   	push   %ebp
801032d2:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801032d4:	a1 64 38 11 80       	mov    0x80113864,%eax
801032d9:	85 c0                	test   %eax,%eax
801032db:	74 39                	je     80103316 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801032dd:	8b 45 08             	mov    0x8(%ebp),%eax
801032e0:	83 c0 20             	add    $0x20,%eax
801032e3:	89 c2                	mov    %eax,%edx
801032e5:	8b 45 08             	mov    0x8(%ebp),%eax
801032e8:	83 c0 08             	add    $0x8,%eax
801032eb:	01 c0                	add    %eax,%eax
801032ed:	52                   	push   %edx
801032ee:	50                   	push   %eax
801032ef:	e8 0c ff ff ff       	call   80103200 <ioapicwrite>
801032f4:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801032f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801032fa:	c1 e0 18             	shl    $0x18,%eax
801032fd:	89 c2                	mov    %eax,%edx
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	83 c0 08             	add    $0x8,%eax
80103305:	01 c0                	add    %eax,%eax
80103307:	83 c0 01             	add    $0x1,%eax
8010330a:	52                   	push   %edx
8010330b:	50                   	push   %eax
8010330c:	e8 ef fe ff ff       	call   80103200 <ioapicwrite>
80103311:	83 c4 08             	add    $0x8,%esp
80103314:	eb 01                	jmp    80103317 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103316:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103317:	c9                   	leave  
80103318:	c3                   	ret    

80103319 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103319:	55                   	push   %ebp
8010331a:	89 e5                	mov    %esp,%ebp
8010331c:	8b 45 08             	mov    0x8(%ebp),%eax
8010331f:	05 00 00 00 80       	add    $0x80000000,%eax
80103324:	5d                   	pop    %ebp
80103325:	c3                   	ret    

80103326 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103326:	55                   	push   %ebp
80103327:	89 e5                	mov    %esp,%ebp
80103329:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
8010332c:	83 ec 08             	sub    $0x8,%esp
8010332f:	68 9e 96 10 80       	push   $0x8010969e
80103334:	68 00 35 11 80       	push   $0x80113500
80103339:	e8 0f 28 00 00       	call   80105b4d <initlock>
8010333e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80103341:	c7 05 34 35 11 80 00 	movl   $0x0,0x80113534
80103348:	00 00 00 
  freerange(vstart, vend);
8010334b:	83 ec 08             	sub    $0x8,%esp
8010334e:	ff 75 0c             	pushl  0xc(%ebp)
80103351:	ff 75 08             	pushl  0x8(%ebp)
80103354:	e8 2a 00 00 00       	call   80103383 <freerange>
80103359:	83 c4 10             	add    $0x10,%esp
}
8010335c:	90                   	nop
8010335d:	c9                   	leave  
8010335e:	c3                   	ret    

8010335f <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010335f:	55                   	push   %ebp
80103360:	89 e5                	mov    %esp,%ebp
80103362:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80103365:	83 ec 08             	sub    $0x8,%esp
80103368:	ff 75 0c             	pushl  0xc(%ebp)
8010336b:	ff 75 08             	pushl  0x8(%ebp)
8010336e:	e8 10 00 00 00       	call   80103383 <freerange>
80103373:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80103376:	c7 05 34 35 11 80 01 	movl   $0x1,0x80113534
8010337d:	00 00 00 
}
80103380:	90                   	nop
80103381:	c9                   	leave  
80103382:	c3                   	ret    

80103383 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103383:	55                   	push   %ebp
80103384:	89 e5                	mov    %esp,%ebp
80103386:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103389:	8b 45 08             	mov    0x8(%ebp),%eax
8010338c:	05 ff 0f 00 00       	add    $0xfff,%eax
80103391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103399:	eb 15                	jmp    801033b0 <freerange+0x2d>
    kfree(p);
8010339b:	83 ec 0c             	sub    $0xc,%esp
8010339e:	ff 75 f4             	pushl  -0xc(%ebp)
801033a1:	e8 1a 00 00 00       	call   801033c0 <kfree>
801033a6:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801033b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b3:	05 00 10 00 00       	add    $0x1000,%eax
801033b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801033bb:	76 de                	jbe    8010339b <freerange+0x18>
    kfree(p);
}
801033bd:	90                   	nop
801033be:	c9                   	leave  
801033bf:	c3                   	ret    

801033c0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801033c0:	55                   	push   %ebp
801033c1:	89 e5                	mov    %esp,%ebp
801033c3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801033c6:	8b 45 08             	mov    0x8(%ebp),%eax
801033c9:	25 ff 0f 00 00       	and    $0xfff,%eax
801033ce:	85 c0                	test   %eax,%eax
801033d0:	75 1b                	jne    801033ed <kfree+0x2d>
801033d2:	81 7d 08 5c 66 11 80 	cmpl   $0x8011665c,0x8(%ebp)
801033d9:	72 12                	jb     801033ed <kfree+0x2d>
801033db:	ff 75 08             	pushl  0x8(%ebp)
801033de:	e8 36 ff ff ff       	call   80103319 <v2p>
801033e3:	83 c4 04             	add    $0x4,%esp
801033e6:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801033eb:	76 0d                	jbe    801033fa <kfree+0x3a>
    panic("kfree");
801033ed:	83 ec 0c             	sub    $0xc,%esp
801033f0:	68 a3 96 10 80       	push   $0x801096a3
801033f5:	e8 6c d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801033fa:	83 ec 04             	sub    $0x4,%esp
801033fd:	68 00 10 00 00       	push   $0x1000
80103402:	6a 01                	push   $0x1
80103404:	ff 75 08             	pushl  0x8(%ebp)
80103407:	e8 c6 29 00 00       	call   80105dd2 <memset>
8010340c:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010340f:	a1 34 35 11 80       	mov    0x80113534,%eax
80103414:	85 c0                	test   %eax,%eax
80103416:	74 10                	je     80103428 <kfree+0x68>
    acquire(&kmem.lock);
80103418:	83 ec 0c             	sub    $0xc,%esp
8010341b:	68 00 35 11 80       	push   $0x80113500
80103420:	e8 4a 27 00 00       	call   80105b6f <acquire>
80103425:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80103428:	8b 45 08             	mov    0x8(%ebp),%eax
8010342b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010342e:	8b 15 38 35 11 80    	mov    0x80113538,%edx
80103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103437:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010343c:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
80103441:	a1 34 35 11 80       	mov    0x80113534,%eax
80103446:	85 c0                	test   %eax,%eax
80103448:	74 10                	je     8010345a <kfree+0x9a>
    release(&kmem.lock);
8010344a:	83 ec 0c             	sub    $0xc,%esp
8010344d:	68 00 35 11 80       	push   $0x80113500
80103452:	e8 7f 27 00 00       	call   80105bd6 <release>
80103457:	83 c4 10             	add    $0x10,%esp
}
8010345a:	90                   	nop
8010345b:	c9                   	leave  
8010345c:	c3                   	ret    

8010345d <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010345d:	55                   	push   %ebp
8010345e:	89 e5                	mov    %esp,%ebp
80103460:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103463:	a1 34 35 11 80       	mov    0x80113534,%eax
80103468:	85 c0                	test   %eax,%eax
8010346a:	74 10                	je     8010347c <kalloc+0x1f>
    acquire(&kmem.lock);
8010346c:	83 ec 0c             	sub    $0xc,%esp
8010346f:	68 00 35 11 80       	push   $0x80113500
80103474:	e8 f6 26 00 00       	call   80105b6f <acquire>
80103479:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010347c:	a1 38 35 11 80       	mov    0x80113538,%eax
80103481:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103484:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103488:	74 0a                	je     80103494 <kalloc+0x37>
    kmem.freelist = r->next;
8010348a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010348d:	8b 00                	mov    (%eax),%eax
8010348f:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
80103494:	a1 34 35 11 80       	mov    0x80113534,%eax
80103499:	85 c0                	test   %eax,%eax
8010349b:	74 10                	je     801034ad <kalloc+0x50>
    release(&kmem.lock);
8010349d:	83 ec 0c             	sub    $0xc,%esp
801034a0:	68 00 35 11 80       	push   $0x80113500
801034a5:	e8 2c 27 00 00       	call   80105bd6 <release>
801034aa:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801034ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801034b0:	c9                   	leave  
801034b1:	c3                   	ret    

801034b2 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034b2:	55                   	push   %ebp
801034b3:	89 e5                	mov    %esp,%ebp
801034b5:	83 ec 14             	sub    $0x14,%esp
801034b8:	8b 45 08             	mov    0x8(%ebp),%eax
801034bb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034bf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034c3:	89 c2                	mov    %eax,%edx
801034c5:	ec                   	in     (%dx),%al
801034c6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034c9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034cd:	c9                   	leave  
801034ce:	c3                   	ret    

801034cf <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801034cf:	55                   	push   %ebp
801034d0:	89 e5                	mov    %esp,%ebp
801034d2:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801034d5:	6a 64                	push   $0x64
801034d7:	e8 d6 ff ff ff       	call   801034b2 <inb>
801034dc:	83 c4 04             	add    $0x4,%esp
801034df:	0f b6 c0             	movzbl %al,%eax
801034e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801034e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e8:	83 e0 01             	and    $0x1,%eax
801034eb:	85 c0                	test   %eax,%eax
801034ed:	75 0a                	jne    801034f9 <kbdgetc+0x2a>
    return -1;
801034ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034f4:	e9 23 01 00 00       	jmp    8010361c <kbdgetc+0x14d>
  data = inb(KBDATAP);
801034f9:	6a 60                	push   $0x60
801034fb:	e8 b2 ff ff ff       	call   801034b2 <inb>
80103500:	83 c4 04             	add    $0x4,%esp
80103503:	0f b6 c0             	movzbl %al,%eax
80103506:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103509:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103510:	75 17                	jne    80103529 <kbdgetc+0x5a>
    shift |= E0ESC;
80103512:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103517:	83 c8 40             	or     $0x40,%eax
8010351a:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010351f:	b8 00 00 00 00       	mov    $0x0,%eax
80103524:	e9 f3 00 00 00       	jmp    8010361c <kbdgetc+0x14d>
  } else if(data & 0x80){
80103529:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010352c:	25 80 00 00 00       	and    $0x80,%eax
80103531:	85 c0                	test   %eax,%eax
80103533:	74 45                	je     8010357a <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103535:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010353a:	83 e0 40             	and    $0x40,%eax
8010353d:	85 c0                	test   %eax,%eax
8010353f:	75 08                	jne    80103549 <kbdgetc+0x7a>
80103541:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103544:	83 e0 7f             	and    $0x7f,%eax
80103547:	eb 03                	jmp    8010354c <kbdgetc+0x7d>
80103549:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010354c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010354f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103552:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103557:	0f b6 00             	movzbl (%eax),%eax
8010355a:	83 c8 40             	or     $0x40,%eax
8010355d:	0f b6 c0             	movzbl %al,%eax
80103560:	f7 d0                	not    %eax
80103562:	89 c2                	mov    %eax,%edx
80103564:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103569:	21 d0                	and    %edx,%eax
8010356b:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103570:	b8 00 00 00 00       	mov    $0x0,%eax
80103575:	e9 a2 00 00 00       	jmp    8010361c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010357a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010357f:	83 e0 40             	and    $0x40,%eax
80103582:	85 c0                	test   %eax,%eax
80103584:	74 14                	je     8010359a <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103586:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010358d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103592:	83 e0 bf             	and    $0xffffffbf,%eax
80103595:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
8010359a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010359d:	05 40 a0 10 80       	add    $0x8010a040,%eax
801035a2:	0f b6 00             	movzbl (%eax),%eax
801035a5:	0f b6 d0             	movzbl %al,%edx
801035a8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035ad:	09 d0                	or     %edx,%eax
801035af:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801035b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035b7:	05 40 a1 10 80       	add    $0x8010a140,%eax
801035bc:	0f b6 00             	movzbl (%eax),%eax
801035bf:	0f b6 d0             	movzbl %al,%edx
801035c2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035c7:	31 d0                	xor    %edx,%eax
801035c9:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801035ce:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035d3:	83 e0 03             	and    $0x3,%eax
801035d6:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
801035dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035e0:	01 d0                	add    %edx,%eax
801035e2:	0f b6 00             	movzbl (%eax),%eax
801035e5:	0f b6 c0             	movzbl %al,%eax
801035e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801035eb:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035f0:	83 e0 08             	and    $0x8,%eax
801035f3:	85 c0                	test   %eax,%eax
801035f5:	74 22                	je     80103619 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801035f7:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801035fb:	76 0c                	jbe    80103609 <kbdgetc+0x13a>
801035fd:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103601:	77 06                	ja     80103609 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103603:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103607:	eb 10                	jmp    80103619 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103609:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010360d:	76 0a                	jbe    80103619 <kbdgetc+0x14a>
8010360f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103613:	77 04                	ja     80103619 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103615:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103619:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010361c:	c9                   	leave  
8010361d:	c3                   	ret    

8010361e <kbdintr>:

void
kbdintr(void)
{
8010361e:	55                   	push   %ebp
8010361f:	89 e5                	mov    %esp,%ebp
80103621:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	68 cf 34 10 80       	push   $0x801034cf
8010362c:	e8 c8 d1 ff ff       	call   801007f9 <consoleintr>
80103631:	83 c4 10             	add    $0x10,%esp
}
80103634:	90                   	nop
80103635:	c9                   	leave  
80103636:	c3                   	ret    

80103637 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103637:	55                   	push   %ebp
80103638:	89 e5                	mov    %esp,%ebp
8010363a:	83 ec 14             	sub    $0x14,%esp
8010363d:	8b 45 08             	mov    0x8(%ebp),%eax
80103640:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103644:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103648:	89 c2                	mov    %eax,%edx
8010364a:	ec                   	in     (%dx),%al
8010364b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010364e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103652:	c9                   	leave  
80103653:	c3                   	ret    

80103654 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103654:	55                   	push   %ebp
80103655:	89 e5                	mov    %esp,%ebp
80103657:	83 ec 08             	sub    $0x8,%esp
8010365a:	8b 55 08             	mov    0x8(%ebp),%edx
8010365d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103660:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103664:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103667:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010366b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010366f:	ee                   	out    %al,(%dx)
}
80103670:	90                   	nop
80103671:	c9                   	leave  
80103672:	c3                   	ret    

80103673 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103673:	55                   	push   %ebp
80103674:	89 e5                	mov    %esp,%ebp
80103676:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103679:	9c                   	pushf  
8010367a:	58                   	pop    %eax
8010367b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010367e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103681:	c9                   	leave  
80103682:	c3                   	ret    

80103683 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103683:	55                   	push   %ebp
80103684:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103686:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010368b:	8b 55 08             	mov    0x8(%ebp),%edx
8010368e:	c1 e2 02             	shl    $0x2,%edx
80103691:	01 c2                	add    %eax,%edx
80103693:	8b 45 0c             	mov    0xc(%ebp),%eax
80103696:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103698:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010369d:	83 c0 20             	add    $0x20,%eax
801036a0:	8b 00                	mov    (%eax),%eax
}
801036a2:	90                   	nop
801036a3:	5d                   	pop    %ebp
801036a4:	c3                   	ret    

801036a5 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801036a5:	55                   	push   %ebp
801036a6:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801036a8:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036ad:	85 c0                	test   %eax,%eax
801036af:	0f 84 0b 01 00 00    	je     801037c0 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801036b5:	68 3f 01 00 00       	push   $0x13f
801036ba:	6a 3c                	push   $0x3c
801036bc:	e8 c2 ff ff ff       	call   80103683 <lapicw>
801036c1:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801036c4:	6a 0b                	push   $0xb
801036c6:	68 f8 00 00 00       	push   $0xf8
801036cb:	e8 b3 ff ff ff       	call   80103683 <lapicw>
801036d0:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801036d3:	68 20 00 02 00       	push   $0x20020
801036d8:	68 c8 00 00 00       	push   $0xc8
801036dd:	e8 a1 ff ff ff       	call   80103683 <lapicw>
801036e2:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801036e5:	68 80 96 98 00       	push   $0x989680
801036ea:	68 e0 00 00 00       	push   $0xe0
801036ef:	e8 8f ff ff ff       	call   80103683 <lapicw>
801036f4:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801036f7:	68 00 00 01 00       	push   $0x10000
801036fc:	68 d4 00 00 00       	push   $0xd4
80103701:	e8 7d ff ff ff       	call   80103683 <lapicw>
80103706:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103709:	68 00 00 01 00       	push   $0x10000
8010370e:	68 d8 00 00 00       	push   $0xd8
80103713:	e8 6b ff ff ff       	call   80103683 <lapicw>
80103718:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010371b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103720:	83 c0 30             	add    $0x30,%eax
80103723:	8b 00                	mov    (%eax),%eax
80103725:	c1 e8 10             	shr    $0x10,%eax
80103728:	0f b6 c0             	movzbl %al,%eax
8010372b:	83 f8 03             	cmp    $0x3,%eax
8010372e:	76 12                	jbe    80103742 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103730:	68 00 00 01 00       	push   $0x10000
80103735:	68 d0 00 00 00       	push   $0xd0
8010373a:	e8 44 ff ff ff       	call   80103683 <lapicw>
8010373f:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103742:	6a 33                	push   $0x33
80103744:	68 dc 00 00 00       	push   $0xdc
80103749:	e8 35 ff ff ff       	call   80103683 <lapicw>
8010374e:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103751:	6a 00                	push   $0x0
80103753:	68 a0 00 00 00       	push   $0xa0
80103758:	e8 26 ff ff ff       	call   80103683 <lapicw>
8010375d:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103760:	6a 00                	push   $0x0
80103762:	68 a0 00 00 00       	push   $0xa0
80103767:	e8 17 ff ff ff       	call   80103683 <lapicw>
8010376c:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010376f:	6a 00                	push   $0x0
80103771:	6a 2c                	push   $0x2c
80103773:	e8 0b ff ff ff       	call   80103683 <lapicw>
80103778:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010377b:	6a 00                	push   $0x0
8010377d:	68 c4 00 00 00       	push   $0xc4
80103782:	e8 fc fe ff ff       	call   80103683 <lapicw>
80103787:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010378a:	68 00 85 08 00       	push   $0x88500
8010378f:	68 c0 00 00 00       	push   $0xc0
80103794:	e8 ea fe ff ff       	call   80103683 <lapicw>
80103799:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010379c:	90                   	nop
8010379d:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801037a2:	05 00 03 00 00       	add    $0x300,%eax
801037a7:	8b 00                	mov    (%eax),%eax
801037a9:	25 00 10 00 00       	and    $0x1000,%eax
801037ae:	85 c0                	test   %eax,%eax
801037b0:	75 eb                	jne    8010379d <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801037b2:	6a 00                	push   $0x0
801037b4:	6a 20                	push   $0x20
801037b6:	e8 c8 fe ff ff       	call   80103683 <lapicw>
801037bb:	83 c4 08             	add    $0x8,%esp
801037be:	eb 01                	jmp    801037c1 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801037c0:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801037c1:	c9                   	leave  
801037c2:	c3                   	ret    

801037c3 <cpunum>:

int
cpunum(void)
{
801037c3:	55                   	push   %ebp
801037c4:	89 e5                	mov    %esp,%ebp
801037c6:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801037c9:	e8 a5 fe ff ff       	call   80103673 <readeflags>
801037ce:	25 00 02 00 00       	and    $0x200,%eax
801037d3:	85 c0                	test   %eax,%eax
801037d5:	74 26                	je     801037fd <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801037d7:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801037dc:	8d 50 01             	lea    0x1(%eax),%edx
801037df:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
801037e5:	85 c0                	test   %eax,%eax
801037e7:	75 14                	jne    801037fd <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801037e9:	8b 45 04             	mov    0x4(%ebp),%eax
801037ec:	83 ec 08             	sub    $0x8,%esp
801037ef:	50                   	push   %eax
801037f0:	68 ac 96 10 80       	push   $0x801096ac
801037f5:	e8 cc cb ff ff       	call   801003c6 <cprintf>
801037fa:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801037fd:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103802:	85 c0                	test   %eax,%eax
80103804:	74 0f                	je     80103815 <cpunum+0x52>
    return lapic[ID]>>24;
80103806:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010380b:	83 c0 20             	add    $0x20,%eax
8010380e:	8b 00                	mov    (%eax),%eax
80103810:	c1 e8 18             	shr    $0x18,%eax
80103813:	eb 05                	jmp    8010381a <cpunum+0x57>
  return 0;
80103815:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010381a:	c9                   	leave  
8010381b:	c3                   	ret    

8010381c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010381c:	55                   	push   %ebp
8010381d:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010381f:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103824:	85 c0                	test   %eax,%eax
80103826:	74 0c                	je     80103834 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103828:	6a 00                	push   $0x0
8010382a:	6a 2c                	push   $0x2c
8010382c:	e8 52 fe ff ff       	call   80103683 <lapicw>
80103831:	83 c4 08             	add    $0x8,%esp
}
80103834:	90                   	nop
80103835:	c9                   	leave  
80103836:	c3                   	ret    

80103837 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103837:	55                   	push   %ebp
80103838:	89 e5                	mov    %esp,%ebp
}
8010383a:	90                   	nop
8010383b:	5d                   	pop    %ebp
8010383c:	c3                   	ret    

8010383d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010383d:	55                   	push   %ebp
8010383e:	89 e5                	mov    %esp,%ebp
80103840:	83 ec 14             	sub    $0x14,%esp
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103849:	6a 0f                	push   $0xf
8010384b:	6a 70                	push   $0x70
8010384d:	e8 02 fe ff ff       	call   80103654 <outb>
80103852:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103855:	6a 0a                	push   $0xa
80103857:	6a 71                	push   $0x71
80103859:	e8 f6 fd ff ff       	call   80103654 <outb>
8010385e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103861:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103868:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010386b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103870:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103873:	83 c0 02             	add    $0x2,%eax
80103876:	8b 55 0c             	mov    0xc(%ebp),%edx
80103879:	c1 ea 04             	shr    $0x4,%edx
8010387c:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010387f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103883:	c1 e0 18             	shl    $0x18,%eax
80103886:	50                   	push   %eax
80103887:	68 c4 00 00 00       	push   $0xc4
8010388c:	e8 f2 fd ff ff       	call   80103683 <lapicw>
80103891:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103894:	68 00 c5 00 00       	push   $0xc500
80103899:	68 c0 00 00 00       	push   $0xc0
8010389e:	e8 e0 fd ff ff       	call   80103683 <lapicw>
801038a3:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801038a6:	68 c8 00 00 00       	push   $0xc8
801038ab:	e8 87 ff ff ff       	call   80103837 <microdelay>
801038b0:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801038b3:	68 00 85 00 00       	push   $0x8500
801038b8:	68 c0 00 00 00       	push   $0xc0
801038bd:	e8 c1 fd ff ff       	call   80103683 <lapicw>
801038c2:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038c5:	6a 64                	push   $0x64
801038c7:	e8 6b ff ff ff       	call   80103837 <microdelay>
801038cc:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038cf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038d6:	eb 3d                	jmp    80103915 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801038d8:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038dc:	c1 e0 18             	shl    $0x18,%eax
801038df:	50                   	push   %eax
801038e0:	68 c4 00 00 00       	push   $0xc4
801038e5:	e8 99 fd ff ff       	call   80103683 <lapicw>
801038ea:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801038ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801038f0:	c1 e8 0c             	shr    $0xc,%eax
801038f3:	80 cc 06             	or     $0x6,%ah
801038f6:	50                   	push   %eax
801038f7:	68 c0 00 00 00       	push   $0xc0
801038fc:	e8 82 fd ff ff       	call   80103683 <lapicw>
80103901:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103904:	68 c8 00 00 00       	push   $0xc8
80103909:	e8 29 ff ff ff       	call   80103837 <microdelay>
8010390e:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103911:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103915:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103919:	7e bd                	jle    801038d8 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010391b:	90                   	nop
8010391c:	c9                   	leave  
8010391d:	c3                   	ret    

8010391e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010391e:	55                   	push   %ebp
8010391f:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103921:	8b 45 08             	mov    0x8(%ebp),%eax
80103924:	0f b6 c0             	movzbl %al,%eax
80103927:	50                   	push   %eax
80103928:	6a 70                	push   $0x70
8010392a:	e8 25 fd ff ff       	call   80103654 <outb>
8010392f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103932:	68 c8 00 00 00       	push   $0xc8
80103937:	e8 fb fe ff ff       	call   80103837 <microdelay>
8010393c:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010393f:	6a 71                	push   $0x71
80103941:	e8 f1 fc ff ff       	call   80103637 <inb>
80103946:	83 c4 04             	add    $0x4,%esp
80103949:	0f b6 c0             	movzbl %al,%eax
}
8010394c:	c9                   	leave  
8010394d:	c3                   	ret    

8010394e <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010394e:	55                   	push   %ebp
8010394f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103951:	6a 00                	push   $0x0
80103953:	e8 c6 ff ff ff       	call   8010391e <cmos_read>
80103958:	83 c4 04             	add    $0x4,%esp
8010395b:	89 c2                	mov    %eax,%edx
8010395d:	8b 45 08             	mov    0x8(%ebp),%eax
80103960:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103962:	6a 02                	push   $0x2
80103964:	e8 b5 ff ff ff       	call   8010391e <cmos_read>
80103969:	83 c4 04             	add    $0x4,%esp
8010396c:	89 c2                	mov    %eax,%edx
8010396e:	8b 45 08             	mov    0x8(%ebp),%eax
80103971:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103974:	6a 04                	push   $0x4
80103976:	e8 a3 ff ff ff       	call   8010391e <cmos_read>
8010397b:	83 c4 04             	add    $0x4,%esp
8010397e:	89 c2                	mov    %eax,%edx
80103980:	8b 45 08             	mov    0x8(%ebp),%eax
80103983:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103986:	6a 07                	push   $0x7
80103988:	e8 91 ff ff ff       	call   8010391e <cmos_read>
8010398d:	83 c4 04             	add    $0x4,%esp
80103990:	89 c2                	mov    %eax,%edx
80103992:	8b 45 08             	mov    0x8(%ebp),%eax
80103995:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103998:	6a 08                	push   $0x8
8010399a:	e8 7f ff ff ff       	call   8010391e <cmos_read>
8010399f:	83 c4 04             	add    $0x4,%esp
801039a2:	89 c2                	mov    %eax,%edx
801039a4:	8b 45 08             	mov    0x8(%ebp),%eax
801039a7:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801039aa:	6a 09                	push   $0x9
801039ac:	e8 6d ff ff ff       	call   8010391e <cmos_read>
801039b1:	83 c4 04             	add    $0x4,%esp
801039b4:	89 c2                	mov    %eax,%edx
801039b6:	8b 45 08             	mov    0x8(%ebp),%eax
801039b9:	89 50 14             	mov    %edx,0x14(%eax)
}
801039bc:	90                   	nop
801039bd:	c9                   	leave  
801039be:	c3                   	ret    

801039bf <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039bf:	55                   	push   %ebp
801039c0:	89 e5                	mov    %esp,%ebp
801039c2:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039c5:	6a 0b                	push   $0xb
801039c7:	e8 52 ff ff ff       	call   8010391e <cmos_read>
801039cc:	83 c4 04             	add    $0x4,%esp
801039cf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d5:	83 e0 04             	and    $0x4,%eax
801039d8:	85 c0                	test   %eax,%eax
801039da:	0f 94 c0             	sete   %al
801039dd:	0f b6 c0             	movzbl %al,%eax
801039e0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039e3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039e6:	50                   	push   %eax
801039e7:	e8 62 ff ff ff       	call   8010394e <fill_rtcdate>
801039ec:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801039ef:	6a 0a                	push   $0xa
801039f1:	e8 28 ff ff ff       	call   8010391e <cmos_read>
801039f6:	83 c4 04             	add    $0x4,%esp
801039f9:	25 80 00 00 00       	and    $0x80,%eax
801039fe:	85 c0                	test   %eax,%eax
80103a00:	75 27                	jne    80103a29 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103a02:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a05:	50                   	push   %eax
80103a06:	e8 43 ff ff ff       	call   8010394e <fill_rtcdate>
80103a0b:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a0e:	83 ec 04             	sub    $0x4,%esp
80103a11:	6a 18                	push   $0x18
80103a13:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a16:	50                   	push   %eax
80103a17:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a1a:	50                   	push   %eax
80103a1b:	e8 19 24 00 00       	call   80105e39 <memcmp>
80103a20:	83 c4 10             	add    $0x10,%esp
80103a23:	85 c0                	test   %eax,%eax
80103a25:	74 05                	je     80103a2c <cmostime+0x6d>
80103a27:	eb ba                	jmp    801039e3 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a29:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a2a:	eb b7                	jmp    801039e3 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103a2c:	90                   	nop
  }

  // convert
  if (bcd) {
80103a2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a31:	0f 84 b4 00 00 00    	je     80103aeb <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a37:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a3a:	c1 e8 04             	shr    $0x4,%eax
80103a3d:	89 c2                	mov    %eax,%edx
80103a3f:	89 d0                	mov    %edx,%eax
80103a41:	c1 e0 02             	shl    $0x2,%eax
80103a44:	01 d0                	add    %edx,%eax
80103a46:	01 c0                	add    %eax,%eax
80103a48:	89 c2                	mov    %eax,%edx
80103a4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a4d:	83 e0 0f             	and    $0xf,%eax
80103a50:	01 d0                	add    %edx,%eax
80103a52:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a58:	c1 e8 04             	shr    $0x4,%eax
80103a5b:	89 c2                	mov    %eax,%edx
80103a5d:	89 d0                	mov    %edx,%eax
80103a5f:	c1 e0 02             	shl    $0x2,%eax
80103a62:	01 d0                	add    %edx,%eax
80103a64:	01 c0                	add    %eax,%eax
80103a66:	89 c2                	mov    %eax,%edx
80103a68:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a6b:	83 e0 0f             	and    $0xf,%eax
80103a6e:	01 d0                	add    %edx,%eax
80103a70:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a76:	c1 e8 04             	shr    $0x4,%eax
80103a79:	89 c2                	mov    %eax,%edx
80103a7b:	89 d0                	mov    %edx,%eax
80103a7d:	c1 e0 02             	shl    $0x2,%eax
80103a80:	01 d0                	add    %edx,%eax
80103a82:	01 c0                	add    %eax,%eax
80103a84:	89 c2                	mov    %eax,%edx
80103a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a89:	83 e0 0f             	and    $0xf,%eax
80103a8c:	01 d0                	add    %edx,%eax
80103a8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a94:	c1 e8 04             	shr    $0x4,%eax
80103a97:	89 c2                	mov    %eax,%edx
80103a99:	89 d0                	mov    %edx,%eax
80103a9b:	c1 e0 02             	shl    $0x2,%eax
80103a9e:	01 d0                	add    %edx,%eax
80103aa0:	01 c0                	add    %eax,%eax
80103aa2:	89 c2                	mov    %eax,%edx
80103aa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103aa7:	83 e0 0f             	and    $0xf,%eax
80103aaa:	01 d0                	add    %edx,%eax
80103aac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103aaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ab2:	c1 e8 04             	shr    $0x4,%eax
80103ab5:	89 c2                	mov    %eax,%edx
80103ab7:	89 d0                	mov    %edx,%eax
80103ab9:	c1 e0 02             	shl    $0x2,%eax
80103abc:	01 d0                	add    %edx,%eax
80103abe:	01 c0                	add    %eax,%eax
80103ac0:	89 c2                	mov    %eax,%edx
80103ac2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ac5:	83 e0 0f             	and    $0xf,%eax
80103ac8:	01 d0                	add    %edx,%eax
80103aca:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103acd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ad0:	c1 e8 04             	shr    $0x4,%eax
80103ad3:	89 c2                	mov    %eax,%edx
80103ad5:	89 d0                	mov    %edx,%eax
80103ad7:	c1 e0 02             	shl    $0x2,%eax
80103ada:	01 d0                	add    %edx,%eax
80103adc:	01 c0                	add    %eax,%eax
80103ade:	89 c2                	mov    %eax,%edx
80103ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae3:	83 e0 0f             	and    $0xf,%eax
80103ae6:	01 d0                	add    %edx,%eax
80103ae8:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80103aee:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103af1:	89 10                	mov    %edx,(%eax)
80103af3:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103af6:	89 50 04             	mov    %edx,0x4(%eax)
80103af9:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103afc:	89 50 08             	mov    %edx,0x8(%eax)
80103aff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b02:	89 50 0c             	mov    %edx,0xc(%eax)
80103b05:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b08:	89 50 10             	mov    %edx,0x10(%eax)
80103b0b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b0e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b11:	8b 45 08             	mov    0x8(%ebp),%eax
80103b14:	8b 40 14             	mov    0x14(%eax),%eax
80103b17:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b20:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b23:	90                   	nop
80103b24:	c9                   	leave  
80103b25:	c3                   	ret    

80103b26 <initlog>:
static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
80103b26:	55                   	push   %ebp
80103b27:	89 e5                	mov    %esp,%ebp
80103b29:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
for(int i=0;i<NPARTITIONS;i++){
80103b2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b33:	e9 98 00 00 00       	jmp    80103bd0 <initlog+0xaa>
     initlock(&logs[i].lock, "log");
80103b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b41:	05 40 35 11 80       	add    $0x80113540,%eax
80103b46:	83 ec 08             	sub    $0x8,%esp
80103b49:	68 d8 96 10 80       	push   $0x801096d8
80103b4e:	50                   	push   %eax
80103b4f:	e8 f9 1f 00 00       	call   80105b4d <initlock>
80103b54:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5a:	c1 e0 05             	shl    $0x5,%eax
80103b5d:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b62:	8b 50 0c             	mov    0xc(%eax),%edx
80103b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b68:	c1 e0 05             	shl    $0x5,%eax
80103b6b:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b70:	8b 00                	mov    (%eax),%eax
80103b72:	01 d0                	add    %edx,%eax
80103b74:	89 c2                	mov    %eax,%edx
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b7f:	05 70 35 11 80       	add    $0x80113570,%eax
80103b84:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8a:	c1 e0 05             	shl    $0x5,%eax
80103b8d:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103b92:	8b 40 0c             	mov    0xc(%eax),%eax
80103b95:	89 c2                	mov    %eax,%edx
80103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ba0:	05 70 35 11 80       	add    $0x80113570,%eax
80103ba5:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bb1:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103bba:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc0:	83 ec 0c             	sub    $0xc,%esp
80103bc3:	50                   	push   %eax
80103bc4:	e8 6a 02 00 00       	call   80103e33 <recover_from_log>
80103bc9:	83 c4 10             	add    $0x10,%esp
void
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
for(int i=0;i<NPARTITIONS;i++){
80103bcc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bd0:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103bd4:	0f 8e 5e ff ff ff    	jle    80103b38 <initlog+0x12>
  logs[i].size =  sbs[i].nlog;
  logs[i].dev = dev;
  recover_from_log(i);
}
 
}
80103bda:	90                   	nop
80103bdb:	c9                   	leave  
80103bdc:	c3                   	ret    

80103bdd <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103bdd:	55                   	push   %ebp
80103bde:	89 e5                	mov    %esp,%ebp
80103be0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103be3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bea:	e9 c0 00 00 00       	jmp    80103caf <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103bef:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bf8:	05 70 35 11 80       	add    $0x80113570,%eax
80103bfd:	8b 50 04             	mov    0x4(%eax),%edx
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	01 d0                	add    %edx,%eax
80103c05:	83 c0 01             	add    $0x1,%eax
80103c08:	89 c2                	mov    %eax,%edx
80103c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c0d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c13:	05 80 35 11 80       	add    $0x80113580,%eax
80103c18:	8b 40 04             	mov    0x4(%eax),%eax
80103c1b:	83 ec 08             	sub    $0x8,%esp
80103c1e:	52                   	push   %edx
80103c1f:	50                   	push   %eax
80103c20:	e8 91 c5 ff ff       	call   801001b6 <bread>
80103c25:	83 c4 10             	add    $0x10,%esp
80103c28:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c2e:	6b d0 31             	imul   $0x31,%eax,%edx
80103c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c34:	01 d0                	add    %edx,%eax
80103c36:	83 c0 10             	add    $0x10,%eax
80103c39:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c40:	89 c2                	mov    %eax,%edx
80103c42:	8b 45 08             	mov    0x8(%ebp),%eax
80103c45:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c4b:	05 80 35 11 80       	add    $0x80113580,%eax
80103c50:	8b 40 04             	mov    0x4(%eax),%eax
80103c53:	83 ec 08             	sub    $0x8,%esp
80103c56:	52                   	push   %edx
80103c57:	50                   	push   %eax
80103c58:	e8 59 c5 ff ff       	call   801001b6 <bread>
80103c5d:	83 c4 10             	add    $0x10,%esp
80103c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c66:	8d 50 18             	lea    0x18(%eax),%edx
80103c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c6c:	83 c0 18             	add    $0x18,%eax
80103c6f:	83 ec 04             	sub    $0x4,%esp
80103c72:	68 00 02 00 00       	push   $0x200
80103c77:	52                   	push   %edx
80103c78:	50                   	push   %eax
80103c79:	e8 13 22 00 00       	call   80105e91 <memmove>
80103c7e:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	ff 75 ec             	pushl  -0x14(%ebp)
80103c87:	e8 63 c5 ff ff       	call   801001ef <bwrite>
80103c8c:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103c8f:	83 ec 0c             	sub    $0xc,%esp
80103c92:	ff 75 f0             	pushl  -0x10(%ebp)
80103c95:	e8 94 c5 ff ff       	call   8010022e <brelse>
80103c9a:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103c9d:	83 ec 0c             	sub    $0xc,%esp
80103ca0:	ff 75 ec             	pushl  -0x14(%ebp)
80103ca3:	e8 86 c5 ff ff       	call   8010022e <brelse>
80103ca8:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103cab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103caf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cb8:	05 80 35 11 80       	add    $0x80113580,%eax
80103cbd:	8b 40 08             	mov    0x8(%eax),%eax
80103cc0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cc3:	0f 8f 26 ff ff ff    	jg     80103bef <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103cc9:	90                   	nop
80103cca:	c9                   	leave  
80103ccb:	c3                   	ret    

80103ccc <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103ccc:	55                   	push   %ebp
80103ccd:	89 e5                	mov    %esp,%ebp
80103ccf:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cdb:	05 70 35 11 80       	add    $0x80113570,%eax
80103ce0:	8b 40 04             	mov    0x4(%eax),%eax
80103ce3:	89 c2                	mov    %eax,%edx
80103ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cee:	05 80 35 11 80       	add    $0x80113580,%eax
80103cf3:	8b 40 04             	mov    0x4(%eax),%eax
80103cf6:	83 ec 08             	sub    $0x8,%esp
80103cf9:	52                   	push   %edx
80103cfa:	50                   	push   %eax
80103cfb:	e8 b6 c4 ff ff       	call   801001b6 <bread>
80103d00:	83 c4 10             	add    $0x10,%esp
80103d03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d09:	83 c0 18             	add    $0x18,%eax
80103d0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d12:	8b 00                	mov    (%eax),%eax
80103d14:	8b 55 08             	mov    0x8(%ebp),%edx
80103d17:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d1d:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d23:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d2d:	eb 23                	jmp    80103d52 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d35:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d39:	8b 55 08             	mov    0x8(%ebp),%edx
80103d3c:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d42:	01 ca                	add    %ecx,%edx
80103d44:	83 c2 10             	add    $0x10,%edx
80103d47:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d52:	8b 45 08             	mov    0x8(%ebp),%eax
80103d55:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d5b:	05 80 35 11 80       	add    $0x80113580,%eax
80103d60:	8b 40 08             	mov    0x8(%eax),%eax
80103d63:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d66:	7f c7                	jg     80103d2f <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d68:	83 ec 0c             	sub    $0xc,%esp
80103d6b:	ff 75 f0             	pushl  -0x10(%ebp)
80103d6e:	e8 bb c4 ff ff       	call   8010022e <brelse>
80103d73:	83 c4 10             	add    $0x10,%esp
}
80103d76:	90                   	nop
80103d77:	c9                   	leave  
80103d78:	c3                   	ret    

80103d79 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103d79:	55                   	push   %ebp
80103d7a:	89 e5                	mov    %esp,%ebp
80103d7c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d82:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d88:	05 70 35 11 80       	add    $0x80113570,%eax
80103d8d:	8b 40 04             	mov    0x4(%eax),%eax
80103d90:	89 c2                	mov    %eax,%edx
80103d92:	8b 45 08             	mov    0x8(%ebp),%eax
80103d95:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d9b:	05 80 35 11 80       	add    $0x80113580,%eax
80103da0:	8b 40 04             	mov    0x4(%eax),%eax
80103da3:	83 ec 08             	sub    $0x8,%esp
80103da6:	52                   	push   %edx
80103da7:	50                   	push   %eax
80103da8:	e8 09 c4 ff ff       	call   801001b6 <bread>
80103dad:	83 c4 10             	add    $0x10,%esp
80103db0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db6:	83 c0 18             	add    $0x18,%eax
80103db9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbf:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dc5:	05 80 35 11 80       	add    $0x80113580,%eax
80103dca:	8b 50 08             	mov    0x8(%eax),%edx
80103dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dd0:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103dd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dd9:	eb 23                	jmp    80103dfe <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dde:	6b d0 31             	imul   $0x31,%eax,%edx
80103de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de4:	01 d0                	add    %edx,%eax
80103de6:	83 c0 10             	add    $0x10,%eax
80103de9:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103df0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103df3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103df6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103dfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80103e01:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e07:	05 80 35 11 80       	add    $0x80113580,%eax
80103e0c:	8b 40 08             	mov    0x8(%eax),%eax
80103e0f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e12:	7f c7                	jg     80103ddb <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	ff 75 f0             	pushl  -0x10(%ebp)
80103e1a:	e8 d0 c3 ff ff       	call   801001ef <bwrite>
80103e1f:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	ff 75 f0             	pushl  -0x10(%ebp)
80103e28:	e8 01 c4 ff ff       	call   8010022e <brelse>
80103e2d:	83 c4 10             	add    $0x10,%esp
}
80103e30:	90                   	nop
80103e31:	c9                   	leave  
80103e32:	c3                   	ret    

80103e33 <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e33:	55                   	push   %ebp
80103e34:	89 e5                	mov    %esp,%ebp
80103e36:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e39:	83 ec 0c             	sub    $0xc,%esp
80103e3c:	ff 75 08             	pushl  0x8(%ebp)
80103e3f:	e8 88 fe ff ff       	call   80103ccc <read_head>
80103e44:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e47:	83 ec 0c             	sub    $0xc,%esp
80103e4a:	ff 75 08             	pushl  0x8(%ebp)
80103e4d:	e8 8b fd ff ff       	call   80103bdd <install_trans>
80103e52:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e55:	8b 45 08             	mov    0x8(%ebp),%eax
80103e58:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e5e:	05 80 35 11 80       	add    $0x80113580,%eax
80103e63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103e6a:	83 ec 0c             	sub    $0xc,%esp
80103e6d:	ff 75 08             	pushl  0x8(%ebp)
80103e70:	e8 04 ff ff ff       	call   80103d79 <write_head>
80103e75:	83 c4 10             	add    $0x10,%esp
}
80103e78:	90                   	nop
80103e79:	c9                   	leave  
80103e7a:	c3                   	ret    

80103e7b <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103e7b:	55                   	push   %ebp
80103e7c:	89 e5                	mov    %esp,%ebp
80103e7e:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103e81:	8b 45 08             	mov    0x8(%ebp),%eax
80103e84:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e8a:	05 40 35 11 80       	add    $0x80113540,%eax
80103e8f:	83 ec 0c             	sub    $0xc,%esp
80103e92:	50                   	push   %eax
80103e93:	e8 d7 1c 00 00       	call   80105b6f <acquire>
80103e98:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ea4:	05 80 35 11 80       	add    $0x80113580,%eax
80103ea9:	8b 00                	mov    (%eax),%eax
80103eab:	85 c0                	test   %eax,%eax
80103ead:	74 2c                	je     80103edb <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eb8:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ec7:	05 40 35 11 80       	add    $0x80113540,%eax
80103ecc:	83 ec 08             	sub    $0x8,%esp
80103ecf:	52                   	push   %edx
80103ed0:	50                   	push   %eax
80103ed1:	e8 a0 19 00 00       	call   80105876 <sleep>
80103ed6:	83 c4 10             	add    $0x10,%esp
80103ed9:	eb c0                	jmp    80103e9b <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103edb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ede:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ee4:	05 80 35 11 80       	add    $0x80113580,%eax
80103ee9:	8b 48 08             	mov    0x8(%eax),%ecx
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ef5:	05 70 35 11 80       	add    $0x80113570,%eax
80103efa:	8b 40 0c             	mov    0xc(%eax),%eax
80103efd:	8d 50 01             	lea    0x1(%eax),%edx
80103f00:	89 d0                	mov    %edx,%eax
80103f02:	c1 e0 02             	shl    $0x2,%eax
80103f05:	01 d0                	add    %edx,%eax
80103f07:	01 c0                	add    %eax,%eax
80103f09:	01 c8                	add    %ecx,%eax
80103f0b:	83 f8 1e             	cmp    $0x1e,%eax
80103f0e:	7e 2f                	jle    80103f3f <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f10:	8b 45 08             	mov    0x8(%ebp),%eax
80103f13:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f19:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f22:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f28:	05 40 35 11 80       	add    $0x80113540,%eax
80103f2d:	83 ec 08             	sub    $0x8,%esp
80103f30:	52                   	push   %edx
80103f31:	50                   	push   %eax
80103f32:	e8 3f 19 00 00       	call   80105876 <sleep>
80103f37:	83 c4 10             	add    $0x10,%esp
80103f3a:	e9 5c ff ff ff       	jmp    80103e9b <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f42:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f48:	05 70 35 11 80       	add    $0x80113570,%eax
80103f4d:	8b 40 0c             	mov    0xc(%eax),%eax
80103f50:	8d 50 01             	lea    0x1(%eax),%edx
80103f53:	8b 45 08             	mov    0x8(%ebp),%eax
80103f56:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f5c:	05 70 35 11 80       	add    $0x80113570,%eax
80103f61:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103f64:	8b 45 08             	mov    0x8(%ebp),%eax
80103f67:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f6d:	05 40 35 11 80       	add    $0x80113540,%eax
80103f72:	83 ec 0c             	sub    $0xc,%esp
80103f75:	50                   	push   %eax
80103f76:	e8 5b 1c 00 00       	call   80105bd6 <release>
80103f7b:	83 c4 10             	add    $0x10,%esp
      break;
80103f7e:	90                   	nop
    }
  }
}
80103f7f:	90                   	nop
80103f80:	c9                   	leave  
80103f81:	c3                   	ret    

80103f82 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103f82:	55                   	push   %ebp
80103f83:	89 e5                	mov    %esp,%ebp
80103f85:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103f88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f92:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f98:	05 40 35 11 80       	add    $0x80113540,%eax
80103f9d:	83 ec 0c             	sub    $0xc,%esp
80103fa0:	50                   	push   %eax
80103fa1:	e8 c9 1b 00 00       	call   80105b6f <acquire>
80103fa6:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fac:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fb2:	05 70 35 11 80       	add    $0x80113570,%eax
80103fb7:	8b 40 0c             	mov    0xc(%eax),%eax
80103fba:	8d 50 ff             	lea    -0x1(%eax),%edx
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fc6:	05 70 35 11 80       	add    $0x80113570,%eax
80103fcb:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80103fce:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fd7:	05 80 35 11 80       	add    $0x80113580,%eax
80103fdc:	8b 00                	mov    (%eax),%eax
80103fde:	85 c0                	test   %eax,%eax
80103fe0:	74 0d                	je     80103fef <end_op+0x6d>
    panic("log.committing");
80103fe2:	83 ec 0c             	sub    $0xc,%esp
80103fe5:	68 dc 96 10 80       	push   $0x801096dc
80103fea:	e8 77 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ff8:	05 70 35 11 80       	add    $0x80113570,%eax
80103ffd:	8b 40 0c             	mov    0xc(%eax),%eax
80104000:	85 c0                	test   %eax,%eax
80104002:	75 1d                	jne    80104021 <end_op+0x9f>
    do_commit = 1;
80104004:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
8010400b:	8b 45 08             	mov    0x8(%ebp),%eax
8010400e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104014:	05 80 35 11 80       	add    $0x80113580,%eax
80104019:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
8010401f:	eb 1a                	jmp    8010403b <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
80104021:	8b 45 08             	mov    0x8(%ebp),%eax
80104024:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010402a:	05 40 35 11 80       	add    $0x80113540,%eax
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	50                   	push   %eax
80104033:	e8 29 19 00 00       	call   80105961 <wakeup>
80104038:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104044:	05 40 35 11 80       	add    $0x80113540,%eax
80104049:	83 ec 0c             	sub    $0xc,%esp
8010404c:	50                   	push   %eax
8010404d:	e8 84 1b 00 00       	call   80105bd6 <release>
80104052:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80104055:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104059:	74 70                	je     801040cb <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
8010405b:	83 ec 0c             	sub    $0xc,%esp
8010405e:	ff 75 08             	pushl  0x8(%ebp)
80104061:	e8 57 01 00 00       	call   801041bd <commit>
80104066:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104072:	05 40 35 11 80       	add    $0x80113540,%eax
80104077:	83 ec 0c             	sub    $0xc,%esp
8010407a:	50                   	push   %eax
8010407b:	e8 ef 1a 00 00       	call   80105b6f <acquire>
80104080:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
80104083:	8b 45 08             	mov    0x8(%ebp),%eax
80104086:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010408c:	05 80 35 11 80       	add    $0x80113580,%eax
80104091:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
80104097:	8b 45 08             	mov    0x8(%ebp),%eax
8010409a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040a0:	05 40 35 11 80       	add    $0x80113540,%eax
801040a5:	83 ec 0c             	sub    $0xc,%esp
801040a8:	50                   	push   %eax
801040a9:	e8 b3 18 00 00       	call   80105961 <wakeup>
801040ae:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040b1:	8b 45 08             	mov    0x8(%ebp),%eax
801040b4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040ba:	05 40 35 11 80       	add    $0x80113540,%eax
801040bf:	83 ec 0c             	sub    $0xc,%esp
801040c2:	50                   	push   %eax
801040c3:	e8 0e 1b 00 00       	call   80105bd6 <release>
801040c8:	83 c4 10             	add    $0x10,%esp
  }
}
801040cb:	90                   	nop
801040cc:	c9                   	leave  
801040cd:	c3                   	ret    

801040ce <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
801040ce:	55                   	push   %ebp
801040cf:	89 e5                	mov    %esp,%ebp
801040d1:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801040d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040db:	e9 c0 00 00 00       	jmp    801041a0 <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
801040e0:	8b 45 08             	mov    0x8(%ebp),%eax
801040e3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040e9:	05 70 35 11 80       	add    $0x80113570,%eax
801040ee:	8b 50 04             	mov    0x4(%eax),%edx
801040f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f4:	01 d0                	add    %edx,%eax
801040f6:	83 c0 01             	add    $0x1,%eax
801040f9:	89 c2                	mov    %eax,%edx
801040fb:	8b 45 08             	mov    0x8(%ebp),%eax
801040fe:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104104:	05 80 35 11 80       	add    $0x80113580,%eax
80104109:	8b 40 04             	mov    0x4(%eax),%eax
8010410c:	83 ec 08             	sub    $0x8,%esp
8010410f:	52                   	push   %edx
80104110:	50                   	push   %eax
80104111:	e8 a0 c0 ff ff       	call   801001b6 <bread>
80104116:	83 c4 10             	add    $0x10,%esp
80104119:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
8010411c:	8b 45 08             	mov    0x8(%ebp),%eax
8010411f:	6b d0 31             	imul   $0x31,%eax,%edx
80104122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104125:	01 d0                	add    %edx,%eax
80104127:	83 c0 10             	add    $0x10,%eax
8010412a:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104131:	89 c2                	mov    %eax,%edx
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010413c:	05 80 35 11 80       	add    $0x80113580,%eax
80104141:	8b 40 04             	mov    0x4(%eax),%eax
80104144:	83 ec 08             	sub    $0x8,%esp
80104147:	52                   	push   %edx
80104148:	50                   	push   %eax
80104149:	e8 68 c0 ff ff       	call   801001b6 <bread>
8010414e:	83 c4 10             	add    $0x10,%esp
80104151:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80104154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104157:	8d 50 18             	lea    0x18(%eax),%edx
8010415a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010415d:	83 c0 18             	add    $0x18,%eax
80104160:	83 ec 04             	sub    $0x4,%esp
80104163:	68 00 02 00 00       	push   $0x200
80104168:	52                   	push   %edx
80104169:	50                   	push   %eax
8010416a:	e8 22 1d 00 00       	call   80105e91 <memmove>
8010416f:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80104172:	83 ec 0c             	sub    $0xc,%esp
80104175:	ff 75 f0             	pushl  -0x10(%ebp)
80104178:	e8 72 c0 ff ff       	call   801001ef <bwrite>
8010417d:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80104180:	83 ec 0c             	sub    $0xc,%esp
80104183:	ff 75 ec             	pushl  -0x14(%ebp)
80104186:	e8 a3 c0 ff ff       	call   8010022e <brelse>
8010418b:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010418e:	83 ec 0c             	sub    $0xc,%esp
80104191:	ff 75 f0             	pushl  -0x10(%ebp)
80104194:	e8 95 c0 ff ff       	call   8010022e <brelse>
80104199:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
8010419c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041a0:	8b 45 08             	mov    0x8(%ebp),%eax
801041a3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041a9:	05 80 35 11 80       	add    $0x80113580,%eax
801041ae:	8b 40 08             	mov    0x8(%eax),%eax
801041b1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041b4:	0f 8f 26 ff ff ff    	jg     801040e0 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041ba:	90                   	nop
801041bb:	c9                   	leave  
801041bc:	c3                   	ret    

801041bd <commit>:

static void
commit(uint partitionNumber)
{
801041bd:	55                   	push   %ebp
801041be:	89 e5                	mov    %esp,%ebp
801041c0:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
801041c3:	8b 45 08             	mov    0x8(%ebp),%eax
801041c6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041cc:	05 80 35 11 80       	add    $0x80113580,%eax
801041d1:	8b 40 08             	mov    0x8(%eax),%eax
801041d4:	85 c0                	test   %eax,%eax
801041d6:	7e 4d                	jle    80104225 <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
801041d8:	83 ec 0c             	sub    $0xc,%esp
801041db:	ff 75 08             	pushl  0x8(%ebp)
801041de:	e8 eb fe ff ff       	call   801040ce <write_log>
801041e3:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
801041e6:	83 ec 0c             	sub    $0xc,%esp
801041e9:	ff 75 08             	pushl  0x8(%ebp)
801041ec:	e8 88 fb ff ff       	call   80103d79 <write_head>
801041f1:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	ff 75 08             	pushl  0x8(%ebp)
801041fa:	e8 de f9 ff ff       	call   80103bdd <install_trans>
801041ff:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104202:	8b 45 08             	mov    0x8(%ebp),%eax
80104205:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010420b:	05 80 35 11 80       	add    $0x80113580,%eax
80104210:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
80104217:	83 ec 0c             	sub    $0xc,%esp
8010421a:	ff 75 08             	pushl  0x8(%ebp)
8010421d:	e8 57 fb ff ff       	call   80103d79 <write_head>
80104222:	83 c4 10             	add    $0x10,%esp
  }
}
80104225:	90                   	nop
80104226:	c9                   	leave  
80104227:	c3                   	ret    

80104228 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
80104228:	55                   	push   %ebp
80104229:	89 e5                	mov    %esp,%ebp
8010422b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
8010422e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104231:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104237:	05 80 35 11 80       	add    $0x80113580,%eax
8010423c:	8b 40 08             	mov    0x8(%eax),%eax
8010423f:	83 f8 1d             	cmp    $0x1d,%eax
80104242:	7f 2a                	jg     8010426e <log_write+0x46>
80104244:	8b 45 0c             	mov    0xc(%ebp),%eax
80104247:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010424d:	05 80 35 11 80       	add    $0x80113580,%eax
80104252:	8b 40 08             	mov    0x8(%eax),%eax
80104255:	8b 55 0c             	mov    0xc(%ebp),%edx
80104258:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
8010425e:	81 c2 70 35 11 80    	add    $0x80113570,%edx
80104264:	8b 52 08             	mov    0x8(%edx),%edx
80104267:	83 ea 01             	sub    $0x1,%edx
8010426a:	39 d0                	cmp    %edx,%eax
8010426c:	7c 0d                	jl     8010427b <log_write+0x53>
    panic("too big a transaction");
8010426e:	83 ec 0c             	sub    $0xc,%esp
80104271:	68 eb 96 10 80       	push   $0x801096eb
80104276:	e8 eb c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
8010427b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104284:	05 70 35 11 80       	add    $0x80113570,%eax
80104289:	8b 40 0c             	mov    0xc(%eax),%eax
8010428c:	85 c0                	test   %eax,%eax
8010428e:	7f 0d                	jg     8010429d <log_write+0x75>
    panic("log_write outside of trans");
80104290:	83 ec 0c             	sub    $0xc,%esp
80104293:	68 01 97 10 80       	push   $0x80109701
80104298:	e8 c9 c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
8010429d:	8b 45 0c             	mov    0xc(%ebp),%eax
801042a0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042a6:	05 40 35 11 80       	add    $0x80113540,%eax
801042ab:	83 ec 0c             	sub    $0xc,%esp
801042ae:	50                   	push   %eax
801042af:	e8 bb 18 00 00       	call   80105b6f <acquire>
801042b4:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042be:	eb 25                	jmp    801042e5 <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801042c3:	6b d0 31             	imul   $0x31,%eax,%edx
801042c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c9:	01 d0                	add    %edx,%eax
801042cb:	83 c0 10             	add    $0x10,%eax
801042ce:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
801042d5:	89 c2                	mov    %eax,%edx
801042d7:	8b 45 08             	mov    0x8(%ebp),%eax
801042da:	8b 40 08             	mov    0x8(%eax),%eax
801042dd:	39 c2                	cmp    %eax,%edx
801042df:	74 1c                	je     801042fd <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801042e8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042ee:	05 80 35 11 80       	add    $0x80113580,%eax
801042f3:	8b 40 08             	mov    0x8(%eax),%eax
801042f6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801042f9:	7f c5                	jg     801042c0 <log_write+0x98>
801042fb:	eb 01                	jmp    801042fe <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
801042fd:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
801042fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104301:	8b 40 08             	mov    0x8(%eax),%eax
80104304:	89 c1                	mov    %eax,%ecx
80104306:	8b 45 0c             	mov    0xc(%ebp),%eax
80104309:	6b d0 31             	imul   $0x31,%eax,%edx
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	01 d0                	add    %edx,%eax
80104311:	83 c0 10             	add    $0x10,%eax
80104314:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
8010431b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104324:	05 80 35 11 80       	add    $0x80113580,%eax
80104329:	8b 40 08             	mov    0x8(%eax),%eax
8010432c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010432f:	75 25                	jne    80104356 <log_write+0x12e>
    logs[partitionNumber].lh.n++;
80104331:	8b 45 0c             	mov    0xc(%ebp),%eax
80104334:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010433a:	05 80 35 11 80       	add    $0x80113580,%eax
8010433f:	8b 40 08             	mov    0x8(%eax),%eax
80104342:	8d 50 01             	lea    0x1(%eax),%edx
80104345:	8b 45 0c             	mov    0xc(%ebp),%eax
80104348:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010434e:	05 80 35 11 80       	add    $0x80113580,%eax
80104353:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
80104356:	8b 45 08             	mov    0x8(%ebp),%eax
80104359:	8b 00                	mov    (%eax),%eax
8010435b:	83 c8 04             	or     $0x4,%eax
8010435e:	89 c2                	mov    %eax,%edx
80104360:	8b 45 08             	mov    0x8(%ebp),%eax
80104363:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
80104365:	8b 45 0c             	mov    0xc(%ebp),%eax
80104368:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010436e:	05 40 35 11 80       	add    $0x80113540,%eax
80104373:	83 ec 0c             	sub    $0xc,%esp
80104376:	50                   	push   %eax
80104377:	e8 5a 18 00 00       	call   80105bd6 <release>
8010437c:	83 c4 10             	add    $0x10,%esp
}
8010437f:	90                   	nop
80104380:	c9                   	leave  
80104381:	c3                   	ret    

80104382 <v2p>:
80104382:	55                   	push   %ebp
80104383:	89 e5                	mov    %esp,%ebp
80104385:	8b 45 08             	mov    0x8(%ebp),%eax
80104388:	05 00 00 00 80       	add    $0x80000000,%eax
8010438d:	5d                   	pop    %ebp
8010438e:	c3                   	ret    

8010438f <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010438f:	55                   	push   %ebp
80104390:	89 e5                	mov    %esp,%ebp
80104392:	8b 45 08             	mov    0x8(%ebp),%eax
80104395:	05 00 00 00 80       	add    $0x80000000,%eax
8010439a:	5d                   	pop    %ebp
8010439b:	c3                   	ret    

8010439c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010439c:	55                   	push   %ebp
8010439d:	89 e5                	mov    %esp,%ebp
8010439f:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043a2:	8b 55 08             	mov    0x8(%ebp),%edx
801043a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043ab:	f0 87 02             	lock xchg %eax,(%edx)
801043ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043b4:	c9                   	leave  
801043b5:	c3                   	ret    

801043b6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043b6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043ba:	83 e4 f0             	and    $0xfffffff0,%esp
801043bd:	ff 71 fc             	pushl  -0x4(%ecx)
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	51                   	push   %ecx
801043c4:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801043c7:	83 ec 08             	sub    $0x8,%esp
801043ca:	68 00 00 40 80       	push   $0x80400000
801043cf:	68 5c 66 11 80       	push   $0x8011665c
801043d4:	e8 4d ef ff ff       	call   80103326 <kinit1>
801043d9:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801043dc:	e8 2d 48 00 00       	call   80108c0e <kvmalloc>
  mpinit();        // collect info about this machine
801043e1:	e8 26 04 00 00       	call   8010480c <mpinit>
  lapicinit();
801043e6:	e8 ba f2 ff ff       	call   801036a5 <lapicinit>
  seginit();       // set up segments
801043eb:	e8 c7 41 00 00       	call   801085b7 <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
801043f0:	e8 6d 06 00 00       	call   80104a62 <picinit>
  ioapicinit();    // another interrupt controller
801043f5:	e8 21 ee ff ff       	call   8010321b <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801043fa:	e8 1a c7 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
801043ff:	e8 0f 35 00 00       	call   80107913 <uartinit>
  pinit();         // process table
80104404:	e8 56 0b 00 00       	call   80104f5f <pinit>
  tvinit();        // trap vectors
80104409:	e8 cf 30 00 00       	call   801074dd <tvinit>
  binit();         // buffer cache
8010440e:	e8 21 bc ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80104413:	e8 b5 cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
80104418:	e8 e6 e9 ff ff       	call   80102e03 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
8010441d:	a1 64 38 11 80       	mov    0x80113864,%eax
80104422:	85 c0                	test   %eax,%eax
80104424:	75 05                	jne    8010442b <main+0x75>
    timerinit();   // uniprocessor timer
80104426:	e8 0f 30 00 00       	call   8010743a <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
8010442b:	e8 7f 00 00 00       	call   801044af <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104430:	83 ec 08             	sub    $0x8,%esp
80104433:	68 00 00 00 8e       	push   $0x8e000000
80104438:	68 00 00 40 80       	push   $0x80400000
8010443d:	e8 1d ef ff ff       	call   8010335f <kinit2>
80104442:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
80104445:	e8 39 0c 00 00       	call   80105083 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
8010444a:	e8 1a 00 00 00       	call   80104469 <mpmain>

8010444f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010444f:	55                   	push   %ebp
80104450:	89 e5                	mov    %esp,%ebp
80104452:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104455:	e8 cc 47 00 00       	call   80108c26 <switchkvm>
  seginit();
8010445a:	e8 58 41 00 00       	call   801085b7 <seginit>
  lapicinit();
8010445f:	e8 41 f2 ff ff       	call   801036a5 <lapicinit>
  mpmain();
80104464:	e8 00 00 00 00       	call   80104469 <mpmain>

80104469 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104469:	55                   	push   %ebp
8010446a:	89 e5                	mov    %esp,%ebp
8010446c:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010446f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104475:	0f b6 00             	movzbl (%eax),%eax
80104478:	0f b6 c0             	movzbl %al,%eax
8010447b:	83 ec 08             	sub    $0x8,%esp
8010447e:	50                   	push   %eax
8010447f:	68 1c 97 10 80       	push   $0x8010971c
80104484:	e8 3d bf ff ff       	call   801003c6 <cprintf>
80104489:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010448c:	e8 c2 31 00 00       	call   80107653 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80104491:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104497:	05 a8 00 00 00       	add    $0xa8,%eax
8010449c:	83 ec 08             	sub    $0x8,%esp
8010449f:	6a 01                	push   $0x1
801044a1:	50                   	push   %eax
801044a2:	e8 f5 fe ff ff       	call   8010439c <xchg>
801044a7:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044aa:	e8 ab 11 00 00       	call   8010565a <scheduler>

801044af <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044af:	55                   	push   %ebp
801044b0:	89 e5                	mov    %esp,%ebp
801044b2:	53                   	push   %ebx
801044b3:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044b6:	68 00 70 00 00       	push   $0x7000
801044bb:	e8 cf fe ff ff       	call   8010438f <p2v>
801044c0:	83 c4 04             	add    $0x4,%esp
801044c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801044c6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801044cb:	83 ec 04             	sub    $0x4,%esp
801044ce:	50                   	push   %eax
801044cf:	68 0c c5 10 80       	push   $0x8010c50c
801044d4:	ff 75 f0             	pushl  -0x10(%ebp)
801044d7:	e8 b5 19 00 00       	call   80105e91 <memmove>
801044dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801044df:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
801044e6:	e9 90 00 00 00       	jmp    8010457b <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801044eb:	e8 d3 f2 ff ff       	call   801037c3 <cpunum>
801044f0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801044f6:	05 80 38 11 80       	add    $0x80113880,%eax
801044fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801044fe:	74 73                	je     80104573 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104500:	e8 58 ef ff ff       	call   8010345d <kalloc>
80104505:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450b:	83 e8 04             	sub    $0x4,%eax
8010450e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104511:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104517:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010451c:	83 e8 08             	sub    $0x8,%eax
8010451f:	c7 00 4f 44 10 80    	movl   $0x8010444f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104528:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010452b:	83 ec 0c             	sub    $0xc,%esp
8010452e:	68 00 b0 10 80       	push   $0x8010b000
80104533:	e8 4a fe ff ff       	call   80104382 <v2p>
80104538:	83 c4 10             	add    $0x10,%esp
8010453b:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010453d:	83 ec 0c             	sub    $0xc,%esp
80104540:	ff 75 f0             	pushl  -0x10(%ebp)
80104543:	e8 3a fe ff ff       	call   80104382 <v2p>
80104548:	83 c4 10             	add    $0x10,%esp
8010454b:	89 c2                	mov    %eax,%edx
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	0f b6 00             	movzbl (%eax),%eax
80104553:	0f b6 c0             	movzbl %al,%eax
80104556:	83 ec 08             	sub    $0x8,%esp
80104559:	52                   	push   %edx
8010455a:	50                   	push   %eax
8010455b:	e8 dd f2 ff ff       	call   8010383d <lapicstartap>
80104560:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104563:	90                   	nop
80104564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104567:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010456d:	85 c0                	test   %eax,%eax
8010456f:	74 f3                	je     80104564 <startothers+0xb5>
80104571:	eb 01                	jmp    80104574 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80104573:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80104574:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010457b:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104580:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104586:	05 80 38 11 80       	add    $0x80113880,%eax
8010458b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010458e:	0f 87 57 ff ff ff    	ja     801044eb <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80104594:	90                   	nop
80104595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104598:	c9                   	leave  
80104599:	c3                   	ret    

8010459a <p2v>:
8010459a:	55                   	push   %ebp
8010459b:	89 e5                	mov    %esp,%ebp
8010459d:	8b 45 08             	mov    0x8(%ebp),%eax
801045a0:	05 00 00 00 80       	add    $0x80000000,%eax
801045a5:	5d                   	pop    %ebp
801045a6:	c3                   	ret    

801045a7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045a7:	55                   	push   %ebp
801045a8:	89 e5                	mov    %esp,%ebp
801045aa:	83 ec 14             	sub    $0x14,%esp
801045ad:	8b 45 08             	mov    0x8(%ebp),%eax
801045b0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045b4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045b8:	89 c2                	mov    %eax,%edx
801045ba:	ec                   	in     (%dx),%al
801045bb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045be:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801045c2:	c9                   	leave  
801045c3:	c3                   	ret    

801045c4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045c4:	55                   	push   %ebp
801045c5:	89 e5                	mov    %esp,%ebp
801045c7:	83 ec 08             	sub    $0x8,%esp
801045ca:	8b 55 08             	mov    0x8(%ebp),%edx
801045cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801045d0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045d4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045d7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801045db:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801045df:	ee                   	out    %al,(%dx)
}
801045e0:	90                   	nop
801045e1:	c9                   	leave  
801045e2:	c3                   	ret    

801045e3 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801045e3:	55                   	push   %ebp
801045e4:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801045e6:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801045eb:	89 c2                	mov    %eax,%edx
801045ed:	b8 80 38 11 80       	mov    $0x80113880,%eax
801045f2:	29 c2                	sub    %eax,%edx
801045f4:	89 d0                	mov    %edx,%eax
801045f6:	c1 f8 02             	sar    $0x2,%eax
801045f9:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801045ff:	5d                   	pop    %ebp
80104600:	c3                   	ret    

80104601 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104601:	55                   	push   %ebp
80104602:	89 e5                	mov    %esp,%ebp
80104604:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104607:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010460e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104615:	eb 15                	jmp    8010462c <sum+0x2b>
    sum += addr[i];
80104617:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010461a:	8b 45 08             	mov    0x8(%ebp),%eax
8010461d:	01 d0                	add    %edx,%eax
8010461f:	0f b6 00             	movzbl (%eax),%eax
80104622:	0f b6 c0             	movzbl %al,%eax
80104625:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104628:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010462c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010462f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104632:	7c e3                	jl     80104617 <sum+0x16>
    sum += addr[i];
  return sum;
80104634:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104637:	c9                   	leave  
80104638:	c3                   	ret    

80104639 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104639:	55                   	push   %ebp
8010463a:	89 e5                	mov    %esp,%ebp
8010463c:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010463f:	ff 75 08             	pushl  0x8(%ebp)
80104642:	e8 53 ff ff ff       	call   8010459a <p2v>
80104647:	83 c4 04             	add    $0x4,%esp
8010464a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010464d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104653:	01 d0                	add    %edx,%eax
80104655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010465b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010465e:	eb 36                	jmp    80104696 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104660:	83 ec 04             	sub    $0x4,%esp
80104663:	6a 04                	push   $0x4
80104665:	68 30 97 10 80       	push   $0x80109730
8010466a:	ff 75 f4             	pushl  -0xc(%ebp)
8010466d:	e8 c7 17 00 00       	call   80105e39 <memcmp>
80104672:	83 c4 10             	add    $0x10,%esp
80104675:	85 c0                	test   %eax,%eax
80104677:	75 19                	jne    80104692 <mpsearch1+0x59>
80104679:	83 ec 08             	sub    $0x8,%esp
8010467c:	6a 10                	push   $0x10
8010467e:	ff 75 f4             	pushl  -0xc(%ebp)
80104681:	e8 7b ff ff ff       	call   80104601 <sum>
80104686:	83 c4 10             	add    $0x10,%esp
80104689:	84 c0                	test   %al,%al
8010468b:	75 05                	jne    80104692 <mpsearch1+0x59>
      return (struct mp*)p;
8010468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104690:	eb 11                	jmp    801046a3 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80104692:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80104696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104699:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010469c:	72 c2                	jb     80104660 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
8010469e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046a3:	c9                   	leave  
801046a4:	c3                   	ret    

801046a5 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046a5:	55                   	push   %ebp
801046a6:	89 e5                	mov    %esp,%ebp
801046a8:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046ab:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b5:	83 c0 0f             	add    $0xf,%eax
801046b8:	0f b6 00             	movzbl (%eax),%eax
801046bb:	0f b6 c0             	movzbl %al,%eax
801046be:	c1 e0 08             	shl    $0x8,%eax
801046c1:	89 c2                	mov    %eax,%edx
801046c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c6:	83 c0 0e             	add    $0xe,%eax
801046c9:	0f b6 00             	movzbl (%eax),%eax
801046cc:	0f b6 c0             	movzbl %al,%eax
801046cf:	09 d0                	or     %edx,%eax
801046d1:	c1 e0 04             	shl    $0x4,%eax
801046d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801046d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801046db:	74 21                	je     801046fe <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801046dd:	83 ec 08             	sub    $0x8,%esp
801046e0:	68 00 04 00 00       	push   $0x400
801046e5:	ff 75 f0             	pushl  -0x10(%ebp)
801046e8:	e8 4c ff ff ff       	call   80104639 <mpsearch1>
801046ed:	83 c4 10             	add    $0x10,%esp
801046f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801046f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801046f7:	74 51                	je     8010474a <mpsearch+0xa5>
      return mp;
801046f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046fc:	eb 61                	jmp    8010475f <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801046fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104701:	83 c0 14             	add    $0x14,%eax
80104704:	0f b6 00             	movzbl (%eax),%eax
80104707:	0f b6 c0             	movzbl %al,%eax
8010470a:	c1 e0 08             	shl    $0x8,%eax
8010470d:	89 c2                	mov    %eax,%edx
8010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104712:	83 c0 13             	add    $0x13,%eax
80104715:	0f b6 00             	movzbl (%eax),%eax
80104718:	0f b6 c0             	movzbl %al,%eax
8010471b:	09 d0                	or     %edx,%eax
8010471d:	c1 e0 0a             	shl    $0xa,%eax
80104720:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104726:	2d 00 04 00 00       	sub    $0x400,%eax
8010472b:	83 ec 08             	sub    $0x8,%esp
8010472e:	68 00 04 00 00       	push   $0x400
80104733:	50                   	push   %eax
80104734:	e8 00 ff ff ff       	call   80104639 <mpsearch1>
80104739:	83 c4 10             	add    $0x10,%esp
8010473c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010473f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104743:	74 05                	je     8010474a <mpsearch+0xa5>
      return mp;
80104745:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104748:	eb 15                	jmp    8010475f <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
8010474a:	83 ec 08             	sub    $0x8,%esp
8010474d:	68 00 00 01 00       	push   $0x10000
80104752:	68 00 00 0f 00       	push   $0xf0000
80104757:	e8 dd fe ff ff       	call   80104639 <mpsearch1>
8010475c:	83 c4 10             	add    $0x10,%esp
}
8010475f:	c9                   	leave  
80104760:	c3                   	ret    

80104761 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104761:	55                   	push   %ebp
80104762:	89 e5                	mov    %esp,%ebp
80104764:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104767:	e8 39 ff ff ff       	call   801046a5 <mpsearch>
8010476c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010476f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104773:	74 0a                	je     8010477f <mpconfig+0x1e>
80104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104778:	8b 40 04             	mov    0x4(%eax),%eax
8010477b:	85 c0                	test   %eax,%eax
8010477d:	75 0a                	jne    80104789 <mpconfig+0x28>
    return 0;
8010477f:	b8 00 00 00 00       	mov    $0x0,%eax
80104784:	e9 81 00 00 00       	jmp    8010480a <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478c:	8b 40 04             	mov    0x4(%eax),%eax
8010478f:	83 ec 0c             	sub    $0xc,%esp
80104792:	50                   	push   %eax
80104793:	e8 02 fe ff ff       	call   8010459a <p2v>
80104798:	83 c4 10             	add    $0x10,%esp
8010479b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010479e:	83 ec 04             	sub    $0x4,%esp
801047a1:	6a 04                	push   $0x4
801047a3:	68 35 97 10 80       	push   $0x80109735
801047a8:	ff 75 f0             	pushl  -0x10(%ebp)
801047ab:	e8 89 16 00 00       	call   80105e39 <memcmp>
801047b0:	83 c4 10             	add    $0x10,%esp
801047b3:	85 c0                	test   %eax,%eax
801047b5:	74 07                	je     801047be <mpconfig+0x5d>
    return 0;
801047b7:	b8 00 00 00 00       	mov    $0x0,%eax
801047bc:	eb 4c                	jmp    8010480a <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047c1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047c5:	3c 01                	cmp    $0x1,%al
801047c7:	74 12                	je     801047db <mpconfig+0x7a>
801047c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047cc:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047d0:	3c 04                	cmp    $0x4,%al
801047d2:	74 07                	je     801047db <mpconfig+0x7a>
    return 0;
801047d4:	b8 00 00 00 00       	mov    $0x0,%eax
801047d9:	eb 2f                	jmp    8010480a <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801047db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047de:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801047e2:	0f b7 c0             	movzwl %ax,%eax
801047e5:	83 ec 08             	sub    $0x8,%esp
801047e8:	50                   	push   %eax
801047e9:	ff 75 f0             	pushl  -0x10(%ebp)
801047ec:	e8 10 fe ff ff       	call   80104601 <sum>
801047f1:	83 c4 10             	add    $0x10,%esp
801047f4:	84 c0                	test   %al,%al
801047f6:	74 07                	je     801047ff <mpconfig+0x9e>
    return 0;
801047f8:	b8 00 00 00 00       	mov    $0x0,%eax
801047fd:	eb 0b                	jmp    8010480a <mpconfig+0xa9>
  *pmp = mp;
801047ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104802:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104805:	89 10                	mov    %edx,(%eax)
  return conf;
80104807:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010480a:	c9                   	leave  
8010480b:	c3                   	ret    

8010480c <mpinit>:

void
mpinit(void)
{
8010480c:	55                   	push   %ebp
8010480d:	89 e5                	mov    %esp,%ebp
8010480f:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104812:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
80104819:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010481c:	83 ec 0c             	sub    $0xc,%esp
8010481f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104822:	50                   	push   %eax
80104823:	e8 39 ff ff ff       	call   80104761 <mpconfig>
80104828:	83 c4 10             	add    $0x10,%esp
8010482b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010482e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104832:	0f 84 96 01 00 00    	je     801049ce <mpinit+0x1c2>
    return;
  ismp = 1;
80104838:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
8010483f:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104842:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104845:	8b 40 24             	mov    0x24(%eax),%eax
80104848:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010484d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104850:	83 c0 2c             	add    $0x2c,%eax
80104853:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104859:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010485d:	0f b7 d0             	movzwl %ax,%edx
80104860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104863:	01 d0                	add    %edx,%eax
80104865:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104868:	e9 f2 00 00 00       	jmp    8010495f <mpinit+0x153>
    switch(*p){
8010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104870:	0f b6 00             	movzbl (%eax),%eax
80104873:	0f b6 c0             	movzbl %al,%eax
80104876:	83 f8 04             	cmp    $0x4,%eax
80104879:	0f 87 bc 00 00 00    	ja     8010493b <mpinit+0x12f>
8010487f:	8b 04 85 78 97 10 80 	mov    -0x7fef6888(,%eax,4),%eax
80104886:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010488e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104891:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104895:	0f b6 d0             	movzbl %al,%edx
80104898:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010489d:	39 c2                	cmp    %eax,%edx
8010489f:	74 2b                	je     801048cc <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048a4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048a8:	0f b6 d0             	movzbl %al,%edx
801048ab:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048b0:	83 ec 04             	sub    $0x4,%esp
801048b3:	52                   	push   %edx
801048b4:	50                   	push   %eax
801048b5:	68 3a 97 10 80       	push   $0x8010973a
801048ba:	e8 07 bb ff ff       	call   801003c6 <cprintf>
801048bf:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801048c2:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
801048c9:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801048cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048cf:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801048d3:	0f b6 c0             	movzbl %al,%eax
801048d6:	83 e0 02             	and    $0x2,%eax
801048d9:	85 c0                	test   %eax,%eax
801048db:	74 15                	je     801048f2 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801048dd:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048e2:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801048e8:	05 80 38 11 80       	add    $0x80113880,%eax
801048ed:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
801048f2:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048f7:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
801048fd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104903:	05 80 38 11 80       	add    $0x80113880,%eax
80104908:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010490a:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010490f:	83 c0 01             	add    $0x1,%eax
80104912:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
80104917:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010491b:	eb 42                	jmp    8010495f <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104923:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104926:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010492a:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
8010492f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104933:	eb 2a                	jmp    8010495f <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104935:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104939:	eb 24                	jmp    8010495f <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010493b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493e:	0f b6 00             	movzbl (%eax),%eax
80104941:	0f b6 c0             	movzbl %al,%eax
80104944:	83 ec 08             	sub    $0x8,%esp
80104947:	50                   	push   %eax
80104948:	68 58 97 10 80       	push   $0x80109758
8010494d:	e8 74 ba ff ff       	call   801003c6 <cprintf>
80104952:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104955:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
8010495c:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010495f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104962:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104965:	0f 82 02 ff ff ff    	jb     8010486d <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
8010496b:	a1 64 38 11 80       	mov    0x80113864,%eax
80104970:	85 c0                	test   %eax,%eax
80104972:	75 1d                	jne    80104991 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104974:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
8010497b:	00 00 00 
    lapic = 0;
8010497e:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
80104985:	00 00 00 
    ioapicid = 0;
80104988:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
8010498f:	eb 3e                	jmp    801049cf <mpinit+0x1c3>
  }

  if(mp->imcrp){
80104991:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104994:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104998:	84 c0                	test   %al,%al
8010499a:	74 33                	je     801049cf <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010499c:	83 ec 08             	sub    $0x8,%esp
8010499f:	6a 70                	push   $0x70
801049a1:	6a 22                	push   $0x22
801049a3:	e8 1c fc ff ff       	call   801045c4 <outb>
801049a8:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049ab:	83 ec 0c             	sub    $0xc,%esp
801049ae:	6a 23                	push   $0x23
801049b0:	e8 f2 fb ff ff       	call   801045a7 <inb>
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	83 c8 01             	or     $0x1,%eax
801049bb:	0f b6 c0             	movzbl %al,%eax
801049be:	83 ec 08             	sub    $0x8,%esp
801049c1:	50                   	push   %eax
801049c2:	6a 23                	push   $0x23
801049c4:	e8 fb fb ff ff       	call   801045c4 <outb>
801049c9:	83 c4 10             	add    $0x10,%esp
801049cc:	eb 01                	jmp    801049cf <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801049ce:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801049cf:	c9                   	leave  
801049d0:	c3                   	ret    

801049d1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801049d1:	55                   	push   %ebp
801049d2:	89 e5                	mov    %esp,%ebp
801049d4:	83 ec 08             	sub    $0x8,%esp
801049d7:	8b 55 08             	mov    0x8(%ebp),%edx
801049da:	8b 45 0c             	mov    0xc(%ebp),%eax
801049dd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801049e1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801049e4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801049e8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801049ec:	ee                   	out    %al,(%dx)
}
801049ed:	90                   	nop
801049ee:	c9                   	leave  
801049ef:	c3                   	ret    

801049f0 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801049f0:	55                   	push   %ebp
801049f1:	89 e5                	mov    %esp,%ebp
801049f3:	83 ec 04             	sub    $0x4,%esp
801049f6:	8b 45 08             	mov    0x8(%ebp),%eax
801049f9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801049fd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a01:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a07:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a0b:	0f b6 c0             	movzbl %al,%eax
80104a0e:	50                   	push   %eax
80104a0f:	6a 21                	push   $0x21
80104a11:	e8 bb ff ff ff       	call   801049d1 <outb>
80104a16:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a19:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a1d:	66 c1 e8 08          	shr    $0x8,%ax
80104a21:	0f b6 c0             	movzbl %al,%eax
80104a24:	50                   	push   %eax
80104a25:	68 a1 00 00 00       	push   $0xa1
80104a2a:	e8 a2 ff ff ff       	call   801049d1 <outb>
80104a2f:	83 c4 08             	add    $0x8,%esp
}
80104a32:	90                   	nop
80104a33:	c9                   	leave  
80104a34:	c3                   	ret    

80104a35 <picenable>:

void
picenable(int irq)
{
80104a35:	55                   	push   %ebp
80104a36:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a38:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3b:	ba 01 00 00 00       	mov    $0x1,%edx
80104a40:	89 c1                	mov    %eax,%ecx
80104a42:	d3 e2                	shl    %cl,%edx
80104a44:	89 d0                	mov    %edx,%eax
80104a46:	f7 d0                	not    %eax
80104a48:	89 c2                	mov    %eax,%edx
80104a4a:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a51:	21 d0                	and    %edx,%eax
80104a53:	0f b7 c0             	movzwl %ax,%eax
80104a56:	50                   	push   %eax
80104a57:	e8 94 ff ff ff       	call   801049f0 <picsetmask>
80104a5c:	83 c4 04             	add    $0x4,%esp
}
80104a5f:	90                   	nop
80104a60:	c9                   	leave  
80104a61:	c3                   	ret    

80104a62 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104a62:	55                   	push   %ebp
80104a63:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104a65:	68 ff 00 00 00       	push   $0xff
80104a6a:	6a 21                	push   $0x21
80104a6c:	e8 60 ff ff ff       	call   801049d1 <outb>
80104a71:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104a74:	68 ff 00 00 00       	push   $0xff
80104a79:	68 a1 00 00 00       	push   $0xa1
80104a7e:	e8 4e ff ff ff       	call   801049d1 <outb>
80104a83:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104a86:	6a 11                	push   $0x11
80104a88:	6a 20                	push   $0x20
80104a8a:	e8 42 ff ff ff       	call   801049d1 <outb>
80104a8f:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104a92:	6a 20                	push   $0x20
80104a94:	6a 21                	push   $0x21
80104a96:	e8 36 ff ff ff       	call   801049d1 <outb>
80104a9b:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104a9e:	6a 04                	push   $0x4
80104aa0:	6a 21                	push   $0x21
80104aa2:	e8 2a ff ff ff       	call   801049d1 <outb>
80104aa7:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104aaa:	6a 03                	push   $0x3
80104aac:	6a 21                	push   $0x21
80104aae:	e8 1e ff ff ff       	call   801049d1 <outb>
80104ab3:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104ab6:	6a 11                	push   $0x11
80104ab8:	68 a0 00 00 00       	push   $0xa0
80104abd:	e8 0f ff ff ff       	call   801049d1 <outb>
80104ac2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104ac5:	6a 28                	push   $0x28
80104ac7:	68 a1 00 00 00       	push   $0xa1
80104acc:	e8 00 ff ff ff       	call   801049d1 <outb>
80104ad1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104ad4:	6a 02                	push   $0x2
80104ad6:	68 a1 00 00 00       	push   $0xa1
80104adb:	e8 f1 fe ff ff       	call   801049d1 <outb>
80104ae0:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104ae3:	6a 03                	push   $0x3
80104ae5:	68 a1 00 00 00       	push   $0xa1
80104aea:	e8 e2 fe ff ff       	call   801049d1 <outb>
80104aef:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104af2:	6a 68                	push   $0x68
80104af4:	6a 20                	push   $0x20
80104af6:	e8 d6 fe ff ff       	call   801049d1 <outb>
80104afb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104afe:	6a 0a                	push   $0xa
80104b00:	6a 20                	push   $0x20
80104b02:	e8 ca fe ff ff       	call   801049d1 <outb>
80104b07:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b0a:	6a 68                	push   $0x68
80104b0c:	68 a0 00 00 00       	push   $0xa0
80104b11:	e8 bb fe ff ff       	call   801049d1 <outb>
80104b16:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b19:	6a 0a                	push   $0xa
80104b1b:	68 a0 00 00 00       	push   $0xa0
80104b20:	e8 ac fe ff ff       	call   801049d1 <outb>
80104b25:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b28:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b2f:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b33:	74 13                	je     80104b48 <picinit+0xe6>
    picsetmask(irqmask);
80104b35:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b3c:	0f b7 c0             	movzwl %ax,%eax
80104b3f:	50                   	push   %eax
80104b40:	e8 ab fe ff ff       	call   801049f0 <picsetmask>
80104b45:	83 c4 04             	add    $0x4,%esp
}
80104b48:	90                   	nop
80104b49:	c9                   	leave  
80104b4a:	c3                   	ret    

80104b4b <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b4b:	55                   	push   %ebp
80104b4c:	89 e5                	mov    %esp,%ebp
80104b4e:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b58:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b61:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b64:	8b 10                	mov    (%eax),%edx
80104b66:	8b 45 08             	mov    0x8(%ebp),%eax
80104b69:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104b6b:	e8 7b c4 ff ff       	call   80100feb <filealloc>
80104b70:	89 c2                	mov    %eax,%edx
80104b72:	8b 45 08             	mov    0x8(%ebp),%eax
80104b75:	89 10                	mov    %edx,(%eax)
80104b77:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7a:	8b 00                	mov    (%eax),%eax
80104b7c:	85 c0                	test   %eax,%eax
80104b7e:	0f 84 cb 00 00 00    	je     80104c4f <pipealloc+0x104>
80104b84:	e8 62 c4 ff ff       	call   80100feb <filealloc>
80104b89:	89 c2                	mov    %eax,%edx
80104b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8e:	89 10                	mov    %edx,(%eax)
80104b90:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b93:	8b 00                	mov    (%eax),%eax
80104b95:	85 c0                	test   %eax,%eax
80104b97:	0f 84 b2 00 00 00    	je     80104c4f <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104b9d:	e8 bb e8 ff ff       	call   8010345d <kalloc>
80104ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ba5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ba9:	0f 84 9f 00 00 00    	je     80104c4e <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104bb9:	00 00 00 
  p->writeopen = 1;
80104bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104bc6:	00 00 00 
  p->nwrite = 0;
80104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104bd3:	00 00 00 
  p->nread = 0;
80104bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104be0:	00 00 00 
  initlock(&p->lock, "pipe");
80104be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be6:	83 ec 08             	sub    $0x8,%esp
80104be9:	68 8c 97 10 80       	push   $0x8010978c
80104bee:	50                   	push   %eax
80104bef:	e8 59 0f 00 00       	call   80105b4d <initlock>
80104bf4:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfa:	8b 00                	mov    (%eax),%eax
80104bfc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c02:	8b 45 08             	mov    0x8(%ebp),%eax
80104c05:	8b 00                	mov    (%eax),%eax
80104c07:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0e:	8b 00                	mov    (%eax),%eax
80104c10:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c14:	8b 45 08             	mov    0x8(%ebp),%eax
80104c17:	8b 00                	mov    (%eax),%eax
80104c19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c1c:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c22:	8b 00                	mov    (%eax),%eax
80104c24:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c2d:	8b 00                	mov    (%eax),%eax
80104c2f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c36:	8b 00                	mov    (%eax),%eax
80104c38:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3f:	8b 00                	mov    (%eax),%eax
80104c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c44:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c47:	b8 00 00 00 00       	mov    $0x0,%eax
80104c4c:	eb 4e                	jmp    80104c9c <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c4e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c53:	74 0e                	je     80104c63 <pipealloc+0x118>
    kfree((char*)p);
80104c55:	83 ec 0c             	sub    $0xc,%esp
80104c58:	ff 75 f4             	pushl  -0xc(%ebp)
80104c5b:	e8 60 e7 ff ff       	call   801033c0 <kfree>
80104c60:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104c63:	8b 45 08             	mov    0x8(%ebp),%eax
80104c66:	8b 00                	mov    (%eax),%eax
80104c68:	85 c0                	test   %eax,%eax
80104c6a:	74 11                	je     80104c7d <pipealloc+0x132>
    fileclose(*f0);
80104c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6f:	8b 00                	mov    (%eax),%eax
80104c71:	83 ec 0c             	sub    $0xc,%esp
80104c74:	50                   	push   %eax
80104c75:	e8 2f c4 ff ff       	call   801010a9 <fileclose>
80104c7a:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c80:	8b 00                	mov    (%eax),%eax
80104c82:	85 c0                	test   %eax,%eax
80104c84:	74 11                	je     80104c97 <pipealloc+0x14c>
    fileclose(*f1);
80104c86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c89:	8b 00                	mov    (%eax),%eax
80104c8b:	83 ec 0c             	sub    $0xc,%esp
80104c8e:	50                   	push   %eax
80104c8f:	e8 15 c4 ff ff       	call   801010a9 <fileclose>
80104c94:	83 c4 10             	add    $0x10,%esp
  return -1;
80104c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c9c:	c9                   	leave  
80104c9d:	c3                   	ret    

80104c9e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104c9e:	55                   	push   %ebp
80104c9f:	89 e5                	mov    %esp,%ebp
80104ca1:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca7:	83 ec 0c             	sub    $0xc,%esp
80104caa:	50                   	push   %eax
80104cab:	e8 bf 0e 00 00       	call   80105b6f <acquire>
80104cb0:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104cb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104cb7:	74 23                	je     80104cdc <pipeclose+0x3e>
    p->writeopen = 0;
80104cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbc:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104cc3:	00 00 00 
    wakeup(&p->nread);
80104cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc9:	05 34 02 00 00       	add    $0x234,%eax
80104cce:	83 ec 0c             	sub    $0xc,%esp
80104cd1:	50                   	push   %eax
80104cd2:	e8 8a 0c 00 00       	call   80105961 <wakeup>
80104cd7:	83 c4 10             	add    $0x10,%esp
80104cda:	eb 21                	jmp    80104cfd <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdf:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104ce6:	00 00 00 
    wakeup(&p->nwrite);
80104ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cec:	05 38 02 00 00       	add    $0x238,%eax
80104cf1:	83 ec 0c             	sub    $0xc,%esp
80104cf4:	50                   	push   %eax
80104cf5:	e8 67 0c 00 00       	call   80105961 <wakeup>
80104cfa:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104d00:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d06:	85 c0                	test   %eax,%eax
80104d08:	75 2c                	jne    80104d36 <pipeclose+0x98>
80104d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d13:	85 c0                	test   %eax,%eax
80104d15:	75 1f                	jne    80104d36 <pipeclose+0x98>
    release(&p->lock);
80104d17:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1a:	83 ec 0c             	sub    $0xc,%esp
80104d1d:	50                   	push   %eax
80104d1e:	e8 b3 0e 00 00       	call   80105bd6 <release>
80104d23:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d26:	83 ec 0c             	sub    $0xc,%esp
80104d29:	ff 75 08             	pushl  0x8(%ebp)
80104d2c:	e8 8f e6 ff ff       	call   801033c0 <kfree>
80104d31:	83 c4 10             	add    $0x10,%esp
80104d34:	eb 0f                	jmp    80104d45 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d36:	8b 45 08             	mov    0x8(%ebp),%eax
80104d39:	83 ec 0c             	sub    $0xc,%esp
80104d3c:	50                   	push   %eax
80104d3d:	e8 94 0e 00 00       	call   80105bd6 <release>
80104d42:	83 c4 10             	add    $0x10,%esp
}
80104d45:	90                   	nop
80104d46:	c9                   	leave  
80104d47:	c3                   	ret    

80104d48 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
80104d4b:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d51:	83 ec 0c             	sub    $0xc,%esp
80104d54:	50                   	push   %eax
80104d55:	e8 15 0e 00 00       	call   80105b6f <acquire>
80104d5a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d64:	e9 ad 00 00 00       	jmp    80104e16 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104d69:	8b 45 08             	mov    0x8(%ebp),%eax
80104d6c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d72:	85 c0                	test   %eax,%eax
80104d74:	74 0d                	je     80104d83 <pipewrite+0x3b>
80104d76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d7c:	8b 40 24             	mov    0x24(%eax),%eax
80104d7f:	85 c0                	test   %eax,%eax
80104d81:	74 19                	je     80104d9c <pipewrite+0x54>
        release(&p->lock);
80104d83:	8b 45 08             	mov    0x8(%ebp),%eax
80104d86:	83 ec 0c             	sub    $0xc,%esp
80104d89:	50                   	push   %eax
80104d8a:	e8 47 0e 00 00       	call   80105bd6 <release>
80104d8f:	83 c4 10             	add    $0x10,%esp
        return -1;
80104d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d97:	e9 a8 00 00 00       	jmp    80104e44 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9f:	05 34 02 00 00       	add    $0x234,%eax
80104da4:	83 ec 0c             	sub    $0xc,%esp
80104da7:	50                   	push   %eax
80104da8:	e8 b4 0b 00 00       	call   80105961 <wakeup>
80104dad:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104db0:	8b 45 08             	mov    0x8(%ebp),%eax
80104db3:	8b 55 08             	mov    0x8(%ebp),%edx
80104db6:	81 c2 38 02 00 00    	add    $0x238,%edx
80104dbc:	83 ec 08             	sub    $0x8,%esp
80104dbf:	50                   	push   %eax
80104dc0:	52                   	push   %edx
80104dc1:	e8 b0 0a 00 00       	call   80105876 <sleep>
80104dc6:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcc:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104ddb:	05 00 02 00 00       	add    $0x200,%eax
80104de0:	39 c2                	cmp    %eax,%edx
80104de2:	74 85                	je     80104d69 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104de4:	8b 45 08             	mov    0x8(%ebp),%eax
80104de7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ded:	8d 48 01             	lea    0x1(%eax),%ecx
80104df0:	8b 55 08             	mov    0x8(%ebp),%edx
80104df3:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104df9:	25 ff 01 00 00       	and    $0x1ff,%eax
80104dfe:	89 c1                	mov    %eax,%ecx
80104e00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e06:	01 d0                	add    %edx,%eax
80104e08:	0f b6 10             	movzbl (%eax),%edx
80104e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e19:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e1c:	7c ab                	jl     80104dc9 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e21:	05 34 02 00 00       	add    $0x234,%eax
80104e26:	83 ec 0c             	sub    $0xc,%esp
80104e29:	50                   	push   %eax
80104e2a:	e8 32 0b 00 00       	call   80105961 <wakeup>
80104e2f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e32:	8b 45 08             	mov    0x8(%ebp),%eax
80104e35:	83 ec 0c             	sub    $0xc,%esp
80104e38:	50                   	push   %eax
80104e39:	e8 98 0d 00 00       	call   80105bd6 <release>
80104e3e:	83 c4 10             	add    $0x10,%esp
  return n;
80104e41:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e44:	c9                   	leave  
80104e45:	c3                   	ret    

80104e46 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e46:	55                   	push   %ebp
80104e47:	89 e5                	mov    %esp,%ebp
80104e49:	53                   	push   %ebx
80104e4a:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e50:	83 ec 0c             	sub    $0xc,%esp
80104e53:	50                   	push   %eax
80104e54:	e8 16 0d 00 00       	call   80105b6f <acquire>
80104e59:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e5c:	eb 3f                	jmp    80104e9d <piperead+0x57>
    if(proc->killed){
80104e5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e64:	8b 40 24             	mov    0x24(%eax),%eax
80104e67:	85 c0                	test   %eax,%eax
80104e69:	74 19                	je     80104e84 <piperead+0x3e>
      release(&p->lock);
80104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6e:	83 ec 0c             	sub    $0xc,%esp
80104e71:	50                   	push   %eax
80104e72:	e8 5f 0d 00 00       	call   80105bd6 <release>
80104e77:	83 c4 10             	add    $0x10,%esp
      return -1;
80104e7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e7f:	e9 bf 00 00 00       	jmp    80104f43 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104e84:	8b 45 08             	mov    0x8(%ebp),%eax
80104e87:	8b 55 08             	mov    0x8(%ebp),%edx
80104e8a:	81 c2 34 02 00 00    	add    $0x234,%edx
80104e90:	83 ec 08             	sub    $0x8,%esp
80104e93:	50                   	push   %eax
80104e94:	52                   	push   %edx
80104e95:	e8 dc 09 00 00       	call   80105876 <sleep>
80104e9a:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104eaf:	39 c2                	cmp    %eax,%edx
80104eb1:	75 0d                	jne    80104ec0 <piperead+0x7a>
80104eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ebc:	85 c0                	test   %eax,%eax
80104ebe:	75 9e                	jne    80104e5e <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ec0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ec7:	eb 49                	jmp    80104f12 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecc:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed5:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104edb:	39 c2                	cmp    %eax,%edx
80104edd:	74 3d                	je     80104f1c <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104edf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eeb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104ef1:	8d 48 01             	lea    0x1(%eax),%ecx
80104ef4:	8b 55 08             	mov    0x8(%ebp),%edx
80104ef7:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104efd:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f02:	89 c2                	mov    %eax,%edx
80104f04:	8b 45 08             	mov    0x8(%ebp),%eax
80104f07:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f0c:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f15:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f18:	7c af                	jl     80104ec9 <piperead+0x83>
80104f1a:	eb 01                	jmp    80104f1d <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f1c:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f20:	05 38 02 00 00       	add    $0x238,%eax
80104f25:	83 ec 0c             	sub    $0xc,%esp
80104f28:	50                   	push   %eax
80104f29:	e8 33 0a 00 00       	call   80105961 <wakeup>
80104f2e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f31:	8b 45 08             	mov    0x8(%ebp),%eax
80104f34:	83 ec 0c             	sub    $0xc,%esp
80104f37:	50                   	push   %eax
80104f38:	e8 99 0c 00 00       	call   80105bd6 <release>
80104f3d:	83 c4 10             	add    $0x10,%esp
  return i;
80104f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f46:	c9                   	leave  
80104f47:	c3                   	ret    

80104f48 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f48:	55                   	push   %ebp
80104f49:	89 e5                	mov    %esp,%ebp
80104f4b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f4e:	9c                   	pushf  
80104f4f:	58                   	pop    %eax
80104f50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f53:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f56:	c9                   	leave  
80104f57:	c3                   	ret    

80104f58 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f58:	55                   	push   %ebp
80104f59:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f5b:	fb                   	sti    
}
80104f5c:	90                   	nop
80104f5d:	5d                   	pop    %ebp
80104f5e:	c3                   	ret    

80104f5f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f5f:	55                   	push   %ebp
80104f60:	89 e5                	mov    %esp,%ebp
80104f62:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104f65:	83 ec 08             	sub    $0x8,%esp
80104f68:	68 91 97 10 80       	push   $0x80109791
80104f6d:	68 80 3e 11 80       	push   $0x80113e80
80104f72:	e8 d6 0b 00 00       	call   80105b4d <initlock>
80104f77:	83 c4 10             	add    $0x10,%esp
}
80104f7a:	90                   	nop
80104f7b:	c9                   	leave  
80104f7c:	c3                   	ret    

80104f7d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104f7d:	55                   	push   %ebp
80104f7e:	89 e5                	mov    %esp,%ebp
80104f80:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104f83:	83 ec 0c             	sub    $0xc,%esp
80104f86:	68 80 3e 11 80       	push   $0x80113e80
80104f8b:	e8 df 0b 00 00       	call   80105b6f <acquire>
80104f90:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f93:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104f9a:	eb 0e                	jmp    80104faa <allocproc+0x2d>
    if(p->state == UNUSED)
80104f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9f:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa2:	85 c0                	test   %eax,%eax
80104fa4:	74 27                	je     80104fcd <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fa6:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104faa:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fb1:	72 e9                	jb     80104f9c <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104fb3:	83 ec 0c             	sub    $0xc,%esp
80104fb6:	68 80 3e 11 80       	push   $0x80113e80
80104fbb:	e8 16 0c 00 00       	call   80105bd6 <release>
80104fc0:	83 c4 10             	add    $0x10,%esp
  return 0;
80104fc3:	b8 00 00 00 00       	mov    $0x0,%eax
80104fc8:	e9 b4 00 00 00       	jmp    80105081 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104fcd:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104fd8:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104fdd:	8d 50 01             	lea    0x1(%eax),%edx
80104fe0:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe9:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104fec:	83 ec 0c             	sub    $0xc,%esp
80104fef:	68 80 3e 11 80       	push   $0x80113e80
80104ff4:	e8 dd 0b 00 00       	call   80105bd6 <release>
80104ff9:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104ffc:	e8 5c e4 ff ff       	call   8010345d <kalloc>
80105001:	89 c2                	mov    %eax,%edx
80105003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105006:	89 50 08             	mov    %edx,0x8(%eax)
80105009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500c:	8b 40 08             	mov    0x8(%eax),%eax
8010500f:	85 c0                	test   %eax,%eax
80105011:	75 11                	jne    80105024 <allocproc+0xa7>
    p->state = UNUSED;
80105013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105016:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010501d:	b8 00 00 00 00       	mov    $0x0,%eax
80105022:	eb 5d                	jmp    80105081 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80105024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105027:	8b 40 08             	mov    0x8(%eax),%eax
8010502a:	05 00 10 00 00       	add    $0x1000,%eax
8010502f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105032:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80105036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105039:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010503c:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010503f:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80105043:	ba 97 74 10 80       	mov    $0x80107497,%edx
80105048:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010504d:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80105051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105054:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105057:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010505a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105060:	83 ec 04             	sub    $0x4,%esp
80105063:	6a 14                	push   $0x14
80105065:	6a 00                	push   $0x0
80105067:	50                   	push   %eax
80105068:	e8 65 0d 00 00       	call   80105dd2 <memset>
8010506d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80105070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105073:	8b 40 1c             	mov    0x1c(%eax),%eax
80105076:	ba f6 57 10 80       	mov    $0x801057f6,%edx
8010507b:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010507e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105081:	c9                   	leave  
80105082:	c3                   	ret    

80105083 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80105083:	55                   	push   %ebp
80105084:	89 e5                	mov    %esp,%ebp
80105086:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80105089:	e8 ef fe ff ff       	call   80104f7d <allocproc>
8010508e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80105091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105094:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80105099:	e8 be 3a 00 00       	call   80108b5c <setupkvm>
8010509e:	89 c2                	mov    %eax,%edx
801050a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a3:	89 50 04             	mov    %edx,0x4(%eax)
801050a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a9:	8b 40 04             	mov    0x4(%eax),%eax
801050ac:	85 c0                	test   %eax,%eax
801050ae:	75 0d                	jne    801050bd <userinit+0x3a>
    panic("userinit: out of memory?");
801050b0:	83 ec 0c             	sub    $0xc,%esp
801050b3:	68 98 97 10 80       	push   $0x80109798
801050b8:	e8 a9 b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050bd:	ba 2c 00 00 00       	mov    $0x2c,%edx
801050c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c5:	8b 40 04             	mov    0x4(%eax),%eax
801050c8:	83 ec 04             	sub    $0x4,%esp
801050cb:	52                   	push   %edx
801050cc:	68 e0 c4 10 80       	push   $0x8010c4e0
801050d1:	50                   	push   %eax
801050d2:	e8 df 3c 00 00       	call   80108db6 <inituvm>
801050d7:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801050da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050dd:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801050e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e6:	8b 40 18             	mov    0x18(%eax),%eax
801050e9:	83 ec 04             	sub    $0x4,%esp
801050ec:	6a 4c                	push   $0x4c
801050ee:	6a 00                	push   $0x0
801050f0:	50                   	push   %eax
801050f1:	e8 dc 0c 00 00       	call   80105dd2 <memset>
801050f6:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801050f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fc:	8b 40 18             	mov    0x18(%eax),%eax
801050ff:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80105105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105108:	8b 40 18             	mov    0x18(%eax),%eax
8010510b:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80105111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105114:	8b 40 18             	mov    0x18(%eax),%eax
80105117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010511a:	8b 52 18             	mov    0x18(%edx),%edx
8010511d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105121:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80105125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105128:	8b 40 18             	mov    0x18(%eax),%eax
8010512b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010512e:	8b 52 18             	mov    0x18(%edx),%edx
80105131:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105135:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80105139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513c:	8b 40 18             	mov    0x18(%eax),%eax
8010513f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80105146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105149:	8b 40 18             	mov    0x18(%eax),%eax
8010514c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80105153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105156:	8b 40 18             	mov    0x18(%eax),%eax
80105159:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80105160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105163:	83 c0 6c             	add    $0x6c,%eax
80105166:	83 ec 04             	sub    $0x4,%esp
80105169:	6a 10                	push   $0x10
8010516b:	68 b1 97 10 80       	push   $0x801097b1
80105170:	50                   	push   %eax
80105171:	e8 5f 0e 00 00       	call   80105fd5 <safestrcpy>
80105176:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80105179:	83 ec 0c             	sub    $0xc,%esp
8010517c:	68 ba 97 10 80       	push   $0x801097ba
80105181:	e8 60 db ff ff       	call   80102ce6 <namei>
80105186:	83 c4 10             	add    $0x10,%esp
80105189:	89 c2                	mov    %eax,%edx
8010518b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518e:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
80105191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105194:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010519b:	90                   	nop
8010519c:	c9                   	leave  
8010519d:	c3                   	ret    

8010519e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010519e:	55                   	push   %ebp
8010519f:	89 e5                	mov    %esp,%ebp
801051a1:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051aa:	8b 00                	mov    (%eax),%eax
801051ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051b3:	7e 31                	jle    801051e6 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051b5:	8b 55 08             	mov    0x8(%ebp),%edx
801051b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bb:	01 c2                	add    %eax,%edx
801051bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c3:	8b 40 04             	mov    0x4(%eax),%eax
801051c6:	83 ec 04             	sub    $0x4,%esp
801051c9:	52                   	push   %edx
801051ca:	ff 75 f4             	pushl  -0xc(%ebp)
801051cd:	50                   	push   %eax
801051ce:	e8 30 3d 00 00       	call   80108f03 <allocuvm>
801051d3:	83 c4 10             	add    $0x10,%esp
801051d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051dd:	75 3e                	jne    8010521d <growproc+0x7f>
      return -1;
801051df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e4:	eb 59                	jmp    8010523f <growproc+0xa1>
  } else if(n < 0){
801051e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051ea:	79 31                	jns    8010521d <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801051ec:	8b 55 08             	mov    0x8(%ebp),%edx
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	01 c2                	add    %eax,%edx
801051f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051fa:	8b 40 04             	mov    0x4(%eax),%eax
801051fd:	83 ec 04             	sub    $0x4,%esp
80105200:	52                   	push   %edx
80105201:	ff 75 f4             	pushl  -0xc(%ebp)
80105204:	50                   	push   %eax
80105205:	e8 c2 3d 00 00       	call   80108fcc <deallocuvm>
8010520a:	83 c4 10             	add    $0x10,%esp
8010520d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105210:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105214:	75 07                	jne    8010521d <growproc+0x7f>
      return -1;
80105216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010521b:	eb 22                	jmp    8010523f <growproc+0xa1>
  }
  proc->sz = sz;
8010521d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105223:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105226:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80105228:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010522e:	83 ec 0c             	sub    $0xc,%esp
80105231:	50                   	push   %eax
80105232:	e8 0c 3a 00 00       	call   80108c43 <switchuvm>
80105237:	83 c4 10             	add    $0x10,%esp
  return 0;
8010523a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010523f:	c9                   	leave  
80105240:	c3                   	ret    

80105241 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80105241:	55                   	push   %ebp
80105242:	89 e5                	mov    %esp,%ebp
80105244:	57                   	push   %edi
80105245:	56                   	push   %esi
80105246:	53                   	push   %ebx
80105247:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010524a:	e8 2e fd ff ff       	call   80104f7d <allocproc>
8010524f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105252:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80105256:	75 0a                	jne    80105262 <fork+0x21>
    return -1;
80105258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010525d:	e9 68 01 00 00       	jmp    801053ca <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80105262:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105268:	8b 10                	mov    (%eax),%edx
8010526a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105270:	8b 40 04             	mov    0x4(%eax),%eax
80105273:	83 ec 08             	sub    $0x8,%esp
80105276:	52                   	push   %edx
80105277:	50                   	push   %eax
80105278:	e8 ed 3e 00 00       	call   8010916a <copyuvm>
8010527d:	83 c4 10             	add    $0x10,%esp
80105280:	89 c2                	mov    %eax,%edx
80105282:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105285:	89 50 04             	mov    %edx,0x4(%eax)
80105288:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010528b:	8b 40 04             	mov    0x4(%eax),%eax
8010528e:	85 c0                	test   %eax,%eax
80105290:	75 30                	jne    801052c2 <fork+0x81>
    kfree(np->kstack);
80105292:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105295:	8b 40 08             	mov    0x8(%eax),%eax
80105298:	83 ec 0c             	sub    $0xc,%esp
8010529b:	50                   	push   %eax
8010529c:	e8 1f e1 ff ff       	call   801033c0 <kfree>
801052a1:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052b1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052bd:	e9 08 01 00 00       	jmp    801053ca <fork+0x189>
  }
  np->sz = proc->sz;
801052c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c8:	8b 10                	mov    (%eax),%edx
801052ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052cd:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801052cf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052d9:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801052dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052df:	8b 50 18             	mov    0x18(%eax),%edx
801052e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052e8:	8b 40 18             	mov    0x18(%eax),%eax
801052eb:	89 c3                	mov    %eax,%ebx
801052ed:	b8 13 00 00 00       	mov    $0x13,%eax
801052f2:	89 d7                	mov    %edx,%edi
801052f4:	89 de                	mov    %ebx,%esi
801052f6:	89 c1                	mov    %eax,%ecx
801052f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801052fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052fd:	8b 40 18             	mov    0x18(%eax),%eax
80105300:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105307:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010530e:	eb 43                	jmp    80105353 <fork+0x112>
    if(proc->ofile[i])
80105310:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105316:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105319:	83 c2 08             	add    $0x8,%edx
8010531c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105320:	85 c0                	test   %eax,%eax
80105322:	74 2b                	je     8010534f <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80105324:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010532a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010532d:	83 c2 08             	add    $0x8,%edx
80105330:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105334:	83 ec 0c             	sub    $0xc,%esp
80105337:	50                   	push   %eax
80105338:	e8 1b bd ff ff       	call   80101058 <filedup>
8010533d:	83 c4 10             	add    $0x10,%esp
80105340:	89 c1                	mov    %eax,%ecx
80105342:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105345:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105348:	83 c2 08             	add    $0x8,%edx
8010534b:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010534f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105353:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105357:	7e b7                	jle    80105310 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105359:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010535f:	8b 40 68             	mov    0x68(%eax),%eax
80105362:	83 ec 0c             	sub    $0xc,%esp
80105365:	50                   	push   %eax
80105366:	e8 30 cb ff ff       	call   80101e9b <idup>
8010536b:	83 c4 10             	add    $0x10,%esp
8010536e:	89 c2                	mov    %eax,%edx
80105370:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105373:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80105376:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010537c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010537f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105382:	83 c0 6c             	add    $0x6c,%eax
80105385:	83 ec 04             	sub    $0x4,%esp
80105388:	6a 10                	push   $0x10
8010538a:	52                   	push   %edx
8010538b:	50                   	push   %eax
8010538c:	e8 44 0c 00 00       	call   80105fd5 <safestrcpy>
80105391:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80105394:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105397:	8b 40 10             	mov    0x10(%eax),%eax
8010539a:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010539d:	83 ec 0c             	sub    $0xc,%esp
801053a0:	68 80 3e 11 80       	push   $0x80113e80
801053a5:	e8 c5 07 00 00       	call   80105b6f <acquire>
801053aa:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053b0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053b7:	83 ec 0c             	sub    $0xc,%esp
801053ba:	68 80 3e 11 80       	push   $0x80113e80
801053bf:	e8 12 08 00 00       	call   80105bd6 <release>
801053c4:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801053c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801053ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053cd:	5b                   	pop    %ebx
801053ce:	5e                   	pop    %esi
801053cf:	5f                   	pop    %edi
801053d0:	5d                   	pop    %ebp
801053d1:	c3                   	ret    

801053d2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801053d2:	55                   	push   %ebp
801053d3:	89 e5                	mov    %esp,%ebp
801053d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801053d8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053df:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801053e4:	39 c2                	cmp    %eax,%edx
801053e6:	75 0d                	jne    801053f5 <exit+0x23>
    panic("init exiting");
801053e8:	83 ec 0c             	sub    $0xc,%esp
801053eb:	68 bc 97 10 80       	push   $0x801097bc
801053f0:	e8 71 b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801053f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801053fc:	eb 48                	jmp    80105446 <exit+0x74>
    if(proc->ofile[fd]){
801053fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105404:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105407:	83 c2 08             	add    $0x8,%edx
8010540a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010540e:	85 c0                	test   %eax,%eax
80105410:	74 30                	je     80105442 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105412:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105418:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010541b:	83 c2 08             	add    $0x8,%edx
8010541e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105422:	83 ec 0c             	sub    $0xc,%esp
80105425:	50                   	push   %eax
80105426:	e8 7e bc ff ff       	call   801010a9 <fileclose>
8010542b:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010542e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105434:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105437:	83 c2 08             	add    $0x8,%edx
8010543a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105441:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105442:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105446:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010544a:	7e b2                	jle    801053fe <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
8010544c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105452:	8b 40 68             	mov    0x68(%eax),%eax
80105455:	8b 40 50             	mov    0x50(%eax),%eax
80105458:	8b 40 14             	mov    0x14(%eax),%eax
8010545b:	83 ec 0c             	sub    $0xc,%esp
8010545e:	50                   	push   %eax
8010545f:	e8 17 ea ff ff       	call   80103e7b <begin_op>
80105464:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80105467:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010546d:	8b 40 68             	mov    0x68(%eax),%eax
80105470:	83 ec 0c             	sub    $0xc,%esp
80105473:	50                   	push   %eax
80105474:	e8 6f cc ff ff       	call   801020e8 <iput>
80105479:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
8010547c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105482:	8b 40 68             	mov    0x68(%eax),%eax
80105485:	8b 40 50             	mov    0x50(%eax),%eax
80105488:	8b 40 14             	mov    0x14(%eax),%eax
8010548b:	83 ec 0c             	sub    $0xc,%esp
8010548e:	50                   	push   %eax
8010548f:	e8 ee ea ff ff       	call   80103f82 <end_op>
80105494:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
80105497:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054a4:	83 ec 0c             	sub    $0xc,%esp
801054a7:	68 80 3e 11 80       	push   $0x80113e80
801054ac:	e8 be 06 00 00       	call   80105b6f <acquire>
801054b1:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ba:	8b 40 14             	mov    0x14(%eax),%eax
801054bd:	83 ec 0c             	sub    $0xc,%esp
801054c0:	50                   	push   %eax
801054c1:	e8 5c 04 00 00       	call   80105922 <wakeup1>
801054c6:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054c9:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801054d0:	eb 3c                	jmp    8010550e <exit+0x13c>
    if(p->parent == proc){
801054d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d5:	8b 50 14             	mov    0x14(%eax),%edx
801054d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054de:	39 c2                	cmp    %eax,%edx
801054e0:	75 28                	jne    8010550a <exit+0x138>
      p->parent = initproc;
801054e2:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801054e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054eb:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801054ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f1:	8b 40 0c             	mov    0xc(%eax),%eax
801054f4:	83 f8 05             	cmp    $0x5,%eax
801054f7:	75 11                	jne    8010550a <exit+0x138>
        wakeup1(initproc);
801054f9:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801054fe:	83 ec 0c             	sub    $0xc,%esp
80105501:	50                   	push   %eax
80105502:	e8 1b 04 00 00       	call   80105922 <wakeup1>
80105507:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010550a:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010550e:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105515:	72 bb                	jb     801054d2 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105517:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010551d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105524:	e8 d6 01 00 00       	call   801056ff <sched>
  panic("zombie exit");
80105529:	83 ec 0c             	sub    $0xc,%esp
8010552c:	68 c9 97 10 80       	push   $0x801097c9
80105531:	e8 30 b0 ff ff       	call   80100566 <panic>

80105536 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105536:	55                   	push   %ebp
80105537:	89 e5                	mov    %esp,%ebp
80105539:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010553c:	83 ec 0c             	sub    $0xc,%esp
8010553f:	68 80 3e 11 80       	push   $0x80113e80
80105544:	e8 26 06 00 00       	call   80105b6f <acquire>
80105549:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010554c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105553:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
8010555a:	e9 a6 00 00 00       	jmp    80105605 <wait+0xcf>
      if(p->parent != proc)
8010555f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105562:	8b 50 14             	mov    0x14(%eax),%edx
80105565:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556b:	39 c2                	cmp    %eax,%edx
8010556d:	0f 85 8d 00 00 00    	jne    80105600 <wait+0xca>
        continue;
      havekids = 1;
80105573:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010557a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557d:	8b 40 0c             	mov    0xc(%eax),%eax
80105580:	83 f8 05             	cmp    $0x5,%eax
80105583:	75 7c                	jne    80105601 <wait+0xcb>
        // Found one.
        pid = p->pid;
80105585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105588:	8b 40 10             	mov    0x10(%eax),%eax
8010558b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010558e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105591:	8b 40 08             	mov    0x8(%eax),%eax
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	50                   	push   %eax
80105598:	e8 23 de ff ff       	call   801033c0 <kfree>
8010559d:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ad:	8b 40 04             	mov    0x4(%eax),%eax
801055b0:	83 ec 0c             	sub    $0xc,%esp
801055b3:	50                   	push   %eax
801055b4:	e8 d0 3a 00 00       	call   80109089 <freevm>
801055b9:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801055c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801055d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dd:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801055e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801055eb:	83 ec 0c             	sub    $0xc,%esp
801055ee:	68 80 3e 11 80       	push   $0x80113e80
801055f3:	e8 de 05 00 00       	call   80105bd6 <release>
801055f8:	83 c4 10             	add    $0x10,%esp
        return pid;
801055fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801055fe:	eb 58                	jmp    80105658 <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105600:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105601:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105605:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010560c:	0f 82 4d ff ff ff    	jb     8010555f <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105612:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105616:	74 0d                	je     80105625 <wait+0xef>
80105618:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010561e:	8b 40 24             	mov    0x24(%eax),%eax
80105621:	85 c0                	test   %eax,%eax
80105623:	74 17                	je     8010563c <wait+0x106>
      release(&ptable.lock);
80105625:	83 ec 0c             	sub    $0xc,%esp
80105628:	68 80 3e 11 80       	push   $0x80113e80
8010562d:	e8 a4 05 00 00       	call   80105bd6 <release>
80105632:	83 c4 10             	add    $0x10,%esp
      return -1;
80105635:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010563a:	eb 1c                	jmp    80105658 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010563c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105642:	83 ec 08             	sub    $0x8,%esp
80105645:	68 80 3e 11 80       	push   $0x80113e80
8010564a:	50                   	push   %eax
8010564b:	e8 26 02 00 00       	call   80105876 <sleep>
80105650:	83 c4 10             	add    $0x10,%esp
  }
80105653:	e9 f4 fe ff ff       	jmp    8010554c <wait+0x16>
}
80105658:	c9                   	leave  
80105659:	c3                   	ret    

8010565a <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010565a:	55                   	push   %ebp
8010565b:	89 e5                	mov    %esp,%ebp
8010565d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105660:	e8 f3 f8 ff ff       	call   80104f58 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105665:	83 ec 0c             	sub    $0xc,%esp
80105668:	68 80 3e 11 80       	push   $0x80113e80
8010566d:	e8 fd 04 00 00       	call   80105b6f <acquire>
80105672:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105675:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
8010567c:	eb 63                	jmp    801056e1 <scheduler+0x87>
      if(p->state != RUNNABLE)
8010567e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105681:	8b 40 0c             	mov    0xc(%eax),%eax
80105684:	83 f8 03             	cmp    $0x3,%eax
80105687:	75 53                	jne    801056dc <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105692:	83 ec 0c             	sub    $0xc,%esp
80105695:	ff 75 f4             	pushl  -0xc(%ebp)
80105698:	e8 a6 35 00 00       	call   80108c43 <switchuvm>
8010569d:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a3:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b0:	8b 40 1c             	mov    0x1c(%eax),%eax
801056b3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056ba:	83 c2 04             	add    $0x4,%edx
801056bd:	83 ec 08             	sub    $0x8,%esp
801056c0:	50                   	push   %eax
801056c1:	52                   	push   %edx
801056c2:	e8 7f 09 00 00       	call   80106046 <swtch>
801056c7:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801056ca:	e8 57 35 00 00       	call   80108c26 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801056cf:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801056d6:	00 00 00 00 
801056da:	eb 01                	jmp    801056dd <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801056dc:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056dd:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801056e1:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801056e8:	72 94                	jb     8010567e <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801056ea:	83 ec 0c             	sub    $0xc,%esp
801056ed:	68 80 3e 11 80       	push   $0x80113e80
801056f2:	e8 df 04 00 00       	call   80105bd6 <release>
801056f7:	83 c4 10             	add    $0x10,%esp

  }
801056fa:	e9 61 ff ff ff       	jmp    80105660 <scheduler+0x6>

801056ff <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801056ff:	55                   	push   %ebp
80105700:	89 e5                	mov    %esp,%ebp
80105702:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105705:	83 ec 0c             	sub    $0xc,%esp
80105708:	68 80 3e 11 80       	push   $0x80113e80
8010570d:	e8 90 05 00 00       	call   80105ca2 <holding>
80105712:	83 c4 10             	add    $0x10,%esp
80105715:	85 c0                	test   %eax,%eax
80105717:	75 0d                	jne    80105726 <sched+0x27>
    panic("sched ptable.lock");
80105719:	83 ec 0c             	sub    $0xc,%esp
8010571c:	68 d5 97 10 80       	push   $0x801097d5
80105721:	e8 40 ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105726:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010572c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105732:	83 f8 01             	cmp    $0x1,%eax
80105735:	74 0d                	je     80105744 <sched+0x45>
   panic("sched locks");
80105737:	83 ec 0c             	sub    $0xc,%esp
8010573a:	68 e7 97 10 80       	push   $0x801097e7
8010573f:	e8 22 ae ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105744:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574a:	8b 40 0c             	mov    0xc(%eax),%eax
8010574d:	83 f8 04             	cmp    $0x4,%eax
80105750:	75 0d                	jne    8010575f <sched+0x60>
    panic("sched running");
80105752:	83 ec 0c             	sub    $0xc,%esp
80105755:	68 f3 97 10 80       	push   $0x801097f3
8010575a:	e8 07 ae ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010575f:	e8 e4 f7 ff ff       	call   80104f48 <readeflags>
80105764:	25 00 02 00 00       	and    $0x200,%eax
80105769:	85 c0                	test   %eax,%eax
8010576b:	74 0d                	je     8010577a <sched+0x7b>
    panic("sched interruptible");
8010576d:	83 ec 0c             	sub    $0xc,%esp
80105770:	68 01 98 10 80       	push   $0x80109801
80105775:	e8 ec ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
8010577a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105780:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105786:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105789:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010578f:	8b 40 04             	mov    0x4(%eax),%eax
80105792:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105799:	83 c2 1c             	add    $0x1c,%edx
8010579c:	83 ec 08             	sub    $0x8,%esp
8010579f:	50                   	push   %eax
801057a0:	52                   	push   %edx
801057a1:	e8 a0 08 00 00       	call   80106046 <swtch>
801057a6:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057a9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057b2:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057b8:	90                   	nop
801057b9:	c9                   	leave  
801057ba:	c3                   	ret    

801057bb <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057bb:	55                   	push   %ebp
801057bc:	89 e5                	mov    %esp,%ebp
801057be:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057c1:	83 ec 0c             	sub    $0xc,%esp
801057c4:	68 80 3e 11 80       	push   $0x80113e80
801057c9:	e8 a1 03 00 00       	call   80105b6f <acquire>
801057ce:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801057d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057d7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801057de:	e8 1c ff ff ff       	call   801056ff <sched>
  release(&ptable.lock);
801057e3:	83 ec 0c             	sub    $0xc,%esp
801057e6:	68 80 3e 11 80       	push   $0x80113e80
801057eb:	e8 e6 03 00 00       	call   80105bd6 <release>
801057f0:	83 c4 10             	add    $0x10,%esp
}
801057f3:	90                   	nop
801057f4:	c9                   	leave  
801057f5:	c3                   	ret    

801057f6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801057f6:	55                   	push   %ebp
801057f7:	89 e5                	mov    %esp,%ebp
801057f9:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801057fc:	83 ec 0c             	sub    $0xc,%esp
801057ff:	68 80 3e 11 80       	push   $0x80113e80
80105804:	e8 cd 03 00 00       	call   80105bd6 <release>
80105809:	83 c4 10             	add    $0x10,%esp


  if (first) {
8010580c:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105811:	85 c0                	test   %eax,%eax
80105813:	74 5e                	je     80105873 <forkret+0x7d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105815:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
8010581c:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
8010581f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105825:	0f b6 00             	movzbl (%eax),%eax
80105828:	0f b6 c0             	movzbl %al,%eax
8010582b:	83 ec 08             	sub    $0x8,%esp
8010582e:	50                   	push   %eax
8010582f:	68 15 98 10 80       	push   $0x80109815
80105834:	e8 8d ab ff ff       	call   801003c6 <cprintf>
80105839:	83 c4 10             	add    $0x10,%esp
    int bootfrom=iinit(proc,ROOTDEV);
8010583c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105842:	83 ec 08             	sub    $0x8,%esp
80105845:	6a 00                	push   $0x0
80105847:	50                   	push   %eax
80105848:	e8 ed c1 ff ff       	call   80101a3a <iinit>
8010584d:	83 c4 10             	add    $0x10,%esp
80105850:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // iinitDone=1;
    cprintf("boot from after iinit is %d \n",bootfrom);
80105853:	83 ec 08             	sub    $0x8,%esp
80105856:	ff 75 f4             	pushl  -0xc(%ebp)
80105859:	68 24 98 10 80       	push   $0x80109824
8010585e:	e8 63 ab ff ff       	call   801003c6 <cprintf>
80105863:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105866:	83 ec 0c             	sub    $0xc,%esp
80105869:	6a 00                	push   $0x0
8010586b:	e8 b6 e2 ff ff       	call   80103b26 <initlog>
80105870:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
80105873:	90                   	nop
80105874:	c9                   	leave  
80105875:	c3                   	ret    

80105876 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105876:	55                   	push   %ebp
80105877:	89 e5                	mov    %esp,%ebp
80105879:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010587c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105882:	85 c0                	test   %eax,%eax
80105884:	75 0d                	jne    80105893 <sleep+0x1d>
    panic("sleep");
80105886:	83 ec 0c             	sub    $0xc,%esp
80105889:	68 42 98 10 80       	push   $0x80109842
8010588e:	e8 d3 ac ff ff       	call   80100566 <panic>

  if(lk == 0)
80105893:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105897:	75 0d                	jne    801058a6 <sleep+0x30>
    panic("sleep without lk");
80105899:	83 ec 0c             	sub    $0xc,%esp
8010589c:	68 48 98 10 80       	push   $0x80109848
801058a1:	e8 c0 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058a6:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058ad:	74 1e                	je     801058cd <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058af:	83 ec 0c             	sub    $0xc,%esp
801058b2:	68 80 3e 11 80       	push   $0x80113e80
801058b7:	e8 b3 02 00 00       	call   80105b6f <acquire>
801058bc:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058bf:	83 ec 0c             	sub    $0xc,%esp
801058c2:	ff 75 0c             	pushl  0xc(%ebp)
801058c5:	e8 0c 03 00 00       	call   80105bd6 <release>
801058ca:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d3:	8b 55 08             	mov    0x8(%ebp),%edx
801058d6:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058df:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801058e6:	e8 14 fe ff ff       	call   801056ff <sched>

  // Tidy up.
  proc->chan = 0;
801058eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801058f8:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058ff:	74 1e                	je     8010591f <sleep+0xa9>
    release(&ptable.lock);
80105901:	83 ec 0c             	sub    $0xc,%esp
80105904:	68 80 3e 11 80       	push   $0x80113e80
80105909:	e8 c8 02 00 00       	call   80105bd6 <release>
8010590e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105911:	83 ec 0c             	sub    $0xc,%esp
80105914:	ff 75 0c             	pushl  0xc(%ebp)
80105917:	e8 53 02 00 00       	call   80105b6f <acquire>
8010591c:	83 c4 10             	add    $0x10,%esp
  }
}
8010591f:	90                   	nop
80105920:	c9                   	leave  
80105921:	c3                   	ret    

80105922 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105922:	55                   	push   %ebp
80105923:	89 e5                	mov    %esp,%ebp
80105925:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105928:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
8010592f:	eb 24                	jmp    80105955 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105931:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105934:	8b 40 0c             	mov    0xc(%eax),%eax
80105937:	83 f8 02             	cmp    $0x2,%eax
8010593a:	75 15                	jne    80105951 <wakeup1+0x2f>
8010593c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010593f:	8b 40 20             	mov    0x20(%eax),%eax
80105942:	3b 45 08             	cmp    0x8(%ebp),%eax
80105945:	75 0a                	jne    80105951 <wakeup1+0x2f>
      p->state = RUNNABLE;
80105947:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010594a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105951:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80105955:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
8010595c:	72 d3                	jb     80105931 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010595e:	90                   	nop
8010595f:	c9                   	leave  
80105960:	c3                   	ret    

80105961 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105961:	55                   	push   %ebp
80105962:	89 e5                	mov    %esp,%ebp
80105964:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105967:	83 ec 0c             	sub    $0xc,%esp
8010596a:	68 80 3e 11 80       	push   $0x80113e80
8010596f:	e8 fb 01 00 00       	call   80105b6f <acquire>
80105974:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105977:	83 ec 0c             	sub    $0xc,%esp
8010597a:	ff 75 08             	pushl  0x8(%ebp)
8010597d:	e8 a0 ff ff ff       	call   80105922 <wakeup1>
80105982:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105985:	83 ec 0c             	sub    $0xc,%esp
80105988:	68 80 3e 11 80       	push   $0x80113e80
8010598d:	e8 44 02 00 00       	call   80105bd6 <release>
80105992:	83 c4 10             	add    $0x10,%esp
}
80105995:	90                   	nop
80105996:	c9                   	leave  
80105997:	c3                   	ret    

80105998 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105998:	55                   	push   %ebp
80105999:	89 e5                	mov    %esp,%ebp
8010599b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010599e:	83 ec 0c             	sub    $0xc,%esp
801059a1:	68 80 3e 11 80       	push   $0x80113e80
801059a6:	e8 c4 01 00 00       	call   80105b6f <acquire>
801059ab:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059ae:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059b5:	eb 45                	jmp    801059fc <kill+0x64>
    if(p->pid == pid){
801059b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ba:	8b 40 10             	mov    0x10(%eax),%eax
801059bd:	3b 45 08             	cmp    0x8(%ebp),%eax
801059c0:	75 36                	jne    801059f8 <kill+0x60>
      p->killed = 1;
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cf:	8b 40 0c             	mov    0xc(%eax),%eax
801059d2:	83 f8 02             	cmp    $0x2,%eax
801059d5:	75 0a                	jne    801059e1 <kill+0x49>
        p->state = RUNNABLE;
801059d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059da:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801059e1:	83 ec 0c             	sub    $0xc,%esp
801059e4:	68 80 3e 11 80       	push   $0x80113e80
801059e9:	e8 e8 01 00 00       	call   80105bd6 <release>
801059ee:	83 c4 10             	add    $0x10,%esp
      return 0;
801059f1:	b8 00 00 00 00       	mov    $0x0,%eax
801059f6:	eb 22                	jmp    80105a1a <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059f8:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801059fc:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105a03:	72 b2                	jb     801059b7 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	68 80 3e 11 80       	push   $0x80113e80
80105a0d:	e8 c4 01 00 00       	call   80105bd6 <release>
80105a12:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a1a:	c9                   	leave  
80105a1b:	c3                   	ret    

80105a1c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a1c:	55                   	push   %ebp
80105a1d:	89 e5                	mov    %esp,%ebp
80105a1f:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a22:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a29:	e9 d7 00 00 00       	jmp    80105b05 <procdump+0xe9>
    if(p->state == UNUSED)
80105a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a31:	8b 40 0c             	mov    0xc(%eax),%eax
80105a34:	85 c0                	test   %eax,%eax
80105a36:	0f 84 c4 00 00 00    	je     80105b00 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3f:	8b 40 0c             	mov    0xc(%eax),%eax
80105a42:	83 f8 05             	cmp    $0x5,%eax
80105a45:	77 23                	ja     80105a6a <procdump+0x4e>
80105a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4a:	8b 40 0c             	mov    0xc(%eax),%eax
80105a4d:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a54:	85 c0                	test   %eax,%eax
80105a56:	74 12                	je     80105a6a <procdump+0x4e>
      state = states[p->state];
80105a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5b:	8b 40 0c             	mov    0xc(%eax),%eax
80105a5e:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a65:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a68:	eb 07                	jmp    80105a71 <procdump+0x55>
    else
      state = "???";
80105a6a:	c7 45 ec 59 98 10 80 	movl   $0x80109859,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a74:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7a:	8b 40 10             	mov    0x10(%eax),%eax
80105a7d:	52                   	push   %edx
80105a7e:	ff 75 ec             	pushl  -0x14(%ebp)
80105a81:	50                   	push   %eax
80105a82:	68 5d 98 10 80       	push   $0x8010985d
80105a87:	e8 3a a9 ff ff       	call   801003c6 <cprintf>
80105a8c:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a92:	8b 40 0c             	mov    0xc(%eax),%eax
80105a95:	83 f8 02             	cmp    $0x2,%eax
80105a98:	75 54                	jne    80105aee <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105aa0:	8b 40 0c             	mov    0xc(%eax),%eax
80105aa3:	83 c0 08             	add    $0x8,%eax
80105aa6:	89 c2                	mov    %eax,%edx
80105aa8:	83 ec 08             	sub    $0x8,%esp
80105aab:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105aae:	50                   	push   %eax
80105aaf:	52                   	push   %edx
80105ab0:	e8 73 01 00 00       	call   80105c28 <getcallerpcs>
80105ab5:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ab8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105abf:	eb 1c                	jmp    80105add <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ac8:	83 ec 08             	sub    $0x8,%esp
80105acb:	50                   	push   %eax
80105acc:	68 66 98 10 80       	push   $0x80109866
80105ad1:	e8 f0 a8 ff ff       	call   801003c6 <cprintf>
80105ad6:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105ad9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105add:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105ae1:	7f 0b                	jg     80105aee <procdump+0xd2>
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105aea:	85 c0                	test   %eax,%eax
80105aec:	75 d3                	jne    80105ac1 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105aee:	83 ec 0c             	sub    $0xc,%esp
80105af1:	68 6a 98 10 80       	push   $0x8010986a
80105af6:	e8 cb a8 ff ff       	call   801003c6 <cprintf>
80105afb:	83 c4 10             	add    $0x10,%esp
80105afe:	eb 01                	jmp    80105b01 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b00:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b01:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105b05:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b0c:	0f 82 1c ff ff ff    	jb     80105a2e <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b12:	90                   	nop
80105b13:	c9                   	leave  
80105b14:	c3                   	ret    

80105b15 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b15:	55                   	push   %ebp
80105b16:	89 e5                	mov    %esp,%ebp
80105b18:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b1b:	9c                   	pushf  
80105b1c:	58                   	pop    %eax
80105b1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b20:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b23:	c9                   	leave  
80105b24:	c3                   	ret    

80105b25 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b25:	55                   	push   %ebp
80105b26:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b28:	fa                   	cli    
}
80105b29:	90                   	nop
80105b2a:	5d                   	pop    %ebp
80105b2b:	c3                   	ret    

80105b2c <sti>:

static inline void
sti(void)
{
80105b2c:	55                   	push   %ebp
80105b2d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b2f:	fb                   	sti    
}
80105b30:	90                   	nop
80105b31:	5d                   	pop    %ebp
80105b32:	c3                   	ret    

80105b33 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b33:	55                   	push   %ebp
80105b34:	89 e5                	mov    %esp,%ebp
80105b36:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b39:	8b 55 08             	mov    0x8(%ebp),%edx
80105b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b42:	f0 87 02             	lock xchg %eax,(%edx)
80105b45:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b4b:	c9                   	leave  
80105b4c:	c3                   	ret    

80105b4d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b4d:	55                   	push   %ebp
80105b4e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b50:	8b 45 08             	mov    0x8(%ebp),%eax
80105b53:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b56:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b59:	8b 45 08             	mov    0x8(%ebp),%eax
80105b5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b62:	8b 45 08             	mov    0x8(%ebp),%eax
80105b65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b6c:	90                   	nop
80105b6d:	5d                   	pop    %ebp
80105b6e:	c3                   	ret    

80105b6f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b6f:	55                   	push   %ebp
80105b70:	89 e5                	mov    %esp,%ebp
80105b72:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b75:	e8 52 01 00 00       	call   80105ccc <pushcli>
  if(holding(lk))
80105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7d:	83 ec 0c             	sub    $0xc,%esp
80105b80:	50                   	push   %eax
80105b81:	e8 1c 01 00 00       	call   80105ca2 <holding>
80105b86:	83 c4 10             	add    $0x10,%esp
80105b89:	85 c0                	test   %eax,%eax
80105b8b:	74 0d                	je     80105b9a <acquire+0x2b>
    panic("acquire");
80105b8d:	83 ec 0c             	sub    $0xc,%esp
80105b90:	68 96 98 10 80       	push   $0x80109896
80105b95:	e8 cc a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105b9a:	90                   	nop
80105b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9e:	83 ec 08             	sub    $0x8,%esp
80105ba1:	6a 01                	push   $0x1
80105ba3:	50                   	push   %eax
80105ba4:	e8 8a ff ff ff       	call   80105b33 <xchg>
80105ba9:	83 c4 10             	add    $0x10,%esp
80105bac:	85 c0                	test   %eax,%eax
80105bae:	75 eb                	jne    80105b9b <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bba:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc0:	83 c0 0c             	add    $0xc,%eax
80105bc3:	83 ec 08             	sub    $0x8,%esp
80105bc6:	50                   	push   %eax
80105bc7:	8d 45 08             	lea    0x8(%ebp),%eax
80105bca:	50                   	push   %eax
80105bcb:	e8 58 00 00 00       	call   80105c28 <getcallerpcs>
80105bd0:	83 c4 10             	add    $0x10,%esp
}
80105bd3:	90                   	nop
80105bd4:	c9                   	leave  
80105bd5:	c3                   	ret    

80105bd6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105bd6:	55                   	push   %ebp
80105bd7:	89 e5                	mov    %esp,%ebp
80105bd9:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bdc:	83 ec 0c             	sub    $0xc,%esp
80105bdf:	ff 75 08             	pushl  0x8(%ebp)
80105be2:	e8 bb 00 00 00       	call   80105ca2 <holding>
80105be7:	83 c4 10             	add    $0x10,%esp
80105bea:	85 c0                	test   %eax,%eax
80105bec:	75 0d                	jne    80105bfb <release+0x25>
    panic("release");
80105bee:	83 ec 0c             	sub    $0xc,%esp
80105bf1:	68 9e 98 10 80       	push   $0x8010989e
80105bf6:	e8 6b a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c05:	8b 45 08             	mov    0x8(%ebp),%eax
80105c08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c12:	83 ec 08             	sub    $0x8,%esp
80105c15:	6a 00                	push   $0x0
80105c17:	50                   	push   %eax
80105c18:	e8 16 ff ff ff       	call   80105b33 <xchg>
80105c1d:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c20:	e8 ec 00 00 00       	call   80105d11 <popcli>
}
80105c25:	90                   	nop
80105c26:	c9                   	leave  
80105c27:	c3                   	ret    

80105c28 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c28:	55                   	push   %ebp
80105c29:	89 e5                	mov    %esp,%ebp
80105c2b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c31:	83 e8 08             	sub    $0x8,%eax
80105c34:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c37:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c3e:	eb 38                	jmp    80105c78 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c40:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c44:	74 53                	je     80105c99 <getcallerpcs+0x71>
80105c46:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c4d:	76 4a                	jbe    80105c99 <getcallerpcs+0x71>
80105c4f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c53:	74 44                	je     80105c99 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c58:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c62:	01 c2                	add    %eax,%edx
80105c64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c67:	8b 40 04             	mov    0x4(%eax),%eax
80105c6a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c6f:	8b 00                	mov    (%eax),%eax
80105c71:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c74:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c78:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c7c:	7e c2                	jle    80105c40 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c7e:	eb 19                	jmp    80105c99 <getcallerpcs+0x71>
    pcs[i] = 0;
80105c80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c8d:	01 d0                	add    %edx,%eax
80105c8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c99:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c9d:	7e e1                	jle    80105c80 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105c9f:	90                   	nop
80105ca0:	c9                   	leave  
80105ca1:	c3                   	ret    

80105ca2 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105ca2:	55                   	push   %ebp
80105ca3:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca8:	8b 00                	mov    (%eax),%eax
80105caa:	85 c0                	test   %eax,%eax
80105cac:	74 17                	je     80105cc5 <holding+0x23>
80105cae:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb1:	8b 50 08             	mov    0x8(%eax),%edx
80105cb4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cba:	39 c2                	cmp    %eax,%edx
80105cbc:	75 07                	jne    80105cc5 <holding+0x23>
80105cbe:	b8 01 00 00 00       	mov    $0x1,%eax
80105cc3:	eb 05                	jmp    80105cca <holding+0x28>
80105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cca:	5d                   	pop    %ebp
80105ccb:	c3                   	ret    

80105ccc <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105ccc:	55                   	push   %ebp
80105ccd:	89 e5                	mov    %esp,%ebp
80105ccf:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105cd2:	e8 3e fe ff ff       	call   80105b15 <readeflags>
80105cd7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105cda:	e8 46 fe ff ff       	call   80105b25 <cli>
  if(cpu->ncli++ == 0)
80105cdf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105ce6:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105cec:	8d 48 01             	lea    0x1(%eax),%ecx
80105cef:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105cf5:	85 c0                	test   %eax,%eax
80105cf7:	75 15                	jne    80105d0e <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105cf9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cff:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d02:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d08:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d0e:	90                   	nop
80105d0f:	c9                   	leave  
80105d10:	c3                   	ret    

80105d11 <popcli>:

void
popcli(void)
{
80105d11:	55                   	push   %ebp
80105d12:	89 e5                	mov    %esp,%ebp
80105d14:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d17:	e8 f9 fd ff ff       	call   80105b15 <readeflags>
80105d1c:	25 00 02 00 00       	and    $0x200,%eax
80105d21:	85 c0                	test   %eax,%eax
80105d23:	74 0d                	je     80105d32 <popcli+0x21>
    panic("popcli - interruptible");
80105d25:	83 ec 0c             	sub    $0xc,%esp
80105d28:	68 a6 98 10 80       	push   $0x801098a6
80105d2d:	e8 34 a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d32:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d38:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d3e:	83 ea 01             	sub    $0x1,%edx
80105d41:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d47:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	79 0d                	jns    80105d5e <popcli+0x4d>
    panic("popcli");
80105d51:	83 ec 0c             	sub    $0xc,%esp
80105d54:	68 bd 98 10 80       	push   $0x801098bd
80105d59:	e8 08 a8 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d5e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d64:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d6a:	85 c0                	test   %eax,%eax
80105d6c:	75 15                	jne    80105d83 <popcli+0x72>
80105d6e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d74:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d7a:	85 c0                	test   %eax,%eax
80105d7c:	74 05                	je     80105d83 <popcli+0x72>
    sti();
80105d7e:	e8 a9 fd ff ff       	call   80105b2c <sti>
}
80105d83:	90                   	nop
80105d84:	c9                   	leave  
80105d85:	c3                   	ret    

80105d86 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d86:	55                   	push   %ebp
80105d87:	89 e5                	mov    %esp,%ebp
80105d89:	57                   	push   %edi
80105d8a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d8e:	8b 55 10             	mov    0x10(%ebp),%edx
80105d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d94:	89 cb                	mov    %ecx,%ebx
80105d96:	89 df                	mov    %ebx,%edi
80105d98:	89 d1                	mov    %edx,%ecx
80105d9a:	fc                   	cld    
80105d9b:	f3 aa                	rep stos %al,%es:(%edi)
80105d9d:	89 ca                	mov    %ecx,%edx
80105d9f:	89 fb                	mov    %edi,%ebx
80105da1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105da4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105da7:	90                   	nop
80105da8:	5b                   	pop    %ebx
80105da9:	5f                   	pop    %edi
80105daa:	5d                   	pop    %ebp
80105dab:	c3                   	ret    

80105dac <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dac:	55                   	push   %ebp
80105dad:	89 e5                	mov    %esp,%ebp
80105daf:	57                   	push   %edi
80105db0:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105db4:	8b 55 10             	mov    0x10(%ebp),%edx
80105db7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dba:	89 cb                	mov    %ecx,%ebx
80105dbc:	89 df                	mov    %ebx,%edi
80105dbe:	89 d1                	mov    %edx,%ecx
80105dc0:	fc                   	cld    
80105dc1:	f3 ab                	rep stos %eax,%es:(%edi)
80105dc3:	89 ca                	mov    %ecx,%edx
80105dc5:	89 fb                	mov    %edi,%ebx
80105dc7:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dcd:	90                   	nop
80105dce:	5b                   	pop    %ebx
80105dcf:	5f                   	pop    %edi
80105dd0:	5d                   	pop    %ebp
80105dd1:	c3                   	ret    

80105dd2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105dd2:	55                   	push   %ebp
80105dd3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd8:	83 e0 03             	and    $0x3,%eax
80105ddb:	85 c0                	test   %eax,%eax
80105ddd:	75 43                	jne    80105e22 <memset+0x50>
80105ddf:	8b 45 10             	mov    0x10(%ebp),%eax
80105de2:	83 e0 03             	and    $0x3,%eax
80105de5:	85 c0                	test   %eax,%eax
80105de7:	75 39                	jne    80105e22 <memset+0x50>
    c &= 0xFF;
80105de9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105df0:	8b 45 10             	mov    0x10(%ebp),%eax
80105df3:	c1 e8 02             	shr    $0x2,%eax
80105df6:	89 c1                	mov    %eax,%ecx
80105df8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dfb:	c1 e0 18             	shl    $0x18,%eax
80105dfe:	89 c2                	mov    %eax,%edx
80105e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e03:	c1 e0 10             	shl    $0x10,%eax
80105e06:	09 c2                	or     %eax,%edx
80105e08:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e0b:	c1 e0 08             	shl    $0x8,%eax
80105e0e:	09 d0                	or     %edx,%eax
80105e10:	0b 45 0c             	or     0xc(%ebp),%eax
80105e13:	51                   	push   %ecx
80105e14:	50                   	push   %eax
80105e15:	ff 75 08             	pushl  0x8(%ebp)
80105e18:	e8 8f ff ff ff       	call   80105dac <stosl>
80105e1d:	83 c4 0c             	add    $0xc,%esp
80105e20:	eb 12                	jmp    80105e34 <memset+0x62>
  } else
    stosb(dst, c, n);
80105e22:	8b 45 10             	mov    0x10(%ebp),%eax
80105e25:	50                   	push   %eax
80105e26:	ff 75 0c             	pushl  0xc(%ebp)
80105e29:	ff 75 08             	pushl  0x8(%ebp)
80105e2c:	e8 55 ff ff ff       	call   80105d86 <stosb>
80105e31:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e34:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e37:	c9                   	leave  
80105e38:	c3                   	ret    

80105e39 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e39:	55                   	push   %ebp
80105e3a:	89 e5                	mov    %esp,%ebp
80105e3c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80105e42:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e45:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e48:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e4b:	eb 30                	jmp    80105e7d <memcmp+0x44>
    if(*s1 != *s2)
80105e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e50:	0f b6 10             	movzbl (%eax),%edx
80105e53:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e56:	0f b6 00             	movzbl (%eax),%eax
80105e59:	38 c2                	cmp    %al,%dl
80105e5b:	74 18                	je     80105e75 <memcmp+0x3c>
      return *s1 - *s2;
80105e5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e60:	0f b6 00             	movzbl (%eax),%eax
80105e63:	0f b6 d0             	movzbl %al,%edx
80105e66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e69:	0f b6 00             	movzbl (%eax),%eax
80105e6c:	0f b6 c0             	movzbl %al,%eax
80105e6f:	29 c2                	sub    %eax,%edx
80105e71:	89 d0                	mov    %edx,%eax
80105e73:	eb 1a                	jmp    80105e8f <memcmp+0x56>
    s1++, s2++;
80105e75:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e79:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e7d:	8b 45 10             	mov    0x10(%ebp),%eax
80105e80:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e83:	89 55 10             	mov    %edx,0x10(%ebp)
80105e86:	85 c0                	test   %eax,%eax
80105e88:	75 c3                	jne    80105e4d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105e8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e8f:	c9                   	leave  
80105e90:	c3                   	ret    

80105e91 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105e91:	55                   	push   %ebp
80105e92:	89 e5                	mov    %esp,%ebp
80105e94:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105e97:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ea6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ea9:	73 54                	jae    80105eff <memmove+0x6e>
80105eab:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105eae:	8b 45 10             	mov    0x10(%ebp),%eax
80105eb1:	01 d0                	add    %edx,%eax
80105eb3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105eb6:	76 47                	jbe    80105eff <memmove+0x6e>
    s += n;
80105eb8:	8b 45 10             	mov    0x10(%ebp),%eax
80105ebb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ebe:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105ec4:	eb 13                	jmp    80105ed9 <memmove+0x48>
      *--d = *--s;
80105ec6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105eca:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ece:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ed1:	0f b6 10             	movzbl (%eax),%edx
80105ed4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ed7:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105ed9:	8b 45 10             	mov    0x10(%ebp),%eax
80105edc:	8d 50 ff             	lea    -0x1(%eax),%edx
80105edf:	89 55 10             	mov    %edx,0x10(%ebp)
80105ee2:	85 c0                	test   %eax,%eax
80105ee4:	75 e0                	jne    80105ec6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105ee6:	eb 24                	jmp    80105f0c <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105ee8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105eeb:	8d 50 01             	lea    0x1(%eax),%edx
80105eee:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105ef1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ef4:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ef7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105efa:	0f b6 12             	movzbl (%edx),%edx
80105efd:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105eff:	8b 45 10             	mov    0x10(%ebp),%eax
80105f02:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f05:	89 55 10             	mov    %edx,0x10(%ebp)
80105f08:	85 c0                	test   %eax,%eax
80105f0a:	75 dc                	jne    80105ee8 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f0c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f0f:	c9                   	leave  
80105f10:	c3                   	ret    

80105f11 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f11:	55                   	push   %ebp
80105f12:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f14:	ff 75 10             	pushl  0x10(%ebp)
80105f17:	ff 75 0c             	pushl  0xc(%ebp)
80105f1a:	ff 75 08             	pushl  0x8(%ebp)
80105f1d:	e8 6f ff ff ff       	call   80105e91 <memmove>
80105f22:	83 c4 0c             	add    $0xc,%esp
}
80105f25:	c9                   	leave  
80105f26:	c3                   	ret    

80105f27 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f27:	55                   	push   %ebp
80105f28:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f2a:	eb 0c                	jmp    80105f38 <strncmp+0x11>
    n--, p++, q++;
80105f2c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f30:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f34:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f3c:	74 1a                	je     80105f58 <strncmp+0x31>
80105f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f41:	0f b6 00             	movzbl (%eax),%eax
80105f44:	84 c0                	test   %al,%al
80105f46:	74 10                	je     80105f58 <strncmp+0x31>
80105f48:	8b 45 08             	mov    0x8(%ebp),%eax
80105f4b:	0f b6 10             	movzbl (%eax),%edx
80105f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f51:	0f b6 00             	movzbl (%eax),%eax
80105f54:	38 c2                	cmp    %al,%dl
80105f56:	74 d4                	je     80105f2c <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f5c:	75 07                	jne    80105f65 <strncmp+0x3e>
    return 0;
80105f5e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f63:	eb 16                	jmp    80105f7b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f65:	8b 45 08             	mov    0x8(%ebp),%eax
80105f68:	0f b6 00             	movzbl (%eax),%eax
80105f6b:	0f b6 d0             	movzbl %al,%edx
80105f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f71:	0f b6 00             	movzbl (%eax),%eax
80105f74:	0f b6 c0             	movzbl %al,%eax
80105f77:	29 c2                	sub    %eax,%edx
80105f79:	89 d0                	mov    %edx,%eax
}
80105f7b:	5d                   	pop    %ebp
80105f7c:	c3                   	ret    

80105f7d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f7d:	55                   	push   %ebp
80105f7e:	89 e5                	mov    %esp,%ebp
80105f80:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f83:	8b 45 08             	mov    0x8(%ebp),%eax
80105f86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105f89:	90                   	nop
80105f8a:	8b 45 10             	mov    0x10(%ebp),%eax
80105f8d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f90:	89 55 10             	mov    %edx,0x10(%ebp)
80105f93:	85 c0                	test   %eax,%eax
80105f95:	7e 2c                	jle    80105fc3 <strncpy+0x46>
80105f97:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9a:	8d 50 01             	lea    0x1(%eax),%edx
80105f9d:	89 55 08             	mov    %edx,0x8(%ebp)
80105fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fa3:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fa6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fa9:	0f b6 12             	movzbl (%edx),%edx
80105fac:	88 10                	mov    %dl,(%eax)
80105fae:	0f b6 00             	movzbl (%eax),%eax
80105fb1:	84 c0                	test   %al,%al
80105fb3:	75 d5                	jne    80105f8a <strncpy+0xd>
    ;
  while(n-- > 0)
80105fb5:	eb 0c                	jmp    80105fc3 <strncpy+0x46>
    *s++ = 0;
80105fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80105fba:	8d 50 01             	lea    0x1(%eax),%edx
80105fbd:	89 55 08             	mov    %edx,0x8(%ebp)
80105fc0:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80105fc6:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fc9:	89 55 10             	mov    %edx,0x10(%ebp)
80105fcc:	85 c0                	test   %eax,%eax
80105fce:	7f e7                	jg     80105fb7 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fd3:	c9                   	leave  
80105fd4:	c3                   	ret    

80105fd5 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105fd5:	55                   	push   %ebp
80105fd6:	89 e5                	mov    %esp,%ebp
80105fd8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80105fde:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105fe1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fe5:	7f 05                	jg     80105fec <safestrcpy+0x17>
    return os;
80105fe7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fea:	eb 31                	jmp    8010601d <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105fec:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105ff0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ff4:	7e 1e                	jle    80106014 <safestrcpy+0x3f>
80105ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff9:	8d 50 01             	lea    0x1(%eax),%edx
80105ffc:	89 55 08             	mov    %edx,0x8(%ebp)
80105fff:	8b 55 0c             	mov    0xc(%ebp),%edx
80106002:	8d 4a 01             	lea    0x1(%edx),%ecx
80106005:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106008:	0f b6 12             	movzbl (%edx),%edx
8010600b:	88 10                	mov    %dl,(%eax)
8010600d:	0f b6 00             	movzbl (%eax),%eax
80106010:	84 c0                	test   %al,%al
80106012:	75 d8                	jne    80105fec <safestrcpy+0x17>
    ;
  *s = 0;
80106014:	8b 45 08             	mov    0x8(%ebp),%eax
80106017:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010601a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010601d:	c9                   	leave  
8010601e:	c3                   	ret    

8010601f <strlen>:

int
strlen(const char *s)
{
8010601f:	55                   	push   %ebp
80106020:	89 e5                	mov    %esp,%ebp
80106022:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106025:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010602c:	eb 04                	jmp    80106032 <strlen+0x13>
8010602e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106032:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106035:	8b 45 08             	mov    0x8(%ebp),%eax
80106038:	01 d0                	add    %edx,%eax
8010603a:	0f b6 00             	movzbl (%eax),%eax
8010603d:	84 c0                	test   %al,%al
8010603f:	75 ed                	jne    8010602e <strlen+0xf>
    ;
  return n;
80106041:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106044:	c9                   	leave  
80106045:	c3                   	ret    

80106046 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106046:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010604a:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010604e:	55                   	push   %ebp
  pushl %ebx
8010604f:	53                   	push   %ebx
  pushl %esi
80106050:	56                   	push   %esi
  pushl %edi
80106051:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106052:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106054:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106056:	5f                   	pop    %edi
  popl %esi
80106057:	5e                   	pop    %esi
  popl %ebx
80106058:	5b                   	pop    %ebx
  popl %ebp
80106059:	5d                   	pop    %ebp
  ret
8010605a:	c3                   	ret    

8010605b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010605b:	55                   	push   %ebp
8010605c:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010605e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106064:	8b 00                	mov    (%eax),%eax
80106066:	3b 45 08             	cmp    0x8(%ebp),%eax
80106069:	76 12                	jbe    8010607d <fetchint+0x22>
8010606b:	8b 45 08             	mov    0x8(%ebp),%eax
8010606e:	8d 50 04             	lea    0x4(%eax),%edx
80106071:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106077:	8b 00                	mov    (%eax),%eax
80106079:	39 c2                	cmp    %eax,%edx
8010607b:	76 07                	jbe    80106084 <fetchint+0x29>
    return -1;
8010607d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106082:	eb 0f                	jmp    80106093 <fetchint+0x38>
  *ip = *(int*)(addr);
80106084:	8b 45 08             	mov    0x8(%ebp),%eax
80106087:	8b 10                	mov    (%eax),%edx
80106089:	8b 45 0c             	mov    0xc(%ebp),%eax
8010608c:	89 10                	mov    %edx,(%eax)
  return 0;
8010608e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106093:	5d                   	pop    %ebp
80106094:	c3                   	ret    

80106095 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106095:	55                   	push   %ebp
80106096:	89 e5                	mov    %esp,%ebp
80106098:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010609b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060a1:	8b 00                	mov    (%eax),%eax
801060a3:	3b 45 08             	cmp    0x8(%ebp),%eax
801060a6:	77 07                	ja     801060af <fetchstr+0x1a>
    return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ad:	eb 46                	jmp    801060f5 <fetchstr+0x60>
  *pp = (char*)addr;
801060af:	8b 55 08             	mov    0x8(%ebp),%edx
801060b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b5:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060bd:	8b 00                	mov    (%eax),%eax
801060bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801060c5:	8b 00                	mov    (%eax),%eax
801060c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060ca:	eb 1c                	jmp    801060e8 <fetchstr+0x53>
    if(*s == 0)
801060cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060cf:	0f b6 00             	movzbl (%eax),%eax
801060d2:	84 c0                	test   %al,%al
801060d4:	75 0e                	jne    801060e4 <fetchstr+0x4f>
      return s - *pp;
801060d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801060dc:	8b 00                	mov    (%eax),%eax
801060de:	29 c2                	sub    %eax,%edx
801060e0:	89 d0                	mov    %edx,%eax
801060e2:	eb 11                	jmp    801060f5 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060e4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801060ee:	72 dc                	jb     801060cc <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801060f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060f5:	c9                   	leave  
801060f6:	c3                   	ret    

801060f7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801060f7:	55                   	push   %ebp
801060f8:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801060fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106100:	8b 40 18             	mov    0x18(%eax),%eax
80106103:	8b 40 44             	mov    0x44(%eax),%eax
80106106:	8b 55 08             	mov    0x8(%ebp),%edx
80106109:	c1 e2 02             	shl    $0x2,%edx
8010610c:	01 d0                	add    %edx,%eax
8010610e:	83 c0 04             	add    $0x4,%eax
80106111:	ff 75 0c             	pushl  0xc(%ebp)
80106114:	50                   	push   %eax
80106115:	e8 41 ff ff ff       	call   8010605b <fetchint>
8010611a:	83 c4 08             	add    $0x8,%esp
}
8010611d:	c9                   	leave  
8010611e:	c3                   	ret    

8010611f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010611f:	55                   	push   %ebp
80106120:	89 e5                	mov    %esp,%ebp
80106122:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106125:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106128:	50                   	push   %eax
80106129:	ff 75 08             	pushl  0x8(%ebp)
8010612c:	e8 c6 ff ff ff       	call   801060f7 <argint>
80106131:	83 c4 08             	add    $0x8,%esp
80106134:	85 c0                	test   %eax,%eax
80106136:	79 07                	jns    8010613f <argptr+0x20>
    return -1;
80106138:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613d:	eb 3b                	jmp    8010617a <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010613f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106145:	8b 00                	mov    (%eax),%eax
80106147:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010614a:	39 d0                	cmp    %edx,%eax
8010614c:	76 16                	jbe    80106164 <argptr+0x45>
8010614e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106151:	89 c2                	mov    %eax,%edx
80106153:	8b 45 10             	mov    0x10(%ebp),%eax
80106156:	01 c2                	add    %eax,%edx
80106158:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615e:	8b 00                	mov    (%eax),%eax
80106160:	39 c2                	cmp    %eax,%edx
80106162:	76 07                	jbe    8010616b <argptr+0x4c>
    return -1;
80106164:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106169:	eb 0f                	jmp    8010617a <argptr+0x5b>
  *pp = (char*)i;
8010616b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010616e:	89 c2                	mov    %eax,%edx
80106170:	8b 45 0c             	mov    0xc(%ebp),%eax
80106173:	89 10                	mov    %edx,(%eax)
  return 0;
80106175:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010617a:	c9                   	leave  
8010617b:	c3                   	ret    

8010617c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010617c:	55                   	push   %ebp
8010617d:	89 e5                	mov    %esp,%ebp
8010617f:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106182:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106185:	50                   	push   %eax
80106186:	ff 75 08             	pushl  0x8(%ebp)
80106189:	e8 69 ff ff ff       	call   801060f7 <argint>
8010618e:	83 c4 08             	add    $0x8,%esp
80106191:	85 c0                	test   %eax,%eax
80106193:	79 07                	jns    8010619c <argstr+0x20>
    return -1;
80106195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619a:	eb 0f                	jmp    801061ab <argstr+0x2f>
  return fetchstr(addr, pp);
8010619c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010619f:	ff 75 0c             	pushl  0xc(%ebp)
801061a2:	50                   	push   %eax
801061a3:	e8 ed fe ff ff       	call   80106095 <fetchstr>
801061a8:	83 c4 08             	add    $0x8,%esp
}
801061ab:	c9                   	leave  
801061ac:	c3                   	ret    

801061ad <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061ad:	55                   	push   %ebp
801061ae:	89 e5                	mov    %esp,%ebp
801061b0:	53                   	push   %ebx
801061b1:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ba:	8b 40 18             	mov    0x18(%eax),%eax
801061bd:	8b 40 1c             	mov    0x1c(%eax),%eax
801061c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c7:	7e 30                	jle    801061f9 <syscall+0x4c>
801061c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cc:	83 f8 16             	cmp    $0x16,%eax
801061cf:	77 28                	ja     801061f9 <syscall+0x4c>
801061d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d4:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061db:	85 c0                	test   %eax,%eax
801061dd:	74 1a                	je     801061f9 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e5:	8b 58 18             	mov    0x18(%eax),%ebx
801061e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061eb:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061f2:	ff d0                	call   *%eax
801061f4:	89 43 1c             	mov    %eax,0x1c(%ebx)
801061f7:	eb 34                	jmp    8010622d <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801061f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ff:	8d 50 6c             	lea    0x6c(%eax),%edx
80106202:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106208:	8b 40 10             	mov    0x10(%eax),%eax
8010620b:	ff 75 f4             	pushl  -0xc(%ebp)
8010620e:	52                   	push   %edx
8010620f:	50                   	push   %eax
80106210:	68 c4 98 10 80       	push   $0x801098c4
80106215:	e8 ac a1 ff ff       	call   801003c6 <cprintf>
8010621a:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010621d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106223:	8b 40 18             	mov    0x18(%eax),%eax
80106226:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010622d:	90                   	nop
8010622e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106231:	c9                   	leave  
80106232:	c3                   	ret    

80106233 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
80106233:	55                   	push   %ebp
80106234:	89 e5                	mov    %esp,%ebp
80106236:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
80106239:	83 ec 08             	sub    $0x8,%esp
8010623c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010623f:	50                   	push   %eax
80106240:	ff 75 08             	pushl  0x8(%ebp)
80106243:	e8 af fe ff ff       	call   801060f7 <argint>
80106248:	83 c4 10             	add    $0x10,%esp
8010624b:	85 c0                	test   %eax,%eax
8010624d:	79 07                	jns    80106256 <argfd+0x23>
        return -1;
8010624f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106254:	eb 50                	jmp    801062a6 <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
80106256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106259:	85 c0                	test   %eax,%eax
8010625b:	78 21                	js     8010627e <argfd+0x4b>
8010625d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106260:	83 f8 0f             	cmp    $0xf,%eax
80106263:	7f 19                	jg     8010627e <argfd+0x4b>
80106265:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010626b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010626e:	83 c2 08             	add    $0x8,%edx
80106271:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106275:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106278:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010627c:	75 07                	jne    80106285 <argfd+0x52>
        return -1;
8010627e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106283:	eb 21                	jmp    801062a6 <argfd+0x73>
    if (pfd)
80106285:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106289:	74 08                	je     80106293 <argfd+0x60>
        *pfd = fd;
8010628b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010628e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106291:	89 10                	mov    %edx,(%eax)
    if (pf)
80106293:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106297:	74 08                	je     801062a1 <argfd+0x6e>
        *pf = f;
80106299:	8b 45 10             	mov    0x10(%ebp),%eax
8010629c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010629f:	89 10                	mov    %edx,(%eax)
    return 0;
801062a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a6:	c9                   	leave  
801062a7:	c3                   	ret    

801062a8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062a8:	55                   	push   %ebp
801062a9:	89 e5                	mov    %esp,%ebp
801062ab:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062b5:	eb 30                	jmp    801062e7 <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062c0:	83 c2 08             	add    $0x8,%edx
801062c3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062c7:	85 c0                	test   %eax,%eax
801062c9:	75 18                	jne    801062e3 <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062d4:	8d 4a 08             	lea    0x8(%edx),%ecx
801062d7:	8b 55 08             	mov    0x8(%ebp),%edx
801062da:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801062de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062e1:	eb 0f                	jmp    801062f2 <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062e7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801062eb:	7e ca                	jle    801062b7 <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
801062ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062f2:	c9                   	leave  
801062f3:	c3                   	ret    

801062f4 <sys_dup>:

int sys_dup(void)
{
801062f4:	55                   	push   %ebp
801062f5:	89 e5                	mov    %esp,%ebp
801062f7:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
801062fa:	83 ec 04             	sub    $0x4,%esp
801062fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106300:	50                   	push   %eax
80106301:	6a 00                	push   $0x0
80106303:	6a 00                	push   $0x0
80106305:	e8 29 ff ff ff       	call   80106233 <argfd>
8010630a:	83 c4 10             	add    $0x10,%esp
8010630d:	85 c0                	test   %eax,%eax
8010630f:	79 07                	jns    80106318 <sys_dup+0x24>
        return -1;
80106311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106316:	eb 31                	jmp    80106349 <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106318:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631b:	83 ec 0c             	sub    $0xc,%esp
8010631e:	50                   	push   %eax
8010631f:	e8 84 ff ff ff       	call   801062a8 <fdalloc>
80106324:	83 c4 10             	add    $0x10,%esp
80106327:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010632a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632e:	79 07                	jns    80106337 <sys_dup+0x43>
        return -1;
80106330:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106335:	eb 12                	jmp    80106349 <sys_dup+0x55>
    filedup(f);
80106337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633a:	83 ec 0c             	sub    $0xc,%esp
8010633d:	50                   	push   %eax
8010633e:	e8 15 ad ff ff       	call   80101058 <filedup>
80106343:	83 c4 10             	add    $0x10,%esp
    return fd;
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106349:	c9                   	leave  
8010634a:	c3                   	ret    

8010634b <sys_read>:

int sys_read(void)
{
8010634b:	55                   	push   %ebp
8010634c:	89 e5                	mov    %esp,%ebp
8010634e:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106351:	83 ec 04             	sub    $0x4,%esp
80106354:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106357:	50                   	push   %eax
80106358:	6a 00                	push   $0x0
8010635a:	6a 00                	push   $0x0
8010635c:	e8 d2 fe ff ff       	call   80106233 <argfd>
80106361:	83 c4 10             	add    $0x10,%esp
80106364:	85 c0                	test   %eax,%eax
80106366:	78 2e                	js     80106396 <sys_read+0x4b>
80106368:	83 ec 08             	sub    $0x8,%esp
8010636b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010636e:	50                   	push   %eax
8010636f:	6a 02                	push   $0x2
80106371:	e8 81 fd ff ff       	call   801060f7 <argint>
80106376:	83 c4 10             	add    $0x10,%esp
80106379:	85 c0                	test   %eax,%eax
8010637b:	78 19                	js     80106396 <sys_read+0x4b>
8010637d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106380:	83 ec 04             	sub    $0x4,%esp
80106383:	50                   	push   %eax
80106384:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106387:	50                   	push   %eax
80106388:	6a 01                	push   $0x1
8010638a:	e8 90 fd ff ff       	call   8010611f <argptr>
8010638f:	83 c4 10             	add    $0x10,%esp
80106392:	85 c0                	test   %eax,%eax
80106394:	79 07                	jns    8010639d <sys_read+0x52>
        return -1;
80106396:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639b:	eb 17                	jmp    801063b4 <sys_read+0x69>
    return fileread(f, p, n);
8010639d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a6:	83 ec 04             	sub    $0x4,%esp
801063a9:	51                   	push   %ecx
801063aa:	52                   	push   %edx
801063ab:	50                   	push   %eax
801063ac:	e8 5f ae ff ff       	call   80101210 <fileread>
801063b1:	83 c4 10             	add    $0x10,%esp
}
801063b4:	c9                   	leave  
801063b5:	c3                   	ret    

801063b6 <sys_write>:

int sys_write(void)
{
801063b6:	55                   	push   %ebp
801063b7:	89 e5                	mov    %esp,%ebp
801063b9:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063bc:	83 ec 04             	sub    $0x4,%esp
801063bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063c2:	50                   	push   %eax
801063c3:	6a 00                	push   $0x0
801063c5:	6a 00                	push   $0x0
801063c7:	e8 67 fe ff ff       	call   80106233 <argfd>
801063cc:	83 c4 10             	add    $0x10,%esp
801063cf:	85 c0                	test   %eax,%eax
801063d1:	78 2e                	js     80106401 <sys_write+0x4b>
801063d3:	83 ec 08             	sub    $0x8,%esp
801063d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063d9:	50                   	push   %eax
801063da:	6a 02                	push   $0x2
801063dc:	e8 16 fd ff ff       	call   801060f7 <argint>
801063e1:	83 c4 10             	add    $0x10,%esp
801063e4:	85 c0                	test   %eax,%eax
801063e6:	78 19                	js     80106401 <sys_write+0x4b>
801063e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063eb:	83 ec 04             	sub    $0x4,%esp
801063ee:	50                   	push   %eax
801063ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063f2:	50                   	push   %eax
801063f3:	6a 01                	push   $0x1
801063f5:	e8 25 fd ff ff       	call   8010611f <argptr>
801063fa:	83 c4 10             	add    $0x10,%esp
801063fd:	85 c0                	test   %eax,%eax
801063ff:	79 07                	jns    80106408 <sys_write+0x52>
        return -1;
80106401:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106406:	eb 17                	jmp    8010641f <sys_write+0x69>
    return filewrite(f, p, n);
80106408:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010640b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010640e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106411:	83 ec 04             	sub    $0x4,%esp
80106414:	51                   	push   %ecx
80106415:	52                   	push   %edx
80106416:	50                   	push   %eax
80106417:	e8 ac ae ff ff       	call   801012c8 <filewrite>
8010641c:	83 c4 10             	add    $0x10,%esp
}
8010641f:	c9                   	leave  
80106420:	c3                   	ret    

80106421 <sys_close>:

int sys_close(void)
{
80106421:	55                   	push   %ebp
80106422:	89 e5                	mov    %esp,%ebp
80106424:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
80106427:	83 ec 04             	sub    $0x4,%esp
8010642a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010642d:	50                   	push   %eax
8010642e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106431:	50                   	push   %eax
80106432:	6a 00                	push   $0x0
80106434:	e8 fa fd ff ff       	call   80106233 <argfd>
80106439:	83 c4 10             	add    $0x10,%esp
8010643c:	85 c0                	test   %eax,%eax
8010643e:	79 07                	jns    80106447 <sys_close+0x26>
        return -1;
80106440:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106445:	eb 28                	jmp    8010646f <sys_close+0x4e>
    proc->ofile[fd] = 0;
80106447:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010644d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106450:	83 c2 08             	add    $0x8,%edx
80106453:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010645a:	00 
    fileclose(f);
8010645b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645e:	83 ec 0c             	sub    $0xc,%esp
80106461:	50                   	push   %eax
80106462:	e8 42 ac ff ff       	call   801010a9 <fileclose>
80106467:	83 c4 10             	add    $0x10,%esp
    return 0;
8010646a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646f:	c9                   	leave  
80106470:	c3                   	ret    

80106471 <sys_fstat>:

int sys_fstat(void)
{
80106471:	55                   	push   %ebp
80106472:	89 e5                	mov    %esp,%ebp
80106474:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106477:	83 ec 04             	sub    $0x4,%esp
8010647a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010647d:	50                   	push   %eax
8010647e:	6a 00                	push   $0x0
80106480:	6a 00                	push   $0x0
80106482:	e8 ac fd ff ff       	call   80106233 <argfd>
80106487:	83 c4 10             	add    $0x10,%esp
8010648a:	85 c0                	test   %eax,%eax
8010648c:	78 17                	js     801064a5 <sys_fstat+0x34>
8010648e:	83 ec 04             	sub    $0x4,%esp
80106491:	6a 14                	push   $0x14
80106493:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106496:	50                   	push   %eax
80106497:	6a 01                	push   $0x1
80106499:	e8 81 fc ff ff       	call   8010611f <argptr>
8010649e:	83 c4 10             	add    $0x10,%esp
801064a1:	85 c0                	test   %eax,%eax
801064a3:	79 07                	jns    801064ac <sys_fstat+0x3b>
        return -1;
801064a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064aa:	eb 13                	jmp    801064bf <sys_fstat+0x4e>
    return filestat(f, st);
801064ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b2:	83 ec 08             	sub    $0x8,%esp
801064b5:	52                   	push   %edx
801064b6:	50                   	push   %eax
801064b7:	e8 fd ac ff ff       	call   801011b9 <filestat>
801064bc:	83 c4 10             	add    $0x10,%esp
}
801064bf:	c9                   	leave  
801064c0:	c3                   	ret    

801064c1 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064c1:	55                   	push   %ebp
801064c2:	89 e5                	mov    %esp,%ebp
801064c4:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064c7:	83 ec 08             	sub    $0x8,%esp
801064ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064cd:	50                   	push   %eax
801064ce:	6a 00                	push   $0x0
801064d0:	e8 a7 fc ff ff       	call   8010617c <argstr>
801064d5:	83 c4 10             	add    $0x10,%esp
801064d8:	85 c0                	test   %eax,%eax
801064da:	78 15                	js     801064f1 <sys_link+0x30>
801064dc:	83 ec 08             	sub    $0x8,%esp
801064df:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064e2:	50                   	push   %eax
801064e3:	6a 01                	push   $0x1
801064e5:	e8 92 fc ff ff       	call   8010617c <argstr>
801064ea:	83 c4 10             	add    $0x10,%esp
801064ed:	85 c0                	test   %eax,%eax
801064ef:	79 0a                	jns    801064fb <sys_link+0x3a>
        return -1;
801064f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f6:	e9 da 01 00 00       	jmp    801066d5 <sys_link+0x214>

    begin_op(proc->cwd->part->number);
801064fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106501:	8b 40 68             	mov    0x68(%eax),%eax
80106504:	8b 40 50             	mov    0x50(%eax),%eax
80106507:	8b 40 14             	mov    0x14(%eax),%eax
8010650a:	83 ec 0c             	sub    $0xc,%esp
8010650d:	50                   	push   %eax
8010650e:	e8 68 d9 ff ff       	call   80103e7b <begin_op>
80106513:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
80106516:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106519:	83 ec 0c             	sub    $0xc,%esp
8010651c:	50                   	push   %eax
8010651d:	e8 c4 c7 ff ff       	call   80102ce6 <namei>
80106522:	83 c4 10             	add    $0x10,%esp
80106525:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106528:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010652c:	75 25                	jne    80106553 <sys_link+0x92>
        end_op(proc->cwd->part->number);
8010652e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106534:	8b 40 68             	mov    0x68(%eax),%eax
80106537:	8b 40 50             	mov    0x50(%eax),%eax
8010653a:	8b 40 14             	mov    0x14(%eax),%eax
8010653d:	83 ec 0c             	sub    $0xc,%esp
80106540:	50                   	push   %eax
80106541:	e8 3c da ff ff       	call   80103f82 <end_op>
80106546:	83 c4 10             	add    $0x10,%esp
        return -1;
80106549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654e:	e9 82 01 00 00       	jmp    801066d5 <sys_link+0x214>
    }

    ilock(ip);
80106553:	83 ec 0c             	sub    $0xc,%esp
80106556:	ff 75 f4             	pushl  -0xc(%ebp)
80106559:	e8 77 b9 ff ff       	call   80101ed5 <ilock>
8010655e:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106564:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106568:	66 83 f8 01          	cmp    $0x1,%ax
8010656c:	75 33                	jne    801065a1 <sys_link+0xe0>
        iunlockput(ip);
8010656e:	83 ec 0c             	sub    $0xc,%esp
80106571:	ff 75 f4             	pushl  -0xc(%ebp)
80106574:	e8 5f bc ff ff       	call   801021d8 <iunlockput>
80106579:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
8010657c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106582:	8b 40 68             	mov    0x68(%eax),%eax
80106585:	8b 40 50             	mov    0x50(%eax),%eax
80106588:	8b 40 14             	mov    0x14(%eax),%eax
8010658b:	83 ec 0c             	sub    $0xc,%esp
8010658e:	50                   	push   %eax
8010658f:	e8 ee d9 ff ff       	call   80103f82 <end_op>
80106594:	83 c4 10             	add    $0x10,%esp
        return -1;
80106597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659c:	e9 34 01 00 00       	jmp    801066d5 <sys_link+0x214>
    }

    ip->nlink++;
801065a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065a8:	83 c0 01             	add    $0x1,%eax
801065ab:	89 c2                	mov    %eax,%edx
801065ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b0:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065b4:	83 ec 0c             	sub    $0xc,%esp
801065b7:	ff 75 f4             	pushl  -0xc(%ebp)
801065ba:	e8 b8 b6 ff ff       	call   80101c77 <iupdate>
801065bf:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065c2:	83 ec 0c             	sub    $0xc,%esp
801065c5:	ff 75 f4             	pushl  -0xc(%ebp)
801065c8:	e8 a9 ba ff ff       	call   80102076 <iunlock>
801065cd:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065d3:	83 ec 08             	sub    $0x8,%esp
801065d6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065d9:	52                   	push   %edx
801065da:	50                   	push   %eax
801065db:	e8 3c c7 ff ff       	call   80102d1c <nameiparent>
801065e0:	83 c4 10             	add    $0x10,%esp
801065e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ea:	0f 84 87 00 00 00    	je     80106677 <sys_link+0x1b6>
        goto bad;
    ilock(dp);
801065f0:	83 ec 0c             	sub    $0xc,%esp
801065f3:	ff 75 f0             	pushl  -0x10(%ebp)
801065f6:	e8 da b8 ff ff       	call   80101ed5 <ilock>
801065fb:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
801065fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106601:	8b 10                	mov    (%eax),%edx
80106603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106606:	8b 00                	mov    (%eax),%eax
80106608:	39 c2                	cmp    %eax,%edx
8010660a:	75 1d                	jne    80106629 <sys_link+0x168>
8010660c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660f:	8b 40 04             	mov    0x4(%eax),%eax
80106612:	83 ec 04             	sub    $0x4,%esp
80106615:	50                   	push   %eax
80106616:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106619:	50                   	push   %eax
8010661a:	ff 75 f0             	pushl  -0x10(%ebp)
8010661d:	e8 9e c3 ff ff       	call   801029c0 <dirlink>
80106622:	83 c4 10             	add    $0x10,%esp
80106625:	85 c0                	test   %eax,%eax
80106627:	79 10                	jns    80106639 <sys_link+0x178>
        iunlockput(dp);
80106629:	83 ec 0c             	sub    $0xc,%esp
8010662c:	ff 75 f0             	pushl  -0x10(%ebp)
8010662f:	e8 a4 bb ff ff       	call   801021d8 <iunlockput>
80106634:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106637:	eb 3f                	jmp    80106678 <sys_link+0x1b7>
    }
    iunlockput(dp);
80106639:	83 ec 0c             	sub    $0xc,%esp
8010663c:	ff 75 f0             	pushl  -0x10(%ebp)
8010663f:	e8 94 bb ff ff       	call   801021d8 <iunlockput>
80106644:	83 c4 10             	add    $0x10,%esp
    iput(ip);
80106647:	83 ec 0c             	sub    $0xc,%esp
8010664a:	ff 75 f4             	pushl  -0xc(%ebp)
8010664d:	e8 96 ba ff ff       	call   801020e8 <iput>
80106652:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106655:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010665b:	8b 40 68             	mov    0x68(%eax),%eax
8010665e:	8b 40 50             	mov    0x50(%eax),%eax
80106661:	8b 40 14             	mov    0x14(%eax),%eax
80106664:	83 ec 0c             	sub    $0xc,%esp
80106667:	50                   	push   %eax
80106668:	e8 15 d9 ff ff       	call   80103f82 <end_op>
8010666d:	83 c4 10             	add    $0x10,%esp

    return 0;
80106670:	b8 00 00 00 00       	mov    $0x0,%eax
80106675:	eb 5e                	jmp    801066d5 <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
80106677:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
80106678:	83 ec 0c             	sub    $0xc,%esp
8010667b:	ff 75 f4             	pushl  -0xc(%ebp)
8010667e:	e8 52 b8 ff ff       	call   80101ed5 <ilock>
80106683:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
80106686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106689:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010668d:	83 e8 01             	sub    $0x1,%eax
80106690:	89 c2                	mov    %eax,%edx
80106692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106695:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
80106699:	83 ec 0c             	sub    $0xc,%esp
8010669c:	ff 75 f4             	pushl  -0xc(%ebp)
8010669f:	e8 d3 b5 ff ff       	call   80101c77 <iupdate>
801066a4:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066a7:	83 ec 0c             	sub    $0xc,%esp
801066aa:	ff 75 f4             	pushl  -0xc(%ebp)
801066ad:	e8 26 bb ff ff       	call   801021d8 <iunlockput>
801066b2:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066bb:	8b 40 68             	mov    0x68(%eax),%eax
801066be:	8b 40 50             	mov    0x50(%eax),%eax
801066c1:	8b 40 14             	mov    0x14(%eax),%eax
801066c4:	83 ec 0c             	sub    $0xc,%esp
801066c7:	50                   	push   %eax
801066c8:	e8 b5 d8 ff ff       	call   80103f82 <end_op>
801066cd:	83 c4 10             	add    $0x10,%esp
    return -1;
801066d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066d5:	c9                   	leave  
801066d6:	c3                   	ret    

801066d7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066d7:	55                   	push   %ebp
801066d8:	89 e5                	mov    %esp,%ebp
801066da:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801066dd:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066e4:	eb 40                	jmp    80106726 <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e9:	6a 10                	push   $0x10
801066eb:	50                   	push   %eax
801066ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066ef:	50                   	push   %eax
801066f0:	ff 75 08             	pushl  0x8(%ebp)
801066f3:	e8 6b be ff ff       	call   80102563 <readi>
801066f8:	83 c4 10             	add    $0x10,%esp
801066fb:	83 f8 10             	cmp    $0x10,%eax
801066fe:	74 0d                	je     8010670d <isdirempty+0x36>
            panic("isdirempty: readi");
80106700:	83 ec 0c             	sub    $0xc,%esp
80106703:	68 e0 98 10 80       	push   $0x801098e0
80106708:	e8 59 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
8010670d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106711:	66 85 c0             	test   %ax,%ax
80106714:	74 07                	je     8010671d <isdirempty+0x46>
            return 0;
80106716:	b8 00 00 00 00       	mov    $0x0,%eax
8010671b:	eb 1b                	jmp    80106738 <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
8010671d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106720:	83 c0 10             	add    $0x10,%eax
80106723:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106726:	8b 45 08             	mov    0x8(%ebp),%eax
80106729:	8b 50 18             	mov    0x18(%eax),%edx
8010672c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672f:	39 c2                	cmp    %eax,%edx
80106731:	77 b3                	ja     801066e6 <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
80106733:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106738:	c9                   	leave  
80106739:	c3                   	ret    

8010673a <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
8010673a:	55                   	push   %ebp
8010673b:	89 e5                	mov    %esp,%ebp
8010673d:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106740:	83 ec 08             	sub    $0x8,%esp
80106743:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106746:	50                   	push   %eax
80106747:	6a 00                	push   $0x0
80106749:	e8 2e fa ff ff       	call   8010617c <argstr>
8010674e:	83 c4 10             	add    $0x10,%esp
80106751:	85 c0                	test   %eax,%eax
80106753:	79 0a                	jns    8010675f <sys_unlink+0x25>
        return -1;
80106755:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675a:	e9 14 02 00 00       	jmp    80106973 <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
8010675f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106765:	8b 40 68             	mov    0x68(%eax),%eax
80106768:	8b 40 50             	mov    0x50(%eax),%eax
8010676b:	8b 40 14             	mov    0x14(%eax),%eax
8010676e:	83 ec 0c             	sub    $0xc,%esp
80106771:	50                   	push   %eax
80106772:	e8 04 d7 ff ff       	call   80103e7b <begin_op>
80106777:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
8010677a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010677d:	83 ec 08             	sub    $0x8,%esp
80106780:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106783:	52                   	push   %edx
80106784:	50                   	push   %eax
80106785:	e8 92 c5 ff ff       	call   80102d1c <nameiparent>
8010678a:	83 c4 10             	add    $0x10,%esp
8010678d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106790:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106794:	75 25                	jne    801067bb <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
80106796:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010679c:	8b 40 68             	mov    0x68(%eax),%eax
8010679f:	8b 40 50             	mov    0x50(%eax),%eax
801067a2:	8b 40 14             	mov    0x14(%eax),%eax
801067a5:	83 ec 0c             	sub    $0xc,%esp
801067a8:	50                   	push   %eax
801067a9:	e8 d4 d7 ff ff       	call   80103f82 <end_op>
801067ae:	83 c4 10             	add    $0x10,%esp
        return -1;
801067b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b6:	e9 b8 01 00 00       	jmp    80106973 <sys_unlink+0x239>
    }

    ilock(dp);
801067bb:	83 ec 0c             	sub    $0xc,%esp
801067be:	ff 75 f4             	pushl  -0xc(%ebp)
801067c1:	e8 0f b7 ff ff       	call   80101ed5 <ilock>
801067c6:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067c9:	83 ec 08             	sub    $0x8,%esp
801067cc:	68 f2 98 10 80       	push   $0x801098f2
801067d1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067d4:	50                   	push   %eax
801067d5:	e8 04 c1 ff ff       	call   801028de <namecmp>
801067da:	83 c4 10             	add    $0x10,%esp
801067dd:	85 c0                	test   %eax,%eax
801067df:	0f 84 60 01 00 00    	je     80106945 <sys_unlink+0x20b>
801067e5:	83 ec 08             	sub    $0x8,%esp
801067e8:	68 f4 98 10 80       	push   $0x801098f4
801067ed:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067f0:	50                   	push   %eax
801067f1:	e8 e8 c0 ff ff       	call   801028de <namecmp>
801067f6:	83 c4 10             	add    $0x10,%esp
801067f9:	85 c0                	test   %eax,%eax
801067fb:	0f 84 44 01 00 00    	je     80106945 <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
80106801:	83 ec 04             	sub    $0x4,%esp
80106804:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106807:	50                   	push   %eax
80106808:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010680b:	50                   	push   %eax
8010680c:	ff 75 f4             	pushl  -0xc(%ebp)
8010680f:	e8 e5 c0 ff ff       	call   801028f9 <dirlookup>
80106814:	83 c4 10             	add    $0x10,%esp
80106817:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010681a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010681e:	0f 84 20 01 00 00    	je     80106944 <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
80106824:	83 ec 0c             	sub    $0xc,%esp
80106827:	ff 75 f0             	pushl  -0x10(%ebp)
8010682a:	e8 a6 b6 ff ff       	call   80101ed5 <ilock>
8010682f:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
80106832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106835:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106839:	66 85 c0             	test   %ax,%ax
8010683c:	7f 0d                	jg     8010684b <sys_unlink+0x111>
        panic("unlink: nlink < 1");
8010683e:	83 ec 0c             	sub    $0xc,%esp
80106841:	68 f7 98 10 80       	push   $0x801098f7
80106846:	e8 1b 9d ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
8010684b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010684e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106852:	66 83 f8 01          	cmp    $0x1,%ax
80106856:	75 25                	jne    8010687d <sys_unlink+0x143>
80106858:	83 ec 0c             	sub    $0xc,%esp
8010685b:	ff 75 f0             	pushl  -0x10(%ebp)
8010685e:	e8 74 fe ff ff       	call   801066d7 <isdirempty>
80106863:	83 c4 10             	add    $0x10,%esp
80106866:	85 c0                	test   %eax,%eax
80106868:	75 13                	jne    8010687d <sys_unlink+0x143>
        iunlockput(ip);
8010686a:	83 ec 0c             	sub    $0xc,%esp
8010686d:	ff 75 f0             	pushl  -0x10(%ebp)
80106870:	e8 63 b9 ff ff       	call   801021d8 <iunlockput>
80106875:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106878:	e9 c8 00 00 00       	jmp    80106945 <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
8010687d:	83 ec 04             	sub    $0x4,%esp
80106880:	6a 10                	push   $0x10
80106882:	6a 00                	push   $0x0
80106884:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106887:	50                   	push   %eax
80106888:	e8 45 f5 ff ff       	call   80105dd2 <memset>
8010688d:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106890:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106893:	6a 10                	push   $0x10
80106895:	50                   	push   %eax
80106896:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106899:	50                   	push   %eax
8010689a:	ff 75 f4             	pushl  -0xc(%ebp)
8010689d:	e8 61 be ff ff       	call   80102703 <writei>
801068a2:	83 c4 10             	add    $0x10,%esp
801068a5:	83 f8 10             	cmp    $0x10,%eax
801068a8:	74 0d                	je     801068b7 <sys_unlink+0x17d>
        panic("unlink: writei");
801068aa:	83 ec 0c             	sub    $0xc,%esp
801068ad:	68 09 99 10 80       	push   $0x80109909
801068b2:	e8 af 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068be:	66 83 f8 01          	cmp    $0x1,%ax
801068c2:	75 21                	jne    801068e5 <sys_unlink+0x1ab>
        dp->nlink--;
801068c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068cb:	83 e8 01             	sub    $0x1,%eax
801068ce:	89 c2                	mov    %eax,%edx
801068d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d3:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068d7:	83 ec 0c             	sub    $0xc,%esp
801068da:	ff 75 f4             	pushl  -0xc(%ebp)
801068dd:	e8 95 b3 ff ff       	call   80101c77 <iupdate>
801068e2:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
801068e5:	83 ec 0c             	sub    $0xc,%esp
801068e8:	ff 75 f4             	pushl  -0xc(%ebp)
801068eb:	e8 e8 b8 ff ff       	call   801021d8 <iunlockput>
801068f0:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
801068f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068fa:	83 e8 01             	sub    $0x1,%eax
801068fd:	89 c2                	mov    %eax,%edx
801068ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106902:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
80106906:	83 ec 0c             	sub    $0xc,%esp
80106909:	ff 75 f0             	pushl  -0x10(%ebp)
8010690c:	e8 66 b3 ff ff       	call   80101c77 <iupdate>
80106911:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106914:	83 ec 0c             	sub    $0xc,%esp
80106917:	ff 75 f0             	pushl  -0x10(%ebp)
8010691a:	e8 b9 b8 ff ff       	call   801021d8 <iunlockput>
8010691f:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106922:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106928:	8b 40 68             	mov    0x68(%eax),%eax
8010692b:	8b 40 50             	mov    0x50(%eax),%eax
8010692e:	8b 40 14             	mov    0x14(%eax),%eax
80106931:	83 ec 0c             	sub    $0xc,%esp
80106934:	50                   	push   %eax
80106935:	e8 48 d6 ff ff       	call   80103f82 <end_op>
8010693a:	83 c4 10             	add    $0x10,%esp

    return 0;
8010693d:	b8 00 00 00 00       	mov    $0x0,%eax
80106942:	eb 2f                	jmp    80106973 <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
80106944:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
80106945:	83 ec 0c             	sub    $0xc,%esp
80106948:	ff 75 f4             	pushl  -0xc(%ebp)
8010694b:	e8 88 b8 ff ff       	call   801021d8 <iunlockput>
80106950:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106953:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106959:	8b 40 68             	mov    0x68(%eax),%eax
8010695c:	8b 40 50             	mov    0x50(%eax),%eax
8010695f:	8b 40 14             	mov    0x14(%eax),%eax
80106962:	83 ec 0c             	sub    $0xc,%esp
80106965:	50                   	push   %eax
80106966:	e8 17 d6 ff ff       	call   80103f82 <end_op>
8010696b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010696e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106973:	c9                   	leave  
80106974:	c3                   	ret    

80106975 <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
80106975:	55                   	push   %ebp
80106976:	89 e5                	mov    %esp,%ebp
80106978:	83 ec 38             	sub    $0x38,%esp
8010697b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010697e:	8b 55 10             	mov    0x10(%ebp),%edx
80106981:	8b 45 14             	mov    0x14(%ebp),%eax
80106984:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106988:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010698c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
    // cprintf("path %d  \n",path);
    if ((dp = nameiparent(path, name)) == 0)
80106990:	83 ec 08             	sub    $0x8,%esp
80106993:	8d 45 de             	lea    -0x22(%ebp),%eax
80106996:	50                   	push   %eax
80106997:	ff 75 08             	pushl  0x8(%ebp)
8010699a:	e8 7d c3 ff ff       	call   80102d1c <nameiparent>
8010699f:	83 c4 10             	add    $0x10,%esp
801069a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069a9:	75 0a                	jne    801069b5 <create+0x40>
        return 0;
801069ab:	b8 00 00 00 00       	mov    $0x0,%eax
801069b0:	e9 9c 01 00 00       	jmp    80106b51 <create+0x1dc>
    ilock(dp);
801069b5:	83 ec 0c             	sub    $0xc,%esp
801069b8:	ff 75 f4             	pushl  -0xc(%ebp)
801069bb:	e8 15 b5 ff ff       	call   80101ed5 <ilock>
801069c0:	83 c4 10             	add    $0x10,%esp

    if ((ip = dirlookup(dp, name, &off)) != 0) {
801069c3:	83 ec 04             	sub    $0x4,%esp
801069c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069c9:	50                   	push   %eax
801069ca:	8d 45 de             	lea    -0x22(%ebp),%eax
801069cd:	50                   	push   %eax
801069ce:	ff 75 f4             	pushl  -0xc(%ebp)
801069d1:	e8 23 bf ff ff       	call   801028f9 <dirlookup>
801069d6:	83 c4 10             	add    $0x10,%esp
801069d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069e0:	74 50                	je     80106a32 <create+0xbd>
        iunlockput(dp);
801069e2:	83 ec 0c             	sub    $0xc,%esp
801069e5:	ff 75 f4             	pushl  -0xc(%ebp)
801069e8:	e8 eb b7 ff ff       	call   801021d8 <iunlockput>
801069ed:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801069f0:	83 ec 0c             	sub    $0xc,%esp
801069f3:	ff 75 f0             	pushl  -0x10(%ebp)
801069f6:	e8 da b4 ff ff       	call   80101ed5 <ilock>
801069fb:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
801069fe:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a03:	75 15                	jne    80106a1a <create+0xa5>
80106a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a08:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a0c:	66 83 f8 02          	cmp    $0x2,%ax
80106a10:	75 08                	jne    80106a1a <create+0xa5>
            return ip;
80106a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a15:	e9 37 01 00 00       	jmp    80106b51 <create+0x1dc>
        iunlockput(ip);
80106a1a:	83 ec 0c             	sub    $0xc,%esp
80106a1d:	ff 75 f0             	pushl  -0x10(%ebp)
80106a20:	e8 b3 b7 ff ff       	call   801021d8 <iunlockput>
80106a25:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a28:	b8 00 00 00 00       	mov    $0x0,%eax
80106a2d:	e9 1f 01 00 00       	jmp    80106b51 <create+0x1dc>
    }
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a35:	8b 40 50             	mov    0x50(%eax),%eax
80106a38:	8b 40 14             	mov    0x14(%eax),%eax
80106a3b:	89 c1                	mov    %eax,%ecx
80106a3d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a44:	8b 00                	mov    (%eax),%eax
80106a46:	83 ec 04             	sub    $0x4,%esp
80106a49:	51                   	push   %ecx
80106a4a:	52                   	push   %edx
80106a4b:	50                   	push   %eax
80106a4c:	e8 0d b1 ff ff       	call   80101b5e <ialloc>
80106a51:	83 c4 10             	add    $0x10,%esp
80106a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a5b:	75 0d                	jne    80106a6a <create+0xf5>
        panic("create: ialloc");
80106a5d:	83 ec 0c             	sub    $0xc,%esp
80106a60:	68 18 99 10 80       	push   $0x80109918
80106a65:	e8 fc 9a ff ff       	call   80100566 <panic>

    ilock(ip);
80106a6a:	83 ec 0c             	sub    $0xc,%esp
80106a6d:	ff 75 f0             	pushl  -0x10(%ebp)
80106a70:	e8 60 b4 ff ff       	call   80101ed5 <ilock>
80106a75:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a7b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a7f:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a86:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a8a:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a91:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    iupdate(ip);
80106a97:	83 ec 0c             	sub    $0xc,%esp
80106a9a:	ff 75 f0             	pushl  -0x10(%ebp)
80106a9d:	e8 d5 b1 ff ff       	call   80101c77 <iupdate>
80106aa2:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106aa5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106aaa:	75 6a                	jne    80106b16 <create+0x1a1>
        dp->nlink++;     // for ".."
80106aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aaf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ab3:	83 c0 01             	add    $0x1,%eax
80106ab6:	89 c2                	mov    %eax,%edx
80106ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106abb:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106abf:	83 ec 0c             	sub    $0xc,%esp
80106ac2:	ff 75 f4             	pushl  -0xc(%ebp)
80106ac5:	e8 ad b1 ff ff       	call   80101c77 <iupdate>
80106aca:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ad0:	8b 40 04             	mov    0x4(%eax),%eax
80106ad3:	83 ec 04             	sub    $0x4,%esp
80106ad6:	50                   	push   %eax
80106ad7:	68 f2 98 10 80       	push   $0x801098f2
80106adc:	ff 75 f0             	pushl  -0x10(%ebp)
80106adf:	e8 dc be ff ff       	call   801029c0 <dirlink>
80106ae4:	83 c4 10             	add    $0x10,%esp
80106ae7:	85 c0                	test   %eax,%eax
80106ae9:	78 1e                	js     80106b09 <create+0x194>
80106aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aee:	8b 40 04             	mov    0x4(%eax),%eax
80106af1:	83 ec 04             	sub    $0x4,%esp
80106af4:	50                   	push   %eax
80106af5:	68 f4 98 10 80       	push   $0x801098f4
80106afa:	ff 75 f0             	pushl  -0x10(%ebp)
80106afd:	e8 be be ff ff       	call   801029c0 <dirlink>
80106b02:	83 c4 10             	add    $0x10,%esp
80106b05:	85 c0                	test   %eax,%eax
80106b07:	79 0d                	jns    80106b16 <create+0x1a1>
            panic("create dots");
80106b09:	83 ec 0c             	sub    $0xc,%esp
80106b0c:	68 27 99 10 80       	push   $0x80109927
80106b11:	e8 50 9a ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b19:	8b 40 04             	mov    0x4(%eax),%eax
80106b1c:	83 ec 04             	sub    $0x4,%esp
80106b1f:	50                   	push   %eax
80106b20:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b23:	50                   	push   %eax
80106b24:	ff 75 f4             	pushl  -0xc(%ebp)
80106b27:	e8 94 be ff ff       	call   801029c0 <dirlink>
80106b2c:	83 c4 10             	add    $0x10,%esp
80106b2f:	85 c0                	test   %eax,%eax
80106b31:	79 0d                	jns    80106b40 <create+0x1cb>
        panic("create: dirlink");
80106b33:	83 ec 0c             	sub    $0xc,%esp
80106b36:	68 33 99 10 80       	push   $0x80109933
80106b3b:	e8 26 9a ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b40:	83 ec 0c             	sub    $0xc,%esp
80106b43:	ff 75 f4             	pushl  -0xc(%ebp)
80106b46:	e8 8d b6 ff ff       	call   801021d8 <iunlockput>
80106b4b:	83 c4 10             	add    $0x10,%esp

    return ip;
80106b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b51:	c9                   	leave  
80106b52:	c3                   	ret    

80106b53 <sys_open>:

int sys_open(void)
{
80106b53:	55                   	push   %ebp
80106b54:	89 e5                	mov    %esp,%ebp
80106b56:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b59:	83 ec 08             	sub    $0x8,%esp
80106b5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b5f:	50                   	push   %eax
80106b60:	6a 00                	push   $0x0
80106b62:	e8 15 f6 ff ff       	call   8010617c <argstr>
80106b67:	83 c4 10             	add    $0x10,%esp
80106b6a:	85 c0                	test   %eax,%eax
80106b6c:	78 15                	js     80106b83 <sys_open+0x30>
80106b6e:	83 ec 08             	sub    $0x8,%esp
80106b71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b74:	50                   	push   %eax
80106b75:	6a 01                	push   $0x1
80106b77:	e8 7b f5 ff ff       	call   801060f7 <argint>
80106b7c:	83 c4 10             	add    $0x10,%esp
80106b7f:	85 c0                	test   %eax,%eax
80106b81:	79 07                	jns    80106b8a <sys_open+0x37>
        return -1;
80106b83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b88:	eb 13                	jmp    80106b9d <sys_open+0x4a>

    return openFile(path, omode);
80106b8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b90:	83 ec 08             	sub    $0x8,%esp
80106b93:	52                   	push   %edx
80106b94:	50                   	push   %eax
80106b95:	e8 05 00 00 00       	call   80106b9f <openFile>
80106b9a:	83 c4 10             	add    $0x10,%esp
}
80106b9d:	c9                   	leave  
80106b9e:	c3                   	ret    

80106b9f <openFile>:

int openFile(char* path, int omode)
{
80106b9f:	55                   	push   %ebp
80106ba0:	89 e5                	mov    %esp,%ebp
80106ba2:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106ba5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bab:	8b 40 68             	mov    0x68(%eax),%eax
80106bae:	8b 40 50             	mov    0x50(%eax),%eax
80106bb1:	8b 40 14             	mov    0x14(%eax),%eax
80106bb4:	83 ec 0c             	sub    $0xc,%esp
80106bb7:	50                   	push   %eax
80106bb8:	e8 be d2 ff ff       	call   80103e7b <begin_op>
80106bbd:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bc3:	25 00 02 00 00       	and    $0x200,%eax
80106bc8:	85 c0                	test   %eax,%eax
80106bca:	74 43                	je     80106c0f <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106bcc:	6a 00                	push   $0x0
80106bce:	6a 00                	push   $0x0
80106bd0:	6a 02                	push   $0x2
80106bd2:	ff 75 08             	pushl  0x8(%ebp)
80106bd5:	e8 9b fd ff ff       	call   80106975 <create>
80106bda:	83 c4 10             	add    $0x10,%esp
80106bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106be0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106be4:	0f 85 b5 00 00 00    	jne    80106c9f <openFile+0x100>
            end_op(proc->cwd->part->number);
80106bea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf0:	8b 40 68             	mov    0x68(%eax),%eax
80106bf3:	8b 40 50             	mov    0x50(%eax),%eax
80106bf6:	8b 40 14             	mov    0x14(%eax),%eax
80106bf9:	83 ec 0c             	sub    $0xc,%esp
80106bfc:	50                   	push   %eax
80106bfd:	e8 80 d3 ff ff       	call   80103f82 <end_op>
80106c02:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c0a:	e9 7f 01 00 00       	jmp    80106d8e <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c0f:	83 ec 0c             	sub    $0xc,%esp
80106c12:	ff 75 08             	pushl  0x8(%ebp)
80106c15:	e8 cc c0 ff ff       	call   80102ce6 <namei>
80106c1a:	83 c4 10             	add    $0x10,%esp
80106c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c24:	75 25                	jne    80106c4b <openFile+0xac>
            end_op(proc->cwd->part->number);
80106c26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c2c:	8b 40 68             	mov    0x68(%eax),%eax
80106c2f:	8b 40 50             	mov    0x50(%eax),%eax
80106c32:	8b 40 14             	mov    0x14(%eax),%eax
80106c35:	83 ec 0c             	sub    $0xc,%esp
80106c38:	50                   	push   %eax
80106c39:	e8 44 d3 ff ff       	call   80103f82 <end_op>
80106c3e:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c46:	e9 43 01 00 00       	jmp    80106d8e <openFile+0x1ef>
        }
        ilock(ip);
80106c4b:	83 ec 0c             	sub    $0xc,%esp
80106c4e:	ff 75 f4             	pushl  -0xc(%ebp)
80106c51:	e8 7f b2 ff ff       	call   80101ed5 <ilock>
80106c56:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c5c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c60:	66 83 f8 01          	cmp    $0x1,%ax
80106c64:	75 39                	jne    80106c9f <openFile+0x100>
80106c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106c6a:	74 33                	je     80106c9f <openFile+0x100>
            iunlockput(ip);
80106c6c:	83 ec 0c             	sub    $0xc,%esp
80106c6f:	ff 75 f4             	pushl  -0xc(%ebp)
80106c72:	e8 61 b5 ff ff       	call   801021d8 <iunlockput>
80106c77:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106c7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c80:	8b 40 68             	mov    0x68(%eax),%eax
80106c83:	8b 40 50             	mov    0x50(%eax),%eax
80106c86:	8b 40 14             	mov    0x14(%eax),%eax
80106c89:	83 ec 0c             	sub    $0xc,%esp
80106c8c:	50                   	push   %eax
80106c8d:	e8 f0 d2 ff ff       	call   80103f82 <end_op>
80106c92:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9a:	e9 ef 00 00 00       	jmp    80106d8e <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106c9f:	e8 47 a3 ff ff       	call   80100feb <filealloc>
80106ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ca7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cab:	74 17                	je     80106cc4 <openFile+0x125>
80106cad:	83 ec 0c             	sub    $0xc,%esp
80106cb0:	ff 75 f0             	pushl  -0x10(%ebp)
80106cb3:	e8 f0 f5 ff ff       	call   801062a8 <fdalloc>
80106cb8:	83 c4 10             	add    $0x10,%esp
80106cbb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106cbe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106cc2:	79 47                	jns    80106d0b <openFile+0x16c>
        if (f)
80106cc4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cc8:	74 0e                	je     80106cd8 <openFile+0x139>
            fileclose(f);
80106cca:	83 ec 0c             	sub    $0xc,%esp
80106ccd:	ff 75 f0             	pushl  -0x10(%ebp)
80106cd0:	e8 d4 a3 ff ff       	call   801010a9 <fileclose>
80106cd5:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106cd8:	83 ec 0c             	sub    $0xc,%esp
80106cdb:	ff 75 f4             	pushl  -0xc(%ebp)
80106cde:	e8 f5 b4 ff ff       	call   801021d8 <iunlockput>
80106ce3:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106ce6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cec:	8b 40 68             	mov    0x68(%eax),%eax
80106cef:	8b 40 50             	mov    0x50(%eax),%eax
80106cf2:	8b 40 14             	mov    0x14(%eax),%eax
80106cf5:	83 ec 0c             	sub    $0xc,%esp
80106cf8:	50                   	push   %eax
80106cf9:	e8 84 d2 ff ff       	call   80103f82 <end_op>
80106cfe:	83 c4 10             	add    $0x10,%esp
        return -1;
80106d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d06:	e9 83 00 00 00       	jmp    80106d8e <openFile+0x1ef>
    }
    iunlock(ip);
80106d0b:	83 ec 0c             	sub    $0xc,%esp
80106d0e:	ff 75 f4             	pushl  -0xc(%ebp)
80106d11:	e8 60 b3 ff ff       	call   80102076 <iunlock>
80106d16:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106d19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d1f:	8b 40 68             	mov    0x68(%eax),%eax
80106d22:	8b 40 50             	mov    0x50(%eax),%eax
80106d25:	8b 40 14             	mov    0x14(%eax),%eax
80106d28:	83 ec 0c             	sub    $0xc,%esp
80106d2b:	50                   	push   %eax
80106d2c:	e8 51 d2 ff ff       	call   80103f82 <end_op>
80106d31:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d37:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d43:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d49:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106d50:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d53:	83 e0 01             	and    $0x1,%eax
80106d56:	85 c0                	test   %eax,%eax
80106d58:	0f 94 c0             	sete   %al
80106d5b:	89 c2                	mov    %eax,%edx
80106d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d60:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d66:	83 e0 01             	and    $0x1,%eax
80106d69:	85 c0                	test   %eax,%eax
80106d6b:	75 0a                	jne    80106d77 <openFile+0x1d8>
80106d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d70:	83 e0 02             	and    $0x2,%eax
80106d73:	85 c0                	test   %eax,%eax
80106d75:	74 07                	je     80106d7e <openFile+0x1df>
80106d77:	b8 01 00 00 00       	mov    $0x1,%eax
80106d7c:	eb 05                	jmp    80106d83 <openFile+0x1e4>
80106d7e:	b8 00 00 00 00       	mov    $0x0,%eax
80106d83:	89 c2                	mov    %eax,%edx
80106d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d88:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106d8e:	c9                   	leave  
80106d8f:	c3                   	ret    

80106d90 <sys_mkdir>:

int sys_mkdir(void)
{
80106d90:	55                   	push   %ebp
80106d91:	89 e5                	mov    %esp,%ebp
80106d93:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106d96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d9c:	8b 40 68             	mov    0x68(%eax),%eax
80106d9f:	8b 40 50             	mov    0x50(%eax),%eax
80106da2:	8b 40 14             	mov    0x14(%eax),%eax
80106da5:	83 ec 0c             	sub    $0xc,%esp
80106da8:	50                   	push   %eax
80106da9:	e8 cd d0 ff ff       	call   80103e7b <begin_op>
80106dae:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106db1:	83 ec 08             	sub    $0x8,%esp
80106db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106db7:	50                   	push   %eax
80106db8:	6a 00                	push   $0x0
80106dba:	e8 bd f3 ff ff       	call   8010617c <argstr>
80106dbf:	83 c4 10             	add    $0x10,%esp
80106dc2:	85 c0                	test   %eax,%eax
80106dc4:	78 1b                	js     80106de1 <sys_mkdir+0x51>
80106dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc9:	6a 00                	push   $0x0
80106dcb:	6a 00                	push   $0x0
80106dcd:	6a 01                	push   $0x1
80106dcf:	50                   	push   %eax
80106dd0:	e8 a0 fb ff ff       	call   80106975 <create>
80106dd5:	83 c4 10             	add    $0x10,%esp
80106dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ddb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ddf:	75 22                	jne    80106e03 <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106de1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106de7:	8b 40 68             	mov    0x68(%eax),%eax
80106dea:	8b 40 50             	mov    0x50(%eax),%eax
80106ded:	8b 40 14             	mov    0x14(%eax),%eax
80106df0:	83 ec 0c             	sub    $0xc,%esp
80106df3:	50                   	push   %eax
80106df4:	e8 89 d1 ff ff       	call   80103f82 <end_op>
80106df9:	83 c4 10             	add    $0x10,%esp
        return -1;
80106dfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e01:	eb 2e                	jmp    80106e31 <sys_mkdir+0xa1>
    }
    iunlockput(ip);
80106e03:	83 ec 0c             	sub    $0xc,%esp
80106e06:	ff 75 f4             	pushl  -0xc(%ebp)
80106e09:	e8 ca b3 ff ff       	call   801021d8 <iunlockput>
80106e0e:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e17:	8b 40 68             	mov    0x68(%eax),%eax
80106e1a:	8b 40 50             	mov    0x50(%eax),%eax
80106e1d:	8b 40 14             	mov    0x14(%eax),%eax
80106e20:	83 ec 0c             	sub    $0xc,%esp
80106e23:	50                   	push   %eax
80106e24:	e8 59 d1 ff ff       	call   80103f82 <end_op>
80106e29:	83 c4 10             	add    $0x10,%esp
    return 0;
80106e2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e31:	c9                   	leave  
80106e32:	c3                   	ret    

80106e33 <sys_mknod>:

int sys_mknod(void)
{
80106e33:	55                   	push   %ebp
80106e34:	89 e5                	mov    %esp,%ebp
80106e36:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106e39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e3f:	8b 40 68             	mov    0x68(%eax),%eax
80106e42:	8b 40 50             	mov    0x50(%eax),%eax
80106e45:	8b 40 14             	mov    0x14(%eax),%eax
80106e48:	83 ec 0c             	sub    $0xc,%esp
80106e4b:	50                   	push   %eax
80106e4c:	e8 2a d0 ff ff       	call   80103e7b <begin_op>
80106e51:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106e54:	83 ec 08             	sub    $0x8,%esp
80106e57:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e5a:	50                   	push   %eax
80106e5b:	6a 00                	push   $0x0
80106e5d:	e8 1a f3 ff ff       	call   8010617c <argstr>
80106e62:	83 c4 10             	add    $0x10,%esp
80106e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e6c:	78 4f                	js     80106ebd <sys_mknod+0x8a>
80106e6e:	83 ec 08             	sub    $0x8,%esp
80106e71:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e74:	50                   	push   %eax
80106e75:	6a 01                	push   $0x1
80106e77:	e8 7b f2 ff ff       	call   801060f7 <argint>
80106e7c:	83 c4 10             	add    $0x10,%esp
80106e7f:	85 c0                	test   %eax,%eax
80106e81:	78 3a                	js     80106ebd <sys_mknod+0x8a>
80106e83:	83 ec 08             	sub    $0x8,%esp
80106e86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e89:	50                   	push   %eax
80106e8a:	6a 02                	push   $0x2
80106e8c:	e8 66 f2 ff ff       	call   801060f7 <argint>
80106e91:	83 c4 10             	add    $0x10,%esp
80106e94:	85 c0                	test   %eax,%eax
80106e96:	78 25                	js     80106ebd <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e9b:	0f bf c8             	movswl %ax,%ecx
80106e9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ea1:	0f bf d0             	movswl %ax,%edx
80106ea4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106ea7:	51                   	push   %ecx
80106ea8:	52                   	push   %edx
80106ea9:	6a 03                	push   $0x3
80106eab:	50                   	push   %eax
80106eac:	e8 c4 fa ff ff       	call   80106975 <create>
80106eb1:	83 c4 10             	add    $0x10,%esp
80106eb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106eb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ebb:	75 22                	jne    80106edf <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106ebd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec3:	8b 40 68             	mov    0x68(%eax),%eax
80106ec6:	8b 40 50             	mov    0x50(%eax),%eax
80106ec9:	8b 40 14             	mov    0x14(%eax),%eax
80106ecc:	83 ec 0c             	sub    $0xc,%esp
80106ecf:	50                   	push   %eax
80106ed0:	e8 ad d0 ff ff       	call   80103f82 <end_op>
80106ed5:	83 c4 10             	add    $0x10,%esp
        return -1;
80106ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106edd:	eb 2e                	jmp    80106f0d <sys_mknod+0xda>
    }
    iunlockput(ip);
80106edf:	83 ec 0c             	sub    $0xc,%esp
80106ee2:	ff 75 f0             	pushl  -0x10(%ebp)
80106ee5:	e8 ee b2 ff ff       	call   801021d8 <iunlockput>
80106eea:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106eed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef3:	8b 40 68             	mov    0x68(%eax),%eax
80106ef6:	8b 40 50             	mov    0x50(%eax),%eax
80106ef9:	8b 40 14             	mov    0x14(%eax),%eax
80106efc:	83 ec 0c             	sub    $0xc,%esp
80106eff:	50                   	push   %eax
80106f00:	e8 7d d0 ff ff       	call   80103f82 <end_op>
80106f05:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f0d:	c9                   	leave  
80106f0e:	c3                   	ret    

80106f0f <sys_chdir>:

int sys_chdir(void)
{
80106f0f:	55                   	push   %ebp
80106f10:	89 e5                	mov    %esp,%ebp
80106f12:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106f15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f1b:	8b 40 68             	mov    0x68(%eax),%eax
80106f1e:	8b 40 50             	mov    0x50(%eax),%eax
80106f21:	8b 40 14             	mov    0x14(%eax),%eax
80106f24:	83 ec 0c             	sub    $0xc,%esp
80106f27:	50                   	push   %eax
80106f28:	e8 4e cf ff ff       	call   80103e7b <begin_op>
80106f2d:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106f30:	83 ec 08             	sub    $0x8,%esp
80106f33:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f36:	50                   	push   %eax
80106f37:	6a 00                	push   $0x0
80106f39:	e8 3e f2 ff ff       	call   8010617c <argstr>
80106f3e:	83 c4 10             	add    $0x10,%esp
80106f41:	85 c0                	test   %eax,%eax
80106f43:	78 18                	js     80106f5d <sys_chdir+0x4e>
80106f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f48:	83 ec 0c             	sub    $0xc,%esp
80106f4b:	50                   	push   %eax
80106f4c:	e8 95 bd ff ff       	call   80102ce6 <namei>
80106f51:	83 c4 10             	add    $0x10,%esp
80106f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f5b:	75 25                	jne    80106f82 <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106f5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f63:	8b 40 68             	mov    0x68(%eax),%eax
80106f66:	8b 40 50             	mov    0x50(%eax),%eax
80106f69:	8b 40 14             	mov    0x14(%eax),%eax
80106f6c:	83 ec 0c             	sub    $0xc,%esp
80106f6f:	50                   	push   %eax
80106f70:	e8 0d d0 ff ff       	call   80103f82 <end_op>
80106f75:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f7d:	e9 9a 00 00 00       	jmp    8010701c <sys_chdir+0x10d>
    }
    ilock(ip);
80106f82:	83 ec 0c             	sub    $0xc,%esp
80106f85:	ff 75 f4             	pushl  -0xc(%ebp)
80106f88:	e8 48 af ff ff       	call   80101ed5 <ilock>
80106f8d:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
80106f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f93:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106f97:	66 83 f8 01          	cmp    $0x1,%ax
80106f9b:	74 30                	je     80106fcd <sys_chdir+0xbe>
        iunlockput(ip);
80106f9d:	83 ec 0c             	sub    $0xc,%esp
80106fa0:	ff 75 f4             	pushl  -0xc(%ebp)
80106fa3:	e8 30 b2 ff ff       	call   801021d8 <iunlockput>
80106fa8:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fb1:	8b 40 68             	mov    0x68(%eax),%eax
80106fb4:	8b 40 50             	mov    0x50(%eax),%eax
80106fb7:	8b 40 14             	mov    0x14(%eax),%eax
80106fba:	83 ec 0c             	sub    $0xc,%esp
80106fbd:	50                   	push   %eax
80106fbe:	e8 bf cf ff ff       	call   80103f82 <end_op>
80106fc3:	83 c4 10             	add    $0x10,%esp
        return -1;
80106fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fcb:	eb 4f                	jmp    8010701c <sys_chdir+0x10d>
    }
    iunlock(ip);
80106fcd:	83 ec 0c             	sub    $0xc,%esp
80106fd0:	ff 75 f4             	pushl  -0xc(%ebp)
80106fd3:	e8 9e b0 ff ff       	call   80102076 <iunlock>
80106fd8:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80106fdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fe1:	8b 40 68             	mov    0x68(%eax),%eax
80106fe4:	83 ec 0c             	sub    $0xc,%esp
80106fe7:	50                   	push   %eax
80106fe8:	e8 fb b0 ff ff       	call   801020e8 <iput>
80106fed:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ff6:	8b 40 68             	mov    0x68(%eax),%eax
80106ff9:	8b 40 50             	mov    0x50(%eax),%eax
80106ffc:	8b 40 14             	mov    0x14(%eax),%eax
80106fff:	83 ec 0c             	sub    $0xc,%esp
80107002:	50                   	push   %eax
80107003:	e8 7a cf ff ff       	call   80103f82 <end_op>
80107008:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
8010700b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107011:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107014:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
80107017:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010701c:	c9                   	leave  
8010701d:	c3                   	ret    

8010701e <sys_exec>:

int sys_exec(void)
{
8010701e:	55                   	push   %ebp
8010701f:	89 e5                	mov    %esp,%ebp
80107021:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
80107027:	83 ec 08             	sub    $0x8,%esp
8010702a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010702d:	50                   	push   %eax
8010702e:	6a 00                	push   $0x0
80107030:	e8 47 f1 ff ff       	call   8010617c <argstr>
80107035:	83 c4 10             	add    $0x10,%esp
80107038:	85 c0                	test   %eax,%eax
8010703a:	78 18                	js     80107054 <sys_exec+0x36>
8010703c:	83 ec 08             	sub    $0x8,%esp
8010703f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107045:	50                   	push   %eax
80107046:	6a 01                	push   $0x1
80107048:	e8 aa f0 ff ff       	call   801060f7 <argint>
8010704d:	83 c4 10             	add    $0x10,%esp
80107050:	85 c0                	test   %eax,%eax
80107052:	79 0a                	jns    8010705e <sys_exec+0x40>
        return -1;
80107054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107059:	e9 c6 00 00 00       	jmp    80107124 <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
8010705e:	83 ec 04             	sub    $0x4,%esp
80107061:	68 80 00 00 00       	push   $0x80
80107066:	6a 00                	push   $0x0
80107068:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010706e:	50                   	push   %eax
8010706f:	e8 5e ed ff ff       	call   80105dd2 <memset>
80107074:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
80107077:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
8010707e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107081:	83 f8 1f             	cmp    $0x1f,%eax
80107084:	76 0a                	jbe    80107090 <sys_exec+0x72>
            return -1;
80107086:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010708b:	e9 94 00 00 00       	jmp    80107124 <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
80107090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107093:	c1 e0 02             	shl    $0x2,%eax
80107096:	89 c2                	mov    %eax,%edx
80107098:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010709e:	01 c2                	add    %eax,%edx
801070a0:	83 ec 08             	sub    $0x8,%esp
801070a3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801070a9:	50                   	push   %eax
801070aa:	52                   	push   %edx
801070ab:	e8 ab ef ff ff       	call   8010605b <fetchint>
801070b0:	83 c4 10             	add    $0x10,%esp
801070b3:	85 c0                	test   %eax,%eax
801070b5:	79 07                	jns    801070be <sys_exec+0xa0>
            return -1;
801070b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070bc:	eb 66                	jmp    80107124 <sys_exec+0x106>
        if (uarg == 0) {
801070be:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801070c4:	85 c0                	test   %eax,%eax
801070c6:	75 27                	jne    801070ef <sys_exec+0xd1>
            argv[i] = 0;
801070c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070cb:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801070d2:	00 00 00 00 
            break;
801070d6:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
801070d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070da:	83 ec 08             	sub    $0x8,%esp
801070dd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801070e3:	52                   	push   %edx
801070e4:	50                   	push   %eax
801070e5:	e8 87 9a ff ff       	call   80100b71 <exec>
801070ea:	83 c4 10             	add    $0x10,%esp
801070ed:	eb 35                	jmp    80107124 <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
801070ef:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801070f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070f8:	c1 e2 02             	shl    $0x2,%edx
801070fb:	01 c2                	add    %eax,%edx
801070fd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107103:	83 ec 08             	sub    $0x8,%esp
80107106:	52                   	push   %edx
80107107:	50                   	push   %eax
80107108:	e8 88 ef ff ff       	call   80106095 <fetchstr>
8010710d:	83 c4 10             	add    $0x10,%esp
80107110:	85 c0                	test   %eax,%eax
80107112:	79 07                	jns    8010711b <sys_exec+0xfd>
            return -1;
80107114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107119:	eb 09                	jmp    80107124 <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
8010711b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
8010711f:	e9 5a ff ff ff       	jmp    8010707e <sys_exec+0x60>
    return exec(path, argv);
}
80107124:	c9                   	leave  
80107125:	c3                   	ret    

80107126 <sys_pipe>:

int sys_pipe(void)
{
80107126:	55                   	push   %ebp
80107127:	89 e5                	mov    %esp,%ebp
80107129:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
8010712c:	83 ec 04             	sub    $0x4,%esp
8010712f:	6a 08                	push   $0x8
80107131:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107134:	50                   	push   %eax
80107135:	6a 00                	push   $0x0
80107137:	e8 e3 ef ff ff       	call   8010611f <argptr>
8010713c:	83 c4 10             	add    $0x10,%esp
8010713f:	85 c0                	test   %eax,%eax
80107141:	79 0a                	jns    8010714d <sys_pipe+0x27>
        return -1;
80107143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107148:	e9 af 00 00 00       	jmp    801071fc <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
8010714d:	83 ec 08             	sub    $0x8,%esp
80107150:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107153:	50                   	push   %eax
80107154:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107157:	50                   	push   %eax
80107158:	e8 ee d9 ff ff       	call   80104b4b <pipealloc>
8010715d:	83 c4 10             	add    $0x10,%esp
80107160:	85 c0                	test   %eax,%eax
80107162:	79 0a                	jns    8010716e <sys_pipe+0x48>
        return -1;
80107164:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107169:	e9 8e 00 00 00       	jmp    801071fc <sys_pipe+0xd6>
    fd0 = -1;
8010716e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80107175:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107178:	83 ec 0c             	sub    $0xc,%esp
8010717b:	50                   	push   %eax
8010717c:	e8 27 f1 ff ff       	call   801062a8 <fdalloc>
80107181:	83 c4 10             	add    $0x10,%esp
80107184:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010718b:	78 18                	js     801071a5 <sys_pipe+0x7f>
8010718d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107190:	83 ec 0c             	sub    $0xc,%esp
80107193:	50                   	push   %eax
80107194:	e8 0f f1 ff ff       	call   801062a8 <fdalloc>
80107199:	83 c4 10             	add    $0x10,%esp
8010719c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010719f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801071a3:	79 3f                	jns    801071e4 <sys_pipe+0xbe>
        if (fd0 >= 0)
801071a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071a9:	78 14                	js     801071bf <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
801071ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071b4:	83 c2 08             	add    $0x8,%edx
801071b7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801071be:	00 
        fileclose(rf);
801071bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071c2:	83 ec 0c             	sub    $0xc,%esp
801071c5:	50                   	push   %eax
801071c6:	e8 de 9e ff ff       	call   801010a9 <fileclose>
801071cb:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
801071ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071d1:	83 ec 0c             	sub    $0xc,%esp
801071d4:	50                   	push   %eax
801071d5:	e8 cf 9e ff ff       	call   801010a9 <fileclose>
801071da:	83 c4 10             	add    $0x10,%esp
        return -1;
801071dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e2:	eb 18                	jmp    801071fc <sys_pipe+0xd6>
    }
    fd[0] = fd0;
801071e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071ea:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
801071ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071ef:	8d 50 04             	lea    0x4(%eax),%edx
801071f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071f5:	89 02                	mov    %eax,(%edx)
    return 0;
801071f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071fc:	c9                   	leave  
801071fd:	c3                   	ret    

801071fe <sys_mount>:

int sys_mount(void)
{
801071fe:	55                   	push   %ebp
801071ff:	89 e5                	mov    %esp,%ebp
80107201:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
80107204:	83 ec 08             	sub    $0x8,%esp
80107207:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010720a:	50                   	push   %eax
8010720b:	6a 00                	push   $0x0
8010720d:	e8 6a ef ff ff       	call   8010617c <argstr>
80107212:	83 c4 10             	add    $0x10,%esp
80107215:	85 c0                	test   %eax,%eax
80107217:	78 1d                	js     80107236 <sys_mount+0x38>
80107219:	83 ec 08             	sub    $0x8,%esp
8010721c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010721f:	50                   	push   %eax
80107220:	6a 01                	push   $0x1
80107222:	e8 d0 ee ff ff       	call   801060f7 <argint>
80107227:	83 c4 10             	add    $0x10,%esp
8010722a:	85 c0                	test   %eax,%eax
8010722c:	78 08                	js     80107236 <sys_mount+0x38>
8010722e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107231:	83 f8 04             	cmp    $0x4,%eax
80107234:	76 07                	jbe    8010723d <sys_mount+0x3f>
        return -1;
80107236:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010723b:	eb 55                	jmp    80107292 <sys_mount+0x94>
    }

    i=nameiIgnoreMounts(path);
8010723d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107240:	83 ec 0c             	sub    $0xc,%esp
80107243:	50                   	push   %eax
80107244:	e8 b8 ba ff ff       	call   80102d01 <nameiIgnoreMounts>
80107249:	83 c4 10             	add    $0x10,%esp
8010724c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
8010724f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107253:	75 07                	jne    8010725c <sys_mount+0x5e>
        return -1;
80107255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010725a:	eb 36                	jmp    80107292 <sys_mount+0x94>
    }
    ilock(i);
8010725c:	83 ec 0c             	sub    $0xc,%esp
8010725f:	ff 75 f4             	pushl  -0xc(%ebp)
80107262:	e8 6e ac ff ff       	call   80101ed5 <ilock>
80107267:	83 c4 10             	add    $0x10,%esp
    i->major=MOUNTING_POINT;
8010726a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726d:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
80107273:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107276:	89 c2                	mov    %eax,%edx
80107278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727b:	66 89 50 14          	mov    %dx,0x14(%eax)
   // iupdate(i);
    iunlockput(i);
8010727f:	83 ec 0c             	sub    $0xc,%esp
80107282:	ff 75 f4             	pushl  -0xc(%ebp)
80107285:	e8 4e af ff ff       	call   801021d8 <iunlockput>
8010728a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010728d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107292:	c9                   	leave  
80107293:	c3                   	ret    

80107294 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80107294:	55                   	push   %ebp
80107295:	89 e5                	mov    %esp,%ebp
80107297:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010729a:	e8 a2 df ff ff       	call   80105241 <fork>
}
8010729f:	c9                   	leave  
801072a0:	c3                   	ret    

801072a1 <sys_exit>:

int
sys_exit(void)
{
801072a1:	55                   	push   %ebp
801072a2:	89 e5                	mov    %esp,%ebp
801072a4:	83 ec 08             	sub    $0x8,%esp
  exit();
801072a7:	e8 26 e1 ff ff       	call   801053d2 <exit>
  return 0;  // not reached
801072ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072b1:	c9                   	leave  
801072b2:	c3                   	ret    

801072b3 <sys_wait>:

int
sys_wait(void)
{
801072b3:	55                   	push   %ebp
801072b4:	89 e5                	mov    %esp,%ebp
801072b6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801072b9:	e8 78 e2 ff ff       	call   80105536 <wait>
}
801072be:	c9                   	leave  
801072bf:	c3                   	ret    

801072c0 <sys_kill>:

int
sys_kill(void)
{
801072c0:	55                   	push   %ebp
801072c1:	89 e5                	mov    %esp,%ebp
801072c3:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801072c6:	83 ec 08             	sub    $0x8,%esp
801072c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072cc:	50                   	push   %eax
801072cd:	6a 00                	push   $0x0
801072cf:	e8 23 ee ff ff       	call   801060f7 <argint>
801072d4:	83 c4 10             	add    $0x10,%esp
801072d7:	85 c0                	test   %eax,%eax
801072d9:	79 07                	jns    801072e2 <sys_kill+0x22>
    return -1;
801072db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072e0:	eb 0f                	jmp    801072f1 <sys_kill+0x31>
  return kill(pid);
801072e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e5:	83 ec 0c             	sub    $0xc,%esp
801072e8:	50                   	push   %eax
801072e9:	e8 aa e6 ff ff       	call   80105998 <kill>
801072ee:	83 c4 10             	add    $0x10,%esp
}
801072f1:	c9                   	leave  
801072f2:	c3                   	ret    

801072f3 <sys_getpid>:

int
sys_getpid(void)
{
801072f3:	55                   	push   %ebp
801072f4:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801072f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072fc:	8b 40 10             	mov    0x10(%eax),%eax
}
801072ff:	5d                   	pop    %ebp
80107300:	c3                   	ret    

80107301 <sys_sbrk>:

int
sys_sbrk(void)
{
80107301:	55                   	push   %ebp
80107302:	89 e5                	mov    %esp,%ebp
80107304:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107307:	83 ec 08             	sub    $0x8,%esp
8010730a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010730d:	50                   	push   %eax
8010730e:	6a 00                	push   $0x0
80107310:	e8 e2 ed ff ff       	call   801060f7 <argint>
80107315:	83 c4 10             	add    $0x10,%esp
80107318:	85 c0                	test   %eax,%eax
8010731a:	79 07                	jns    80107323 <sys_sbrk+0x22>
    return -1;
8010731c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107321:	eb 28                	jmp    8010734b <sys_sbrk+0x4a>
  addr = proc->sz;
80107323:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107329:	8b 00                	mov    (%eax),%eax
8010732b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010732e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107331:	83 ec 0c             	sub    $0xc,%esp
80107334:	50                   	push   %eax
80107335:	e8 64 de ff ff       	call   8010519e <growproc>
8010733a:	83 c4 10             	add    $0x10,%esp
8010733d:	85 c0                	test   %eax,%eax
8010733f:	79 07                	jns    80107348 <sys_sbrk+0x47>
    return -1;
80107341:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107346:	eb 03                	jmp    8010734b <sys_sbrk+0x4a>
  return addr;
80107348:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010734b:	c9                   	leave  
8010734c:	c3                   	ret    

8010734d <sys_sleep>:

int
sys_sleep(void)
{
8010734d:	55                   	push   %ebp
8010734e:	89 e5                	mov    %esp,%ebp
80107350:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107353:	83 ec 08             	sub    $0x8,%esp
80107356:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107359:	50                   	push   %eax
8010735a:	6a 00                	push   $0x0
8010735c:	e8 96 ed ff ff       	call   801060f7 <argint>
80107361:	83 c4 10             	add    $0x10,%esp
80107364:	85 c0                	test   %eax,%eax
80107366:	79 07                	jns    8010736f <sys_sleep+0x22>
    return -1;
80107368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010736d:	eb 77                	jmp    801073e6 <sys_sleep+0x99>
  acquire(&tickslock);
8010736f:	83 ec 0c             	sub    $0xc,%esp
80107372:	68 c0 5d 11 80       	push   $0x80115dc0
80107377:	e8 f3 e7 ff ff       	call   80105b6f <acquire>
8010737c:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010737f:	a1 00 66 11 80       	mov    0x80116600,%eax
80107384:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107387:	eb 39                	jmp    801073c2 <sys_sleep+0x75>
    if(proc->killed){
80107389:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010738f:	8b 40 24             	mov    0x24(%eax),%eax
80107392:	85 c0                	test   %eax,%eax
80107394:	74 17                	je     801073ad <sys_sleep+0x60>
      release(&tickslock);
80107396:	83 ec 0c             	sub    $0xc,%esp
80107399:	68 c0 5d 11 80       	push   $0x80115dc0
8010739e:	e8 33 e8 ff ff       	call   80105bd6 <release>
801073a3:	83 c4 10             	add    $0x10,%esp
      return -1;
801073a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ab:	eb 39                	jmp    801073e6 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801073ad:	83 ec 08             	sub    $0x8,%esp
801073b0:	68 c0 5d 11 80       	push   $0x80115dc0
801073b5:	68 00 66 11 80       	push   $0x80116600
801073ba:	e8 b7 e4 ff ff       	call   80105876 <sleep>
801073bf:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801073c2:	a1 00 66 11 80       	mov    0x80116600,%eax
801073c7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801073ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073cd:	39 d0                	cmp    %edx,%eax
801073cf:	72 b8                	jb     80107389 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801073d1:	83 ec 0c             	sub    $0xc,%esp
801073d4:	68 c0 5d 11 80       	push   $0x80115dc0
801073d9:	e8 f8 e7 ff ff       	call   80105bd6 <release>
801073de:	83 c4 10             	add    $0x10,%esp
  return 0;
801073e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073e6:	c9                   	leave  
801073e7:	c3                   	ret    

801073e8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801073e8:	55                   	push   %ebp
801073e9:	89 e5                	mov    %esp,%ebp
801073eb:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801073ee:	83 ec 0c             	sub    $0xc,%esp
801073f1:	68 c0 5d 11 80       	push   $0x80115dc0
801073f6:	e8 74 e7 ff ff       	call   80105b6f <acquire>
801073fb:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801073fe:	a1 00 66 11 80       	mov    0x80116600,%eax
80107403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107406:	83 ec 0c             	sub    $0xc,%esp
80107409:	68 c0 5d 11 80       	push   $0x80115dc0
8010740e:	e8 c3 e7 ff ff       	call   80105bd6 <release>
80107413:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107416:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107419:	c9                   	leave  
8010741a:	c3                   	ret    

8010741b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010741b:	55                   	push   %ebp
8010741c:	89 e5                	mov    %esp,%ebp
8010741e:	83 ec 08             	sub    $0x8,%esp
80107421:	8b 55 08             	mov    0x8(%ebp),%edx
80107424:	8b 45 0c             	mov    0xc(%ebp),%eax
80107427:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010742b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010742e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107432:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107436:	ee                   	out    %al,(%dx)
}
80107437:	90                   	nop
80107438:	c9                   	leave  
80107439:	c3                   	ret    

8010743a <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010743a:	55                   	push   %ebp
8010743b:	89 e5                	mov    %esp,%ebp
8010743d:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107440:	6a 34                	push   $0x34
80107442:	6a 43                	push   $0x43
80107444:	e8 d2 ff ff ff       	call   8010741b <outb>
80107449:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010744c:	68 9c 00 00 00       	push   $0x9c
80107451:	6a 40                	push   $0x40
80107453:	e8 c3 ff ff ff       	call   8010741b <outb>
80107458:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010745b:	6a 2e                	push   $0x2e
8010745d:	6a 40                	push   $0x40
8010745f:	e8 b7 ff ff ff       	call   8010741b <outb>
80107464:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107467:	83 ec 0c             	sub    $0xc,%esp
8010746a:	6a 00                	push   $0x0
8010746c:	e8 c4 d5 ff ff       	call   80104a35 <picenable>
80107471:	83 c4 10             	add    $0x10,%esp
}
80107474:	90                   	nop
80107475:	c9                   	leave  
80107476:	c3                   	ret    

80107477 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107477:	1e                   	push   %ds
  pushl %es
80107478:	06                   	push   %es
  pushl %fs
80107479:	0f a0                	push   %fs
  pushl %gs
8010747b:	0f a8                	push   %gs
  pushal
8010747d:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010747e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107482:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107484:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107486:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010748a:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010748c:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010748e:	54                   	push   %esp
  call trap
8010748f:	e8 d7 01 00 00       	call   8010766b <trap>
  addl $4, %esp
80107494:	83 c4 04             	add    $0x4,%esp

80107497 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107497:	61                   	popa   
  popl %gs
80107498:	0f a9                	pop    %gs
  popl %fs
8010749a:	0f a1                	pop    %fs
  popl %es
8010749c:	07                   	pop    %es
  popl %ds
8010749d:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010749e:	83 c4 08             	add    $0x8,%esp
  iret
801074a1:	cf                   	iret   

801074a2 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801074a2:	55                   	push   %ebp
801074a3:	89 e5                	mov    %esp,%ebp
801074a5:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801074a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801074ab:	83 e8 01             	sub    $0x1,%eax
801074ae:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074b2:	8b 45 08             	mov    0x8(%ebp),%eax
801074b5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074b9:	8b 45 08             	mov    0x8(%ebp),%eax
801074bc:	c1 e8 10             	shr    $0x10,%eax
801074bf:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801074c3:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074c6:	0f 01 18             	lidtl  (%eax)
}
801074c9:	90                   	nop
801074ca:	c9                   	leave  
801074cb:	c3                   	ret    

801074cc <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801074cc:	55                   	push   %ebp
801074cd:	89 e5                	mov    %esp,%ebp
801074cf:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801074d2:	0f 20 d0             	mov    %cr2,%eax
801074d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801074d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801074db:	c9                   	leave  
801074dc:	c3                   	ret    

801074dd <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801074dd:	55                   	push   %ebp
801074de:	89 e5                	mov    %esp,%ebp
801074e0:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801074e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074ea:	e9 c3 00 00 00       	jmp    801075b2 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801074ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f2:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
801074f9:	89 c2                	mov    %eax,%edx
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
80107505:	80 
80107506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107509:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
80107510:	80 08 00 
80107513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107516:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
8010751d:	80 
8010751e:	83 e2 e0             	and    $0xffffffe0,%edx
80107521:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
80107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752b:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107532:	80 
80107533:	83 e2 1f             	and    $0x1f,%edx
80107536:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
8010753d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107540:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107547:	80 
80107548:	83 e2 f0             	and    $0xfffffff0,%edx
8010754b:	83 ca 0e             	or     $0xe,%edx
8010754e:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107558:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
8010755f:	80 
80107560:	83 e2 ef             	and    $0xffffffef,%edx
80107563:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
8010756a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756d:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107574:	80 
80107575:	83 e2 9f             	and    $0xffffff9f,%edx
80107578:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
8010757f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107582:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107589:	80 
8010758a:	83 ca 80             	or     $0xffffff80,%edx
8010758d:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107597:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010759e:	c1 e8 10             	shr    $0x10,%eax
801075a1:	89 c2                	mov    %eax,%edx
801075a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a6:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
801075ad:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801075ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075b2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801075b9:	0f 8e 30 ff ff ff    	jle    801074ef <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801075bf:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
801075c4:	66 a3 00 60 11 80    	mov    %ax,0x80116000
801075ca:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
801075d1:	08 00 
801075d3:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801075da:	83 e0 e0             	and    $0xffffffe0,%eax
801075dd:	a2 04 60 11 80       	mov    %al,0x80116004
801075e2:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801075e9:	83 e0 1f             	and    $0x1f,%eax
801075ec:	a2 04 60 11 80       	mov    %al,0x80116004
801075f1:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801075f8:	83 c8 0f             	or     $0xf,%eax
801075fb:	a2 05 60 11 80       	mov    %al,0x80116005
80107600:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107607:	83 e0 ef             	and    $0xffffffef,%eax
8010760a:	a2 05 60 11 80       	mov    %al,0x80116005
8010760f:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107616:	83 c8 60             	or     $0x60,%eax
80107619:	a2 05 60 11 80       	mov    %al,0x80116005
8010761e:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107625:	83 c8 80             	or     $0xffffff80,%eax
80107628:	a2 05 60 11 80       	mov    %al,0x80116005
8010762d:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107632:	c1 e8 10             	shr    $0x10,%eax
80107635:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
8010763b:	83 ec 08             	sub    $0x8,%esp
8010763e:	68 44 99 10 80       	push   $0x80109944
80107643:	68 c0 5d 11 80       	push   $0x80115dc0
80107648:	e8 00 e5 ff ff       	call   80105b4d <initlock>
8010764d:	83 c4 10             	add    $0x10,%esp
}
80107650:	90                   	nop
80107651:	c9                   	leave  
80107652:	c3                   	ret    

80107653 <idtinit>:

void
idtinit(void)
{
80107653:	55                   	push   %ebp
80107654:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107656:	68 00 08 00 00       	push   $0x800
8010765b:	68 00 5e 11 80       	push   $0x80115e00
80107660:	e8 3d fe ff ff       	call   801074a2 <lidt>
80107665:	83 c4 08             	add    $0x8,%esp
}
80107668:	90                   	nop
80107669:	c9                   	leave  
8010766a:	c3                   	ret    

8010766b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010766b:	55                   	push   %ebp
8010766c:	89 e5                	mov    %esp,%ebp
8010766e:	57                   	push   %edi
8010766f:	56                   	push   %esi
80107670:	53                   	push   %ebx
80107671:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107674:	8b 45 08             	mov    0x8(%ebp),%eax
80107677:	8b 40 30             	mov    0x30(%eax),%eax
8010767a:	83 f8 40             	cmp    $0x40,%eax
8010767d:	75 3e                	jne    801076bd <trap+0x52>
    if(proc->killed)
8010767f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107685:	8b 40 24             	mov    0x24(%eax),%eax
80107688:	85 c0                	test   %eax,%eax
8010768a:	74 05                	je     80107691 <trap+0x26>
      exit();
8010768c:	e8 41 dd ff ff       	call   801053d2 <exit>
    proc->tf = tf;
80107691:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107697:	8b 55 08             	mov    0x8(%ebp),%edx
8010769a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010769d:	e8 0b eb ff ff       	call   801061ad <syscall>
    if(proc->killed)
801076a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076a8:	8b 40 24             	mov    0x24(%eax),%eax
801076ab:	85 c0                	test   %eax,%eax
801076ad:	0f 84 1b 02 00 00    	je     801078ce <trap+0x263>
      exit();
801076b3:	e8 1a dd ff ff       	call   801053d2 <exit>
    return;
801076b8:	e9 11 02 00 00       	jmp    801078ce <trap+0x263>
  }

  switch(tf->trapno){
801076bd:	8b 45 08             	mov    0x8(%ebp),%eax
801076c0:	8b 40 30             	mov    0x30(%eax),%eax
801076c3:	83 e8 20             	sub    $0x20,%eax
801076c6:	83 f8 1f             	cmp    $0x1f,%eax
801076c9:	0f 87 c0 00 00 00    	ja     8010778f <trap+0x124>
801076cf:	8b 04 85 ec 99 10 80 	mov    -0x7fef6614(,%eax,4),%eax
801076d6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801076d8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076de:	0f b6 00             	movzbl (%eax),%eax
801076e1:	84 c0                	test   %al,%al
801076e3:	75 3d                	jne    80107722 <trap+0xb7>
      acquire(&tickslock);
801076e5:	83 ec 0c             	sub    $0xc,%esp
801076e8:	68 c0 5d 11 80       	push   $0x80115dc0
801076ed:	e8 7d e4 ff ff       	call   80105b6f <acquire>
801076f2:	83 c4 10             	add    $0x10,%esp
      ticks++;
801076f5:	a1 00 66 11 80       	mov    0x80116600,%eax
801076fa:	83 c0 01             	add    $0x1,%eax
801076fd:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
80107702:	83 ec 0c             	sub    $0xc,%esp
80107705:	68 00 66 11 80       	push   $0x80116600
8010770a:	e8 52 e2 ff ff       	call   80105961 <wakeup>
8010770f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107712:	83 ec 0c             	sub    $0xc,%esp
80107715:	68 c0 5d 11 80       	push   $0x80115dc0
8010771a:	e8 b7 e4 ff ff       	call   80105bd6 <release>
8010771f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107722:	e8 f5 c0 ff ff       	call   8010381c <lapiceoi>
    break;
80107727:	e9 1c 01 00 00       	jmp    80107848 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010772c:	e8 ee b8 ff ff       	call   8010301f <ideintr>
    lapiceoi();
80107731:	e8 e6 c0 ff ff       	call   8010381c <lapiceoi>
    break;
80107736:	e9 0d 01 00 00       	jmp    80107848 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010773b:	e8 de be ff ff       	call   8010361e <kbdintr>
    lapiceoi();
80107740:	e8 d7 c0 ff ff       	call   8010381c <lapiceoi>
    break;
80107745:	e9 fe 00 00 00       	jmp    80107848 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010774a:	e8 60 03 00 00       	call   80107aaf <uartintr>
    lapiceoi();
8010774f:	e8 c8 c0 ff ff       	call   8010381c <lapiceoi>
    break;
80107754:	e9 ef 00 00 00       	jmp    80107848 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107759:	8b 45 08             	mov    0x8(%ebp),%eax
8010775c:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010775f:	8b 45 08             	mov    0x8(%ebp),%eax
80107762:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107766:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107769:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010776f:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107772:	0f b6 c0             	movzbl %al,%eax
80107775:	51                   	push   %ecx
80107776:	52                   	push   %edx
80107777:	50                   	push   %eax
80107778:	68 4c 99 10 80       	push   $0x8010994c
8010777d:	e8 44 8c ff ff       	call   801003c6 <cprintf>
80107782:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107785:	e8 92 c0 ff ff       	call   8010381c <lapiceoi>
    break;
8010778a:	e9 b9 00 00 00       	jmp    80107848 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010778f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107795:	85 c0                	test   %eax,%eax
80107797:	74 11                	je     801077aa <trap+0x13f>
80107799:	8b 45 08             	mov    0x8(%ebp),%eax
8010779c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801077a0:	0f b7 c0             	movzwl %ax,%eax
801077a3:	83 e0 03             	and    $0x3,%eax
801077a6:	85 c0                	test   %eax,%eax
801077a8:	75 40                	jne    801077ea <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801077aa:	e8 1d fd ff ff       	call   801074cc <rcr2>
801077af:	89 c3                	mov    %eax,%ebx
801077b1:	8b 45 08             	mov    0x8(%ebp),%eax
801077b4:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801077b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077bd:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801077c0:	0f b6 d0             	movzbl %al,%edx
801077c3:	8b 45 08             	mov    0x8(%ebp),%eax
801077c6:	8b 40 30             	mov    0x30(%eax),%eax
801077c9:	83 ec 0c             	sub    $0xc,%esp
801077cc:	53                   	push   %ebx
801077cd:	51                   	push   %ecx
801077ce:	52                   	push   %edx
801077cf:	50                   	push   %eax
801077d0:	68 70 99 10 80       	push   $0x80109970
801077d5:	e8 ec 8b ff ff       	call   801003c6 <cprintf>
801077da:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801077dd:	83 ec 0c             	sub    $0xc,%esp
801077e0:	68 a2 99 10 80       	push   $0x801099a2
801077e5:	e8 7c 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077ea:	e8 dd fc ff ff       	call   801074cc <rcr2>
801077ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077f2:	8b 45 08             	mov    0x8(%ebp),%eax
801077f5:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801077f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077fe:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107801:	0f b6 d8             	movzbl %al,%ebx
80107804:	8b 45 08             	mov    0x8(%ebp),%eax
80107807:	8b 48 34             	mov    0x34(%eax),%ecx
8010780a:	8b 45 08             	mov    0x8(%ebp),%eax
8010780d:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107810:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107816:	8d 78 6c             	lea    0x6c(%eax),%edi
80107819:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010781f:	8b 40 10             	mov    0x10(%eax),%eax
80107822:	ff 75 e4             	pushl  -0x1c(%ebp)
80107825:	56                   	push   %esi
80107826:	53                   	push   %ebx
80107827:	51                   	push   %ecx
80107828:	52                   	push   %edx
80107829:	57                   	push   %edi
8010782a:	50                   	push   %eax
8010782b:	68 a8 99 10 80       	push   $0x801099a8
80107830:	e8 91 8b ff ff       	call   801003c6 <cprintf>
80107835:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010783e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107845:	eb 01                	jmp    80107848 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107847:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107848:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010784e:	85 c0                	test   %eax,%eax
80107850:	74 24                	je     80107876 <trap+0x20b>
80107852:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107858:	8b 40 24             	mov    0x24(%eax),%eax
8010785b:	85 c0                	test   %eax,%eax
8010785d:	74 17                	je     80107876 <trap+0x20b>
8010785f:	8b 45 08             	mov    0x8(%ebp),%eax
80107862:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107866:	0f b7 c0             	movzwl %ax,%eax
80107869:	83 e0 03             	and    $0x3,%eax
8010786c:	83 f8 03             	cmp    $0x3,%eax
8010786f:	75 05                	jne    80107876 <trap+0x20b>
    exit();
80107871:	e8 5c db ff ff       	call   801053d2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010787c:	85 c0                	test   %eax,%eax
8010787e:	74 1e                	je     8010789e <trap+0x233>
80107880:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107886:	8b 40 0c             	mov    0xc(%eax),%eax
80107889:	83 f8 04             	cmp    $0x4,%eax
8010788c:	75 10                	jne    8010789e <trap+0x233>
8010788e:	8b 45 08             	mov    0x8(%ebp),%eax
80107891:	8b 40 30             	mov    0x30(%eax),%eax
80107894:	83 f8 20             	cmp    $0x20,%eax
80107897:	75 05                	jne    8010789e <trap+0x233>
    yield();
80107899:	e8 1d df ff ff       	call   801057bb <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010789e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078a4:	85 c0                	test   %eax,%eax
801078a6:	74 27                	je     801078cf <trap+0x264>
801078a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078ae:	8b 40 24             	mov    0x24(%eax),%eax
801078b1:	85 c0                	test   %eax,%eax
801078b3:	74 1a                	je     801078cf <trap+0x264>
801078b5:	8b 45 08             	mov    0x8(%ebp),%eax
801078b8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078bc:	0f b7 c0             	movzwl %ax,%eax
801078bf:	83 e0 03             	and    $0x3,%eax
801078c2:	83 f8 03             	cmp    $0x3,%eax
801078c5:	75 08                	jne    801078cf <trap+0x264>
    exit();
801078c7:	e8 06 db ff ff       	call   801053d2 <exit>
801078cc:	eb 01                	jmp    801078cf <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801078ce:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801078cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801078d2:	5b                   	pop    %ebx
801078d3:	5e                   	pop    %esi
801078d4:	5f                   	pop    %edi
801078d5:	5d                   	pop    %ebp
801078d6:	c3                   	ret    

801078d7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801078d7:	55                   	push   %ebp
801078d8:	89 e5                	mov    %esp,%ebp
801078da:	83 ec 14             	sub    $0x14,%esp
801078dd:	8b 45 08             	mov    0x8(%ebp),%eax
801078e0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801078e4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801078e8:	89 c2                	mov    %eax,%edx
801078ea:	ec                   	in     (%dx),%al
801078eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801078ee:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801078f2:	c9                   	leave  
801078f3:	c3                   	ret    

801078f4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801078f4:	55                   	push   %ebp
801078f5:	89 e5                	mov    %esp,%ebp
801078f7:	83 ec 08             	sub    $0x8,%esp
801078fa:	8b 55 08             	mov    0x8(%ebp),%edx
801078fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107900:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107904:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107907:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010790b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010790f:	ee                   	out    %al,(%dx)
}
80107910:	90                   	nop
80107911:	c9                   	leave  
80107912:	c3                   	ret    

80107913 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107913:	55                   	push   %ebp
80107914:	89 e5                	mov    %esp,%ebp
80107916:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107919:	6a 00                	push   $0x0
8010791b:	68 fa 03 00 00       	push   $0x3fa
80107920:	e8 cf ff ff ff       	call   801078f4 <outb>
80107925:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107928:	68 80 00 00 00       	push   $0x80
8010792d:	68 fb 03 00 00       	push   $0x3fb
80107932:	e8 bd ff ff ff       	call   801078f4 <outb>
80107937:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010793a:	6a 0c                	push   $0xc
8010793c:	68 f8 03 00 00       	push   $0x3f8
80107941:	e8 ae ff ff ff       	call   801078f4 <outb>
80107946:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107949:	6a 00                	push   $0x0
8010794b:	68 f9 03 00 00       	push   $0x3f9
80107950:	e8 9f ff ff ff       	call   801078f4 <outb>
80107955:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107958:	6a 03                	push   $0x3
8010795a:	68 fb 03 00 00       	push   $0x3fb
8010795f:	e8 90 ff ff ff       	call   801078f4 <outb>
80107964:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107967:	6a 00                	push   $0x0
80107969:	68 fc 03 00 00       	push   $0x3fc
8010796e:	e8 81 ff ff ff       	call   801078f4 <outb>
80107973:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107976:	6a 01                	push   $0x1
80107978:	68 f9 03 00 00       	push   $0x3f9
8010797d:	e8 72 ff ff ff       	call   801078f4 <outb>
80107982:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107985:	68 fd 03 00 00       	push   $0x3fd
8010798a:	e8 48 ff ff ff       	call   801078d7 <inb>
8010798f:	83 c4 04             	add    $0x4,%esp
80107992:	3c ff                	cmp    $0xff,%al
80107994:	74 6e                	je     80107a04 <uartinit+0xf1>
    return;
  uart = 1;
80107996:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
8010799d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801079a0:	68 fa 03 00 00       	push   $0x3fa
801079a5:	e8 2d ff ff ff       	call   801078d7 <inb>
801079aa:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801079ad:	68 f8 03 00 00       	push   $0x3f8
801079b2:	e8 20 ff ff ff       	call   801078d7 <inb>
801079b7:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801079ba:	83 ec 0c             	sub    $0xc,%esp
801079bd:	6a 04                	push   $0x4
801079bf:	e8 71 d0 ff ff       	call   80104a35 <picenable>
801079c4:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801079c7:	83 ec 08             	sub    $0x8,%esp
801079ca:	6a 00                	push   $0x0
801079cc:	6a 04                	push   $0x4
801079ce:	e8 fe b8 ff ff       	call   801032d1 <ioapicenable>
801079d3:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079d6:	c7 45 f4 6c 9a 10 80 	movl   $0x80109a6c,-0xc(%ebp)
801079dd:	eb 19                	jmp    801079f8 <uartinit+0xe5>
    uartputc(*p);
801079df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e2:	0f b6 00             	movzbl (%eax),%eax
801079e5:	0f be c0             	movsbl %al,%eax
801079e8:	83 ec 0c             	sub    $0xc,%esp
801079eb:	50                   	push   %eax
801079ec:	e8 16 00 00 00       	call   80107a07 <uartputc>
801079f1:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fb:	0f b6 00             	movzbl (%eax),%eax
801079fe:	84 c0                	test   %al,%al
80107a00:	75 dd                	jne    801079df <uartinit+0xcc>
80107a02:	eb 01                	jmp    80107a05 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107a04:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107a05:	c9                   	leave  
80107a06:	c3                   	ret    

80107a07 <uartputc>:

void
uartputc(int c)
{
80107a07:	55                   	push   %ebp
80107a08:	89 e5                	mov    %esp,%ebp
80107a0a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a0d:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a12:	85 c0                	test   %eax,%eax
80107a14:	74 53                	je     80107a69 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a1d:	eb 11                	jmp    80107a30 <uartputc+0x29>
    microdelay(10);
80107a1f:	83 ec 0c             	sub    $0xc,%esp
80107a22:	6a 0a                	push   $0xa
80107a24:	e8 0e be ff ff       	call   80103837 <microdelay>
80107a29:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a30:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a34:	7f 1a                	jg     80107a50 <uartputc+0x49>
80107a36:	83 ec 0c             	sub    $0xc,%esp
80107a39:	68 fd 03 00 00       	push   $0x3fd
80107a3e:	e8 94 fe ff ff       	call   801078d7 <inb>
80107a43:	83 c4 10             	add    $0x10,%esp
80107a46:	0f b6 c0             	movzbl %al,%eax
80107a49:	83 e0 20             	and    $0x20,%eax
80107a4c:	85 c0                	test   %eax,%eax
80107a4e:	74 cf                	je     80107a1f <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107a50:	8b 45 08             	mov    0x8(%ebp),%eax
80107a53:	0f b6 c0             	movzbl %al,%eax
80107a56:	83 ec 08             	sub    $0x8,%esp
80107a59:	50                   	push   %eax
80107a5a:	68 f8 03 00 00       	push   $0x3f8
80107a5f:	e8 90 fe ff ff       	call   801078f4 <outb>
80107a64:	83 c4 10             	add    $0x10,%esp
80107a67:	eb 01                	jmp    80107a6a <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107a69:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107a6a:	c9                   	leave  
80107a6b:	c3                   	ret    

80107a6c <uartgetc>:

static int
uartgetc(void)
{
80107a6c:	55                   	push   %ebp
80107a6d:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a6f:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a74:	85 c0                	test   %eax,%eax
80107a76:	75 07                	jne    80107a7f <uartgetc+0x13>
    return -1;
80107a78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a7d:	eb 2e                	jmp    80107aad <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a7f:	68 fd 03 00 00       	push   $0x3fd
80107a84:	e8 4e fe ff ff       	call   801078d7 <inb>
80107a89:	83 c4 04             	add    $0x4,%esp
80107a8c:	0f b6 c0             	movzbl %al,%eax
80107a8f:	83 e0 01             	and    $0x1,%eax
80107a92:	85 c0                	test   %eax,%eax
80107a94:	75 07                	jne    80107a9d <uartgetc+0x31>
    return -1;
80107a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a9b:	eb 10                	jmp    80107aad <uartgetc+0x41>
  return inb(COM1+0);
80107a9d:	68 f8 03 00 00       	push   $0x3f8
80107aa2:	e8 30 fe ff ff       	call   801078d7 <inb>
80107aa7:	83 c4 04             	add    $0x4,%esp
80107aaa:	0f b6 c0             	movzbl %al,%eax
}
80107aad:	c9                   	leave  
80107aae:	c3                   	ret    

80107aaf <uartintr>:

void
uartintr(void)
{
80107aaf:	55                   	push   %ebp
80107ab0:	89 e5                	mov    %esp,%ebp
80107ab2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107ab5:	83 ec 0c             	sub    $0xc,%esp
80107ab8:	68 6c 7a 10 80       	push   $0x80107a6c
80107abd:	e8 37 8d ff ff       	call   801007f9 <consoleintr>
80107ac2:	83 c4 10             	add    $0x10,%esp
}
80107ac5:	90                   	nop
80107ac6:	c9                   	leave  
80107ac7:	c3                   	ret    

80107ac8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $0
80107aca:	6a 00                	push   $0x0
  jmp alltraps
80107acc:	e9 a6 f9 ff ff       	jmp    80107477 <alltraps>

80107ad1 <vector1>:
.globl vector1
vector1:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $1
80107ad3:	6a 01                	push   $0x1
  jmp alltraps
80107ad5:	e9 9d f9 ff ff       	jmp    80107477 <alltraps>

80107ada <vector2>:
.globl vector2
vector2:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $2
80107adc:	6a 02                	push   $0x2
  jmp alltraps
80107ade:	e9 94 f9 ff ff       	jmp    80107477 <alltraps>

80107ae3 <vector3>:
.globl vector3
vector3:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $3
80107ae5:	6a 03                	push   $0x3
  jmp alltraps
80107ae7:	e9 8b f9 ff ff       	jmp    80107477 <alltraps>

80107aec <vector4>:
.globl vector4
vector4:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $4
80107aee:	6a 04                	push   $0x4
  jmp alltraps
80107af0:	e9 82 f9 ff ff       	jmp    80107477 <alltraps>

80107af5 <vector5>:
.globl vector5
vector5:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $5
80107af7:	6a 05                	push   $0x5
  jmp alltraps
80107af9:	e9 79 f9 ff ff       	jmp    80107477 <alltraps>

80107afe <vector6>:
.globl vector6
vector6:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $6
80107b00:	6a 06                	push   $0x6
  jmp alltraps
80107b02:	e9 70 f9 ff ff       	jmp    80107477 <alltraps>

80107b07 <vector7>:
.globl vector7
vector7:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $7
80107b09:	6a 07                	push   $0x7
  jmp alltraps
80107b0b:	e9 67 f9 ff ff       	jmp    80107477 <alltraps>

80107b10 <vector8>:
.globl vector8
vector8:
  pushl $8
80107b10:	6a 08                	push   $0x8
  jmp alltraps
80107b12:	e9 60 f9 ff ff       	jmp    80107477 <alltraps>

80107b17 <vector9>:
.globl vector9
vector9:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $9
80107b19:	6a 09                	push   $0x9
  jmp alltraps
80107b1b:	e9 57 f9 ff ff       	jmp    80107477 <alltraps>

80107b20 <vector10>:
.globl vector10
vector10:
  pushl $10
80107b20:	6a 0a                	push   $0xa
  jmp alltraps
80107b22:	e9 50 f9 ff ff       	jmp    80107477 <alltraps>

80107b27 <vector11>:
.globl vector11
vector11:
  pushl $11
80107b27:	6a 0b                	push   $0xb
  jmp alltraps
80107b29:	e9 49 f9 ff ff       	jmp    80107477 <alltraps>

80107b2e <vector12>:
.globl vector12
vector12:
  pushl $12
80107b2e:	6a 0c                	push   $0xc
  jmp alltraps
80107b30:	e9 42 f9 ff ff       	jmp    80107477 <alltraps>

80107b35 <vector13>:
.globl vector13
vector13:
  pushl $13
80107b35:	6a 0d                	push   $0xd
  jmp alltraps
80107b37:	e9 3b f9 ff ff       	jmp    80107477 <alltraps>

80107b3c <vector14>:
.globl vector14
vector14:
  pushl $14
80107b3c:	6a 0e                	push   $0xe
  jmp alltraps
80107b3e:	e9 34 f9 ff ff       	jmp    80107477 <alltraps>

80107b43 <vector15>:
.globl vector15
vector15:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $15
80107b45:	6a 0f                	push   $0xf
  jmp alltraps
80107b47:	e9 2b f9 ff ff       	jmp    80107477 <alltraps>

80107b4c <vector16>:
.globl vector16
vector16:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $16
80107b4e:	6a 10                	push   $0x10
  jmp alltraps
80107b50:	e9 22 f9 ff ff       	jmp    80107477 <alltraps>

80107b55 <vector17>:
.globl vector17
vector17:
  pushl $17
80107b55:	6a 11                	push   $0x11
  jmp alltraps
80107b57:	e9 1b f9 ff ff       	jmp    80107477 <alltraps>

80107b5c <vector18>:
.globl vector18
vector18:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $18
80107b5e:	6a 12                	push   $0x12
  jmp alltraps
80107b60:	e9 12 f9 ff ff       	jmp    80107477 <alltraps>

80107b65 <vector19>:
.globl vector19
vector19:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $19
80107b67:	6a 13                	push   $0x13
  jmp alltraps
80107b69:	e9 09 f9 ff ff       	jmp    80107477 <alltraps>

80107b6e <vector20>:
.globl vector20
vector20:
  pushl $0
80107b6e:	6a 00                	push   $0x0
  pushl $20
80107b70:	6a 14                	push   $0x14
  jmp alltraps
80107b72:	e9 00 f9 ff ff       	jmp    80107477 <alltraps>

80107b77 <vector21>:
.globl vector21
vector21:
  pushl $0
80107b77:	6a 00                	push   $0x0
  pushl $21
80107b79:	6a 15                	push   $0x15
  jmp alltraps
80107b7b:	e9 f7 f8 ff ff       	jmp    80107477 <alltraps>

80107b80 <vector22>:
.globl vector22
vector22:
  pushl $0
80107b80:	6a 00                	push   $0x0
  pushl $22
80107b82:	6a 16                	push   $0x16
  jmp alltraps
80107b84:	e9 ee f8 ff ff       	jmp    80107477 <alltraps>

80107b89 <vector23>:
.globl vector23
vector23:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $23
80107b8b:	6a 17                	push   $0x17
  jmp alltraps
80107b8d:	e9 e5 f8 ff ff       	jmp    80107477 <alltraps>

80107b92 <vector24>:
.globl vector24
vector24:
  pushl $0
80107b92:	6a 00                	push   $0x0
  pushl $24
80107b94:	6a 18                	push   $0x18
  jmp alltraps
80107b96:	e9 dc f8 ff ff       	jmp    80107477 <alltraps>

80107b9b <vector25>:
.globl vector25
vector25:
  pushl $0
80107b9b:	6a 00                	push   $0x0
  pushl $25
80107b9d:	6a 19                	push   $0x19
  jmp alltraps
80107b9f:	e9 d3 f8 ff ff       	jmp    80107477 <alltraps>

80107ba4 <vector26>:
.globl vector26
vector26:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $26
80107ba6:	6a 1a                	push   $0x1a
  jmp alltraps
80107ba8:	e9 ca f8 ff ff       	jmp    80107477 <alltraps>

80107bad <vector27>:
.globl vector27
vector27:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $27
80107baf:	6a 1b                	push   $0x1b
  jmp alltraps
80107bb1:	e9 c1 f8 ff ff       	jmp    80107477 <alltraps>

80107bb6 <vector28>:
.globl vector28
vector28:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $28
80107bb8:	6a 1c                	push   $0x1c
  jmp alltraps
80107bba:	e9 b8 f8 ff ff       	jmp    80107477 <alltraps>

80107bbf <vector29>:
.globl vector29
vector29:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $29
80107bc1:	6a 1d                	push   $0x1d
  jmp alltraps
80107bc3:	e9 af f8 ff ff       	jmp    80107477 <alltraps>

80107bc8 <vector30>:
.globl vector30
vector30:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $30
80107bca:	6a 1e                	push   $0x1e
  jmp alltraps
80107bcc:	e9 a6 f8 ff ff       	jmp    80107477 <alltraps>

80107bd1 <vector31>:
.globl vector31
vector31:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $31
80107bd3:	6a 1f                	push   $0x1f
  jmp alltraps
80107bd5:	e9 9d f8 ff ff       	jmp    80107477 <alltraps>

80107bda <vector32>:
.globl vector32
vector32:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $32
80107bdc:	6a 20                	push   $0x20
  jmp alltraps
80107bde:	e9 94 f8 ff ff       	jmp    80107477 <alltraps>

80107be3 <vector33>:
.globl vector33
vector33:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $33
80107be5:	6a 21                	push   $0x21
  jmp alltraps
80107be7:	e9 8b f8 ff ff       	jmp    80107477 <alltraps>

80107bec <vector34>:
.globl vector34
vector34:
  pushl $0
80107bec:	6a 00                	push   $0x0
  pushl $34
80107bee:	6a 22                	push   $0x22
  jmp alltraps
80107bf0:	e9 82 f8 ff ff       	jmp    80107477 <alltraps>

80107bf5 <vector35>:
.globl vector35
vector35:
  pushl $0
80107bf5:	6a 00                	push   $0x0
  pushl $35
80107bf7:	6a 23                	push   $0x23
  jmp alltraps
80107bf9:	e9 79 f8 ff ff       	jmp    80107477 <alltraps>

80107bfe <vector36>:
.globl vector36
vector36:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $36
80107c00:	6a 24                	push   $0x24
  jmp alltraps
80107c02:	e9 70 f8 ff ff       	jmp    80107477 <alltraps>

80107c07 <vector37>:
.globl vector37
vector37:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $37
80107c09:	6a 25                	push   $0x25
  jmp alltraps
80107c0b:	e9 67 f8 ff ff       	jmp    80107477 <alltraps>

80107c10 <vector38>:
.globl vector38
vector38:
  pushl $0
80107c10:	6a 00                	push   $0x0
  pushl $38
80107c12:	6a 26                	push   $0x26
  jmp alltraps
80107c14:	e9 5e f8 ff ff       	jmp    80107477 <alltraps>

80107c19 <vector39>:
.globl vector39
vector39:
  pushl $0
80107c19:	6a 00                	push   $0x0
  pushl $39
80107c1b:	6a 27                	push   $0x27
  jmp alltraps
80107c1d:	e9 55 f8 ff ff       	jmp    80107477 <alltraps>

80107c22 <vector40>:
.globl vector40
vector40:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $40
80107c24:	6a 28                	push   $0x28
  jmp alltraps
80107c26:	e9 4c f8 ff ff       	jmp    80107477 <alltraps>

80107c2b <vector41>:
.globl vector41
vector41:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $41
80107c2d:	6a 29                	push   $0x29
  jmp alltraps
80107c2f:	e9 43 f8 ff ff       	jmp    80107477 <alltraps>

80107c34 <vector42>:
.globl vector42
vector42:
  pushl $0
80107c34:	6a 00                	push   $0x0
  pushl $42
80107c36:	6a 2a                	push   $0x2a
  jmp alltraps
80107c38:	e9 3a f8 ff ff       	jmp    80107477 <alltraps>

80107c3d <vector43>:
.globl vector43
vector43:
  pushl $0
80107c3d:	6a 00                	push   $0x0
  pushl $43
80107c3f:	6a 2b                	push   $0x2b
  jmp alltraps
80107c41:	e9 31 f8 ff ff       	jmp    80107477 <alltraps>

80107c46 <vector44>:
.globl vector44
vector44:
  pushl $0
80107c46:	6a 00                	push   $0x0
  pushl $44
80107c48:	6a 2c                	push   $0x2c
  jmp alltraps
80107c4a:	e9 28 f8 ff ff       	jmp    80107477 <alltraps>

80107c4f <vector45>:
.globl vector45
vector45:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $45
80107c51:	6a 2d                	push   $0x2d
  jmp alltraps
80107c53:	e9 1f f8 ff ff       	jmp    80107477 <alltraps>

80107c58 <vector46>:
.globl vector46
vector46:
  pushl $0
80107c58:	6a 00                	push   $0x0
  pushl $46
80107c5a:	6a 2e                	push   $0x2e
  jmp alltraps
80107c5c:	e9 16 f8 ff ff       	jmp    80107477 <alltraps>

80107c61 <vector47>:
.globl vector47
vector47:
  pushl $0
80107c61:	6a 00                	push   $0x0
  pushl $47
80107c63:	6a 2f                	push   $0x2f
  jmp alltraps
80107c65:	e9 0d f8 ff ff       	jmp    80107477 <alltraps>

80107c6a <vector48>:
.globl vector48
vector48:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $48
80107c6c:	6a 30                	push   $0x30
  jmp alltraps
80107c6e:	e9 04 f8 ff ff       	jmp    80107477 <alltraps>

80107c73 <vector49>:
.globl vector49
vector49:
  pushl $0
80107c73:	6a 00                	push   $0x0
  pushl $49
80107c75:	6a 31                	push   $0x31
  jmp alltraps
80107c77:	e9 fb f7 ff ff       	jmp    80107477 <alltraps>

80107c7c <vector50>:
.globl vector50
vector50:
  pushl $0
80107c7c:	6a 00                	push   $0x0
  pushl $50
80107c7e:	6a 32                	push   $0x32
  jmp alltraps
80107c80:	e9 f2 f7 ff ff       	jmp    80107477 <alltraps>

80107c85 <vector51>:
.globl vector51
vector51:
  pushl $0
80107c85:	6a 00                	push   $0x0
  pushl $51
80107c87:	6a 33                	push   $0x33
  jmp alltraps
80107c89:	e9 e9 f7 ff ff       	jmp    80107477 <alltraps>

80107c8e <vector52>:
.globl vector52
vector52:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $52
80107c90:	6a 34                	push   $0x34
  jmp alltraps
80107c92:	e9 e0 f7 ff ff       	jmp    80107477 <alltraps>

80107c97 <vector53>:
.globl vector53
vector53:
  pushl $0
80107c97:	6a 00                	push   $0x0
  pushl $53
80107c99:	6a 35                	push   $0x35
  jmp alltraps
80107c9b:	e9 d7 f7 ff ff       	jmp    80107477 <alltraps>

80107ca0 <vector54>:
.globl vector54
vector54:
  pushl $0
80107ca0:	6a 00                	push   $0x0
  pushl $54
80107ca2:	6a 36                	push   $0x36
  jmp alltraps
80107ca4:	e9 ce f7 ff ff       	jmp    80107477 <alltraps>

80107ca9 <vector55>:
.globl vector55
vector55:
  pushl $0
80107ca9:	6a 00                	push   $0x0
  pushl $55
80107cab:	6a 37                	push   $0x37
  jmp alltraps
80107cad:	e9 c5 f7 ff ff       	jmp    80107477 <alltraps>

80107cb2 <vector56>:
.globl vector56
vector56:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $56
80107cb4:	6a 38                	push   $0x38
  jmp alltraps
80107cb6:	e9 bc f7 ff ff       	jmp    80107477 <alltraps>

80107cbb <vector57>:
.globl vector57
vector57:
  pushl $0
80107cbb:	6a 00                	push   $0x0
  pushl $57
80107cbd:	6a 39                	push   $0x39
  jmp alltraps
80107cbf:	e9 b3 f7 ff ff       	jmp    80107477 <alltraps>

80107cc4 <vector58>:
.globl vector58
vector58:
  pushl $0
80107cc4:	6a 00                	push   $0x0
  pushl $58
80107cc6:	6a 3a                	push   $0x3a
  jmp alltraps
80107cc8:	e9 aa f7 ff ff       	jmp    80107477 <alltraps>

80107ccd <vector59>:
.globl vector59
vector59:
  pushl $0
80107ccd:	6a 00                	push   $0x0
  pushl $59
80107ccf:	6a 3b                	push   $0x3b
  jmp alltraps
80107cd1:	e9 a1 f7 ff ff       	jmp    80107477 <alltraps>

80107cd6 <vector60>:
.globl vector60
vector60:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $60
80107cd8:	6a 3c                	push   $0x3c
  jmp alltraps
80107cda:	e9 98 f7 ff ff       	jmp    80107477 <alltraps>

80107cdf <vector61>:
.globl vector61
vector61:
  pushl $0
80107cdf:	6a 00                	push   $0x0
  pushl $61
80107ce1:	6a 3d                	push   $0x3d
  jmp alltraps
80107ce3:	e9 8f f7 ff ff       	jmp    80107477 <alltraps>

80107ce8 <vector62>:
.globl vector62
vector62:
  pushl $0
80107ce8:	6a 00                	push   $0x0
  pushl $62
80107cea:	6a 3e                	push   $0x3e
  jmp alltraps
80107cec:	e9 86 f7 ff ff       	jmp    80107477 <alltraps>

80107cf1 <vector63>:
.globl vector63
vector63:
  pushl $0
80107cf1:	6a 00                	push   $0x0
  pushl $63
80107cf3:	6a 3f                	push   $0x3f
  jmp alltraps
80107cf5:	e9 7d f7 ff ff       	jmp    80107477 <alltraps>

80107cfa <vector64>:
.globl vector64
vector64:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $64
80107cfc:	6a 40                	push   $0x40
  jmp alltraps
80107cfe:	e9 74 f7 ff ff       	jmp    80107477 <alltraps>

80107d03 <vector65>:
.globl vector65
vector65:
  pushl $0
80107d03:	6a 00                	push   $0x0
  pushl $65
80107d05:	6a 41                	push   $0x41
  jmp alltraps
80107d07:	e9 6b f7 ff ff       	jmp    80107477 <alltraps>

80107d0c <vector66>:
.globl vector66
vector66:
  pushl $0
80107d0c:	6a 00                	push   $0x0
  pushl $66
80107d0e:	6a 42                	push   $0x42
  jmp alltraps
80107d10:	e9 62 f7 ff ff       	jmp    80107477 <alltraps>

80107d15 <vector67>:
.globl vector67
vector67:
  pushl $0
80107d15:	6a 00                	push   $0x0
  pushl $67
80107d17:	6a 43                	push   $0x43
  jmp alltraps
80107d19:	e9 59 f7 ff ff       	jmp    80107477 <alltraps>

80107d1e <vector68>:
.globl vector68
vector68:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $68
80107d20:	6a 44                	push   $0x44
  jmp alltraps
80107d22:	e9 50 f7 ff ff       	jmp    80107477 <alltraps>

80107d27 <vector69>:
.globl vector69
vector69:
  pushl $0
80107d27:	6a 00                	push   $0x0
  pushl $69
80107d29:	6a 45                	push   $0x45
  jmp alltraps
80107d2b:	e9 47 f7 ff ff       	jmp    80107477 <alltraps>

80107d30 <vector70>:
.globl vector70
vector70:
  pushl $0
80107d30:	6a 00                	push   $0x0
  pushl $70
80107d32:	6a 46                	push   $0x46
  jmp alltraps
80107d34:	e9 3e f7 ff ff       	jmp    80107477 <alltraps>

80107d39 <vector71>:
.globl vector71
vector71:
  pushl $0
80107d39:	6a 00                	push   $0x0
  pushl $71
80107d3b:	6a 47                	push   $0x47
  jmp alltraps
80107d3d:	e9 35 f7 ff ff       	jmp    80107477 <alltraps>

80107d42 <vector72>:
.globl vector72
vector72:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $72
80107d44:	6a 48                	push   $0x48
  jmp alltraps
80107d46:	e9 2c f7 ff ff       	jmp    80107477 <alltraps>

80107d4b <vector73>:
.globl vector73
vector73:
  pushl $0
80107d4b:	6a 00                	push   $0x0
  pushl $73
80107d4d:	6a 49                	push   $0x49
  jmp alltraps
80107d4f:	e9 23 f7 ff ff       	jmp    80107477 <alltraps>

80107d54 <vector74>:
.globl vector74
vector74:
  pushl $0
80107d54:	6a 00                	push   $0x0
  pushl $74
80107d56:	6a 4a                	push   $0x4a
  jmp alltraps
80107d58:	e9 1a f7 ff ff       	jmp    80107477 <alltraps>

80107d5d <vector75>:
.globl vector75
vector75:
  pushl $0
80107d5d:	6a 00                	push   $0x0
  pushl $75
80107d5f:	6a 4b                	push   $0x4b
  jmp alltraps
80107d61:	e9 11 f7 ff ff       	jmp    80107477 <alltraps>

80107d66 <vector76>:
.globl vector76
vector76:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $76
80107d68:	6a 4c                	push   $0x4c
  jmp alltraps
80107d6a:	e9 08 f7 ff ff       	jmp    80107477 <alltraps>

80107d6f <vector77>:
.globl vector77
vector77:
  pushl $0
80107d6f:	6a 00                	push   $0x0
  pushl $77
80107d71:	6a 4d                	push   $0x4d
  jmp alltraps
80107d73:	e9 ff f6 ff ff       	jmp    80107477 <alltraps>

80107d78 <vector78>:
.globl vector78
vector78:
  pushl $0
80107d78:	6a 00                	push   $0x0
  pushl $78
80107d7a:	6a 4e                	push   $0x4e
  jmp alltraps
80107d7c:	e9 f6 f6 ff ff       	jmp    80107477 <alltraps>

80107d81 <vector79>:
.globl vector79
vector79:
  pushl $0
80107d81:	6a 00                	push   $0x0
  pushl $79
80107d83:	6a 4f                	push   $0x4f
  jmp alltraps
80107d85:	e9 ed f6 ff ff       	jmp    80107477 <alltraps>

80107d8a <vector80>:
.globl vector80
vector80:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $80
80107d8c:	6a 50                	push   $0x50
  jmp alltraps
80107d8e:	e9 e4 f6 ff ff       	jmp    80107477 <alltraps>

80107d93 <vector81>:
.globl vector81
vector81:
  pushl $0
80107d93:	6a 00                	push   $0x0
  pushl $81
80107d95:	6a 51                	push   $0x51
  jmp alltraps
80107d97:	e9 db f6 ff ff       	jmp    80107477 <alltraps>

80107d9c <vector82>:
.globl vector82
vector82:
  pushl $0
80107d9c:	6a 00                	push   $0x0
  pushl $82
80107d9e:	6a 52                	push   $0x52
  jmp alltraps
80107da0:	e9 d2 f6 ff ff       	jmp    80107477 <alltraps>

80107da5 <vector83>:
.globl vector83
vector83:
  pushl $0
80107da5:	6a 00                	push   $0x0
  pushl $83
80107da7:	6a 53                	push   $0x53
  jmp alltraps
80107da9:	e9 c9 f6 ff ff       	jmp    80107477 <alltraps>

80107dae <vector84>:
.globl vector84
vector84:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $84
80107db0:	6a 54                	push   $0x54
  jmp alltraps
80107db2:	e9 c0 f6 ff ff       	jmp    80107477 <alltraps>

80107db7 <vector85>:
.globl vector85
vector85:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $85
80107db9:	6a 55                	push   $0x55
  jmp alltraps
80107dbb:	e9 b7 f6 ff ff       	jmp    80107477 <alltraps>

80107dc0 <vector86>:
.globl vector86
vector86:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $86
80107dc2:	6a 56                	push   $0x56
  jmp alltraps
80107dc4:	e9 ae f6 ff ff       	jmp    80107477 <alltraps>

80107dc9 <vector87>:
.globl vector87
vector87:
  pushl $0
80107dc9:	6a 00                	push   $0x0
  pushl $87
80107dcb:	6a 57                	push   $0x57
  jmp alltraps
80107dcd:	e9 a5 f6 ff ff       	jmp    80107477 <alltraps>

80107dd2 <vector88>:
.globl vector88
vector88:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $88
80107dd4:	6a 58                	push   $0x58
  jmp alltraps
80107dd6:	e9 9c f6 ff ff       	jmp    80107477 <alltraps>

80107ddb <vector89>:
.globl vector89
vector89:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $89
80107ddd:	6a 59                	push   $0x59
  jmp alltraps
80107ddf:	e9 93 f6 ff ff       	jmp    80107477 <alltraps>

80107de4 <vector90>:
.globl vector90
vector90:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $90
80107de6:	6a 5a                	push   $0x5a
  jmp alltraps
80107de8:	e9 8a f6 ff ff       	jmp    80107477 <alltraps>

80107ded <vector91>:
.globl vector91
vector91:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $91
80107def:	6a 5b                	push   $0x5b
  jmp alltraps
80107df1:	e9 81 f6 ff ff       	jmp    80107477 <alltraps>

80107df6 <vector92>:
.globl vector92
vector92:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $92
80107df8:	6a 5c                	push   $0x5c
  jmp alltraps
80107dfa:	e9 78 f6 ff ff       	jmp    80107477 <alltraps>

80107dff <vector93>:
.globl vector93
vector93:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $93
80107e01:	6a 5d                	push   $0x5d
  jmp alltraps
80107e03:	e9 6f f6 ff ff       	jmp    80107477 <alltraps>

80107e08 <vector94>:
.globl vector94
vector94:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $94
80107e0a:	6a 5e                	push   $0x5e
  jmp alltraps
80107e0c:	e9 66 f6 ff ff       	jmp    80107477 <alltraps>

80107e11 <vector95>:
.globl vector95
vector95:
  pushl $0
80107e11:	6a 00                	push   $0x0
  pushl $95
80107e13:	6a 5f                	push   $0x5f
  jmp alltraps
80107e15:	e9 5d f6 ff ff       	jmp    80107477 <alltraps>

80107e1a <vector96>:
.globl vector96
vector96:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $96
80107e1c:	6a 60                	push   $0x60
  jmp alltraps
80107e1e:	e9 54 f6 ff ff       	jmp    80107477 <alltraps>

80107e23 <vector97>:
.globl vector97
vector97:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $97
80107e25:	6a 61                	push   $0x61
  jmp alltraps
80107e27:	e9 4b f6 ff ff       	jmp    80107477 <alltraps>

80107e2c <vector98>:
.globl vector98
vector98:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $98
80107e2e:	6a 62                	push   $0x62
  jmp alltraps
80107e30:	e9 42 f6 ff ff       	jmp    80107477 <alltraps>

80107e35 <vector99>:
.globl vector99
vector99:
  pushl $0
80107e35:	6a 00                	push   $0x0
  pushl $99
80107e37:	6a 63                	push   $0x63
  jmp alltraps
80107e39:	e9 39 f6 ff ff       	jmp    80107477 <alltraps>

80107e3e <vector100>:
.globl vector100
vector100:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $100
80107e40:	6a 64                	push   $0x64
  jmp alltraps
80107e42:	e9 30 f6 ff ff       	jmp    80107477 <alltraps>

80107e47 <vector101>:
.globl vector101
vector101:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $101
80107e49:	6a 65                	push   $0x65
  jmp alltraps
80107e4b:	e9 27 f6 ff ff       	jmp    80107477 <alltraps>

80107e50 <vector102>:
.globl vector102
vector102:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $102
80107e52:	6a 66                	push   $0x66
  jmp alltraps
80107e54:	e9 1e f6 ff ff       	jmp    80107477 <alltraps>

80107e59 <vector103>:
.globl vector103
vector103:
  pushl $0
80107e59:	6a 00                	push   $0x0
  pushl $103
80107e5b:	6a 67                	push   $0x67
  jmp alltraps
80107e5d:	e9 15 f6 ff ff       	jmp    80107477 <alltraps>

80107e62 <vector104>:
.globl vector104
vector104:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $104
80107e64:	6a 68                	push   $0x68
  jmp alltraps
80107e66:	e9 0c f6 ff ff       	jmp    80107477 <alltraps>

80107e6b <vector105>:
.globl vector105
vector105:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $105
80107e6d:	6a 69                	push   $0x69
  jmp alltraps
80107e6f:	e9 03 f6 ff ff       	jmp    80107477 <alltraps>

80107e74 <vector106>:
.globl vector106
vector106:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $106
80107e76:	6a 6a                	push   $0x6a
  jmp alltraps
80107e78:	e9 fa f5 ff ff       	jmp    80107477 <alltraps>

80107e7d <vector107>:
.globl vector107
vector107:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $107
80107e7f:	6a 6b                	push   $0x6b
  jmp alltraps
80107e81:	e9 f1 f5 ff ff       	jmp    80107477 <alltraps>

80107e86 <vector108>:
.globl vector108
vector108:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $108
80107e88:	6a 6c                	push   $0x6c
  jmp alltraps
80107e8a:	e9 e8 f5 ff ff       	jmp    80107477 <alltraps>

80107e8f <vector109>:
.globl vector109
vector109:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $109
80107e91:	6a 6d                	push   $0x6d
  jmp alltraps
80107e93:	e9 df f5 ff ff       	jmp    80107477 <alltraps>

80107e98 <vector110>:
.globl vector110
vector110:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $110
80107e9a:	6a 6e                	push   $0x6e
  jmp alltraps
80107e9c:	e9 d6 f5 ff ff       	jmp    80107477 <alltraps>

80107ea1 <vector111>:
.globl vector111
vector111:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $111
80107ea3:	6a 6f                	push   $0x6f
  jmp alltraps
80107ea5:	e9 cd f5 ff ff       	jmp    80107477 <alltraps>

80107eaa <vector112>:
.globl vector112
vector112:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $112
80107eac:	6a 70                	push   $0x70
  jmp alltraps
80107eae:	e9 c4 f5 ff ff       	jmp    80107477 <alltraps>

80107eb3 <vector113>:
.globl vector113
vector113:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $113
80107eb5:	6a 71                	push   $0x71
  jmp alltraps
80107eb7:	e9 bb f5 ff ff       	jmp    80107477 <alltraps>

80107ebc <vector114>:
.globl vector114
vector114:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $114
80107ebe:	6a 72                	push   $0x72
  jmp alltraps
80107ec0:	e9 b2 f5 ff ff       	jmp    80107477 <alltraps>

80107ec5 <vector115>:
.globl vector115
vector115:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $115
80107ec7:	6a 73                	push   $0x73
  jmp alltraps
80107ec9:	e9 a9 f5 ff ff       	jmp    80107477 <alltraps>

80107ece <vector116>:
.globl vector116
vector116:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $116
80107ed0:	6a 74                	push   $0x74
  jmp alltraps
80107ed2:	e9 a0 f5 ff ff       	jmp    80107477 <alltraps>

80107ed7 <vector117>:
.globl vector117
vector117:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $117
80107ed9:	6a 75                	push   $0x75
  jmp alltraps
80107edb:	e9 97 f5 ff ff       	jmp    80107477 <alltraps>

80107ee0 <vector118>:
.globl vector118
vector118:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $118
80107ee2:	6a 76                	push   $0x76
  jmp alltraps
80107ee4:	e9 8e f5 ff ff       	jmp    80107477 <alltraps>

80107ee9 <vector119>:
.globl vector119
vector119:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $119
80107eeb:	6a 77                	push   $0x77
  jmp alltraps
80107eed:	e9 85 f5 ff ff       	jmp    80107477 <alltraps>

80107ef2 <vector120>:
.globl vector120
vector120:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $120
80107ef4:	6a 78                	push   $0x78
  jmp alltraps
80107ef6:	e9 7c f5 ff ff       	jmp    80107477 <alltraps>

80107efb <vector121>:
.globl vector121
vector121:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $121
80107efd:	6a 79                	push   $0x79
  jmp alltraps
80107eff:	e9 73 f5 ff ff       	jmp    80107477 <alltraps>

80107f04 <vector122>:
.globl vector122
vector122:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $122
80107f06:	6a 7a                	push   $0x7a
  jmp alltraps
80107f08:	e9 6a f5 ff ff       	jmp    80107477 <alltraps>

80107f0d <vector123>:
.globl vector123
vector123:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $123
80107f0f:	6a 7b                	push   $0x7b
  jmp alltraps
80107f11:	e9 61 f5 ff ff       	jmp    80107477 <alltraps>

80107f16 <vector124>:
.globl vector124
vector124:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $124
80107f18:	6a 7c                	push   $0x7c
  jmp alltraps
80107f1a:	e9 58 f5 ff ff       	jmp    80107477 <alltraps>

80107f1f <vector125>:
.globl vector125
vector125:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $125
80107f21:	6a 7d                	push   $0x7d
  jmp alltraps
80107f23:	e9 4f f5 ff ff       	jmp    80107477 <alltraps>

80107f28 <vector126>:
.globl vector126
vector126:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $126
80107f2a:	6a 7e                	push   $0x7e
  jmp alltraps
80107f2c:	e9 46 f5 ff ff       	jmp    80107477 <alltraps>

80107f31 <vector127>:
.globl vector127
vector127:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $127
80107f33:	6a 7f                	push   $0x7f
  jmp alltraps
80107f35:	e9 3d f5 ff ff       	jmp    80107477 <alltraps>

80107f3a <vector128>:
.globl vector128
vector128:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $128
80107f3c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107f41:	e9 31 f5 ff ff       	jmp    80107477 <alltraps>

80107f46 <vector129>:
.globl vector129
vector129:
  pushl $0
80107f46:	6a 00                	push   $0x0
  pushl $129
80107f48:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107f4d:	e9 25 f5 ff ff       	jmp    80107477 <alltraps>

80107f52 <vector130>:
.globl vector130
vector130:
  pushl $0
80107f52:	6a 00                	push   $0x0
  pushl $130
80107f54:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f59:	e9 19 f5 ff ff       	jmp    80107477 <alltraps>

80107f5e <vector131>:
.globl vector131
vector131:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $131
80107f60:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f65:	e9 0d f5 ff ff       	jmp    80107477 <alltraps>

80107f6a <vector132>:
.globl vector132
vector132:
  pushl $0
80107f6a:	6a 00                	push   $0x0
  pushl $132
80107f6c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f71:	e9 01 f5 ff ff       	jmp    80107477 <alltraps>

80107f76 <vector133>:
.globl vector133
vector133:
  pushl $0
80107f76:	6a 00                	push   $0x0
  pushl $133
80107f78:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f7d:	e9 f5 f4 ff ff       	jmp    80107477 <alltraps>

80107f82 <vector134>:
.globl vector134
vector134:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $134
80107f84:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f89:	e9 e9 f4 ff ff       	jmp    80107477 <alltraps>

80107f8e <vector135>:
.globl vector135
vector135:
  pushl $0
80107f8e:	6a 00                	push   $0x0
  pushl $135
80107f90:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107f95:	e9 dd f4 ff ff       	jmp    80107477 <alltraps>

80107f9a <vector136>:
.globl vector136
vector136:
  pushl $0
80107f9a:	6a 00                	push   $0x0
  pushl $136
80107f9c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107fa1:	e9 d1 f4 ff ff       	jmp    80107477 <alltraps>

80107fa6 <vector137>:
.globl vector137
vector137:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $137
80107fa8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107fad:	e9 c5 f4 ff ff       	jmp    80107477 <alltraps>

80107fb2 <vector138>:
.globl vector138
vector138:
  pushl $0
80107fb2:	6a 00                	push   $0x0
  pushl $138
80107fb4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107fb9:	e9 b9 f4 ff ff       	jmp    80107477 <alltraps>

80107fbe <vector139>:
.globl vector139
vector139:
  pushl $0
80107fbe:	6a 00                	push   $0x0
  pushl $139
80107fc0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107fc5:	e9 ad f4 ff ff       	jmp    80107477 <alltraps>

80107fca <vector140>:
.globl vector140
vector140:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $140
80107fcc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107fd1:	e9 a1 f4 ff ff       	jmp    80107477 <alltraps>

80107fd6 <vector141>:
.globl vector141
vector141:
  pushl $0
80107fd6:	6a 00                	push   $0x0
  pushl $141
80107fd8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107fdd:	e9 95 f4 ff ff       	jmp    80107477 <alltraps>

80107fe2 <vector142>:
.globl vector142
vector142:
  pushl $0
80107fe2:	6a 00                	push   $0x0
  pushl $142
80107fe4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107fe9:	e9 89 f4 ff ff       	jmp    80107477 <alltraps>

80107fee <vector143>:
.globl vector143
vector143:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $143
80107ff0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107ff5:	e9 7d f4 ff ff       	jmp    80107477 <alltraps>

80107ffa <vector144>:
.globl vector144
vector144:
  pushl $0
80107ffa:	6a 00                	push   $0x0
  pushl $144
80107ffc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108001:	e9 71 f4 ff ff       	jmp    80107477 <alltraps>

80108006 <vector145>:
.globl vector145
vector145:
  pushl $0
80108006:	6a 00                	push   $0x0
  pushl $145
80108008:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010800d:	e9 65 f4 ff ff       	jmp    80107477 <alltraps>

80108012 <vector146>:
.globl vector146
vector146:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $146
80108014:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108019:	e9 59 f4 ff ff       	jmp    80107477 <alltraps>

8010801e <vector147>:
.globl vector147
vector147:
  pushl $0
8010801e:	6a 00                	push   $0x0
  pushl $147
80108020:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108025:	e9 4d f4 ff ff       	jmp    80107477 <alltraps>

8010802a <vector148>:
.globl vector148
vector148:
  pushl $0
8010802a:	6a 00                	push   $0x0
  pushl $148
8010802c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108031:	e9 41 f4 ff ff       	jmp    80107477 <alltraps>

80108036 <vector149>:
.globl vector149
vector149:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $149
80108038:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010803d:	e9 35 f4 ff ff       	jmp    80107477 <alltraps>

80108042 <vector150>:
.globl vector150
vector150:
  pushl $0
80108042:	6a 00                	push   $0x0
  pushl $150
80108044:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108049:	e9 29 f4 ff ff       	jmp    80107477 <alltraps>

8010804e <vector151>:
.globl vector151
vector151:
  pushl $0
8010804e:	6a 00                	push   $0x0
  pushl $151
80108050:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108055:	e9 1d f4 ff ff       	jmp    80107477 <alltraps>

8010805a <vector152>:
.globl vector152
vector152:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $152
8010805c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108061:	e9 11 f4 ff ff       	jmp    80107477 <alltraps>

80108066 <vector153>:
.globl vector153
vector153:
  pushl $0
80108066:	6a 00                	push   $0x0
  pushl $153
80108068:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010806d:	e9 05 f4 ff ff       	jmp    80107477 <alltraps>

80108072 <vector154>:
.globl vector154
vector154:
  pushl $0
80108072:	6a 00                	push   $0x0
  pushl $154
80108074:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108079:	e9 f9 f3 ff ff       	jmp    80107477 <alltraps>

8010807e <vector155>:
.globl vector155
vector155:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $155
80108080:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108085:	e9 ed f3 ff ff       	jmp    80107477 <alltraps>

8010808a <vector156>:
.globl vector156
vector156:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $156
8010808c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108091:	e9 e1 f3 ff ff       	jmp    80107477 <alltraps>

80108096 <vector157>:
.globl vector157
vector157:
  pushl $0
80108096:	6a 00                	push   $0x0
  pushl $157
80108098:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010809d:	e9 d5 f3 ff ff       	jmp    80107477 <alltraps>

801080a2 <vector158>:
.globl vector158
vector158:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $158
801080a4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801080a9:	e9 c9 f3 ff ff       	jmp    80107477 <alltraps>

801080ae <vector159>:
.globl vector159
vector159:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $159
801080b0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801080b5:	e9 bd f3 ff ff       	jmp    80107477 <alltraps>

801080ba <vector160>:
.globl vector160
vector160:
  pushl $0
801080ba:	6a 00                	push   $0x0
  pushl $160
801080bc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801080c1:	e9 b1 f3 ff ff       	jmp    80107477 <alltraps>

801080c6 <vector161>:
.globl vector161
vector161:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $161
801080c8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801080cd:	e9 a5 f3 ff ff       	jmp    80107477 <alltraps>

801080d2 <vector162>:
.globl vector162
vector162:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $162
801080d4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801080d9:	e9 99 f3 ff ff       	jmp    80107477 <alltraps>

801080de <vector163>:
.globl vector163
vector163:
  pushl $0
801080de:	6a 00                	push   $0x0
  pushl $163
801080e0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801080e5:	e9 8d f3 ff ff       	jmp    80107477 <alltraps>

801080ea <vector164>:
.globl vector164
vector164:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $164
801080ec:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801080f1:	e9 81 f3 ff ff       	jmp    80107477 <alltraps>

801080f6 <vector165>:
.globl vector165
vector165:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $165
801080f8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801080fd:	e9 75 f3 ff ff       	jmp    80107477 <alltraps>

80108102 <vector166>:
.globl vector166
vector166:
  pushl $0
80108102:	6a 00                	push   $0x0
  pushl $166
80108104:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108109:	e9 69 f3 ff ff       	jmp    80107477 <alltraps>

8010810e <vector167>:
.globl vector167
vector167:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $167
80108110:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108115:	e9 5d f3 ff ff       	jmp    80107477 <alltraps>

8010811a <vector168>:
.globl vector168
vector168:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $168
8010811c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108121:	e9 51 f3 ff ff       	jmp    80107477 <alltraps>

80108126 <vector169>:
.globl vector169
vector169:
  pushl $0
80108126:	6a 00                	push   $0x0
  pushl $169
80108128:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010812d:	e9 45 f3 ff ff       	jmp    80107477 <alltraps>

80108132 <vector170>:
.globl vector170
vector170:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $170
80108134:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108139:	e9 39 f3 ff ff       	jmp    80107477 <alltraps>

8010813e <vector171>:
.globl vector171
vector171:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $171
80108140:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108145:	e9 2d f3 ff ff       	jmp    80107477 <alltraps>

8010814a <vector172>:
.globl vector172
vector172:
  pushl $0
8010814a:	6a 00                	push   $0x0
  pushl $172
8010814c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108151:	e9 21 f3 ff ff       	jmp    80107477 <alltraps>

80108156 <vector173>:
.globl vector173
vector173:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $173
80108158:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010815d:	e9 15 f3 ff ff       	jmp    80107477 <alltraps>

80108162 <vector174>:
.globl vector174
vector174:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $174
80108164:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108169:	e9 09 f3 ff ff       	jmp    80107477 <alltraps>

8010816e <vector175>:
.globl vector175
vector175:
  pushl $0
8010816e:	6a 00                	push   $0x0
  pushl $175
80108170:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108175:	e9 fd f2 ff ff       	jmp    80107477 <alltraps>

8010817a <vector176>:
.globl vector176
vector176:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $176
8010817c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108181:	e9 f1 f2 ff ff       	jmp    80107477 <alltraps>

80108186 <vector177>:
.globl vector177
vector177:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $177
80108188:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010818d:	e9 e5 f2 ff ff       	jmp    80107477 <alltraps>

80108192 <vector178>:
.globl vector178
vector178:
  pushl $0
80108192:	6a 00                	push   $0x0
  pushl $178
80108194:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108199:	e9 d9 f2 ff ff       	jmp    80107477 <alltraps>

8010819e <vector179>:
.globl vector179
vector179:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $179
801081a0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801081a5:	e9 cd f2 ff ff       	jmp    80107477 <alltraps>

801081aa <vector180>:
.globl vector180
vector180:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $180
801081ac:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801081b1:	e9 c1 f2 ff ff       	jmp    80107477 <alltraps>

801081b6 <vector181>:
.globl vector181
vector181:
  pushl $0
801081b6:	6a 00                	push   $0x0
  pushl $181
801081b8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801081bd:	e9 b5 f2 ff ff       	jmp    80107477 <alltraps>

801081c2 <vector182>:
.globl vector182
vector182:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $182
801081c4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801081c9:	e9 a9 f2 ff ff       	jmp    80107477 <alltraps>

801081ce <vector183>:
.globl vector183
vector183:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $183
801081d0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801081d5:	e9 9d f2 ff ff       	jmp    80107477 <alltraps>

801081da <vector184>:
.globl vector184
vector184:
  pushl $0
801081da:	6a 00                	push   $0x0
  pushl $184
801081dc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801081e1:	e9 91 f2 ff ff       	jmp    80107477 <alltraps>

801081e6 <vector185>:
.globl vector185
vector185:
  pushl $0
801081e6:	6a 00                	push   $0x0
  pushl $185
801081e8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801081ed:	e9 85 f2 ff ff       	jmp    80107477 <alltraps>

801081f2 <vector186>:
.globl vector186
vector186:
  pushl $0
801081f2:	6a 00                	push   $0x0
  pushl $186
801081f4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801081f9:	e9 79 f2 ff ff       	jmp    80107477 <alltraps>

801081fe <vector187>:
.globl vector187
vector187:
  pushl $0
801081fe:	6a 00                	push   $0x0
  pushl $187
80108200:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108205:	e9 6d f2 ff ff       	jmp    80107477 <alltraps>

8010820a <vector188>:
.globl vector188
vector188:
  pushl $0
8010820a:	6a 00                	push   $0x0
  pushl $188
8010820c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108211:	e9 61 f2 ff ff       	jmp    80107477 <alltraps>

80108216 <vector189>:
.globl vector189
vector189:
  pushl $0
80108216:	6a 00                	push   $0x0
  pushl $189
80108218:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010821d:	e9 55 f2 ff ff       	jmp    80107477 <alltraps>

80108222 <vector190>:
.globl vector190
vector190:
  pushl $0
80108222:	6a 00                	push   $0x0
  pushl $190
80108224:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108229:	e9 49 f2 ff ff       	jmp    80107477 <alltraps>

8010822e <vector191>:
.globl vector191
vector191:
  pushl $0
8010822e:	6a 00                	push   $0x0
  pushl $191
80108230:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108235:	e9 3d f2 ff ff       	jmp    80107477 <alltraps>

8010823a <vector192>:
.globl vector192
vector192:
  pushl $0
8010823a:	6a 00                	push   $0x0
  pushl $192
8010823c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108241:	e9 31 f2 ff ff       	jmp    80107477 <alltraps>

80108246 <vector193>:
.globl vector193
vector193:
  pushl $0
80108246:	6a 00                	push   $0x0
  pushl $193
80108248:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010824d:	e9 25 f2 ff ff       	jmp    80107477 <alltraps>

80108252 <vector194>:
.globl vector194
vector194:
  pushl $0
80108252:	6a 00                	push   $0x0
  pushl $194
80108254:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108259:	e9 19 f2 ff ff       	jmp    80107477 <alltraps>

8010825e <vector195>:
.globl vector195
vector195:
  pushl $0
8010825e:	6a 00                	push   $0x0
  pushl $195
80108260:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108265:	e9 0d f2 ff ff       	jmp    80107477 <alltraps>

8010826a <vector196>:
.globl vector196
vector196:
  pushl $0
8010826a:	6a 00                	push   $0x0
  pushl $196
8010826c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108271:	e9 01 f2 ff ff       	jmp    80107477 <alltraps>

80108276 <vector197>:
.globl vector197
vector197:
  pushl $0
80108276:	6a 00                	push   $0x0
  pushl $197
80108278:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010827d:	e9 f5 f1 ff ff       	jmp    80107477 <alltraps>

80108282 <vector198>:
.globl vector198
vector198:
  pushl $0
80108282:	6a 00                	push   $0x0
  pushl $198
80108284:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108289:	e9 e9 f1 ff ff       	jmp    80107477 <alltraps>

8010828e <vector199>:
.globl vector199
vector199:
  pushl $0
8010828e:	6a 00                	push   $0x0
  pushl $199
80108290:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108295:	e9 dd f1 ff ff       	jmp    80107477 <alltraps>

8010829a <vector200>:
.globl vector200
vector200:
  pushl $0
8010829a:	6a 00                	push   $0x0
  pushl $200
8010829c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801082a1:	e9 d1 f1 ff ff       	jmp    80107477 <alltraps>

801082a6 <vector201>:
.globl vector201
vector201:
  pushl $0
801082a6:	6a 00                	push   $0x0
  pushl $201
801082a8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801082ad:	e9 c5 f1 ff ff       	jmp    80107477 <alltraps>

801082b2 <vector202>:
.globl vector202
vector202:
  pushl $0
801082b2:	6a 00                	push   $0x0
  pushl $202
801082b4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801082b9:	e9 b9 f1 ff ff       	jmp    80107477 <alltraps>

801082be <vector203>:
.globl vector203
vector203:
  pushl $0
801082be:	6a 00                	push   $0x0
  pushl $203
801082c0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801082c5:	e9 ad f1 ff ff       	jmp    80107477 <alltraps>

801082ca <vector204>:
.globl vector204
vector204:
  pushl $0
801082ca:	6a 00                	push   $0x0
  pushl $204
801082cc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801082d1:	e9 a1 f1 ff ff       	jmp    80107477 <alltraps>

801082d6 <vector205>:
.globl vector205
vector205:
  pushl $0
801082d6:	6a 00                	push   $0x0
  pushl $205
801082d8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801082dd:	e9 95 f1 ff ff       	jmp    80107477 <alltraps>

801082e2 <vector206>:
.globl vector206
vector206:
  pushl $0
801082e2:	6a 00                	push   $0x0
  pushl $206
801082e4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801082e9:	e9 89 f1 ff ff       	jmp    80107477 <alltraps>

801082ee <vector207>:
.globl vector207
vector207:
  pushl $0
801082ee:	6a 00                	push   $0x0
  pushl $207
801082f0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801082f5:	e9 7d f1 ff ff       	jmp    80107477 <alltraps>

801082fa <vector208>:
.globl vector208
vector208:
  pushl $0
801082fa:	6a 00                	push   $0x0
  pushl $208
801082fc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108301:	e9 71 f1 ff ff       	jmp    80107477 <alltraps>

80108306 <vector209>:
.globl vector209
vector209:
  pushl $0
80108306:	6a 00                	push   $0x0
  pushl $209
80108308:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010830d:	e9 65 f1 ff ff       	jmp    80107477 <alltraps>

80108312 <vector210>:
.globl vector210
vector210:
  pushl $0
80108312:	6a 00                	push   $0x0
  pushl $210
80108314:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108319:	e9 59 f1 ff ff       	jmp    80107477 <alltraps>

8010831e <vector211>:
.globl vector211
vector211:
  pushl $0
8010831e:	6a 00                	push   $0x0
  pushl $211
80108320:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108325:	e9 4d f1 ff ff       	jmp    80107477 <alltraps>

8010832a <vector212>:
.globl vector212
vector212:
  pushl $0
8010832a:	6a 00                	push   $0x0
  pushl $212
8010832c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108331:	e9 41 f1 ff ff       	jmp    80107477 <alltraps>

80108336 <vector213>:
.globl vector213
vector213:
  pushl $0
80108336:	6a 00                	push   $0x0
  pushl $213
80108338:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010833d:	e9 35 f1 ff ff       	jmp    80107477 <alltraps>

80108342 <vector214>:
.globl vector214
vector214:
  pushl $0
80108342:	6a 00                	push   $0x0
  pushl $214
80108344:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108349:	e9 29 f1 ff ff       	jmp    80107477 <alltraps>

8010834e <vector215>:
.globl vector215
vector215:
  pushl $0
8010834e:	6a 00                	push   $0x0
  pushl $215
80108350:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108355:	e9 1d f1 ff ff       	jmp    80107477 <alltraps>

8010835a <vector216>:
.globl vector216
vector216:
  pushl $0
8010835a:	6a 00                	push   $0x0
  pushl $216
8010835c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108361:	e9 11 f1 ff ff       	jmp    80107477 <alltraps>

80108366 <vector217>:
.globl vector217
vector217:
  pushl $0
80108366:	6a 00                	push   $0x0
  pushl $217
80108368:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010836d:	e9 05 f1 ff ff       	jmp    80107477 <alltraps>

80108372 <vector218>:
.globl vector218
vector218:
  pushl $0
80108372:	6a 00                	push   $0x0
  pushl $218
80108374:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108379:	e9 f9 f0 ff ff       	jmp    80107477 <alltraps>

8010837e <vector219>:
.globl vector219
vector219:
  pushl $0
8010837e:	6a 00                	push   $0x0
  pushl $219
80108380:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108385:	e9 ed f0 ff ff       	jmp    80107477 <alltraps>

8010838a <vector220>:
.globl vector220
vector220:
  pushl $0
8010838a:	6a 00                	push   $0x0
  pushl $220
8010838c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108391:	e9 e1 f0 ff ff       	jmp    80107477 <alltraps>

80108396 <vector221>:
.globl vector221
vector221:
  pushl $0
80108396:	6a 00                	push   $0x0
  pushl $221
80108398:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010839d:	e9 d5 f0 ff ff       	jmp    80107477 <alltraps>

801083a2 <vector222>:
.globl vector222
vector222:
  pushl $0
801083a2:	6a 00                	push   $0x0
  pushl $222
801083a4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801083a9:	e9 c9 f0 ff ff       	jmp    80107477 <alltraps>

801083ae <vector223>:
.globl vector223
vector223:
  pushl $0
801083ae:	6a 00                	push   $0x0
  pushl $223
801083b0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801083b5:	e9 bd f0 ff ff       	jmp    80107477 <alltraps>

801083ba <vector224>:
.globl vector224
vector224:
  pushl $0
801083ba:	6a 00                	push   $0x0
  pushl $224
801083bc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801083c1:	e9 b1 f0 ff ff       	jmp    80107477 <alltraps>

801083c6 <vector225>:
.globl vector225
vector225:
  pushl $0
801083c6:	6a 00                	push   $0x0
  pushl $225
801083c8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801083cd:	e9 a5 f0 ff ff       	jmp    80107477 <alltraps>

801083d2 <vector226>:
.globl vector226
vector226:
  pushl $0
801083d2:	6a 00                	push   $0x0
  pushl $226
801083d4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801083d9:	e9 99 f0 ff ff       	jmp    80107477 <alltraps>

801083de <vector227>:
.globl vector227
vector227:
  pushl $0
801083de:	6a 00                	push   $0x0
  pushl $227
801083e0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801083e5:	e9 8d f0 ff ff       	jmp    80107477 <alltraps>

801083ea <vector228>:
.globl vector228
vector228:
  pushl $0
801083ea:	6a 00                	push   $0x0
  pushl $228
801083ec:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801083f1:	e9 81 f0 ff ff       	jmp    80107477 <alltraps>

801083f6 <vector229>:
.globl vector229
vector229:
  pushl $0
801083f6:	6a 00                	push   $0x0
  pushl $229
801083f8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801083fd:	e9 75 f0 ff ff       	jmp    80107477 <alltraps>

80108402 <vector230>:
.globl vector230
vector230:
  pushl $0
80108402:	6a 00                	push   $0x0
  pushl $230
80108404:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108409:	e9 69 f0 ff ff       	jmp    80107477 <alltraps>

8010840e <vector231>:
.globl vector231
vector231:
  pushl $0
8010840e:	6a 00                	push   $0x0
  pushl $231
80108410:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108415:	e9 5d f0 ff ff       	jmp    80107477 <alltraps>

8010841a <vector232>:
.globl vector232
vector232:
  pushl $0
8010841a:	6a 00                	push   $0x0
  pushl $232
8010841c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108421:	e9 51 f0 ff ff       	jmp    80107477 <alltraps>

80108426 <vector233>:
.globl vector233
vector233:
  pushl $0
80108426:	6a 00                	push   $0x0
  pushl $233
80108428:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010842d:	e9 45 f0 ff ff       	jmp    80107477 <alltraps>

80108432 <vector234>:
.globl vector234
vector234:
  pushl $0
80108432:	6a 00                	push   $0x0
  pushl $234
80108434:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108439:	e9 39 f0 ff ff       	jmp    80107477 <alltraps>

8010843e <vector235>:
.globl vector235
vector235:
  pushl $0
8010843e:	6a 00                	push   $0x0
  pushl $235
80108440:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108445:	e9 2d f0 ff ff       	jmp    80107477 <alltraps>

8010844a <vector236>:
.globl vector236
vector236:
  pushl $0
8010844a:	6a 00                	push   $0x0
  pushl $236
8010844c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108451:	e9 21 f0 ff ff       	jmp    80107477 <alltraps>

80108456 <vector237>:
.globl vector237
vector237:
  pushl $0
80108456:	6a 00                	push   $0x0
  pushl $237
80108458:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010845d:	e9 15 f0 ff ff       	jmp    80107477 <alltraps>

80108462 <vector238>:
.globl vector238
vector238:
  pushl $0
80108462:	6a 00                	push   $0x0
  pushl $238
80108464:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108469:	e9 09 f0 ff ff       	jmp    80107477 <alltraps>

8010846e <vector239>:
.globl vector239
vector239:
  pushl $0
8010846e:	6a 00                	push   $0x0
  pushl $239
80108470:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108475:	e9 fd ef ff ff       	jmp    80107477 <alltraps>

8010847a <vector240>:
.globl vector240
vector240:
  pushl $0
8010847a:	6a 00                	push   $0x0
  pushl $240
8010847c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108481:	e9 f1 ef ff ff       	jmp    80107477 <alltraps>

80108486 <vector241>:
.globl vector241
vector241:
  pushl $0
80108486:	6a 00                	push   $0x0
  pushl $241
80108488:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010848d:	e9 e5 ef ff ff       	jmp    80107477 <alltraps>

80108492 <vector242>:
.globl vector242
vector242:
  pushl $0
80108492:	6a 00                	push   $0x0
  pushl $242
80108494:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108499:	e9 d9 ef ff ff       	jmp    80107477 <alltraps>

8010849e <vector243>:
.globl vector243
vector243:
  pushl $0
8010849e:	6a 00                	push   $0x0
  pushl $243
801084a0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801084a5:	e9 cd ef ff ff       	jmp    80107477 <alltraps>

801084aa <vector244>:
.globl vector244
vector244:
  pushl $0
801084aa:	6a 00                	push   $0x0
  pushl $244
801084ac:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801084b1:	e9 c1 ef ff ff       	jmp    80107477 <alltraps>

801084b6 <vector245>:
.globl vector245
vector245:
  pushl $0
801084b6:	6a 00                	push   $0x0
  pushl $245
801084b8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801084bd:	e9 b5 ef ff ff       	jmp    80107477 <alltraps>

801084c2 <vector246>:
.globl vector246
vector246:
  pushl $0
801084c2:	6a 00                	push   $0x0
  pushl $246
801084c4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801084c9:	e9 a9 ef ff ff       	jmp    80107477 <alltraps>

801084ce <vector247>:
.globl vector247
vector247:
  pushl $0
801084ce:	6a 00                	push   $0x0
  pushl $247
801084d0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801084d5:	e9 9d ef ff ff       	jmp    80107477 <alltraps>

801084da <vector248>:
.globl vector248
vector248:
  pushl $0
801084da:	6a 00                	push   $0x0
  pushl $248
801084dc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801084e1:	e9 91 ef ff ff       	jmp    80107477 <alltraps>

801084e6 <vector249>:
.globl vector249
vector249:
  pushl $0
801084e6:	6a 00                	push   $0x0
  pushl $249
801084e8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801084ed:	e9 85 ef ff ff       	jmp    80107477 <alltraps>

801084f2 <vector250>:
.globl vector250
vector250:
  pushl $0
801084f2:	6a 00                	push   $0x0
  pushl $250
801084f4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801084f9:	e9 79 ef ff ff       	jmp    80107477 <alltraps>

801084fe <vector251>:
.globl vector251
vector251:
  pushl $0
801084fe:	6a 00                	push   $0x0
  pushl $251
80108500:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108505:	e9 6d ef ff ff       	jmp    80107477 <alltraps>

8010850a <vector252>:
.globl vector252
vector252:
  pushl $0
8010850a:	6a 00                	push   $0x0
  pushl $252
8010850c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108511:	e9 61 ef ff ff       	jmp    80107477 <alltraps>

80108516 <vector253>:
.globl vector253
vector253:
  pushl $0
80108516:	6a 00                	push   $0x0
  pushl $253
80108518:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010851d:	e9 55 ef ff ff       	jmp    80107477 <alltraps>

80108522 <vector254>:
.globl vector254
vector254:
  pushl $0
80108522:	6a 00                	push   $0x0
  pushl $254
80108524:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108529:	e9 49 ef ff ff       	jmp    80107477 <alltraps>

8010852e <vector255>:
.globl vector255
vector255:
  pushl $0
8010852e:	6a 00                	push   $0x0
  pushl $255
80108530:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108535:	e9 3d ef ff ff       	jmp    80107477 <alltraps>

8010853a <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010853a:	55                   	push   %ebp
8010853b:	89 e5                	mov    %esp,%ebp
8010853d:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108540:	8b 45 0c             	mov    0xc(%ebp),%eax
80108543:	83 e8 01             	sub    $0x1,%eax
80108546:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010854a:	8b 45 08             	mov    0x8(%ebp),%eax
8010854d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108551:	8b 45 08             	mov    0x8(%ebp),%eax
80108554:	c1 e8 10             	shr    $0x10,%eax
80108557:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010855b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010855e:	0f 01 10             	lgdtl  (%eax)
}
80108561:	90                   	nop
80108562:	c9                   	leave  
80108563:	c3                   	ret    

80108564 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108564:	55                   	push   %ebp
80108565:	89 e5                	mov    %esp,%ebp
80108567:	83 ec 04             	sub    $0x4,%esp
8010856a:	8b 45 08             	mov    0x8(%ebp),%eax
8010856d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108571:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108575:	0f 00 d8             	ltr    %ax
}
80108578:	90                   	nop
80108579:	c9                   	leave  
8010857a:	c3                   	ret    

8010857b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010857b:	55                   	push   %ebp
8010857c:	89 e5                	mov    %esp,%ebp
8010857e:	83 ec 04             	sub    $0x4,%esp
80108581:	8b 45 08             	mov    0x8(%ebp),%eax
80108584:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108588:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010858c:	8e e8                	mov    %eax,%gs
}
8010858e:	90                   	nop
8010858f:	c9                   	leave  
80108590:	c3                   	ret    

80108591 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108591:	55                   	push   %ebp
80108592:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108594:	8b 45 08             	mov    0x8(%ebp),%eax
80108597:	0f 22 d8             	mov    %eax,%cr3
}
8010859a:	90                   	nop
8010859b:	5d                   	pop    %ebp
8010859c:	c3                   	ret    

8010859d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010859d:	55                   	push   %ebp
8010859e:	89 e5                	mov    %esp,%ebp
801085a0:	8b 45 08             	mov    0x8(%ebp),%eax
801085a3:	05 00 00 00 80       	add    $0x80000000,%eax
801085a8:	5d                   	pop    %ebp
801085a9:	c3                   	ret    

801085aa <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801085aa:	55                   	push   %ebp
801085ab:	89 e5                	mov    %esp,%ebp
801085ad:	8b 45 08             	mov    0x8(%ebp),%eax
801085b0:	05 00 00 00 80       	add    $0x80000000,%eax
801085b5:	5d                   	pop    %ebp
801085b6:	c3                   	ret    

801085b7 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801085b7:	55                   	push   %ebp
801085b8:	89 e5                	mov    %esp,%ebp
801085ba:	53                   	push   %ebx
801085bb:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801085be:	e8 00 b2 ff ff       	call   801037c3 <cpunum>
801085c3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801085c9:	05 80 38 11 80       	add    $0x80113880,%eax
801085ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801085d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801085da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085dd:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801085e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801085ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ed:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085f1:	83 e2 f0             	and    $0xfffffff0,%edx
801085f4:	83 ca 0a             	or     $0xa,%edx
801085f7:	88 50 7d             	mov    %dl,0x7d(%eax)
801085fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108601:	83 ca 10             	or     $0x10,%edx
80108604:	88 50 7d             	mov    %dl,0x7d(%eax)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010860e:	83 e2 9f             	and    $0xffffff9f,%edx
80108611:	88 50 7d             	mov    %dl,0x7d(%eax)
80108614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108617:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010861b:	83 ca 80             	or     $0xffffff80,%edx
8010861e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108624:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108628:	83 ca 0f             	or     $0xf,%edx
8010862b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108631:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108635:	83 e2 ef             	and    $0xffffffef,%edx
80108638:	88 50 7e             	mov    %dl,0x7e(%eax)
8010863b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108642:	83 e2 df             	and    $0xffffffdf,%edx
80108645:	88 50 7e             	mov    %dl,0x7e(%eax)
80108648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010864f:	83 ca 40             	or     $0x40,%edx
80108652:	88 50 7e             	mov    %dl,0x7e(%eax)
80108655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108658:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010865c:	83 ca 80             	or     $0xffffff80,%edx
8010865f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108665:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108673:	ff ff 
80108675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108678:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010867f:	00 00 
80108681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108684:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010868b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108695:	83 e2 f0             	and    $0xfffffff0,%edx
80108698:	83 ca 02             	or     $0x2,%edx
8010869b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086ab:	83 ca 10             	or     $0x10,%edx
801086ae:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086be:	83 e2 9f             	and    $0xffffff9f,%edx
801086c1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ca:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086d1:	83 ca 80             	or     $0xffffff80,%edx
801086d4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086e4:	83 ca 0f             	or     $0xf,%edx
801086e7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086f7:	83 e2 ef             	and    $0xffffffef,%edx
801086fa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108703:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010870a:	83 e2 df             	and    $0xffffffdf,%edx
8010870d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108716:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010871d:	83 ca 40             	or     $0x40,%edx
80108720:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108729:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108730:	83 ca 80             	or     $0xffffff80,%edx
80108733:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108746:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010874d:	ff ff 
8010874f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108752:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108759:	00 00 
8010875b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108768:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010876f:	83 e2 f0             	and    $0xfffffff0,%edx
80108772:	83 ca 0a             	or     $0xa,%edx
80108775:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108785:	83 ca 10             	or     $0x10,%edx
80108788:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010878e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108791:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108798:	83 ca 60             	or     $0x60,%edx
8010879b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087ab:	83 ca 80             	or     $0xffffff80,%edx
801087ae:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087be:	83 ca 0f             	or     $0xf,%edx
801087c1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ca:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087d1:	83 e2 ef             	and    $0xffffffef,%edx
801087d4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087dd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087e4:	83 e2 df             	and    $0xffffffdf,%edx
801087e7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087f7:	83 ca 40             	or     $0x40,%edx
801087fa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108803:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010880a:	83 ca 80             	or     $0xffffff80,%edx
8010880d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108816:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010881d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108820:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108827:	ff ff 
80108829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882c:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108833:	00 00 
80108835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108838:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010883f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108842:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108849:	83 e2 f0             	and    $0xfffffff0,%edx
8010884c:	83 ca 02             	or     $0x2,%edx
8010884f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108858:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010885f:	83 ca 10             	or     $0x10,%edx
80108862:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108872:	83 ca 60             	or     $0x60,%edx
80108875:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010887b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108885:	83 ca 80             	or     $0xffffff80,%edx
80108888:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010888e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108891:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108898:	83 ca 0f             	or     $0xf,%edx
8010889b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088ab:	83 e2 ef             	and    $0xffffffef,%edx
801088ae:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088be:	83 e2 df             	and    $0xffffffdf,%edx
801088c1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088d1:	83 ca 40             	or     $0x40,%edx
801088d4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088e4:	83 ca 80             	or     $0xffffff80,%edx
801088e7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f0:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801088f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fa:	05 b4 00 00 00       	add    $0xb4,%eax
801088ff:	89 c3                	mov    %eax,%ebx
80108901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108904:	05 b4 00 00 00       	add    $0xb4,%eax
80108909:	c1 e8 10             	shr    $0x10,%eax
8010890c:	89 c2                	mov    %eax,%edx
8010890e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108911:	05 b4 00 00 00       	add    $0xb4,%eax
80108916:	c1 e8 18             	shr    $0x18,%eax
80108919:	89 c1                	mov    %eax,%ecx
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108925:	00 00 
80108927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892a:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108934:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010893a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108944:	83 e2 f0             	and    $0xfffffff0,%edx
80108947:	83 ca 02             	or     $0x2,%edx
8010894a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108953:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010895a:	83 ca 10             	or     $0x10,%edx
8010895d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108966:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010896d:	83 e2 9f             	and    $0xffffff9f,%edx
80108970:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108979:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108980:	83 ca 80             	or     $0xffffff80,%edx
80108983:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108993:	83 e2 f0             	and    $0xfffffff0,%edx
80108996:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010899c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089a6:	83 e2 ef             	and    $0xffffffef,%edx
801089a9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089b9:	83 e2 df             	and    $0xffffffdf,%edx
801089bc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089cc:	83 ca 40             	or     $0x40,%edx
801089cf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089df:	83 ca 80             	or     $0xffffff80,%edx
801089e2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089eb:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801089f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f4:	83 c0 70             	add    $0x70,%eax
801089f7:	83 ec 08             	sub    $0x8,%esp
801089fa:	6a 38                	push   $0x38
801089fc:	50                   	push   %eax
801089fd:	e8 38 fb ff ff       	call   8010853a <lgdt>
80108a02:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108a05:	83 ec 0c             	sub    $0xc,%esp
80108a08:	6a 18                	push   $0x18
80108a0a:	e8 6c fb ff ff       	call   8010857b <loadgs>
80108a0f:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a15:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108a1b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a22:	00 00 00 00 
}
80108a26:	90                   	nop
80108a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a2a:	c9                   	leave  
80108a2b:	c3                   	ret    

80108a2c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a2c:	55                   	push   %ebp
80108a2d:	89 e5                	mov    %esp,%ebp
80108a2f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a32:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a35:	c1 e8 16             	shr    $0x16,%eax
80108a38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80108a42:	01 d0                	add    %edx,%eax
80108a44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a4a:	8b 00                	mov    (%eax),%eax
80108a4c:	83 e0 01             	and    $0x1,%eax
80108a4f:	85 c0                	test   %eax,%eax
80108a51:	74 18                	je     80108a6b <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a56:	8b 00                	mov    (%eax),%eax
80108a58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a5d:	50                   	push   %eax
80108a5e:	e8 47 fb ff ff       	call   801085aa <p2v>
80108a63:	83 c4 04             	add    $0x4,%esp
80108a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a69:	eb 48                	jmp    80108ab3 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a6f:	74 0e                	je     80108a7f <walkpgdir+0x53>
80108a71:	e8 e7 a9 ff ff       	call   8010345d <kalloc>
80108a76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a7d:	75 07                	jne    80108a86 <walkpgdir+0x5a>
      return 0;
80108a7f:	b8 00 00 00 00       	mov    $0x0,%eax
80108a84:	eb 44                	jmp    80108aca <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108a86:	83 ec 04             	sub    $0x4,%esp
80108a89:	68 00 10 00 00       	push   $0x1000
80108a8e:	6a 00                	push   $0x0
80108a90:	ff 75 f4             	pushl  -0xc(%ebp)
80108a93:	e8 3a d3 ff ff       	call   80105dd2 <memset>
80108a98:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108a9b:	83 ec 0c             	sub    $0xc,%esp
80108a9e:	ff 75 f4             	pushl  -0xc(%ebp)
80108aa1:	e8 f7 fa ff ff       	call   8010859d <v2p>
80108aa6:	83 c4 10             	add    $0x10,%esp
80108aa9:	83 c8 07             	or     $0x7,%eax
80108aac:	89 c2                	mov    %eax,%edx
80108aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ab6:	c1 e8 0c             	shr    $0xc,%eax
80108ab9:	25 ff 03 00 00       	and    $0x3ff,%eax
80108abe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac8:	01 d0                	add    %edx,%eax
}
80108aca:	c9                   	leave  
80108acb:	c3                   	ret    

80108acc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108acc:	55                   	push   %ebp
80108acd:	89 e5                	mov    %esp,%ebp
80108acf:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ad5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ada:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108add:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ae0:	8b 45 10             	mov    0x10(%ebp),%eax
80108ae3:	01 d0                	add    %edx,%eax
80108ae5:	83 e8 01             	sub    $0x1,%eax
80108ae8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108af0:	83 ec 04             	sub    $0x4,%esp
80108af3:	6a 01                	push   $0x1
80108af5:	ff 75 f4             	pushl  -0xc(%ebp)
80108af8:	ff 75 08             	pushl  0x8(%ebp)
80108afb:	e8 2c ff ff ff       	call   80108a2c <walkpgdir>
80108b00:	83 c4 10             	add    $0x10,%esp
80108b03:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b06:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b0a:	75 07                	jne    80108b13 <mappages+0x47>
      return -1;
80108b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b11:	eb 47                	jmp    80108b5a <mappages+0x8e>
    if(*pte & PTE_P)
80108b13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b16:	8b 00                	mov    (%eax),%eax
80108b18:	83 e0 01             	and    $0x1,%eax
80108b1b:	85 c0                	test   %eax,%eax
80108b1d:	74 0d                	je     80108b2c <mappages+0x60>
      panic("remap");
80108b1f:	83 ec 0c             	sub    $0xc,%esp
80108b22:	68 74 9a 10 80       	push   $0x80109a74
80108b27:	e8 3a 7a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108b2c:	8b 45 18             	mov    0x18(%ebp),%eax
80108b2f:	0b 45 14             	or     0x14(%ebp),%eax
80108b32:	83 c8 01             	or     $0x1,%eax
80108b35:	89 c2                	mov    %eax,%edx
80108b37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b3a:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b3f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b42:	74 10                	je     80108b54 <mappages+0x88>
      break;
    a += PGSIZE;
80108b44:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108b4b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108b52:	eb 9c                	jmp    80108af0 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108b54:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108b55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b5a:	c9                   	leave  
80108b5b:	c3                   	ret    

80108b5c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b5c:	55                   	push   %ebp
80108b5d:	89 e5                	mov    %esp,%ebp
80108b5f:	53                   	push   %ebx
80108b60:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b63:	e8 f5 a8 ff ff       	call   8010345d <kalloc>
80108b68:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b6f:	75 0a                	jne    80108b7b <setupkvm+0x1f>
    return 0;
80108b71:	b8 00 00 00 00       	mov    $0x0,%eax
80108b76:	e9 8e 00 00 00       	jmp    80108c09 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b7b:	83 ec 04             	sub    $0x4,%esp
80108b7e:	68 00 10 00 00       	push   $0x1000
80108b83:	6a 00                	push   $0x0
80108b85:	ff 75 f0             	pushl  -0x10(%ebp)
80108b88:	e8 45 d2 ff ff       	call   80105dd2 <memset>
80108b8d:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108b90:	83 ec 0c             	sub    $0xc,%esp
80108b93:	68 00 00 00 0e       	push   $0xe000000
80108b98:	e8 0d fa ff ff       	call   801085aa <p2v>
80108b9d:	83 c4 10             	add    $0x10,%esp
80108ba0:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108ba5:	76 0d                	jbe    80108bb4 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108ba7:	83 ec 0c             	sub    $0xc,%esp
80108baa:	68 7a 9a 10 80       	push   $0x80109a7a
80108baf:	e8 b2 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bb4:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108bbb:	eb 40                	jmp    80108bfd <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc0:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc6:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bcc:	8b 58 08             	mov    0x8(%eax),%ebx
80108bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd2:	8b 40 04             	mov    0x4(%eax),%eax
80108bd5:	29 c3                	sub    %eax,%ebx
80108bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bda:	8b 00                	mov    (%eax),%eax
80108bdc:	83 ec 0c             	sub    $0xc,%esp
80108bdf:	51                   	push   %ecx
80108be0:	52                   	push   %edx
80108be1:	53                   	push   %ebx
80108be2:	50                   	push   %eax
80108be3:	ff 75 f0             	pushl  -0x10(%ebp)
80108be6:	e8 e1 fe ff ff       	call   80108acc <mappages>
80108beb:	83 c4 20             	add    $0x20,%esp
80108bee:	85 c0                	test   %eax,%eax
80108bf0:	79 07                	jns    80108bf9 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108bf2:	b8 00 00 00 00       	mov    $0x0,%eax
80108bf7:	eb 10                	jmp    80108c09 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bf9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108bfd:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108c04:	72 b7                	jb     80108bbd <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c0c:	c9                   	leave  
80108c0d:	c3                   	ret    

80108c0e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108c0e:	55                   	push   %ebp
80108c0f:	89 e5                	mov    %esp,%ebp
80108c11:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108c14:	e8 43 ff ff ff       	call   80108b5c <setupkvm>
80108c19:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108c1e:	e8 03 00 00 00       	call   80108c26 <switchkvm>
}
80108c23:	90                   	nop
80108c24:	c9                   	leave  
80108c25:	c3                   	ret    

80108c26 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108c26:	55                   	push   %ebp
80108c27:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c29:	a1 58 66 11 80       	mov    0x80116658,%eax
80108c2e:	50                   	push   %eax
80108c2f:	e8 69 f9 ff ff       	call   8010859d <v2p>
80108c34:	83 c4 04             	add    $0x4,%esp
80108c37:	50                   	push   %eax
80108c38:	e8 54 f9 ff ff       	call   80108591 <lcr3>
80108c3d:	83 c4 04             	add    $0x4,%esp
}
80108c40:	90                   	nop
80108c41:	c9                   	leave  
80108c42:	c3                   	ret    

80108c43 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108c43:	55                   	push   %ebp
80108c44:	89 e5                	mov    %esp,%ebp
80108c46:	56                   	push   %esi
80108c47:	53                   	push   %ebx
  pushcli();
80108c48:	e8 7f d0 ff ff       	call   80105ccc <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108c4d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c53:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c5a:	83 c2 08             	add    $0x8,%edx
80108c5d:	89 d6                	mov    %edx,%esi
80108c5f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c66:	83 c2 08             	add    $0x8,%edx
80108c69:	c1 ea 10             	shr    $0x10,%edx
80108c6c:	89 d3                	mov    %edx,%ebx
80108c6e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c75:	83 c2 08             	add    $0x8,%edx
80108c78:	c1 ea 18             	shr    $0x18,%edx
80108c7b:	89 d1                	mov    %edx,%ecx
80108c7d:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c84:	67 00 
80108c86:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108c8d:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108c93:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c9a:	83 e2 f0             	and    $0xfffffff0,%edx
80108c9d:	83 ca 09             	or     $0x9,%edx
80108ca0:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ca6:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cad:	83 ca 10             	or     $0x10,%edx
80108cb0:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cb6:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cbd:	83 e2 9f             	and    $0xffffff9f,%edx
80108cc0:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cc6:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ccd:	83 ca 80             	or     $0xffffff80,%edx
80108cd0:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cd6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cdd:	83 e2 f0             	and    $0xfffffff0,%edx
80108ce0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ce6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ced:	83 e2 ef             	and    $0xffffffef,%edx
80108cf0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cf6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cfd:	83 e2 df             	and    $0xffffffdf,%edx
80108d00:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d06:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d0d:	83 ca 40             	or     $0x40,%edx
80108d10:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d16:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d1d:	83 e2 7f             	and    $0x7f,%edx
80108d20:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d26:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d32:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d39:	83 e2 ef             	and    $0xffffffef,%edx
80108d3c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108d42:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d48:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108d4e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d54:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d5b:	8b 52 08             	mov    0x8(%edx),%edx
80108d5e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d64:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d67:	83 ec 0c             	sub    $0xc,%esp
80108d6a:	6a 30                	push   $0x30
80108d6c:	e8 f3 f7 ff ff       	call   80108564 <ltr>
80108d71:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d74:	8b 45 08             	mov    0x8(%ebp),%eax
80108d77:	8b 40 04             	mov    0x4(%eax),%eax
80108d7a:	85 c0                	test   %eax,%eax
80108d7c:	75 0d                	jne    80108d8b <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d7e:	83 ec 0c             	sub    $0xc,%esp
80108d81:	68 8b 9a 10 80       	push   $0x80109a8b
80108d86:	e8 db 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8e:	8b 40 04             	mov    0x4(%eax),%eax
80108d91:	83 ec 0c             	sub    $0xc,%esp
80108d94:	50                   	push   %eax
80108d95:	e8 03 f8 ff ff       	call   8010859d <v2p>
80108d9a:	83 c4 10             	add    $0x10,%esp
80108d9d:	83 ec 0c             	sub    $0xc,%esp
80108da0:	50                   	push   %eax
80108da1:	e8 eb f7 ff ff       	call   80108591 <lcr3>
80108da6:	83 c4 10             	add    $0x10,%esp
  popcli();
80108da9:	e8 63 cf ff ff       	call   80105d11 <popcli>
}
80108dae:	90                   	nop
80108daf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108db2:	5b                   	pop    %ebx
80108db3:	5e                   	pop    %esi
80108db4:	5d                   	pop    %ebp
80108db5:	c3                   	ret    

80108db6 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108db6:	55                   	push   %ebp
80108db7:	89 e5                	mov    %esp,%ebp
80108db9:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108dbc:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108dc3:	76 0d                	jbe    80108dd2 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108dc5:	83 ec 0c             	sub    $0xc,%esp
80108dc8:	68 9f 9a 10 80       	push   $0x80109a9f
80108dcd:	e8 94 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108dd2:	e8 86 a6 ff ff       	call   8010345d <kalloc>
80108dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108dda:	83 ec 04             	sub    $0x4,%esp
80108ddd:	68 00 10 00 00       	push   $0x1000
80108de2:	6a 00                	push   $0x0
80108de4:	ff 75 f4             	pushl  -0xc(%ebp)
80108de7:	e8 e6 cf ff ff       	call   80105dd2 <memset>
80108dec:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108def:	83 ec 0c             	sub    $0xc,%esp
80108df2:	ff 75 f4             	pushl  -0xc(%ebp)
80108df5:	e8 a3 f7 ff ff       	call   8010859d <v2p>
80108dfa:	83 c4 10             	add    $0x10,%esp
80108dfd:	83 ec 0c             	sub    $0xc,%esp
80108e00:	6a 06                	push   $0x6
80108e02:	50                   	push   %eax
80108e03:	68 00 10 00 00       	push   $0x1000
80108e08:	6a 00                	push   $0x0
80108e0a:	ff 75 08             	pushl  0x8(%ebp)
80108e0d:	e8 ba fc ff ff       	call   80108acc <mappages>
80108e12:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108e15:	83 ec 04             	sub    $0x4,%esp
80108e18:	ff 75 10             	pushl  0x10(%ebp)
80108e1b:	ff 75 0c             	pushl  0xc(%ebp)
80108e1e:	ff 75 f4             	pushl  -0xc(%ebp)
80108e21:	e8 6b d0 ff ff       	call   80105e91 <memmove>
80108e26:	83 c4 10             	add    $0x10,%esp
}
80108e29:	90                   	nop
80108e2a:	c9                   	leave  
80108e2b:	c3                   	ret    

80108e2c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e2c:	55                   	push   %ebp
80108e2d:	89 e5                	mov    %esp,%ebp
80108e2f:	53                   	push   %ebx
80108e30:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e36:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e3b:	85 c0                	test   %eax,%eax
80108e3d:	74 0d                	je     80108e4c <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108e3f:	83 ec 0c             	sub    $0xc,%esp
80108e42:	68 bc 9a 10 80       	push   $0x80109abc
80108e47:	e8 1a 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e53:	e9 95 00 00 00       	jmp    80108eed <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e58:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e5e:	01 d0                	add    %edx,%eax
80108e60:	83 ec 04             	sub    $0x4,%esp
80108e63:	6a 00                	push   $0x0
80108e65:	50                   	push   %eax
80108e66:	ff 75 08             	pushl  0x8(%ebp)
80108e69:	e8 be fb ff ff       	call   80108a2c <walkpgdir>
80108e6e:	83 c4 10             	add    $0x10,%esp
80108e71:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e78:	75 0d                	jne    80108e87 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e7a:	83 ec 0c             	sub    $0xc,%esp
80108e7d:	68 df 9a 10 80       	push   $0x80109adf
80108e82:	e8 df 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108e87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e8a:	8b 00                	mov    (%eax),%eax
80108e8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e91:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e94:	8b 45 18             	mov    0x18(%ebp),%eax
80108e97:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e9a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e9f:	77 0b                	ja     80108eac <loaduvm+0x80>
      n = sz - i;
80108ea1:	8b 45 18             	mov    0x18(%ebp),%eax
80108ea4:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108ea7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108eaa:	eb 07                	jmp    80108eb3 <loaduvm+0x87>
    else
      n = PGSIZE;
80108eac:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108eb3:	8b 55 14             	mov    0x14(%ebp),%edx
80108eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108ebc:	83 ec 0c             	sub    $0xc,%esp
80108ebf:	ff 75 e8             	pushl  -0x18(%ebp)
80108ec2:	e8 e3 f6 ff ff       	call   801085aa <p2v>
80108ec7:	83 c4 10             	add    $0x10,%esp
80108eca:	ff 75 f0             	pushl  -0x10(%ebp)
80108ecd:	53                   	push   %ebx
80108ece:	50                   	push   %eax
80108ecf:	ff 75 10             	pushl  0x10(%ebp)
80108ed2:	e8 8c 96 ff ff       	call   80102563 <readi>
80108ed7:	83 c4 10             	add    $0x10,%esp
80108eda:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108edd:	74 07                	je     80108ee6 <loaduvm+0xba>
      return -1;
80108edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ee4:	eb 18                	jmp    80108efe <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108ee6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef0:	3b 45 18             	cmp    0x18(%ebp),%eax
80108ef3:	0f 82 5f ff ff ff    	jb     80108e58 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108ef9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108efe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f01:	c9                   	leave  
80108f02:	c3                   	ret    

80108f03 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f03:	55                   	push   %ebp
80108f04:	89 e5                	mov    %esp,%ebp
80108f06:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f09:	8b 45 10             	mov    0x10(%ebp),%eax
80108f0c:	85 c0                	test   %eax,%eax
80108f0e:	79 0a                	jns    80108f1a <allocuvm+0x17>
    return 0;
80108f10:	b8 00 00 00 00       	mov    $0x0,%eax
80108f15:	e9 b0 00 00 00       	jmp    80108fca <allocuvm+0xc7>
  if(newsz < oldsz)
80108f1a:	8b 45 10             	mov    0x10(%ebp),%eax
80108f1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f20:	73 08                	jae    80108f2a <allocuvm+0x27>
    return oldsz;
80108f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f25:	e9 a0 00 00 00       	jmp    80108fca <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f2d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108f3a:	eb 7f                	jmp    80108fbb <allocuvm+0xb8>
    mem = kalloc();
80108f3c:	e8 1c a5 ff ff       	call   8010345d <kalloc>
80108f41:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108f44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f48:	75 2b                	jne    80108f75 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108f4a:	83 ec 0c             	sub    $0xc,%esp
80108f4d:	68 fd 9a 10 80       	push   $0x80109afd
80108f52:	e8 6f 74 ff ff       	call   801003c6 <cprintf>
80108f57:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108f5a:	83 ec 04             	sub    $0x4,%esp
80108f5d:	ff 75 0c             	pushl  0xc(%ebp)
80108f60:	ff 75 10             	pushl  0x10(%ebp)
80108f63:	ff 75 08             	pushl  0x8(%ebp)
80108f66:	e8 61 00 00 00       	call   80108fcc <deallocuvm>
80108f6b:	83 c4 10             	add    $0x10,%esp
      return 0;
80108f6e:	b8 00 00 00 00       	mov    $0x0,%eax
80108f73:	eb 55                	jmp    80108fca <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108f75:	83 ec 04             	sub    $0x4,%esp
80108f78:	68 00 10 00 00       	push   $0x1000
80108f7d:	6a 00                	push   $0x0
80108f7f:	ff 75 f0             	pushl  -0x10(%ebp)
80108f82:	e8 4b ce ff ff       	call   80105dd2 <memset>
80108f87:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108f8a:	83 ec 0c             	sub    $0xc,%esp
80108f8d:	ff 75 f0             	pushl  -0x10(%ebp)
80108f90:	e8 08 f6 ff ff       	call   8010859d <v2p>
80108f95:	83 c4 10             	add    $0x10,%esp
80108f98:	89 c2                	mov    %eax,%edx
80108f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9d:	83 ec 0c             	sub    $0xc,%esp
80108fa0:	6a 06                	push   $0x6
80108fa2:	52                   	push   %edx
80108fa3:	68 00 10 00 00       	push   $0x1000
80108fa8:	50                   	push   %eax
80108fa9:	ff 75 08             	pushl  0x8(%ebp)
80108fac:	e8 1b fb ff ff       	call   80108acc <mappages>
80108fb1:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108fb4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fbe:	3b 45 10             	cmp    0x10(%ebp),%eax
80108fc1:	0f 82 75 ff ff ff    	jb     80108f3c <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108fc7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fca:	c9                   	leave  
80108fcb:	c3                   	ret    

80108fcc <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fcc:	55                   	push   %ebp
80108fcd:	89 e5                	mov    %esp,%ebp
80108fcf:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108fd2:	8b 45 10             	mov    0x10(%ebp),%eax
80108fd5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fd8:	72 08                	jb     80108fe2 <deallocuvm+0x16>
    return oldsz;
80108fda:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fdd:	e9 a5 00 00 00       	jmp    80109087 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108fe2:	8b 45 10             	mov    0x10(%ebp),%eax
80108fe5:	05 ff 0f 00 00       	add    $0xfff,%eax
80108fea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108ff2:	e9 81 00 00 00       	jmp    80109078 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ffa:	83 ec 04             	sub    $0x4,%esp
80108ffd:	6a 00                	push   $0x0
80108fff:	50                   	push   %eax
80109000:	ff 75 08             	pushl  0x8(%ebp)
80109003:	e8 24 fa ff ff       	call   80108a2c <walkpgdir>
80109008:	83 c4 10             	add    $0x10,%esp
8010900b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010900e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109012:	75 09                	jne    8010901d <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109014:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010901b:	eb 54                	jmp    80109071 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010901d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109020:	8b 00                	mov    (%eax),%eax
80109022:	83 e0 01             	and    $0x1,%eax
80109025:	85 c0                	test   %eax,%eax
80109027:	74 48                	je     80109071 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010902c:	8b 00                	mov    (%eax),%eax
8010902e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109033:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109036:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010903a:	75 0d                	jne    80109049 <deallocuvm+0x7d>
        panic("kfree");
8010903c:	83 ec 0c             	sub    $0xc,%esp
8010903f:	68 15 9b 10 80       	push   $0x80109b15
80109044:	e8 1d 75 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109049:	83 ec 0c             	sub    $0xc,%esp
8010904c:	ff 75 ec             	pushl  -0x14(%ebp)
8010904f:	e8 56 f5 ff ff       	call   801085aa <p2v>
80109054:	83 c4 10             	add    $0x10,%esp
80109057:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010905a:	83 ec 0c             	sub    $0xc,%esp
8010905d:	ff 75 e8             	pushl  -0x18(%ebp)
80109060:	e8 5b a3 ff ff       	call   801033c0 <kfree>
80109065:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010906b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109071:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010907b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010907e:	0f 82 73 ff ff ff    	jb     80108ff7 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109084:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109087:	c9                   	leave  
80109088:	c3                   	ret    

80109089 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109089:	55                   	push   %ebp
8010908a:	89 e5                	mov    %esp,%ebp
8010908c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010908f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109093:	75 0d                	jne    801090a2 <freevm+0x19>
    panic("freevm: no pgdir");
80109095:	83 ec 0c             	sub    $0xc,%esp
80109098:	68 1b 9b 10 80       	push   $0x80109b1b
8010909d:	e8 c4 74 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801090a2:	83 ec 04             	sub    $0x4,%esp
801090a5:	6a 00                	push   $0x0
801090a7:	68 00 00 00 80       	push   $0x80000000
801090ac:	ff 75 08             	pushl  0x8(%ebp)
801090af:	e8 18 ff ff ff       	call   80108fcc <deallocuvm>
801090b4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801090b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090be:	eb 4f                	jmp    8010910f <freevm+0x86>
    if(pgdir[i] & PTE_P){
801090c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090ca:	8b 45 08             	mov    0x8(%ebp),%eax
801090cd:	01 d0                	add    %edx,%eax
801090cf:	8b 00                	mov    (%eax),%eax
801090d1:	83 e0 01             	and    $0x1,%eax
801090d4:	85 c0                	test   %eax,%eax
801090d6:	74 33                	je     8010910b <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801090d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090e2:	8b 45 08             	mov    0x8(%ebp),%eax
801090e5:	01 d0                	add    %edx,%eax
801090e7:	8b 00                	mov    (%eax),%eax
801090e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090ee:	83 ec 0c             	sub    $0xc,%esp
801090f1:	50                   	push   %eax
801090f2:	e8 b3 f4 ff ff       	call   801085aa <p2v>
801090f7:	83 c4 10             	add    $0x10,%esp
801090fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801090fd:	83 ec 0c             	sub    $0xc,%esp
80109100:	ff 75 f0             	pushl  -0x10(%ebp)
80109103:	e8 b8 a2 ff ff       	call   801033c0 <kfree>
80109108:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010910b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010910f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109116:	76 a8                	jbe    801090c0 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109118:	83 ec 0c             	sub    $0xc,%esp
8010911b:	ff 75 08             	pushl  0x8(%ebp)
8010911e:	e8 9d a2 ff ff       	call   801033c0 <kfree>
80109123:	83 c4 10             	add    $0x10,%esp
}
80109126:	90                   	nop
80109127:	c9                   	leave  
80109128:	c3                   	ret    

80109129 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109129:	55                   	push   %ebp
8010912a:	89 e5                	mov    %esp,%ebp
8010912c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010912f:	83 ec 04             	sub    $0x4,%esp
80109132:	6a 00                	push   $0x0
80109134:	ff 75 0c             	pushl  0xc(%ebp)
80109137:	ff 75 08             	pushl  0x8(%ebp)
8010913a:	e8 ed f8 ff ff       	call   80108a2c <walkpgdir>
8010913f:	83 c4 10             	add    $0x10,%esp
80109142:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109149:	75 0d                	jne    80109158 <clearpteu+0x2f>
    panic("clearpteu");
8010914b:	83 ec 0c             	sub    $0xc,%esp
8010914e:	68 2c 9b 10 80       	push   $0x80109b2c
80109153:	e8 0e 74 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915b:	8b 00                	mov    (%eax),%eax
8010915d:	83 e0 fb             	and    $0xfffffffb,%eax
80109160:	89 c2                	mov    %eax,%edx
80109162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109165:	89 10                	mov    %edx,(%eax)
}
80109167:	90                   	nop
80109168:	c9                   	leave  
80109169:	c3                   	ret    

8010916a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010916a:	55                   	push   %ebp
8010916b:	89 e5                	mov    %esp,%ebp
8010916d:	53                   	push   %ebx
8010916e:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109171:	e8 e6 f9 ff ff       	call   80108b5c <setupkvm>
80109176:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109179:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010917d:	75 0a                	jne    80109189 <copyuvm+0x1f>
    return 0;
8010917f:	b8 00 00 00 00       	mov    $0x0,%eax
80109184:	e9 f8 00 00 00       	jmp    80109281 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109189:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109190:	e9 c4 00 00 00       	jmp    80109259 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109198:	83 ec 04             	sub    $0x4,%esp
8010919b:	6a 00                	push   $0x0
8010919d:	50                   	push   %eax
8010919e:	ff 75 08             	pushl  0x8(%ebp)
801091a1:	e8 86 f8 ff ff       	call   80108a2c <walkpgdir>
801091a6:	83 c4 10             	add    $0x10,%esp
801091a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801091ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801091b0:	75 0d                	jne    801091bf <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801091b2:	83 ec 0c             	sub    $0xc,%esp
801091b5:	68 36 9b 10 80       	push   $0x80109b36
801091ba:	e8 a7 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801091bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091c2:	8b 00                	mov    (%eax),%eax
801091c4:	83 e0 01             	and    $0x1,%eax
801091c7:	85 c0                	test   %eax,%eax
801091c9:	75 0d                	jne    801091d8 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801091cb:	83 ec 0c             	sub    $0xc,%esp
801091ce:	68 50 9b 10 80       	push   $0x80109b50
801091d3:	e8 8e 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801091d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091db:	8b 00                	mov    (%eax),%eax
801091dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801091e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091e8:	8b 00                	mov    (%eax),%eax
801091ea:	25 ff 0f 00 00       	and    $0xfff,%eax
801091ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801091f2:	e8 66 a2 ff ff       	call   8010345d <kalloc>
801091f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801091fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801091fe:	74 6a                	je     8010926a <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109200:	83 ec 0c             	sub    $0xc,%esp
80109203:	ff 75 e8             	pushl  -0x18(%ebp)
80109206:	e8 9f f3 ff ff       	call   801085aa <p2v>
8010920b:	83 c4 10             	add    $0x10,%esp
8010920e:	83 ec 04             	sub    $0x4,%esp
80109211:	68 00 10 00 00       	push   $0x1000
80109216:	50                   	push   %eax
80109217:	ff 75 e0             	pushl  -0x20(%ebp)
8010921a:	e8 72 cc ff ff       	call   80105e91 <memmove>
8010921f:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109222:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109225:	83 ec 0c             	sub    $0xc,%esp
80109228:	ff 75 e0             	pushl  -0x20(%ebp)
8010922b:	e8 6d f3 ff ff       	call   8010859d <v2p>
80109230:	83 c4 10             	add    $0x10,%esp
80109233:	89 c2                	mov    %eax,%edx
80109235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109238:	83 ec 0c             	sub    $0xc,%esp
8010923b:	53                   	push   %ebx
8010923c:	52                   	push   %edx
8010923d:	68 00 10 00 00       	push   $0x1000
80109242:	50                   	push   %eax
80109243:	ff 75 f0             	pushl  -0x10(%ebp)
80109246:	e8 81 f8 ff ff       	call   80108acc <mappages>
8010924b:	83 c4 20             	add    $0x20,%esp
8010924e:	85 c0                	test   %eax,%eax
80109250:	78 1b                	js     8010926d <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109252:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010925f:	0f 82 30 ff ff ff    	jb     80109195 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109268:	eb 17                	jmp    80109281 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010926a:	90                   	nop
8010926b:	eb 01                	jmp    8010926e <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010926d:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010926e:	83 ec 0c             	sub    $0xc,%esp
80109271:	ff 75 f0             	pushl  -0x10(%ebp)
80109274:	e8 10 fe ff ff       	call   80109089 <freevm>
80109279:	83 c4 10             	add    $0x10,%esp
  return 0;
8010927c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109284:	c9                   	leave  
80109285:	c3                   	ret    

80109286 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109286:	55                   	push   %ebp
80109287:	89 e5                	mov    %esp,%ebp
80109289:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010928c:	83 ec 04             	sub    $0x4,%esp
8010928f:	6a 00                	push   $0x0
80109291:	ff 75 0c             	pushl  0xc(%ebp)
80109294:	ff 75 08             	pushl  0x8(%ebp)
80109297:	e8 90 f7 ff ff       	call   80108a2c <walkpgdir>
8010929c:	83 c4 10             	add    $0x10,%esp
8010929f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801092a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092a5:	8b 00                	mov    (%eax),%eax
801092a7:	83 e0 01             	and    $0x1,%eax
801092aa:	85 c0                	test   %eax,%eax
801092ac:	75 07                	jne    801092b5 <uva2ka+0x2f>
    return 0;
801092ae:	b8 00 00 00 00       	mov    $0x0,%eax
801092b3:	eb 29                	jmp    801092de <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801092b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b8:	8b 00                	mov    (%eax),%eax
801092ba:	83 e0 04             	and    $0x4,%eax
801092bd:	85 c0                	test   %eax,%eax
801092bf:	75 07                	jne    801092c8 <uva2ka+0x42>
    return 0;
801092c1:	b8 00 00 00 00       	mov    $0x0,%eax
801092c6:	eb 16                	jmp    801092de <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801092c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cb:	8b 00                	mov    (%eax),%eax
801092cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092d2:	83 ec 0c             	sub    $0xc,%esp
801092d5:	50                   	push   %eax
801092d6:	e8 cf f2 ff ff       	call   801085aa <p2v>
801092db:	83 c4 10             	add    $0x10,%esp
}
801092de:	c9                   	leave  
801092df:	c3                   	ret    

801092e0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801092e0:	55                   	push   %ebp
801092e1:	89 e5                	mov    %esp,%ebp
801092e3:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801092e6:	8b 45 10             	mov    0x10(%ebp),%eax
801092e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801092ec:	eb 7f                	jmp    8010936d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801092ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801092f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801092f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092fc:	83 ec 08             	sub    $0x8,%esp
801092ff:	50                   	push   %eax
80109300:	ff 75 08             	pushl  0x8(%ebp)
80109303:	e8 7e ff ff ff       	call   80109286 <uva2ka>
80109308:	83 c4 10             	add    $0x10,%esp
8010930b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010930e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109312:	75 07                	jne    8010931b <copyout+0x3b>
      return -1;
80109314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109319:	eb 61                	jmp    8010937c <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010931b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010931e:	2b 45 0c             	sub    0xc(%ebp),%eax
80109321:	05 00 10 00 00       	add    $0x1000,%eax
80109326:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010932f:	76 06                	jbe    80109337 <copyout+0x57>
      n = len;
80109331:	8b 45 14             	mov    0x14(%ebp),%eax
80109334:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010933a:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010933d:	89 c2                	mov    %eax,%edx
8010933f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109342:	01 d0                	add    %edx,%eax
80109344:	83 ec 04             	sub    $0x4,%esp
80109347:	ff 75 f0             	pushl  -0x10(%ebp)
8010934a:	ff 75 f4             	pushl  -0xc(%ebp)
8010934d:	50                   	push   %eax
8010934e:	e8 3e cb ff ff       	call   80105e91 <memmove>
80109353:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109356:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109359:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010935c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010935f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109362:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109365:	05 00 10 00 00       	add    $0x1000,%eax
8010936a:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010936d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109371:	0f 85 77 ff ff ff    	jne    801092ee <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109377:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010937c:	c9                   	leave  
8010937d:	c3                   	ret    
