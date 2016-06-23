
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
8010002d:	b8 c4 43 10 80       	mov    $0x801043c4,%eax
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
8010003d:	68 dc 93 10 80       	push   $0x801093dc
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 f9 5a 00 00       	call   80105b45 <initlock>
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
801000c1:	e8 a1 5a 00 00       	call   80105b67 <acquire>
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
8010010c:	e8 bd 5a 00 00       	call   80105bce <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 42 57 00 00       	call   8010586e <sleep>
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
80100188:	e8 41 5a 00 00       	call   80105bce <release>
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
801001aa:	68 e3 93 10 80       	push   $0x801093e3
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
801001e2:	e8 2b 2f 00 00       	call   80103112 <iderw>
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
80100204:	68 f4 93 10 80       	push   $0x801093f4
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
80100223:	e8 ea 2e 00 00       	call   80103112 <iderw>
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
80100243:	68 fb 93 10 80       	push   $0x801093fb
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 0d 59 00 00       	call   80105b67 <acquire>
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
801002b9:	e8 9b 56 00 00       	call   80105959 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 00 59 00 00       	call   80105bce <release>
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
801003e2:	e8 80 57 00 00       	call   80105b67 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 02 94 10 80       	push   $0x80109402
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
801004cd:	c7 45 ec 0b 94 10 80 	movl   $0x8010940b,-0x14(%ebp)
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
8010055b:	e8 6e 56 00 00       	call   80105bce <release>
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
8010058b:	68 12 94 10 80       	push   $0x80109412
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
801005aa:	68 21 94 10 80       	push   $0x80109421
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 59 56 00 00       	call   80105c20 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 23 94 10 80       	push   $0x80109423
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
801006ca:	68 27 94 10 80       	push   $0x80109427
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
801006f7:	e8 8d 57 00 00       	call   80105e89 <memmove>
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
80100721:	e8 a4 56 00 00       	call   80105dca <memset>
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
801007b6:	e8 aa 72 00 00       	call   80107a65 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 9d 72 00 00       	call   80107a65 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 90 72 00 00       	call   80107a65 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 80 72 00 00       	call   80107a65 <uartputc>
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
8010080e:	e8 54 53 00 00       	call   80105b67 <acquire>
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
80100956:	e8 fe 4f 00 00       	call   80105959 <wakeup>
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
80100979:	e8 50 52 00 00       	call   80105bce <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 88 50 00 00       	call   80105a14 <procdump>
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
8010099b:	e8 e3 16 00 00       	call   80102083 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 b1 51 00 00       	call   80105b67 <acquire>
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
801009d3:	e8 f6 51 00 00       	call   80105bce <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        //cprintf("cRead \n");
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 fc 14 00 00       	call   80101ee2 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 e0 18 11 80       	push   $0x801118e0
80100a00:	e8 69 4e 00 00       	call   8010586e <sleep>
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
80100a7e:	e8 4b 51 00 00       	call   80105bce <release>
80100a83:	83 c4 10             	add    $0x10,%esp
          //    cprintf("cRead2 \n");

  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 51 14 00 00       	call   80101ee2 <ilock>
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
80100aac:	e8 d2 15 00 00       	call   80102083 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 a6 50 00 00       	call   80105b67 <acquire>
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
80100afe:	e8 cb 50 00 00       	call   80105bce <release>
80100b03:	83 c4 10             	add    $0x10,%esp
        //  cprintf("cWrite \n");

  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 d1 13 00 00       	call   80101ee2 <ilock>
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
80100b22:	68 3a 94 10 80       	push   $0x8010943a
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 14 50 00 00       	call   80105b45 <initlock>
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
80100b57:	e8 e7 3e 00 00       	call   80104a43 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 74 27 00 00       	call   801032df <ioapicenable>
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
80100b8d:	e8 f7 32 00 00       	call   80103e89 <begin_op>
80100b92:	83 c4 10             	add    $0x10,%esp
  if((ip = namei(path)) == 0){
80100b95:	83 ec 0c             	sub    $0xc,%esp
80100b98:	ff 75 08             	pushl  0x8(%ebp)
80100b9b:	e8 64 21 00 00       	call   80102d04 <namei>
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
80100bbf:	e8 cc 33 00 00       	call   80103f90 <end_op>
80100bc4:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bcc:	e9 fa 03 00 00       	jmp    80100fcb <exec+0x45a>
  }
           // cprintf("exec \n");

  ilock(ip);
80100bd1:	83 ec 0c             	sub    $0xc,%esp
80100bd4:	ff 75 d8             	pushl  -0x28(%ebp)
80100bd7:	e8 06 13 00 00       	call   80101ee2 <ilock>
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
80100bf4:	e8 77 19 00 00       	call   80102570 <readi>
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
80100c16:	e8 9f 7f 00 00       	call   80108bba <setupkvm>
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
80100c54:	e8 17 19 00 00       	call   80102570 <readi>
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
80100c9c:	e8 c0 82 00 00       	call   80108f61 <allocuvm>
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
80100ccf:	e8 b6 81 00 00       	call   80108e8a <loaduvm>
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
80100d08:	e8 d8 14 00 00       	call   801021e5 <iunlockput>
80100d0d:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
80100d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d16:	8b 40 68             	mov    0x68(%eax),%eax
80100d19:	8b 40 50             	mov    0x50(%eax),%eax
80100d1c:	8b 40 14             	mov    0x14(%eax),%eax
80100d1f:	83 ec 0c             	sub    $0xc,%esp
80100d22:	50                   	push   %eax
80100d23:	e8 68 32 00 00       	call   80103f90 <end_op>
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
80100d54:	e8 08 82 00 00       	call   80108f61 <allocuvm>
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
80100d78:	e8 0a 84 00 00       	call   80109187 <clearpteu>
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
80100db1:	e8 61 52 00 00       	call   80106017 <strlen>
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
80100dde:	e8 34 52 00 00       	call   80106017 <strlen>
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
80100e04:	e8 35 85 00 00       	call   8010933e <copyout>
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
80100ea0:	e8 99 84 00 00       	call   8010933e <copyout>
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
80100ef1:	e8 d7 50 00 00       	call   80105fcd <safestrcpy>
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
80100f47:	e8 55 7d 00 00       	call   80108ca1 <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 8d 81 00 00       	call   801090e7 <freevm>
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
80100f8f:	e8 53 81 00 00       	call   801090e7 <freevm>
80100f94:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f97:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f9b:	74 29                	je     80100fc6 <exec+0x455>
    iunlockput(ip);
80100f9d:	83 ec 0c             	sub    $0xc,%esp
80100fa0:	ff 75 d8             	pushl  -0x28(%ebp)
80100fa3:	e8 3d 12 00 00       	call   801021e5 <iunlockput>
80100fa8:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80100fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fb1:	8b 40 68             	mov    0x68(%eax),%eax
80100fb4:	8b 40 50             	mov    0x50(%eax),%eax
80100fb7:	8b 40 14             	mov    0x14(%eax),%eax
80100fba:	83 ec 0c             	sub    $0xc,%esp
80100fbd:	50                   	push   %eax
80100fbe:	e8 cd 2f 00 00       	call   80103f90 <end_op>
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
80100fd6:	68 42 94 10 80       	push   $0x80109442
80100fdb:	68 00 19 11 80       	push   $0x80111900
80100fe0:	e8 60 4b 00 00       	call   80105b45 <initlock>
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
80100ff9:	e8 69 4b 00 00       	call   80105b67 <acquire>
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
80101026:	e8 a3 4b 00 00       	call   80105bce <release>
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
80101049:	e8 80 4b 00 00       	call   80105bce <release>
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
80101066:	e8 fc 4a 00 00       	call   80105b67 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 49 94 10 80       	push   $0x80109449
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
8010109c:	e8 2d 4b 00 00       	call   80105bce <release>
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
801010b7:	e8 ab 4a 00 00       	call   80105b67 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 51 94 10 80       	push   $0x80109451
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
801010f7:	e8 d2 4a 00 00       	call   80105bce <release>
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
80101147:	e8 82 4a 00 00       	call   80105bce <release>
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
80101166:	e8 41 3b 00 00       	call   80104cac <pipeclose>
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
80101188:	e8 fc 2c 00 00       	call   80103e89 <begin_op>
8010118d:	83 c4 10             	add    $0x10,%esp
    iput(ff.ip);
80101190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101193:	83 ec 0c             	sub    $0xc,%esp
80101196:	50                   	push   %eax
80101197:	e8 59 0f 00 00       	call   801020f5 <iput>
8010119c:	83 c4 10             	add    $0x10,%esp
    end_op(f->ip->part->number);
8010119f:	8b 45 08             	mov    0x8(%ebp),%eax
801011a2:	8b 40 0e             	mov    0xe(%eax),%eax
801011a5:	8b 40 50             	mov    0x50(%eax),%eax
801011a8:	8b 40 14             	mov    0x14(%eax),%eax
801011ab:	83 ec 0c             	sub    $0xc,%esp
801011ae:	50                   	push   %eax
801011af:	e8 dc 2d 00 00       	call   80103f90 <end_op>
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
801011d3:	e8 0a 0d 00 00       	call   80101ee2 <ilock>
801011d8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 40 0e             	mov    0xe(%eax),%eax
801011e1:	83 ec 08             	sub    $0x8,%esp
801011e4:	ff 75 0c             	pushl  0xc(%ebp)
801011e7:	50                   	push   %eax
801011e8:	e8 3d 13 00 00       	call   8010252a <stati>
801011ed:	83 c4 10             	add    $0x10,%esp
   // cprintf("filestat \n");

    iunlock(f->ip);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0e             	mov    0xe(%eax),%eax
801011f6:	83 ec 0c             	sub    $0xc,%esp
801011f9:	50                   	push   %eax
801011fa:	e8 84 0e 00 00       	call   80102083 <iunlock>
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
80101245:	e8 0a 3c 00 00       	call   80104e54 <piperead>
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
80101263:	e8 7a 0c 00 00       	call   80101ee2 <ilock>
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
80101280:	e8 eb 12 00 00       	call   80102570 <readi>
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
801012ac:	e8 d2 0d 00 00       	call   80102083 <iunlock>
801012b1:	83 c4 10             	add    $0x10,%esp
    return r;
801012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b7:	eb 0d                	jmp    801012c6 <fileread+0xb6>
  }
  panic("fileread");
801012b9:	83 ec 0c             	sub    $0xc,%esp
801012bc:	68 5b 94 10 80       	push   $0x8010945b
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
801012fe:	e8 53 3a 00 00       	call   80104d56 <pipewrite>
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
80101353:	e8 31 2b 00 00       	call   80103e89 <begin_op>
80101358:	83 c4 10             	add    $0x10,%esp
      ilock(f->ip);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 40 0e             	mov    0xe(%eax),%eax
80101361:	83 ec 0c             	sub    $0xc,%esp
80101364:	50                   	push   %eax
80101365:	e8 78 0b 00 00       	call   80101ee2 <ilock>
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
80101388:	e8 83 13 00 00       	call   80102710 <writei>
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
801013b4:	e8 ca 0c 00 00       	call   80102083 <iunlock>
801013b9:	83 c4 10             	add    $0x10,%esp
      end_op(f->ip->part->number);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	8b 40 0e             	mov    0xe(%eax),%eax
801013c2:	8b 40 50             	mov    0x50(%eax),%eax
801013c5:	8b 40 14             	mov    0x14(%eax),%eax
801013c8:	83 ec 0c             	sub    $0xc,%esp
801013cb:	50                   	push   %eax
801013cc:	e8 bf 2b 00 00       	call   80103f90 <end_op>
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
801013e5:	68 64 94 10 80       	push   $0x80109464
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
8010141b:	68 74 94 10 80       	push   $0x80109474
80101420:	e8 41 f1 ff ff       	call   80100566 <panic>
}
80101425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101428:	c9                   	leave  
80101429:	c3                   	ret    

8010142a <readsb>:
int bootfrom = -1;
struct file* fstabFd;

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
8010146c:	e8 18 4a 00 00       	call   80105e89 <memmove>
80101471:	83 c4 10             	add    $0x10,%esp
    sbs[partitionNumber].offset = mbrI.partitions[partitionNumber].offset;
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
801014d3:	e8 b1 49 00 00       	call   80105e89 <memmove>
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
static void bzero(int dev, int bno, uint partitionNumber)
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
80101519:	e8 ac 48 00 00       	call   80105dca <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp, partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 07 2d 00 00       	call   80104236 <log_write>
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
                log_write(bp, partitionNumber);
80101635:	8b 45 0c             	mov    0xc(%ebp),%eax
80101638:	83 ec 08             	sub    $0x8,%esp
8010163b:	50                   	push   %eax
8010163c:	ff 75 ec             	pushl  -0x14(%ebp)
8010163f:	e8 f2 2b 00 00       	call   80104236 <log_write>
80101644:	83 c4 10             	add    $0x10,%esp
                brelse(bp);
80101647:	83 ec 0c             	sub    $0xc,%esp
8010164a:	ff 75 ec             	pushl  -0x14(%ebp)
8010164d:	e8 dc eb ff ff       	call   8010022e <brelse>
80101652:	83 c4 10             	add    $0x10,%esp
                bzero(dev, sb.offset + b + bi, partitionNumber);
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
                bzero(dev, sb.offset + b + bi, partitionNumber);
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
801016ca:	68 80 94 10 80       	push   $0x80109480
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
80101787:	68 96 94 10 80       	push   $0x80109496
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
    log_write(bp, partitionNumber);
801017b9:	8b 45 10             	mov    0x10(%ebp),%eax
801017bc:	83 ec 08             	sub    $0x8,%esp
801017bf:	50                   	push   %eax
801017c0:	ff 75 f4             	pushl  -0xc(%ebp)
801017c3:	e8 6e 2a 00 00       	call   80104236 <log_write>
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
    static char* FS_TYPE[] = {[FS_INODE] "INODE", [FS_FAT] "FAT" };

    int i;
    char* bootable;
    char* type;
    cprintf("MBR Dump \n");
801017e2:	83 ec 0c             	sub    $0xc,%esp
801017e5:	68 a9 94 10 80       	push   $0x801094a9
801017ea:	e8 d7 eb ff ff       	call   801003c6 <cprintf>
801017ef:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPARTITIONS; i++) {
801017f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801017f9:	e9 f5 00 00 00       	jmp    801018f3 <printMBR+0x117>
        if (m->partitions[i].flags > 1 && m->partitions[i].flags < 4) {
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
8010182a:	c7 45 f0 b4 94 10 80 	movl   $0x801094b4,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 b8 94 10 80 	movl   $0x801094b8,-0x10(%ebp)
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
80101861:	8b 04 85 1c a0 10 80 	mov    -0x7fef5fe4(,%eax,4),%eax
80101868:	85 c0                	test   %eax,%eax
8010186a:	74 1d                	je     80101889 <printMBR+0xad>
            type = FS_TYPE[m->partitions[i].type];
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101872:	83 c2 1b             	add    $0x1b,%edx
80101875:	c1 e2 04             	shl    $0x4,%edx
80101878:	01 d0                	add    %edx,%eax
8010187a:	8b 40 12             	mov    0x12(%eax),%eax
8010187d:	8b 04 85 1c a0 10 80 	mov    -0x7fef5fe4(,%eax,4),%eax
80101884:	89 45 ec             	mov    %eax,-0x14(%ebp)
80101887:	eb 29                	jmp    801018b2 <printMBR+0xd6>

        } else {
            type = "???";
80101889:	c7 45 ec bb 94 10 80 	movl   $0x801094bb,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 bf 94 10 80       	push   $0x801094bf
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
801018e2:	68 d4 94 10 80       	push   $0x801094d4
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
80101909:	68 0a 95 10 80       	push   $0x8010950a
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
80101934:	e9 ec 00 00 00       	jmp    80101a25 <initMbr+0x10c>
        if (mbrI.partitions[i].flags >= PART_BOOTABLE && bootfrom == -1) {
80101939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193c:	83 c0 1b             	add    $0x1b,%eax
8010193f:	c1 e0 04             	shl    $0x4,%eax
80101942:	05 60 22 11 80       	add    $0x80112260,%eax
80101947:	8b 40 0e             	mov    0xe(%eax),%eax
8010194a:	83 f8 01             	cmp    $0x1,%eax
8010194d:	76 12                	jbe    80101961 <initMbr+0x48>
8010194f:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101954:	83 f8 ff             	cmp    $0xffffffff,%eax
80101957:	75 08                	jne    80101961 <initMbr+0x48>
            bootfrom = i;
80101959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195c:	a3 18 a0 10 80       	mov    %eax,0x8010a018
        }
        partitions[i].dev = dev;
80101961:	8b 4d 08             	mov    0x8(%ebp),%ecx
80101964:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101967:	89 d0                	mov    %edx,%eax
80101969:	01 c0                	add    %eax,%eax
8010196b:	01 d0                	add    %edx,%eax
8010196d:	c1 e0 03             	shl    $0x3,%eax
80101970:	05 00 18 11 80       	add    $0x80111800,%eax
80101975:	89 08                	mov    %ecx,(%eax)
        partitions[i].flags = mbrI.partitions[i].flags;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	83 c0 1b             	add    $0x1b,%eax
8010197d:	c1 e0 04             	shl    $0x4,%eax
80101980:	05 60 22 11 80       	add    $0x80112260,%eax
80101985:	8b 48 0e             	mov    0xe(%eax),%ecx
80101988:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010198b:	89 d0                	mov    %edx,%eax
8010198d:	01 c0                	add    %eax,%eax
8010198f:	01 d0                	add    %edx,%eax
80101991:	c1 e0 03             	shl    $0x3,%eax
80101994:	05 00 18 11 80       	add    $0x80111800,%eax
80101999:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].type = mbrI.partitions[i].type;
8010199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199f:	83 c0 1b             	add    $0x1b,%eax
801019a2:	c1 e0 04             	shl    $0x4,%eax
801019a5:	05 60 22 11 80       	add    $0x80112260,%eax
801019aa:	8b 48 12             	mov    0x12(%eax),%ecx
801019ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019b0:	89 d0                	mov    %edx,%eax
801019b2:	01 c0                	add    %eax,%eax
801019b4:	01 d0                	add    %edx,%eax
801019b6:	c1 e0 03             	shl    $0x3,%eax
801019b9:	05 00 18 11 80       	add    $0x80111800,%eax
801019be:	89 48 08             	mov    %ecx,0x8(%eax)
        partitions[i].number = i;
801019c1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801019c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019c7:	89 d0                	mov    %edx,%eax
801019c9:	01 c0                	add    %eax,%eax
801019cb:	01 d0                	add    %edx,%eax
801019cd:	c1 e0 03             	shl    $0x3,%eax
801019d0:	05 10 18 11 80       	add    $0x80111810,%eax
801019d5:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].offset = mbrI.partitions[i].offset;
801019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019db:	83 c0 1b             	add    $0x1b,%eax
801019de:	c1 e0 04             	shl    $0x4,%eax
801019e1:	05 60 22 11 80       	add    $0x80112260,%eax
801019e6:	8b 48 16             	mov    0x16(%eax),%ecx
801019e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019ec:	89 d0                	mov    %edx,%eax
801019ee:	01 c0                	add    %eax,%eax
801019f0:	01 d0                	add    %edx,%eax
801019f2:	c1 e0 03             	shl    $0x3,%eax
801019f5:	05 00 18 11 80       	add    $0x80111800,%eax
801019fa:	89 48 0c             	mov    %ecx,0xc(%eax)
        partitions[i].size = mbrI.partitions[i].size;
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	83 c0 1b             	add    $0x1b,%eax
80101a03:	c1 e0 04             	shl    $0x4,%eax
80101a06:	05 60 22 11 80       	add    $0x80112260,%eax
80101a0b:	8b 48 1a             	mov    0x1a(%eax),%ecx
80101a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a11:	89 d0                	mov    %edx,%eax
80101a13:	01 c0                	add    %eax,%eax
80101a15:	01 d0                	add    %edx,%eax
80101a17:	c1 e0 03             	shl    $0x3,%eax
80101a1a:	05 10 18 11 80       	add    $0x80111810,%eax
80101a1f:	89 08                	mov    %ecx,(%eax)
{

    readmbr(dev);
    int i;

    for (i = 0; i < NPARTITIONS; i++) {
80101a21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a25:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80101a29:	0f 8e 0a ff ff ff    	jle    80101939 <initMbr+0x20>
        partitions[i].type = mbrI.partitions[i].type;
        partitions[i].number = i;
        partitions[i].offset = mbrI.partitions[i].offset;
        partitions[i].size = mbrI.partitions[i].size;
    }
}
80101a2f:	90                   	nop
80101a30:	c9                   	leave  
80101a31:	c3                   	ret    

80101a32 <iinit>:

int iinit(struct proc* p, int dev)
{
80101a32:	55                   	push   %ebp
80101a33:	89 e5                	mov    %esp,%ebp
80101a35:	57                   	push   %edi
80101a36:	56                   	push   %esi
80101a37:	53                   	push   %ebx
80101a38:	83 ec 4c             	sub    $0x4c,%esp
    struct inode* rootNode;
    struct superblock sb;
    // TODO: change ot iterate over all partitions

    initlock(&icache.lock, "icache");
80101a3b:	83 ec 08             	sub    $0x8,%esp
80101a3e:	68 15 95 10 80       	push   $0x80109515
80101a43:	68 60 24 11 80       	push   $0x80112460
80101a48:	e8 f8 40 00 00       	call   80105b45 <initlock>
80101a4d:	83 c4 10             	add    $0x10,%esp

    rootNode = p->cwd;
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	8b 40 68             	mov    0x68(%eax),%eax
80101a56:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // acquire(&icache.lock);

    initMbr(dev);
80101a59:	83 ec 0c             	sub    $0xc,%esp
80101a5c:	ff 75 0c             	pushl  0xc(%ebp)
80101a5f:	e8 b5 fe ff ff       	call   80101919 <initMbr>
80101a64:	83 c4 10             	add    $0x10,%esp
    printMBR(&mbrI);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 60 22 11 80       	push   $0x80112260
80101a6f:	e8 68 fd ff ff       	call   801017dc <printMBR>
80101a74:	83 c4 10             	add    $0x10,%esp
    cprintf("booting from %d \n", bootfrom);
80101a77:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a7c:	83 ec 08             	sub    $0x8,%esp
80101a7f:	50                   	push   %eax
80101a80:	68 1c 95 10 80       	push   $0x8010951c
80101a85:	e8 3c e9 ff ff       	call   801003c6 <cprintf>
80101a8a:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a8d:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a92:	83 f8 ff             	cmp    $0xffffffff,%eax
80101a95:	75 0d                	jne    80101aa4 <iinit+0x72>
        panic("no bootable partition");
80101a97:	83 ec 0c             	sub    $0xc,%esp
80101a9a:	68 2e 95 10 80       	push   $0x8010952e
80101a9f:	e8 c2 ea ff ff       	call   80100566 <panic>
    }
    rootNode->part = &(partitions[bootfrom]);
80101aa4:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
80101aaa:	89 d0                	mov    %edx,%eax
80101aac:	01 c0                	add    %eax,%eax
80101aae:	01 d0                	add    %edx,%eax
80101ab0:	c1 e0 03             	shl    $0x3,%eax
80101ab3:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101ab9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101abc:	89 50 50             	mov    %edx,0x50(%eax)
    int i;
    for (i = 0; i < NPARTITIONS; i++) {
80101abf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101ac6:	e9 89 00 00 00       	jmp    80101b54 <iinit+0x122>
        readsb(dev, i);
80101acb:	83 ec 08             	sub    $0x8,%esp
80101ace:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ad1:	ff 75 0c             	pushl  0xc(%ebp)
80101ad4:	e8 51 f9 ff ff       	call   8010142a <readsb>
80101ad9:	83 c4 10             	add    $0x10,%esp
        sb = sbs[i];
80101adc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101adf:	c1 e0 05             	shl    $0x5,%eax
80101ae2:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101ae7:	8b 10                	mov    (%eax),%edx
80101ae9:	89 55 c0             	mov    %edx,-0x40(%ebp)
80101aec:	8b 50 04             	mov    0x4(%eax),%edx
80101aef:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80101af2:	8b 50 08             	mov    0x8(%eax),%edx
80101af5:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101af8:	8b 50 0c             	mov    0xc(%eax),%edx
80101afb:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101afe:	8b 50 10             	mov    0x10(%eax),%edx
80101b01:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b04:	8b 50 14             	mov    0x14(%eax),%edx
80101b07:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101b0a:	8b 50 18             	mov    0x18(%eax),%edx
80101b0d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101b10:	8b 40 1c             	mov    0x1c(%eax),%eax
80101b13:	89 45 dc             	mov    %eax,-0x24(%ebp)
        cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
80101b16:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101b19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101b1c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80101b1f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80101b22:	89 4d b0             	mov    %ecx,-0x50(%ebp)
80101b25:	8b 7d cc             	mov    -0x34(%ebp),%edi
80101b28:	8b 75 c8             	mov    -0x38(%ebp),%esi
80101b2b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
80101b2e:	8b 4d c0             	mov    -0x40(%ebp),%ecx
80101b31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101b34:	83 ec 0c             	sub    $0xc,%esp
80101b37:	52                   	push   %edx
80101b38:	ff 75 b4             	pushl  -0x4c(%ebp)
80101b3b:	ff 75 b0             	pushl  -0x50(%ebp)
80101b3e:	57                   	push   %edi
80101b3f:	56                   	push   %esi
80101b40:	53                   	push   %ebx
80101b41:	51                   	push   %ecx
80101b42:	50                   	push   %eax
80101b43:	68 44 95 10 80       	push   $0x80109544
80101b48:	e8 79 e8 ff ff       	call   801003c6 <cprintf>
80101b4d:	83 c4 30             	add    $0x30,%esp
    if (bootfrom == -1) {
        panic("no bootable partition");
    }
    rootNode->part = &(partitions[bootfrom]);
    int i;
    for (i = 0; i < NPARTITIONS; i++) {
80101b50:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101b54:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80101b58:	0f 8e 6d ff ff ff    	jle    80101acb <iinit+0x99>

    // release(&icache.lock);

    // cprintf("root node init %d \n",rootNode->part->offset);

    return bootfrom;
80101b5e:	a1 18 a0 10 80       	mov    0x8010a018,%eax
}
80101b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b66:	5b                   	pop    %ebx
80101b67:	5e                   	pop    %esi
80101b68:	5f                   	pop    %edi
80101b69:	5d                   	pop    %ebp
80101b6a:	c3                   	ret    

80101b6b <ialloc>:

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
80101b6b:	55                   	push   %ebp
80101b6c:	89 e5                	mov    %esp,%ebp
80101b6e:	83 ec 48             	sub    $0x48,%esp
80101b71:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b74:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    // cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
80101b78:	8b 45 10             	mov    0x10(%ebp),%eax
80101b7b:	c1 e0 05             	shl    $0x5,%eax
80101b7e:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101b83:	8b 10                	mov    (%eax),%edx
80101b85:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101b88:	8b 50 04             	mov    0x4(%eax),%edx
80101b8b:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b8e:	8b 50 08             	mov    0x8(%eax),%edx
80101b91:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101b94:	8b 50 0c             	mov    0xc(%eax),%edx
80101b97:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101b9a:	8b 50 10             	mov    0x10(%eax),%edx
80101b9d:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ba0:	8b 50 14             	mov    0x14(%eax),%edx
80101ba3:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ba6:	8b 50 18             	mov    0x18(%eax),%edx
80101ba9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101bac:	8b 40 1c             	mov    0x1c(%eax),%eax
80101baf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101bb2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101bb9:	e9 a9 00 00 00       	jmp    80101c67 <ialloc+0xfc>
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
80101bbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101bc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bc4:	89 d1                	mov    %edx,%ecx
80101bc6:	c1 e9 03             	shr    $0x3,%ecx
80101bc9:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101bcc:	01 ca                	add    %ecx,%edx
80101bce:	01 d0                	add    %edx,%eax
80101bd0:	83 ec 08             	sub    $0x8,%esp
80101bd3:	50                   	push   %eax
80101bd4:	ff 75 08             	pushl  0x8(%ebp)
80101bd7:	e8 da e5 ff ff       	call   801001b6 <bread>
80101bdc:	83 c4 10             	add    $0x10,%esp
80101bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
        dip = (struct dinode*)bp->data + inum % IPB;
80101be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be5:	8d 50 18             	lea    0x18(%eax),%edx
80101be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101beb:	83 e0 07             	and    $0x7,%eax
80101bee:	c1 e0 06             	shl    $0x6,%eax
80101bf1:	01 d0                	add    %edx,%eax
80101bf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (dip->type == 0) { // a free inode
80101bf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bf9:	0f b7 00             	movzwl (%eax),%eax
80101bfc:	66 85 c0             	test   %ax,%ax
80101bff:	75 54                	jne    80101c55 <ialloc+0xea>
            memset(dip, 0, sizeof(*dip));
80101c01:	83 ec 04             	sub    $0x4,%esp
80101c04:	6a 40                	push   $0x40
80101c06:	6a 00                	push   $0x0
80101c08:	ff 75 ec             	pushl  -0x14(%ebp)
80101c0b:	e8 ba 41 00 00       	call   80105dca <memset>
80101c10:	83 c4 10             	add    $0x10,%esp
            dip->type = type;
80101c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c16:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
80101c1a:	66 89 10             	mov    %dx,(%eax)
            log_write(bp, partitionNumber); // mark it allocated on the disk
80101c1d:	8b 45 10             	mov    0x10(%ebp),%eax
80101c20:	83 ec 08             	sub    $0x8,%esp
80101c23:	50                   	push   %eax
80101c24:	ff 75 f0             	pushl  -0x10(%ebp)
80101c27:	e8 0a 26 00 00       	call   80104236 <log_write>
80101c2c:	83 c4 10             	add    $0x10,%esp
            brelse(bp);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 f0             	pushl  -0x10(%ebp)
80101c35:	e8 f4 e5 ff ff       	call   8010022e <brelse>
80101c3a:	83 c4 10             	add    $0x10,%esp
            return iget(dev, inum, partitionNumber);
80101c3d:	8b 55 10             	mov    0x10(%ebp),%edx
80101c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c43:	83 ec 04             	sub    $0x4,%esp
80101c46:	52                   	push   %edx
80101c47:	50                   	push   %eax
80101c48:	ff 75 08             	pushl  0x8(%ebp)
80101c4b:	e8 42 01 00 00       	call   80101d92 <iget>
80101c50:	83 c4 10             	add    $0x10,%esp
80101c53:	eb 2d                	jmp    80101c82 <ialloc+0x117>
        }
        brelse(bp);
80101c55:	83 ec 0c             	sub    $0xc,%esp
80101c58:	ff 75 f0             	pushl  -0x10(%ebp)
80101c5b:	e8 ce e5 ff ff       	call   8010022e <brelse>
80101c60:	83 c4 10             	add    $0x10,%esp
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101c63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c67:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c6d:	39 c2                	cmp    %eax,%edx
80101c6f:	0f 87 49 ff ff ff    	ja     80101bbe <ialloc+0x53>
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	68 a1 95 10 80       	push   $0x801095a1
80101c7d:	e8 e4 e8 ff ff       	call   80100566 <panic>
}
80101c82:	c9                   	leave  
80101c83:	c3                   	ret    

80101c84 <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{
80101c84:	55                   	push   %ebp
80101c85:	89 e5                	mov    %esp,%ebp
80101c87:	83 ec 38             	sub    $0x38,%esp

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8b 40 50             	mov    0x50(%eax),%eax
80101c90:	8b 40 14             	mov    0x14(%eax),%eax
80101c93:	c1 e0 05             	shl    $0x5,%eax
80101c96:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101c9b:	8b 10                	mov    (%eax),%edx
80101c9d:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101ca0:	8b 50 04             	mov    0x4(%eax),%edx
80101ca3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101ca6:	8b 50 08             	mov    0x8(%eax),%edx
80101ca9:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101cac:	8b 50 0c             	mov    0xc(%eax),%edx
80101caf:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101cb2:	8b 50 10             	mov    0x10(%eax),%edx
80101cb5:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101cb8:	8b 50 14             	mov    0x14(%eax),%edx
80101cbb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101cbe:	8b 50 18             	mov    0x18(%eax),%edx
80101cc1:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101cc4:	8b 40 1c             	mov    0x1c(%eax),%eax
80101cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101cca:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	8b 40 04             	mov    0x4(%eax),%eax
80101cd3:	c1 e8 03             	shr    $0x3,%eax
80101cd6:	89 c1                	mov    %eax,%ecx
80101cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101cdb:	01 c8                	add    %ecx,%eax
80101cdd:	01 c2                	add    %eax,%edx
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	8b 00                	mov    (%eax),%eax
80101ce4:	83 ec 08             	sub    $0x8,%esp
80101ce7:	52                   	push   %edx
80101ce8:	50                   	push   %eax
80101ce9:	e8 c8 e4 ff ff       	call   801001b6 <bread>
80101cee:	83 c4 10             	add    $0x10,%esp
80101cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum % IPB;
80101cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf7:	8d 50 18             	lea    0x18(%eax),%edx
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	8b 40 04             	mov    0x4(%eax),%eax
80101d00:	83 e0 07             	and    $0x7,%eax
80101d03:	c1 e0 06             	shl    $0x6,%eax
80101d06:	01 d0                	add    %edx,%eax
80101d08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip->type = ip->type;
80101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d15:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d22:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d30:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101d34:	8b 45 08             	mov    0x8(%ebp),%eax
80101d37:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d3e:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 50 18             	mov    0x18(%eax),%edx
80101d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4b:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	8d 50 1c             	lea    0x1c(%eax),%edx
80101d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d57:	83 c0 0c             	add    $0xc,%eax
80101d5a:	83 ec 04             	sub    $0x4,%esp
80101d5d:	6a 34                	push   $0x34
80101d5f:	52                   	push   %edx
80101d60:	50                   	push   %eax
80101d61:	e8 23 41 00 00       	call   80105e89 <memmove>
80101d66:	83 c4 10             	add    $0x10,%esp
    log_write(bp, ip->part->number);
80101d69:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6c:	8b 40 50             	mov    0x50(%eax),%eax
80101d6f:	8b 40 14             	mov    0x14(%eax),%eax
80101d72:	83 ec 08             	sub    $0x8,%esp
80101d75:	50                   	push   %eax
80101d76:	ff 75 f4             	pushl  -0xc(%ebp)
80101d79:	e8 b8 24 00 00       	call   80104236 <log_write>
80101d7e:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101d81:	83 ec 0c             	sub    $0xc,%esp
80101d84:	ff 75 f4             	pushl  -0xc(%ebp)
80101d87:	e8 a2 e4 ff ff       	call   8010022e <brelse>
80101d8c:	83 c4 10             	add    $0x10,%esp
}
80101d8f:	90                   	nop
80101d90:	c9                   	leave  
80101d91:	c3                   	ret    

80101d92 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
80101d92:	55                   	push   %ebp
80101d93:	89 e5                	mov    %esp,%ebp
80101d95:	83 ec 18             	sub    $0x18,%esp
    struct inode* ip, *empty;

    acquire(&icache.lock);
80101d98:	83 ec 0c             	sub    $0xc,%esp
80101d9b:	68 60 24 11 80       	push   $0x80112460
80101da0:	e8 c2 3d 00 00       	call   80105b67 <acquire>
80101da5:	83 c4 10             	add    $0x10,%esp
    // cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
80101da8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101daf:	c7 45 f4 94 24 11 80 	movl   $0x80112494,-0xc(%ebp)
80101db6:	eb 78                	jmp    80101e30 <iget+0x9e>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
80101db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dbb:	8b 40 08             	mov    0x8(%eax),%eax
80101dbe:	85 c0                	test   %eax,%eax
80101dc0:	7e 54                	jle    80101e16 <iget+0x84>
80101dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc5:	8b 00                	mov    (%eax),%eax
80101dc7:	3b 45 08             	cmp    0x8(%ebp),%eax
80101dca:	75 4a                	jne    80101e16 <iget+0x84>
80101dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dcf:	8b 40 04             	mov    0x4(%eax),%eax
80101dd2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101dd5:	75 3f                	jne    80101e16 <iget+0x84>
80101dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dda:	8b 40 50             	mov    0x50(%eax),%eax
80101ddd:	85 c0                	test   %eax,%eax
80101ddf:	74 35                	je     80101e16 <iget+0x84>
80101de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de4:	8b 40 50             	mov    0x50(%eax),%eax
80101de7:	8b 40 14             	mov    0x14(%eax),%eax
80101dea:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ded:	75 27                	jne    80101e16 <iget+0x84>
            ip->ref++;
80101def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df2:	8b 40 08             	mov    0x8(%eax),%eax
80101df5:	8d 50 01             	lea    0x1(%eax),%edx
80101df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dfb:	89 50 08             	mov    %edx,0x8(%eax)
            release(&icache.lock);
80101dfe:	83 ec 0c             	sub    $0xc,%esp
80101e01:	68 60 24 11 80       	push   $0x80112460
80101e06:	e8 c3 3d 00 00       	call   80105bce <release>
80101e0b:	83 c4 10             	add    $0x10,%esp
            return ip;
80101e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e11:	e9 90 00 00 00       	jmp    80101ea6 <iget+0x114>
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101e16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e1a:	75 10                	jne    80101e2c <iget+0x9a>
80101e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e1f:	8b 40 08             	mov    0x8(%eax),%eax
80101e22:	85 c0                	test   %eax,%eax
80101e24:	75 06                	jne    80101e2c <iget+0x9a>
            empty = ip;
80101e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&icache.lock);
    // cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101e2c:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101e30:	81 7d f4 fc 34 11 80 	cmpl   $0x801134fc,-0xc(%ebp)
80101e37:	0f 82 7b ff ff ff    	jb     80101db8 <iget+0x26>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
80101e3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e41:	75 0d                	jne    80101e50 <iget+0xbe>
        panic("iget: no inodes");
80101e43:	83 ec 0c             	sub    $0xc,%esp
80101e46:	68 b3 95 10 80       	push   $0x801095b3
80101e4b:	e8 16 e7 ff ff       	call   80100566 <panic>

    ip = empty;
80101e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e53:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip->dev = dev;
80101e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e59:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5c:	89 10                	mov    %edx,(%eax)
    ip->inum = inum;
80101e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e61:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e64:	89 50 04             	mov    %edx,0x4(%eax)
    ip->part = &(partitions[partitionNumber]);
80101e67:	8b 55 10             	mov    0x10(%ebp),%edx
80101e6a:	89 d0                	mov    %edx,%eax
80101e6c:	01 c0                	add    %eax,%eax
80101e6e:	01 d0                	add    %edx,%eax
80101e70:	c1 e0 03             	shl    $0x3,%eax
80101e73:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e7c:	89 50 50             	mov    %edx,0x50(%eax)
    ip->ref = 1;
80101e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    ip->flags = 0;
80101e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e8c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    release(&icache.lock);
80101e93:	83 ec 0c             	sub    $0xc,%esp
80101e96:	68 60 24 11 80       	push   $0x80112460
80101e9b:	e8 2e 3d 00 00       	call   80105bce <release>
80101ea0:	83 c4 10             	add    $0x10,%esp

    return ip;
80101ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ea6:	c9                   	leave  
80101ea7:	c3                   	ret    

80101ea8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
80101ea8:	55                   	push   %ebp
80101ea9:	89 e5                	mov    %esp,%ebp
80101eab:	83 ec 08             	sub    $0x8,%esp
    //   cprintf("idup \n");

    acquire(&icache.lock);
80101eae:	83 ec 0c             	sub    $0xc,%esp
80101eb1:	68 60 24 11 80       	push   $0x80112460
80101eb6:	e8 ac 3c 00 00       	call   80105b67 <acquire>
80101ebb:	83 c4 10             	add    $0x10,%esp
    ip->ref++;
80101ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec1:	8b 40 08             	mov    0x8(%eax),%eax
80101ec4:	8d 50 01             	lea    0x1(%eax),%edx
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101ecd:	83 ec 0c             	sub    $0xc,%esp
80101ed0:	68 60 24 11 80       	push   $0x80112460
80101ed5:	e8 f4 3c 00 00       	call   80105bce <release>
80101eda:	83 c4 10             	add    $0x10,%esp
    return ip;
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ee0:	c9                   	leave  
80101ee1:	c3                   	ret    

80101ee2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
80101ee2:	55                   	push   %ebp
80101ee3:	89 e5                	mov    %esp,%ebp
80101ee5:	83 ec 38             	sub    $0x38,%esp
    struct buf* bp;
    struct dinode* dip;
    //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
80101ee8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101eec:	74 0a                	je     80101ef8 <ilock+0x16>
80101eee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef1:	8b 40 08             	mov    0x8(%eax),%eax
80101ef4:	85 c0                	test   %eax,%eax
80101ef6:	7f 0d                	jg     80101f05 <ilock+0x23>
        panic("ilock");
80101ef8:	83 ec 0c             	sub    $0xc,%esp
80101efb:	68 c3 95 10 80       	push   $0x801095c3
80101f00:	e8 61 e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101f05:	83 ec 0c             	sub    $0xc,%esp
80101f08:	68 60 24 11 80       	push   $0x80112460
80101f0d:	e8 55 3c 00 00       	call   80105b67 <acquire>
80101f12:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f15:	eb 13                	jmp    80101f2a <ilock+0x48>
        sleep(ip, &icache.lock);
80101f17:	83 ec 08             	sub    $0x8,%esp
80101f1a:	68 60 24 11 80       	push   $0x80112460
80101f1f:	ff 75 08             	pushl  0x8(%ebp)
80101f22:	e8 47 39 00 00       	call   8010586e <sleep>
80101f27:	83 c4 10             	add    $0x10,%esp

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
80101f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2d:	8b 40 0c             	mov    0xc(%eax),%eax
80101f30:	83 e0 01             	and    $0x1,%eax
80101f33:	85 c0                	test   %eax,%eax
80101f35:	75 e0                	jne    80101f17 <ilock+0x35>
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
80101f37:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3a:	8b 40 0c             	mov    0xc(%eax),%eax
80101f3d:	83 c8 01             	or     $0x1,%eax
80101f40:	89 c2                	mov    %eax,%edx
80101f42:	8b 45 08             	mov    0x8(%ebp),%eax
80101f45:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101f48:	83 ec 0c             	sub    $0xc,%esp
80101f4b:	68 60 24 11 80       	push   $0x80112460
80101f50:	e8 79 3c 00 00       	call   80105bce <release>
80101f55:	83 c4 10             	add    $0x10,%esp

    if (!(ip->flags & I_VALID)) {
80101f58:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5b:	8b 40 0c             	mov    0xc(%eax),%eax
80101f5e:	83 e0 02             	and    $0x2,%eax
80101f61:	85 c0                	test   %eax,%eax
80101f63:	0f 85 17 01 00 00    	jne    80102080 <ilock+0x19e>
        struct superblock sb;
        sb = sbs[ip->part->number];
80101f69:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6c:	8b 40 50             	mov    0x50(%eax),%eax
80101f6f:	8b 40 14             	mov    0x14(%eax),%eax
80101f72:	c1 e0 05             	shl    $0x5,%eax
80101f75:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101f7a:	8b 10                	mov    (%eax),%edx
80101f7c:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101f7f:	8b 50 04             	mov    0x4(%eax),%edx
80101f82:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101f85:	8b 50 08             	mov    0x8(%eax),%edx
80101f88:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101f8b:	8b 50 0c             	mov    0xc(%eax),%edx
80101f8e:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101f91:	8b 50 10             	mov    0x10(%eax),%edx
80101f94:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101f97:	8b 50 14             	mov    0x14(%eax),%edx
80101f9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101f9d:	8b 50 18             	mov    0x18(%eax),%edx
80101fa0:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101fa3:	8b 40 1c             	mov    0x1c(%eax),%eax
80101fa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101fa9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101fac:	8b 45 08             	mov    0x8(%ebp),%eax
80101faf:	8b 40 04             	mov    0x4(%eax),%eax
80101fb2:	c1 e8 03             	shr    $0x3,%eax
80101fb5:	89 c1                	mov    %eax,%ecx
80101fb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101fba:	01 c8                	add    %ecx,%eax
80101fbc:	01 c2                	add    %eax,%edx
80101fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc1:	8b 00                	mov    (%eax),%eax
80101fc3:	83 ec 08             	sub    $0x8,%esp
80101fc6:	52                   	push   %edx
80101fc7:	50                   	push   %eax
80101fc8:	e8 e9 e1 ff ff       	call   801001b6 <bread>
80101fcd:	83 c4 10             	add    $0x10,%esp
80101fd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        dip = (struct dinode*)bp->data + ip->inum % IPB;
80101fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fd6:	8d 50 18             	lea    0x18(%eax),%edx
80101fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdc:	8b 40 04             	mov    0x4(%eax),%eax
80101fdf:	83 e0 07             	and    $0x7,%eax
80101fe2:	c1 e0 06             	shl    $0x6,%eax
80101fe5:	01 d0                	add    %edx,%eax
80101fe7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ip->type = dip->type;
80101fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fed:	0f b7 10             	movzwl (%eax),%edx
80101ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff3:	66 89 50 10          	mov    %dx,0x10(%eax)
        ip->major = dip->major;
80101ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ffa:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80102001:	66 89 50 12          	mov    %dx,0x12(%eax)
        ip->minor = dip->minor;
80102005:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102008:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010200c:	8b 45 08             	mov    0x8(%ebp),%eax
8010200f:	66 89 50 14          	mov    %dx,0x14(%eax)
        ip->nlink = dip->nlink;
80102013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102016:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010201a:	8b 45 08             	mov    0x8(%ebp),%eax
8010201d:	66 89 50 16          	mov    %dx,0x16(%eax)
        ip->size = dip->size;
80102021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102024:	8b 50 08             	mov    0x8(%eax),%edx
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	89 50 18             	mov    %edx,0x18(%eax)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010202d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102030:	8d 50 0c             	lea    0xc(%eax),%edx
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	83 c0 1c             	add    $0x1c,%eax
80102039:	83 ec 04             	sub    $0x4,%esp
8010203c:	6a 34                	push   $0x34
8010203e:	52                   	push   %edx
8010203f:	50                   	push   %eax
80102040:	e8 44 3e 00 00       	call   80105e89 <memmove>
80102045:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80102048:	83 ec 0c             	sub    $0xc,%esp
8010204b:	ff 75 f4             	pushl  -0xc(%ebp)
8010204e:	e8 db e1 ff ff       	call   8010022e <brelse>
80102053:	83 c4 10             	add    $0x10,%esp
        ip->flags |= I_VALID;
80102056:	8b 45 08             	mov    0x8(%ebp),%eax
80102059:	8b 40 0c             	mov    0xc(%eax),%eax
8010205c:	83 c8 02             	or     $0x2,%eax
8010205f:	89 c2                	mov    %eax,%edx
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	89 50 0c             	mov    %edx,0xc(%eax)
        if (ip->type == 0)
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010206e:	66 85 c0             	test   %ax,%ax
80102071:	75 0d                	jne    80102080 <ilock+0x19e>
            panic("ilock: no type");
80102073:	83 ec 0c             	sub    $0xc,%esp
80102076:	68 c9 95 10 80       	push   $0x801095c9
8010207b:	e8 e6 e4 ff ff       	call   80100566 <panic>
    }
}
80102080:	90                   	nop
80102081:	c9                   	leave  
80102082:	c3                   	ret    

80102083 <iunlock>:

// Unlock the given inode.
void iunlock(struct inode* ip)
{
80102083:	55                   	push   %ebp
80102084:	89 e5                	mov    %esp,%ebp
80102086:	83 ec 08             	sub    $0x8,%esp
    //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
80102089:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010208d:	74 17                	je     801020a6 <iunlock+0x23>
8010208f:	8b 45 08             	mov    0x8(%ebp),%eax
80102092:	8b 40 0c             	mov    0xc(%eax),%eax
80102095:	83 e0 01             	and    $0x1,%eax
80102098:	85 c0                	test   %eax,%eax
8010209a:	74 0a                	je     801020a6 <iunlock+0x23>
8010209c:	8b 45 08             	mov    0x8(%ebp),%eax
8010209f:	8b 40 08             	mov    0x8(%eax),%eax
801020a2:	85 c0                	test   %eax,%eax
801020a4:	7f 0d                	jg     801020b3 <iunlock+0x30>
        // cprintf("iunlock ilock%d ",ip);
        panic("iunlock");
801020a6:	83 ec 0c             	sub    $0xc,%esp
801020a9:	68 d8 95 10 80       	push   $0x801095d8
801020ae:	e8 b3 e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020b3:	83 ec 0c             	sub    $0xc,%esp
801020b6:	68 60 24 11 80       	push   $0x80112460
801020bb:	e8 a7 3a 00 00       	call   80105b67 <acquire>
801020c0:	83 c4 10             	add    $0x10,%esp
    ip->flags &= ~I_BUSY;
801020c3:	8b 45 08             	mov    0x8(%ebp),%eax
801020c6:	8b 40 0c             	mov    0xc(%eax),%eax
801020c9:	83 e0 fe             	and    $0xfffffffe,%eax
801020cc:	89 c2                	mov    %eax,%edx
801020ce:	8b 45 08             	mov    0x8(%ebp),%eax
801020d1:	89 50 0c             	mov    %edx,0xc(%eax)
    wakeup(ip);
801020d4:	83 ec 0c             	sub    $0xc,%esp
801020d7:	ff 75 08             	pushl  0x8(%ebp)
801020da:	e8 7a 38 00 00       	call   80105959 <wakeup>
801020df:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020e2:	83 ec 0c             	sub    $0xc,%esp
801020e5:	68 60 24 11 80       	push   $0x80112460
801020ea:	e8 df 3a 00 00       	call   80105bce <release>
801020ef:	83 c4 10             	add    $0x10,%esp
}
801020f2:	90                   	nop
801020f3:	c9                   	leave  
801020f4:	c3                   	ret    

801020f5 <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
801020f5:	55                   	push   %ebp
801020f6:	89 e5                	mov    %esp,%ebp
801020f8:	83 ec 08             	sub    $0x8,%esp
    // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
801020fb:	83 ec 0c             	sub    $0xc,%esp
801020fe:	68 60 24 11 80       	push   $0x80112460
80102103:	e8 5f 3a 00 00       	call   80105b67 <acquire>
80102108:	83 c4 10             	add    $0x10,%esp
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
8010210b:	8b 45 08             	mov    0x8(%ebp),%eax
8010210e:	8b 40 08             	mov    0x8(%eax),%eax
80102111:	83 f8 01             	cmp    $0x1,%eax
80102114:	0f 85 a9 00 00 00    	jne    801021c3 <iput+0xce>
8010211a:	8b 45 08             	mov    0x8(%ebp),%eax
8010211d:	8b 40 0c             	mov    0xc(%eax),%eax
80102120:	83 e0 02             	and    $0x2,%eax
80102123:	85 c0                	test   %eax,%eax
80102125:	0f 84 98 00 00 00    	je     801021c3 <iput+0xce>
8010212b:	8b 45 08             	mov    0x8(%ebp),%eax
8010212e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102132:	66 85 c0             	test   %ax,%ax
80102135:	0f 85 88 00 00 00    	jne    801021c3 <iput+0xce>
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
8010213b:	8b 45 08             	mov    0x8(%ebp),%eax
8010213e:	8b 40 0c             	mov    0xc(%eax),%eax
80102141:	83 e0 01             	and    $0x1,%eax
80102144:	85 c0                	test   %eax,%eax
80102146:	74 0d                	je     80102155 <iput+0x60>
            panic("iput busy");
80102148:	83 ec 0c             	sub    $0xc,%esp
8010214b:	68 e0 95 10 80       	push   $0x801095e0
80102150:	e8 11 e4 ff ff       	call   80100566 <panic>
        ip->flags |= I_BUSY;
80102155:	8b 45 08             	mov    0x8(%ebp),%eax
80102158:	8b 40 0c             	mov    0xc(%eax),%eax
8010215b:	83 c8 01             	or     $0x1,%eax
8010215e:	89 c2                	mov    %eax,%edx
80102160:	8b 45 08             	mov    0x8(%ebp),%eax
80102163:	89 50 0c             	mov    %edx,0xc(%eax)
        release(&icache.lock);
80102166:	83 ec 0c             	sub    $0xc,%esp
80102169:	68 60 24 11 80       	push   $0x80112460
8010216e:	e8 5b 3a 00 00       	call   80105bce <release>
80102173:	83 c4 10             	add    $0x10,%esp
        itrunc(ip);
80102176:	83 ec 0c             	sub    $0xc,%esp
80102179:	ff 75 08             	pushl  0x8(%ebp)
8010217c:	e8 1c 02 00 00       	call   8010239d <itrunc>
80102181:	83 c4 10             	add    $0x10,%esp
        ip->type = 0;
80102184:	8b 45 08             	mov    0x8(%ebp),%eax
80102187:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
        iupdate(ip);
8010218d:	83 ec 0c             	sub    $0xc,%esp
80102190:	ff 75 08             	pushl  0x8(%ebp)
80102193:	e8 ec fa ff ff       	call   80101c84 <iupdate>
80102198:	83 c4 10             	add    $0x10,%esp
        acquire(&icache.lock);
8010219b:	83 ec 0c             	sub    $0xc,%esp
8010219e:	68 60 24 11 80       	push   $0x80112460
801021a3:	e8 bf 39 00 00       	call   80105b67 <acquire>
801021a8:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801021ab:	8b 45 08             	mov    0x8(%ebp),%eax
801021ae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021b5:	83 ec 0c             	sub    $0xc,%esp
801021b8:	ff 75 08             	pushl  0x8(%ebp)
801021bb:	e8 99 37 00 00       	call   80105959 <wakeup>
801021c0:	83 c4 10             	add    $0x10,%esp
    }
    ip->ref--;
801021c3:	8b 45 08             	mov    0x8(%ebp),%eax
801021c6:	8b 40 08             	mov    0x8(%eax),%eax
801021c9:	8d 50 ff             	lea    -0x1(%eax),%edx
801021cc:	8b 45 08             	mov    0x8(%ebp),%eax
801021cf:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
801021d2:	83 ec 0c             	sub    $0xc,%esp
801021d5:	68 60 24 11 80       	push   $0x80112460
801021da:	e8 ef 39 00 00       	call   80105bce <release>
801021df:	83 c4 10             	add    $0x10,%esp
}
801021e2:	90                   	nop
801021e3:	c9                   	leave  
801021e4:	c3                   	ret    

801021e5 <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
801021e5:	55                   	push   %ebp
801021e6:	89 e5                	mov    %esp,%ebp
801021e8:	83 ec 08             	sub    $0x8,%esp
    iunlock(ip);
801021eb:	83 ec 0c             	sub    $0xc,%esp
801021ee:	ff 75 08             	pushl  0x8(%ebp)
801021f1:	e8 8d fe ff ff       	call   80102083 <iunlock>
801021f6:	83 c4 10             	add    $0x10,%esp
    iput(ip);
801021f9:	83 ec 0c             	sub    $0xc,%esp
801021fc:	ff 75 08             	pushl  0x8(%ebp)
801021ff:	e8 f1 fe ff ff       	call   801020f5 <iput>
80102204:	83 c4 10             	add    $0x10,%esp
}
80102207:	90                   	nop
80102208:	c9                   	leave  
80102209:	c3                   	ret    

8010220a <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
8010220a:	55                   	push   %ebp
8010220b:	89 e5                	mov    %esp,%ebp
8010220d:	53                   	push   %ebx
8010220e:	83 ec 34             	sub    $0x34,%esp
    //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
    struct superblock sb;
    sb = sbs[ip->part->number];
80102211:	8b 45 08             	mov    0x8(%ebp),%eax
80102214:	8b 40 50             	mov    0x50(%eax),%eax
80102217:	8b 40 14             	mov    0x14(%eax),%eax
8010221a:	c1 e0 05             	shl    $0x5,%eax
8010221d:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102222:	8b 10                	mov    (%eax),%edx
80102224:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102227:	8b 50 04             	mov    0x4(%eax),%edx
8010222a:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010222d:	8b 50 08             	mov    0x8(%eax),%edx
80102230:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102233:	8b 50 0c             	mov    0xc(%eax),%edx
80102236:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102239:	8b 50 10             	mov    0x10(%eax),%edx
8010223c:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010223f:	8b 50 14             	mov    0x14(%eax),%edx
80102242:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102245:	8b 50 18             	mov    0x18(%eax),%edx
80102248:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010224b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010224e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (bn < NDIRECT) {
80102251:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102255:	77 4e                	ja     801022a5 <bmap+0x9b>
        if ((addr = ip->addrs[bn]) == 0)
80102257:	8b 45 08             	mov    0x8(%ebp),%eax
8010225a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010225d:	83 c2 04             	add    $0x4,%edx
80102260:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102264:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102267:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010226b:	75 30                	jne    8010229d <bmap+0x93>
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
8010226d:	8b 45 08             	mov    0x8(%ebp),%eax
80102270:	8b 40 50             	mov    0x50(%eax),%eax
80102273:	8b 40 14             	mov    0x14(%eax),%eax
80102276:	89 c2                	mov    %eax,%edx
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 00                	mov    (%eax),%eax
8010227d:	83 ec 08             	sub    $0x8,%esp
80102280:	52                   	push   %edx
80102281:	50                   	push   %eax
80102282:	e8 bc f2 ff ff       	call   80101543 <balloc>
80102287:	83 c4 10             	add    $0x10,%esp
8010228a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010228d:	8b 45 08             	mov    0x8(%ebp),%eax
80102290:	8b 55 0c             	mov    0xc(%ebp),%edx
80102293:	8d 4a 04             	lea    0x4(%edx),%ecx
80102296:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102299:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
        // cprintf("addr %d \n ",addr);
        return addr;
8010229d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a0:	e9 f3 00 00 00       	jmp    80102398 <bmap+0x18e>
    }
    bn -= NDIRECT;
801022a5:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

    if (bn < NINDIRECT) {
801022a9:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801022ad:	0f 87 d8 00 00 00    	ja     8010238b <bmap+0x181>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801022b3:	8b 45 08             	mov    0x8(%ebp),%eax
801022b6:	8b 40 4c             	mov    0x4c(%eax),%eax
801022b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022c0:	75 29                	jne    801022eb <bmap+0xe1>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
801022c2:	8b 45 08             	mov    0x8(%ebp),%eax
801022c5:	8b 40 50             	mov    0x50(%eax),%eax
801022c8:	8b 40 14             	mov    0x14(%eax),%eax
801022cb:	89 c2                	mov    %eax,%edx
801022cd:	8b 45 08             	mov    0x8(%ebp),%eax
801022d0:	8b 00                	mov    (%eax),%eax
801022d2:	83 ec 08             	sub    $0x8,%esp
801022d5:	52                   	push   %edx
801022d6:	50                   	push   %eax
801022d7:	e8 67 f2 ff ff       	call   80101543 <balloc>
801022dc:	83 c4 10             	add    $0x10,%esp
801022df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022e2:	8b 45 08             	mov    0x8(%ebp),%eax
801022e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022e8:	89 50 4c             	mov    %edx,0x4c(%eax)
        bp = bread(ip->dev, sb.offset + addr);
801022eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801022ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f1:	01 c2                	add    %eax,%edx
801022f3:	8b 45 08             	mov    0x8(%ebp),%eax
801022f6:	8b 00                	mov    (%eax),%eax
801022f8:	83 ec 08             	sub    $0x8,%esp
801022fb:	52                   	push   %edx
801022fc:	50                   	push   %eax
801022fd:	e8 b4 de ff ff       	call   801001b6 <bread>
80102302:	83 c4 10             	add    $0x10,%esp
80102305:	89 45 f0             	mov    %eax,-0x10(%ebp)
        a = (uint*)bp->data;
80102308:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010230b:	83 c0 18             	add    $0x18,%eax
8010230e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if ((addr = a[bn]) == 0) {
80102311:	8b 45 0c             	mov    0xc(%ebp),%eax
80102314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010231b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010231e:	01 d0                	add    %edx,%eax
80102320:	8b 00                	mov    (%eax),%eax
80102322:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102325:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102329:	75 4d                	jne    80102378 <bmap+0x16e>
            a[bn] = addr = balloc(ip->dev, ip->part->number);
8010232b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102335:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102338:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010233b:	8b 45 08             	mov    0x8(%ebp),%eax
8010233e:	8b 40 50             	mov    0x50(%eax),%eax
80102341:	8b 40 14             	mov    0x14(%eax),%eax
80102344:	89 c2                	mov    %eax,%edx
80102346:	8b 45 08             	mov    0x8(%ebp),%eax
80102349:	8b 00                	mov    (%eax),%eax
8010234b:	83 ec 08             	sub    $0x8,%esp
8010234e:	52                   	push   %edx
8010234f:	50                   	push   %eax
80102350:	e8 ee f1 ff ff       	call   80101543 <balloc>
80102355:	83 c4 10             	add    $0x10,%esp
80102358:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010235b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235e:	89 03                	mov    %eax,(%ebx)
            log_write(bp, ip->part->number);
80102360:	8b 45 08             	mov    0x8(%ebp),%eax
80102363:	8b 40 50             	mov    0x50(%eax),%eax
80102366:	8b 40 14             	mov    0x14(%eax),%eax
80102369:	83 ec 08             	sub    $0x8,%esp
8010236c:	50                   	push   %eax
8010236d:	ff 75 f0             	pushl  -0x10(%ebp)
80102370:	e8 c1 1e 00 00       	call   80104236 <log_write>
80102375:	83 c4 10             	add    $0x10,%esp
        }
        brelse(bp);
80102378:	83 ec 0c             	sub    $0xc,%esp
8010237b:	ff 75 f0             	pushl  -0x10(%ebp)
8010237e:	e8 ab de ff ff       	call   8010022e <brelse>
80102383:	83 c4 10             	add    $0x10,%esp
        return addr;
80102386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102389:	eb 0d                	jmp    80102398 <bmap+0x18e>
    }

    panic("bmap: out of range");
8010238b:	83 ec 0c             	sub    $0xc,%esp
8010238e:	68 ea 95 10 80       	push   $0x801095ea
80102393:	e8 ce e1 ff ff       	call   80100566 <panic>
}
80102398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010239b:	c9                   	leave  
8010239c:	c3                   	ret    

8010239d <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
8010239d:	55                   	push   %ebp
8010239e:	89 e5                	mov    %esp,%ebp
801023a0:	83 ec 38             	sub    $0x38,%esp

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb = sbs[ip->part->number];
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	8b 40 50             	mov    0x50(%eax),%eax
801023a9:	8b 40 14             	mov    0x14(%eax),%eax
801023ac:	c1 e0 05             	shl    $0x5,%eax
801023af:	05 60 d6 10 80       	add    $0x8010d660,%eax
801023b4:	8b 10                	mov    (%eax),%edx
801023b6:	89 55 c8             	mov    %edx,-0x38(%ebp)
801023b9:	8b 50 04             	mov    0x4(%eax),%edx
801023bc:	89 55 cc             	mov    %edx,-0x34(%ebp)
801023bf:	8b 50 08             	mov    0x8(%eax),%edx
801023c2:	89 55 d0             	mov    %edx,-0x30(%ebp)
801023c5:	8b 50 0c             	mov    0xc(%eax),%edx
801023c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801023cb:	8b 50 10             	mov    0x10(%eax),%edx
801023ce:	89 55 d8             	mov    %edx,-0x28(%ebp)
801023d1:	8b 50 14             	mov    0x14(%eax),%edx
801023d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
801023d7:	8b 50 18             	mov    0x18(%eax),%edx
801023da:	89 55 e0             	mov    %edx,-0x20(%ebp)
801023dd:	8b 40 1c             	mov    0x1c(%eax),%eax
801023e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < NDIRECT; i++) {
801023e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023ea:	eb 51                	jmp    8010243d <itrunc+0xa0>
        if (ip->addrs[i]) {
801023ec:	8b 45 08             	mov    0x8(%ebp),%eax
801023ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023f2:	83 c2 04             	add    $0x4,%edx
801023f5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801023f9:	85 c0                	test   %eax,%eax
801023fb:	74 3c                	je     80102439 <itrunc+0x9c>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
801023fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102400:	8b 40 50             	mov    0x50(%eax),%eax
80102403:	8b 40 14             	mov    0x14(%eax),%eax
80102406:	89 c1                	mov    %eax,%ecx
80102408:	8b 45 08             	mov    0x8(%ebp),%eax
8010240b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010240e:	83 c2 04             	add    $0x4,%edx
80102411:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102415:	8b 55 08             	mov    0x8(%ebp),%edx
80102418:	8b 12                	mov    (%edx),%edx
8010241a:	83 ec 04             	sub    $0x4,%esp
8010241d:	51                   	push   %ecx
8010241e:	50                   	push   %eax
8010241f:	52                   	push   %edx
80102420:	e8 b1 f2 ff ff       	call   801016d6 <bfree>
80102425:	83 c4 10             	add    $0x10,%esp
            ip->addrs[i] = 0;
80102428:	8b 45 08             	mov    0x8(%ebp),%eax
8010242b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010242e:	83 c2 04             	add    $0x4,%edx
80102431:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80102438:	00 
    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb = sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
80102439:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010243d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102441:	7e a9                	jle    801023ec <itrunc+0x4f>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
80102443:	8b 45 08             	mov    0x8(%ebp),%eax
80102446:	8b 40 4c             	mov    0x4c(%eax),%eax
80102449:	85 c0                	test   %eax,%eax
8010244b:	0f 84 be 00 00 00    	je     8010250f <itrunc+0x172>
        bp = bread(ip->dev, sb.offset + ip->addrs[NDIRECT]);
80102451:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102454:	8b 45 08             	mov    0x8(%ebp),%eax
80102457:	8b 40 4c             	mov    0x4c(%eax),%eax
8010245a:	01 c2                	add    %eax,%edx
8010245c:	8b 45 08             	mov    0x8(%ebp),%eax
8010245f:	8b 00                	mov    (%eax),%eax
80102461:	83 ec 08             	sub    $0x8,%esp
80102464:	52                   	push   %edx
80102465:	50                   	push   %eax
80102466:	e8 4b dd ff ff       	call   801001b6 <bread>
8010246b:	83 c4 10             	add    $0x10,%esp
8010246e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        a = (uint*)bp->data;
80102471:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102474:	83 c0 18             	add    $0x18,%eax
80102477:	89 45 e8             	mov    %eax,-0x18(%ebp)
        for (j = 0; j < NINDIRECT; j++) {
8010247a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102481:	eb 48                	jmp    801024cb <itrunc+0x12e>
            if (a[j])
80102483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102486:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010248d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102490:	01 d0                	add    %edx,%eax
80102492:	8b 00                	mov    (%eax),%eax
80102494:	85 c0                	test   %eax,%eax
80102496:	74 2f                	je     801024c7 <itrunc+0x12a>
                bfree(ip->dev, a[j], ip->part->number);
80102498:	8b 45 08             	mov    0x8(%ebp),%eax
8010249b:	8b 40 50             	mov    0x50(%eax),%eax
8010249e:	8b 40 14             	mov    0x14(%eax),%eax
801024a1:	89 c1                	mov    %eax,%ecx
801024a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801024ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024b0:	01 d0                	add    %edx,%eax
801024b2:	8b 00                	mov    (%eax),%eax
801024b4:	8b 55 08             	mov    0x8(%ebp),%edx
801024b7:	8b 12                	mov    (%edx),%edx
801024b9:	83 ec 04             	sub    $0x4,%esp
801024bc:	51                   	push   %ecx
801024bd:	50                   	push   %eax
801024be:	52                   	push   %edx
801024bf:	e8 12 f2 ff ff       	call   801016d6 <bfree>
801024c4:	83 c4 10             	add    $0x10,%esp
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset + ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
801024c7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801024cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024ce:	83 f8 7f             	cmp    $0x7f,%eax
801024d1:	76 b0                	jbe    80102483 <itrunc+0xe6>
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 ec             	pushl  -0x14(%ebp)
801024d9:	e8 50 dd ff ff       	call   8010022e <brelse>
801024de:	83 c4 10             	add    $0x10,%esp
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
801024e1:	8b 45 08             	mov    0x8(%ebp),%eax
801024e4:	8b 40 50             	mov    0x50(%eax),%eax
801024e7:	8b 40 14             	mov    0x14(%eax),%eax
801024ea:	89 c1                	mov    %eax,%ecx
801024ec:	8b 45 08             	mov    0x8(%ebp),%eax
801024ef:	8b 40 4c             	mov    0x4c(%eax),%eax
801024f2:	8b 55 08             	mov    0x8(%ebp),%edx
801024f5:	8b 12                	mov    (%edx),%edx
801024f7:	83 ec 04             	sub    $0x4,%esp
801024fa:	51                   	push   %ecx
801024fb:	50                   	push   %eax
801024fc:	52                   	push   %edx
801024fd:	e8 d4 f1 ff ff       	call   801016d6 <bfree>
80102502:	83 c4 10             	add    $0x10,%esp
        ip->addrs[NDIRECT] = 0;
80102505:	8b 45 08             	mov    0x8(%ebp),%eax
80102508:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }

    ip->size = 0;
8010250f:	8b 45 08             	mov    0x8(%ebp),%eax
80102512:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    iupdate(ip);
80102519:	83 ec 0c             	sub    $0xc,%esp
8010251c:	ff 75 08             	pushl  0x8(%ebp)
8010251f:	e8 60 f7 ff ff       	call   80101c84 <iupdate>
80102524:	83 c4 10             	add    $0x10,%esp
}
80102527:	90                   	nop
80102528:	c9                   	leave  
80102529:	c3                   	ret    

8010252a <stati>:

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
8010252a:	55                   	push   %ebp
8010252b:	89 e5                	mov    %esp,%ebp
    st->dev = ip->dev;
8010252d:	8b 45 08             	mov    0x8(%ebp),%eax
80102530:	8b 00                	mov    (%eax),%eax
80102532:	89 c2                	mov    %eax,%edx
80102534:	8b 45 0c             	mov    0xc(%ebp),%eax
80102537:	89 50 04             	mov    %edx,0x4(%eax)
    st->ino = ip->inum;
8010253a:	8b 45 08             	mov    0x8(%ebp),%eax
8010253d:	8b 50 04             	mov    0x4(%eax),%edx
80102540:	8b 45 0c             	mov    0xc(%ebp),%eax
80102543:	89 50 08             	mov    %edx,0x8(%eax)
    st->type = ip->type;
80102546:	8b 45 08             	mov    0x8(%ebp),%eax
80102549:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010254d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102550:	66 89 10             	mov    %dx,(%eax)
    st->nlink = ip->nlink;
80102553:	8b 45 08             	mov    0x8(%ebp),%eax
80102556:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010255a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010255d:	66 89 50 0c          	mov    %dx,0xc(%eax)
    st->size = ip->size;
80102561:	8b 45 08             	mov    0x8(%ebp),%eax
80102564:	8b 50 18             	mov    0x18(%eax),%edx
80102567:	8b 45 0c             	mov    0xc(%ebp),%eax
8010256a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010256d:	90                   	nop
8010256e:	5d                   	pop    %ebp
8010256f:	c3                   	ret    

80102570 <readi>:

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
80102570:	55                   	push   %ebp
80102571:	89 e5                	mov    %esp,%ebp
80102573:	83 ec 38             	sub    $0x38,%esp
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
    //      cprintf("readi \n");
    sb = sbs[ip->part->number];
80102576:	8b 45 08             	mov    0x8(%ebp),%eax
80102579:	8b 40 50             	mov    0x50(%eax),%eax
8010257c:	8b 40 14             	mov    0x14(%eax),%eax
8010257f:	c1 e0 05             	shl    $0x5,%eax
80102582:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102587:	8b 10                	mov    (%eax),%edx
80102589:	89 55 c8             	mov    %edx,-0x38(%ebp)
8010258c:	8b 50 04             	mov    0x4(%eax),%edx
8010258f:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102592:	8b 50 08             	mov    0x8(%eax),%edx
80102595:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102598:	8b 50 0c             	mov    0xc(%eax),%edx
8010259b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010259e:	8b 50 10             	mov    0x10(%eax),%edx
801025a1:	89 55 d8             	mov    %edx,-0x28(%ebp)
801025a4:	8b 50 14             	mov    0x14(%eax),%edx
801025a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
801025aa:	8b 50 18             	mov    0x18(%eax),%edx
801025ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
801025b0:	8b 40 1c             	mov    0x1c(%eax),%eax
801025b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ip->type == T_DEV) {
801025b6:	8b 45 08             	mov    0x8(%ebp),%eax
801025b9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025bd:	66 83 f8 03          	cmp    $0x3,%ax
801025c1:	75 5c                	jne    8010261f <readi+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801025c3:	8b 45 08             	mov    0x8(%ebp),%eax
801025c6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025ca:	66 85 c0             	test   %ax,%ax
801025cd:	78 20                	js     801025ef <readi+0x7f>
801025cf:	8b 45 08             	mov    0x8(%ebp),%eax
801025d2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025d6:	66 83 f8 09          	cmp    $0x9,%ax
801025da:	7f 13                	jg     801025ef <readi+0x7f>
801025dc:	8b 45 08             	mov    0x8(%ebp),%eax
801025df:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025e3:	98                   	cwtl   
801025e4:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
801025eb:	85 c0                	test   %eax,%eax
801025ed:	75 0a                	jne    801025f9 <readi+0x89>
            return -1;
801025ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025f4:	e9 15 01 00 00       	jmp    8010270e <readi+0x19e>
        return devsw[ip->major].read(ip, dst, n);
801025f9:	8b 45 08             	mov    0x8(%ebp),%eax
801025fc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102600:	98                   	cwtl   
80102601:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80102608:	8b 55 14             	mov    0x14(%ebp),%edx
8010260b:	83 ec 04             	sub    $0x4,%esp
8010260e:	52                   	push   %edx
8010260f:	ff 75 0c             	pushl  0xc(%ebp)
80102612:	ff 75 08             	pushl  0x8(%ebp)
80102615:	ff d0                	call   *%eax
80102617:	83 c4 10             	add    $0x10,%esp
8010261a:	e9 ef 00 00 00       	jmp    8010270e <readi+0x19e>
    }

    if (off > ip->size || off + n < off)
8010261f:	8b 45 08             	mov    0x8(%ebp),%eax
80102622:	8b 40 18             	mov    0x18(%eax),%eax
80102625:	3b 45 10             	cmp    0x10(%ebp),%eax
80102628:	72 0d                	jb     80102637 <readi+0xc7>
8010262a:	8b 55 10             	mov    0x10(%ebp),%edx
8010262d:	8b 45 14             	mov    0x14(%ebp),%eax
80102630:	01 d0                	add    %edx,%eax
80102632:	3b 45 10             	cmp    0x10(%ebp),%eax
80102635:	73 0a                	jae    80102641 <readi+0xd1>
        return -1;
80102637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010263c:	e9 cd 00 00 00       	jmp    8010270e <readi+0x19e>
    if (off + n > ip->size)
80102641:	8b 55 10             	mov    0x10(%ebp),%edx
80102644:	8b 45 14             	mov    0x14(%ebp),%eax
80102647:	01 c2                	add    %eax,%edx
80102649:	8b 45 08             	mov    0x8(%ebp),%eax
8010264c:	8b 40 18             	mov    0x18(%eax),%eax
8010264f:	39 c2                	cmp    %eax,%edx
80102651:	76 0c                	jbe    8010265f <readi+0xef>
        n = ip->size - off;
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	8b 40 18             	mov    0x18(%eax),%eax
80102659:	2b 45 10             	sub    0x10(%ebp),%eax
8010265c:	89 45 14             	mov    %eax,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
8010265f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102666:	e9 94 00 00 00       	jmp    801026ff <readi+0x18f>
        uint bmapOut = bmap(ip, off / BSIZE);
8010266b:	8b 45 10             	mov    0x10(%ebp),%eax
8010266e:	c1 e8 09             	shr    $0x9,%eax
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	50                   	push   %eax
80102675:	ff 75 08             	pushl  0x8(%ebp)
80102678:	e8 8d fb ff ff       	call   8010220a <bmap>
8010267d:	83 c4 10             	add    $0x10,%esp
80102680:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset + bmapOut);
80102683:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102686:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102689:	01 c2                	add    %eax,%edx
8010268b:	8b 45 08             	mov    0x8(%ebp),%eax
8010268e:	8b 00                	mov    (%eax),%eax
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	52                   	push   %edx
80102694:	50                   	push   %eax
80102695:	e8 1c db ff ff       	call   801001b6 <bread>
8010269a:	83 c4 10             	add    $0x10,%esp
8010269d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
801026a0:	8b 45 10             	mov    0x10(%ebp),%eax
801026a3:	25 ff 01 00 00       	and    $0x1ff,%eax
801026a8:	ba 00 02 00 00       	mov    $0x200,%edx
801026ad:	29 c2                	sub    %eax,%edx
801026af:	8b 45 14             	mov    0x14(%ebp),%eax
801026b2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801026b5:	39 c2                	cmp    %eax,%edx
801026b7:	0f 46 c2             	cmovbe %edx,%eax
801026ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(dst, bp->data + off % BSIZE, m);
801026bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026c0:	8d 50 18             	lea    0x18(%eax),%edx
801026c3:	8b 45 10             	mov    0x10(%ebp),%eax
801026c6:	25 ff 01 00 00       	and    $0x1ff,%eax
801026cb:	01 d0                	add    %edx,%eax
801026cd:	83 ec 04             	sub    $0x4,%esp
801026d0:	ff 75 e8             	pushl  -0x18(%ebp)
801026d3:	50                   	push   %eax
801026d4:	ff 75 0c             	pushl  0xc(%ebp)
801026d7:	e8 ad 37 00 00       	call   80105e89 <memmove>
801026dc:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801026df:	83 ec 0c             	sub    $0xc,%esp
801026e2:	ff 75 ec             	pushl  -0x14(%ebp)
801026e5:	e8 44 db ff ff       	call   8010022e <brelse>
801026ea:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
801026ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026f0:	01 45 f4             	add    %eax,-0xc(%ebp)
801026f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026f6:	01 45 10             	add    %eax,0x10(%ebp)
801026f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026fc:	01 45 0c             	add    %eax,0xc(%ebp)
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	3b 45 14             	cmp    0x14(%ebp),%eax
80102705:	0f 82 60 ff ff ff    	jb     8010266b <readi+0xfb>
        bp = bread(ip->dev, sb.offset + bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
8010270b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010270e:	c9                   	leave  
8010270f:	c3                   	ret    

80102710 <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
80102713:	83 ec 38             	sub    $0x38,%esp
    // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
    sb = sbs[ip->part->number];
80102716:	8b 45 08             	mov    0x8(%ebp),%eax
80102719:	8b 40 50             	mov    0x50(%eax),%eax
8010271c:	8b 40 14             	mov    0x14(%eax),%eax
8010271f:	c1 e0 05             	shl    $0x5,%eax
80102722:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102727:	8b 10                	mov    (%eax),%edx
80102729:	89 55 c8             	mov    %edx,-0x38(%ebp)
8010272c:	8b 50 04             	mov    0x4(%eax),%edx
8010272f:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102732:	8b 50 08             	mov    0x8(%eax),%edx
80102735:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102738:	8b 50 0c             	mov    0xc(%eax),%edx
8010273b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010273e:	8b 50 10             	mov    0x10(%eax),%edx
80102741:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102744:	8b 50 14             	mov    0x14(%eax),%edx
80102747:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010274a:	8b 50 18             	mov    0x18(%eax),%edx
8010274d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102750:	8b 40 1c             	mov    0x1c(%eax),%eax
80102753:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (ip->type == T_DEV) {
80102756:	8b 45 08             	mov    0x8(%ebp),%eax
80102759:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010275d:	66 83 f8 03          	cmp    $0x3,%ax
80102761:	75 5c                	jne    801027bf <writei+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102763:	8b 45 08             	mov    0x8(%ebp),%eax
80102766:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010276a:	66 85 c0             	test   %ax,%ax
8010276d:	78 20                	js     8010278f <writei+0x7f>
8010276f:	8b 45 08             	mov    0x8(%ebp),%eax
80102772:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102776:	66 83 f8 09          	cmp    $0x9,%ax
8010277a:	7f 13                	jg     8010278f <writei+0x7f>
8010277c:	8b 45 08             	mov    0x8(%ebp),%eax
8010277f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102783:	98                   	cwtl   
80102784:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010278b:	85 c0                	test   %eax,%eax
8010278d:	75 0a                	jne    80102799 <writei+0x89>
            return -1;
8010278f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102794:	e9 50 01 00 00       	jmp    801028e9 <writei+0x1d9>
        return devsw[ip->major].write(ip, src, n);
80102799:	8b 45 08             	mov    0x8(%ebp),%eax
8010279c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027a0:	98                   	cwtl   
801027a1:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801027a8:	8b 55 14             	mov    0x14(%ebp),%edx
801027ab:	83 ec 04             	sub    $0x4,%esp
801027ae:	52                   	push   %edx
801027af:	ff 75 0c             	pushl  0xc(%ebp)
801027b2:	ff 75 08             	pushl  0x8(%ebp)
801027b5:	ff d0                	call   *%eax
801027b7:	83 c4 10             	add    $0x10,%esp
801027ba:	e9 2a 01 00 00       	jmp    801028e9 <writei+0x1d9>
    }

    if (off > ip->size || off + n < off)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 40 18             	mov    0x18(%eax),%eax
801027c5:	3b 45 10             	cmp    0x10(%ebp),%eax
801027c8:	72 0d                	jb     801027d7 <writei+0xc7>
801027ca:	8b 55 10             	mov    0x10(%ebp),%edx
801027cd:	8b 45 14             	mov    0x14(%ebp),%eax
801027d0:	01 d0                	add    %edx,%eax
801027d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801027d5:	73 0a                	jae    801027e1 <writei+0xd1>
        return -1;
801027d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027dc:	e9 08 01 00 00       	jmp    801028e9 <writei+0x1d9>
    if (off + n > MAXFILE * BSIZE)
801027e1:	8b 55 10             	mov    0x10(%ebp),%edx
801027e4:	8b 45 14             	mov    0x14(%ebp),%eax
801027e7:	01 d0                	add    %edx,%eax
801027e9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801027ee:	76 0a                	jbe    801027fa <writei+0xea>
        return -1;
801027f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027f5:	e9 ef 00 00 00       	jmp    801028e9 <writei+0x1d9>

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801027fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102801:	e9 ac 00 00 00       	jmp    801028b2 <writei+0x1a2>
        uint bmapOut = bmap(ip, off / BSIZE);
80102806:	8b 45 10             	mov    0x10(%ebp),%eax
80102809:	c1 e8 09             	shr    $0x9,%eax
8010280c:	83 ec 08             	sub    $0x8,%esp
8010280f:	50                   	push   %eax
80102810:	ff 75 08             	pushl  0x8(%ebp)
80102813:	e8 f2 f9 ff ff       	call   8010220a <bmap>
80102818:	83 c4 10             	add    $0x10,%esp
8010281b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        bp = bread(ip->dev, sb.offset + bmapOut);
8010281e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102824:	01 c2                	add    %eax,%edx
80102826:	8b 45 08             	mov    0x8(%ebp),%eax
80102829:	8b 00                	mov    (%eax),%eax
8010282b:	83 ec 08             	sub    $0x8,%esp
8010282e:	52                   	push   %edx
8010282f:	50                   	push   %eax
80102830:	e8 81 d9 ff ff       	call   801001b6 <bread>
80102835:	83 c4 10             	add    $0x10,%esp
80102838:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
8010283b:	8b 45 10             	mov    0x10(%ebp),%eax
8010283e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102843:	ba 00 02 00 00       	mov    $0x200,%edx
80102848:	29 c2                	sub    %eax,%edx
8010284a:	8b 45 14             	mov    0x14(%ebp),%eax
8010284d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102850:	39 c2                	cmp    %eax,%edx
80102852:	0f 46 c2             	cmovbe %edx,%eax
80102855:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(bp->data + off % BSIZE, src, m);
80102858:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010285b:	8d 50 18             	lea    0x18(%eax),%edx
8010285e:	8b 45 10             	mov    0x10(%ebp),%eax
80102861:	25 ff 01 00 00       	and    $0x1ff,%eax
80102866:	01 d0                	add    %edx,%eax
80102868:	83 ec 04             	sub    $0x4,%esp
8010286b:	ff 75 e8             	pushl  -0x18(%ebp)
8010286e:	ff 75 0c             	pushl  0xc(%ebp)
80102871:	50                   	push   %eax
80102872:	e8 12 36 00 00       	call   80105e89 <memmove>
80102877:	83 c4 10             	add    $0x10,%esp
        log_write(bp, ip->part->number);
8010287a:	8b 45 08             	mov    0x8(%ebp),%eax
8010287d:	8b 40 50             	mov    0x50(%eax),%eax
80102880:	8b 40 14             	mov    0x14(%eax),%eax
80102883:	83 ec 08             	sub    $0x8,%esp
80102886:	50                   	push   %eax
80102887:	ff 75 ec             	pushl  -0x14(%ebp)
8010288a:	e8 a7 19 00 00       	call   80104236 <log_write>
8010288f:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80102892:	83 ec 0c             	sub    $0xc,%esp
80102895:	ff 75 ec             	pushl  -0x14(%ebp)
80102898:	e8 91 d9 ff ff       	call   8010022e <brelse>
8010289d:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801028a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028a3:	01 45 f4             	add    %eax,-0xc(%ebp)
801028a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028a9:	01 45 10             	add    %eax,0x10(%ebp)
801028ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028af:	01 45 0c             	add    %eax,0xc(%ebp)
801028b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b5:	3b 45 14             	cmp    0x14(%ebp),%eax
801028b8:	0f 82 48 ff ff ff    	jb     80102806 <writei+0xf6>
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp, ip->part->number);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
801028be:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801028c2:	74 22                	je     801028e6 <writei+0x1d6>
801028c4:	8b 45 08             	mov    0x8(%ebp),%eax
801028c7:	8b 40 18             	mov    0x18(%eax),%eax
801028ca:	3b 45 10             	cmp    0x10(%ebp),%eax
801028cd:	73 17                	jae    801028e6 <writei+0x1d6>
        ip->size = off;
801028cf:	8b 45 08             	mov    0x8(%ebp),%eax
801028d2:	8b 55 10             	mov    0x10(%ebp),%edx
801028d5:	89 50 18             	mov    %edx,0x18(%eax)
        iupdate(ip);
801028d8:	83 ec 0c             	sub    $0xc,%esp
801028db:	ff 75 08             	pushl  0x8(%ebp)
801028de:	e8 a1 f3 ff ff       	call   80101c84 <iupdate>
801028e3:	83 c4 10             	add    $0x10,%esp
    }
    return n;
801028e6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <namecmp>:

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 08             	sub    $0x8,%esp
    return strncmp(s, t, DIRSIZ);
801028f1:	83 ec 04             	sub    $0x4,%esp
801028f4:	6a 0e                	push   $0xe
801028f6:	ff 75 0c             	pushl  0xc(%ebp)
801028f9:	ff 75 08             	pushl  0x8(%ebp)
801028fc:	e8 1e 36 00 00       	call   80105f1f <strncmp>
80102901:	83 c4 10             	add    $0x10,%esp
}
80102904:	c9                   	leave  
80102905:	c3                   	ret    

80102906 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
80102906:	55                   	push   %ebp
80102907:	89 e5                	mov    %esp,%ebp
80102909:	83 ec 28             	sub    $0x28,%esp

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
8010290c:	8b 45 08             	mov    0x8(%ebp),%eax
8010290f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102913:	66 83 f8 01          	cmp    $0x1,%ax
80102917:	74 0d                	je     80102926 <dirlookup+0x20>
        panic("dirlookup not DIR");
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	68 fd 95 10 80       	push   $0x801095fd
80102921:	e8 40 dc ff ff       	call   80100566 <panic>

    for (off = 0; off < dp->size; off += sizeof(de)) {
80102926:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010292d:	e9 85 00 00 00       	jmp    801029b7 <dirlookup+0xb1>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102932:	6a 10                	push   $0x10
80102934:	ff 75 f4             	pushl  -0xc(%ebp)
80102937:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010293a:	50                   	push   %eax
8010293b:	ff 75 08             	pushl  0x8(%ebp)
8010293e:	e8 2d fc ff ff       	call   80102570 <readi>
80102943:	83 c4 10             	add    $0x10,%esp
80102946:	83 f8 10             	cmp    $0x10,%eax
80102949:	74 0d                	je     80102958 <dirlookup+0x52>
            panic("dirlink read");
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 0f 96 10 80       	push   $0x8010960f
80102953:	e8 0e dc ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102958:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010295c:	66 85 c0             	test   %ax,%ax
8010295f:	74 51                	je     801029b2 <dirlookup+0xac>
            continue;
        if (namecmp(name, de.name) == 0) {
80102961:	83 ec 08             	sub    $0x8,%esp
80102964:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102967:	83 c0 02             	add    $0x2,%eax
8010296a:	50                   	push   %eax
8010296b:	ff 75 0c             	pushl  0xc(%ebp)
8010296e:	e8 78 ff ff ff       	call   801028eb <namecmp>
80102973:	83 c4 10             	add    $0x10,%esp
80102976:	85 c0                	test   %eax,%eax
80102978:	75 39                	jne    801029b3 <dirlookup+0xad>
            // entry matches path element
            if (poff)
8010297a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010297e:	74 08                	je     80102988 <dirlookup+0x82>
                *poff = off;
80102980:	8b 45 10             	mov    0x10(%ebp),%eax
80102983:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102986:	89 10                	mov    %edx,(%eax)
            inum = de.inum;
80102988:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010298c:	0f b7 c0             	movzwl %ax,%eax
8010298f:	89 45 f0             	mov    %eax,-0x10(%ebp)
            return iget(dp->dev, inum, dp->part->number);
80102992:	8b 45 08             	mov    0x8(%ebp),%eax
80102995:	8b 40 50             	mov    0x50(%eax),%eax
80102998:	8b 50 14             	mov    0x14(%eax),%edx
8010299b:	8b 45 08             	mov    0x8(%ebp),%eax
8010299e:	8b 00                	mov    (%eax),%eax
801029a0:	83 ec 04             	sub    $0x4,%esp
801029a3:	52                   	push   %edx
801029a4:	ff 75 f0             	pushl  -0x10(%ebp)
801029a7:	50                   	push   %eax
801029a8:	e8 e5 f3 ff ff       	call   80101d92 <iget>
801029ad:	83 c4 10             	add    $0x10,%esp
801029b0:	eb 19                	jmp    801029cb <dirlookup+0xc5>

    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            continue;
801029b2:	90                   	nop
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801029b3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801029b7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ba:	8b 40 18             	mov    0x18(%eax),%eax
801029bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801029c0:	0f 87 6c ff ff ff    	ja     80102932 <dirlookup+0x2c>
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
801029c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    

801029cd <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
801029cd:	55                   	push   %ebp
801029ce:	89 e5                	mov    %esp,%ebp
801029d0:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
801029d3:	83 ec 04             	sub    $0x4,%esp
801029d6:	6a 00                	push   $0x0
801029d8:	ff 75 0c             	pushl  0xc(%ebp)
801029db:	ff 75 08             	pushl  0x8(%ebp)
801029de:	e8 23 ff ff ff       	call   80102906 <dirlookup>
801029e3:	83 c4 10             	add    $0x10,%esp
801029e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801029e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801029ed:	74 18                	je     80102a07 <dirlink+0x3a>
        iput(ip);
801029ef:	83 ec 0c             	sub    $0xc,%esp
801029f2:	ff 75 f0             	pushl  -0x10(%ebp)
801029f5:	e8 fb f6 ff ff       	call   801020f5 <iput>
801029fa:	83 c4 10             	add    $0x10,%esp
        return -1;
801029fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a02:	e9 9c 00 00 00       	jmp    80102aa3 <dirlink+0xd6>
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a0e:	eb 39                	jmp    80102a49 <dirlink+0x7c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a13:	6a 10                	push   $0x10
80102a15:	50                   	push   %eax
80102a16:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a19:	50                   	push   %eax
80102a1a:	ff 75 08             	pushl  0x8(%ebp)
80102a1d:	e8 4e fb ff ff       	call   80102570 <readi>
80102a22:	83 c4 10             	add    $0x10,%esp
80102a25:	83 f8 10             	cmp    $0x10,%eax
80102a28:	74 0d                	je     80102a37 <dirlink+0x6a>
            panic("dirlink read");
80102a2a:	83 ec 0c             	sub    $0xc,%esp
80102a2d:	68 0f 96 10 80       	push   $0x8010960f
80102a32:	e8 2f db ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102a37:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102a3b:	66 85 c0             	test   %ax,%ax
80102a3e:	74 18                	je     80102a58 <dirlink+0x8b>
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a43:	83 c0 10             	add    $0x10,%eax
80102a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a49:	8b 45 08             	mov    0x8(%ebp),%eax
80102a4c:	8b 50 18             	mov    0x18(%eax),%edx
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	39 c2                	cmp    %eax,%edx
80102a54:	77 ba                	ja     80102a10 <dirlink+0x43>
80102a56:	eb 01                	jmp    80102a59 <dirlink+0x8c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            break;
80102a58:	90                   	nop
    }

    strncpy(de.name, name, DIRSIZ);
80102a59:	83 ec 04             	sub    $0x4,%esp
80102a5c:	6a 0e                	push   $0xe
80102a5e:	ff 75 0c             	pushl  0xc(%ebp)
80102a61:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a64:	83 c0 02             	add    $0x2,%eax
80102a67:	50                   	push   %eax
80102a68:	e8 08 35 00 00       	call   80105f75 <strncpy>
80102a6d:	83 c4 10             	add    $0x10,%esp
    de.inum = inum;
80102a70:	8b 45 10             	mov    0x10(%ebp),%eax
80102a73:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7a:	6a 10                	push   $0x10
80102a7c:	50                   	push   %eax
80102a7d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a80:	50                   	push   %eax
80102a81:	ff 75 08             	pushl  0x8(%ebp)
80102a84:	e8 87 fc ff ff       	call   80102710 <writei>
80102a89:	83 c4 10             	add    $0x10,%esp
80102a8c:	83 f8 10             	cmp    $0x10,%eax
80102a8f:	74 0d                	je     80102a9e <dirlink+0xd1>
        panic("dirlink");
80102a91:	83 ec 0c             	sub    $0xc,%esp
80102a94:	68 1c 96 10 80       	push   $0x8010961c
80102a99:	e8 c8 da ff ff       	call   80100566 <panic>

    return 0;
80102a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102aa3:	c9                   	leave  
80102aa4:	c3                   	ret    

80102aa5 <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
80102aa5:	55                   	push   %ebp
80102aa6:	89 e5                	mov    %esp,%ebp
80102aa8:	83 ec 18             	sub    $0x18,%esp

    char* s;
    int len;

    while (*path == '/')
80102aab:	eb 04                	jmp    80102ab1 <skipelem+0xc>
        path++;
80102aad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{

    char* s;
    int len;

    while (*path == '/')
80102ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab4:	0f b6 00             	movzbl (%eax),%eax
80102ab7:	3c 2f                	cmp    $0x2f,%al
80102ab9:	74 f2                	je     80102aad <skipelem+0x8>
        path++;
    if (*path == 0)
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	0f b6 00             	movzbl (%eax),%eax
80102ac1:	84 c0                	test   %al,%al
80102ac3:	75 07                	jne    80102acc <skipelem+0x27>
        return 0;
80102ac5:	b8 00 00 00 00       	mov    $0x0,%eax
80102aca:	eb 7b                	jmp    80102b47 <skipelem+0xa2>
    s = path;
80102acc:	8b 45 08             	mov    0x8(%ebp),%eax
80102acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (*path != '/' && *path != 0)
80102ad2:	eb 04                	jmp    80102ad8 <skipelem+0x33>
        path++;
80102ad4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
80102ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80102adb:	0f b6 00             	movzbl (%eax),%eax
80102ade:	3c 2f                	cmp    $0x2f,%al
80102ae0:	74 0a                	je     80102aec <skipelem+0x47>
80102ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae5:	0f b6 00             	movzbl (%eax),%eax
80102ae8:	84 c0                	test   %al,%al
80102aea:	75 e8                	jne    80102ad4 <skipelem+0x2f>
        path++;
    len = path - s;
80102aec:	8b 55 08             	mov    0x8(%ebp),%edx
80102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af2:	29 c2                	sub    %eax,%edx
80102af4:	89 d0                	mov    %edx,%eax
80102af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (len >= DIRSIZ)
80102af9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102afd:	7e 15                	jle    80102b14 <skipelem+0x6f>
        memmove(name, s, DIRSIZ);
80102aff:	83 ec 04             	sub    $0x4,%esp
80102b02:	6a 0e                	push   $0xe
80102b04:	ff 75 f4             	pushl  -0xc(%ebp)
80102b07:	ff 75 0c             	pushl  0xc(%ebp)
80102b0a:	e8 7a 33 00 00       	call   80105e89 <memmove>
80102b0f:	83 c4 10             	add    $0x10,%esp
80102b12:	eb 26                	jmp    80102b3a <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b17:	83 ec 04             	sub    $0x4,%esp
80102b1a:	50                   	push   %eax
80102b1b:	ff 75 f4             	pushl  -0xc(%ebp)
80102b1e:	ff 75 0c             	pushl  0xc(%ebp)
80102b21:	e8 63 33 00 00       	call   80105e89 <memmove>
80102b26:	83 c4 10             	add    $0x10,%esp
        name[len] = 0;
80102b29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b2f:	01 d0                	add    %edx,%eax
80102b31:	c6 00 00             	movb   $0x0,(%eax)
    }
    while (*path == '/')
80102b34:	eb 04                	jmp    80102b3a <skipelem+0x95>
        path++;
80102b36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3d:	0f b6 00             	movzbl (%eax),%eax
80102b40:	3c 2f                	cmp    $0x2f,%al
80102b42:	74 f2                	je     80102b36 <skipelem+0x91>
        path++;
    return path;
80102b44:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102b47:	c9                   	leave  
80102b48:	c3                   	ret    

80102b49 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, int ignoreMounts, char* name)
{
80102b49:	55                   	push   %ebp
80102b4a:	89 e5                	mov    %esp,%ebp
80102b4c:	83 ec 18             	sub    $0x18,%esp
    // cprintf("namex \n");

    struct inode* ip, *next;
    // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
80102b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b52:	0f b6 00             	movzbl (%eax),%eax
80102b55:	3c 2f                	cmp    $0x2f,%al
80102b57:	75 1d                	jne    80102b76 <namex+0x2d>
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
80102b59:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80102b5e:	83 ec 04             	sub    $0x4,%esp
80102b61:	50                   	push   %eax
80102b62:	6a 01                	push   $0x1
80102b64:	6a 00                	push   $0x0
80102b66:	e8 27 f2 ff ff       	call   80101d92 <iget>
80102b6b:	83 c4 10             	add    $0x10,%esp
80102b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b71:	e9 50 01 00 00       	jmp    80102cc6 <namex+0x17d>
    else
        ip = idup(proc->cwd);
80102b76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102b7c:	8b 40 68             	mov    0x68(%eax),%eax
80102b7f:	83 ec 0c             	sub    $0xc,%esp
80102b82:	50                   	push   %eax
80102b83:	e8 20 f3 ff ff       	call   80101ea8 <idup>
80102b88:	83 c4 10             	add    $0x10,%esp
80102b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while ((path = skipelem(path, name)) != 0) {
80102b8e:	e9 33 01 00 00       	jmp    80102cc6 <namex+0x17d>
//cprintf("namex path %s \n",path);
        ilock(ip);
80102b93:	83 ec 0c             	sub    $0xc,%esp
80102b96:	ff 75 f4             	pushl  -0xc(%ebp)
80102b99:	e8 44 f3 ff ff       	call   80101ee2 <ilock>
80102b9e:	83 c4 10             	add    $0x10,%esp
        if (ip->type != T_DIR) {
80102ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102ba8:	66 83 f8 01          	cmp    $0x1,%ax
80102bac:	74 18                	je     80102bc6 <namex+0x7d>
            iunlockput(ip);
80102bae:	83 ec 0c             	sub    $0xc,%esp
80102bb1:	ff 75 f4             	pushl  -0xc(%ebp)
80102bb4:	e8 2c f6 ff ff       	call   801021e5 <iunlockput>
80102bb9:	83 c4 10             	add    $0x10,%esp
            return 0;
80102bbc:	b8 00 00 00 00       	mov    $0x0,%eax
80102bc1:	e9 3c 01 00 00       	jmp    80102d02 <namex+0x1b9>
        }
        if (nameiparent && *path == '\0') {
80102bc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bca:	74 20                	je     80102bec <namex+0xa3>
80102bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcf:	0f b6 00             	movzbl (%eax),%eax
80102bd2:	84 c0                	test   %al,%al
80102bd4:	75 16                	jne    80102bec <namex+0xa3>
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
80102bd6:	83 ec 0c             	sub    $0xc,%esp
80102bd9:	ff 75 f4             	pushl  -0xc(%ebp)
80102bdc:	e8 a2 f4 ff ff       	call   80102083 <iunlock>
80102be1:	83 c4 10             	add    $0x10,%esp
            return ip;
80102be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be7:	e9 16 01 00 00       	jmp    80102d02 <namex+0x1b9>
        }

        if ((next = dirlookup(ip, name, 0)) == 0) {
80102bec:	83 ec 04             	sub    $0x4,%esp
80102bef:	6a 00                	push   $0x0
80102bf1:	ff 75 14             	pushl  0x14(%ebp)
80102bf4:	ff 75 f4             	pushl  -0xc(%ebp)
80102bf7:	e8 0a fd ff ff       	call   80102906 <dirlookup>
80102bfc:	83 c4 10             	add    $0x10,%esp
80102bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102c02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102c06:	75 18                	jne    80102c20 <namex+0xd7>
           // cprintf("next is zero \n");
            iunlockput(ip);
80102c08:	83 ec 0c             	sub    $0xc,%esp
80102c0b:	ff 75 f4             	pushl  -0xc(%ebp)
80102c0e:	e8 d2 f5 ff ff       	call   801021e5 <iunlockput>
80102c13:	83 c4 10             	add    $0x10,%esp
            return 0;
80102c16:	b8 00 00 00 00       	mov    $0x0,%eax
80102c1b:	e9 e2 00 00 00       	jmp    80102d02 <namex+0x1b9>
        }
        iunlockput(ip);
80102c20:	83 ec 0c             	sub    $0xc,%esp
80102c23:	ff 75 f4             	pushl  -0xc(%ebp)
80102c26:	e8 ba f5 ff ff       	call   801021e5 <iunlockput>
80102c2b:	83 c4 10             	add    $0x10,%esp
        ilock(next);
80102c2e:	83 ec 0c             	sub    $0xc,%esp
80102c31:	ff 75 f0             	pushl  -0x10(%ebp)
80102c34:	e8 a9 f2 ff ff       	call   80101ee2 <ilock>
80102c39:	83 c4 10             	add    $0x10,%esp
       //  cprintf("next %d , type %d major %d minor %d \n",next->inum,next->type,next->major,next->minor);
        if (!ignoreMounts && next->type == T_DIR && next->major != 0 && next->major != MOUNTING_POINT) {
80102c3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c40:	75 17                	jne    80102c59 <namex+0x110>
80102c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c45:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c49:	66 83 f8 01          	cmp    $0x1,%ax
80102c4d:	75 0a                	jne    80102c59 <namex+0x110>
80102c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c52:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c56:	66 85 c0             	test   %ax,%ax
         //   cprintf("major used ,we are fucked \n");
        }
        // handle mounting points

        if (!ignoreMounts && !nameiparent && next->type == T_DIR && next->major == MOUNTING_POINT) {
80102c59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c5d:	75 53                	jne    80102cb2 <namex+0x169>
80102c5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c63:	75 4d                	jne    80102cb2 <namex+0x169>
80102c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c6c:	66 83 f8 01          	cmp    $0x1,%ax
80102c70:	75 40                	jne    80102cb2 <namex+0x169>
80102c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c75:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c79:	66 83 f8 01          	cmp    $0x1,%ax
80102c7d:	75 33                	jne    80102cb2 <namex+0x169>
           // cprintf("got into condition \n");
                        iunlock(next);
80102c7f:	83 ec 0c             	sub    $0xc,%esp
80102c82:	ff 75 f0             	pushl  -0x10(%ebp)
80102c85:	e8 f9 f3 ff ff       	call   80102083 <iunlock>
80102c8a:	83 c4 10             	add    $0x10,%esp

            // iunlockput(ip);
            uint partitionNumnber = next->minor;
80102c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c90:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80102c94:	98                   	cwtl   
80102c95:	89 45 ec             	mov    %eax,-0x14(%ebp)
            ip = iget(ROOTDEV, 1, partitionNumnber);
80102c98:	83 ec 04             	sub    $0x4,%esp
80102c9b:	ff 75 ec             	pushl  -0x14(%ebp)
80102c9e:	6a 01                	push   $0x1
80102ca0:	6a 00                	push   $0x0
80102ca2:	e8 eb f0 ff ff       	call   80101d92 <iget>
80102ca7:	83 c4 10             	add    $0x10,%esp
80102caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
            return ip;
80102cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb0:	eb 50                	jmp    80102d02 <namex+0x1b9>
        }
        iunlock(next);
80102cb2:	83 ec 0c             	sub    $0xc,%esp
80102cb5:	ff 75 f0             	pushl  -0x10(%ebp)
80102cb8:	e8 c6 f3 ff ff       	call   80102083 <iunlock>
80102cbd:	83 c4 10             	add    $0x10,%esp

        // testing

        ip = next;
80102cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102cc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102cc6:	83 ec 08             	sub    $0x8,%esp
80102cc9:	ff 75 14             	pushl  0x14(%ebp)
80102ccc:	ff 75 08             	pushl  0x8(%ebp)
80102ccf:	e8 d1 fd ff ff       	call   80102aa5 <skipelem>
80102cd4:	83 c4 10             	add    $0x10,%esp
80102cd7:	89 45 08             	mov    %eax,0x8(%ebp)
80102cda:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cde:	0f 85 af fe ff ff    	jne    80102b93 <namex+0x4a>

        // testing

        ip = next;
    }
    if (nameiparent) {
80102ce4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102ce8:	74 15                	je     80102cff <namex+0x1b6>
        iput(ip);
80102cea:	83 ec 0c             	sub    $0xc,%esp
80102ced:	ff 75 f4             	pushl  -0xc(%ebp)
80102cf0:	e8 00 f4 ff ff       	call   801020f5 <iput>
80102cf5:	83 c4 10             	add    $0x10,%esp
        return 0;
80102cf8:	b8 00 00 00 00       	mov    $0x0,%eax
80102cfd:	eb 03                	jmp    80102d02 <namex+0x1b9>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d02:	c9                   	leave  
80102d03:	c3                   	ret    

80102d04 <namei>:

struct inode* namei(char* path)
{
80102d04:	55                   	push   %ebp
80102d05:	89 e5                	mov    %esp,%ebp
80102d07:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 0, name);
80102d0a:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	6a 00                	push   $0x0
80102d10:	6a 00                	push   $0x0
80102d12:	ff 75 08             	pushl  0x8(%ebp)
80102d15:	e8 2f fe ff ff       	call   80102b49 <namex>
80102d1a:	83 c4 10             	add    $0x10,%esp
}
80102d1d:	c9                   	leave  
80102d1e:	c3                   	ret    

80102d1f <nameiIgnoreMounts>:

struct inode* nameiIgnoreMounts(char* path)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 1, name);
80102d25:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d28:	50                   	push   %eax
80102d29:	6a 01                	push   $0x1
80102d2b:	6a 00                	push   $0x0
80102d2d:	ff 75 08             	pushl  0x8(%ebp)
80102d30:	e8 14 fe ff ff       	call   80102b49 <namex>
80102d35:	83 c4 10             	add    $0x10,%esp
}
80102d38:	c9                   	leave  
80102d39:	c3                   	ret    

80102d3a <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
80102d3d:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, 0, name);
80102d40:	ff 75 0c             	pushl  0xc(%ebp)
80102d43:	6a 00                	push   $0x0
80102d45:	6a 01                	push   $0x1
80102d47:	ff 75 08             	pushl  0x8(%ebp)
80102d4a:	e8 fa fd ff ff       	call   80102b49 <namex>
80102d4f:	83 c4 10             	add    $0x10,%esp
}
80102d52:	c9                   	leave  
80102d53:	c3                   	ret    

80102d54 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d54:	55                   	push   %ebp
80102d55:	89 e5                	mov    %esp,%ebp
80102d57:	83 ec 14             	sub    $0x14,%esp
80102d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d5d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d61:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d65:	89 c2                	mov    %eax,%edx
80102d67:	ec                   	in     (%dx),%al
80102d68:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d6b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d6f:	c9                   	leave  
80102d70:	c3                   	ret    

80102d71 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d71:	55                   	push   %ebp
80102d72:	89 e5                	mov    %esp,%ebp
80102d74:	57                   	push   %edi
80102d75:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d76:	8b 55 08             	mov    0x8(%ebp),%edx
80102d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d7c:	8b 45 10             	mov    0x10(%ebp),%eax
80102d7f:	89 cb                	mov    %ecx,%ebx
80102d81:	89 df                	mov    %ebx,%edi
80102d83:	89 c1                	mov    %eax,%ecx
80102d85:	fc                   	cld    
80102d86:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d88:	89 c8                	mov    %ecx,%eax
80102d8a:	89 fb                	mov    %edi,%ebx
80102d8c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d8f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d92:	90                   	nop
80102d93:	5b                   	pop    %ebx
80102d94:	5f                   	pop    %edi
80102d95:	5d                   	pop    %ebp
80102d96:	c3                   	ret    

80102d97 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d97:	55                   	push   %ebp
80102d98:	89 e5                	mov    %esp,%ebp
80102d9a:	83 ec 08             	sub    $0x8,%esp
80102d9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102da3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102da7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102daa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102dae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102db2:	ee                   	out    %al,(%dx)
}
80102db3:	90                   	nop
80102db4:	c9                   	leave  
80102db5:	c3                   	ret    

80102db6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102db6:	55                   	push   %ebp
80102db7:	89 e5                	mov    %esp,%ebp
80102db9:	56                   	push   %esi
80102dba:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102dbb:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102dc1:	8b 45 10             	mov    0x10(%ebp),%eax
80102dc4:	89 cb                	mov    %ecx,%ebx
80102dc6:	89 de                	mov    %ebx,%esi
80102dc8:	89 c1                	mov    %eax,%ecx
80102dca:	fc                   	cld    
80102dcb:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102dcd:	89 c8                	mov    %ecx,%eax
80102dcf:	89 f3                	mov    %esi,%ebx
80102dd1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102dd4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102dd7:	90                   	nop
80102dd8:	5b                   	pop    %ebx
80102dd9:	5e                   	pop    %esi
80102dda:	5d                   	pop    %ebp
80102ddb:	c3                   	ret    

80102ddc <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102ddc:	55                   	push   %ebp
80102ddd:	89 e5                	mov    %esp,%ebp
80102ddf:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102de2:	90                   	nop
80102de3:	68 f7 01 00 00       	push   $0x1f7
80102de8:	e8 67 ff ff ff       	call   80102d54 <inb>
80102ded:	83 c4 04             	add    $0x4,%esp
80102df0:	0f b6 c0             	movzbl %al,%eax
80102df3:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102df6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df9:	25 c0 00 00 00       	and    $0xc0,%eax
80102dfe:	83 f8 40             	cmp    $0x40,%eax
80102e01:	75 e0                	jne    80102de3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102e03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e07:	74 11                	je     80102e1a <idewait+0x3e>
80102e09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0c:	83 e0 21             	and    $0x21,%eax
80102e0f:	85 c0                	test   %eax,%eax
80102e11:	74 07                	je     80102e1a <idewait+0x3e>
    return -1;
80102e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e18:	eb 05                	jmp    80102e1f <idewait+0x43>
  return 0;
80102e1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e1f:	c9                   	leave  
80102e20:	c3                   	ret    

80102e21 <ideinit>:

void
ideinit(void)
{
80102e21:	55                   	push   %ebp
80102e22:	89 e5                	mov    %esp,%ebp
80102e24:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102e27:	83 ec 08             	sub    $0x8,%esp
80102e2a:	68 2e 96 10 80       	push   $0x8010962e
80102e2f:	68 00 c6 10 80       	push   $0x8010c600
80102e34:	e8 0c 2d 00 00       	call   80105b45 <initlock>
80102e39:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e3c:	83 ec 0c             	sub    $0xc,%esp
80102e3f:	6a 0e                	push   $0xe
80102e41:	e8 fd 1b 00 00       	call   80104a43 <picenable>
80102e46:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e49:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102e4e:	83 e8 01             	sub    $0x1,%eax
80102e51:	83 ec 08             	sub    $0x8,%esp
80102e54:	50                   	push   %eax
80102e55:	6a 0e                	push   $0xe
80102e57:	e8 83 04 00 00       	call   801032df <ioapicenable>
80102e5c:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102e5f:	83 ec 0c             	sub    $0xc,%esp
80102e62:	6a 00                	push   $0x0
80102e64:	e8 73 ff ff ff       	call   80102ddc <idewait>
80102e69:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e6c:	83 ec 08             	sub    $0x8,%esp
80102e6f:	68 f0 00 00 00       	push   $0xf0
80102e74:	68 f6 01 00 00       	push   $0x1f6
80102e79:	e8 19 ff ff ff       	call   80102d97 <outb>
80102e7e:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102e81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e88:	eb 24                	jmp    80102eae <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102e8a:	83 ec 0c             	sub    $0xc,%esp
80102e8d:	68 f7 01 00 00       	push   $0x1f7
80102e92:	e8 bd fe ff ff       	call   80102d54 <inb>
80102e97:	83 c4 10             	add    $0x10,%esp
80102e9a:	84 c0                	test   %al,%al
80102e9c:	74 0c                	je     80102eaa <ideinit+0x89>
      havedisk1 = 1;
80102e9e:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102ea5:	00 00 00 
      break;
80102ea8:	eb 0d                	jmp    80102eb7 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102eaa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102eae:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102eb5:	7e d3                	jle    80102e8a <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102eb7:	83 ec 08             	sub    $0x8,%esp
80102eba:	68 e0 00 00 00       	push   $0xe0
80102ebf:	68 f6 01 00 00       	push   $0x1f6
80102ec4:	e8 ce fe ff ff       	call   80102d97 <outb>
80102ec9:	83 c4 10             	add    $0x10,%esp
}
80102ecc:	90                   	nop
80102ecd:	c9                   	leave  
80102ece:	c3                   	ret    

80102ecf <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102ecf:	55                   	push   %ebp
80102ed0:	89 e5                	mov    %esp,%ebp
80102ed2:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102ed5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ed9:	75 0d                	jne    80102ee8 <idestart+0x19>
    panic("idestart");
80102edb:	83 ec 0c             	sub    $0xc,%esp
80102ede:	68 32 96 10 80       	push   $0x80109632
80102ee3:	e8 7e d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80102eeb:	8b 40 08             	mov    0x8(%eax),%eax
80102eee:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102ef3:	76 1d                	jbe    80102f12 <idestart+0x43>
      cprintf("block %d \n");
80102ef5:	83 ec 0c             	sub    $0xc,%esp
80102ef8:	68 3b 96 10 80       	push   $0x8010963b
80102efd:	e8 c4 d4 ff ff       	call   801003c6 <cprintf>
80102f02:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102f05:	83 ec 0c             	sub    $0xc,%esp
80102f08:	68 46 96 10 80       	push   $0x80109646
80102f0d:	e8 54 d6 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102f12:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102f19:	8b 45 08             	mov    0x8(%ebp),%eax
80102f1c:	8b 50 08             	mov    0x8(%eax),%edx
80102f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f22:	0f af c2             	imul   %edx,%eax
80102f25:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f28:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f2c:	7e 0d                	jle    80102f3b <idestart+0x6c>
80102f2e:	83 ec 0c             	sub    $0xc,%esp
80102f31:	68 32 96 10 80       	push   $0x80109632
80102f36:	e8 2b d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102f3b:	83 ec 0c             	sub    $0xc,%esp
80102f3e:	6a 00                	push   $0x0
80102f40:	e8 97 fe ff ff       	call   80102ddc <idewait>
80102f45:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f48:	83 ec 08             	sub    $0x8,%esp
80102f4b:	6a 00                	push   $0x0
80102f4d:	68 f6 03 00 00       	push   $0x3f6
80102f52:	e8 40 fe ff ff       	call   80102d97 <outb>
80102f57:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f5d:	0f b6 c0             	movzbl %al,%eax
80102f60:	83 ec 08             	sub    $0x8,%esp
80102f63:	50                   	push   %eax
80102f64:	68 f2 01 00 00       	push   $0x1f2
80102f69:	e8 29 fe ff ff       	call   80102d97 <outb>
80102f6e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f74:	0f b6 c0             	movzbl %al,%eax
80102f77:	83 ec 08             	sub    $0x8,%esp
80102f7a:	50                   	push   %eax
80102f7b:	68 f3 01 00 00       	push   $0x1f3
80102f80:	e8 12 fe ff ff       	call   80102d97 <outb>
80102f85:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f8b:	c1 f8 08             	sar    $0x8,%eax
80102f8e:	0f b6 c0             	movzbl %al,%eax
80102f91:	83 ec 08             	sub    $0x8,%esp
80102f94:	50                   	push   %eax
80102f95:	68 f4 01 00 00       	push   $0x1f4
80102f9a:	e8 f8 fd ff ff       	call   80102d97 <outb>
80102f9f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa5:	c1 f8 10             	sar    $0x10,%eax
80102fa8:	0f b6 c0             	movzbl %al,%eax
80102fab:	83 ec 08             	sub    $0x8,%esp
80102fae:	50                   	push   %eax
80102faf:	68 f5 01 00 00       	push   $0x1f5
80102fb4:	e8 de fd ff ff       	call   80102d97 <outb>
80102fb9:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80102fbf:	8b 40 04             	mov    0x4(%eax),%eax
80102fc2:	83 e0 01             	and    $0x1,%eax
80102fc5:	c1 e0 04             	shl    $0x4,%eax
80102fc8:	89 c2                	mov    %eax,%edx
80102fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fcd:	c1 f8 18             	sar    $0x18,%eax
80102fd0:	83 e0 0f             	and    $0xf,%eax
80102fd3:	09 d0                	or     %edx,%eax
80102fd5:	83 c8 e0             	or     $0xffffffe0,%eax
80102fd8:	0f b6 c0             	movzbl %al,%eax
80102fdb:	83 ec 08             	sub    $0x8,%esp
80102fde:	50                   	push   %eax
80102fdf:	68 f6 01 00 00       	push   $0x1f6
80102fe4:	e8 ae fd ff ff       	call   80102d97 <outb>
80102fe9:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102fec:	8b 45 08             	mov    0x8(%ebp),%eax
80102fef:	8b 00                	mov    (%eax),%eax
80102ff1:	83 e0 04             	and    $0x4,%eax
80102ff4:	85 c0                	test   %eax,%eax
80102ff6:	74 30                	je     80103028 <idestart+0x159>
    outb(0x1f7, IDE_CMD_WRITE);
80102ff8:	83 ec 08             	sub    $0x8,%esp
80102ffb:	6a 30                	push   $0x30
80102ffd:	68 f7 01 00 00       	push   $0x1f7
80103002:	e8 90 fd ff ff       	call   80102d97 <outb>
80103007:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010300a:	8b 45 08             	mov    0x8(%ebp),%eax
8010300d:	83 c0 18             	add    $0x18,%eax
80103010:	83 ec 04             	sub    $0x4,%esp
80103013:	68 80 00 00 00       	push   $0x80
80103018:	50                   	push   %eax
80103019:	68 f0 01 00 00       	push   $0x1f0
8010301e:	e8 93 fd ff ff       	call   80102db6 <outsl>
80103023:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80103026:	eb 12                	jmp    8010303a <idestart+0x16b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80103028:	83 ec 08             	sub    $0x8,%esp
8010302b:	6a 20                	push   $0x20
8010302d:	68 f7 01 00 00       	push   $0x1f7
80103032:	e8 60 fd ff ff       	call   80102d97 <outb>
80103037:	83 c4 10             	add    $0x10,%esp
  }
}
8010303a:	90                   	nop
8010303b:	c9                   	leave  
8010303c:	c3                   	ret    

8010303d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010303d:	55                   	push   %ebp
8010303e:	89 e5                	mov    %esp,%ebp
80103040:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80103043:	83 ec 0c             	sub    $0xc,%esp
80103046:	68 00 c6 10 80       	push   $0x8010c600
8010304b:	e8 17 2b 00 00       	call   80105b67 <acquire>
80103050:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80103053:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103058:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010305b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010305f:	75 15                	jne    80103076 <ideintr+0x39>
    release(&idelock);
80103061:	83 ec 0c             	sub    $0xc,%esp
80103064:	68 00 c6 10 80       	push   $0x8010c600
80103069:	e8 60 2b 00 00       	call   80105bce <release>
8010306e:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80103071:	e9 9a 00 00 00       	jmp    80103110 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80103076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103079:	8b 40 14             	mov    0x14(%eax),%eax
8010307c:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103084:	8b 00                	mov    (%eax),%eax
80103086:	83 e0 04             	and    $0x4,%eax
80103089:	85 c0                	test   %eax,%eax
8010308b:	75 2d                	jne    801030ba <ideintr+0x7d>
8010308d:	83 ec 0c             	sub    $0xc,%esp
80103090:	6a 01                	push   $0x1
80103092:	e8 45 fd ff ff       	call   80102ddc <idewait>
80103097:	83 c4 10             	add    $0x10,%esp
8010309a:	85 c0                	test   %eax,%eax
8010309c:	78 1c                	js     801030ba <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010309e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030a1:	83 c0 18             	add    $0x18,%eax
801030a4:	83 ec 04             	sub    $0x4,%esp
801030a7:	68 80 00 00 00       	push   $0x80
801030ac:	50                   	push   %eax
801030ad:	68 f0 01 00 00       	push   $0x1f0
801030b2:	e8 ba fc ff ff       	call   80102d71 <insl>
801030b7:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801030ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030bd:	8b 00                	mov    (%eax),%eax
801030bf:	83 c8 02             	or     $0x2,%eax
801030c2:	89 c2                	mov    %eax,%edx
801030c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c7:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030cc:	8b 00                	mov    (%eax),%eax
801030ce:	83 e0 fb             	and    $0xfffffffb,%eax
801030d1:	89 c2                	mov    %eax,%edx
801030d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030d6:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801030d8:	83 ec 0c             	sub    $0xc,%esp
801030db:	ff 75 f4             	pushl  -0xc(%ebp)
801030de:	e8 76 28 00 00       	call   80105959 <wakeup>
801030e3:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
801030e6:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030eb:	85 c0                	test   %eax,%eax
801030ed:	74 11                	je     80103100 <ideintr+0xc3>
            //cprintf("ideintr \n");
                idestart(idequeue);
801030ef:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030f4:	83 ec 0c             	sub    $0xc,%esp
801030f7:	50                   	push   %eax
801030f8:	e8 d2 fd ff ff       	call   80102ecf <idestart>
801030fd:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
80103100:	83 ec 0c             	sub    $0xc,%esp
80103103:	68 00 c6 10 80       	push   $0x8010c600
80103108:	e8 c1 2a 00 00       	call   80105bce <release>
8010310d:	83 c4 10             	add    $0x10,%esp
}
80103110:	c9                   	leave  
80103111:	c3                   	ret    

80103112 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103112:	55                   	push   %ebp
80103113:	89 e5                	mov    %esp,%ebp
80103115:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103118:	8b 45 08             	mov    0x8(%ebp),%eax
8010311b:	8b 00                	mov    (%eax),%eax
8010311d:	83 e0 01             	and    $0x1,%eax
80103120:	85 c0                	test   %eax,%eax
80103122:	75 0d                	jne    80103131 <iderw+0x1f>
    panic("iderw: buf not busy");
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 58 96 10 80       	push   $0x80109658
8010312c:	e8 35 d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103131:	8b 45 08             	mov    0x8(%ebp),%eax
80103134:	8b 00                	mov    (%eax),%eax
80103136:	83 e0 06             	and    $0x6,%eax
80103139:	83 f8 02             	cmp    $0x2,%eax
8010313c:	75 0d                	jne    8010314b <iderw+0x39>
    panic("iderw: nothing to do");
8010313e:	83 ec 0c             	sub    $0xc,%esp
80103141:	68 6c 96 10 80       	push   $0x8010966c
80103146:	e8 1b d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010314b:	8b 45 08             	mov    0x8(%ebp),%eax
8010314e:	8b 40 04             	mov    0x4(%eax),%eax
80103151:	85 c0                	test   %eax,%eax
80103153:	74 16                	je     8010316b <iderw+0x59>
80103155:	a1 38 c6 10 80       	mov    0x8010c638,%eax
8010315a:	85 c0                	test   %eax,%eax
8010315c:	75 0d                	jne    8010316b <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010315e:	83 ec 0c             	sub    $0xc,%esp
80103161:	68 81 96 10 80       	push   $0x80109681
80103166:	e8 fb d3 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 00 c6 10 80       	push   $0x8010c600
80103173:	e8 ef 29 00 00       	call   80105b67 <acquire>
80103178:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010317b:	8b 45 08             	mov    0x8(%ebp),%eax
8010317e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80103185:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
8010318c:	eb 0b                	jmp    80103199 <iderw+0x87>
8010318e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103191:	8b 00                	mov    (%eax),%eax
80103193:	83 c0 14             	add    $0x14,%eax
80103196:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010319c:	8b 00                	mov    (%eax),%eax
8010319e:	85 c0                	test   %eax,%eax
801031a0:	75 ec                	jne    8010318e <iderw+0x7c>
    ;
  *pp = b;
801031a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a5:	8b 55 08             	mov    0x8(%ebp),%edx
801031a8:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
801031aa:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801031af:	3b 45 08             	cmp    0x8(%ebp),%eax
801031b2:	75 23                	jne    801031d7 <iderw+0xc5>
     // cprintf("iderw \n");
          idestart(b);
801031b4:	83 ec 0c             	sub    $0xc,%esp
801031b7:	ff 75 08             	pushl  0x8(%ebp)
801031ba:	e8 10 fd ff ff       	call   80102ecf <idestart>
801031bf:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031c2:	eb 13                	jmp    801031d7 <iderw+0xc5>
    sleep(b, &idelock);
801031c4:	83 ec 08             	sub    $0x8,%esp
801031c7:	68 00 c6 10 80       	push   $0x8010c600
801031cc:	ff 75 08             	pushl  0x8(%ebp)
801031cf:	e8 9a 26 00 00       	call   8010586e <sleep>
801031d4:	83 c4 10             	add    $0x10,%esp
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031d7:	8b 45 08             	mov    0x8(%ebp),%eax
801031da:	8b 00                	mov    (%eax),%eax
801031dc:	83 e0 06             	and    $0x6,%eax
801031df:	83 f8 02             	cmp    $0x2,%eax
801031e2:	75 e0                	jne    801031c4 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801031e4:	83 ec 0c             	sub    $0xc,%esp
801031e7:	68 00 c6 10 80       	push   $0x8010c600
801031ec:	e8 dd 29 00 00       	call   80105bce <release>
801031f1:	83 c4 10             	add    $0x10,%esp
}
801031f4:	90                   	nop
801031f5:	c9                   	leave  
801031f6:	c3                   	ret    

801031f7 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801031f7:	55                   	push   %ebp
801031f8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801031fa:	a1 fc 34 11 80       	mov    0x801134fc,%eax
801031ff:	8b 55 08             	mov    0x8(%ebp),%edx
80103202:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103204:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103209:	8b 40 10             	mov    0x10(%eax),%eax
}
8010320c:	5d                   	pop    %ebp
8010320d:	c3                   	ret    

8010320e <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010320e:	55                   	push   %ebp
8010320f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103211:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103216:	8b 55 08             	mov    0x8(%ebp),%edx
80103219:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010321b:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103220:	8b 55 0c             	mov    0xc(%ebp),%edx
80103223:	89 50 10             	mov    %edx,0x10(%eax)
}
80103226:	90                   	nop
80103227:	5d                   	pop    %ebp
80103228:	c3                   	ret    

80103229 <ioapicinit>:

void
ioapicinit(void)
{
80103229:	55                   	push   %ebp
8010322a:	89 e5                	mov    %esp,%ebp
8010322c:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
8010322f:	a1 64 38 11 80       	mov    0x80113864,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	0f 84 a0 00 00 00    	je     801032dc <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010323c:	c7 05 fc 34 11 80 00 	movl   $0xfec00000,0x801134fc
80103243:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103246:	6a 01                	push   $0x1
80103248:	e8 aa ff ff ff       	call   801031f7 <ioapicread>
8010324d:	83 c4 04             	add    $0x4,%esp
80103250:	c1 e8 10             	shr    $0x10,%eax
80103253:	25 ff 00 00 00       	and    $0xff,%eax
80103258:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010325b:	6a 00                	push   $0x0
8010325d:	e8 95 ff ff ff       	call   801031f7 <ioapicread>
80103262:	83 c4 04             	add    $0x4,%esp
80103265:	c1 e8 18             	shr    $0x18,%eax
80103268:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010326b:	0f b6 05 60 38 11 80 	movzbl 0x80113860,%eax
80103272:	0f b6 c0             	movzbl %al,%eax
80103275:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103278:	74 10                	je     8010328a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010327a:	83 ec 0c             	sub    $0xc,%esp
8010327d:	68 a0 96 10 80       	push   $0x801096a0
80103282:	e8 3f d1 ff ff       	call   801003c6 <cprintf>
80103287:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010328a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103291:	eb 3f                	jmp    801032d2 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103296:	83 c0 20             	add    $0x20,%eax
80103299:	0d 00 00 01 00       	or     $0x10000,%eax
8010329e:	89 c2                	mov    %eax,%edx
801032a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032a3:	83 c0 08             	add    $0x8,%eax
801032a6:	01 c0                	add    %eax,%eax
801032a8:	83 ec 08             	sub    $0x8,%esp
801032ab:	52                   	push   %edx
801032ac:	50                   	push   %eax
801032ad:	e8 5c ff ff ff       	call   8010320e <ioapicwrite>
801032b2:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801032b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032b8:	83 c0 08             	add    $0x8,%eax
801032bb:	01 c0                	add    %eax,%eax
801032bd:	83 c0 01             	add    $0x1,%eax
801032c0:	83 ec 08             	sub    $0x8,%esp
801032c3:	6a 00                	push   $0x0
801032c5:	50                   	push   %eax
801032c6:	e8 43 ff ff ff       	call   8010320e <ioapicwrite>
801032cb:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801032d8:	7e b9                	jle    80103293 <ioapicinit+0x6a>
801032da:	eb 01                	jmp    801032dd <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801032dc:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801032dd:	c9                   	leave  
801032de:	c3                   	ret    

801032df <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801032df:	55                   	push   %ebp
801032e0:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801032e2:	a1 64 38 11 80       	mov    0x80113864,%eax
801032e7:	85 c0                	test   %eax,%eax
801032e9:	74 39                	je     80103324 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801032eb:	8b 45 08             	mov    0x8(%ebp),%eax
801032ee:	83 c0 20             	add    $0x20,%eax
801032f1:	89 c2                	mov    %eax,%edx
801032f3:	8b 45 08             	mov    0x8(%ebp),%eax
801032f6:	83 c0 08             	add    $0x8,%eax
801032f9:	01 c0                	add    %eax,%eax
801032fb:	52                   	push   %edx
801032fc:	50                   	push   %eax
801032fd:	e8 0c ff ff ff       	call   8010320e <ioapicwrite>
80103302:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103305:	8b 45 0c             	mov    0xc(%ebp),%eax
80103308:	c1 e0 18             	shl    $0x18,%eax
8010330b:	89 c2                	mov    %eax,%edx
8010330d:	8b 45 08             	mov    0x8(%ebp),%eax
80103310:	83 c0 08             	add    $0x8,%eax
80103313:	01 c0                	add    %eax,%eax
80103315:	83 c0 01             	add    $0x1,%eax
80103318:	52                   	push   %edx
80103319:	50                   	push   %eax
8010331a:	e8 ef fe ff ff       	call   8010320e <ioapicwrite>
8010331f:	83 c4 08             	add    $0x8,%esp
80103322:	eb 01                	jmp    80103325 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103324:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103325:	c9                   	leave  
80103326:	c3                   	ret    

80103327 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103327:	55                   	push   %ebp
80103328:	89 e5                	mov    %esp,%ebp
8010332a:	8b 45 08             	mov    0x8(%ebp),%eax
8010332d:	05 00 00 00 80       	add    $0x80000000,%eax
80103332:	5d                   	pop    %ebp
80103333:	c3                   	ret    

80103334 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103334:	55                   	push   %ebp
80103335:	89 e5                	mov    %esp,%ebp
80103337:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
8010333a:	83 ec 08             	sub    $0x8,%esp
8010333d:	68 d2 96 10 80       	push   $0x801096d2
80103342:	68 00 35 11 80       	push   $0x80113500
80103347:	e8 f9 27 00 00       	call   80105b45 <initlock>
8010334c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010334f:	c7 05 34 35 11 80 00 	movl   $0x0,0x80113534
80103356:	00 00 00 
  freerange(vstart, vend);
80103359:	83 ec 08             	sub    $0x8,%esp
8010335c:	ff 75 0c             	pushl  0xc(%ebp)
8010335f:	ff 75 08             	pushl  0x8(%ebp)
80103362:	e8 2a 00 00 00       	call   80103391 <freerange>
80103367:	83 c4 10             	add    $0x10,%esp
}
8010336a:	90                   	nop
8010336b:	c9                   	leave  
8010336c:	c3                   	ret    

8010336d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010336d:	55                   	push   %ebp
8010336e:	89 e5                	mov    %esp,%ebp
80103370:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80103373:	83 ec 08             	sub    $0x8,%esp
80103376:	ff 75 0c             	pushl  0xc(%ebp)
80103379:	ff 75 08             	pushl  0x8(%ebp)
8010337c:	e8 10 00 00 00       	call   80103391 <freerange>
80103381:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80103384:	c7 05 34 35 11 80 01 	movl   $0x1,0x80113534
8010338b:	00 00 00 
}
8010338e:	90                   	nop
8010338f:	c9                   	leave  
80103390:	c3                   	ret    

80103391 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103391:	55                   	push   %ebp
80103392:	89 e5                	mov    %esp,%ebp
80103394:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103397:	8b 45 08             	mov    0x8(%ebp),%eax
8010339a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010339f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801033a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033a7:	eb 15                	jmp    801033be <freerange+0x2d>
    kfree(p);
801033a9:	83 ec 0c             	sub    $0xc,%esp
801033ac:	ff 75 f4             	pushl  -0xc(%ebp)
801033af:	e8 1a 00 00 00       	call   801033ce <kfree>
801033b4:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033b7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801033be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c1:	05 00 10 00 00       	add    $0x1000,%eax
801033c6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801033c9:	76 de                	jbe    801033a9 <freerange+0x18>
    kfree(p);
}
801033cb:	90                   	nop
801033cc:	c9                   	leave  
801033cd:	c3                   	ret    

801033ce <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801033ce:	55                   	push   %ebp
801033cf:	89 e5                	mov    %esp,%ebp
801033d1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801033d4:	8b 45 08             	mov    0x8(%ebp),%eax
801033d7:	25 ff 0f 00 00       	and    $0xfff,%eax
801033dc:	85 c0                	test   %eax,%eax
801033de:	75 1b                	jne    801033fb <kfree+0x2d>
801033e0:	81 7d 08 5c 66 11 80 	cmpl   $0x8011665c,0x8(%ebp)
801033e7:	72 12                	jb     801033fb <kfree+0x2d>
801033e9:	ff 75 08             	pushl  0x8(%ebp)
801033ec:	e8 36 ff ff ff       	call   80103327 <v2p>
801033f1:	83 c4 04             	add    $0x4,%esp
801033f4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801033f9:	76 0d                	jbe    80103408 <kfree+0x3a>
    panic("kfree");
801033fb:	83 ec 0c             	sub    $0xc,%esp
801033fe:	68 d7 96 10 80       	push   $0x801096d7
80103403:	e8 5e d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103408:	83 ec 04             	sub    $0x4,%esp
8010340b:	68 00 10 00 00       	push   $0x1000
80103410:	6a 01                	push   $0x1
80103412:	ff 75 08             	pushl  0x8(%ebp)
80103415:	e8 b0 29 00 00       	call   80105dca <memset>
8010341a:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010341d:	a1 34 35 11 80       	mov    0x80113534,%eax
80103422:	85 c0                	test   %eax,%eax
80103424:	74 10                	je     80103436 <kfree+0x68>
    acquire(&kmem.lock);
80103426:	83 ec 0c             	sub    $0xc,%esp
80103429:	68 00 35 11 80       	push   $0x80113500
8010342e:	e8 34 27 00 00       	call   80105b67 <acquire>
80103433:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80103436:	8b 45 08             	mov    0x8(%ebp),%eax
80103439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010343c:	8b 15 38 35 11 80    	mov    0x80113538,%edx
80103442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103445:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010344a:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
8010344f:	a1 34 35 11 80       	mov    0x80113534,%eax
80103454:	85 c0                	test   %eax,%eax
80103456:	74 10                	je     80103468 <kfree+0x9a>
    release(&kmem.lock);
80103458:	83 ec 0c             	sub    $0xc,%esp
8010345b:	68 00 35 11 80       	push   $0x80113500
80103460:	e8 69 27 00 00       	call   80105bce <release>
80103465:	83 c4 10             	add    $0x10,%esp
}
80103468:	90                   	nop
80103469:	c9                   	leave  
8010346a:	c3                   	ret    

8010346b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010346b:	55                   	push   %ebp
8010346c:	89 e5                	mov    %esp,%ebp
8010346e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103471:	a1 34 35 11 80       	mov    0x80113534,%eax
80103476:	85 c0                	test   %eax,%eax
80103478:	74 10                	je     8010348a <kalloc+0x1f>
    acquire(&kmem.lock);
8010347a:	83 ec 0c             	sub    $0xc,%esp
8010347d:	68 00 35 11 80       	push   $0x80113500
80103482:	e8 e0 26 00 00       	call   80105b67 <acquire>
80103487:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010348a:	a1 38 35 11 80       	mov    0x80113538,%eax
8010348f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103492:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103496:	74 0a                	je     801034a2 <kalloc+0x37>
    kmem.freelist = r->next;
80103498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010349b:	8b 00                	mov    (%eax),%eax
8010349d:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
801034a2:	a1 34 35 11 80       	mov    0x80113534,%eax
801034a7:	85 c0                	test   %eax,%eax
801034a9:	74 10                	je     801034bb <kalloc+0x50>
    release(&kmem.lock);
801034ab:	83 ec 0c             	sub    $0xc,%esp
801034ae:	68 00 35 11 80       	push   $0x80113500
801034b3:	e8 16 27 00 00       	call   80105bce <release>
801034b8:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801034bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801034be:	c9                   	leave  
801034bf:	c3                   	ret    

801034c0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034c0:	55                   	push   %ebp
801034c1:	89 e5                	mov    %esp,%ebp
801034c3:	83 ec 14             	sub    $0x14,%esp
801034c6:	8b 45 08             	mov    0x8(%ebp),%eax
801034c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034cd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034d1:	89 c2                	mov    %eax,%edx
801034d3:	ec                   	in     (%dx),%al
801034d4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034d7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034db:	c9                   	leave  
801034dc:	c3                   	ret    

801034dd <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801034dd:	55                   	push   %ebp
801034de:	89 e5                	mov    %esp,%ebp
801034e0:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801034e3:	6a 64                	push   $0x64
801034e5:	e8 d6 ff ff ff       	call   801034c0 <inb>
801034ea:	83 c4 04             	add    $0x4,%esp
801034ed:	0f b6 c0             	movzbl %al,%eax
801034f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801034f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f6:	83 e0 01             	and    $0x1,%eax
801034f9:	85 c0                	test   %eax,%eax
801034fb:	75 0a                	jne    80103507 <kbdgetc+0x2a>
    return -1;
801034fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103502:	e9 23 01 00 00       	jmp    8010362a <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103507:	6a 60                	push   $0x60
80103509:	e8 b2 ff ff ff       	call   801034c0 <inb>
8010350e:	83 c4 04             	add    $0x4,%esp
80103511:	0f b6 c0             	movzbl %al,%eax
80103514:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103517:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010351e:	75 17                	jne    80103537 <kbdgetc+0x5a>
    shift |= E0ESC;
80103520:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103525:	83 c8 40             	or     $0x40,%eax
80103528:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010352d:	b8 00 00 00 00       	mov    $0x0,%eax
80103532:	e9 f3 00 00 00       	jmp    8010362a <kbdgetc+0x14d>
  } else if(data & 0x80){
80103537:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010353a:	25 80 00 00 00       	and    $0x80,%eax
8010353f:	85 c0                	test   %eax,%eax
80103541:	74 45                	je     80103588 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103543:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103548:	83 e0 40             	and    $0x40,%eax
8010354b:	85 c0                	test   %eax,%eax
8010354d:	75 08                	jne    80103557 <kbdgetc+0x7a>
8010354f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103552:	83 e0 7f             	and    $0x7f,%eax
80103555:	eb 03                	jmp    8010355a <kbdgetc+0x7d>
80103557:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010355a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010355d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103560:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103565:	0f b6 00             	movzbl (%eax),%eax
80103568:	83 c8 40             	or     $0x40,%eax
8010356b:	0f b6 c0             	movzbl %al,%eax
8010356e:	f7 d0                	not    %eax
80103570:	89 c2                	mov    %eax,%edx
80103572:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103577:	21 d0                	and    %edx,%eax
80103579:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010357e:	b8 00 00 00 00       	mov    $0x0,%eax
80103583:	e9 a2 00 00 00       	jmp    8010362a <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103588:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010358d:	83 e0 40             	and    $0x40,%eax
80103590:	85 c0                	test   %eax,%eax
80103592:	74 14                	je     801035a8 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103594:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010359b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035a0:	83 e0 bf             	and    $0xffffffbf,%eax
801035a3:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
801035a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035ab:	05 40 a0 10 80       	add    $0x8010a040,%eax
801035b0:	0f b6 00             	movzbl (%eax),%eax
801035b3:	0f b6 d0             	movzbl %al,%edx
801035b6:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035bb:	09 d0                	or     %edx,%eax
801035bd:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801035c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035c5:	05 40 a1 10 80       	add    $0x8010a140,%eax
801035ca:	0f b6 00             	movzbl (%eax),%eax
801035cd:	0f b6 d0             	movzbl %al,%edx
801035d0:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035d5:	31 d0                	xor    %edx,%eax
801035d7:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801035dc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035e1:	83 e0 03             	and    $0x3,%eax
801035e4:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
801035eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035ee:	01 d0                	add    %edx,%eax
801035f0:	0f b6 00             	movzbl (%eax),%eax
801035f3:	0f b6 c0             	movzbl %al,%eax
801035f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801035f9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035fe:	83 e0 08             	and    $0x8,%eax
80103601:	85 c0                	test   %eax,%eax
80103603:	74 22                	je     80103627 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103605:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103609:	76 0c                	jbe    80103617 <kbdgetc+0x13a>
8010360b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010360f:	77 06                	ja     80103617 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103611:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103615:	eb 10                	jmp    80103627 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103617:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010361b:	76 0a                	jbe    80103627 <kbdgetc+0x14a>
8010361d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103621:	77 04                	ja     80103627 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103623:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103627:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010362a:	c9                   	leave  
8010362b:	c3                   	ret    

8010362c <kbdintr>:

void
kbdintr(void)
{
8010362c:	55                   	push   %ebp
8010362d:	89 e5                	mov    %esp,%ebp
8010362f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103632:	83 ec 0c             	sub    $0xc,%esp
80103635:	68 dd 34 10 80       	push   $0x801034dd
8010363a:	e8 ba d1 ff ff       	call   801007f9 <consoleintr>
8010363f:	83 c4 10             	add    $0x10,%esp
}
80103642:	90                   	nop
80103643:	c9                   	leave  
80103644:	c3                   	ret    

80103645 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103645:	55                   	push   %ebp
80103646:	89 e5                	mov    %esp,%ebp
80103648:	83 ec 14             	sub    $0x14,%esp
8010364b:	8b 45 08             	mov    0x8(%ebp),%eax
8010364e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103652:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103656:	89 c2                	mov    %eax,%edx
80103658:	ec                   	in     (%dx),%al
80103659:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010365c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103660:	c9                   	leave  
80103661:	c3                   	ret    

80103662 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103662:	55                   	push   %ebp
80103663:	89 e5                	mov    %esp,%ebp
80103665:	83 ec 08             	sub    $0x8,%esp
80103668:	8b 55 08             	mov    0x8(%ebp),%edx
8010366b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010366e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103672:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103675:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103679:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010367d:	ee                   	out    %al,(%dx)
}
8010367e:	90                   	nop
8010367f:	c9                   	leave  
80103680:	c3                   	ret    

80103681 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103681:	55                   	push   %ebp
80103682:	89 e5                	mov    %esp,%ebp
80103684:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103687:	9c                   	pushf  
80103688:	58                   	pop    %eax
80103689:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010368c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010368f:	c9                   	leave  
80103690:	c3                   	ret    

80103691 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103691:	55                   	push   %ebp
80103692:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103694:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103699:	8b 55 08             	mov    0x8(%ebp),%edx
8010369c:	c1 e2 02             	shl    $0x2,%edx
8010369f:	01 c2                	add    %eax,%edx
801036a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a4:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801036a6:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036ab:	83 c0 20             	add    $0x20,%eax
801036ae:	8b 00                	mov    (%eax),%eax
}
801036b0:	90                   	nop
801036b1:	5d                   	pop    %ebp
801036b2:	c3                   	ret    

801036b3 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801036b3:	55                   	push   %ebp
801036b4:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801036b6:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036bb:	85 c0                	test   %eax,%eax
801036bd:	0f 84 0b 01 00 00    	je     801037ce <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801036c3:	68 3f 01 00 00       	push   $0x13f
801036c8:	6a 3c                	push   $0x3c
801036ca:	e8 c2 ff ff ff       	call   80103691 <lapicw>
801036cf:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801036d2:	6a 0b                	push   $0xb
801036d4:	68 f8 00 00 00       	push   $0xf8
801036d9:	e8 b3 ff ff ff       	call   80103691 <lapicw>
801036de:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801036e1:	68 20 00 02 00       	push   $0x20020
801036e6:	68 c8 00 00 00       	push   $0xc8
801036eb:	e8 a1 ff ff ff       	call   80103691 <lapicw>
801036f0:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801036f3:	68 80 96 98 00       	push   $0x989680
801036f8:	68 e0 00 00 00       	push   $0xe0
801036fd:	e8 8f ff ff ff       	call   80103691 <lapicw>
80103702:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103705:	68 00 00 01 00       	push   $0x10000
8010370a:	68 d4 00 00 00       	push   $0xd4
8010370f:	e8 7d ff ff ff       	call   80103691 <lapicw>
80103714:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103717:	68 00 00 01 00       	push   $0x10000
8010371c:	68 d8 00 00 00       	push   $0xd8
80103721:	e8 6b ff ff ff       	call   80103691 <lapicw>
80103726:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103729:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010372e:	83 c0 30             	add    $0x30,%eax
80103731:	8b 00                	mov    (%eax),%eax
80103733:	c1 e8 10             	shr    $0x10,%eax
80103736:	0f b6 c0             	movzbl %al,%eax
80103739:	83 f8 03             	cmp    $0x3,%eax
8010373c:	76 12                	jbe    80103750 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010373e:	68 00 00 01 00       	push   $0x10000
80103743:	68 d0 00 00 00       	push   $0xd0
80103748:	e8 44 ff ff ff       	call   80103691 <lapicw>
8010374d:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103750:	6a 33                	push   $0x33
80103752:	68 dc 00 00 00       	push   $0xdc
80103757:	e8 35 ff ff ff       	call   80103691 <lapicw>
8010375c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010375f:	6a 00                	push   $0x0
80103761:	68 a0 00 00 00       	push   $0xa0
80103766:	e8 26 ff ff ff       	call   80103691 <lapicw>
8010376b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010376e:	6a 00                	push   $0x0
80103770:	68 a0 00 00 00       	push   $0xa0
80103775:	e8 17 ff ff ff       	call   80103691 <lapicw>
8010377a:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010377d:	6a 00                	push   $0x0
8010377f:	6a 2c                	push   $0x2c
80103781:	e8 0b ff ff ff       	call   80103691 <lapicw>
80103786:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103789:	6a 00                	push   $0x0
8010378b:	68 c4 00 00 00       	push   $0xc4
80103790:	e8 fc fe ff ff       	call   80103691 <lapicw>
80103795:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103798:	68 00 85 08 00       	push   $0x88500
8010379d:	68 c0 00 00 00       	push   $0xc0
801037a2:	e8 ea fe ff ff       	call   80103691 <lapicw>
801037a7:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801037aa:	90                   	nop
801037ab:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801037b0:	05 00 03 00 00       	add    $0x300,%eax
801037b5:	8b 00                	mov    (%eax),%eax
801037b7:	25 00 10 00 00       	and    $0x1000,%eax
801037bc:	85 c0                	test   %eax,%eax
801037be:	75 eb                	jne    801037ab <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801037c0:	6a 00                	push   $0x0
801037c2:	6a 20                	push   $0x20
801037c4:	e8 c8 fe ff ff       	call   80103691 <lapicw>
801037c9:	83 c4 08             	add    $0x8,%esp
801037cc:	eb 01                	jmp    801037cf <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801037ce:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801037cf:	c9                   	leave  
801037d0:	c3                   	ret    

801037d1 <cpunum>:

int
cpunum(void)
{
801037d1:	55                   	push   %ebp
801037d2:	89 e5                	mov    %esp,%ebp
801037d4:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801037d7:	e8 a5 fe ff ff       	call   80103681 <readeflags>
801037dc:	25 00 02 00 00       	and    $0x200,%eax
801037e1:	85 c0                	test   %eax,%eax
801037e3:	74 26                	je     8010380b <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801037e5:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801037ea:	8d 50 01             	lea    0x1(%eax),%edx
801037ed:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
801037f3:	85 c0                	test   %eax,%eax
801037f5:	75 14                	jne    8010380b <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801037f7:	8b 45 04             	mov    0x4(%ebp),%eax
801037fa:	83 ec 08             	sub    $0x8,%esp
801037fd:	50                   	push   %eax
801037fe:	68 e0 96 10 80       	push   $0x801096e0
80103803:	e8 be cb ff ff       	call   801003c6 <cprintf>
80103808:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010380b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103810:	85 c0                	test   %eax,%eax
80103812:	74 0f                	je     80103823 <cpunum+0x52>
    return lapic[ID]>>24;
80103814:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103819:	83 c0 20             	add    $0x20,%eax
8010381c:	8b 00                	mov    (%eax),%eax
8010381e:	c1 e8 18             	shr    $0x18,%eax
80103821:	eb 05                	jmp    80103828 <cpunum+0x57>
  return 0;
80103823:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103828:	c9                   	leave  
80103829:	c3                   	ret    

8010382a <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010382a:	55                   	push   %ebp
8010382b:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010382d:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103832:	85 c0                	test   %eax,%eax
80103834:	74 0c                	je     80103842 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103836:	6a 00                	push   $0x0
80103838:	6a 2c                	push   $0x2c
8010383a:	e8 52 fe ff ff       	call   80103691 <lapicw>
8010383f:	83 c4 08             	add    $0x8,%esp
}
80103842:	90                   	nop
80103843:	c9                   	leave  
80103844:	c3                   	ret    

80103845 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103845:	55                   	push   %ebp
80103846:	89 e5                	mov    %esp,%ebp
}
80103848:	90                   	nop
80103849:	5d                   	pop    %ebp
8010384a:	c3                   	ret    

8010384b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010384b:	55                   	push   %ebp
8010384c:	89 e5                	mov    %esp,%ebp
8010384e:	83 ec 14             	sub    $0x14,%esp
80103851:	8b 45 08             	mov    0x8(%ebp),%eax
80103854:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103857:	6a 0f                	push   $0xf
80103859:	6a 70                	push   $0x70
8010385b:	e8 02 fe ff ff       	call   80103662 <outb>
80103860:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103863:	6a 0a                	push   $0xa
80103865:	6a 71                	push   $0x71
80103867:	e8 f6 fd ff ff       	call   80103662 <outb>
8010386c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010386f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103876:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103879:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010387e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103881:	83 c0 02             	add    $0x2,%eax
80103884:	8b 55 0c             	mov    0xc(%ebp),%edx
80103887:	c1 ea 04             	shr    $0x4,%edx
8010388a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010388d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103891:	c1 e0 18             	shl    $0x18,%eax
80103894:	50                   	push   %eax
80103895:	68 c4 00 00 00       	push   $0xc4
8010389a:	e8 f2 fd ff ff       	call   80103691 <lapicw>
8010389f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801038a2:	68 00 c5 00 00       	push   $0xc500
801038a7:	68 c0 00 00 00       	push   $0xc0
801038ac:	e8 e0 fd ff ff       	call   80103691 <lapicw>
801038b1:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801038b4:	68 c8 00 00 00       	push   $0xc8
801038b9:	e8 87 ff ff ff       	call   80103845 <microdelay>
801038be:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801038c1:	68 00 85 00 00       	push   $0x8500
801038c6:	68 c0 00 00 00       	push   $0xc0
801038cb:	e8 c1 fd ff ff       	call   80103691 <lapicw>
801038d0:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038d3:	6a 64                	push   $0x64
801038d5:	e8 6b ff ff ff       	call   80103845 <microdelay>
801038da:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038e4:	eb 3d                	jmp    80103923 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801038e6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038ea:	c1 e0 18             	shl    $0x18,%eax
801038ed:	50                   	push   %eax
801038ee:	68 c4 00 00 00       	push   $0xc4
801038f3:	e8 99 fd ff ff       	call   80103691 <lapicw>
801038f8:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801038fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801038fe:	c1 e8 0c             	shr    $0xc,%eax
80103901:	80 cc 06             	or     $0x6,%ah
80103904:	50                   	push   %eax
80103905:	68 c0 00 00 00       	push   $0xc0
8010390a:	e8 82 fd ff ff       	call   80103691 <lapicw>
8010390f:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103912:	68 c8 00 00 00       	push   $0xc8
80103917:	e8 29 ff ff ff       	call   80103845 <microdelay>
8010391c:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010391f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103923:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103927:	7e bd                	jle    801038e6 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103929:	90                   	nop
8010392a:	c9                   	leave  
8010392b:	c3                   	ret    

8010392c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010392c:	55                   	push   %ebp
8010392d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010392f:	8b 45 08             	mov    0x8(%ebp),%eax
80103932:	0f b6 c0             	movzbl %al,%eax
80103935:	50                   	push   %eax
80103936:	6a 70                	push   $0x70
80103938:	e8 25 fd ff ff       	call   80103662 <outb>
8010393d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103940:	68 c8 00 00 00       	push   $0xc8
80103945:	e8 fb fe ff ff       	call   80103845 <microdelay>
8010394a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010394d:	6a 71                	push   $0x71
8010394f:	e8 f1 fc ff ff       	call   80103645 <inb>
80103954:	83 c4 04             	add    $0x4,%esp
80103957:	0f b6 c0             	movzbl %al,%eax
}
8010395a:	c9                   	leave  
8010395b:	c3                   	ret    

8010395c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010395c:	55                   	push   %ebp
8010395d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010395f:	6a 00                	push   $0x0
80103961:	e8 c6 ff ff ff       	call   8010392c <cmos_read>
80103966:	83 c4 04             	add    $0x4,%esp
80103969:	89 c2                	mov    %eax,%edx
8010396b:	8b 45 08             	mov    0x8(%ebp),%eax
8010396e:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103970:	6a 02                	push   $0x2
80103972:	e8 b5 ff ff ff       	call   8010392c <cmos_read>
80103977:	83 c4 04             	add    $0x4,%esp
8010397a:	89 c2                	mov    %eax,%edx
8010397c:	8b 45 08             	mov    0x8(%ebp),%eax
8010397f:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103982:	6a 04                	push   $0x4
80103984:	e8 a3 ff ff ff       	call   8010392c <cmos_read>
80103989:	83 c4 04             	add    $0x4,%esp
8010398c:	89 c2                	mov    %eax,%edx
8010398e:	8b 45 08             	mov    0x8(%ebp),%eax
80103991:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103994:	6a 07                	push   $0x7
80103996:	e8 91 ff ff ff       	call   8010392c <cmos_read>
8010399b:	83 c4 04             	add    $0x4,%esp
8010399e:	89 c2                	mov    %eax,%edx
801039a0:	8b 45 08             	mov    0x8(%ebp),%eax
801039a3:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801039a6:	6a 08                	push   $0x8
801039a8:	e8 7f ff ff ff       	call   8010392c <cmos_read>
801039ad:	83 c4 04             	add    $0x4,%esp
801039b0:	89 c2                	mov    %eax,%edx
801039b2:	8b 45 08             	mov    0x8(%ebp),%eax
801039b5:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801039b8:	6a 09                	push   $0x9
801039ba:	e8 6d ff ff ff       	call   8010392c <cmos_read>
801039bf:	83 c4 04             	add    $0x4,%esp
801039c2:	89 c2                	mov    %eax,%edx
801039c4:	8b 45 08             	mov    0x8(%ebp),%eax
801039c7:	89 50 14             	mov    %edx,0x14(%eax)
}
801039ca:	90                   	nop
801039cb:	c9                   	leave  
801039cc:	c3                   	ret    

801039cd <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039cd:	55                   	push   %ebp
801039ce:	89 e5                	mov    %esp,%ebp
801039d0:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039d3:	6a 0b                	push   $0xb
801039d5:	e8 52 ff ff ff       	call   8010392c <cmos_read>
801039da:	83 c4 04             	add    $0x4,%esp
801039dd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e3:	83 e0 04             	and    $0x4,%eax
801039e6:	85 c0                	test   %eax,%eax
801039e8:	0f 94 c0             	sete   %al
801039eb:	0f b6 c0             	movzbl %al,%eax
801039ee:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039f4:	50                   	push   %eax
801039f5:	e8 62 ff ff ff       	call   8010395c <fill_rtcdate>
801039fa:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801039fd:	6a 0a                	push   $0xa
801039ff:	e8 28 ff ff ff       	call   8010392c <cmos_read>
80103a04:	83 c4 04             	add    $0x4,%esp
80103a07:	25 80 00 00 00       	and    $0x80,%eax
80103a0c:	85 c0                	test   %eax,%eax
80103a0e:	75 27                	jne    80103a37 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103a10:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a13:	50                   	push   %eax
80103a14:	e8 43 ff ff ff       	call   8010395c <fill_rtcdate>
80103a19:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a1c:	83 ec 04             	sub    $0x4,%esp
80103a1f:	6a 18                	push   $0x18
80103a21:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a24:	50                   	push   %eax
80103a25:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a28:	50                   	push   %eax
80103a29:	e8 03 24 00 00       	call   80105e31 <memcmp>
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	85 c0                	test   %eax,%eax
80103a33:	74 05                	je     80103a3a <cmostime+0x6d>
80103a35:	eb ba                	jmp    801039f1 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a37:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a38:	eb b7                	jmp    801039f1 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103a3a:	90                   	nop
  }

  // convert
  if (bcd) {
80103a3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a3f:	0f 84 b4 00 00 00    	je     80103af9 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a45:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a48:	c1 e8 04             	shr    $0x4,%eax
80103a4b:	89 c2                	mov    %eax,%edx
80103a4d:	89 d0                	mov    %edx,%eax
80103a4f:	c1 e0 02             	shl    $0x2,%eax
80103a52:	01 d0                	add    %edx,%eax
80103a54:	01 c0                	add    %eax,%eax
80103a56:	89 c2                	mov    %eax,%edx
80103a58:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a5b:	83 e0 0f             	and    $0xf,%eax
80103a5e:	01 d0                	add    %edx,%eax
80103a60:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a66:	c1 e8 04             	shr    $0x4,%eax
80103a69:	89 c2                	mov    %eax,%edx
80103a6b:	89 d0                	mov    %edx,%eax
80103a6d:	c1 e0 02             	shl    $0x2,%eax
80103a70:	01 d0                	add    %edx,%eax
80103a72:	01 c0                	add    %eax,%eax
80103a74:	89 c2                	mov    %eax,%edx
80103a76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a79:	83 e0 0f             	and    $0xf,%eax
80103a7c:	01 d0                	add    %edx,%eax
80103a7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a84:	c1 e8 04             	shr    $0x4,%eax
80103a87:	89 c2                	mov    %eax,%edx
80103a89:	89 d0                	mov    %edx,%eax
80103a8b:	c1 e0 02             	shl    $0x2,%eax
80103a8e:	01 d0                	add    %edx,%eax
80103a90:	01 c0                	add    %eax,%eax
80103a92:	89 c2                	mov    %eax,%edx
80103a94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a97:	83 e0 0f             	and    $0xf,%eax
80103a9a:	01 d0                	add    %edx,%eax
80103a9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103aa2:	c1 e8 04             	shr    $0x4,%eax
80103aa5:	89 c2                	mov    %eax,%edx
80103aa7:	89 d0                	mov    %edx,%eax
80103aa9:	c1 e0 02             	shl    $0x2,%eax
80103aac:	01 d0                	add    %edx,%eax
80103aae:	01 c0                	add    %eax,%eax
80103ab0:	89 c2                	mov    %eax,%edx
80103ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ab5:	83 e0 0f             	and    $0xf,%eax
80103ab8:	01 d0                	add    %edx,%eax
80103aba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103abd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ac0:	c1 e8 04             	shr    $0x4,%eax
80103ac3:	89 c2                	mov    %eax,%edx
80103ac5:	89 d0                	mov    %edx,%eax
80103ac7:	c1 e0 02             	shl    $0x2,%eax
80103aca:	01 d0                	add    %edx,%eax
80103acc:	01 c0                	add    %eax,%eax
80103ace:	89 c2                	mov    %eax,%edx
80103ad0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ad3:	83 e0 0f             	and    $0xf,%eax
80103ad6:	01 d0                	add    %edx,%eax
80103ad8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103adb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ade:	c1 e8 04             	shr    $0x4,%eax
80103ae1:	89 c2                	mov    %eax,%edx
80103ae3:	89 d0                	mov    %edx,%eax
80103ae5:	c1 e0 02             	shl    $0x2,%eax
80103ae8:	01 d0                	add    %edx,%eax
80103aea:	01 c0                	add    %eax,%eax
80103aec:	89 c2                	mov    %eax,%edx
80103aee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af1:	83 e0 0f             	and    $0xf,%eax
80103af4:	01 d0                	add    %edx,%eax
80103af6:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103af9:	8b 45 08             	mov    0x8(%ebp),%eax
80103afc:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103aff:	89 10                	mov    %edx,(%eax)
80103b01:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103b04:	89 50 04             	mov    %edx,0x4(%eax)
80103b07:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103b0a:	89 50 08             	mov    %edx,0x8(%eax)
80103b0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b10:	89 50 0c             	mov    %edx,0xc(%eax)
80103b13:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b16:	89 50 10             	mov    %edx,0x10(%eax)
80103b19:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b1c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b22:	8b 40 14             	mov    0x14(%eax),%eax
80103b25:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b31:	90                   	nop
80103b32:	c9                   	leave  
80103b33:	c3                   	ret    

80103b34 <initlog>:
static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
80103b34:	55                   	push   %ebp
80103b35:	89 e5                	mov    %esp,%ebp
80103b37:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103b3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b41:	e9 98 00 00 00       	jmp    80103bde <initlog+0xaa>
     initlock(&logs[i].lock, "log");
80103b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b49:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b4f:	05 40 35 11 80       	add    $0x80113540,%eax
80103b54:	83 ec 08             	sub    $0x8,%esp
80103b57:	68 0c 97 10 80       	push   $0x8010970c
80103b5c:	50                   	push   %eax
80103b5d:	e8 e3 1f 00 00       	call   80105b45 <initlock>
80103b62:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b68:	c1 e0 05             	shl    $0x5,%eax
80103b6b:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b70:	8b 50 0c             	mov    0xc(%eax),%edx
80103b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b76:	c1 e0 05             	shl    $0x5,%eax
80103b79:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b7e:	8b 00                	mov    (%eax),%eax
80103b80:	01 d0                	add    %edx,%eax
80103b82:	89 c2                	mov    %eax,%edx
80103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b87:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b8d:	05 70 35 11 80       	add    $0x80113570,%eax
80103b92:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b98:	c1 e0 05             	shl    $0x5,%eax
80103b9b:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103ba0:	8b 40 0c             	mov    0xc(%eax),%eax
80103ba3:	89 c2                	mov    %eax,%edx
80103ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bae:	05 70 35 11 80       	add    $0x80113570,%eax
80103bb3:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bbf:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc8:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bce:	83 ec 0c             	sub    $0xc,%esp
80103bd1:	50                   	push   %eax
80103bd2:	e8 6a 02 00 00       	call   80103e41 <recover_from_log>
80103bd7:	83 c4 10             	add    $0x10,%esp
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103bda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bde:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103be2:	0f 8e 5e ff ff ff    	jle    80103b46 <initlog+0x12>
  logs[i].size =  sbs[i].nlog;
  logs[i].dev = dev;
  recover_from_log(i);
}
 
}
80103be8:	90                   	nop
80103be9:	c9                   	leave  
80103bea:	c3                   	ret    

80103beb <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103beb:	55                   	push   %ebp
80103bec:	89 e5                	mov    %esp,%ebp
80103bee:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103bf1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bf8:	e9 c0 00 00 00       	jmp    80103cbd <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80103c00:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c06:	05 70 35 11 80       	add    $0x80113570,%eax
80103c0b:	8b 50 04             	mov    0x4(%eax),%edx
80103c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c11:	01 d0                	add    %edx,%eax
80103c13:	83 c0 01             	add    $0x1,%eax
80103c16:	89 c2                	mov    %eax,%edx
80103c18:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c21:	05 80 35 11 80       	add    $0x80113580,%eax
80103c26:	8b 40 04             	mov    0x4(%eax),%eax
80103c29:	83 ec 08             	sub    $0x8,%esp
80103c2c:	52                   	push   %edx
80103c2d:	50                   	push   %eax
80103c2e:	e8 83 c5 ff ff       	call   801001b6 <bread>
80103c33:	83 c4 10             	add    $0x10,%esp
80103c36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c39:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3c:	6b d0 31             	imul   $0x31,%eax,%edx
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	01 d0                	add    %edx,%eax
80103c44:	83 c0 10             	add    $0x10,%eax
80103c47:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c4e:	89 c2                	mov    %eax,%edx
80103c50:	8b 45 08             	mov    0x8(%ebp),%eax
80103c53:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c59:	05 80 35 11 80       	add    $0x80113580,%eax
80103c5e:	8b 40 04             	mov    0x4(%eax),%eax
80103c61:	83 ec 08             	sub    $0x8,%esp
80103c64:	52                   	push   %edx
80103c65:	50                   	push   %eax
80103c66:	e8 4b c5 ff ff       	call   801001b6 <bread>
80103c6b:	83 c4 10             	add    $0x10,%esp
80103c6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c74:	8d 50 18             	lea    0x18(%eax),%edx
80103c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c7a:	83 c0 18             	add    $0x18,%eax
80103c7d:	83 ec 04             	sub    $0x4,%esp
80103c80:	68 00 02 00 00       	push   $0x200
80103c85:	52                   	push   %edx
80103c86:	50                   	push   %eax
80103c87:	e8 fd 21 00 00       	call   80105e89 <memmove>
80103c8c:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103c8f:	83 ec 0c             	sub    $0xc,%esp
80103c92:	ff 75 ec             	pushl  -0x14(%ebp)
80103c95:	e8 55 c5 ff ff       	call   801001ef <bwrite>
80103c9a:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103c9d:	83 ec 0c             	sub    $0xc,%esp
80103ca0:	ff 75 f0             	pushl  -0x10(%ebp)
80103ca3:	e8 86 c5 ff ff       	call   8010022e <brelse>
80103ca8:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103cab:	83 ec 0c             	sub    $0xc,%esp
80103cae:	ff 75 ec             	pushl  -0x14(%ebp)
80103cb1:	e8 78 c5 ff ff       	call   8010022e <brelse>
80103cb6:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103cb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cc6:	05 80 35 11 80       	add    $0x80113580,%eax
80103ccb:	8b 40 08             	mov    0x8(%eax),%eax
80103cce:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cd1:	0f 8f 26 ff ff ff    	jg     80103bfd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103cd7:	90                   	nop
80103cd8:	c9                   	leave  
80103cd9:	c3                   	ret    

80103cda <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103cda:	55                   	push   %ebp
80103cdb:	89 e5                	mov    %esp,%ebp
80103cdd:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ce9:	05 70 35 11 80       	add    $0x80113570,%eax
80103cee:	8b 40 04             	mov    0x4(%eax),%eax
80103cf1:	89 c2                	mov    %eax,%edx
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cfc:	05 80 35 11 80       	add    $0x80113580,%eax
80103d01:	8b 40 04             	mov    0x4(%eax),%eax
80103d04:	83 ec 08             	sub    $0x8,%esp
80103d07:	52                   	push   %edx
80103d08:	50                   	push   %eax
80103d09:	e8 a8 c4 ff ff       	call   801001b6 <bread>
80103d0e:	83 c4 10             	add    $0x10,%esp
80103d11:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d17:	83 c0 18             	add    $0x18,%eax
80103d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d20:	8b 00                	mov    (%eax),%eax
80103d22:	8b 55 08             	mov    0x8(%ebp),%edx
80103d25:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d2b:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d31:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d3b:	eb 23                	jmp    80103d60 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d43:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d47:	8b 55 08             	mov    0x8(%ebp),%edx
80103d4a:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d50:	01 ca                	add    %ecx,%edx
80103d52:	83 c2 10             	add    $0x10,%edx
80103d55:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d60:	8b 45 08             	mov    0x8(%ebp),%eax
80103d63:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d69:	05 80 35 11 80       	add    $0x80113580,%eax
80103d6e:	8b 40 08             	mov    0x8(%eax),%eax
80103d71:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d74:	7f c7                	jg     80103d3d <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	ff 75 f0             	pushl  -0x10(%ebp)
80103d7c:	e8 ad c4 ff ff       	call   8010022e <brelse>
80103d81:	83 c4 10             	add    $0x10,%esp
}
80103d84:	90                   	nop
80103d85:	c9                   	leave  
80103d86:	c3                   	ret    

80103d87 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103d87:	55                   	push   %ebp
80103d88:	89 e5                	mov    %esp,%ebp
80103d8a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d90:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d96:	05 70 35 11 80       	add    $0x80113570,%eax
80103d9b:	8b 40 04             	mov    0x4(%eax),%eax
80103d9e:	89 c2                	mov    %eax,%edx
80103da0:	8b 45 08             	mov    0x8(%ebp),%eax
80103da3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103da9:	05 80 35 11 80       	add    $0x80113580,%eax
80103dae:	8b 40 04             	mov    0x4(%eax),%eax
80103db1:	83 ec 08             	sub    $0x8,%esp
80103db4:	52                   	push   %edx
80103db5:	50                   	push   %eax
80103db6:	e8 fb c3 ff ff       	call   801001b6 <bread>
80103dbb:	83 c4 10             	add    $0x10,%esp
80103dbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc4:	83 c0 18             	add    $0x18,%eax
80103dc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103dca:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dd3:	05 80 35 11 80       	add    $0x80113580,%eax
80103dd8:	8b 50 08             	mov    0x8(%eax),%edx
80103ddb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dde:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103de0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103de7:	eb 23                	jmp    80103e0c <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103de9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dec:	6b d0 31             	imul   $0x31,%eax,%edx
80103def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df2:	01 d0                	add    %edx,%eax
80103df4:	83 c0 10             	add    $0x10,%eax
80103df7:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103dfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e04:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e15:	05 80 35 11 80       	add    $0x80113580,%eax
80103e1a:	8b 40 08             	mov    0x8(%eax),%eax
80103e1d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e20:	7f c7                	jg     80103de9 <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	ff 75 f0             	pushl  -0x10(%ebp)
80103e28:	e8 c2 c3 ff ff       	call   801001ef <bwrite>
80103e2d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e30:	83 ec 0c             	sub    $0xc,%esp
80103e33:	ff 75 f0             	pushl  -0x10(%ebp)
80103e36:	e8 f3 c3 ff ff       	call   8010022e <brelse>
80103e3b:	83 c4 10             	add    $0x10,%esp
}
80103e3e:	90                   	nop
80103e3f:	c9                   	leave  
80103e40:	c3                   	ret    

80103e41 <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e41:	55                   	push   %ebp
80103e42:	89 e5                	mov    %esp,%ebp
80103e44:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e47:	83 ec 0c             	sub    $0xc,%esp
80103e4a:	ff 75 08             	pushl  0x8(%ebp)
80103e4d:	e8 88 fe ff ff       	call   80103cda <read_head>
80103e52:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e55:	83 ec 0c             	sub    $0xc,%esp
80103e58:	ff 75 08             	pushl  0x8(%ebp)
80103e5b:	e8 8b fd ff ff       	call   80103beb <install_trans>
80103e60:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e63:	8b 45 08             	mov    0x8(%ebp),%eax
80103e66:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e6c:	05 80 35 11 80       	add    $0x80113580,%eax
80103e71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	ff 75 08             	pushl  0x8(%ebp)
80103e7e:	e8 04 ff ff ff       	call   80103d87 <write_head>
80103e83:	83 c4 10             	add    $0x10,%esp
}
80103e86:	90                   	nop
80103e87:	c9                   	leave  
80103e88:	c3                   	ret    

80103e89 <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103e89:	55                   	push   %ebp
80103e8a:	89 e5                	mov    %esp,%ebp
80103e8c:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e92:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e98:	05 40 35 11 80       	add    $0x80113540,%eax
80103e9d:	83 ec 0c             	sub    $0xc,%esp
80103ea0:	50                   	push   %eax
80103ea1:	e8 c1 1c 00 00       	call   80105b67 <acquire>
80103ea6:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80103eac:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eb2:	05 80 35 11 80       	add    $0x80113580,%eax
80103eb7:	8b 00                	mov    (%eax),%eax
80103eb9:	85 c0                	test   %eax,%eax
80103ebb:	74 2c                	je     80103ee9 <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ec6:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecf:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ed5:	05 40 35 11 80       	add    $0x80113540,%eax
80103eda:	83 ec 08             	sub    $0x8,%esp
80103edd:	52                   	push   %edx
80103ede:	50                   	push   %eax
80103edf:	e8 8a 19 00 00       	call   8010586e <sleep>
80103ee4:	83 c4 10             	add    $0x10,%esp
80103ee7:	eb c0                	jmp    80103ea9 <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80103eec:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ef2:	05 80 35 11 80       	add    $0x80113580,%eax
80103ef7:	8b 48 08             	mov    0x8(%eax),%ecx
80103efa:	8b 45 08             	mov    0x8(%ebp),%eax
80103efd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f03:	05 70 35 11 80       	add    $0x80113570,%eax
80103f08:	8b 40 0c             	mov    0xc(%eax),%eax
80103f0b:	8d 50 01             	lea    0x1(%eax),%edx
80103f0e:	89 d0                	mov    %edx,%eax
80103f10:	c1 e0 02             	shl    $0x2,%eax
80103f13:	01 d0                	add    %edx,%eax
80103f15:	01 c0                	add    %eax,%eax
80103f17:	01 c8                	add    %ecx,%eax
80103f19:	83 f8 1e             	cmp    $0x1e,%eax
80103f1c:	7e 2f                	jle    80103f4d <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f21:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f27:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f30:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f36:	05 40 35 11 80       	add    $0x80113540,%eax
80103f3b:	83 ec 08             	sub    $0x8,%esp
80103f3e:	52                   	push   %edx
80103f3f:	50                   	push   %eax
80103f40:	e8 29 19 00 00       	call   8010586e <sleep>
80103f45:	83 c4 10             	add    $0x10,%esp
80103f48:	e9 5c ff ff ff       	jmp    80103ea9 <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f50:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f56:	05 70 35 11 80       	add    $0x80113570,%eax
80103f5b:	8b 40 0c             	mov    0xc(%eax),%eax
80103f5e:	8d 50 01             	lea    0x1(%eax),%edx
80103f61:	8b 45 08             	mov    0x8(%ebp),%eax
80103f64:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f6a:	05 70 35 11 80       	add    $0x80113570,%eax
80103f6f:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f7b:	05 40 35 11 80       	add    $0x80113540,%eax
80103f80:	83 ec 0c             	sub    $0xc,%esp
80103f83:	50                   	push   %eax
80103f84:	e8 45 1c 00 00       	call   80105bce <release>
80103f89:	83 c4 10             	add    $0x10,%esp
      break;
80103f8c:	90                   	nop
    }
  }
}
80103f8d:	90                   	nop
80103f8e:	c9                   	leave  
80103f8f:	c3                   	ret    

80103f90 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
80103f93:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fa6:	05 40 35 11 80       	add    $0x80113540,%eax
80103fab:	83 ec 0c             	sub    $0xc,%esp
80103fae:	50                   	push   %eax
80103faf:	e8 b3 1b 00 00       	call   80105b67 <acquire>
80103fb4:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fba:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fc0:	05 70 35 11 80       	add    $0x80113570,%eax
80103fc5:	8b 40 0c             	mov    0xc(%eax),%eax
80103fc8:	8d 50 ff             	lea    -0x1(%eax),%edx
80103fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fce:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fd4:	05 70 35 11 80       	add    $0x80113570,%eax
80103fd9:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80103fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdf:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fe5:	05 80 35 11 80       	add    $0x80113580,%eax
80103fea:	8b 00                	mov    (%eax),%eax
80103fec:	85 c0                	test   %eax,%eax
80103fee:	74 0d                	je     80103ffd <end_op+0x6d>
    panic("log.committing");
80103ff0:	83 ec 0c             	sub    $0xc,%esp
80103ff3:	68 10 97 10 80       	push   $0x80109710
80103ff8:	e8 69 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
80103ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80104000:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104006:	05 70 35 11 80       	add    $0x80113570,%eax
8010400b:	8b 40 0c             	mov    0xc(%eax),%eax
8010400e:	85 c0                	test   %eax,%eax
80104010:	75 1d                	jne    8010402f <end_op+0x9f>
    do_commit = 1;
80104012:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80104019:	8b 45 08             	mov    0x8(%ebp),%eax
8010401c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104022:	05 80 35 11 80       	add    $0x80113580,%eax
80104027:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
8010402d:	eb 1a                	jmp    80104049 <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
8010402f:	8b 45 08             	mov    0x8(%ebp),%eax
80104032:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104038:	05 40 35 11 80       	add    $0x80113540,%eax
8010403d:	83 ec 0c             	sub    $0xc,%esp
80104040:	50                   	push   %eax
80104041:	e8 13 19 00 00       	call   80105959 <wakeup>
80104046:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
80104049:	8b 45 08             	mov    0x8(%ebp),%eax
8010404c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104052:	05 40 35 11 80       	add    $0x80113540,%eax
80104057:	83 ec 0c             	sub    $0xc,%esp
8010405a:	50                   	push   %eax
8010405b:	e8 6e 1b 00 00       	call   80105bce <release>
80104060:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80104063:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104067:	74 70                	je     801040d9 <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80104069:	83 ec 0c             	sub    $0xc,%esp
8010406c:	ff 75 08             	pushl  0x8(%ebp)
8010406f:	e8 57 01 00 00       	call   801041cb <commit>
80104074:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104080:	05 40 35 11 80       	add    $0x80113540,%eax
80104085:	83 ec 0c             	sub    $0xc,%esp
80104088:	50                   	push   %eax
80104089:	e8 d9 1a 00 00       	call   80105b67 <acquire>
8010408e:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
80104091:	8b 45 08             	mov    0x8(%ebp),%eax
80104094:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010409a:	05 80 35 11 80       	add    $0x80113580,%eax
8010409f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
801040a5:	8b 45 08             	mov    0x8(%ebp),%eax
801040a8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040ae:	05 40 35 11 80       	add    $0x80113540,%eax
801040b3:	83 ec 0c             	sub    $0xc,%esp
801040b6:	50                   	push   %eax
801040b7:	e8 9d 18 00 00       	call   80105959 <wakeup>
801040bc:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040bf:	8b 45 08             	mov    0x8(%ebp),%eax
801040c2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040c8:	05 40 35 11 80       	add    $0x80113540,%eax
801040cd:	83 ec 0c             	sub    $0xc,%esp
801040d0:	50                   	push   %eax
801040d1:	e8 f8 1a 00 00       	call   80105bce <release>
801040d6:	83 c4 10             	add    $0x10,%esp
  }
}
801040d9:	90                   	nop
801040da:	c9                   	leave  
801040db:	c3                   	ret    

801040dc <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
801040dc:	55                   	push   %ebp
801040dd:	89 e5                	mov    %esp,%ebp
801040df:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801040e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040e9:	e9 c0 00 00 00       	jmp    801041ae <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
801040ee:	8b 45 08             	mov    0x8(%ebp),%eax
801040f1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040f7:	05 70 35 11 80       	add    $0x80113570,%eax
801040fc:	8b 50 04             	mov    0x4(%eax),%edx
801040ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104102:	01 d0                	add    %edx,%eax
80104104:	83 c0 01             	add    $0x1,%eax
80104107:	89 c2                	mov    %eax,%edx
80104109:	8b 45 08             	mov    0x8(%ebp),%eax
8010410c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104112:	05 80 35 11 80       	add    $0x80113580,%eax
80104117:	8b 40 04             	mov    0x4(%eax),%eax
8010411a:	83 ec 08             	sub    $0x8,%esp
8010411d:	52                   	push   %edx
8010411e:	50                   	push   %eax
8010411f:	e8 92 c0 ff ff       	call   801001b6 <bread>
80104124:	83 c4 10             	add    $0x10,%esp
80104127:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
8010412a:	8b 45 08             	mov    0x8(%ebp),%eax
8010412d:	6b d0 31             	imul   $0x31,%eax,%edx
80104130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104133:	01 d0                	add    %edx,%eax
80104135:	83 c0 10             	add    $0x10,%eax
80104138:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
8010413f:	89 c2                	mov    %eax,%edx
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010414a:	05 80 35 11 80       	add    $0x80113580,%eax
8010414f:	8b 40 04             	mov    0x4(%eax),%eax
80104152:	83 ec 08             	sub    $0x8,%esp
80104155:	52                   	push   %edx
80104156:	50                   	push   %eax
80104157:	e8 5a c0 ff ff       	call   801001b6 <bread>
8010415c:	83 c4 10             	add    $0x10,%esp
8010415f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80104162:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104165:	8d 50 18             	lea    0x18(%eax),%edx
80104168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010416b:	83 c0 18             	add    $0x18,%eax
8010416e:	83 ec 04             	sub    $0x4,%esp
80104171:	68 00 02 00 00       	push   $0x200
80104176:	52                   	push   %edx
80104177:	50                   	push   %eax
80104178:	e8 0c 1d 00 00       	call   80105e89 <memmove>
8010417d:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80104180:	83 ec 0c             	sub    $0xc,%esp
80104183:	ff 75 f0             	pushl  -0x10(%ebp)
80104186:	e8 64 c0 ff ff       	call   801001ef <bwrite>
8010418b:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010418e:	83 ec 0c             	sub    $0xc,%esp
80104191:	ff 75 ec             	pushl  -0x14(%ebp)
80104194:	e8 95 c0 ff ff       	call   8010022e <brelse>
80104199:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010419c:	83 ec 0c             	sub    $0xc,%esp
8010419f:	ff 75 f0             	pushl  -0x10(%ebp)
801041a2:	e8 87 c0 ff ff       	call   8010022e <brelse>
801041a7:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801041aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041b7:	05 80 35 11 80       	add    $0x80113580,%eax
801041bc:	8b 40 08             	mov    0x8(%eax),%eax
801041bf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041c2:	0f 8f 26 ff ff ff    	jg     801040ee <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041c8:	90                   	nop
801041c9:	c9                   	leave  
801041ca:	c3                   	ret    

801041cb <commit>:

static void
commit(uint partitionNumber)
{
801041cb:	55                   	push   %ebp
801041cc:	89 e5                	mov    %esp,%ebp
801041ce:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041da:	05 80 35 11 80       	add    $0x80113580,%eax
801041df:	8b 40 08             	mov    0x8(%eax),%eax
801041e2:	85 c0                	test   %eax,%eax
801041e4:	7e 4d                	jle    80104233 <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
801041e6:	83 ec 0c             	sub    $0xc,%esp
801041e9:	ff 75 08             	pushl  0x8(%ebp)
801041ec:	e8 eb fe ff ff       	call   801040dc <write_log>
801041f1:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	ff 75 08             	pushl  0x8(%ebp)
801041fa:	e8 88 fb ff ff       	call   80103d87 <write_head>
801041ff:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
80104202:	83 ec 0c             	sub    $0xc,%esp
80104205:	ff 75 08             	pushl  0x8(%ebp)
80104208:	e8 de f9 ff ff       	call   80103beb <install_trans>
8010420d:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104210:	8b 45 08             	mov    0x8(%ebp),%eax
80104213:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104219:	05 80 35 11 80       	add    $0x80113580,%eax
8010421e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
80104225:	83 ec 0c             	sub    $0xc,%esp
80104228:	ff 75 08             	pushl  0x8(%ebp)
8010422b:	e8 57 fb ff ff       	call   80103d87 <write_head>
80104230:	83 c4 10             	add    $0x10,%esp
  }
}
80104233:	90                   	nop
80104234:	c9                   	leave  
80104235:	c3                   	ret    

80104236 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
80104236:	55                   	push   %ebp
80104237:	89 e5                	mov    %esp,%ebp
80104239:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
8010423c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010423f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104245:	05 80 35 11 80       	add    $0x80113580,%eax
8010424a:	8b 40 08             	mov    0x8(%eax),%eax
8010424d:	83 f8 1d             	cmp    $0x1d,%eax
80104250:	7f 2a                	jg     8010427c <log_write+0x46>
80104252:	8b 45 0c             	mov    0xc(%ebp),%eax
80104255:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010425b:	05 80 35 11 80       	add    $0x80113580,%eax
80104260:	8b 40 08             	mov    0x8(%eax),%eax
80104263:	8b 55 0c             	mov    0xc(%ebp),%edx
80104266:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
8010426c:	81 c2 70 35 11 80    	add    $0x80113570,%edx
80104272:	8b 52 08             	mov    0x8(%edx),%edx
80104275:	83 ea 01             	sub    $0x1,%edx
80104278:	39 d0                	cmp    %edx,%eax
8010427a:	7c 0d                	jl     80104289 <log_write+0x53>
    panic("too big a transaction");
8010427c:	83 ec 0c             	sub    $0xc,%esp
8010427f:	68 1f 97 10 80       	push   $0x8010971f
80104284:	e8 dd c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
80104289:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104292:	05 70 35 11 80       	add    $0x80113570,%eax
80104297:	8b 40 0c             	mov    0xc(%eax),%eax
8010429a:	85 c0                	test   %eax,%eax
8010429c:	7f 0d                	jg     801042ab <log_write+0x75>
    panic("log_write outside of trans");
8010429e:	83 ec 0c             	sub    $0xc,%esp
801042a1:	68 35 97 10 80       	push   $0x80109735
801042a6:	e8 bb c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
801042ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ae:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042b4:	05 40 35 11 80       	add    $0x80113540,%eax
801042b9:	83 ec 0c             	sub    $0xc,%esp
801042bc:	50                   	push   %eax
801042bd:	e8 a5 18 00 00       	call   80105b67 <acquire>
801042c2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042cc:	eb 25                	jmp    801042f3 <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d1:	6b d0 31             	imul   $0x31,%eax,%edx
801042d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d7:	01 d0                	add    %edx,%eax
801042d9:	83 c0 10             	add    $0x10,%eax
801042dc:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
801042e3:	89 c2                	mov    %eax,%edx
801042e5:	8b 45 08             	mov    0x8(%ebp),%eax
801042e8:	8b 40 08             	mov    0x8(%eax),%eax
801042eb:	39 c2                	cmp    %eax,%edx
801042ed:	74 1c                	je     8010430b <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801042f6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042fc:	05 80 35 11 80       	add    $0x80113580,%eax
80104301:	8b 40 08             	mov    0x8(%eax),%eax
80104304:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104307:	7f c5                	jg     801042ce <log_write+0x98>
80104309:	eb 01                	jmp    8010430c <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
8010430b:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
8010430c:	8b 45 08             	mov    0x8(%ebp),%eax
8010430f:	8b 40 08             	mov    0x8(%eax),%eax
80104312:	89 c1                	mov    %eax,%ecx
80104314:	8b 45 0c             	mov    0xc(%ebp),%eax
80104317:	6b d0 31             	imul   $0x31,%eax,%edx
8010431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431d:	01 d0                	add    %edx,%eax
8010431f:	83 c0 10             	add    $0x10,%eax
80104322:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
80104329:	8b 45 0c             	mov    0xc(%ebp),%eax
8010432c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104332:	05 80 35 11 80       	add    $0x80113580,%eax
80104337:	8b 40 08             	mov    0x8(%eax),%eax
8010433a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010433d:	75 25                	jne    80104364 <log_write+0x12e>
    logs[partitionNumber].lh.n++;
8010433f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104342:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104348:	05 80 35 11 80       	add    $0x80113580,%eax
8010434d:	8b 40 08             	mov    0x8(%eax),%eax
80104350:	8d 50 01             	lea    0x1(%eax),%edx
80104353:	8b 45 0c             	mov    0xc(%ebp),%eax
80104356:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010435c:	05 80 35 11 80       	add    $0x80113580,%eax
80104361:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
80104364:	8b 45 08             	mov    0x8(%ebp),%eax
80104367:	8b 00                	mov    (%eax),%eax
80104369:	83 c8 04             	or     $0x4,%eax
8010436c:	89 c2                	mov    %eax,%edx
8010436e:	8b 45 08             	mov    0x8(%ebp),%eax
80104371:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
80104373:	8b 45 0c             	mov    0xc(%ebp),%eax
80104376:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010437c:	05 40 35 11 80       	add    $0x80113540,%eax
80104381:	83 ec 0c             	sub    $0xc,%esp
80104384:	50                   	push   %eax
80104385:	e8 44 18 00 00       	call   80105bce <release>
8010438a:	83 c4 10             	add    $0x10,%esp
}
8010438d:	90                   	nop
8010438e:	c9                   	leave  
8010438f:	c3                   	ret    

80104390 <v2p>:
80104390:	55                   	push   %ebp
80104391:	89 e5                	mov    %esp,%ebp
80104393:	8b 45 08             	mov    0x8(%ebp),%eax
80104396:	05 00 00 00 80       	add    $0x80000000,%eax
8010439b:	5d                   	pop    %ebp
8010439c:	c3                   	ret    

8010439d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010439d:	55                   	push   %ebp
8010439e:	89 e5                	mov    %esp,%ebp
801043a0:	8b 45 08             	mov    0x8(%ebp),%eax
801043a3:	05 00 00 00 80       	add    $0x80000000,%eax
801043a8:	5d                   	pop    %ebp
801043a9:	c3                   	ret    

801043aa <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801043aa:	55                   	push   %ebp
801043ab:	89 e5                	mov    %esp,%ebp
801043ad:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043b0:	8b 55 08             	mov    0x8(%ebp),%edx
801043b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801043b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043b9:	f0 87 02             	lock xchg %eax,(%edx)
801043bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043c2:	c9                   	leave  
801043c3:	c3                   	ret    

801043c4 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043c4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043c8:	83 e4 f0             	and    $0xfffffff0,%esp
801043cb:	ff 71 fc             	pushl  -0x4(%ecx)
801043ce:	55                   	push   %ebp
801043cf:	89 e5                	mov    %esp,%ebp
801043d1:	51                   	push   %ecx
801043d2:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801043d5:	83 ec 08             	sub    $0x8,%esp
801043d8:	68 00 00 40 80       	push   $0x80400000
801043dd:	68 5c 66 11 80       	push   $0x8011665c
801043e2:	e8 4d ef ff ff       	call   80103334 <kinit1>
801043e7:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801043ea:	e8 7d 48 00 00       	call   80108c6c <kvmalloc>
  mpinit();        // collect info about this machine
801043ef:	e8 26 04 00 00       	call   8010481a <mpinit>
  lapicinit();
801043f4:	e8 ba f2 ff ff       	call   801036b3 <lapicinit>
  seginit();       // set up segments
801043f9:	e8 17 42 00 00       	call   80108615 <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
801043fe:	e8 6d 06 00 00       	call   80104a70 <picinit>
  ioapicinit();    // another interrupt controller
80104403:	e8 21 ee ff ff       	call   80103229 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104408:	e8 0c c7 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
8010440d:	e8 5f 35 00 00       	call   80107971 <uartinit>
  pinit();         // process table
80104412:	e8 56 0b 00 00       	call   80104f6d <pinit>
  tvinit();        // trap vectors
80104417:	e8 1f 31 00 00       	call   8010753b <tvinit>
  binit();         // buffer cache
8010441c:	e8 13 bc ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80104421:	e8 a7 cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
80104426:	e8 f6 e9 ff ff       	call   80102e21 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
8010442b:	a1 64 38 11 80       	mov    0x80113864,%eax
80104430:	85 c0                	test   %eax,%eax
80104432:	75 05                	jne    80104439 <main+0x75>
    timerinit();   // uniprocessor timer
80104434:	e8 5f 30 00 00       	call   80107498 <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80104439:	e8 7f 00 00 00       	call   801044bd <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010443e:	83 ec 08             	sub    $0x8,%esp
80104441:	68 00 00 00 8e       	push   $0x8e000000
80104446:	68 00 00 40 80       	push   $0x80400000
8010444b:	e8 1d ef ff ff       	call   8010336d <kinit2>
80104450:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
80104453:	e8 39 0c 00 00       	call   80105091 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
80104458:	e8 1a 00 00 00       	call   80104477 <mpmain>

8010445d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010445d:	55                   	push   %ebp
8010445e:	89 e5                	mov    %esp,%ebp
80104460:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104463:	e8 1c 48 00 00       	call   80108c84 <switchkvm>
  seginit();
80104468:	e8 a8 41 00 00       	call   80108615 <seginit>
  lapicinit();
8010446d:	e8 41 f2 ff ff       	call   801036b3 <lapicinit>
  mpmain();
80104472:	e8 00 00 00 00       	call   80104477 <mpmain>

80104477 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104477:	55                   	push   %ebp
80104478:	89 e5                	mov    %esp,%ebp
8010447a:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010447d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104483:	0f b6 00             	movzbl (%eax),%eax
80104486:	0f b6 c0             	movzbl %al,%eax
80104489:	83 ec 08             	sub    $0x8,%esp
8010448c:	50                   	push   %eax
8010448d:	68 50 97 10 80       	push   $0x80109750
80104492:	e8 2f bf ff ff       	call   801003c6 <cprintf>
80104497:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010449a:	e8 12 32 00 00       	call   801076b1 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010449f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044a5:	05 a8 00 00 00       	add    $0xa8,%eax
801044aa:	83 ec 08             	sub    $0x8,%esp
801044ad:	6a 01                	push   $0x1
801044af:	50                   	push   %eax
801044b0:	e8 f5 fe ff ff       	call   801043aa <xchg>
801044b5:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044b8:	e8 ab 11 00 00       	call   80105668 <scheduler>

801044bd <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044bd:	55                   	push   %ebp
801044be:	89 e5                	mov    %esp,%ebp
801044c0:	53                   	push   %ebx
801044c1:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044c4:	68 00 70 00 00       	push   $0x7000
801044c9:	e8 cf fe ff ff       	call   8010439d <p2v>
801044ce:	83 c4 04             	add    $0x4,%esp
801044d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801044d4:	b8 8a 00 00 00       	mov    $0x8a,%eax
801044d9:	83 ec 04             	sub    $0x4,%esp
801044dc:	50                   	push   %eax
801044dd:	68 0c c5 10 80       	push   $0x8010c50c
801044e2:	ff 75 f0             	pushl  -0x10(%ebp)
801044e5:	e8 9f 19 00 00       	call   80105e89 <memmove>
801044ea:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801044ed:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
801044f4:	e9 90 00 00 00       	jmp    80104589 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801044f9:	e8 d3 f2 ff ff       	call   801037d1 <cpunum>
801044fe:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104504:	05 80 38 11 80       	add    $0x80113880,%eax
80104509:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010450c:	74 73                	je     80104581 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010450e:	e8 58 ef ff ff       	call   8010346b <kalloc>
80104513:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104519:	83 e8 04             	sub    $0x4,%eax
8010451c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010451f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104525:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010452a:	83 e8 08             	sub    $0x8,%eax
8010452d:	c7 00 5d 44 10 80    	movl   $0x8010445d,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104533:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104536:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104539:	83 ec 0c             	sub    $0xc,%esp
8010453c:	68 00 b0 10 80       	push   $0x8010b000
80104541:	e8 4a fe ff ff       	call   80104390 <v2p>
80104546:	83 c4 10             	add    $0x10,%esp
80104549:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010454b:	83 ec 0c             	sub    $0xc,%esp
8010454e:	ff 75 f0             	pushl  -0x10(%ebp)
80104551:	e8 3a fe ff ff       	call   80104390 <v2p>
80104556:	83 c4 10             	add    $0x10,%esp
80104559:	89 c2                	mov    %eax,%edx
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	0f b6 00             	movzbl (%eax),%eax
80104561:	0f b6 c0             	movzbl %al,%eax
80104564:	83 ec 08             	sub    $0x8,%esp
80104567:	52                   	push   %edx
80104568:	50                   	push   %eax
80104569:	e8 dd f2 ff ff       	call   8010384b <lapicstartap>
8010456e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104571:	90                   	nop
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010457b:	85 c0                	test   %eax,%eax
8010457d:	74 f3                	je     80104572 <startothers+0xb5>
8010457f:	eb 01                	jmp    80104582 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80104581:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80104582:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80104589:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010458e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104594:	05 80 38 11 80       	add    $0x80113880,%eax
80104599:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010459c:	0f 87 57 ff ff ff    	ja     801044f9 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801045a2:	90                   	nop
801045a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045a6:	c9                   	leave  
801045a7:	c3                   	ret    

801045a8 <p2v>:
801045a8:	55                   	push   %ebp
801045a9:	89 e5                	mov    %esp,%ebp
801045ab:	8b 45 08             	mov    0x8(%ebp),%eax
801045ae:	05 00 00 00 80       	add    $0x80000000,%eax
801045b3:	5d                   	pop    %ebp
801045b4:	c3                   	ret    

801045b5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045b5:	55                   	push   %ebp
801045b6:	89 e5                	mov    %esp,%ebp
801045b8:	83 ec 14             	sub    $0x14,%esp
801045bb:	8b 45 08             	mov    0x8(%ebp),%eax
801045be:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045c2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045c6:	89 c2                	mov    %eax,%edx
801045c8:	ec                   	in     (%dx),%al
801045c9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045cc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801045d0:	c9                   	leave  
801045d1:	c3                   	ret    

801045d2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045d2:	55                   	push   %ebp
801045d3:	89 e5                	mov    %esp,%ebp
801045d5:	83 ec 08             	sub    $0x8,%esp
801045d8:	8b 55 08             	mov    0x8(%ebp),%edx
801045db:	8b 45 0c             	mov    0xc(%ebp),%eax
801045de:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045e2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045e5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801045e9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801045ed:	ee                   	out    %al,(%dx)
}
801045ee:	90                   	nop
801045ef:	c9                   	leave  
801045f0:	c3                   	ret    

801045f1 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801045f1:	55                   	push   %ebp
801045f2:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801045f4:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801045f9:	89 c2                	mov    %eax,%edx
801045fb:	b8 80 38 11 80       	mov    $0x80113880,%eax
80104600:	29 c2                	sub    %eax,%edx
80104602:	89 d0                	mov    %edx,%eax
80104604:	c1 f8 02             	sar    $0x2,%eax
80104607:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010460d:	5d                   	pop    %ebp
8010460e:	c3                   	ret    

8010460f <sum>:

static uchar
sum(uchar *addr, int len)
{
8010460f:	55                   	push   %ebp
80104610:	89 e5                	mov    %esp,%ebp
80104612:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104615:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010461c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104623:	eb 15                	jmp    8010463a <sum+0x2b>
    sum += addr[i];
80104625:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104628:	8b 45 08             	mov    0x8(%ebp),%eax
8010462b:	01 d0                	add    %edx,%eax
8010462d:	0f b6 00             	movzbl (%eax),%eax
80104630:	0f b6 c0             	movzbl %al,%eax
80104633:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104636:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010463a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010463d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104640:	7c e3                	jl     80104625 <sum+0x16>
    sum += addr[i];
  return sum;
80104642:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104645:	c9                   	leave  
80104646:	c3                   	ret    

80104647 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104647:	55                   	push   %ebp
80104648:	89 e5                	mov    %esp,%ebp
8010464a:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010464d:	ff 75 08             	pushl  0x8(%ebp)
80104650:	e8 53 ff ff ff       	call   801045a8 <p2v>
80104655:	83 c4 04             	add    $0x4,%esp
80104658:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010465b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010465e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104661:	01 d0                	add    %edx,%eax
80104663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104666:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104669:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010466c:	eb 36                	jmp    801046a4 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010466e:	83 ec 04             	sub    $0x4,%esp
80104671:	6a 04                	push   $0x4
80104673:	68 64 97 10 80       	push   $0x80109764
80104678:	ff 75 f4             	pushl  -0xc(%ebp)
8010467b:	e8 b1 17 00 00       	call   80105e31 <memcmp>
80104680:	83 c4 10             	add    $0x10,%esp
80104683:	85 c0                	test   %eax,%eax
80104685:	75 19                	jne    801046a0 <mpsearch1+0x59>
80104687:	83 ec 08             	sub    $0x8,%esp
8010468a:	6a 10                	push   $0x10
8010468c:	ff 75 f4             	pushl  -0xc(%ebp)
8010468f:	e8 7b ff ff ff       	call   8010460f <sum>
80104694:	83 c4 10             	add    $0x10,%esp
80104697:	84 c0                	test   %al,%al
80104699:	75 05                	jne    801046a0 <mpsearch1+0x59>
      return (struct mp*)p;
8010469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469e:	eb 11                	jmp    801046b1 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801046a0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801046a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046aa:	72 c2                	jb     8010466e <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801046ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046b1:	c9                   	leave  
801046b2:	c3                   	ret    

801046b3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046b3:	55                   	push   %ebp
801046b4:	89 e5                	mov    %esp,%ebp
801046b6:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046b9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c3:	83 c0 0f             	add    $0xf,%eax
801046c6:	0f b6 00             	movzbl (%eax),%eax
801046c9:	0f b6 c0             	movzbl %al,%eax
801046cc:	c1 e0 08             	shl    $0x8,%eax
801046cf:	89 c2                	mov    %eax,%edx
801046d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d4:	83 c0 0e             	add    $0xe,%eax
801046d7:	0f b6 00             	movzbl (%eax),%eax
801046da:	0f b6 c0             	movzbl %al,%eax
801046dd:	09 d0                	or     %edx,%eax
801046df:	c1 e0 04             	shl    $0x4,%eax
801046e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801046e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801046e9:	74 21                	je     8010470c <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801046eb:	83 ec 08             	sub    $0x8,%esp
801046ee:	68 00 04 00 00       	push   $0x400
801046f3:	ff 75 f0             	pushl  -0x10(%ebp)
801046f6:	e8 4c ff ff ff       	call   80104647 <mpsearch1>
801046fb:	83 c4 10             	add    $0x10,%esp
801046fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104701:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104705:	74 51                	je     80104758 <mpsearch+0xa5>
      return mp;
80104707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010470a:	eb 61                	jmp    8010476d <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010470c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470f:	83 c0 14             	add    $0x14,%eax
80104712:	0f b6 00             	movzbl (%eax),%eax
80104715:	0f b6 c0             	movzbl %al,%eax
80104718:	c1 e0 08             	shl    $0x8,%eax
8010471b:	89 c2                	mov    %eax,%edx
8010471d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104720:	83 c0 13             	add    $0x13,%eax
80104723:	0f b6 00             	movzbl (%eax),%eax
80104726:	0f b6 c0             	movzbl %al,%eax
80104729:	09 d0                	or     %edx,%eax
8010472b:	c1 e0 0a             	shl    $0xa,%eax
8010472e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104731:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104734:	2d 00 04 00 00       	sub    $0x400,%eax
80104739:	83 ec 08             	sub    $0x8,%esp
8010473c:	68 00 04 00 00       	push   $0x400
80104741:	50                   	push   %eax
80104742:	e8 00 ff ff ff       	call   80104647 <mpsearch1>
80104747:	83 c4 10             	add    $0x10,%esp
8010474a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010474d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104751:	74 05                	je     80104758 <mpsearch+0xa5>
      return mp;
80104753:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104756:	eb 15                	jmp    8010476d <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104758:	83 ec 08             	sub    $0x8,%esp
8010475b:	68 00 00 01 00       	push   $0x10000
80104760:	68 00 00 0f 00       	push   $0xf0000
80104765:	e8 dd fe ff ff       	call   80104647 <mpsearch1>
8010476a:	83 c4 10             	add    $0x10,%esp
}
8010476d:	c9                   	leave  
8010476e:	c3                   	ret    

8010476f <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010476f:	55                   	push   %ebp
80104770:	89 e5                	mov    %esp,%ebp
80104772:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104775:	e8 39 ff ff ff       	call   801046b3 <mpsearch>
8010477a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010477d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104781:	74 0a                	je     8010478d <mpconfig+0x1e>
80104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104786:	8b 40 04             	mov    0x4(%eax),%eax
80104789:	85 c0                	test   %eax,%eax
8010478b:	75 0a                	jne    80104797 <mpconfig+0x28>
    return 0;
8010478d:	b8 00 00 00 00       	mov    $0x0,%eax
80104792:	e9 81 00 00 00       	jmp    80104818 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479a:	8b 40 04             	mov    0x4(%eax),%eax
8010479d:	83 ec 0c             	sub    $0xc,%esp
801047a0:	50                   	push   %eax
801047a1:	e8 02 fe ff ff       	call   801045a8 <p2v>
801047a6:	83 c4 10             	add    $0x10,%esp
801047a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801047ac:	83 ec 04             	sub    $0x4,%esp
801047af:	6a 04                	push   $0x4
801047b1:	68 69 97 10 80       	push   $0x80109769
801047b6:	ff 75 f0             	pushl  -0x10(%ebp)
801047b9:	e8 73 16 00 00       	call   80105e31 <memcmp>
801047be:	83 c4 10             	add    $0x10,%esp
801047c1:	85 c0                	test   %eax,%eax
801047c3:	74 07                	je     801047cc <mpconfig+0x5d>
    return 0;
801047c5:	b8 00 00 00 00       	mov    $0x0,%eax
801047ca:	eb 4c                	jmp    80104818 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047cf:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047d3:	3c 01                	cmp    $0x1,%al
801047d5:	74 12                	je     801047e9 <mpconfig+0x7a>
801047d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047da:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047de:	3c 04                	cmp    $0x4,%al
801047e0:	74 07                	je     801047e9 <mpconfig+0x7a>
    return 0;
801047e2:	b8 00 00 00 00       	mov    $0x0,%eax
801047e7:	eb 2f                	jmp    80104818 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801047e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ec:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801047f0:	0f b7 c0             	movzwl %ax,%eax
801047f3:	83 ec 08             	sub    $0x8,%esp
801047f6:	50                   	push   %eax
801047f7:	ff 75 f0             	pushl  -0x10(%ebp)
801047fa:	e8 10 fe ff ff       	call   8010460f <sum>
801047ff:	83 c4 10             	add    $0x10,%esp
80104802:	84 c0                	test   %al,%al
80104804:	74 07                	je     8010480d <mpconfig+0x9e>
    return 0;
80104806:	b8 00 00 00 00       	mov    $0x0,%eax
8010480b:	eb 0b                	jmp    80104818 <mpconfig+0xa9>
  *pmp = mp;
8010480d:	8b 45 08             	mov    0x8(%ebp),%eax
80104810:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104813:	89 10                	mov    %edx,(%eax)
  return conf;
80104815:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104818:	c9                   	leave  
80104819:	c3                   	ret    

8010481a <mpinit>:

void
mpinit(void)
{
8010481a:	55                   	push   %ebp
8010481b:	89 e5                	mov    %esp,%ebp
8010481d:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104820:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
80104827:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010482a:	83 ec 0c             	sub    $0xc,%esp
8010482d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104830:	50                   	push   %eax
80104831:	e8 39 ff ff ff       	call   8010476f <mpconfig>
80104836:	83 c4 10             	add    $0x10,%esp
80104839:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010483c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104840:	0f 84 96 01 00 00    	je     801049dc <mpinit+0x1c2>
    return;
  ismp = 1;
80104846:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
8010484d:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104850:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104853:	8b 40 24             	mov    0x24(%eax),%eax
80104856:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010485b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485e:	83 c0 2c             	add    $0x2c,%eax
80104861:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104864:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104867:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010486b:	0f b7 d0             	movzwl %ax,%edx
8010486e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104871:	01 d0                	add    %edx,%eax
80104873:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104876:	e9 f2 00 00 00       	jmp    8010496d <mpinit+0x153>
    switch(*p){
8010487b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487e:	0f b6 00             	movzbl (%eax),%eax
80104881:	0f b6 c0             	movzbl %al,%eax
80104884:	83 f8 04             	cmp    $0x4,%eax
80104887:	0f 87 bc 00 00 00    	ja     80104949 <mpinit+0x12f>
8010488d:	8b 04 85 ac 97 10 80 	mov    -0x7fef6854(,%eax,4),%eax
80104894:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104899:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010489c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010489f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048a3:	0f b6 d0             	movzbl %al,%edx
801048a6:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048ab:	39 c2                	cmp    %eax,%edx
801048ad:	74 2b                	je     801048da <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048b2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048b6:	0f b6 d0             	movzbl %al,%edx
801048b9:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048be:	83 ec 04             	sub    $0x4,%esp
801048c1:	52                   	push   %edx
801048c2:	50                   	push   %eax
801048c3:	68 6e 97 10 80       	push   $0x8010976e
801048c8:	e8 f9 ba ff ff       	call   801003c6 <cprintf>
801048cd:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801048d0:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
801048d7:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801048da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048dd:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801048e1:	0f b6 c0             	movzbl %al,%eax
801048e4:	83 e0 02             	and    $0x2,%eax
801048e7:	85 c0                	test   %eax,%eax
801048e9:	74 15                	je     80104900 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801048eb:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048f0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801048f6:	05 80 38 11 80       	add    $0x80113880,%eax
801048fb:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104900:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104905:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
8010490b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104911:	05 80 38 11 80       	add    $0x80113880,%eax
80104916:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104918:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010491d:	83 c0 01             	add    $0x1,%eax
80104920:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
80104925:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104929:	eb 42                	jmp    8010496d <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104931:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104934:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104938:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
8010493d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104941:	eb 2a                	jmp    8010496d <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104943:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104947:	eb 24                	jmp    8010496d <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494c:	0f b6 00             	movzbl (%eax),%eax
8010494f:	0f b6 c0             	movzbl %al,%eax
80104952:	83 ec 08             	sub    $0x8,%esp
80104955:	50                   	push   %eax
80104956:	68 8c 97 10 80       	push   $0x8010978c
8010495b:	e8 66 ba ff ff       	call   801003c6 <cprintf>
80104960:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104963:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
8010496a:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010496d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104970:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104973:	0f 82 02 ff ff ff    	jb     8010487b <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104979:	a1 64 38 11 80       	mov    0x80113864,%eax
8010497e:	85 c0                	test   %eax,%eax
80104980:	75 1d                	jne    8010499f <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104982:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
80104989:	00 00 00 
    lapic = 0;
8010498c:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
80104993:	00 00 00 
    ioapicid = 0;
80104996:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
8010499d:	eb 3e                	jmp    801049dd <mpinit+0x1c3>
  }

  if(mp->imcrp){
8010499f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801049a6:	84 c0                	test   %al,%al
801049a8:	74 33                	je     801049dd <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801049aa:	83 ec 08             	sub    $0x8,%esp
801049ad:	6a 70                	push   $0x70
801049af:	6a 22                	push   $0x22
801049b1:	e8 1c fc ff ff       	call   801045d2 <outb>
801049b6:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049b9:	83 ec 0c             	sub    $0xc,%esp
801049bc:	6a 23                	push   $0x23
801049be:	e8 f2 fb ff ff       	call   801045b5 <inb>
801049c3:	83 c4 10             	add    $0x10,%esp
801049c6:	83 c8 01             	or     $0x1,%eax
801049c9:	0f b6 c0             	movzbl %al,%eax
801049cc:	83 ec 08             	sub    $0x8,%esp
801049cf:	50                   	push   %eax
801049d0:	6a 23                	push   $0x23
801049d2:	e8 fb fb ff ff       	call   801045d2 <outb>
801049d7:	83 c4 10             	add    $0x10,%esp
801049da:	eb 01                	jmp    801049dd <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801049dc:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801049dd:	c9                   	leave  
801049de:	c3                   	ret    

801049df <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801049df:	55                   	push   %ebp
801049e0:	89 e5                	mov    %esp,%ebp
801049e2:	83 ec 08             	sub    $0x8,%esp
801049e5:	8b 55 08             	mov    0x8(%ebp),%edx
801049e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801049eb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801049ef:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801049f2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801049f6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801049fa:	ee                   	out    %al,(%dx)
}
801049fb:	90                   	nop
801049fc:	c9                   	leave  
801049fd:	c3                   	ret    

801049fe <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801049fe:	55                   	push   %ebp
801049ff:	89 e5                	mov    %esp,%ebp
80104a01:	83 ec 04             	sub    $0x4,%esp
80104a04:	8b 45 08             	mov    0x8(%ebp),%eax
80104a07:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104a0b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a0f:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a15:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a19:	0f b6 c0             	movzbl %al,%eax
80104a1c:	50                   	push   %eax
80104a1d:	6a 21                	push   $0x21
80104a1f:	e8 bb ff ff ff       	call   801049df <outb>
80104a24:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a27:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a2b:	66 c1 e8 08          	shr    $0x8,%ax
80104a2f:	0f b6 c0             	movzbl %al,%eax
80104a32:	50                   	push   %eax
80104a33:	68 a1 00 00 00       	push   $0xa1
80104a38:	e8 a2 ff ff ff       	call   801049df <outb>
80104a3d:	83 c4 08             	add    $0x8,%esp
}
80104a40:	90                   	nop
80104a41:	c9                   	leave  
80104a42:	c3                   	ret    

80104a43 <picenable>:

void
picenable(int irq)
{
80104a43:	55                   	push   %ebp
80104a44:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a46:	8b 45 08             	mov    0x8(%ebp),%eax
80104a49:	ba 01 00 00 00       	mov    $0x1,%edx
80104a4e:	89 c1                	mov    %eax,%ecx
80104a50:	d3 e2                	shl    %cl,%edx
80104a52:	89 d0                	mov    %edx,%eax
80104a54:	f7 d0                	not    %eax
80104a56:	89 c2                	mov    %eax,%edx
80104a58:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a5f:	21 d0                	and    %edx,%eax
80104a61:	0f b7 c0             	movzwl %ax,%eax
80104a64:	50                   	push   %eax
80104a65:	e8 94 ff ff ff       	call   801049fe <picsetmask>
80104a6a:	83 c4 04             	add    $0x4,%esp
}
80104a6d:	90                   	nop
80104a6e:	c9                   	leave  
80104a6f:	c3                   	ret    

80104a70 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104a70:	55                   	push   %ebp
80104a71:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104a73:	68 ff 00 00 00       	push   $0xff
80104a78:	6a 21                	push   $0x21
80104a7a:	e8 60 ff ff ff       	call   801049df <outb>
80104a7f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104a82:	68 ff 00 00 00       	push   $0xff
80104a87:	68 a1 00 00 00       	push   $0xa1
80104a8c:	e8 4e ff ff ff       	call   801049df <outb>
80104a91:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104a94:	6a 11                	push   $0x11
80104a96:	6a 20                	push   $0x20
80104a98:	e8 42 ff ff ff       	call   801049df <outb>
80104a9d:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104aa0:	6a 20                	push   $0x20
80104aa2:	6a 21                	push   $0x21
80104aa4:	e8 36 ff ff ff       	call   801049df <outb>
80104aa9:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104aac:	6a 04                	push   $0x4
80104aae:	6a 21                	push   $0x21
80104ab0:	e8 2a ff ff ff       	call   801049df <outb>
80104ab5:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104ab8:	6a 03                	push   $0x3
80104aba:	6a 21                	push   $0x21
80104abc:	e8 1e ff ff ff       	call   801049df <outb>
80104ac1:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104ac4:	6a 11                	push   $0x11
80104ac6:	68 a0 00 00 00       	push   $0xa0
80104acb:	e8 0f ff ff ff       	call   801049df <outb>
80104ad0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104ad3:	6a 28                	push   $0x28
80104ad5:	68 a1 00 00 00       	push   $0xa1
80104ada:	e8 00 ff ff ff       	call   801049df <outb>
80104adf:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104ae2:	6a 02                	push   $0x2
80104ae4:	68 a1 00 00 00       	push   $0xa1
80104ae9:	e8 f1 fe ff ff       	call   801049df <outb>
80104aee:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104af1:	6a 03                	push   $0x3
80104af3:	68 a1 00 00 00       	push   $0xa1
80104af8:	e8 e2 fe ff ff       	call   801049df <outb>
80104afd:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104b00:	6a 68                	push   $0x68
80104b02:	6a 20                	push   $0x20
80104b04:	e8 d6 fe ff ff       	call   801049df <outb>
80104b09:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104b0c:	6a 0a                	push   $0xa
80104b0e:	6a 20                	push   $0x20
80104b10:	e8 ca fe ff ff       	call   801049df <outb>
80104b15:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b18:	6a 68                	push   $0x68
80104b1a:	68 a0 00 00 00       	push   $0xa0
80104b1f:	e8 bb fe ff ff       	call   801049df <outb>
80104b24:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b27:	6a 0a                	push   $0xa
80104b29:	68 a0 00 00 00       	push   $0xa0
80104b2e:	e8 ac fe ff ff       	call   801049df <outb>
80104b33:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b36:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b3d:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b41:	74 13                	je     80104b56 <picinit+0xe6>
    picsetmask(irqmask);
80104b43:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b4a:	0f b7 c0             	movzwl %ax,%eax
80104b4d:	50                   	push   %eax
80104b4e:	e8 ab fe ff ff       	call   801049fe <picsetmask>
80104b53:	83 c4 04             	add    $0x4,%esp
}
80104b56:	90                   	nop
80104b57:	c9                   	leave  
80104b58:	c3                   	ret    

80104b59 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b59:	55                   	push   %ebp
80104b5a:	89 e5                	mov    %esp,%ebp
80104b5c:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b66:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b69:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b72:	8b 10                	mov    (%eax),%edx
80104b74:	8b 45 08             	mov    0x8(%ebp),%eax
80104b77:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104b79:	e8 6d c4 ff ff       	call   80100feb <filealloc>
80104b7e:	89 c2                	mov    %eax,%edx
80104b80:	8b 45 08             	mov    0x8(%ebp),%eax
80104b83:	89 10                	mov    %edx,(%eax)
80104b85:	8b 45 08             	mov    0x8(%ebp),%eax
80104b88:	8b 00                	mov    (%eax),%eax
80104b8a:	85 c0                	test   %eax,%eax
80104b8c:	0f 84 cb 00 00 00    	je     80104c5d <pipealloc+0x104>
80104b92:	e8 54 c4 ff ff       	call   80100feb <filealloc>
80104b97:	89 c2                	mov    %eax,%edx
80104b99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9c:	89 10                	mov    %edx,(%eax)
80104b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba1:	8b 00                	mov    (%eax),%eax
80104ba3:	85 c0                	test   %eax,%eax
80104ba5:	0f 84 b2 00 00 00    	je     80104c5d <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104bab:	e8 bb e8 ff ff       	call   8010346b <kalloc>
80104bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bb7:	0f 84 9f 00 00 00    	je     80104c5c <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104bc7:	00 00 00 
  p->writeopen = 1;
80104bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104bd4:	00 00 00 
  p->nwrite = 0;
80104bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bda:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104be1:	00 00 00 
  p->nread = 0;
80104be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104bee:	00 00 00 
  initlock(&p->lock, "pipe");
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	83 ec 08             	sub    $0x8,%esp
80104bf7:	68 c0 97 10 80       	push   $0x801097c0
80104bfc:	50                   	push   %eax
80104bfd:	e8 43 0f 00 00       	call   80105b45 <initlock>
80104c02:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104c05:	8b 45 08             	mov    0x8(%ebp),%eax
80104c08:	8b 00                	mov    (%eax),%eax
80104c0a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c10:	8b 45 08             	mov    0x8(%ebp),%eax
80104c13:	8b 00                	mov    (%eax),%eax
80104c15:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c19:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1c:	8b 00                	mov    (%eax),%eax
80104c1e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c22:	8b 45 08             	mov    0x8(%ebp),%eax
80104c25:	8b 00                	mov    (%eax),%eax
80104c27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c2a:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c30:	8b 00                	mov    (%eax),%eax
80104c32:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c38:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3b:	8b 00                	mov    (%eax),%eax
80104c3d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c44:	8b 00                	mov    (%eax),%eax
80104c46:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4d:	8b 00                	mov    (%eax),%eax
80104c4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c52:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c55:	b8 00 00 00 00       	mov    $0x0,%eax
80104c5a:	eb 4e                	jmp    80104caa <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c5c:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c61:	74 0e                	je     80104c71 <pipealloc+0x118>
    kfree((char*)p);
80104c63:	83 ec 0c             	sub    $0xc,%esp
80104c66:	ff 75 f4             	pushl  -0xc(%ebp)
80104c69:	e8 60 e7 ff ff       	call   801033ce <kfree>
80104c6e:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104c71:	8b 45 08             	mov    0x8(%ebp),%eax
80104c74:	8b 00                	mov    (%eax),%eax
80104c76:	85 c0                	test   %eax,%eax
80104c78:	74 11                	je     80104c8b <pipealloc+0x132>
    fileclose(*f0);
80104c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7d:	8b 00                	mov    (%eax),%eax
80104c7f:	83 ec 0c             	sub    $0xc,%esp
80104c82:	50                   	push   %eax
80104c83:	e8 21 c4 ff ff       	call   801010a9 <fileclose>
80104c88:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8e:	8b 00                	mov    (%eax),%eax
80104c90:	85 c0                	test   %eax,%eax
80104c92:	74 11                	je     80104ca5 <pipealloc+0x14c>
    fileclose(*f1);
80104c94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c97:	8b 00                	mov    (%eax),%eax
80104c99:	83 ec 0c             	sub    $0xc,%esp
80104c9c:	50                   	push   %eax
80104c9d:	e8 07 c4 ff ff       	call   801010a9 <fileclose>
80104ca2:	83 c4 10             	add    $0x10,%esp
  return -1;
80104ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104caa:	c9                   	leave  
80104cab:	c3                   	ret    

80104cac <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104cac:	55                   	push   %ebp
80104cad:	89 e5                	mov    %esp,%ebp
80104caf:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb5:	83 ec 0c             	sub    $0xc,%esp
80104cb8:	50                   	push   %eax
80104cb9:	e8 a9 0e 00 00       	call   80105b67 <acquire>
80104cbe:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104cc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104cc5:	74 23                	je     80104cea <pipeclose+0x3e>
    p->writeopen = 0;
80104cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cca:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104cd1:	00 00 00 
    wakeup(&p->nread);
80104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd7:	05 34 02 00 00       	add    $0x234,%eax
80104cdc:	83 ec 0c             	sub    $0xc,%esp
80104cdf:	50                   	push   %eax
80104ce0:	e8 74 0c 00 00       	call   80105959 <wakeup>
80104ce5:	83 c4 10             	add    $0x10,%esp
80104ce8:	eb 21                	jmp    80104d0b <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104cea:	8b 45 08             	mov    0x8(%ebp),%eax
80104ced:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104cf4:	00 00 00 
    wakeup(&p->nwrite);
80104cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfa:	05 38 02 00 00       	add    $0x238,%eax
80104cff:	83 ec 0c             	sub    $0xc,%esp
80104d02:	50                   	push   %eax
80104d03:	e8 51 0c 00 00       	call   80105959 <wakeup>
80104d08:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d14:	85 c0                	test   %eax,%eax
80104d16:	75 2c                	jne    80104d44 <pipeclose+0x98>
80104d18:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d21:	85 c0                	test   %eax,%eax
80104d23:	75 1f                	jne    80104d44 <pipeclose+0x98>
    release(&p->lock);
80104d25:	8b 45 08             	mov    0x8(%ebp),%eax
80104d28:	83 ec 0c             	sub    $0xc,%esp
80104d2b:	50                   	push   %eax
80104d2c:	e8 9d 0e 00 00       	call   80105bce <release>
80104d31:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d34:	83 ec 0c             	sub    $0xc,%esp
80104d37:	ff 75 08             	pushl  0x8(%ebp)
80104d3a:	e8 8f e6 ff ff       	call   801033ce <kfree>
80104d3f:	83 c4 10             	add    $0x10,%esp
80104d42:	eb 0f                	jmp    80104d53 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d44:	8b 45 08             	mov    0x8(%ebp),%eax
80104d47:	83 ec 0c             	sub    $0xc,%esp
80104d4a:	50                   	push   %eax
80104d4b:	e8 7e 0e 00 00       	call   80105bce <release>
80104d50:	83 c4 10             	add    $0x10,%esp
}
80104d53:	90                   	nop
80104d54:	c9                   	leave  
80104d55:	c3                   	ret    

80104d56 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d56:	55                   	push   %ebp
80104d57:	89 e5                	mov    %esp,%ebp
80104d59:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5f:	83 ec 0c             	sub    $0xc,%esp
80104d62:	50                   	push   %eax
80104d63:	e8 ff 0d 00 00       	call   80105b67 <acquire>
80104d68:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d72:	e9 ad 00 00 00       	jmp    80104e24 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104d77:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d80:	85 c0                	test   %eax,%eax
80104d82:	74 0d                	je     80104d91 <pipewrite+0x3b>
80104d84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d8a:	8b 40 24             	mov    0x24(%eax),%eax
80104d8d:	85 c0                	test   %eax,%eax
80104d8f:	74 19                	je     80104daa <pipewrite+0x54>
        release(&p->lock);
80104d91:	8b 45 08             	mov    0x8(%ebp),%eax
80104d94:	83 ec 0c             	sub    $0xc,%esp
80104d97:	50                   	push   %eax
80104d98:	e8 31 0e 00 00       	call   80105bce <release>
80104d9d:	83 c4 10             	add    $0x10,%esp
        return -1;
80104da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104da5:	e9 a8 00 00 00       	jmp    80104e52 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104daa:	8b 45 08             	mov    0x8(%ebp),%eax
80104dad:	05 34 02 00 00       	add    $0x234,%eax
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	50                   	push   %eax
80104db6:	e8 9e 0b 00 00       	call   80105959 <wakeup>
80104dbb:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc1:	8b 55 08             	mov    0x8(%ebp),%edx
80104dc4:	81 c2 38 02 00 00    	add    $0x238,%edx
80104dca:	83 ec 08             	sub    $0x8,%esp
80104dcd:	50                   	push   %eax
80104dce:	52                   	push   %edx
80104dcf:	e8 9a 0a 00 00       	call   8010586e <sleep>
80104dd4:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dda:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104de0:	8b 45 08             	mov    0x8(%ebp),%eax
80104de3:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104de9:	05 00 02 00 00       	add    $0x200,%eax
80104dee:	39 c2                	cmp    %eax,%edx
80104df0:	74 85                	je     80104d77 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104df2:	8b 45 08             	mov    0x8(%ebp),%eax
80104df5:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104dfb:	8d 48 01             	lea    0x1(%eax),%ecx
80104dfe:	8b 55 08             	mov    0x8(%ebp),%edx
80104e01:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104e07:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e0c:	89 c1                	mov    %eax,%ecx
80104e0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e11:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e14:	01 d0                	add    %edx,%eax
80104e16:	0f b6 10             	movzbl (%eax),%edx
80104e19:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e27:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e2a:	7c ab                	jl     80104dd7 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2f:	05 34 02 00 00       	add    $0x234,%eax
80104e34:	83 ec 0c             	sub    $0xc,%esp
80104e37:	50                   	push   %eax
80104e38:	e8 1c 0b 00 00       	call   80105959 <wakeup>
80104e3d:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e40:	8b 45 08             	mov    0x8(%ebp),%eax
80104e43:	83 ec 0c             	sub    $0xc,%esp
80104e46:	50                   	push   %eax
80104e47:	e8 82 0d 00 00       	call   80105bce <release>
80104e4c:	83 c4 10             	add    $0x10,%esp
  return n;
80104e4f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e52:	c9                   	leave  
80104e53:	c3                   	ret    

80104e54 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e54:	55                   	push   %ebp
80104e55:	89 e5                	mov    %esp,%ebp
80104e57:	53                   	push   %ebx
80104e58:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5e:	83 ec 0c             	sub    $0xc,%esp
80104e61:	50                   	push   %eax
80104e62:	e8 00 0d 00 00       	call   80105b67 <acquire>
80104e67:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e6a:	eb 3f                	jmp    80104eab <piperead+0x57>
    if(proc->killed){
80104e6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e72:	8b 40 24             	mov    0x24(%eax),%eax
80104e75:	85 c0                	test   %eax,%eax
80104e77:	74 19                	je     80104e92 <piperead+0x3e>
      release(&p->lock);
80104e79:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7c:	83 ec 0c             	sub    $0xc,%esp
80104e7f:	50                   	push   %eax
80104e80:	e8 49 0d 00 00       	call   80105bce <release>
80104e85:	83 c4 10             	add    $0x10,%esp
      return -1;
80104e88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8d:	e9 bf 00 00 00       	jmp    80104f51 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104e92:	8b 45 08             	mov    0x8(%ebp),%eax
80104e95:	8b 55 08             	mov    0x8(%ebp),%edx
80104e98:	81 c2 34 02 00 00    	add    $0x234,%edx
80104e9e:	83 ec 08             	sub    $0x8,%esp
80104ea1:	50                   	push   %eax
80104ea2:	52                   	push   %edx
80104ea3:	e8 c6 09 00 00       	call   8010586e <sleep>
80104ea8:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104eab:	8b 45 08             	mov    0x8(%ebp),%eax
80104eae:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ebd:	39 c2                	cmp    %eax,%edx
80104ebf:	75 0d                	jne    80104ece <piperead+0x7a>
80104ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104eca:	85 c0                	test   %eax,%eax
80104ecc:	75 9e                	jne    80104e6c <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ece:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ed5:	eb 49                	jmp    80104f20 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eda:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ee9:	39 c2                	cmp    %eax,%edx
80104eeb:	74 3d                	je     80104f2a <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104eed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104eff:	8d 48 01             	lea    0x1(%eax),%ecx
80104f02:	8b 55 08             	mov    0x8(%ebp),%edx
80104f05:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104f0b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f10:	89 c2                	mov    %eax,%edx
80104f12:	8b 45 08             	mov    0x8(%ebp),%eax
80104f15:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f1a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f23:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f26:	7c af                	jl     80104ed7 <piperead+0x83>
80104f28:	eb 01                	jmp    80104f2b <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f2a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2e:	05 38 02 00 00       	add    $0x238,%eax
80104f33:	83 ec 0c             	sub    $0xc,%esp
80104f36:	50                   	push   %eax
80104f37:	e8 1d 0a 00 00       	call   80105959 <wakeup>
80104f3c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f42:	83 ec 0c             	sub    $0xc,%esp
80104f45:	50                   	push   %eax
80104f46:	e8 83 0c 00 00       	call   80105bce <release>
80104f4b:	83 c4 10             	add    $0x10,%esp
  return i;
80104f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f54:	c9                   	leave  
80104f55:	c3                   	ret    

80104f56 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f56:	55                   	push   %ebp
80104f57:	89 e5                	mov    %esp,%ebp
80104f59:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f5c:	9c                   	pushf  
80104f5d:	58                   	pop    %eax
80104f5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f61:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f64:	c9                   	leave  
80104f65:	c3                   	ret    

80104f66 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f66:	55                   	push   %ebp
80104f67:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f69:	fb                   	sti    
}
80104f6a:	90                   	nop
80104f6b:	5d                   	pop    %ebp
80104f6c:	c3                   	ret    

80104f6d <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f6d:	55                   	push   %ebp
80104f6e:	89 e5                	mov    %esp,%ebp
80104f70:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104f73:	83 ec 08             	sub    $0x8,%esp
80104f76:	68 c5 97 10 80       	push   $0x801097c5
80104f7b:	68 80 3e 11 80       	push   $0x80113e80
80104f80:	e8 c0 0b 00 00       	call   80105b45 <initlock>
80104f85:	83 c4 10             	add    $0x10,%esp
}
80104f88:	90                   	nop
80104f89:	c9                   	leave  
80104f8a:	c3                   	ret    

80104f8b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104f8b:	55                   	push   %ebp
80104f8c:	89 e5                	mov    %esp,%ebp
80104f8e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104f91:	83 ec 0c             	sub    $0xc,%esp
80104f94:	68 80 3e 11 80       	push   $0x80113e80
80104f99:	e8 c9 0b 00 00       	call   80105b67 <acquire>
80104f9e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fa1:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104fa8:	eb 0e                	jmp    80104fb8 <allocproc+0x2d>
    if(p->state == UNUSED)
80104faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fad:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb0:	85 c0                	test   %eax,%eax
80104fb2:	74 27                	je     80104fdb <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fb4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fb8:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fbf:	72 e9                	jb     80104faa <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104fc1:	83 ec 0c             	sub    $0xc,%esp
80104fc4:	68 80 3e 11 80       	push   $0x80113e80
80104fc9:	e8 00 0c 00 00       	call   80105bce <release>
80104fce:	83 c4 10             	add    $0x10,%esp
  return 0;
80104fd1:	b8 00 00 00 00       	mov    $0x0,%eax
80104fd6:	e9 b4 00 00 00       	jmp    8010508f <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104fdb:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdf:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104fe6:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104feb:	8d 50 01             	lea    0x1(%eax),%edx
80104fee:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104ff4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ff7:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104ffa:	83 ec 0c             	sub    $0xc,%esp
80104ffd:	68 80 3e 11 80       	push   $0x80113e80
80105002:	e8 c7 0b 00 00       	call   80105bce <release>
80105007:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010500a:	e8 5c e4 ff ff       	call   8010346b <kalloc>
8010500f:	89 c2                	mov    %eax,%edx
80105011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105014:	89 50 08             	mov    %edx,0x8(%eax)
80105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501a:	8b 40 08             	mov    0x8(%eax),%eax
8010501d:	85 c0                	test   %eax,%eax
8010501f:	75 11                	jne    80105032 <allocproc+0xa7>
    p->state = UNUSED;
80105021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105024:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010502b:	b8 00 00 00 00       	mov    $0x0,%eax
80105030:	eb 5d                	jmp    8010508f <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80105032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105035:	8b 40 08             	mov    0x8(%eax),%eax
80105038:	05 00 10 00 00       	add    $0x1000,%eax
8010503d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105040:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80105044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105047:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010504a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010504d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80105051:	ba f5 74 10 80       	mov    $0x801074f5,%edx
80105056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105059:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010505b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010505f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105062:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105065:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80105068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010506e:	83 ec 04             	sub    $0x4,%esp
80105071:	6a 14                	push   $0x14
80105073:	6a 00                	push   $0x0
80105075:	50                   	push   %eax
80105076:	e8 4f 0d 00 00       	call   80105dca <memset>
8010507b:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010507e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105081:	8b 40 1c             	mov    0x1c(%eax),%eax
80105084:	ba 04 58 10 80       	mov    $0x80105804,%edx
80105089:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010508c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010508f:	c9                   	leave  
80105090:	c3                   	ret    

80105091 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80105091:	55                   	push   %ebp
80105092:	89 e5                	mov    %esp,%ebp
80105094:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80105097:	e8 ef fe ff ff       	call   80104f8b <allocproc>
8010509c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010509f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a2:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801050a7:	e8 0e 3b 00 00       	call   80108bba <setupkvm>
801050ac:	89 c2                	mov    %eax,%edx
801050ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b1:	89 50 04             	mov    %edx,0x4(%eax)
801050b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b7:	8b 40 04             	mov    0x4(%eax),%eax
801050ba:	85 c0                	test   %eax,%eax
801050bc:	75 0d                	jne    801050cb <userinit+0x3a>
    panic("userinit: out of memory?");
801050be:	83 ec 0c             	sub    $0xc,%esp
801050c1:	68 cc 97 10 80       	push   $0x801097cc
801050c6:	e8 9b b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050cb:	ba 2c 00 00 00       	mov    $0x2c,%edx
801050d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d3:	8b 40 04             	mov    0x4(%eax),%eax
801050d6:	83 ec 04             	sub    $0x4,%esp
801050d9:	52                   	push   %edx
801050da:	68 e0 c4 10 80       	push   $0x8010c4e0
801050df:	50                   	push   %eax
801050e0:	e8 2f 3d 00 00       	call   80108e14 <inituvm>
801050e5:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801050e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050eb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801050f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f4:	8b 40 18             	mov    0x18(%eax),%eax
801050f7:	83 ec 04             	sub    $0x4,%esp
801050fa:	6a 4c                	push   $0x4c
801050fc:	6a 00                	push   $0x0
801050fe:	50                   	push   %eax
801050ff:	e8 c6 0c 00 00       	call   80105dca <memset>
80105104:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80105107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510a:	8b 40 18             	mov    0x18(%eax),%eax
8010510d:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80105113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105116:	8b 40 18             	mov    0x18(%eax),%eax
80105119:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010511f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105122:	8b 40 18             	mov    0x18(%eax),%eax
80105125:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105128:	8b 52 18             	mov    0x18(%edx),%edx
8010512b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010512f:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105136:	8b 40 18             	mov    0x18(%eax),%eax
80105139:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010513c:	8b 52 18             	mov    0x18(%edx),%edx
8010513f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105143:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80105147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514a:	8b 40 18             	mov    0x18(%eax),%eax
8010514d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80105154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105157:	8b 40 18             	mov    0x18(%eax),%eax
8010515a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80105161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105164:	8b 40 18             	mov    0x18(%eax),%eax
80105167:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010516e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105171:	83 c0 6c             	add    $0x6c,%eax
80105174:	83 ec 04             	sub    $0x4,%esp
80105177:	6a 10                	push   $0x10
80105179:	68 e5 97 10 80       	push   $0x801097e5
8010517e:	50                   	push   %eax
8010517f:	e8 49 0e 00 00       	call   80105fcd <safestrcpy>
80105184:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80105187:	83 ec 0c             	sub    $0xc,%esp
8010518a:	68 ee 97 10 80       	push   $0x801097ee
8010518f:	e8 70 db ff ff       	call   80102d04 <namei>
80105194:	83 c4 10             	add    $0x10,%esp
80105197:	89 c2                	mov    %eax,%edx
80105199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519c:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
8010519f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801051a9:	90                   	nop
801051aa:	c9                   	leave  
801051ab:	c3                   	ret    

801051ac <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801051ac:	55                   	push   %ebp
801051ad:	89 e5                	mov    %esp,%ebp
801051af:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b8:	8b 00                	mov    (%eax),%eax
801051ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051c1:	7e 31                	jle    801051f4 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051c3:	8b 55 08             	mov    0x8(%ebp),%edx
801051c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c9:	01 c2                	add    %eax,%edx
801051cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d1:	8b 40 04             	mov    0x4(%eax),%eax
801051d4:	83 ec 04             	sub    $0x4,%esp
801051d7:	52                   	push   %edx
801051d8:	ff 75 f4             	pushl  -0xc(%ebp)
801051db:	50                   	push   %eax
801051dc:	e8 80 3d 00 00       	call   80108f61 <allocuvm>
801051e1:	83 c4 10             	add    $0x10,%esp
801051e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051eb:	75 3e                	jne    8010522b <growproc+0x7f>
      return -1;
801051ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f2:	eb 59                	jmp    8010524d <growproc+0xa1>
  } else if(n < 0){
801051f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051f8:	79 31                	jns    8010522b <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801051fa:	8b 55 08             	mov    0x8(%ebp),%edx
801051fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105200:	01 c2                	add    %eax,%edx
80105202:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105208:	8b 40 04             	mov    0x4(%eax),%eax
8010520b:	83 ec 04             	sub    $0x4,%esp
8010520e:	52                   	push   %edx
8010520f:	ff 75 f4             	pushl  -0xc(%ebp)
80105212:	50                   	push   %eax
80105213:	e8 12 3e 00 00       	call   8010902a <deallocuvm>
80105218:	83 c4 10             	add    $0x10,%esp
8010521b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010521e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105222:	75 07                	jne    8010522b <growproc+0x7f>
      return -1;
80105224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105229:	eb 22                	jmp    8010524d <growproc+0xa1>
  }
  proc->sz = sz;
8010522b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105231:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105234:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80105236:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010523c:	83 ec 0c             	sub    $0xc,%esp
8010523f:	50                   	push   %eax
80105240:	e8 5c 3a 00 00       	call   80108ca1 <switchuvm>
80105245:	83 c4 10             	add    $0x10,%esp
  return 0;
80105248:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010524d:	c9                   	leave  
8010524e:	c3                   	ret    

8010524f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010524f:	55                   	push   %ebp
80105250:	89 e5                	mov    %esp,%ebp
80105252:	57                   	push   %edi
80105253:	56                   	push   %esi
80105254:	53                   	push   %ebx
80105255:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80105258:	e8 2e fd ff ff       	call   80104f8b <allocproc>
8010525d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105260:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80105264:	75 0a                	jne    80105270 <fork+0x21>
    return -1;
80105266:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010526b:	e9 68 01 00 00       	jmp    801053d8 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80105270:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105276:	8b 10                	mov    (%eax),%edx
80105278:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010527e:	8b 40 04             	mov    0x4(%eax),%eax
80105281:	83 ec 08             	sub    $0x8,%esp
80105284:	52                   	push   %edx
80105285:	50                   	push   %eax
80105286:	e8 3d 3f 00 00       	call   801091c8 <copyuvm>
8010528b:	83 c4 10             	add    $0x10,%esp
8010528e:	89 c2                	mov    %eax,%edx
80105290:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105293:	89 50 04             	mov    %edx,0x4(%eax)
80105296:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105299:	8b 40 04             	mov    0x4(%eax),%eax
8010529c:	85 c0                	test   %eax,%eax
8010529e:	75 30                	jne    801052d0 <fork+0x81>
    kfree(np->kstack);
801052a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052a3:	8b 40 08             	mov    0x8(%eax),%eax
801052a6:	83 ec 0c             	sub    $0xc,%esp
801052a9:	50                   	push   %eax
801052aa:	e8 1f e1 ff ff       	call   801033ce <kfree>
801052af:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052bf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052cb:	e9 08 01 00 00       	jmp    801053d8 <fork+0x189>
  }
  np->sz = proc->sz;
801052d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d6:	8b 10                	mov    (%eax),%edx
801052d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052db:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801052dd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052e7:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801052ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052ed:	8b 50 18             	mov    0x18(%eax),%edx
801052f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f6:	8b 40 18             	mov    0x18(%eax),%eax
801052f9:	89 c3                	mov    %eax,%ebx
801052fb:	b8 13 00 00 00       	mov    $0x13,%eax
80105300:	89 d7                	mov    %edx,%edi
80105302:	89 de                	mov    %ebx,%esi
80105304:	89 c1                	mov    %eax,%ecx
80105306:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105308:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010530b:	8b 40 18             	mov    0x18(%eax),%eax
8010530e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105315:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010531c:	eb 43                	jmp    80105361 <fork+0x112>
    if(proc->ofile[i])
8010531e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105324:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105327:	83 c2 08             	add    $0x8,%edx
8010532a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010532e:	85 c0                	test   %eax,%eax
80105330:	74 2b                	je     8010535d <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80105332:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010533b:	83 c2 08             	add    $0x8,%edx
8010533e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105342:	83 ec 0c             	sub    $0xc,%esp
80105345:	50                   	push   %eax
80105346:	e8 0d bd ff ff       	call   80101058 <filedup>
8010534b:	83 c4 10             	add    $0x10,%esp
8010534e:	89 c1                	mov    %eax,%ecx
80105350:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105353:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105356:	83 c2 08             	add    $0x8,%edx
80105359:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010535d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105361:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105365:	7e b7                	jle    8010531e <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105367:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010536d:	8b 40 68             	mov    0x68(%eax),%eax
80105370:	83 ec 0c             	sub    $0xc,%esp
80105373:	50                   	push   %eax
80105374:	e8 2f cb ff ff       	call   80101ea8 <idup>
80105379:	83 c4 10             	add    $0x10,%esp
8010537c:	89 c2                	mov    %eax,%edx
8010537e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105381:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80105384:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010538d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105390:	83 c0 6c             	add    $0x6c,%eax
80105393:	83 ec 04             	sub    $0x4,%esp
80105396:	6a 10                	push   $0x10
80105398:	52                   	push   %edx
80105399:	50                   	push   %eax
8010539a:	e8 2e 0c 00 00       	call   80105fcd <safestrcpy>
8010539f:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053a5:	8b 40 10             	mov    0x10(%eax),%eax
801053a8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053ab:	83 ec 0c             	sub    $0xc,%esp
801053ae:	68 80 3e 11 80       	push   $0x80113e80
801053b3:	e8 af 07 00 00       	call   80105b67 <acquire>
801053b8:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053be:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053c5:	83 ec 0c             	sub    $0xc,%esp
801053c8:	68 80 3e 11 80       	push   $0x80113e80
801053cd:	e8 fc 07 00 00       	call   80105bce <release>
801053d2:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801053d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801053d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053db:	5b                   	pop    %ebx
801053dc:	5e                   	pop    %esi
801053dd:	5f                   	pop    %edi
801053de:	5d                   	pop    %ebp
801053df:	c3                   	ret    

801053e0 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801053e0:	55                   	push   %ebp
801053e1:	89 e5                	mov    %esp,%ebp
801053e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801053e6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053ed:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801053f2:	39 c2                	cmp    %eax,%edx
801053f4:	75 0d                	jne    80105403 <exit+0x23>
    panic("init exiting");
801053f6:	83 ec 0c             	sub    $0xc,%esp
801053f9:	68 f0 97 10 80       	push   $0x801097f0
801053fe:	e8 63 b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105403:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010540a:	eb 48                	jmp    80105454 <exit+0x74>
    if(proc->ofile[fd]){
8010540c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105412:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105415:	83 c2 08             	add    $0x8,%edx
80105418:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010541c:	85 c0                	test   %eax,%eax
8010541e:	74 30                	je     80105450 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105420:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105426:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105429:	83 c2 08             	add    $0x8,%edx
8010542c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105430:	83 ec 0c             	sub    $0xc,%esp
80105433:	50                   	push   %eax
80105434:	e8 70 bc ff ff       	call   801010a9 <fileclose>
80105439:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010543c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105442:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105445:	83 c2 08             	add    $0x8,%edx
80105448:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010544f:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105450:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105454:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105458:	7e b2                	jle    8010540c <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
8010545a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105460:	8b 40 68             	mov    0x68(%eax),%eax
80105463:	8b 40 50             	mov    0x50(%eax),%eax
80105466:	8b 40 14             	mov    0x14(%eax),%eax
80105469:	83 ec 0c             	sub    $0xc,%esp
8010546c:	50                   	push   %eax
8010546d:	e8 17 ea ff ff       	call   80103e89 <begin_op>
80105472:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80105475:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547b:	8b 40 68             	mov    0x68(%eax),%eax
8010547e:	83 ec 0c             	sub    $0xc,%esp
80105481:	50                   	push   %eax
80105482:	e8 6e cc ff ff       	call   801020f5 <iput>
80105487:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
8010548a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105490:	8b 40 68             	mov    0x68(%eax),%eax
80105493:	8b 40 50             	mov    0x50(%eax),%eax
80105496:	8b 40 14             	mov    0x14(%eax),%eax
80105499:	83 ec 0c             	sub    $0xc,%esp
8010549c:	50                   	push   %eax
8010549d:	e8 ee ea ff ff       	call   80103f90 <end_op>
801054a2:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
801054a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ab:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054b2:	83 ec 0c             	sub    $0xc,%esp
801054b5:	68 80 3e 11 80       	push   $0x80113e80
801054ba:	e8 a8 06 00 00       	call   80105b67 <acquire>
801054bf:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c8:	8b 40 14             	mov    0x14(%eax),%eax
801054cb:	83 ec 0c             	sub    $0xc,%esp
801054ce:	50                   	push   %eax
801054cf:	e8 46 04 00 00       	call   8010591a <wakeup1>
801054d4:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054d7:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801054de:	eb 3c                	jmp    8010551c <exit+0x13c>
    if(p->parent == proc){
801054e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e3:	8b 50 14             	mov    0x14(%eax),%edx
801054e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ec:	39 c2                	cmp    %eax,%edx
801054ee:	75 28                	jne    80105518 <exit+0x138>
      p->parent = initproc;
801054f0:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801054fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ff:	8b 40 0c             	mov    0xc(%eax),%eax
80105502:	83 f8 05             	cmp    $0x5,%eax
80105505:	75 11                	jne    80105518 <exit+0x138>
        wakeup1(initproc);
80105507:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010550c:	83 ec 0c             	sub    $0xc,%esp
8010550f:	50                   	push   %eax
80105510:	e8 05 04 00 00       	call   8010591a <wakeup1>
80105515:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105518:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010551c:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105523:	72 bb                	jb     801054e0 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105525:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105532:	e8 d6 01 00 00       	call   8010570d <sched>
  panic("zombie exit");
80105537:	83 ec 0c             	sub    $0xc,%esp
8010553a:	68 fd 97 10 80       	push   $0x801097fd
8010553f:	e8 22 b0 ff ff       	call   80100566 <panic>

80105544 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105544:	55                   	push   %ebp
80105545:	89 e5                	mov    %esp,%ebp
80105547:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010554a:	83 ec 0c             	sub    $0xc,%esp
8010554d:	68 80 3e 11 80       	push   $0x80113e80
80105552:	e8 10 06 00 00       	call   80105b67 <acquire>
80105557:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010555a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105561:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105568:	e9 a6 00 00 00       	jmp    80105613 <wait+0xcf>
      if(p->parent != proc)
8010556d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105570:	8b 50 14             	mov    0x14(%eax),%edx
80105573:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105579:	39 c2                	cmp    %eax,%edx
8010557b:	0f 85 8d 00 00 00    	jne    8010560e <wait+0xca>
        continue;
      havekids = 1;
80105581:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558b:	8b 40 0c             	mov    0xc(%eax),%eax
8010558e:	83 f8 05             	cmp    $0x5,%eax
80105591:	75 7c                	jne    8010560f <wait+0xcb>
        // Found one.
        pid = p->pid;
80105593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105596:	8b 40 10             	mov    0x10(%eax),%eax
80105599:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010559c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559f:	8b 40 08             	mov    0x8(%eax),%eax
801055a2:	83 ec 0c             	sub    $0xc,%esp
801055a5:	50                   	push   %eax
801055a6:	e8 23 de ff ff       	call   801033ce <kfree>
801055ab:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bb:	8b 40 04             	mov    0x4(%eax),%eax
801055be:	83 ec 0c             	sub    $0xc,%esp
801055c1:	50                   	push   %eax
801055c2:	e8 20 3b 00 00       	call   801090e7 <freevm>
801055c7:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801055d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801055de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801055e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055eb:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801055ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801055f9:	83 ec 0c             	sub    $0xc,%esp
801055fc:	68 80 3e 11 80       	push   $0x80113e80
80105601:	e8 c8 05 00 00       	call   80105bce <release>
80105606:	83 c4 10             	add    $0x10,%esp
        return pid;
80105609:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010560c:	eb 58                	jmp    80105666 <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010560e:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010560f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105613:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010561a:	0f 82 4d ff ff ff    	jb     8010556d <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105620:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105624:	74 0d                	je     80105633 <wait+0xef>
80105626:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010562c:	8b 40 24             	mov    0x24(%eax),%eax
8010562f:	85 c0                	test   %eax,%eax
80105631:	74 17                	je     8010564a <wait+0x106>
      release(&ptable.lock);
80105633:	83 ec 0c             	sub    $0xc,%esp
80105636:	68 80 3e 11 80       	push   $0x80113e80
8010563b:	e8 8e 05 00 00       	call   80105bce <release>
80105640:	83 c4 10             	add    $0x10,%esp
      return -1;
80105643:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105648:	eb 1c                	jmp    80105666 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010564a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105650:	83 ec 08             	sub    $0x8,%esp
80105653:	68 80 3e 11 80       	push   $0x80113e80
80105658:	50                   	push   %eax
80105659:	e8 10 02 00 00       	call   8010586e <sleep>
8010565e:	83 c4 10             	add    $0x10,%esp
  }
80105661:	e9 f4 fe ff ff       	jmp    8010555a <wait+0x16>
}
80105666:	c9                   	leave  
80105667:	c3                   	ret    

80105668 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105668:	55                   	push   %ebp
80105669:	89 e5                	mov    %esp,%ebp
8010566b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010566e:	e8 f3 f8 ff ff       	call   80104f66 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105673:	83 ec 0c             	sub    $0xc,%esp
80105676:	68 80 3e 11 80       	push   $0x80113e80
8010567b:	e8 e7 04 00 00       	call   80105b67 <acquire>
80105680:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105683:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
8010568a:	eb 63                	jmp    801056ef <scheduler+0x87>
      if(p->state != RUNNABLE)
8010568c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568f:	8b 40 0c             	mov    0xc(%eax),%eax
80105692:	83 f8 03             	cmp    $0x3,%eax
80105695:	75 53                	jne    801056ea <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569a:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056a0:	83 ec 0c             	sub    $0xc,%esp
801056a3:	ff 75 f4             	pushl  -0xc(%ebp)
801056a6:	e8 f6 35 00 00       	call   80108ca1 <switchuvm>
801056ab:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056be:	8b 40 1c             	mov    0x1c(%eax),%eax
801056c1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056c8:	83 c2 04             	add    $0x4,%edx
801056cb:	83 ec 08             	sub    $0x8,%esp
801056ce:	50                   	push   %eax
801056cf:	52                   	push   %edx
801056d0:	e8 69 09 00 00       	call   8010603e <swtch>
801056d5:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801056d8:	e8 a7 35 00 00       	call   80108c84 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801056dd:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801056e4:	00 00 00 00 
801056e8:	eb 01                	jmp    801056eb <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801056ea:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056eb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801056ef:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801056f6:	72 94                	jb     8010568c <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801056f8:	83 ec 0c             	sub    $0xc,%esp
801056fb:	68 80 3e 11 80       	push   $0x80113e80
80105700:	e8 c9 04 00 00       	call   80105bce <release>
80105705:	83 c4 10             	add    $0x10,%esp

  }
80105708:	e9 61 ff ff ff       	jmp    8010566e <scheduler+0x6>

8010570d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010570d:	55                   	push   %ebp
8010570e:	89 e5                	mov    %esp,%ebp
80105710:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105713:	83 ec 0c             	sub    $0xc,%esp
80105716:	68 80 3e 11 80       	push   $0x80113e80
8010571b:	e8 7a 05 00 00       	call   80105c9a <holding>
80105720:	83 c4 10             	add    $0x10,%esp
80105723:	85 c0                	test   %eax,%eax
80105725:	75 0d                	jne    80105734 <sched+0x27>
    panic("sched ptable.lock");
80105727:	83 ec 0c             	sub    $0xc,%esp
8010572a:	68 09 98 10 80       	push   $0x80109809
8010572f:	e8 32 ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105734:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010573a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105740:	83 f8 01             	cmp    $0x1,%eax
80105743:	74 0d                	je     80105752 <sched+0x45>
   panic("sched locks");
80105745:	83 ec 0c             	sub    $0xc,%esp
80105748:	68 1b 98 10 80       	push   $0x8010981b
8010574d:	e8 14 ae ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105752:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105758:	8b 40 0c             	mov    0xc(%eax),%eax
8010575b:	83 f8 04             	cmp    $0x4,%eax
8010575e:	75 0d                	jne    8010576d <sched+0x60>
    panic("sched running");
80105760:	83 ec 0c             	sub    $0xc,%esp
80105763:	68 27 98 10 80       	push   $0x80109827
80105768:	e8 f9 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010576d:	e8 e4 f7 ff ff       	call   80104f56 <readeflags>
80105772:	25 00 02 00 00       	and    $0x200,%eax
80105777:	85 c0                	test   %eax,%eax
80105779:	74 0d                	je     80105788 <sched+0x7b>
    panic("sched interruptible");
8010577b:	83 ec 0c             	sub    $0xc,%esp
8010577e:	68 35 98 10 80       	push   $0x80109835
80105783:	e8 de ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105788:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010578e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105794:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105797:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010579d:	8b 40 04             	mov    0x4(%eax),%eax
801057a0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057a7:	83 c2 1c             	add    $0x1c,%edx
801057aa:	83 ec 08             	sub    $0x8,%esp
801057ad:	50                   	push   %eax
801057ae:	52                   	push   %edx
801057af:	e8 8a 08 00 00       	call   8010603e <swtch>
801057b4:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057c6:	90                   	nop
801057c7:	c9                   	leave  
801057c8:	c3                   	ret    

801057c9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057c9:	55                   	push   %ebp
801057ca:	89 e5                	mov    %esp,%ebp
801057cc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057cf:	83 ec 0c             	sub    $0xc,%esp
801057d2:	68 80 3e 11 80       	push   $0x80113e80
801057d7:	e8 8b 03 00 00       	call   80105b67 <acquire>
801057dc:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801057df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801057ec:	e8 1c ff ff ff       	call   8010570d <sched>
  release(&ptable.lock);
801057f1:	83 ec 0c             	sub    $0xc,%esp
801057f4:	68 80 3e 11 80       	push   $0x80113e80
801057f9:	e8 d0 03 00 00       	call   80105bce <release>
801057fe:	83 c4 10             	add    $0x10,%esp
}
80105801:	90                   	nop
80105802:	c9                   	leave  
80105803:	c3                   	ret    

80105804 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105804:	55                   	push   %ebp
80105805:	89 e5                	mov    %esp,%ebp
80105807:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010580a:	83 ec 0c             	sub    $0xc,%esp
8010580d:	68 80 3e 11 80       	push   $0x80113e80
80105812:	e8 b7 03 00 00       	call   80105bce <release>
80105817:	83 c4 10             	add    $0x10,%esp


  if (first) {
8010581a:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010581f:	85 c0                	test   %eax,%eax
80105821:	74 48                	je     8010586b <forkret+0x67>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105823:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
8010582a:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
8010582d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105833:	0f b6 00             	movzbl (%eax),%eax
80105836:	0f b6 c0             	movzbl %al,%eax
80105839:	83 ec 08             	sub    $0x8,%esp
8010583c:	50                   	push   %eax
8010583d:	68 49 98 10 80       	push   $0x80109849
80105842:	e8 7f ab ff ff       	call   801003c6 <cprintf>
80105847:	83 c4 10             	add    $0x10,%esp
iinit(proc,ROOTDEV);
8010584a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105850:	83 ec 08             	sub    $0x8,%esp
80105853:	6a 00                	push   $0x0
80105855:	50                   	push   %eax
80105856:	e8 d7 c1 ff ff       	call   80101a32 <iinit>
8010585b:	83 c4 10             	add    $0x10,%esp
    // iinitDone=1;
   // cprintf("boot from after iinit is %d \n",bootfrom);
    initlog(ROOTDEV);
8010585e:	83 ec 0c             	sub    $0xc,%esp
80105861:	6a 00                	push   $0x0
80105863:	e8 cc e2 ff ff       	call   80103b34 <initlog>
80105868:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
8010586b:	90                   	nop
8010586c:	c9                   	leave  
8010586d:	c3                   	ret    

8010586e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010586e:	55                   	push   %ebp
8010586f:	89 e5                	mov    %esp,%ebp
80105871:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105874:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010587a:	85 c0                	test   %eax,%eax
8010587c:	75 0d                	jne    8010588b <sleep+0x1d>
    panic("sleep");
8010587e:	83 ec 0c             	sub    $0xc,%esp
80105881:	68 58 98 10 80       	push   $0x80109858
80105886:	e8 db ac ff ff       	call   80100566 <panic>

  if(lk == 0)
8010588b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010588f:	75 0d                	jne    8010589e <sleep+0x30>
    panic("sleep without lk");
80105891:	83 ec 0c             	sub    $0xc,%esp
80105894:	68 5e 98 10 80       	push   $0x8010985e
80105899:	e8 c8 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010589e:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058a5:	74 1e                	je     801058c5 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058a7:	83 ec 0c             	sub    $0xc,%esp
801058aa:	68 80 3e 11 80       	push   $0x80113e80
801058af:	e8 b3 02 00 00       	call   80105b67 <acquire>
801058b4:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058b7:	83 ec 0c             	sub    $0xc,%esp
801058ba:	ff 75 0c             	pushl  0xc(%ebp)
801058bd:	e8 0c 03 00 00       	call   80105bce <release>
801058c2:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058cb:	8b 55 08             	mov    0x8(%ebp),%edx
801058ce:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801058de:	e8 2a fe ff ff       	call   8010570d <sched>

  // Tidy up.
  proc->chan = 0;
801058e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801058f0:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058f7:	74 1e                	je     80105917 <sleep+0xa9>
    release(&ptable.lock);
801058f9:	83 ec 0c             	sub    $0xc,%esp
801058fc:	68 80 3e 11 80       	push   $0x80113e80
80105901:	e8 c8 02 00 00       	call   80105bce <release>
80105906:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105909:	83 ec 0c             	sub    $0xc,%esp
8010590c:	ff 75 0c             	pushl  0xc(%ebp)
8010590f:	e8 53 02 00 00       	call   80105b67 <acquire>
80105914:	83 c4 10             	add    $0x10,%esp
  }
}
80105917:	90                   	nop
80105918:	c9                   	leave  
80105919:	c3                   	ret    

8010591a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010591a:	55                   	push   %ebp
8010591b:	89 e5                	mov    %esp,%ebp
8010591d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105920:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105927:	eb 24                	jmp    8010594d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105929:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010592c:	8b 40 0c             	mov    0xc(%eax),%eax
8010592f:	83 f8 02             	cmp    $0x2,%eax
80105932:	75 15                	jne    80105949 <wakeup1+0x2f>
80105934:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105937:	8b 40 20             	mov    0x20(%eax),%eax
8010593a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010593d:	75 0a                	jne    80105949 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010593f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105942:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105949:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010594d:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
80105954:	72 d3                	jb     80105929 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105956:	90                   	nop
80105957:	c9                   	leave  
80105958:	c3                   	ret    

80105959 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105959:	55                   	push   %ebp
8010595a:	89 e5                	mov    %esp,%ebp
8010595c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010595f:	83 ec 0c             	sub    $0xc,%esp
80105962:	68 80 3e 11 80       	push   $0x80113e80
80105967:	e8 fb 01 00 00       	call   80105b67 <acquire>
8010596c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010596f:	83 ec 0c             	sub    $0xc,%esp
80105972:	ff 75 08             	pushl  0x8(%ebp)
80105975:	e8 a0 ff ff ff       	call   8010591a <wakeup1>
8010597a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010597d:	83 ec 0c             	sub    $0xc,%esp
80105980:	68 80 3e 11 80       	push   $0x80113e80
80105985:	e8 44 02 00 00       	call   80105bce <release>
8010598a:	83 c4 10             	add    $0x10,%esp
}
8010598d:	90                   	nop
8010598e:	c9                   	leave  
8010598f:	c3                   	ret    

80105990 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105996:	83 ec 0c             	sub    $0xc,%esp
80105999:	68 80 3e 11 80       	push   $0x80113e80
8010599e:	e8 c4 01 00 00       	call   80105b67 <acquire>
801059a3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059a6:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059ad:	eb 45                	jmp    801059f4 <kill+0x64>
    if(p->pid == pid){
801059af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b2:	8b 40 10             	mov    0x10(%eax),%eax
801059b5:	3b 45 08             	cmp    0x8(%ebp),%eax
801059b8:	75 36                	jne    801059f0 <kill+0x60>
      p->killed = 1;
801059ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c7:	8b 40 0c             	mov    0xc(%eax),%eax
801059ca:	83 f8 02             	cmp    $0x2,%eax
801059cd:	75 0a                	jne    801059d9 <kill+0x49>
        p->state = RUNNABLE;
801059cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801059d9:	83 ec 0c             	sub    $0xc,%esp
801059dc:	68 80 3e 11 80       	push   $0x80113e80
801059e1:	e8 e8 01 00 00       	call   80105bce <release>
801059e6:	83 c4 10             	add    $0x10,%esp
      return 0;
801059e9:	b8 00 00 00 00       	mov    $0x0,%eax
801059ee:	eb 22                	jmp    80105a12 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059f0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801059f4:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801059fb:	72 b2                	jb     801059af <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801059fd:	83 ec 0c             	sub    $0xc,%esp
80105a00:	68 80 3e 11 80       	push   $0x80113e80
80105a05:	e8 c4 01 00 00       	call   80105bce <release>
80105a0a:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a12:	c9                   	leave  
80105a13:	c3                   	ret    

80105a14 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a14:	55                   	push   %ebp
80105a15:	89 e5                	mov    %esp,%ebp
80105a17:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a1a:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a21:	e9 d7 00 00 00       	jmp    80105afd <procdump+0xe9>
    if(p->state == UNUSED)
80105a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a29:	8b 40 0c             	mov    0xc(%eax),%eax
80105a2c:	85 c0                	test   %eax,%eax
80105a2e:	0f 84 c4 00 00 00    	je     80105af8 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a37:	8b 40 0c             	mov    0xc(%eax),%eax
80105a3a:	83 f8 05             	cmp    $0x5,%eax
80105a3d:	77 23                	ja     80105a62 <procdump+0x4e>
80105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a42:	8b 40 0c             	mov    0xc(%eax),%eax
80105a45:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a4c:	85 c0                	test   %eax,%eax
80105a4e:	74 12                	je     80105a62 <procdump+0x4e>
      state = states[p->state];
80105a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a53:	8b 40 0c             	mov    0xc(%eax),%eax
80105a56:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a60:	eb 07                	jmp    80105a69 <procdump+0x55>
    else
      state = "???";
80105a62:	c7 45 ec 6f 98 10 80 	movl   $0x8010986f,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6c:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a72:	8b 40 10             	mov    0x10(%eax),%eax
80105a75:	52                   	push   %edx
80105a76:	ff 75 ec             	pushl  -0x14(%ebp)
80105a79:	50                   	push   %eax
80105a7a:	68 73 98 10 80       	push   $0x80109873
80105a7f:	e8 42 a9 ff ff       	call   801003c6 <cprintf>
80105a84:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8a:	8b 40 0c             	mov    0xc(%eax),%eax
80105a8d:	83 f8 02             	cmp    $0x2,%eax
80105a90:	75 54                	jne    80105ae6 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a95:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a98:	8b 40 0c             	mov    0xc(%eax),%eax
80105a9b:	83 c0 08             	add    $0x8,%eax
80105a9e:	89 c2                	mov    %eax,%edx
80105aa0:	83 ec 08             	sub    $0x8,%esp
80105aa3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105aa6:	50                   	push   %eax
80105aa7:	52                   	push   %edx
80105aa8:	e8 73 01 00 00       	call   80105c20 <getcallerpcs>
80105aad:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ab0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ab7:	eb 1c                	jmp    80105ad5 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ac0:	83 ec 08             	sub    $0x8,%esp
80105ac3:	50                   	push   %eax
80105ac4:	68 7c 98 10 80       	push   $0x8010987c
80105ac9:	e8 f8 a8 ff ff       	call   801003c6 <cprintf>
80105ace:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105ad1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ad5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105ad9:	7f 0b                	jg     80105ae6 <procdump+0xd2>
80105adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ade:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ae2:	85 c0                	test   %eax,%eax
80105ae4:	75 d3                	jne    80105ab9 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105ae6:	83 ec 0c             	sub    $0xc,%esp
80105ae9:	68 80 98 10 80       	push   $0x80109880
80105aee:	e8 d3 a8 ff ff       	call   801003c6 <cprintf>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	eb 01                	jmp    80105af9 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105af8:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105af9:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105afd:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b04:	0f 82 1c ff ff ff    	jb     80105a26 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b0a:	90                   	nop
80105b0b:	c9                   	leave  
80105b0c:	c3                   	ret    

80105b0d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b0d:	55                   	push   %ebp
80105b0e:	89 e5                	mov    %esp,%ebp
80105b10:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b13:	9c                   	pushf  
80105b14:	58                   	pop    %eax
80105b15:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b18:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b1b:	c9                   	leave  
80105b1c:	c3                   	ret    

80105b1d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b1d:	55                   	push   %ebp
80105b1e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b20:	fa                   	cli    
}
80105b21:	90                   	nop
80105b22:	5d                   	pop    %ebp
80105b23:	c3                   	ret    

80105b24 <sti>:

static inline void
sti(void)
{
80105b24:	55                   	push   %ebp
80105b25:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b27:	fb                   	sti    
}
80105b28:	90                   	nop
80105b29:	5d                   	pop    %ebp
80105b2a:	c3                   	ret    

80105b2b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b2b:	55                   	push   %ebp
80105b2c:	89 e5                	mov    %esp,%ebp
80105b2e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b31:	8b 55 08             	mov    0x8(%ebp),%edx
80105b34:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b37:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b3a:	f0 87 02             	lock xchg %eax,(%edx)
80105b3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b43:	c9                   	leave  
80105b44:	c3                   	ret    

80105b45 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b45:	55                   	push   %ebp
80105b46:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b48:	8b 45 08             	mov    0x8(%ebp),%eax
80105b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b4e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b51:	8b 45 08             	mov    0x8(%ebp),%eax
80105b54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b64:	90                   	nop
80105b65:	5d                   	pop    %ebp
80105b66:	c3                   	ret    

80105b67 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b67:	55                   	push   %ebp
80105b68:	89 e5                	mov    %esp,%ebp
80105b6a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b6d:	e8 52 01 00 00       	call   80105cc4 <pushcli>
  if(holding(lk))
80105b72:	8b 45 08             	mov    0x8(%ebp),%eax
80105b75:	83 ec 0c             	sub    $0xc,%esp
80105b78:	50                   	push   %eax
80105b79:	e8 1c 01 00 00       	call   80105c9a <holding>
80105b7e:	83 c4 10             	add    $0x10,%esp
80105b81:	85 c0                	test   %eax,%eax
80105b83:	74 0d                	je     80105b92 <acquire+0x2b>
    panic("acquire");
80105b85:	83 ec 0c             	sub    $0xc,%esp
80105b88:	68 ac 98 10 80       	push   $0x801098ac
80105b8d:	e8 d4 a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105b92:	90                   	nop
80105b93:	8b 45 08             	mov    0x8(%ebp),%eax
80105b96:	83 ec 08             	sub    $0x8,%esp
80105b99:	6a 01                	push   $0x1
80105b9b:	50                   	push   %eax
80105b9c:	e8 8a ff ff ff       	call   80105b2b <xchg>
80105ba1:	83 c4 10             	add    $0x10,%esp
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	75 eb                	jne    80105b93 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bab:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bb2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb8:	83 c0 0c             	add    $0xc,%eax
80105bbb:	83 ec 08             	sub    $0x8,%esp
80105bbe:	50                   	push   %eax
80105bbf:	8d 45 08             	lea    0x8(%ebp),%eax
80105bc2:	50                   	push   %eax
80105bc3:	e8 58 00 00 00       	call   80105c20 <getcallerpcs>
80105bc8:	83 c4 10             	add    $0x10,%esp
}
80105bcb:	90                   	nop
80105bcc:	c9                   	leave  
80105bcd:	c3                   	ret    

80105bce <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105bce:	55                   	push   %ebp
80105bcf:	89 e5                	mov    %esp,%ebp
80105bd1:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bd4:	83 ec 0c             	sub    $0xc,%esp
80105bd7:	ff 75 08             	pushl  0x8(%ebp)
80105bda:	e8 bb 00 00 00       	call   80105c9a <holding>
80105bdf:	83 c4 10             	add    $0x10,%esp
80105be2:	85 c0                	test   %eax,%eax
80105be4:	75 0d                	jne    80105bf3 <release+0x25>
    panic("release");
80105be6:	83 ec 0c             	sub    $0xc,%esp
80105be9:	68 b4 98 10 80       	push   $0x801098b4
80105bee:	e8 73 a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80105c00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c07:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0a:	83 ec 08             	sub    $0x8,%esp
80105c0d:	6a 00                	push   $0x0
80105c0f:	50                   	push   %eax
80105c10:	e8 16 ff ff ff       	call   80105b2b <xchg>
80105c15:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c18:	e8 ec 00 00 00       	call   80105d09 <popcli>
}
80105c1d:	90                   	nop
80105c1e:	c9                   	leave  
80105c1f:	c3                   	ret    

80105c20 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c20:	55                   	push   %ebp
80105c21:	89 e5                	mov    %esp,%ebp
80105c23:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c26:	8b 45 08             	mov    0x8(%ebp),%eax
80105c29:	83 e8 08             	sub    $0x8,%eax
80105c2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c2f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c36:	eb 38                	jmp    80105c70 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c38:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c3c:	74 53                	je     80105c91 <getcallerpcs+0x71>
80105c3e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c45:	76 4a                	jbe    80105c91 <getcallerpcs+0x71>
80105c47:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c4b:	74 44                	je     80105c91 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c5a:	01 c2                	add    %eax,%edx
80105c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c5f:	8b 40 04             	mov    0x4(%eax),%eax
80105c62:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c67:	8b 00                	mov    (%eax),%eax
80105c69:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c6c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c70:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c74:	7e c2                	jle    80105c38 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c76:	eb 19                	jmp    80105c91 <getcallerpcs+0x71>
    pcs[i] = 0;
80105c78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c82:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c85:	01 d0                	add    %edx,%eax
80105c87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c8d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c91:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c95:	7e e1                	jle    80105c78 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105c97:	90                   	nop
80105c98:	c9                   	leave  
80105c99:	c3                   	ret    

80105c9a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105c9a:	55                   	push   %ebp
80105c9b:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca0:	8b 00                	mov    (%eax),%eax
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	74 17                	je     80105cbd <holding+0x23>
80105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca9:	8b 50 08             	mov    0x8(%eax),%edx
80105cac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cb2:	39 c2                	cmp    %eax,%edx
80105cb4:	75 07                	jne    80105cbd <holding+0x23>
80105cb6:	b8 01 00 00 00       	mov    $0x1,%eax
80105cbb:	eb 05                	jmp    80105cc2 <holding+0x28>
80105cbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cc2:	5d                   	pop    %ebp
80105cc3:	c3                   	ret    

80105cc4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105cc4:	55                   	push   %ebp
80105cc5:	89 e5                	mov    %esp,%ebp
80105cc7:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105cca:	e8 3e fe ff ff       	call   80105b0d <readeflags>
80105ccf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105cd2:	e8 46 fe ff ff       	call   80105b1d <cli>
  if(cpu->ncli++ == 0)
80105cd7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cde:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105ce4:	8d 48 01             	lea    0x1(%eax),%ecx
80105ce7:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105ced:	85 c0                	test   %eax,%eax
80105cef:	75 15                	jne    80105d06 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105cf1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cf7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105cfa:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d00:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d06:	90                   	nop
80105d07:	c9                   	leave  
80105d08:	c3                   	ret    

80105d09 <popcli>:

void
popcli(void)
{
80105d09:	55                   	push   %ebp
80105d0a:	89 e5                	mov    %esp,%ebp
80105d0c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d0f:	e8 f9 fd ff ff       	call   80105b0d <readeflags>
80105d14:	25 00 02 00 00       	and    $0x200,%eax
80105d19:	85 c0                	test   %eax,%eax
80105d1b:	74 0d                	je     80105d2a <popcli+0x21>
    panic("popcli - interruptible");
80105d1d:	83 ec 0c             	sub    $0xc,%esp
80105d20:	68 bc 98 10 80       	push   $0x801098bc
80105d25:	e8 3c a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d2a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d30:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d36:	83 ea 01             	sub    $0x1,%edx
80105d39:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d3f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d45:	85 c0                	test   %eax,%eax
80105d47:	79 0d                	jns    80105d56 <popcli+0x4d>
    panic("popcli");
80105d49:	83 ec 0c             	sub    $0xc,%esp
80105d4c:	68 d3 98 10 80       	push   $0x801098d3
80105d51:	e8 10 a8 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d56:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d5c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d62:	85 c0                	test   %eax,%eax
80105d64:	75 15                	jne    80105d7b <popcli+0x72>
80105d66:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d6c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d72:	85 c0                	test   %eax,%eax
80105d74:	74 05                	je     80105d7b <popcli+0x72>
    sti();
80105d76:	e8 a9 fd ff ff       	call   80105b24 <sti>
}
80105d7b:	90                   	nop
80105d7c:	c9                   	leave  
80105d7d:	c3                   	ret    

80105d7e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d7e:	55                   	push   %ebp
80105d7f:	89 e5                	mov    %esp,%ebp
80105d81:	57                   	push   %edi
80105d82:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d86:	8b 55 10             	mov    0x10(%ebp),%edx
80105d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d8c:	89 cb                	mov    %ecx,%ebx
80105d8e:	89 df                	mov    %ebx,%edi
80105d90:	89 d1                	mov    %edx,%ecx
80105d92:	fc                   	cld    
80105d93:	f3 aa                	rep stos %al,%es:(%edi)
80105d95:	89 ca                	mov    %ecx,%edx
80105d97:	89 fb                	mov    %edi,%ebx
80105d99:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105d9c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105d9f:	90                   	nop
80105da0:	5b                   	pop    %ebx
80105da1:	5f                   	pop    %edi
80105da2:	5d                   	pop    %ebp
80105da3:	c3                   	ret    

80105da4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105da4:	55                   	push   %ebp
80105da5:	89 e5                	mov    %esp,%ebp
80105da7:	57                   	push   %edi
80105da8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dac:	8b 55 10             	mov    0x10(%ebp),%edx
80105daf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105db2:	89 cb                	mov    %ecx,%ebx
80105db4:	89 df                	mov    %ebx,%edi
80105db6:	89 d1                	mov    %edx,%ecx
80105db8:	fc                   	cld    
80105db9:	f3 ab                	rep stos %eax,%es:(%edi)
80105dbb:	89 ca                	mov    %ecx,%edx
80105dbd:	89 fb                	mov    %edi,%ebx
80105dbf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dc2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dc5:	90                   	nop
80105dc6:	5b                   	pop    %ebx
80105dc7:	5f                   	pop    %edi
80105dc8:	5d                   	pop    %ebp
80105dc9:	c3                   	ret    

80105dca <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105dca:	55                   	push   %ebp
80105dcb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd0:	83 e0 03             	and    $0x3,%eax
80105dd3:	85 c0                	test   %eax,%eax
80105dd5:	75 43                	jne    80105e1a <memset+0x50>
80105dd7:	8b 45 10             	mov    0x10(%ebp),%eax
80105dda:	83 e0 03             	and    $0x3,%eax
80105ddd:	85 c0                	test   %eax,%eax
80105ddf:	75 39                	jne    80105e1a <memset+0x50>
    c &= 0xFF;
80105de1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105de8:	8b 45 10             	mov    0x10(%ebp),%eax
80105deb:	c1 e8 02             	shr    $0x2,%eax
80105dee:	89 c1                	mov    %eax,%ecx
80105df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105df3:	c1 e0 18             	shl    $0x18,%eax
80105df6:	89 c2                	mov    %eax,%edx
80105df8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dfb:	c1 e0 10             	shl    $0x10,%eax
80105dfe:	09 c2                	or     %eax,%edx
80105e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e03:	c1 e0 08             	shl    $0x8,%eax
80105e06:	09 d0                	or     %edx,%eax
80105e08:	0b 45 0c             	or     0xc(%ebp),%eax
80105e0b:	51                   	push   %ecx
80105e0c:	50                   	push   %eax
80105e0d:	ff 75 08             	pushl  0x8(%ebp)
80105e10:	e8 8f ff ff ff       	call   80105da4 <stosl>
80105e15:	83 c4 0c             	add    $0xc,%esp
80105e18:	eb 12                	jmp    80105e2c <memset+0x62>
  } else
    stosb(dst, c, n);
80105e1a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e1d:	50                   	push   %eax
80105e1e:	ff 75 0c             	pushl  0xc(%ebp)
80105e21:	ff 75 08             	pushl  0x8(%ebp)
80105e24:	e8 55 ff ff ff       	call   80105d7e <stosb>
80105e29:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e2c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e2f:	c9                   	leave  
80105e30:	c3                   	ret    

80105e31 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e31:	55                   	push   %ebp
80105e32:	89 e5                	mov    %esp,%ebp
80105e34:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e37:	8b 45 08             	mov    0x8(%ebp),%eax
80105e3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e40:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e43:	eb 30                	jmp    80105e75 <memcmp+0x44>
    if(*s1 != *s2)
80105e45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e48:	0f b6 10             	movzbl (%eax),%edx
80105e4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e4e:	0f b6 00             	movzbl (%eax),%eax
80105e51:	38 c2                	cmp    %al,%dl
80105e53:	74 18                	je     80105e6d <memcmp+0x3c>
      return *s1 - *s2;
80105e55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e58:	0f b6 00             	movzbl (%eax),%eax
80105e5b:	0f b6 d0             	movzbl %al,%edx
80105e5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e61:	0f b6 00             	movzbl (%eax),%eax
80105e64:	0f b6 c0             	movzbl %al,%eax
80105e67:	29 c2                	sub    %eax,%edx
80105e69:	89 d0                	mov    %edx,%eax
80105e6b:	eb 1a                	jmp    80105e87 <memcmp+0x56>
    s1++, s2++;
80105e6d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e71:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e75:	8b 45 10             	mov    0x10(%ebp),%eax
80105e78:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e7b:	89 55 10             	mov    %edx,0x10(%ebp)
80105e7e:	85 c0                	test   %eax,%eax
80105e80:	75 c3                	jne    80105e45 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105e82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e87:	c9                   	leave  
80105e88:	c3                   	ret    

80105e89 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105e89:	55                   	push   %ebp
80105e8a:	89 e5                	mov    %esp,%ebp
80105e8c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e92:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105e95:	8b 45 08             	mov    0x8(%ebp),%eax
80105e98:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105e9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e9e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ea1:	73 54                	jae    80105ef7 <memmove+0x6e>
80105ea3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ea9:	01 d0                	add    %edx,%eax
80105eab:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105eae:	76 47                	jbe    80105ef7 <memmove+0x6e>
    s += n;
80105eb0:	8b 45 10             	mov    0x10(%ebp),%eax
80105eb3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105eb6:	8b 45 10             	mov    0x10(%ebp),%eax
80105eb9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105ebc:	eb 13                	jmp    80105ed1 <memmove+0x48>
      *--d = *--s;
80105ebe:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105ec2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ec9:	0f b6 10             	movzbl (%eax),%edx
80105ecc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ecf:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105ed1:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed4:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ed7:	89 55 10             	mov    %edx,0x10(%ebp)
80105eda:	85 c0                	test   %eax,%eax
80105edc:	75 e0                	jne    80105ebe <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105ede:	eb 24                	jmp    80105f04 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105ee0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ee3:	8d 50 01             	lea    0x1(%eax),%edx
80105ee6:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105ee9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105eec:	8d 4a 01             	lea    0x1(%edx),%ecx
80105eef:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105ef2:	0f b6 12             	movzbl (%edx),%edx
80105ef5:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105ef7:	8b 45 10             	mov    0x10(%ebp),%eax
80105efa:	8d 50 ff             	lea    -0x1(%eax),%edx
80105efd:	89 55 10             	mov    %edx,0x10(%ebp)
80105f00:	85 c0                	test   %eax,%eax
80105f02:	75 dc                	jne    80105ee0 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f04:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f07:	c9                   	leave  
80105f08:	c3                   	ret    

80105f09 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f09:	55                   	push   %ebp
80105f0a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f0c:	ff 75 10             	pushl  0x10(%ebp)
80105f0f:	ff 75 0c             	pushl  0xc(%ebp)
80105f12:	ff 75 08             	pushl  0x8(%ebp)
80105f15:	e8 6f ff ff ff       	call   80105e89 <memmove>
80105f1a:	83 c4 0c             	add    $0xc,%esp
}
80105f1d:	c9                   	leave  
80105f1e:	c3                   	ret    

80105f1f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f1f:	55                   	push   %ebp
80105f20:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f22:	eb 0c                	jmp    80105f30 <strncmp+0x11>
    n--, p++, q++;
80105f24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f2c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f34:	74 1a                	je     80105f50 <strncmp+0x31>
80105f36:	8b 45 08             	mov    0x8(%ebp),%eax
80105f39:	0f b6 00             	movzbl (%eax),%eax
80105f3c:	84 c0                	test   %al,%al
80105f3e:	74 10                	je     80105f50 <strncmp+0x31>
80105f40:	8b 45 08             	mov    0x8(%ebp),%eax
80105f43:	0f b6 10             	movzbl (%eax),%edx
80105f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f49:	0f b6 00             	movzbl (%eax),%eax
80105f4c:	38 c2                	cmp    %al,%dl
80105f4e:	74 d4                	je     80105f24 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f54:	75 07                	jne    80105f5d <strncmp+0x3e>
    return 0;
80105f56:	b8 00 00 00 00       	mov    $0x0,%eax
80105f5b:	eb 16                	jmp    80105f73 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f60:	0f b6 00             	movzbl (%eax),%eax
80105f63:	0f b6 d0             	movzbl %al,%edx
80105f66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f69:	0f b6 00             	movzbl (%eax),%eax
80105f6c:	0f b6 c0             	movzbl %al,%eax
80105f6f:	29 c2                	sub    %eax,%edx
80105f71:	89 d0                	mov    %edx,%eax
}
80105f73:	5d                   	pop    %ebp
80105f74:	c3                   	ret    

80105f75 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f75:	55                   	push   %ebp
80105f76:	89 e5                	mov    %esp,%ebp
80105f78:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80105f7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105f81:	90                   	nop
80105f82:	8b 45 10             	mov    0x10(%ebp),%eax
80105f85:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f88:	89 55 10             	mov    %edx,0x10(%ebp)
80105f8b:	85 c0                	test   %eax,%eax
80105f8d:	7e 2c                	jle    80105fbb <strncpy+0x46>
80105f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f92:	8d 50 01             	lea    0x1(%eax),%edx
80105f95:	89 55 08             	mov    %edx,0x8(%ebp)
80105f98:	8b 55 0c             	mov    0xc(%ebp),%edx
80105f9b:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f9e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fa1:	0f b6 12             	movzbl (%edx),%edx
80105fa4:	88 10                	mov    %dl,(%eax)
80105fa6:	0f b6 00             	movzbl (%eax),%eax
80105fa9:	84 c0                	test   %al,%al
80105fab:	75 d5                	jne    80105f82 <strncpy+0xd>
    ;
  while(n-- > 0)
80105fad:	eb 0c                	jmp    80105fbb <strncpy+0x46>
    *s++ = 0;
80105faf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb2:	8d 50 01             	lea    0x1(%eax),%edx
80105fb5:	89 55 08             	mov    %edx,0x8(%ebp)
80105fb8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80105fbe:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fc1:	89 55 10             	mov    %edx,0x10(%ebp)
80105fc4:	85 c0                	test   %eax,%eax
80105fc6:	7f e7                	jg     80105faf <strncpy+0x3a>
    *s++ = 0;
  return os;
80105fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fcb:	c9                   	leave  
80105fcc:	c3                   	ret    

80105fcd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105fcd:	55                   	push   %ebp
80105fce:	89 e5                	mov    %esp,%ebp
80105fd0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105fd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fdd:	7f 05                	jg     80105fe4 <safestrcpy+0x17>
    return os;
80105fdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fe2:	eb 31                	jmp    80106015 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105fe4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105fe8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fec:	7e 1e                	jle    8010600c <safestrcpy+0x3f>
80105fee:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff1:	8d 50 01             	lea    0x1(%eax),%edx
80105ff4:	89 55 08             	mov    %edx,0x8(%ebp)
80105ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ffa:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ffd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106000:	0f b6 12             	movzbl (%edx),%edx
80106003:	88 10                	mov    %dl,(%eax)
80106005:	0f b6 00             	movzbl (%eax),%eax
80106008:	84 c0                	test   %al,%al
8010600a:	75 d8                	jne    80105fe4 <safestrcpy+0x17>
    ;
  *s = 0;
8010600c:	8b 45 08             	mov    0x8(%ebp),%eax
8010600f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106012:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106015:	c9                   	leave  
80106016:	c3                   	ret    

80106017 <strlen>:

int
strlen(const char *s)
{
80106017:	55                   	push   %ebp
80106018:	89 e5                	mov    %esp,%ebp
8010601a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010601d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106024:	eb 04                	jmp    8010602a <strlen+0x13>
80106026:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010602a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010602d:	8b 45 08             	mov    0x8(%ebp),%eax
80106030:	01 d0                	add    %edx,%eax
80106032:	0f b6 00             	movzbl (%eax),%eax
80106035:	84 c0                	test   %al,%al
80106037:	75 ed                	jne    80106026 <strlen+0xf>
    ;
  return n;
80106039:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010603c:	c9                   	leave  
8010603d:	c3                   	ret    

8010603e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010603e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106042:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106046:	55                   	push   %ebp
  pushl %ebx
80106047:	53                   	push   %ebx
  pushl %esi
80106048:	56                   	push   %esi
  pushl %edi
80106049:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010604a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010604c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010604e:	5f                   	pop    %edi
  popl %esi
8010604f:	5e                   	pop    %esi
  popl %ebx
80106050:	5b                   	pop    %ebx
  popl %ebp
80106051:	5d                   	pop    %ebp
  ret
80106052:	c3                   	ret    

80106053 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106053:	55                   	push   %ebp
80106054:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106056:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010605c:	8b 00                	mov    (%eax),%eax
8010605e:	3b 45 08             	cmp    0x8(%ebp),%eax
80106061:	76 12                	jbe    80106075 <fetchint+0x22>
80106063:	8b 45 08             	mov    0x8(%ebp),%eax
80106066:	8d 50 04             	lea    0x4(%eax),%edx
80106069:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010606f:	8b 00                	mov    (%eax),%eax
80106071:	39 c2                	cmp    %eax,%edx
80106073:	76 07                	jbe    8010607c <fetchint+0x29>
    return -1;
80106075:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607a:	eb 0f                	jmp    8010608b <fetchint+0x38>
  *ip = *(int*)(addr);
8010607c:	8b 45 08             	mov    0x8(%ebp),%eax
8010607f:	8b 10                	mov    (%eax),%edx
80106081:	8b 45 0c             	mov    0xc(%ebp),%eax
80106084:	89 10                	mov    %edx,(%eax)
  return 0;
80106086:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010608b:	5d                   	pop    %ebp
8010608c:	c3                   	ret    

8010608d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010608d:	55                   	push   %ebp
8010608e:	89 e5                	mov    %esp,%ebp
80106090:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106093:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106099:	8b 00                	mov    (%eax),%eax
8010609b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010609e:	77 07                	ja     801060a7 <fetchstr+0x1a>
    return -1;
801060a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a5:	eb 46                	jmp    801060ed <fetchstr+0x60>
  *pp = (char*)addr;
801060a7:	8b 55 08             	mov    0x8(%ebp),%edx
801060aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ad:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060b5:	8b 00                	mov    (%eax),%eax
801060b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801060bd:	8b 00                	mov    (%eax),%eax
801060bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060c2:	eb 1c                	jmp    801060e0 <fetchstr+0x53>
    if(*s == 0)
801060c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060c7:	0f b6 00             	movzbl (%eax),%eax
801060ca:	84 c0                	test   %al,%al
801060cc:	75 0e                	jne    801060dc <fetchstr+0x4f>
      return s - *pp;
801060ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801060d4:	8b 00                	mov    (%eax),%eax
801060d6:	29 c2                	sub    %eax,%edx
801060d8:	89 d0                	mov    %edx,%eax
801060da:	eb 11                	jmp    801060ed <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801060e6:	72 dc                	jb     801060c4 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801060e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060ed:	c9                   	leave  
801060ee:	c3                   	ret    

801060ef <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801060ef:	55                   	push   %ebp
801060f0:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801060f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060f8:	8b 40 18             	mov    0x18(%eax),%eax
801060fb:	8b 40 44             	mov    0x44(%eax),%eax
801060fe:	8b 55 08             	mov    0x8(%ebp),%edx
80106101:	c1 e2 02             	shl    $0x2,%edx
80106104:	01 d0                	add    %edx,%eax
80106106:	83 c0 04             	add    $0x4,%eax
80106109:	ff 75 0c             	pushl  0xc(%ebp)
8010610c:	50                   	push   %eax
8010610d:	e8 41 ff ff ff       	call   80106053 <fetchint>
80106112:	83 c4 08             	add    $0x8,%esp
}
80106115:	c9                   	leave  
80106116:	c3                   	ret    

80106117 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106117:	55                   	push   %ebp
80106118:	89 e5                	mov    %esp,%ebp
8010611a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010611d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106120:	50                   	push   %eax
80106121:	ff 75 08             	pushl  0x8(%ebp)
80106124:	e8 c6 ff ff ff       	call   801060ef <argint>
80106129:	83 c4 08             	add    $0x8,%esp
8010612c:	85 c0                	test   %eax,%eax
8010612e:	79 07                	jns    80106137 <argptr+0x20>
    return -1;
80106130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106135:	eb 3b                	jmp    80106172 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106137:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010613d:	8b 00                	mov    (%eax),%eax
8010613f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106142:	39 d0                	cmp    %edx,%eax
80106144:	76 16                	jbe    8010615c <argptr+0x45>
80106146:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106149:	89 c2                	mov    %eax,%edx
8010614b:	8b 45 10             	mov    0x10(%ebp),%eax
8010614e:	01 c2                	add    %eax,%edx
80106150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106156:	8b 00                	mov    (%eax),%eax
80106158:	39 c2                	cmp    %eax,%edx
8010615a:	76 07                	jbe    80106163 <argptr+0x4c>
    return -1;
8010615c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106161:	eb 0f                	jmp    80106172 <argptr+0x5b>
  *pp = (char*)i;
80106163:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106166:	89 c2                	mov    %eax,%edx
80106168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010616b:	89 10                	mov    %edx,(%eax)
  return 0;
8010616d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106172:	c9                   	leave  
80106173:	c3                   	ret    

80106174 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106174:	55                   	push   %ebp
80106175:	89 e5                	mov    %esp,%ebp
80106177:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010617a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010617d:	50                   	push   %eax
8010617e:	ff 75 08             	pushl  0x8(%ebp)
80106181:	e8 69 ff ff ff       	call   801060ef <argint>
80106186:	83 c4 08             	add    $0x8,%esp
80106189:	85 c0                	test   %eax,%eax
8010618b:	79 07                	jns    80106194 <argstr+0x20>
    return -1;
8010618d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106192:	eb 0f                	jmp    801061a3 <argstr+0x2f>
  return fetchstr(addr, pp);
80106194:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106197:	ff 75 0c             	pushl  0xc(%ebp)
8010619a:	50                   	push   %eax
8010619b:	e8 ed fe ff ff       	call   8010608d <fetchstr>
801061a0:	83 c4 08             	add    $0x8,%esp
}
801061a3:	c9                   	leave  
801061a4:	c3                   	ret    

801061a5 <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061a5:	55                   	push   %ebp
801061a6:	89 e5                	mov    %esp,%ebp
801061a8:	53                   	push   %ebx
801061a9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061b2:	8b 40 18             	mov    0x18(%eax),%eax
801061b5:	8b 40 1c             	mov    0x1c(%eax),%eax
801061b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061bf:	7e 30                	jle    801061f1 <syscall+0x4c>
801061c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c4:	83 f8 16             	cmp    $0x16,%eax
801061c7:	77 28                	ja     801061f1 <syscall+0x4c>
801061c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cc:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061d3:	85 c0                	test   %eax,%eax
801061d5:	74 1a                	je     801061f1 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061dd:	8b 58 18             	mov    0x18(%eax),%ebx
801061e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e3:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061ea:	ff d0                	call   *%eax
801061ec:	89 43 1c             	mov    %eax,0x1c(%ebx)
801061ef:	eb 34                	jmp    80106225 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801061f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061f7:	8d 50 6c             	lea    0x6c(%eax),%edx
801061fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106200:	8b 40 10             	mov    0x10(%eax),%eax
80106203:	ff 75 f4             	pushl  -0xc(%ebp)
80106206:	52                   	push   %edx
80106207:	50                   	push   %eax
80106208:	68 da 98 10 80       	push   $0x801098da
8010620d:	e8 b4 a1 ff ff       	call   801003c6 <cprintf>
80106212:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106215:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010621b:	8b 40 18             	mov    0x18(%eax),%eax
8010621e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106225:	90                   	nop
80106226:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106229:	c9                   	leave  
8010622a:	c3                   	ret    

8010622b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
8010622b:	55                   	push   %ebp
8010622c:	89 e5                	mov    %esp,%ebp
8010622e:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
80106231:	83 ec 08             	sub    $0x8,%esp
80106234:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106237:	50                   	push   %eax
80106238:	ff 75 08             	pushl  0x8(%ebp)
8010623b:	e8 af fe ff ff       	call   801060ef <argint>
80106240:	83 c4 10             	add    $0x10,%esp
80106243:	85 c0                	test   %eax,%eax
80106245:	79 07                	jns    8010624e <argfd+0x23>
        return -1;
80106247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624c:	eb 50                	jmp    8010629e <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
8010624e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106251:	85 c0                	test   %eax,%eax
80106253:	78 21                	js     80106276 <argfd+0x4b>
80106255:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106258:	83 f8 0f             	cmp    $0xf,%eax
8010625b:	7f 19                	jg     80106276 <argfd+0x4b>
8010625d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106263:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106266:	83 c2 08             	add    $0x8,%edx
80106269:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010626d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106270:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106274:	75 07                	jne    8010627d <argfd+0x52>
        return -1;
80106276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627b:	eb 21                	jmp    8010629e <argfd+0x73>
    if (pfd)
8010627d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106281:	74 08                	je     8010628b <argfd+0x60>
        *pfd = fd;
80106283:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106286:	8b 45 0c             	mov    0xc(%ebp),%eax
80106289:	89 10                	mov    %edx,(%eax)
    if (pf)
8010628b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010628f:	74 08                	je     80106299 <argfd+0x6e>
        *pf = f;
80106291:	8b 45 10             	mov    0x10(%ebp),%eax
80106294:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106297:	89 10                	mov    %edx,(%eax)
    return 0;
80106299:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010629e:	c9                   	leave  
8010629f:	c3                   	ret    

801062a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062a0:	55                   	push   %ebp
801062a1:	89 e5                	mov    %esp,%ebp
801062a3:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062ad:	eb 30                	jmp    801062df <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062b8:	83 c2 08             	add    $0x8,%edx
801062bb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062bf:	85 c0                	test   %eax,%eax
801062c1:	75 18                	jne    801062db <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062cc:	8d 4a 08             	lea    0x8(%edx),%ecx
801062cf:	8b 55 08             	mov    0x8(%ebp),%edx
801062d2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801062d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062d9:	eb 0f                	jmp    801062ea <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062db:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062df:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801062e3:	7e ca                	jle    801062af <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
801062e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062ea:	c9                   	leave  
801062eb:	c3                   	ret    

801062ec <sys_dup>:

int sys_dup(void)
{
801062ec:	55                   	push   %ebp
801062ed:	89 e5                	mov    %esp,%ebp
801062ef:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
801062f2:	83 ec 04             	sub    $0x4,%esp
801062f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062f8:	50                   	push   %eax
801062f9:	6a 00                	push   $0x0
801062fb:	6a 00                	push   $0x0
801062fd:	e8 29 ff ff ff       	call   8010622b <argfd>
80106302:	83 c4 10             	add    $0x10,%esp
80106305:	85 c0                	test   %eax,%eax
80106307:	79 07                	jns    80106310 <sys_dup+0x24>
        return -1;
80106309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630e:	eb 31                	jmp    80106341 <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106313:	83 ec 0c             	sub    $0xc,%esp
80106316:	50                   	push   %eax
80106317:	e8 84 ff ff ff       	call   801062a0 <fdalloc>
8010631c:	83 c4 10             	add    $0x10,%esp
8010631f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106326:	79 07                	jns    8010632f <sys_dup+0x43>
        return -1;
80106328:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632d:	eb 12                	jmp    80106341 <sys_dup+0x55>
    filedup(f);
8010632f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106332:	83 ec 0c             	sub    $0xc,%esp
80106335:	50                   	push   %eax
80106336:	e8 1d ad ff ff       	call   80101058 <filedup>
8010633b:	83 c4 10             	add    $0x10,%esp
    return fd;
8010633e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106341:	c9                   	leave  
80106342:	c3                   	ret    

80106343 <sys_read>:

int sys_read(void)
{
80106343:	55                   	push   %ebp
80106344:	89 e5                	mov    %esp,%ebp
80106346:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106349:	83 ec 04             	sub    $0x4,%esp
8010634c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010634f:	50                   	push   %eax
80106350:	6a 00                	push   $0x0
80106352:	6a 00                	push   $0x0
80106354:	e8 d2 fe ff ff       	call   8010622b <argfd>
80106359:	83 c4 10             	add    $0x10,%esp
8010635c:	85 c0                	test   %eax,%eax
8010635e:	78 2e                	js     8010638e <sys_read+0x4b>
80106360:	83 ec 08             	sub    $0x8,%esp
80106363:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106366:	50                   	push   %eax
80106367:	6a 02                	push   $0x2
80106369:	e8 81 fd ff ff       	call   801060ef <argint>
8010636e:	83 c4 10             	add    $0x10,%esp
80106371:	85 c0                	test   %eax,%eax
80106373:	78 19                	js     8010638e <sys_read+0x4b>
80106375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106378:	83 ec 04             	sub    $0x4,%esp
8010637b:	50                   	push   %eax
8010637c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010637f:	50                   	push   %eax
80106380:	6a 01                	push   $0x1
80106382:	e8 90 fd ff ff       	call   80106117 <argptr>
80106387:	83 c4 10             	add    $0x10,%esp
8010638a:	85 c0                	test   %eax,%eax
8010638c:	79 07                	jns    80106395 <sys_read+0x52>
        return -1;
8010638e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106393:	eb 17                	jmp    801063ac <sys_read+0x69>
    return fileread(f, p, n);
80106395:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106398:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010639b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639e:	83 ec 04             	sub    $0x4,%esp
801063a1:	51                   	push   %ecx
801063a2:	52                   	push   %edx
801063a3:	50                   	push   %eax
801063a4:	e8 67 ae ff ff       	call   80101210 <fileread>
801063a9:	83 c4 10             	add    $0x10,%esp
}
801063ac:	c9                   	leave  
801063ad:	c3                   	ret    

801063ae <sys_write>:

int sys_write(void)
{
801063ae:	55                   	push   %ebp
801063af:	89 e5                	mov    %esp,%ebp
801063b1:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063b4:	83 ec 04             	sub    $0x4,%esp
801063b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063ba:	50                   	push   %eax
801063bb:	6a 00                	push   $0x0
801063bd:	6a 00                	push   $0x0
801063bf:	e8 67 fe ff ff       	call   8010622b <argfd>
801063c4:	83 c4 10             	add    $0x10,%esp
801063c7:	85 c0                	test   %eax,%eax
801063c9:	78 2e                	js     801063f9 <sys_write+0x4b>
801063cb:	83 ec 08             	sub    $0x8,%esp
801063ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063d1:	50                   	push   %eax
801063d2:	6a 02                	push   $0x2
801063d4:	e8 16 fd ff ff       	call   801060ef <argint>
801063d9:	83 c4 10             	add    $0x10,%esp
801063dc:	85 c0                	test   %eax,%eax
801063de:	78 19                	js     801063f9 <sys_write+0x4b>
801063e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e3:	83 ec 04             	sub    $0x4,%esp
801063e6:	50                   	push   %eax
801063e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063ea:	50                   	push   %eax
801063eb:	6a 01                	push   $0x1
801063ed:	e8 25 fd ff ff       	call   80106117 <argptr>
801063f2:	83 c4 10             	add    $0x10,%esp
801063f5:	85 c0                	test   %eax,%eax
801063f7:	79 07                	jns    80106400 <sys_write+0x52>
        return -1;
801063f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fe:	eb 17                	jmp    80106417 <sys_write+0x69>
    return filewrite(f, p, n);
80106400:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106403:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106409:	83 ec 04             	sub    $0x4,%esp
8010640c:	51                   	push   %ecx
8010640d:	52                   	push   %edx
8010640e:	50                   	push   %eax
8010640f:	e8 b4 ae ff ff       	call   801012c8 <filewrite>
80106414:	83 c4 10             	add    $0x10,%esp
}
80106417:	c9                   	leave  
80106418:	c3                   	ret    

80106419 <sys_close>:

int sys_close(void)
{
80106419:	55                   	push   %ebp
8010641a:	89 e5                	mov    %esp,%ebp
8010641c:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
8010641f:	83 ec 04             	sub    $0x4,%esp
80106422:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106425:	50                   	push   %eax
80106426:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106429:	50                   	push   %eax
8010642a:	6a 00                	push   $0x0
8010642c:	e8 fa fd ff ff       	call   8010622b <argfd>
80106431:	83 c4 10             	add    $0x10,%esp
80106434:	85 c0                	test   %eax,%eax
80106436:	79 07                	jns    8010643f <sys_close+0x26>
        return -1;
80106438:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643d:	eb 28                	jmp    80106467 <sys_close+0x4e>
    proc->ofile[fd] = 0;
8010643f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106445:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106448:	83 c2 08             	add    $0x8,%edx
8010644b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106452:	00 
    fileclose(f);
80106453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106456:	83 ec 0c             	sub    $0xc,%esp
80106459:	50                   	push   %eax
8010645a:	e8 4a ac ff ff       	call   801010a9 <fileclose>
8010645f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106462:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106467:	c9                   	leave  
80106468:	c3                   	ret    

80106469 <sys_fstat>:

int sys_fstat(void)
{
80106469:	55                   	push   %ebp
8010646a:	89 e5                	mov    %esp,%ebp
8010646c:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010646f:	83 ec 04             	sub    $0x4,%esp
80106472:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106475:	50                   	push   %eax
80106476:	6a 00                	push   $0x0
80106478:	6a 00                	push   $0x0
8010647a:	e8 ac fd ff ff       	call   8010622b <argfd>
8010647f:	83 c4 10             	add    $0x10,%esp
80106482:	85 c0                	test   %eax,%eax
80106484:	78 17                	js     8010649d <sys_fstat+0x34>
80106486:	83 ec 04             	sub    $0x4,%esp
80106489:	6a 14                	push   $0x14
8010648b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010648e:	50                   	push   %eax
8010648f:	6a 01                	push   $0x1
80106491:	e8 81 fc ff ff       	call   80106117 <argptr>
80106496:	83 c4 10             	add    $0x10,%esp
80106499:	85 c0                	test   %eax,%eax
8010649b:	79 07                	jns    801064a4 <sys_fstat+0x3b>
        return -1;
8010649d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a2:	eb 13                	jmp    801064b7 <sys_fstat+0x4e>
    return filestat(f, st);
801064a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064aa:	83 ec 08             	sub    $0x8,%esp
801064ad:	52                   	push   %edx
801064ae:	50                   	push   %eax
801064af:	e8 05 ad ff ff       	call   801011b9 <filestat>
801064b4:	83 c4 10             	add    $0x10,%esp
}
801064b7:	c9                   	leave  
801064b8:	c3                   	ret    

801064b9 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064b9:	55                   	push   %ebp
801064ba:	89 e5                	mov    %esp,%ebp
801064bc:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064bf:	83 ec 08             	sub    $0x8,%esp
801064c2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064c5:	50                   	push   %eax
801064c6:	6a 00                	push   $0x0
801064c8:	e8 a7 fc ff ff       	call   80106174 <argstr>
801064cd:	83 c4 10             	add    $0x10,%esp
801064d0:	85 c0                	test   %eax,%eax
801064d2:	78 15                	js     801064e9 <sys_link+0x30>
801064d4:	83 ec 08             	sub    $0x8,%esp
801064d7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064da:	50                   	push   %eax
801064db:	6a 01                	push   $0x1
801064dd:	e8 92 fc ff ff       	call   80106174 <argstr>
801064e2:	83 c4 10             	add    $0x10,%esp
801064e5:	85 c0                	test   %eax,%eax
801064e7:	79 0a                	jns    801064f3 <sys_link+0x3a>
        return -1;
801064e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ee:	e9 da 01 00 00       	jmp    801066cd <sys_link+0x214>

    begin_op(proc->cwd->part->number);
801064f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064f9:	8b 40 68             	mov    0x68(%eax),%eax
801064fc:	8b 40 50             	mov    0x50(%eax),%eax
801064ff:	8b 40 14             	mov    0x14(%eax),%eax
80106502:	83 ec 0c             	sub    $0xc,%esp
80106505:	50                   	push   %eax
80106506:	e8 7e d9 ff ff       	call   80103e89 <begin_op>
8010650b:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
8010650e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106511:	83 ec 0c             	sub    $0xc,%esp
80106514:	50                   	push   %eax
80106515:	e8 ea c7 ff ff       	call   80102d04 <namei>
8010651a:	83 c4 10             	add    $0x10,%esp
8010651d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106520:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106524:	75 25                	jne    8010654b <sys_link+0x92>
        end_op(proc->cwd->part->number);
80106526:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652c:	8b 40 68             	mov    0x68(%eax),%eax
8010652f:	8b 40 50             	mov    0x50(%eax),%eax
80106532:	8b 40 14             	mov    0x14(%eax),%eax
80106535:	83 ec 0c             	sub    $0xc,%esp
80106538:	50                   	push   %eax
80106539:	e8 52 da ff ff       	call   80103f90 <end_op>
8010653e:	83 c4 10             	add    $0x10,%esp
        return -1;
80106541:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106546:	e9 82 01 00 00       	jmp    801066cd <sys_link+0x214>
    }

    ilock(ip);
8010654b:	83 ec 0c             	sub    $0xc,%esp
8010654e:	ff 75 f4             	pushl  -0xc(%ebp)
80106551:	e8 8c b9 ff ff       	call   80101ee2 <ilock>
80106556:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106560:	66 83 f8 01          	cmp    $0x1,%ax
80106564:	75 33                	jne    80106599 <sys_link+0xe0>
        iunlockput(ip);
80106566:	83 ec 0c             	sub    $0xc,%esp
80106569:	ff 75 f4             	pushl  -0xc(%ebp)
8010656c:	e8 74 bc ff ff       	call   801021e5 <iunlockput>
80106571:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106574:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010657a:	8b 40 68             	mov    0x68(%eax),%eax
8010657d:	8b 40 50             	mov    0x50(%eax),%eax
80106580:	8b 40 14             	mov    0x14(%eax),%eax
80106583:	83 ec 0c             	sub    $0xc,%esp
80106586:	50                   	push   %eax
80106587:	e8 04 da ff ff       	call   80103f90 <end_op>
8010658c:	83 c4 10             	add    $0x10,%esp
        return -1;
8010658f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106594:	e9 34 01 00 00       	jmp    801066cd <sys_link+0x214>
    }

    ip->nlink++;
80106599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065a0:	83 c0 01             	add    $0x1,%eax
801065a3:	89 c2                	mov    %eax,%edx
801065a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065ac:	83 ec 0c             	sub    $0xc,%esp
801065af:	ff 75 f4             	pushl  -0xc(%ebp)
801065b2:	e8 cd b6 ff ff       	call   80101c84 <iupdate>
801065b7:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065ba:	83 ec 0c             	sub    $0xc,%esp
801065bd:	ff 75 f4             	pushl  -0xc(%ebp)
801065c0:	e8 be ba ff ff       	call   80102083 <iunlock>
801065c5:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065cb:	83 ec 08             	sub    $0x8,%esp
801065ce:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065d1:	52                   	push   %edx
801065d2:	50                   	push   %eax
801065d3:	e8 62 c7 ff ff       	call   80102d3a <nameiparent>
801065d8:	83 c4 10             	add    $0x10,%esp
801065db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065e2:	0f 84 87 00 00 00    	je     8010666f <sys_link+0x1b6>
        goto bad;
    ilock(dp);
801065e8:	83 ec 0c             	sub    $0xc,%esp
801065eb:	ff 75 f0             	pushl  -0x10(%ebp)
801065ee:	e8 ef b8 ff ff       	call   80101ee2 <ilock>
801065f3:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
801065f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f9:	8b 10                	mov    (%eax),%edx
801065fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fe:	8b 00                	mov    (%eax),%eax
80106600:	39 c2                	cmp    %eax,%edx
80106602:	75 1d                	jne    80106621 <sys_link+0x168>
80106604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106607:	8b 40 04             	mov    0x4(%eax),%eax
8010660a:	83 ec 04             	sub    $0x4,%esp
8010660d:	50                   	push   %eax
8010660e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106611:	50                   	push   %eax
80106612:	ff 75 f0             	pushl  -0x10(%ebp)
80106615:	e8 b3 c3 ff ff       	call   801029cd <dirlink>
8010661a:	83 c4 10             	add    $0x10,%esp
8010661d:	85 c0                	test   %eax,%eax
8010661f:	79 10                	jns    80106631 <sys_link+0x178>
        iunlockput(dp);
80106621:	83 ec 0c             	sub    $0xc,%esp
80106624:	ff 75 f0             	pushl  -0x10(%ebp)
80106627:	e8 b9 bb ff ff       	call   801021e5 <iunlockput>
8010662c:	83 c4 10             	add    $0x10,%esp
        goto bad;
8010662f:	eb 3f                	jmp    80106670 <sys_link+0x1b7>
    }
    iunlockput(dp);
80106631:	83 ec 0c             	sub    $0xc,%esp
80106634:	ff 75 f0             	pushl  -0x10(%ebp)
80106637:	e8 a9 bb ff ff       	call   801021e5 <iunlockput>
8010663c:	83 c4 10             	add    $0x10,%esp
    iput(ip);
8010663f:	83 ec 0c             	sub    $0xc,%esp
80106642:	ff 75 f4             	pushl  -0xc(%ebp)
80106645:	e8 ab ba ff ff       	call   801020f5 <iput>
8010664a:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010664d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106653:	8b 40 68             	mov    0x68(%eax),%eax
80106656:	8b 40 50             	mov    0x50(%eax),%eax
80106659:	8b 40 14             	mov    0x14(%eax),%eax
8010665c:	83 ec 0c             	sub    $0xc,%esp
8010665f:	50                   	push   %eax
80106660:	e8 2b d9 ff ff       	call   80103f90 <end_op>
80106665:	83 c4 10             	add    $0x10,%esp

    return 0;
80106668:	b8 00 00 00 00       	mov    $0x0,%eax
8010666d:	eb 5e                	jmp    801066cd <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
8010666f:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
80106670:	83 ec 0c             	sub    $0xc,%esp
80106673:	ff 75 f4             	pushl  -0xc(%ebp)
80106676:	e8 67 b8 ff ff       	call   80101ee2 <ilock>
8010667b:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
8010667e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106681:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106685:	83 e8 01             	sub    $0x1,%eax
80106688:	89 c2                	mov    %eax,%edx
8010668a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
80106691:	83 ec 0c             	sub    $0xc,%esp
80106694:	ff 75 f4             	pushl  -0xc(%ebp)
80106697:	e8 e8 b5 ff ff       	call   80101c84 <iupdate>
8010669c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010669f:	83 ec 0c             	sub    $0xc,%esp
801066a2:	ff 75 f4             	pushl  -0xc(%ebp)
801066a5:	e8 3b bb ff ff       	call   801021e5 <iunlockput>
801066aa:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b3:	8b 40 68             	mov    0x68(%eax),%eax
801066b6:	8b 40 50             	mov    0x50(%eax),%eax
801066b9:	8b 40 14             	mov    0x14(%eax),%eax
801066bc:	83 ec 0c             	sub    $0xc,%esp
801066bf:	50                   	push   %eax
801066c0:	e8 cb d8 ff ff       	call   80103f90 <end_op>
801066c5:	83 c4 10             	add    $0x10,%esp
    return -1;
801066c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066cd:	c9                   	leave  
801066ce:	c3                   	ret    

801066cf <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066cf:	55                   	push   %ebp
801066d0:	89 e5                	mov    %esp,%ebp
801066d2:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801066d5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066dc:	eb 40                	jmp    8010671e <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e1:	6a 10                	push   $0x10
801066e3:	50                   	push   %eax
801066e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066e7:	50                   	push   %eax
801066e8:	ff 75 08             	pushl  0x8(%ebp)
801066eb:	e8 80 be ff ff       	call   80102570 <readi>
801066f0:	83 c4 10             	add    $0x10,%esp
801066f3:	83 f8 10             	cmp    $0x10,%eax
801066f6:	74 0d                	je     80106705 <isdirempty+0x36>
            panic("isdirempty: readi");
801066f8:	83 ec 0c             	sub    $0xc,%esp
801066fb:	68 f6 98 10 80       	push   $0x801098f6
80106700:	e8 61 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
80106705:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106709:	66 85 c0             	test   %ax,%ax
8010670c:	74 07                	je     80106715 <isdirempty+0x46>
            return 0;
8010670e:	b8 00 00 00 00       	mov    $0x0,%eax
80106713:	eb 1b                	jmp    80106730 <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80106715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106718:	83 c0 10             	add    $0x10,%eax
8010671b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010671e:	8b 45 08             	mov    0x8(%ebp),%eax
80106721:	8b 50 18             	mov    0x18(%eax),%edx
80106724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106727:	39 c2                	cmp    %eax,%edx
80106729:	77 b3                	ja     801066de <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
8010672b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106730:	c9                   	leave  
80106731:	c3                   	ret    

80106732 <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
80106732:	55                   	push   %ebp
80106733:	89 e5                	mov    %esp,%ebp
80106735:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106738:	83 ec 08             	sub    $0x8,%esp
8010673b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010673e:	50                   	push   %eax
8010673f:	6a 00                	push   $0x0
80106741:	e8 2e fa ff ff       	call   80106174 <argstr>
80106746:	83 c4 10             	add    $0x10,%esp
80106749:	85 c0                	test   %eax,%eax
8010674b:	79 0a                	jns    80106757 <sys_unlink+0x25>
        return -1;
8010674d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106752:	e9 14 02 00 00       	jmp    8010696b <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
80106757:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010675d:	8b 40 68             	mov    0x68(%eax),%eax
80106760:	8b 40 50             	mov    0x50(%eax),%eax
80106763:	8b 40 14             	mov    0x14(%eax),%eax
80106766:	83 ec 0c             	sub    $0xc,%esp
80106769:	50                   	push   %eax
8010676a:	e8 1a d7 ff ff       	call   80103e89 <begin_op>
8010676f:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
80106772:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106775:	83 ec 08             	sub    $0x8,%esp
80106778:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010677b:	52                   	push   %edx
8010677c:	50                   	push   %eax
8010677d:	e8 b8 c5 ff ff       	call   80102d3a <nameiparent>
80106782:	83 c4 10             	add    $0x10,%esp
80106785:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106788:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010678c:	75 25                	jne    801067b3 <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
8010678e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106794:	8b 40 68             	mov    0x68(%eax),%eax
80106797:	8b 40 50             	mov    0x50(%eax),%eax
8010679a:	8b 40 14             	mov    0x14(%eax),%eax
8010679d:	83 ec 0c             	sub    $0xc,%esp
801067a0:	50                   	push   %eax
801067a1:	e8 ea d7 ff ff       	call   80103f90 <end_op>
801067a6:	83 c4 10             	add    $0x10,%esp
        return -1;
801067a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ae:	e9 b8 01 00 00       	jmp    8010696b <sys_unlink+0x239>
    }

    ilock(dp);
801067b3:	83 ec 0c             	sub    $0xc,%esp
801067b6:	ff 75 f4             	pushl  -0xc(%ebp)
801067b9:	e8 24 b7 ff ff       	call   80101ee2 <ilock>
801067be:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067c1:	83 ec 08             	sub    $0x8,%esp
801067c4:	68 08 99 10 80       	push   $0x80109908
801067c9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067cc:	50                   	push   %eax
801067cd:	e8 19 c1 ff ff       	call   801028eb <namecmp>
801067d2:	83 c4 10             	add    $0x10,%esp
801067d5:	85 c0                	test   %eax,%eax
801067d7:	0f 84 60 01 00 00    	je     8010693d <sys_unlink+0x20b>
801067dd:	83 ec 08             	sub    $0x8,%esp
801067e0:	68 0a 99 10 80       	push   $0x8010990a
801067e5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067e8:	50                   	push   %eax
801067e9:	e8 fd c0 ff ff       	call   801028eb <namecmp>
801067ee:	83 c4 10             	add    $0x10,%esp
801067f1:	85 c0                	test   %eax,%eax
801067f3:	0f 84 44 01 00 00    	je     8010693d <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
801067f9:	83 ec 04             	sub    $0x4,%esp
801067fc:	8d 45 c8             	lea    -0x38(%ebp),%eax
801067ff:	50                   	push   %eax
80106800:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106803:	50                   	push   %eax
80106804:	ff 75 f4             	pushl  -0xc(%ebp)
80106807:	e8 fa c0 ff ff       	call   80102906 <dirlookup>
8010680c:	83 c4 10             	add    $0x10,%esp
8010680f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106812:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106816:	0f 84 20 01 00 00    	je     8010693c <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
8010681c:	83 ec 0c             	sub    $0xc,%esp
8010681f:	ff 75 f0             	pushl  -0x10(%ebp)
80106822:	e8 bb b6 ff ff       	call   80101ee2 <ilock>
80106827:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
8010682a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106831:	66 85 c0             	test   %ax,%ax
80106834:	7f 0d                	jg     80106843 <sys_unlink+0x111>
        panic("unlink: nlink < 1");
80106836:	83 ec 0c             	sub    $0xc,%esp
80106839:	68 0d 99 10 80       	push   $0x8010990d
8010683e:	e8 23 9d ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
80106843:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106846:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010684a:	66 83 f8 01          	cmp    $0x1,%ax
8010684e:	75 25                	jne    80106875 <sys_unlink+0x143>
80106850:	83 ec 0c             	sub    $0xc,%esp
80106853:	ff 75 f0             	pushl  -0x10(%ebp)
80106856:	e8 74 fe ff ff       	call   801066cf <isdirempty>
8010685b:	83 c4 10             	add    $0x10,%esp
8010685e:	85 c0                	test   %eax,%eax
80106860:	75 13                	jne    80106875 <sys_unlink+0x143>
        iunlockput(ip);
80106862:	83 ec 0c             	sub    $0xc,%esp
80106865:	ff 75 f0             	pushl  -0x10(%ebp)
80106868:	e8 78 b9 ff ff       	call   801021e5 <iunlockput>
8010686d:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106870:	e9 c8 00 00 00       	jmp    8010693d <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
80106875:	83 ec 04             	sub    $0x4,%esp
80106878:	6a 10                	push   $0x10
8010687a:	6a 00                	push   $0x0
8010687c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010687f:	50                   	push   %eax
80106880:	e8 45 f5 ff ff       	call   80105dca <memset>
80106885:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106888:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010688b:	6a 10                	push   $0x10
8010688d:	50                   	push   %eax
8010688e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106891:	50                   	push   %eax
80106892:	ff 75 f4             	pushl  -0xc(%ebp)
80106895:	e8 76 be ff ff       	call   80102710 <writei>
8010689a:	83 c4 10             	add    $0x10,%esp
8010689d:	83 f8 10             	cmp    $0x10,%eax
801068a0:	74 0d                	je     801068af <sys_unlink+0x17d>
        panic("unlink: writei");
801068a2:	83 ec 0c             	sub    $0xc,%esp
801068a5:	68 1f 99 10 80       	push   $0x8010991f
801068aa:	e8 b7 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068b6:	66 83 f8 01          	cmp    $0x1,%ax
801068ba:	75 21                	jne    801068dd <sys_unlink+0x1ab>
        dp->nlink--;
801068bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068bf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068c3:	83 e8 01             	sub    $0x1,%eax
801068c6:	89 c2                	mov    %eax,%edx
801068c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068cb:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068cf:	83 ec 0c             	sub    $0xc,%esp
801068d2:	ff 75 f4             	pushl  -0xc(%ebp)
801068d5:	e8 aa b3 ff ff       	call   80101c84 <iupdate>
801068da:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
801068dd:	83 ec 0c             	sub    $0xc,%esp
801068e0:	ff 75 f4             	pushl  -0xc(%ebp)
801068e3:	e8 fd b8 ff ff       	call   801021e5 <iunlockput>
801068e8:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
801068eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ee:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068f2:	83 e8 01             	sub    $0x1,%eax
801068f5:	89 c2                	mov    %eax,%edx
801068f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068fa:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801068fe:	83 ec 0c             	sub    $0xc,%esp
80106901:	ff 75 f0             	pushl  -0x10(%ebp)
80106904:	e8 7b b3 ff ff       	call   80101c84 <iupdate>
80106909:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010690c:	83 ec 0c             	sub    $0xc,%esp
8010690f:	ff 75 f0             	pushl  -0x10(%ebp)
80106912:	e8 ce b8 ff ff       	call   801021e5 <iunlockput>
80106917:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010691a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106920:	8b 40 68             	mov    0x68(%eax),%eax
80106923:	8b 40 50             	mov    0x50(%eax),%eax
80106926:	8b 40 14             	mov    0x14(%eax),%eax
80106929:	83 ec 0c             	sub    $0xc,%esp
8010692c:	50                   	push   %eax
8010692d:	e8 5e d6 ff ff       	call   80103f90 <end_op>
80106932:	83 c4 10             	add    $0x10,%esp

    return 0;
80106935:	b8 00 00 00 00       	mov    $0x0,%eax
8010693a:	eb 2f                	jmp    8010696b <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
8010693c:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
8010693d:	83 ec 0c             	sub    $0xc,%esp
80106940:	ff 75 f4             	pushl  -0xc(%ebp)
80106943:	e8 9d b8 ff ff       	call   801021e5 <iunlockput>
80106948:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
8010694b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106951:	8b 40 68             	mov    0x68(%eax),%eax
80106954:	8b 40 50             	mov    0x50(%eax),%eax
80106957:	8b 40 14             	mov    0x14(%eax),%eax
8010695a:	83 ec 0c             	sub    $0xc,%esp
8010695d:	50                   	push   %eax
8010695e:	e8 2d d6 ff ff       	call   80103f90 <end_op>
80106963:	83 c4 10             	add    $0x10,%esp
    return -1;
80106966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010696b:	c9                   	leave  
8010696c:	c3                   	ret    

8010696d <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
8010696d:	55                   	push   %ebp
8010696e:	89 e5                	mov    %esp,%ebp
80106970:	83 ec 38             	sub    $0x38,%esp
80106973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106976:	8b 55 10             	mov    0x10(%ebp),%edx
80106979:	8b 45 14             	mov    0x14(%ebp),%eax
8010697c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106980:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106984:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
    // cprintf("path %d  \n",path);
    if ((dp = nameiparent(path, name)) == 0)
80106988:	83 ec 08             	sub    $0x8,%esp
8010698b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010698e:	50                   	push   %eax
8010698f:	ff 75 08             	pushl  0x8(%ebp)
80106992:	e8 a3 c3 ff ff       	call   80102d3a <nameiparent>
80106997:	83 c4 10             	add    $0x10,%esp
8010699a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010699d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069a1:	75 0a                	jne    801069ad <create+0x40>
        return 0;
801069a3:	b8 00 00 00 00       	mov    $0x0,%eax
801069a8:	e9 9c 01 00 00       	jmp    80106b49 <create+0x1dc>
    ilock(dp);
801069ad:	83 ec 0c             	sub    $0xc,%esp
801069b0:	ff 75 f4             	pushl  -0xc(%ebp)
801069b3:	e8 2a b5 ff ff       	call   80101ee2 <ilock>
801069b8:	83 c4 10             	add    $0x10,%esp

    if ((ip = dirlookup(dp, name, &off)) != 0) {
801069bb:	83 ec 04             	sub    $0x4,%esp
801069be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069c1:	50                   	push   %eax
801069c2:	8d 45 de             	lea    -0x22(%ebp),%eax
801069c5:	50                   	push   %eax
801069c6:	ff 75 f4             	pushl  -0xc(%ebp)
801069c9:	e8 38 bf ff ff       	call   80102906 <dirlookup>
801069ce:	83 c4 10             	add    $0x10,%esp
801069d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069d8:	74 50                	je     80106a2a <create+0xbd>
        iunlockput(dp);
801069da:	83 ec 0c             	sub    $0xc,%esp
801069dd:	ff 75 f4             	pushl  -0xc(%ebp)
801069e0:	e8 00 b8 ff ff       	call   801021e5 <iunlockput>
801069e5:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801069e8:	83 ec 0c             	sub    $0xc,%esp
801069eb:	ff 75 f0             	pushl  -0x10(%ebp)
801069ee:	e8 ef b4 ff ff       	call   80101ee2 <ilock>
801069f3:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
801069f6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801069fb:	75 15                	jne    80106a12 <create+0xa5>
801069fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a00:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a04:	66 83 f8 02          	cmp    $0x2,%ax
80106a08:	75 08                	jne    80106a12 <create+0xa5>
            return ip;
80106a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0d:	e9 37 01 00 00       	jmp    80106b49 <create+0x1dc>
        iunlockput(ip);
80106a12:	83 ec 0c             	sub    $0xc,%esp
80106a15:	ff 75 f0             	pushl  -0x10(%ebp)
80106a18:	e8 c8 b7 ff ff       	call   801021e5 <iunlockput>
80106a1d:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a20:	b8 00 00 00 00       	mov    $0x0,%eax
80106a25:	e9 1f 01 00 00       	jmp    80106b49 <create+0x1dc>
    }
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2d:	8b 40 50             	mov    0x50(%eax),%eax
80106a30:	8b 40 14             	mov    0x14(%eax),%eax
80106a33:	89 c1                	mov    %eax,%ecx
80106a35:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3c:	8b 00                	mov    (%eax),%eax
80106a3e:	83 ec 04             	sub    $0x4,%esp
80106a41:	51                   	push   %ecx
80106a42:	52                   	push   %edx
80106a43:	50                   	push   %eax
80106a44:	e8 22 b1 ff ff       	call   80101b6b <ialloc>
80106a49:	83 c4 10             	add    $0x10,%esp
80106a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a53:	75 0d                	jne    80106a62 <create+0xf5>
        panic("create: ialloc");
80106a55:	83 ec 0c             	sub    $0xc,%esp
80106a58:	68 2e 99 10 80       	push   $0x8010992e
80106a5d:	e8 04 9b ff ff       	call   80100566 <panic>

    ilock(ip);
80106a62:	83 ec 0c             	sub    $0xc,%esp
80106a65:	ff 75 f0             	pushl  -0x10(%ebp)
80106a68:	e8 75 b4 ff ff       	call   80101ee2 <ilock>
80106a6d:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a73:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a77:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a7e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a82:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a89:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    iupdate(ip);
80106a8f:	83 ec 0c             	sub    $0xc,%esp
80106a92:	ff 75 f0             	pushl  -0x10(%ebp)
80106a95:	e8 ea b1 ff ff       	call   80101c84 <iupdate>
80106a9a:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106a9d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106aa2:	75 6a                	jne    80106b0e <create+0x1a1>
        dp->nlink++;     // for ".."
80106aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106aab:	83 c0 01             	add    $0x1,%eax
80106aae:	89 c2                	mov    %eax,%edx
80106ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab3:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106ab7:	83 ec 0c             	sub    $0xc,%esp
80106aba:	ff 75 f4             	pushl  -0xc(%ebp)
80106abd:	e8 c2 b1 ff ff       	call   80101c84 <iupdate>
80106ac2:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ac8:	8b 40 04             	mov    0x4(%eax),%eax
80106acb:	83 ec 04             	sub    $0x4,%esp
80106ace:	50                   	push   %eax
80106acf:	68 08 99 10 80       	push   $0x80109908
80106ad4:	ff 75 f0             	pushl  -0x10(%ebp)
80106ad7:	e8 f1 be ff ff       	call   801029cd <dirlink>
80106adc:	83 c4 10             	add    $0x10,%esp
80106adf:	85 c0                	test   %eax,%eax
80106ae1:	78 1e                	js     80106b01 <create+0x194>
80106ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae6:	8b 40 04             	mov    0x4(%eax),%eax
80106ae9:	83 ec 04             	sub    $0x4,%esp
80106aec:	50                   	push   %eax
80106aed:	68 0a 99 10 80       	push   $0x8010990a
80106af2:	ff 75 f0             	pushl  -0x10(%ebp)
80106af5:	e8 d3 be ff ff       	call   801029cd <dirlink>
80106afa:	83 c4 10             	add    $0x10,%esp
80106afd:	85 c0                	test   %eax,%eax
80106aff:	79 0d                	jns    80106b0e <create+0x1a1>
            panic("create dots");
80106b01:	83 ec 0c             	sub    $0xc,%esp
80106b04:	68 3d 99 10 80       	push   $0x8010993d
80106b09:	e8 58 9a ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b11:	8b 40 04             	mov    0x4(%eax),%eax
80106b14:	83 ec 04             	sub    $0x4,%esp
80106b17:	50                   	push   %eax
80106b18:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b1b:	50                   	push   %eax
80106b1c:	ff 75 f4             	pushl  -0xc(%ebp)
80106b1f:	e8 a9 be ff ff       	call   801029cd <dirlink>
80106b24:	83 c4 10             	add    $0x10,%esp
80106b27:	85 c0                	test   %eax,%eax
80106b29:	79 0d                	jns    80106b38 <create+0x1cb>
        panic("create: dirlink");
80106b2b:	83 ec 0c             	sub    $0xc,%esp
80106b2e:	68 49 99 10 80       	push   $0x80109949
80106b33:	e8 2e 9a ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b38:	83 ec 0c             	sub    $0xc,%esp
80106b3b:	ff 75 f4             	pushl  -0xc(%ebp)
80106b3e:	e8 a2 b6 ff ff       	call   801021e5 <iunlockput>
80106b43:	83 c4 10             	add    $0x10,%esp

    return ip;
80106b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b49:	c9                   	leave  
80106b4a:	c3                   	ret    

80106b4b <sys_open>:

int sys_open(void)
{
80106b4b:	55                   	push   %ebp
80106b4c:	89 e5                	mov    %esp,%ebp
80106b4e:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b51:	83 ec 08             	sub    $0x8,%esp
80106b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b57:	50                   	push   %eax
80106b58:	6a 00                	push   $0x0
80106b5a:	e8 15 f6 ff ff       	call   80106174 <argstr>
80106b5f:	83 c4 10             	add    $0x10,%esp
80106b62:	85 c0                	test   %eax,%eax
80106b64:	78 15                	js     80106b7b <sys_open+0x30>
80106b66:	83 ec 08             	sub    $0x8,%esp
80106b69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b6c:	50                   	push   %eax
80106b6d:	6a 01                	push   $0x1
80106b6f:	e8 7b f5 ff ff       	call   801060ef <argint>
80106b74:	83 c4 10             	add    $0x10,%esp
80106b77:	85 c0                	test   %eax,%eax
80106b79:	79 07                	jns    80106b82 <sys_open+0x37>
        return -1;
80106b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b80:	eb 13                	jmp    80106b95 <sys_open+0x4a>

    return openFile(path, omode);
80106b82:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b88:	83 ec 08             	sub    $0x8,%esp
80106b8b:	52                   	push   %edx
80106b8c:	50                   	push   %eax
80106b8d:	e8 05 00 00 00       	call   80106b97 <openFile>
80106b92:	83 c4 10             	add    $0x10,%esp
}
80106b95:	c9                   	leave  
80106b96:	c3                   	ret    

80106b97 <openFile>:

int openFile(char* path, int omode)
{
80106b97:	55                   	push   %ebp
80106b98:	89 e5                	mov    %esp,%ebp
80106b9a:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106b9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba3:	8b 40 68             	mov    0x68(%eax),%eax
80106ba6:	8b 40 50             	mov    0x50(%eax),%eax
80106ba9:	8b 40 14             	mov    0x14(%eax),%eax
80106bac:	83 ec 0c             	sub    $0xc,%esp
80106baf:	50                   	push   %eax
80106bb0:	e8 d4 d2 ff ff       	call   80103e89 <begin_op>
80106bb5:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bbb:	25 00 02 00 00       	and    $0x200,%eax
80106bc0:	85 c0                	test   %eax,%eax
80106bc2:	74 43                	je     80106c07 <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106bc4:	6a 00                	push   $0x0
80106bc6:	6a 00                	push   $0x0
80106bc8:	6a 02                	push   $0x2
80106bca:	ff 75 08             	pushl  0x8(%ebp)
80106bcd:	e8 9b fd ff ff       	call   8010696d <create>
80106bd2:	83 c4 10             	add    $0x10,%esp
80106bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106bd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bdc:	0f 85 b5 00 00 00    	jne    80106c97 <openFile+0x100>
            end_op(proc->cwd->part->number);
80106be2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106be8:	8b 40 68             	mov    0x68(%eax),%eax
80106beb:	8b 40 50             	mov    0x50(%eax),%eax
80106bee:	8b 40 14             	mov    0x14(%eax),%eax
80106bf1:	83 ec 0c             	sub    $0xc,%esp
80106bf4:	50                   	push   %eax
80106bf5:	e8 96 d3 ff ff       	call   80103f90 <end_op>
80106bfa:	83 c4 10             	add    $0x10,%esp
            return -1;
80106bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c02:	e9 7f 01 00 00       	jmp    80106d86 <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c07:	83 ec 0c             	sub    $0xc,%esp
80106c0a:	ff 75 08             	pushl  0x8(%ebp)
80106c0d:	e8 f2 c0 ff ff       	call   80102d04 <namei>
80106c12:	83 c4 10             	add    $0x10,%esp
80106c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c18:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c1c:	75 25                	jne    80106c43 <openFile+0xac>
            end_op(proc->cwd->part->number);
80106c1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c24:	8b 40 68             	mov    0x68(%eax),%eax
80106c27:	8b 40 50             	mov    0x50(%eax),%eax
80106c2a:	8b 40 14             	mov    0x14(%eax),%eax
80106c2d:	83 ec 0c             	sub    $0xc,%esp
80106c30:	50                   	push   %eax
80106c31:	e8 5a d3 ff ff       	call   80103f90 <end_op>
80106c36:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c3e:	e9 43 01 00 00       	jmp    80106d86 <openFile+0x1ef>
        }
        ilock(ip);
80106c43:	83 ec 0c             	sub    $0xc,%esp
80106c46:	ff 75 f4             	pushl  -0xc(%ebp)
80106c49:	e8 94 b2 ff ff       	call   80101ee2 <ilock>
80106c4e:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c54:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c58:	66 83 f8 01          	cmp    $0x1,%ax
80106c5c:	75 39                	jne    80106c97 <openFile+0x100>
80106c5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106c62:	74 33                	je     80106c97 <openFile+0x100>
            iunlockput(ip);
80106c64:	83 ec 0c             	sub    $0xc,%esp
80106c67:	ff 75 f4             	pushl  -0xc(%ebp)
80106c6a:	e8 76 b5 ff ff       	call   801021e5 <iunlockput>
80106c6f:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106c72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c78:	8b 40 68             	mov    0x68(%eax),%eax
80106c7b:	8b 40 50             	mov    0x50(%eax),%eax
80106c7e:	8b 40 14             	mov    0x14(%eax),%eax
80106c81:	83 ec 0c             	sub    $0xc,%esp
80106c84:	50                   	push   %eax
80106c85:	e8 06 d3 ff ff       	call   80103f90 <end_op>
80106c8a:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c92:	e9 ef 00 00 00       	jmp    80106d86 <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106c97:	e8 4f a3 ff ff       	call   80100feb <filealloc>
80106c9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ca3:	74 17                	je     80106cbc <openFile+0x125>
80106ca5:	83 ec 0c             	sub    $0xc,%esp
80106ca8:	ff 75 f0             	pushl  -0x10(%ebp)
80106cab:	e8 f0 f5 ff ff       	call   801062a0 <fdalloc>
80106cb0:	83 c4 10             	add    $0x10,%esp
80106cb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106cb6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106cba:	79 47                	jns    80106d03 <openFile+0x16c>
        if (f)
80106cbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cc0:	74 0e                	je     80106cd0 <openFile+0x139>
            fileclose(f);
80106cc2:	83 ec 0c             	sub    $0xc,%esp
80106cc5:	ff 75 f0             	pushl  -0x10(%ebp)
80106cc8:	e8 dc a3 ff ff       	call   801010a9 <fileclose>
80106ccd:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106cd0:	83 ec 0c             	sub    $0xc,%esp
80106cd3:	ff 75 f4             	pushl  -0xc(%ebp)
80106cd6:	e8 0a b5 ff ff       	call   801021e5 <iunlockput>
80106cdb:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106cde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce4:	8b 40 68             	mov    0x68(%eax),%eax
80106ce7:	8b 40 50             	mov    0x50(%eax),%eax
80106cea:	8b 40 14             	mov    0x14(%eax),%eax
80106ced:	83 ec 0c             	sub    $0xc,%esp
80106cf0:	50                   	push   %eax
80106cf1:	e8 9a d2 ff ff       	call   80103f90 <end_op>
80106cf6:	83 c4 10             	add    $0x10,%esp
        return -1;
80106cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cfe:	e9 83 00 00 00       	jmp    80106d86 <openFile+0x1ef>
    }
    iunlock(ip);
80106d03:	83 ec 0c             	sub    $0xc,%esp
80106d06:	ff 75 f4             	pushl  -0xc(%ebp)
80106d09:	e8 75 b3 ff ff       	call   80102083 <iunlock>
80106d0e:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106d11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d17:	8b 40 68             	mov    0x68(%eax),%eax
80106d1a:	8b 40 50             	mov    0x50(%eax),%eax
80106d1d:	8b 40 14             	mov    0x14(%eax),%eax
80106d20:	83 ec 0c             	sub    $0xc,%esp
80106d23:	50                   	push   %eax
80106d24:	e8 67 d2 ff ff       	call   80103f90 <end_op>
80106d29:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d2f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d3b:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d41:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d4b:	83 e0 01             	and    $0x1,%eax
80106d4e:	85 c0                	test   %eax,%eax
80106d50:	0f 94 c0             	sete   %al
80106d53:	89 c2                	mov    %eax,%edx
80106d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d58:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d5e:	83 e0 01             	and    $0x1,%eax
80106d61:	85 c0                	test   %eax,%eax
80106d63:	75 0a                	jne    80106d6f <openFile+0x1d8>
80106d65:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d68:	83 e0 02             	and    $0x2,%eax
80106d6b:	85 c0                	test   %eax,%eax
80106d6d:	74 07                	je     80106d76 <openFile+0x1df>
80106d6f:	b8 01 00 00 00       	mov    $0x1,%eax
80106d74:	eb 05                	jmp    80106d7b <openFile+0x1e4>
80106d76:	b8 00 00 00 00       	mov    $0x0,%eax
80106d7b:	89 c2                	mov    %eax,%edx
80106d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d80:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106d83:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106d86:	c9                   	leave  
80106d87:	c3                   	ret    

80106d88 <sys_mkdir>:

int sys_mkdir(void)
{
80106d88:	55                   	push   %ebp
80106d89:	89 e5                	mov    %esp,%ebp
80106d8b:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106d8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d94:	8b 40 68             	mov    0x68(%eax),%eax
80106d97:	8b 40 50             	mov    0x50(%eax),%eax
80106d9a:	8b 40 14             	mov    0x14(%eax),%eax
80106d9d:	83 ec 0c             	sub    $0xc,%esp
80106da0:	50                   	push   %eax
80106da1:	e8 e3 d0 ff ff       	call   80103e89 <begin_op>
80106da6:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106da9:	83 ec 08             	sub    $0x8,%esp
80106dac:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106daf:	50                   	push   %eax
80106db0:	6a 00                	push   $0x0
80106db2:	e8 bd f3 ff ff       	call   80106174 <argstr>
80106db7:	83 c4 10             	add    $0x10,%esp
80106dba:	85 c0                	test   %eax,%eax
80106dbc:	78 1b                	js     80106dd9 <sys_mkdir+0x51>
80106dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc1:	6a 00                	push   $0x0
80106dc3:	6a 00                	push   $0x0
80106dc5:	6a 01                	push   $0x1
80106dc7:	50                   	push   %eax
80106dc8:	e8 a0 fb ff ff       	call   8010696d <create>
80106dcd:	83 c4 10             	add    $0x10,%esp
80106dd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106dd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106dd7:	75 22                	jne    80106dfb <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106dd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ddf:	8b 40 68             	mov    0x68(%eax),%eax
80106de2:	8b 40 50             	mov    0x50(%eax),%eax
80106de5:	8b 40 14             	mov    0x14(%eax),%eax
80106de8:	83 ec 0c             	sub    $0xc,%esp
80106deb:	50                   	push   %eax
80106dec:	e8 9f d1 ff ff       	call   80103f90 <end_op>
80106df1:	83 c4 10             	add    $0x10,%esp
        return -1;
80106df4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106df9:	eb 2e                	jmp    80106e29 <sys_mkdir+0xa1>
    }
    iunlockput(ip);
80106dfb:	83 ec 0c             	sub    $0xc,%esp
80106dfe:	ff 75 f4             	pushl  -0xc(%ebp)
80106e01:	e8 df b3 ff ff       	call   801021e5 <iunlockput>
80106e06:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e0f:	8b 40 68             	mov    0x68(%eax),%eax
80106e12:	8b 40 50             	mov    0x50(%eax),%eax
80106e15:	8b 40 14             	mov    0x14(%eax),%eax
80106e18:	83 ec 0c             	sub    $0xc,%esp
80106e1b:	50                   	push   %eax
80106e1c:	e8 6f d1 ff ff       	call   80103f90 <end_op>
80106e21:	83 c4 10             	add    $0x10,%esp
    return 0;
80106e24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e29:	c9                   	leave  
80106e2a:	c3                   	ret    

80106e2b <sys_mknod>:

int sys_mknod(void)
{
80106e2b:	55                   	push   %ebp
80106e2c:	89 e5                	mov    %esp,%ebp
80106e2e:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106e31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e37:	8b 40 68             	mov    0x68(%eax),%eax
80106e3a:	8b 40 50             	mov    0x50(%eax),%eax
80106e3d:	8b 40 14             	mov    0x14(%eax),%eax
80106e40:	83 ec 0c             	sub    $0xc,%esp
80106e43:	50                   	push   %eax
80106e44:	e8 40 d0 ff ff       	call   80103e89 <begin_op>
80106e49:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106e4c:	83 ec 08             	sub    $0x8,%esp
80106e4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e52:	50                   	push   %eax
80106e53:	6a 00                	push   $0x0
80106e55:	e8 1a f3 ff ff       	call   80106174 <argstr>
80106e5a:	83 c4 10             	add    $0x10,%esp
80106e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e64:	78 4f                	js     80106eb5 <sys_mknod+0x8a>
80106e66:	83 ec 08             	sub    $0x8,%esp
80106e69:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e6c:	50                   	push   %eax
80106e6d:	6a 01                	push   $0x1
80106e6f:	e8 7b f2 ff ff       	call   801060ef <argint>
80106e74:	83 c4 10             	add    $0x10,%esp
80106e77:	85 c0                	test   %eax,%eax
80106e79:	78 3a                	js     80106eb5 <sys_mknod+0x8a>
80106e7b:	83 ec 08             	sub    $0x8,%esp
80106e7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e81:	50                   	push   %eax
80106e82:	6a 02                	push   $0x2
80106e84:	e8 66 f2 ff ff       	call   801060ef <argint>
80106e89:	83 c4 10             	add    $0x10,%esp
80106e8c:	85 c0                	test   %eax,%eax
80106e8e:	78 25                	js     80106eb5 <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e93:	0f bf c8             	movswl %ax,%ecx
80106e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e99:	0f bf d0             	movswl %ax,%edx
80106e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106e9f:	51                   	push   %ecx
80106ea0:	52                   	push   %edx
80106ea1:	6a 03                	push   $0x3
80106ea3:	50                   	push   %eax
80106ea4:	e8 c4 fa ff ff       	call   8010696d <create>
80106ea9:	83 c4 10             	add    $0x10,%esp
80106eac:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106eaf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106eb3:	75 22                	jne    80106ed7 <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106eb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ebb:	8b 40 68             	mov    0x68(%eax),%eax
80106ebe:	8b 40 50             	mov    0x50(%eax),%eax
80106ec1:	8b 40 14             	mov    0x14(%eax),%eax
80106ec4:	83 ec 0c             	sub    $0xc,%esp
80106ec7:	50                   	push   %eax
80106ec8:	e8 c3 d0 ff ff       	call   80103f90 <end_op>
80106ecd:	83 c4 10             	add    $0x10,%esp
        return -1;
80106ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed5:	eb 2e                	jmp    80106f05 <sys_mknod+0xda>
    }
    iunlockput(ip);
80106ed7:	83 ec 0c             	sub    $0xc,%esp
80106eda:	ff 75 f0             	pushl  -0x10(%ebp)
80106edd:	e8 03 b3 ff ff       	call   801021e5 <iunlockput>
80106ee2:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106ee5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eeb:	8b 40 68             	mov    0x68(%eax),%eax
80106eee:	8b 40 50             	mov    0x50(%eax),%eax
80106ef1:	8b 40 14             	mov    0x14(%eax),%eax
80106ef4:	83 ec 0c             	sub    $0xc,%esp
80106ef7:	50                   	push   %eax
80106ef8:	e8 93 d0 ff ff       	call   80103f90 <end_op>
80106efd:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f00:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f05:	c9                   	leave  
80106f06:	c3                   	ret    

80106f07 <sys_chdir>:

int sys_chdir(void)
{
80106f07:	55                   	push   %ebp
80106f08:	89 e5                	mov    %esp,%ebp
80106f0a:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;


    begin_op(proc->cwd->part->number);
80106f0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f13:	8b 40 68             	mov    0x68(%eax),%eax
80106f16:	8b 40 50             	mov    0x50(%eax),%eax
80106f19:	8b 40 14             	mov    0x14(%eax),%eax
80106f1c:	83 ec 0c             	sub    $0xc,%esp
80106f1f:	50                   	push   %eax
80106f20:	e8 64 cf ff ff       	call   80103e89 <begin_op>
80106f25:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106f28:	83 ec 08             	sub    $0x8,%esp
80106f2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f2e:	50                   	push   %eax
80106f2f:	6a 00                	push   $0x0
80106f31:	e8 3e f2 ff ff       	call   80106174 <argstr>
80106f36:	83 c4 10             	add    $0x10,%esp
80106f39:	85 c0                	test   %eax,%eax
80106f3b:	78 18                	js     80106f55 <sys_chdir+0x4e>
80106f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f40:	83 ec 0c             	sub    $0xc,%esp
80106f43:	50                   	push   %eax
80106f44:	e8 bb bd ff ff       	call   80102d04 <namei>
80106f49:	83 c4 10             	add    $0x10,%esp
80106f4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f53:	75 25                	jne    80106f7a <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106f55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f5b:	8b 40 68             	mov    0x68(%eax),%eax
80106f5e:	8b 40 50             	mov    0x50(%eax),%eax
80106f61:	8b 40 14             	mov    0x14(%eax),%eax
80106f64:	83 ec 0c             	sub    $0xc,%esp
80106f67:	50                   	push   %eax
80106f68:	e8 23 d0 ff ff       	call   80103f90 <end_op>
80106f6d:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f75:	e9 ae 00 00 00       	jmp    80107028 <sys_chdir+0x121>
    }
    cprintf("cd path %s \n",path);
80106f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f7d:	83 ec 08             	sub    $0x8,%esp
80106f80:	50                   	push   %eax
80106f81:	68 59 99 10 80       	push   $0x80109959
80106f86:	e8 3b 94 ff ff       	call   801003c6 <cprintf>
80106f8b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106f8e:	83 ec 0c             	sub    $0xc,%esp
80106f91:	ff 75 f4             	pushl  -0xc(%ebp)
80106f94:	e8 49 af ff ff       	call   80101ee2 <ilock>
80106f99:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
80106f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106fa3:	66 83 f8 01          	cmp    $0x1,%ax
80106fa7:	74 30                	je     80106fd9 <sys_chdir+0xd2>
        iunlockput(ip);
80106fa9:	83 ec 0c             	sub    $0xc,%esp
80106fac:	ff 75 f4             	pushl  -0xc(%ebp)
80106faf:	e8 31 b2 ff ff       	call   801021e5 <iunlockput>
80106fb4:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106fb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fbd:	8b 40 68             	mov    0x68(%eax),%eax
80106fc0:	8b 40 50             	mov    0x50(%eax),%eax
80106fc3:	8b 40 14             	mov    0x14(%eax),%eax
80106fc6:	83 ec 0c             	sub    $0xc,%esp
80106fc9:	50                   	push   %eax
80106fca:	e8 c1 cf ff ff       	call   80103f90 <end_op>
80106fcf:	83 c4 10             	add    $0x10,%esp
        return -1;
80106fd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fd7:	eb 4f                	jmp    80107028 <sys_chdir+0x121>
    }
    iunlock(ip);
80106fd9:	83 ec 0c             	sub    $0xc,%esp
80106fdc:	ff 75 f4             	pushl  -0xc(%ebp)
80106fdf:	e8 9f b0 ff ff       	call   80102083 <iunlock>
80106fe4:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80106fe7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fed:	8b 40 68             	mov    0x68(%eax),%eax
80106ff0:	83 ec 0c             	sub    $0xc,%esp
80106ff3:	50                   	push   %eax
80106ff4:	e8 fc b0 ff ff       	call   801020f5 <iput>
80106ff9:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106ffc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107002:	8b 40 68             	mov    0x68(%eax),%eax
80107005:	8b 40 50             	mov    0x50(%eax),%eax
80107008:	8b 40 14             	mov    0x14(%eax),%eax
8010700b:	83 ec 0c             	sub    $0xc,%esp
8010700e:	50                   	push   %eax
8010700f:	e8 7c cf ff ff       	call   80103f90 <end_op>
80107014:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
80107017:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010701d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107020:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
80107023:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107028:	c9                   	leave  
80107029:	c3                   	ret    

8010702a <sys_exec>:

int sys_exec(void)
{
8010702a:	55                   	push   %ebp
8010702b:	89 e5                	mov    %esp,%ebp
8010702d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
80107033:	83 ec 08             	sub    $0x8,%esp
80107036:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107039:	50                   	push   %eax
8010703a:	6a 00                	push   $0x0
8010703c:	e8 33 f1 ff ff       	call   80106174 <argstr>
80107041:	83 c4 10             	add    $0x10,%esp
80107044:	85 c0                	test   %eax,%eax
80107046:	78 18                	js     80107060 <sys_exec+0x36>
80107048:	83 ec 08             	sub    $0x8,%esp
8010704b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107051:	50                   	push   %eax
80107052:	6a 01                	push   $0x1
80107054:	e8 96 f0 ff ff       	call   801060ef <argint>
80107059:	83 c4 10             	add    $0x10,%esp
8010705c:	85 c0                	test   %eax,%eax
8010705e:	79 0a                	jns    8010706a <sys_exec+0x40>
        return -1;
80107060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107065:	e9 c6 00 00 00       	jmp    80107130 <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
8010706a:	83 ec 04             	sub    $0x4,%esp
8010706d:	68 80 00 00 00       	push   $0x80
80107072:	6a 00                	push   $0x0
80107074:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010707a:	50                   	push   %eax
8010707b:	e8 4a ed ff ff       	call   80105dca <memset>
80107080:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
80107083:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
8010708a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708d:	83 f8 1f             	cmp    $0x1f,%eax
80107090:	76 0a                	jbe    8010709c <sys_exec+0x72>
            return -1;
80107092:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107097:	e9 94 00 00 00       	jmp    80107130 <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
8010709c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709f:	c1 e0 02             	shl    $0x2,%eax
801070a2:	89 c2                	mov    %eax,%edx
801070a4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801070aa:	01 c2                	add    %eax,%edx
801070ac:	83 ec 08             	sub    $0x8,%esp
801070af:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801070b5:	50                   	push   %eax
801070b6:	52                   	push   %edx
801070b7:	e8 97 ef ff ff       	call   80106053 <fetchint>
801070bc:	83 c4 10             	add    $0x10,%esp
801070bf:	85 c0                	test   %eax,%eax
801070c1:	79 07                	jns    801070ca <sys_exec+0xa0>
            return -1;
801070c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c8:	eb 66                	jmp    80107130 <sys_exec+0x106>
        if (uarg == 0) {
801070ca:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801070d0:	85 c0                	test   %eax,%eax
801070d2:	75 27                	jne    801070fb <sys_exec+0xd1>
            argv[i] = 0;
801070d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801070de:	00 00 00 00 
            break;
801070e2:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
801070e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070e6:	83 ec 08             	sub    $0x8,%esp
801070e9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801070ef:	52                   	push   %edx
801070f0:	50                   	push   %eax
801070f1:	e8 7b 9a ff ff       	call   80100b71 <exec>
801070f6:	83 c4 10             	add    $0x10,%esp
801070f9:	eb 35                	jmp    80107130 <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
801070fb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107101:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107104:	c1 e2 02             	shl    $0x2,%edx
80107107:	01 c2                	add    %eax,%edx
80107109:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010710f:	83 ec 08             	sub    $0x8,%esp
80107112:	52                   	push   %edx
80107113:	50                   	push   %eax
80107114:	e8 74 ef ff ff       	call   8010608d <fetchstr>
80107119:	83 c4 10             	add    $0x10,%esp
8010711c:	85 c0                	test   %eax,%eax
8010711e:	79 07                	jns    80107127 <sys_exec+0xfd>
            return -1;
80107120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107125:	eb 09                	jmp    80107130 <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
80107127:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
8010712b:	e9 5a ff ff ff       	jmp    8010708a <sys_exec+0x60>
    return exec(path, argv);
}
80107130:	c9                   	leave  
80107131:	c3                   	ret    

80107132 <sys_pipe>:

int sys_pipe(void)
{
80107132:	55                   	push   %ebp
80107133:	89 e5                	mov    %esp,%ebp
80107135:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
80107138:	83 ec 04             	sub    $0x4,%esp
8010713b:	6a 08                	push   $0x8
8010713d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107140:	50                   	push   %eax
80107141:	6a 00                	push   $0x0
80107143:	e8 cf ef ff ff       	call   80106117 <argptr>
80107148:	83 c4 10             	add    $0x10,%esp
8010714b:	85 c0                	test   %eax,%eax
8010714d:	79 0a                	jns    80107159 <sys_pipe+0x27>
        return -1;
8010714f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107154:	e9 af 00 00 00       	jmp    80107208 <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
80107159:	83 ec 08             	sub    $0x8,%esp
8010715c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010715f:	50                   	push   %eax
80107160:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107163:	50                   	push   %eax
80107164:	e8 f0 d9 ff ff       	call   80104b59 <pipealloc>
80107169:	83 c4 10             	add    $0x10,%esp
8010716c:	85 c0                	test   %eax,%eax
8010716e:	79 0a                	jns    8010717a <sys_pipe+0x48>
        return -1;
80107170:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107175:	e9 8e 00 00 00       	jmp    80107208 <sys_pipe+0xd6>
    fd0 = -1;
8010717a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80107181:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107184:	83 ec 0c             	sub    $0xc,%esp
80107187:	50                   	push   %eax
80107188:	e8 13 f1 ff ff       	call   801062a0 <fdalloc>
8010718d:	83 c4 10             	add    $0x10,%esp
80107190:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107193:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107197:	78 18                	js     801071b1 <sys_pipe+0x7f>
80107199:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010719c:	83 ec 0c             	sub    $0xc,%esp
8010719f:	50                   	push   %eax
801071a0:	e8 fb f0 ff ff       	call   801062a0 <fdalloc>
801071a5:	83 c4 10             	add    $0x10,%esp
801071a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801071ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801071af:	79 3f                	jns    801071f0 <sys_pipe+0xbe>
        if (fd0 >= 0)
801071b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071b5:	78 14                	js     801071cb <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
801071b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071c0:	83 c2 08             	add    $0x8,%edx
801071c3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801071ca:	00 
        fileclose(rf);
801071cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071ce:	83 ec 0c             	sub    $0xc,%esp
801071d1:	50                   	push   %eax
801071d2:	e8 d2 9e ff ff       	call   801010a9 <fileclose>
801071d7:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
801071da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071dd:	83 ec 0c             	sub    $0xc,%esp
801071e0:	50                   	push   %eax
801071e1:	e8 c3 9e ff ff       	call   801010a9 <fileclose>
801071e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801071e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ee:	eb 18                	jmp    80107208 <sys_pipe+0xd6>
    }
    fd[0] = fd0;
801071f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071f6:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
801071f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071fb:	8d 50 04             	lea    0x4(%eax),%edx
801071fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107201:	89 02                	mov    %eax,(%edx)
    return 0;
80107203:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107208:	c9                   	leave  
80107209:	c3                   	ret    

8010720a <sys_mount>:

int sys_mount(void)
{
8010720a:	55                   	push   %ebp
8010720b:	89 e5                	mov    %esp,%ebp
8010720d:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
80107210:	83 ec 08             	sub    $0x8,%esp
80107213:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107216:	50                   	push   %eax
80107217:	6a 00                	push   $0x0
80107219:	e8 56 ef ff ff       	call   80106174 <argstr>
8010721e:	83 c4 10             	add    $0x10,%esp
80107221:	85 c0                	test   %eax,%eax
80107223:	78 1d                	js     80107242 <sys_mount+0x38>
80107225:	83 ec 08             	sub    $0x8,%esp
80107228:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010722b:	50                   	push   %eax
8010722c:	6a 01                	push   $0x1
8010722e:	e8 bc ee ff ff       	call   801060ef <argint>
80107233:	83 c4 10             	add    $0x10,%esp
80107236:	85 c0                	test   %eax,%eax
80107238:	78 08                	js     80107242 <sys_mount+0x38>
8010723a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010723d:	83 f8 04             	cmp    $0x4,%eax
80107240:	76 0a                	jbe    8010724c <sys_mount+0x42>
        return -1;
80107242:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107247:	e9 a4 00 00 00       	jmp    801072f0 <sys_mount+0xe6>
    }
    //cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);

    i=nameiIgnoreMounts(path);
8010724c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010724f:	83 ec 0c             	sub    $0xc,%esp
80107252:	50                   	push   %eax
80107253:	e8 c7 ba ff ff       	call   80102d1f <nameiIgnoreMounts>
80107258:	83 c4 10             	add    $0x10,%esp
8010725b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
8010725e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107262:	75 0a                	jne    8010726e <sys_mount+0x64>
        return -1;
80107264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107269:	e9 82 00 00 00       	jmp    801072f0 <sys_mount+0xe6>
    }
    ilock(i);
8010726e:	83 ec 0c             	sub    $0xc,%esp
80107271:	ff 75 f4             	pushl  -0xc(%ebp)
80107274:	e8 69 ac ff ff       	call   80101ee2 <ilock>
80107279:	83 c4 10             	add    $0x10,%esp
    if(i->type!=T_DIR){
8010727c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107283:	66 83 f8 01          	cmp    $0x1,%ax
80107287:	74 07                	je     80107290 <sys_mount+0x86>
        return -1;
80107289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010728e:	eb 60                	jmp    801072f0 <sys_mount+0xe6>
    }
    i->major=MOUNTING_POINT;
80107290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107293:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
80107299:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010729c:	89 c2                	mov    %eax,%edx
8010729e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a1:	66 89 50 14          	mov    %dx,0x14(%eax)
    begin_op(i->part->number);
801072a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a8:	8b 40 50             	mov    0x50(%eax),%eax
801072ab:	8b 40 14             	mov    0x14(%eax),%eax
801072ae:	83 ec 0c             	sub    $0xc,%esp
801072b1:	50                   	push   %eax
801072b2:	e8 d2 cb ff ff       	call   80103e89 <begin_op>
801072b7:	83 c4 10             	add    $0x10,%esp
    iupdate(i);
801072ba:	83 ec 0c             	sub    $0xc,%esp
801072bd:	ff 75 f4             	pushl  -0xc(%ebp)
801072c0:	e8 bf a9 ff ff       	call   80101c84 <iupdate>
801072c5:	83 c4 10             	add    $0x10,%esp
    end_op(i->part->number);
801072c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cb:	8b 40 50             	mov    0x50(%eax),%eax
801072ce:	8b 40 14             	mov    0x14(%eax),%eax
801072d1:	83 ec 0c             	sub    $0xc,%esp
801072d4:	50                   	push   %eax
801072d5:	e8 b6 cc ff ff       	call   80103f90 <end_op>
801072da:	83 c4 10             	add    $0x10,%esp
    iunlockput(i);
801072dd:	83 ec 0c             	sub    $0xc,%esp
801072e0:	ff 75 f4             	pushl  -0xc(%ebp)
801072e3:	e8 fd ae ff ff       	call   801021e5 <iunlockput>
801072e8:	83 c4 10             	add    $0x10,%esp
   // cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);
    return 0;
801072eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072f0:	c9                   	leave  
801072f1:	c3                   	ret    

801072f2 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801072f2:	55                   	push   %ebp
801072f3:	89 e5                	mov    %esp,%ebp
801072f5:	83 ec 08             	sub    $0x8,%esp
  return fork();
801072f8:	e8 52 df ff ff       	call   8010524f <fork>
}
801072fd:	c9                   	leave  
801072fe:	c3                   	ret    

801072ff <sys_exit>:

int
sys_exit(void)
{
801072ff:	55                   	push   %ebp
80107300:	89 e5                	mov    %esp,%ebp
80107302:	83 ec 08             	sub    $0x8,%esp
  exit();
80107305:	e8 d6 e0 ff ff       	call   801053e0 <exit>
  return 0;  // not reached
8010730a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010730f:	c9                   	leave  
80107310:	c3                   	ret    

80107311 <sys_wait>:

int
sys_wait(void)
{
80107311:	55                   	push   %ebp
80107312:	89 e5                	mov    %esp,%ebp
80107314:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107317:	e8 28 e2 ff ff       	call   80105544 <wait>
}
8010731c:	c9                   	leave  
8010731d:	c3                   	ret    

8010731e <sys_kill>:

int
sys_kill(void)
{
8010731e:	55                   	push   %ebp
8010731f:	89 e5                	mov    %esp,%ebp
80107321:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107324:	83 ec 08             	sub    $0x8,%esp
80107327:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010732a:	50                   	push   %eax
8010732b:	6a 00                	push   $0x0
8010732d:	e8 bd ed ff ff       	call   801060ef <argint>
80107332:	83 c4 10             	add    $0x10,%esp
80107335:	85 c0                	test   %eax,%eax
80107337:	79 07                	jns    80107340 <sys_kill+0x22>
    return -1;
80107339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010733e:	eb 0f                	jmp    8010734f <sys_kill+0x31>
  return kill(pid);
80107340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107343:	83 ec 0c             	sub    $0xc,%esp
80107346:	50                   	push   %eax
80107347:	e8 44 e6 ff ff       	call   80105990 <kill>
8010734c:	83 c4 10             	add    $0x10,%esp
}
8010734f:	c9                   	leave  
80107350:	c3                   	ret    

80107351 <sys_getpid>:

int
sys_getpid(void)
{
80107351:	55                   	push   %ebp
80107352:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010735a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010735d:	5d                   	pop    %ebp
8010735e:	c3                   	ret    

8010735f <sys_sbrk>:

int
sys_sbrk(void)
{
8010735f:	55                   	push   %ebp
80107360:	89 e5                	mov    %esp,%ebp
80107362:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107365:	83 ec 08             	sub    $0x8,%esp
80107368:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010736b:	50                   	push   %eax
8010736c:	6a 00                	push   $0x0
8010736e:	e8 7c ed ff ff       	call   801060ef <argint>
80107373:	83 c4 10             	add    $0x10,%esp
80107376:	85 c0                	test   %eax,%eax
80107378:	79 07                	jns    80107381 <sys_sbrk+0x22>
    return -1;
8010737a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010737f:	eb 28                	jmp    801073a9 <sys_sbrk+0x4a>
  addr = proc->sz;
80107381:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107387:	8b 00                	mov    (%eax),%eax
80107389:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010738c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010738f:	83 ec 0c             	sub    $0xc,%esp
80107392:	50                   	push   %eax
80107393:	e8 14 de ff ff       	call   801051ac <growproc>
80107398:	83 c4 10             	add    $0x10,%esp
8010739b:	85 c0                	test   %eax,%eax
8010739d:	79 07                	jns    801073a6 <sys_sbrk+0x47>
    return -1;
8010739f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073a4:	eb 03                	jmp    801073a9 <sys_sbrk+0x4a>
  return addr;
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801073a9:	c9                   	leave  
801073aa:	c3                   	ret    

801073ab <sys_sleep>:

int
sys_sleep(void)
{
801073ab:	55                   	push   %ebp
801073ac:	89 e5                	mov    %esp,%ebp
801073ae:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801073b1:	83 ec 08             	sub    $0x8,%esp
801073b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073b7:	50                   	push   %eax
801073b8:	6a 00                	push   $0x0
801073ba:	e8 30 ed ff ff       	call   801060ef <argint>
801073bf:	83 c4 10             	add    $0x10,%esp
801073c2:	85 c0                	test   %eax,%eax
801073c4:	79 07                	jns    801073cd <sys_sleep+0x22>
    return -1;
801073c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073cb:	eb 77                	jmp    80107444 <sys_sleep+0x99>
  acquire(&tickslock);
801073cd:	83 ec 0c             	sub    $0xc,%esp
801073d0:	68 c0 5d 11 80       	push   $0x80115dc0
801073d5:	e8 8d e7 ff ff       	call   80105b67 <acquire>
801073da:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801073dd:	a1 00 66 11 80       	mov    0x80116600,%eax
801073e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801073e5:	eb 39                	jmp    80107420 <sys_sleep+0x75>
    if(proc->killed){
801073e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073ed:	8b 40 24             	mov    0x24(%eax),%eax
801073f0:	85 c0                	test   %eax,%eax
801073f2:	74 17                	je     8010740b <sys_sleep+0x60>
      release(&tickslock);
801073f4:	83 ec 0c             	sub    $0xc,%esp
801073f7:	68 c0 5d 11 80       	push   $0x80115dc0
801073fc:	e8 cd e7 ff ff       	call   80105bce <release>
80107401:	83 c4 10             	add    $0x10,%esp
      return -1;
80107404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107409:	eb 39                	jmp    80107444 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
8010740b:	83 ec 08             	sub    $0x8,%esp
8010740e:	68 c0 5d 11 80       	push   $0x80115dc0
80107413:	68 00 66 11 80       	push   $0x80116600
80107418:	e8 51 e4 ff ff       	call   8010586e <sleep>
8010741d:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107420:	a1 00 66 11 80       	mov    0x80116600,%eax
80107425:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107428:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010742b:	39 d0                	cmp    %edx,%eax
8010742d:	72 b8                	jb     801073e7 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010742f:	83 ec 0c             	sub    $0xc,%esp
80107432:	68 c0 5d 11 80       	push   $0x80115dc0
80107437:	e8 92 e7 ff ff       	call   80105bce <release>
8010743c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010743f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107444:	c9                   	leave  
80107445:	c3                   	ret    

80107446 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107446:	55                   	push   %ebp
80107447:	89 e5                	mov    %esp,%ebp
80107449:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010744c:	83 ec 0c             	sub    $0xc,%esp
8010744f:	68 c0 5d 11 80       	push   $0x80115dc0
80107454:	e8 0e e7 ff ff       	call   80105b67 <acquire>
80107459:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010745c:	a1 00 66 11 80       	mov    0x80116600,%eax
80107461:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107464:	83 ec 0c             	sub    $0xc,%esp
80107467:	68 c0 5d 11 80       	push   $0x80115dc0
8010746c:	e8 5d e7 ff ff       	call   80105bce <release>
80107471:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107474:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107477:	c9                   	leave  
80107478:	c3                   	ret    

80107479 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107479:	55                   	push   %ebp
8010747a:	89 e5                	mov    %esp,%ebp
8010747c:	83 ec 08             	sub    $0x8,%esp
8010747f:	8b 55 08             	mov    0x8(%ebp),%edx
80107482:	8b 45 0c             	mov    0xc(%ebp),%eax
80107485:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107489:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010748c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107490:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107494:	ee                   	out    %al,(%dx)
}
80107495:	90                   	nop
80107496:	c9                   	leave  
80107497:	c3                   	ret    

80107498 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107498:	55                   	push   %ebp
80107499:	89 e5                	mov    %esp,%ebp
8010749b:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010749e:	6a 34                	push   $0x34
801074a0:	6a 43                	push   $0x43
801074a2:	e8 d2 ff ff ff       	call   80107479 <outb>
801074a7:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801074aa:	68 9c 00 00 00       	push   $0x9c
801074af:	6a 40                	push   $0x40
801074b1:	e8 c3 ff ff ff       	call   80107479 <outb>
801074b6:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801074b9:	6a 2e                	push   $0x2e
801074bb:	6a 40                	push   $0x40
801074bd:	e8 b7 ff ff ff       	call   80107479 <outb>
801074c2:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801074c5:	83 ec 0c             	sub    $0xc,%esp
801074c8:	6a 00                	push   $0x0
801074ca:	e8 74 d5 ff ff       	call   80104a43 <picenable>
801074cf:	83 c4 10             	add    $0x10,%esp
}
801074d2:	90                   	nop
801074d3:	c9                   	leave  
801074d4:	c3                   	ret    

801074d5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801074d5:	1e                   	push   %ds
  pushl %es
801074d6:	06                   	push   %es
  pushl %fs
801074d7:	0f a0                	push   %fs
  pushl %gs
801074d9:	0f a8                	push   %gs
  pushal
801074db:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801074dc:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801074e0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801074e2:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801074e4:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801074e8:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801074ea:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801074ec:	54                   	push   %esp
  call trap
801074ed:	e8 d7 01 00 00       	call   801076c9 <trap>
  addl $4, %esp
801074f2:	83 c4 04             	add    $0x4,%esp

801074f5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801074f5:	61                   	popa   
  popl %gs
801074f6:	0f a9                	pop    %gs
  popl %fs
801074f8:	0f a1                	pop    %fs
  popl %es
801074fa:	07                   	pop    %es
  popl %ds
801074fb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801074fc:	83 c4 08             	add    $0x8,%esp
  iret
801074ff:	cf                   	iret   

80107500 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107500:	55                   	push   %ebp
80107501:	89 e5                	mov    %esp,%ebp
80107503:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107506:	8b 45 0c             	mov    0xc(%ebp),%eax
80107509:	83 e8 01             	sub    $0x1,%eax
8010750c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107510:	8b 45 08             	mov    0x8(%ebp),%eax
80107513:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107517:	8b 45 08             	mov    0x8(%ebp),%eax
8010751a:	c1 e8 10             	shr    $0x10,%eax
8010751d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107521:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107524:	0f 01 18             	lidtl  (%eax)
}
80107527:	90                   	nop
80107528:	c9                   	leave  
80107529:	c3                   	ret    

8010752a <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010752a:	55                   	push   %ebp
8010752b:	89 e5                	mov    %esp,%ebp
8010752d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107530:	0f 20 d0             	mov    %cr2,%eax
80107533:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107536:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107539:	c9                   	leave  
8010753a:	c3                   	ret    

8010753b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010753b:	55                   	push   %ebp
8010753c:	89 e5                	mov    %esp,%ebp
8010753e:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107541:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107548:	e9 c3 00 00 00       	jmp    80107610 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010754d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107550:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
80107557:	89 c2                	mov    %eax,%edx
80107559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755c:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
80107563:	80 
80107564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107567:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
8010756e:	80 08 00 
80107571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107574:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
8010757b:	80 
8010757c:	83 e2 e0             	and    $0xffffffe0,%edx
8010757f:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
80107586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107589:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107590:	80 
80107591:	83 e2 1f             	and    $0x1f,%edx
80107594:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
8010759b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759e:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075a5:	80 
801075a6:	83 e2 f0             	and    $0xfffffff0,%edx
801075a9:	83 ca 0e             	or     $0xe,%edx
801075ac:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b6:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075bd:	80 
801075be:	83 e2 ef             	and    $0xffffffef,%edx
801075c1:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cb:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075d2:	80 
801075d3:	83 e2 9f             	and    $0xffffff9f,%edx
801075d6:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e0:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075e7:	80 
801075e8:	83 ca 80             	or     $0xffffff80,%edx
801075eb:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f5:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
801075fc:	c1 e8 10             	shr    $0x10,%eax
801075ff:	89 c2                	mov    %eax,%edx
80107601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107604:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
8010760b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010760c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107610:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107617:	0f 8e 30 ff ff ff    	jle    8010754d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010761d:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107622:	66 a3 00 60 11 80    	mov    %ax,0x80116000
80107628:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
8010762f:	08 00 
80107631:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
80107638:	83 e0 e0             	and    $0xffffffe0,%eax
8010763b:	a2 04 60 11 80       	mov    %al,0x80116004
80107640:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
80107647:	83 e0 1f             	and    $0x1f,%eax
8010764a:	a2 04 60 11 80       	mov    %al,0x80116004
8010764f:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107656:	83 c8 0f             	or     $0xf,%eax
80107659:	a2 05 60 11 80       	mov    %al,0x80116005
8010765e:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107665:	83 e0 ef             	and    $0xffffffef,%eax
80107668:	a2 05 60 11 80       	mov    %al,0x80116005
8010766d:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107674:	83 c8 60             	or     $0x60,%eax
80107677:	a2 05 60 11 80       	mov    %al,0x80116005
8010767c:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107683:	83 c8 80             	or     $0xffffff80,%eax
80107686:	a2 05 60 11 80       	mov    %al,0x80116005
8010768b:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107690:	c1 e8 10             	shr    $0x10,%eax
80107693:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
80107699:	83 ec 08             	sub    $0x8,%esp
8010769c:	68 68 99 10 80       	push   $0x80109968
801076a1:	68 c0 5d 11 80       	push   $0x80115dc0
801076a6:	e8 9a e4 ff ff       	call   80105b45 <initlock>
801076ab:	83 c4 10             	add    $0x10,%esp
}
801076ae:	90                   	nop
801076af:	c9                   	leave  
801076b0:	c3                   	ret    

801076b1 <idtinit>:

void
idtinit(void)
{
801076b1:	55                   	push   %ebp
801076b2:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801076b4:	68 00 08 00 00       	push   $0x800
801076b9:	68 00 5e 11 80       	push   $0x80115e00
801076be:	e8 3d fe ff ff       	call   80107500 <lidt>
801076c3:	83 c4 08             	add    $0x8,%esp
}
801076c6:	90                   	nop
801076c7:	c9                   	leave  
801076c8:	c3                   	ret    

801076c9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801076c9:	55                   	push   %ebp
801076ca:	89 e5                	mov    %esp,%ebp
801076cc:	57                   	push   %edi
801076cd:	56                   	push   %esi
801076ce:	53                   	push   %ebx
801076cf:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801076d2:	8b 45 08             	mov    0x8(%ebp),%eax
801076d5:	8b 40 30             	mov    0x30(%eax),%eax
801076d8:	83 f8 40             	cmp    $0x40,%eax
801076db:	75 3e                	jne    8010771b <trap+0x52>
    if(proc->killed)
801076dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076e3:	8b 40 24             	mov    0x24(%eax),%eax
801076e6:	85 c0                	test   %eax,%eax
801076e8:	74 05                	je     801076ef <trap+0x26>
      exit();
801076ea:	e8 f1 dc ff ff       	call   801053e0 <exit>
    proc->tf = tf;
801076ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076f5:	8b 55 08             	mov    0x8(%ebp),%edx
801076f8:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801076fb:	e8 a5 ea ff ff       	call   801061a5 <syscall>
    if(proc->killed)
80107700:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107706:	8b 40 24             	mov    0x24(%eax),%eax
80107709:	85 c0                	test   %eax,%eax
8010770b:	0f 84 1b 02 00 00    	je     8010792c <trap+0x263>
      exit();
80107711:	e8 ca dc ff ff       	call   801053e0 <exit>
    return;
80107716:	e9 11 02 00 00       	jmp    8010792c <trap+0x263>
  }

  switch(tf->trapno){
8010771b:	8b 45 08             	mov    0x8(%ebp),%eax
8010771e:	8b 40 30             	mov    0x30(%eax),%eax
80107721:	83 e8 20             	sub    $0x20,%eax
80107724:	83 f8 1f             	cmp    $0x1f,%eax
80107727:	0f 87 c0 00 00 00    	ja     801077ed <trap+0x124>
8010772d:	8b 04 85 10 9a 10 80 	mov    -0x7fef65f0(,%eax,4),%eax
80107734:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107736:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010773c:	0f b6 00             	movzbl (%eax),%eax
8010773f:	84 c0                	test   %al,%al
80107741:	75 3d                	jne    80107780 <trap+0xb7>
      acquire(&tickslock);
80107743:	83 ec 0c             	sub    $0xc,%esp
80107746:	68 c0 5d 11 80       	push   $0x80115dc0
8010774b:	e8 17 e4 ff ff       	call   80105b67 <acquire>
80107750:	83 c4 10             	add    $0x10,%esp
      ticks++;
80107753:	a1 00 66 11 80       	mov    0x80116600,%eax
80107758:	83 c0 01             	add    $0x1,%eax
8010775b:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
80107760:	83 ec 0c             	sub    $0xc,%esp
80107763:	68 00 66 11 80       	push   $0x80116600
80107768:	e8 ec e1 ff ff       	call   80105959 <wakeup>
8010776d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107770:	83 ec 0c             	sub    $0xc,%esp
80107773:	68 c0 5d 11 80       	push   $0x80115dc0
80107778:	e8 51 e4 ff ff       	call   80105bce <release>
8010777d:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107780:	e8 a5 c0 ff ff       	call   8010382a <lapiceoi>
    break;
80107785:	e9 1c 01 00 00       	jmp    801078a6 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010778a:	e8 ae b8 ff ff       	call   8010303d <ideintr>
    lapiceoi();
8010778f:	e8 96 c0 ff ff       	call   8010382a <lapiceoi>
    break;
80107794:	e9 0d 01 00 00       	jmp    801078a6 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107799:	e8 8e be ff ff       	call   8010362c <kbdintr>
    lapiceoi();
8010779e:	e8 87 c0 ff ff       	call   8010382a <lapiceoi>
    break;
801077a3:	e9 fe 00 00 00       	jmp    801078a6 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801077a8:	e8 60 03 00 00       	call   80107b0d <uartintr>
    lapiceoi();
801077ad:	e8 78 c0 ff ff       	call   8010382a <lapiceoi>
    break;
801077b2:	e9 ef 00 00 00       	jmp    801078a6 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077b7:	8b 45 08             	mov    0x8(%ebp),%eax
801077ba:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801077bd:	8b 45 08             	mov    0x8(%ebp),%eax
801077c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077c4:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801077c7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077cd:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077d0:	0f b6 c0             	movzbl %al,%eax
801077d3:	51                   	push   %ecx
801077d4:	52                   	push   %edx
801077d5:	50                   	push   %eax
801077d6:	68 70 99 10 80       	push   $0x80109970
801077db:	e8 e6 8b ff ff       	call   801003c6 <cprintf>
801077e0:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801077e3:	e8 42 c0 ff ff       	call   8010382a <lapiceoi>
    break;
801077e8:	e9 b9 00 00 00       	jmp    801078a6 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801077ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077f3:	85 c0                	test   %eax,%eax
801077f5:	74 11                	je     80107808 <trap+0x13f>
801077f7:	8b 45 08             	mov    0x8(%ebp),%eax
801077fa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801077fe:	0f b7 c0             	movzwl %ax,%eax
80107801:	83 e0 03             	and    $0x3,%eax
80107804:	85 c0                	test   %eax,%eax
80107806:	75 40                	jne    80107848 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107808:	e8 1d fd ff ff       	call   8010752a <rcr2>
8010780d:	89 c3                	mov    %eax,%ebx
8010780f:	8b 45 08             	mov    0x8(%ebp),%eax
80107812:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107815:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010781b:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010781e:	0f b6 d0             	movzbl %al,%edx
80107821:	8b 45 08             	mov    0x8(%ebp),%eax
80107824:	8b 40 30             	mov    0x30(%eax),%eax
80107827:	83 ec 0c             	sub    $0xc,%esp
8010782a:	53                   	push   %ebx
8010782b:	51                   	push   %ecx
8010782c:	52                   	push   %edx
8010782d:	50                   	push   %eax
8010782e:	68 94 99 10 80       	push   $0x80109994
80107833:	e8 8e 8b ff ff       	call   801003c6 <cprintf>
80107838:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010783b:	83 ec 0c             	sub    $0xc,%esp
8010783e:	68 c6 99 10 80       	push   $0x801099c6
80107843:	e8 1e 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107848:	e8 dd fc ff ff       	call   8010752a <rcr2>
8010784d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107850:	8b 45 08             	mov    0x8(%ebp),%eax
80107853:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107856:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010785c:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010785f:	0f b6 d8             	movzbl %al,%ebx
80107862:	8b 45 08             	mov    0x8(%ebp),%eax
80107865:	8b 48 34             	mov    0x34(%eax),%ecx
80107868:	8b 45 08             	mov    0x8(%ebp),%eax
8010786b:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010786e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107874:	8d 78 6c             	lea    0x6c(%eax),%edi
80107877:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010787d:	8b 40 10             	mov    0x10(%eax),%eax
80107880:	ff 75 e4             	pushl  -0x1c(%ebp)
80107883:	56                   	push   %esi
80107884:	53                   	push   %ebx
80107885:	51                   	push   %ecx
80107886:	52                   	push   %edx
80107887:	57                   	push   %edi
80107888:	50                   	push   %eax
80107889:	68 cc 99 10 80       	push   $0x801099cc
8010788e:	e8 33 8b ff ff       	call   801003c6 <cprintf>
80107893:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107896:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010789c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801078a3:	eb 01                	jmp    801078a6 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801078a5:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801078a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078ac:	85 c0                	test   %eax,%eax
801078ae:	74 24                	je     801078d4 <trap+0x20b>
801078b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078b6:	8b 40 24             	mov    0x24(%eax),%eax
801078b9:	85 c0                	test   %eax,%eax
801078bb:	74 17                	je     801078d4 <trap+0x20b>
801078bd:	8b 45 08             	mov    0x8(%ebp),%eax
801078c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078c4:	0f b7 c0             	movzwl %ax,%eax
801078c7:	83 e0 03             	and    $0x3,%eax
801078ca:	83 f8 03             	cmp    $0x3,%eax
801078cd:	75 05                	jne    801078d4 <trap+0x20b>
    exit();
801078cf:	e8 0c db ff ff       	call   801053e0 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801078d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078da:	85 c0                	test   %eax,%eax
801078dc:	74 1e                	je     801078fc <trap+0x233>
801078de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078e4:	8b 40 0c             	mov    0xc(%eax),%eax
801078e7:	83 f8 04             	cmp    $0x4,%eax
801078ea:	75 10                	jne    801078fc <trap+0x233>
801078ec:	8b 45 08             	mov    0x8(%ebp),%eax
801078ef:	8b 40 30             	mov    0x30(%eax),%eax
801078f2:	83 f8 20             	cmp    $0x20,%eax
801078f5:	75 05                	jne    801078fc <trap+0x233>
    yield();
801078f7:	e8 cd de ff ff       	call   801057c9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801078fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107902:	85 c0                	test   %eax,%eax
80107904:	74 27                	je     8010792d <trap+0x264>
80107906:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010790c:	8b 40 24             	mov    0x24(%eax),%eax
8010790f:	85 c0                	test   %eax,%eax
80107911:	74 1a                	je     8010792d <trap+0x264>
80107913:	8b 45 08             	mov    0x8(%ebp),%eax
80107916:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010791a:	0f b7 c0             	movzwl %ax,%eax
8010791d:	83 e0 03             	and    $0x3,%eax
80107920:	83 f8 03             	cmp    $0x3,%eax
80107923:	75 08                	jne    8010792d <trap+0x264>
    exit();
80107925:	e8 b6 da ff ff       	call   801053e0 <exit>
8010792a:	eb 01                	jmp    8010792d <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010792c:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010792d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107930:	5b                   	pop    %ebx
80107931:	5e                   	pop    %esi
80107932:	5f                   	pop    %edi
80107933:	5d                   	pop    %ebp
80107934:	c3                   	ret    

80107935 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107935:	55                   	push   %ebp
80107936:	89 e5                	mov    %esp,%ebp
80107938:	83 ec 14             	sub    $0x14,%esp
8010793b:	8b 45 08             	mov    0x8(%ebp),%eax
8010793e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107942:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107946:	89 c2                	mov    %eax,%edx
80107948:	ec                   	in     (%dx),%al
80107949:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010794c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107950:	c9                   	leave  
80107951:	c3                   	ret    

80107952 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107952:	55                   	push   %ebp
80107953:	89 e5                	mov    %esp,%ebp
80107955:	83 ec 08             	sub    $0x8,%esp
80107958:	8b 55 08             	mov    0x8(%ebp),%edx
8010795b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010795e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107962:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107965:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107969:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010796d:	ee                   	out    %al,(%dx)
}
8010796e:	90                   	nop
8010796f:	c9                   	leave  
80107970:	c3                   	ret    

80107971 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107971:	55                   	push   %ebp
80107972:	89 e5                	mov    %esp,%ebp
80107974:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107977:	6a 00                	push   $0x0
80107979:	68 fa 03 00 00       	push   $0x3fa
8010797e:	e8 cf ff ff ff       	call   80107952 <outb>
80107983:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107986:	68 80 00 00 00       	push   $0x80
8010798b:	68 fb 03 00 00       	push   $0x3fb
80107990:	e8 bd ff ff ff       	call   80107952 <outb>
80107995:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107998:	6a 0c                	push   $0xc
8010799a:	68 f8 03 00 00       	push   $0x3f8
8010799f:	e8 ae ff ff ff       	call   80107952 <outb>
801079a4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801079a7:	6a 00                	push   $0x0
801079a9:	68 f9 03 00 00       	push   $0x3f9
801079ae:	e8 9f ff ff ff       	call   80107952 <outb>
801079b3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801079b6:	6a 03                	push   $0x3
801079b8:	68 fb 03 00 00       	push   $0x3fb
801079bd:	e8 90 ff ff ff       	call   80107952 <outb>
801079c2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801079c5:	6a 00                	push   $0x0
801079c7:	68 fc 03 00 00       	push   $0x3fc
801079cc:	e8 81 ff ff ff       	call   80107952 <outb>
801079d1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801079d4:	6a 01                	push   $0x1
801079d6:	68 f9 03 00 00       	push   $0x3f9
801079db:	e8 72 ff ff ff       	call   80107952 <outb>
801079e0:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801079e3:	68 fd 03 00 00       	push   $0x3fd
801079e8:	e8 48 ff ff ff       	call   80107935 <inb>
801079ed:	83 c4 04             	add    $0x4,%esp
801079f0:	3c ff                	cmp    $0xff,%al
801079f2:	74 6e                	je     80107a62 <uartinit+0xf1>
    return;
  uart = 1;
801079f4:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
801079fb:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801079fe:	68 fa 03 00 00       	push   $0x3fa
80107a03:	e8 2d ff ff ff       	call   80107935 <inb>
80107a08:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107a0b:	68 f8 03 00 00       	push   $0x3f8
80107a10:	e8 20 ff ff ff       	call   80107935 <inb>
80107a15:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107a18:	83 ec 0c             	sub    $0xc,%esp
80107a1b:	6a 04                	push   $0x4
80107a1d:	e8 21 d0 ff ff       	call   80104a43 <picenable>
80107a22:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107a25:	83 ec 08             	sub    $0x8,%esp
80107a28:	6a 00                	push   $0x0
80107a2a:	6a 04                	push   $0x4
80107a2c:	e8 ae b8 ff ff       	call   801032df <ioapicenable>
80107a31:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a34:	c7 45 f4 90 9a 10 80 	movl   $0x80109a90,-0xc(%ebp)
80107a3b:	eb 19                	jmp    80107a56 <uartinit+0xe5>
    uartputc(*p);
80107a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a40:	0f b6 00             	movzbl (%eax),%eax
80107a43:	0f be c0             	movsbl %al,%eax
80107a46:	83 ec 0c             	sub    $0xc,%esp
80107a49:	50                   	push   %eax
80107a4a:	e8 16 00 00 00       	call   80107a65 <uartputc>
80107a4f:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a52:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a59:	0f b6 00             	movzbl (%eax),%eax
80107a5c:	84 c0                	test   %al,%al
80107a5e:	75 dd                	jne    80107a3d <uartinit+0xcc>
80107a60:	eb 01                	jmp    80107a63 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107a62:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107a63:	c9                   	leave  
80107a64:	c3                   	ret    

80107a65 <uartputc>:

void
uartputc(int c)
{
80107a65:	55                   	push   %ebp
80107a66:	89 e5                	mov    %esp,%ebp
80107a68:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a6b:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a70:	85 c0                	test   %eax,%eax
80107a72:	74 53                	je     80107ac7 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a7b:	eb 11                	jmp    80107a8e <uartputc+0x29>
    microdelay(10);
80107a7d:	83 ec 0c             	sub    $0xc,%esp
80107a80:	6a 0a                	push   $0xa
80107a82:	e8 be bd ff ff       	call   80103845 <microdelay>
80107a87:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a8e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a92:	7f 1a                	jg     80107aae <uartputc+0x49>
80107a94:	83 ec 0c             	sub    $0xc,%esp
80107a97:	68 fd 03 00 00       	push   $0x3fd
80107a9c:	e8 94 fe ff ff       	call   80107935 <inb>
80107aa1:	83 c4 10             	add    $0x10,%esp
80107aa4:	0f b6 c0             	movzbl %al,%eax
80107aa7:	83 e0 20             	and    $0x20,%eax
80107aaa:	85 c0                	test   %eax,%eax
80107aac:	74 cf                	je     80107a7d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107aae:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab1:	0f b6 c0             	movzbl %al,%eax
80107ab4:	83 ec 08             	sub    $0x8,%esp
80107ab7:	50                   	push   %eax
80107ab8:	68 f8 03 00 00       	push   $0x3f8
80107abd:	e8 90 fe ff ff       	call   80107952 <outb>
80107ac2:	83 c4 10             	add    $0x10,%esp
80107ac5:	eb 01                	jmp    80107ac8 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107ac7:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107ac8:	c9                   	leave  
80107ac9:	c3                   	ret    

80107aca <uartgetc>:

static int
uartgetc(void)
{
80107aca:	55                   	push   %ebp
80107acb:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107acd:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107ad2:	85 c0                	test   %eax,%eax
80107ad4:	75 07                	jne    80107add <uartgetc+0x13>
    return -1;
80107ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107adb:	eb 2e                	jmp    80107b0b <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107add:	68 fd 03 00 00       	push   $0x3fd
80107ae2:	e8 4e fe ff ff       	call   80107935 <inb>
80107ae7:	83 c4 04             	add    $0x4,%esp
80107aea:	0f b6 c0             	movzbl %al,%eax
80107aed:	83 e0 01             	and    $0x1,%eax
80107af0:	85 c0                	test   %eax,%eax
80107af2:	75 07                	jne    80107afb <uartgetc+0x31>
    return -1;
80107af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107af9:	eb 10                	jmp    80107b0b <uartgetc+0x41>
  return inb(COM1+0);
80107afb:	68 f8 03 00 00       	push   $0x3f8
80107b00:	e8 30 fe ff ff       	call   80107935 <inb>
80107b05:	83 c4 04             	add    $0x4,%esp
80107b08:	0f b6 c0             	movzbl %al,%eax
}
80107b0b:	c9                   	leave  
80107b0c:	c3                   	ret    

80107b0d <uartintr>:

void
uartintr(void)
{
80107b0d:	55                   	push   %ebp
80107b0e:	89 e5                	mov    %esp,%ebp
80107b10:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107b13:	83 ec 0c             	sub    $0xc,%esp
80107b16:	68 ca 7a 10 80       	push   $0x80107aca
80107b1b:	e8 d9 8c ff ff       	call   801007f9 <consoleintr>
80107b20:	83 c4 10             	add    $0x10,%esp
}
80107b23:	90                   	nop
80107b24:	c9                   	leave  
80107b25:	c3                   	ret    

80107b26 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $0
80107b28:	6a 00                	push   $0x0
  jmp alltraps
80107b2a:	e9 a6 f9 ff ff       	jmp    801074d5 <alltraps>

80107b2f <vector1>:
.globl vector1
vector1:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $1
80107b31:	6a 01                	push   $0x1
  jmp alltraps
80107b33:	e9 9d f9 ff ff       	jmp    801074d5 <alltraps>

80107b38 <vector2>:
.globl vector2
vector2:
  pushl $0
80107b38:	6a 00                	push   $0x0
  pushl $2
80107b3a:	6a 02                	push   $0x2
  jmp alltraps
80107b3c:	e9 94 f9 ff ff       	jmp    801074d5 <alltraps>

80107b41 <vector3>:
.globl vector3
vector3:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $3
80107b43:	6a 03                	push   $0x3
  jmp alltraps
80107b45:	e9 8b f9 ff ff       	jmp    801074d5 <alltraps>

80107b4a <vector4>:
.globl vector4
vector4:
  pushl $0
80107b4a:	6a 00                	push   $0x0
  pushl $4
80107b4c:	6a 04                	push   $0x4
  jmp alltraps
80107b4e:	e9 82 f9 ff ff       	jmp    801074d5 <alltraps>

80107b53 <vector5>:
.globl vector5
vector5:
  pushl $0
80107b53:	6a 00                	push   $0x0
  pushl $5
80107b55:	6a 05                	push   $0x5
  jmp alltraps
80107b57:	e9 79 f9 ff ff       	jmp    801074d5 <alltraps>

80107b5c <vector6>:
.globl vector6
vector6:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $6
80107b5e:	6a 06                	push   $0x6
  jmp alltraps
80107b60:	e9 70 f9 ff ff       	jmp    801074d5 <alltraps>

80107b65 <vector7>:
.globl vector7
vector7:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $7
80107b67:	6a 07                	push   $0x7
  jmp alltraps
80107b69:	e9 67 f9 ff ff       	jmp    801074d5 <alltraps>

80107b6e <vector8>:
.globl vector8
vector8:
  pushl $8
80107b6e:	6a 08                	push   $0x8
  jmp alltraps
80107b70:	e9 60 f9 ff ff       	jmp    801074d5 <alltraps>

80107b75 <vector9>:
.globl vector9
vector9:
  pushl $0
80107b75:	6a 00                	push   $0x0
  pushl $9
80107b77:	6a 09                	push   $0x9
  jmp alltraps
80107b79:	e9 57 f9 ff ff       	jmp    801074d5 <alltraps>

80107b7e <vector10>:
.globl vector10
vector10:
  pushl $10
80107b7e:	6a 0a                	push   $0xa
  jmp alltraps
80107b80:	e9 50 f9 ff ff       	jmp    801074d5 <alltraps>

80107b85 <vector11>:
.globl vector11
vector11:
  pushl $11
80107b85:	6a 0b                	push   $0xb
  jmp alltraps
80107b87:	e9 49 f9 ff ff       	jmp    801074d5 <alltraps>

80107b8c <vector12>:
.globl vector12
vector12:
  pushl $12
80107b8c:	6a 0c                	push   $0xc
  jmp alltraps
80107b8e:	e9 42 f9 ff ff       	jmp    801074d5 <alltraps>

80107b93 <vector13>:
.globl vector13
vector13:
  pushl $13
80107b93:	6a 0d                	push   $0xd
  jmp alltraps
80107b95:	e9 3b f9 ff ff       	jmp    801074d5 <alltraps>

80107b9a <vector14>:
.globl vector14
vector14:
  pushl $14
80107b9a:	6a 0e                	push   $0xe
  jmp alltraps
80107b9c:	e9 34 f9 ff ff       	jmp    801074d5 <alltraps>

80107ba1 <vector15>:
.globl vector15
vector15:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $15
80107ba3:	6a 0f                	push   $0xf
  jmp alltraps
80107ba5:	e9 2b f9 ff ff       	jmp    801074d5 <alltraps>

80107baa <vector16>:
.globl vector16
vector16:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $16
80107bac:	6a 10                	push   $0x10
  jmp alltraps
80107bae:	e9 22 f9 ff ff       	jmp    801074d5 <alltraps>

80107bb3 <vector17>:
.globl vector17
vector17:
  pushl $17
80107bb3:	6a 11                	push   $0x11
  jmp alltraps
80107bb5:	e9 1b f9 ff ff       	jmp    801074d5 <alltraps>

80107bba <vector18>:
.globl vector18
vector18:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $18
80107bbc:	6a 12                	push   $0x12
  jmp alltraps
80107bbe:	e9 12 f9 ff ff       	jmp    801074d5 <alltraps>

80107bc3 <vector19>:
.globl vector19
vector19:
  pushl $0
80107bc3:	6a 00                	push   $0x0
  pushl $19
80107bc5:	6a 13                	push   $0x13
  jmp alltraps
80107bc7:	e9 09 f9 ff ff       	jmp    801074d5 <alltraps>

80107bcc <vector20>:
.globl vector20
vector20:
  pushl $0
80107bcc:	6a 00                	push   $0x0
  pushl $20
80107bce:	6a 14                	push   $0x14
  jmp alltraps
80107bd0:	e9 00 f9 ff ff       	jmp    801074d5 <alltraps>

80107bd5 <vector21>:
.globl vector21
vector21:
  pushl $0
80107bd5:	6a 00                	push   $0x0
  pushl $21
80107bd7:	6a 15                	push   $0x15
  jmp alltraps
80107bd9:	e9 f7 f8 ff ff       	jmp    801074d5 <alltraps>

80107bde <vector22>:
.globl vector22
vector22:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $22
80107be0:	6a 16                	push   $0x16
  jmp alltraps
80107be2:	e9 ee f8 ff ff       	jmp    801074d5 <alltraps>

80107be7 <vector23>:
.globl vector23
vector23:
  pushl $0
80107be7:	6a 00                	push   $0x0
  pushl $23
80107be9:	6a 17                	push   $0x17
  jmp alltraps
80107beb:	e9 e5 f8 ff ff       	jmp    801074d5 <alltraps>

80107bf0 <vector24>:
.globl vector24
vector24:
  pushl $0
80107bf0:	6a 00                	push   $0x0
  pushl $24
80107bf2:	6a 18                	push   $0x18
  jmp alltraps
80107bf4:	e9 dc f8 ff ff       	jmp    801074d5 <alltraps>

80107bf9 <vector25>:
.globl vector25
vector25:
  pushl $0
80107bf9:	6a 00                	push   $0x0
  pushl $25
80107bfb:	6a 19                	push   $0x19
  jmp alltraps
80107bfd:	e9 d3 f8 ff ff       	jmp    801074d5 <alltraps>

80107c02 <vector26>:
.globl vector26
vector26:
  pushl $0
80107c02:	6a 00                	push   $0x0
  pushl $26
80107c04:	6a 1a                	push   $0x1a
  jmp alltraps
80107c06:	e9 ca f8 ff ff       	jmp    801074d5 <alltraps>

80107c0b <vector27>:
.globl vector27
vector27:
  pushl $0
80107c0b:	6a 00                	push   $0x0
  pushl $27
80107c0d:	6a 1b                	push   $0x1b
  jmp alltraps
80107c0f:	e9 c1 f8 ff ff       	jmp    801074d5 <alltraps>

80107c14 <vector28>:
.globl vector28
vector28:
  pushl $0
80107c14:	6a 00                	push   $0x0
  pushl $28
80107c16:	6a 1c                	push   $0x1c
  jmp alltraps
80107c18:	e9 b8 f8 ff ff       	jmp    801074d5 <alltraps>

80107c1d <vector29>:
.globl vector29
vector29:
  pushl $0
80107c1d:	6a 00                	push   $0x0
  pushl $29
80107c1f:	6a 1d                	push   $0x1d
  jmp alltraps
80107c21:	e9 af f8 ff ff       	jmp    801074d5 <alltraps>

80107c26 <vector30>:
.globl vector30
vector30:
  pushl $0
80107c26:	6a 00                	push   $0x0
  pushl $30
80107c28:	6a 1e                	push   $0x1e
  jmp alltraps
80107c2a:	e9 a6 f8 ff ff       	jmp    801074d5 <alltraps>

80107c2f <vector31>:
.globl vector31
vector31:
  pushl $0
80107c2f:	6a 00                	push   $0x0
  pushl $31
80107c31:	6a 1f                	push   $0x1f
  jmp alltraps
80107c33:	e9 9d f8 ff ff       	jmp    801074d5 <alltraps>

80107c38 <vector32>:
.globl vector32
vector32:
  pushl $0
80107c38:	6a 00                	push   $0x0
  pushl $32
80107c3a:	6a 20                	push   $0x20
  jmp alltraps
80107c3c:	e9 94 f8 ff ff       	jmp    801074d5 <alltraps>

80107c41 <vector33>:
.globl vector33
vector33:
  pushl $0
80107c41:	6a 00                	push   $0x0
  pushl $33
80107c43:	6a 21                	push   $0x21
  jmp alltraps
80107c45:	e9 8b f8 ff ff       	jmp    801074d5 <alltraps>

80107c4a <vector34>:
.globl vector34
vector34:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $34
80107c4c:	6a 22                	push   $0x22
  jmp alltraps
80107c4e:	e9 82 f8 ff ff       	jmp    801074d5 <alltraps>

80107c53 <vector35>:
.globl vector35
vector35:
  pushl $0
80107c53:	6a 00                	push   $0x0
  pushl $35
80107c55:	6a 23                	push   $0x23
  jmp alltraps
80107c57:	e9 79 f8 ff ff       	jmp    801074d5 <alltraps>

80107c5c <vector36>:
.globl vector36
vector36:
  pushl $0
80107c5c:	6a 00                	push   $0x0
  pushl $36
80107c5e:	6a 24                	push   $0x24
  jmp alltraps
80107c60:	e9 70 f8 ff ff       	jmp    801074d5 <alltraps>

80107c65 <vector37>:
.globl vector37
vector37:
  pushl $0
80107c65:	6a 00                	push   $0x0
  pushl $37
80107c67:	6a 25                	push   $0x25
  jmp alltraps
80107c69:	e9 67 f8 ff ff       	jmp    801074d5 <alltraps>

80107c6e <vector38>:
.globl vector38
vector38:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $38
80107c70:	6a 26                	push   $0x26
  jmp alltraps
80107c72:	e9 5e f8 ff ff       	jmp    801074d5 <alltraps>

80107c77 <vector39>:
.globl vector39
vector39:
  pushl $0
80107c77:	6a 00                	push   $0x0
  pushl $39
80107c79:	6a 27                	push   $0x27
  jmp alltraps
80107c7b:	e9 55 f8 ff ff       	jmp    801074d5 <alltraps>

80107c80 <vector40>:
.globl vector40
vector40:
  pushl $0
80107c80:	6a 00                	push   $0x0
  pushl $40
80107c82:	6a 28                	push   $0x28
  jmp alltraps
80107c84:	e9 4c f8 ff ff       	jmp    801074d5 <alltraps>

80107c89 <vector41>:
.globl vector41
vector41:
  pushl $0
80107c89:	6a 00                	push   $0x0
  pushl $41
80107c8b:	6a 29                	push   $0x29
  jmp alltraps
80107c8d:	e9 43 f8 ff ff       	jmp    801074d5 <alltraps>

80107c92 <vector42>:
.globl vector42
vector42:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $42
80107c94:	6a 2a                	push   $0x2a
  jmp alltraps
80107c96:	e9 3a f8 ff ff       	jmp    801074d5 <alltraps>

80107c9b <vector43>:
.globl vector43
vector43:
  pushl $0
80107c9b:	6a 00                	push   $0x0
  pushl $43
80107c9d:	6a 2b                	push   $0x2b
  jmp alltraps
80107c9f:	e9 31 f8 ff ff       	jmp    801074d5 <alltraps>

80107ca4 <vector44>:
.globl vector44
vector44:
  pushl $0
80107ca4:	6a 00                	push   $0x0
  pushl $44
80107ca6:	6a 2c                	push   $0x2c
  jmp alltraps
80107ca8:	e9 28 f8 ff ff       	jmp    801074d5 <alltraps>

80107cad <vector45>:
.globl vector45
vector45:
  pushl $0
80107cad:	6a 00                	push   $0x0
  pushl $45
80107caf:	6a 2d                	push   $0x2d
  jmp alltraps
80107cb1:	e9 1f f8 ff ff       	jmp    801074d5 <alltraps>

80107cb6 <vector46>:
.globl vector46
vector46:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $46
80107cb8:	6a 2e                	push   $0x2e
  jmp alltraps
80107cba:	e9 16 f8 ff ff       	jmp    801074d5 <alltraps>

80107cbf <vector47>:
.globl vector47
vector47:
  pushl $0
80107cbf:	6a 00                	push   $0x0
  pushl $47
80107cc1:	6a 2f                	push   $0x2f
  jmp alltraps
80107cc3:	e9 0d f8 ff ff       	jmp    801074d5 <alltraps>

80107cc8 <vector48>:
.globl vector48
vector48:
  pushl $0
80107cc8:	6a 00                	push   $0x0
  pushl $48
80107cca:	6a 30                	push   $0x30
  jmp alltraps
80107ccc:	e9 04 f8 ff ff       	jmp    801074d5 <alltraps>

80107cd1 <vector49>:
.globl vector49
vector49:
  pushl $0
80107cd1:	6a 00                	push   $0x0
  pushl $49
80107cd3:	6a 31                	push   $0x31
  jmp alltraps
80107cd5:	e9 fb f7 ff ff       	jmp    801074d5 <alltraps>

80107cda <vector50>:
.globl vector50
vector50:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $50
80107cdc:	6a 32                	push   $0x32
  jmp alltraps
80107cde:	e9 f2 f7 ff ff       	jmp    801074d5 <alltraps>

80107ce3 <vector51>:
.globl vector51
vector51:
  pushl $0
80107ce3:	6a 00                	push   $0x0
  pushl $51
80107ce5:	6a 33                	push   $0x33
  jmp alltraps
80107ce7:	e9 e9 f7 ff ff       	jmp    801074d5 <alltraps>

80107cec <vector52>:
.globl vector52
vector52:
  pushl $0
80107cec:	6a 00                	push   $0x0
  pushl $52
80107cee:	6a 34                	push   $0x34
  jmp alltraps
80107cf0:	e9 e0 f7 ff ff       	jmp    801074d5 <alltraps>

80107cf5 <vector53>:
.globl vector53
vector53:
  pushl $0
80107cf5:	6a 00                	push   $0x0
  pushl $53
80107cf7:	6a 35                	push   $0x35
  jmp alltraps
80107cf9:	e9 d7 f7 ff ff       	jmp    801074d5 <alltraps>

80107cfe <vector54>:
.globl vector54
vector54:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $54
80107d00:	6a 36                	push   $0x36
  jmp alltraps
80107d02:	e9 ce f7 ff ff       	jmp    801074d5 <alltraps>

80107d07 <vector55>:
.globl vector55
vector55:
  pushl $0
80107d07:	6a 00                	push   $0x0
  pushl $55
80107d09:	6a 37                	push   $0x37
  jmp alltraps
80107d0b:	e9 c5 f7 ff ff       	jmp    801074d5 <alltraps>

80107d10 <vector56>:
.globl vector56
vector56:
  pushl $0
80107d10:	6a 00                	push   $0x0
  pushl $56
80107d12:	6a 38                	push   $0x38
  jmp alltraps
80107d14:	e9 bc f7 ff ff       	jmp    801074d5 <alltraps>

80107d19 <vector57>:
.globl vector57
vector57:
  pushl $0
80107d19:	6a 00                	push   $0x0
  pushl $57
80107d1b:	6a 39                	push   $0x39
  jmp alltraps
80107d1d:	e9 b3 f7 ff ff       	jmp    801074d5 <alltraps>

80107d22 <vector58>:
.globl vector58
vector58:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $58
80107d24:	6a 3a                	push   $0x3a
  jmp alltraps
80107d26:	e9 aa f7 ff ff       	jmp    801074d5 <alltraps>

80107d2b <vector59>:
.globl vector59
vector59:
  pushl $0
80107d2b:	6a 00                	push   $0x0
  pushl $59
80107d2d:	6a 3b                	push   $0x3b
  jmp alltraps
80107d2f:	e9 a1 f7 ff ff       	jmp    801074d5 <alltraps>

80107d34 <vector60>:
.globl vector60
vector60:
  pushl $0
80107d34:	6a 00                	push   $0x0
  pushl $60
80107d36:	6a 3c                	push   $0x3c
  jmp alltraps
80107d38:	e9 98 f7 ff ff       	jmp    801074d5 <alltraps>

80107d3d <vector61>:
.globl vector61
vector61:
  pushl $0
80107d3d:	6a 00                	push   $0x0
  pushl $61
80107d3f:	6a 3d                	push   $0x3d
  jmp alltraps
80107d41:	e9 8f f7 ff ff       	jmp    801074d5 <alltraps>

80107d46 <vector62>:
.globl vector62
vector62:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $62
80107d48:	6a 3e                	push   $0x3e
  jmp alltraps
80107d4a:	e9 86 f7 ff ff       	jmp    801074d5 <alltraps>

80107d4f <vector63>:
.globl vector63
vector63:
  pushl $0
80107d4f:	6a 00                	push   $0x0
  pushl $63
80107d51:	6a 3f                	push   $0x3f
  jmp alltraps
80107d53:	e9 7d f7 ff ff       	jmp    801074d5 <alltraps>

80107d58 <vector64>:
.globl vector64
vector64:
  pushl $0
80107d58:	6a 00                	push   $0x0
  pushl $64
80107d5a:	6a 40                	push   $0x40
  jmp alltraps
80107d5c:	e9 74 f7 ff ff       	jmp    801074d5 <alltraps>

80107d61 <vector65>:
.globl vector65
vector65:
  pushl $0
80107d61:	6a 00                	push   $0x0
  pushl $65
80107d63:	6a 41                	push   $0x41
  jmp alltraps
80107d65:	e9 6b f7 ff ff       	jmp    801074d5 <alltraps>

80107d6a <vector66>:
.globl vector66
vector66:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $66
80107d6c:	6a 42                	push   $0x42
  jmp alltraps
80107d6e:	e9 62 f7 ff ff       	jmp    801074d5 <alltraps>

80107d73 <vector67>:
.globl vector67
vector67:
  pushl $0
80107d73:	6a 00                	push   $0x0
  pushl $67
80107d75:	6a 43                	push   $0x43
  jmp alltraps
80107d77:	e9 59 f7 ff ff       	jmp    801074d5 <alltraps>

80107d7c <vector68>:
.globl vector68
vector68:
  pushl $0
80107d7c:	6a 00                	push   $0x0
  pushl $68
80107d7e:	6a 44                	push   $0x44
  jmp alltraps
80107d80:	e9 50 f7 ff ff       	jmp    801074d5 <alltraps>

80107d85 <vector69>:
.globl vector69
vector69:
  pushl $0
80107d85:	6a 00                	push   $0x0
  pushl $69
80107d87:	6a 45                	push   $0x45
  jmp alltraps
80107d89:	e9 47 f7 ff ff       	jmp    801074d5 <alltraps>

80107d8e <vector70>:
.globl vector70
vector70:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $70
80107d90:	6a 46                	push   $0x46
  jmp alltraps
80107d92:	e9 3e f7 ff ff       	jmp    801074d5 <alltraps>

80107d97 <vector71>:
.globl vector71
vector71:
  pushl $0
80107d97:	6a 00                	push   $0x0
  pushl $71
80107d99:	6a 47                	push   $0x47
  jmp alltraps
80107d9b:	e9 35 f7 ff ff       	jmp    801074d5 <alltraps>

80107da0 <vector72>:
.globl vector72
vector72:
  pushl $0
80107da0:	6a 00                	push   $0x0
  pushl $72
80107da2:	6a 48                	push   $0x48
  jmp alltraps
80107da4:	e9 2c f7 ff ff       	jmp    801074d5 <alltraps>

80107da9 <vector73>:
.globl vector73
vector73:
  pushl $0
80107da9:	6a 00                	push   $0x0
  pushl $73
80107dab:	6a 49                	push   $0x49
  jmp alltraps
80107dad:	e9 23 f7 ff ff       	jmp    801074d5 <alltraps>

80107db2 <vector74>:
.globl vector74
vector74:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $74
80107db4:	6a 4a                	push   $0x4a
  jmp alltraps
80107db6:	e9 1a f7 ff ff       	jmp    801074d5 <alltraps>

80107dbb <vector75>:
.globl vector75
vector75:
  pushl $0
80107dbb:	6a 00                	push   $0x0
  pushl $75
80107dbd:	6a 4b                	push   $0x4b
  jmp alltraps
80107dbf:	e9 11 f7 ff ff       	jmp    801074d5 <alltraps>

80107dc4 <vector76>:
.globl vector76
vector76:
  pushl $0
80107dc4:	6a 00                	push   $0x0
  pushl $76
80107dc6:	6a 4c                	push   $0x4c
  jmp alltraps
80107dc8:	e9 08 f7 ff ff       	jmp    801074d5 <alltraps>

80107dcd <vector77>:
.globl vector77
vector77:
  pushl $0
80107dcd:	6a 00                	push   $0x0
  pushl $77
80107dcf:	6a 4d                	push   $0x4d
  jmp alltraps
80107dd1:	e9 ff f6 ff ff       	jmp    801074d5 <alltraps>

80107dd6 <vector78>:
.globl vector78
vector78:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $78
80107dd8:	6a 4e                	push   $0x4e
  jmp alltraps
80107dda:	e9 f6 f6 ff ff       	jmp    801074d5 <alltraps>

80107ddf <vector79>:
.globl vector79
vector79:
  pushl $0
80107ddf:	6a 00                	push   $0x0
  pushl $79
80107de1:	6a 4f                	push   $0x4f
  jmp alltraps
80107de3:	e9 ed f6 ff ff       	jmp    801074d5 <alltraps>

80107de8 <vector80>:
.globl vector80
vector80:
  pushl $0
80107de8:	6a 00                	push   $0x0
  pushl $80
80107dea:	6a 50                	push   $0x50
  jmp alltraps
80107dec:	e9 e4 f6 ff ff       	jmp    801074d5 <alltraps>

80107df1 <vector81>:
.globl vector81
vector81:
  pushl $0
80107df1:	6a 00                	push   $0x0
  pushl $81
80107df3:	6a 51                	push   $0x51
  jmp alltraps
80107df5:	e9 db f6 ff ff       	jmp    801074d5 <alltraps>

80107dfa <vector82>:
.globl vector82
vector82:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $82
80107dfc:	6a 52                	push   $0x52
  jmp alltraps
80107dfe:	e9 d2 f6 ff ff       	jmp    801074d5 <alltraps>

80107e03 <vector83>:
.globl vector83
vector83:
  pushl $0
80107e03:	6a 00                	push   $0x0
  pushl $83
80107e05:	6a 53                	push   $0x53
  jmp alltraps
80107e07:	e9 c9 f6 ff ff       	jmp    801074d5 <alltraps>

80107e0c <vector84>:
.globl vector84
vector84:
  pushl $0
80107e0c:	6a 00                	push   $0x0
  pushl $84
80107e0e:	6a 54                	push   $0x54
  jmp alltraps
80107e10:	e9 c0 f6 ff ff       	jmp    801074d5 <alltraps>

80107e15 <vector85>:
.globl vector85
vector85:
  pushl $0
80107e15:	6a 00                	push   $0x0
  pushl $85
80107e17:	6a 55                	push   $0x55
  jmp alltraps
80107e19:	e9 b7 f6 ff ff       	jmp    801074d5 <alltraps>

80107e1e <vector86>:
.globl vector86
vector86:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $86
80107e20:	6a 56                	push   $0x56
  jmp alltraps
80107e22:	e9 ae f6 ff ff       	jmp    801074d5 <alltraps>

80107e27 <vector87>:
.globl vector87
vector87:
  pushl $0
80107e27:	6a 00                	push   $0x0
  pushl $87
80107e29:	6a 57                	push   $0x57
  jmp alltraps
80107e2b:	e9 a5 f6 ff ff       	jmp    801074d5 <alltraps>

80107e30 <vector88>:
.globl vector88
vector88:
  pushl $0
80107e30:	6a 00                	push   $0x0
  pushl $88
80107e32:	6a 58                	push   $0x58
  jmp alltraps
80107e34:	e9 9c f6 ff ff       	jmp    801074d5 <alltraps>

80107e39 <vector89>:
.globl vector89
vector89:
  pushl $0
80107e39:	6a 00                	push   $0x0
  pushl $89
80107e3b:	6a 59                	push   $0x59
  jmp alltraps
80107e3d:	e9 93 f6 ff ff       	jmp    801074d5 <alltraps>

80107e42 <vector90>:
.globl vector90
vector90:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $90
80107e44:	6a 5a                	push   $0x5a
  jmp alltraps
80107e46:	e9 8a f6 ff ff       	jmp    801074d5 <alltraps>

80107e4b <vector91>:
.globl vector91
vector91:
  pushl $0
80107e4b:	6a 00                	push   $0x0
  pushl $91
80107e4d:	6a 5b                	push   $0x5b
  jmp alltraps
80107e4f:	e9 81 f6 ff ff       	jmp    801074d5 <alltraps>

80107e54 <vector92>:
.globl vector92
vector92:
  pushl $0
80107e54:	6a 00                	push   $0x0
  pushl $92
80107e56:	6a 5c                	push   $0x5c
  jmp alltraps
80107e58:	e9 78 f6 ff ff       	jmp    801074d5 <alltraps>

80107e5d <vector93>:
.globl vector93
vector93:
  pushl $0
80107e5d:	6a 00                	push   $0x0
  pushl $93
80107e5f:	6a 5d                	push   $0x5d
  jmp alltraps
80107e61:	e9 6f f6 ff ff       	jmp    801074d5 <alltraps>

80107e66 <vector94>:
.globl vector94
vector94:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $94
80107e68:	6a 5e                	push   $0x5e
  jmp alltraps
80107e6a:	e9 66 f6 ff ff       	jmp    801074d5 <alltraps>

80107e6f <vector95>:
.globl vector95
vector95:
  pushl $0
80107e6f:	6a 00                	push   $0x0
  pushl $95
80107e71:	6a 5f                	push   $0x5f
  jmp alltraps
80107e73:	e9 5d f6 ff ff       	jmp    801074d5 <alltraps>

80107e78 <vector96>:
.globl vector96
vector96:
  pushl $0
80107e78:	6a 00                	push   $0x0
  pushl $96
80107e7a:	6a 60                	push   $0x60
  jmp alltraps
80107e7c:	e9 54 f6 ff ff       	jmp    801074d5 <alltraps>

80107e81 <vector97>:
.globl vector97
vector97:
  pushl $0
80107e81:	6a 00                	push   $0x0
  pushl $97
80107e83:	6a 61                	push   $0x61
  jmp alltraps
80107e85:	e9 4b f6 ff ff       	jmp    801074d5 <alltraps>

80107e8a <vector98>:
.globl vector98
vector98:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $98
80107e8c:	6a 62                	push   $0x62
  jmp alltraps
80107e8e:	e9 42 f6 ff ff       	jmp    801074d5 <alltraps>

80107e93 <vector99>:
.globl vector99
vector99:
  pushl $0
80107e93:	6a 00                	push   $0x0
  pushl $99
80107e95:	6a 63                	push   $0x63
  jmp alltraps
80107e97:	e9 39 f6 ff ff       	jmp    801074d5 <alltraps>

80107e9c <vector100>:
.globl vector100
vector100:
  pushl $0
80107e9c:	6a 00                	push   $0x0
  pushl $100
80107e9e:	6a 64                	push   $0x64
  jmp alltraps
80107ea0:	e9 30 f6 ff ff       	jmp    801074d5 <alltraps>

80107ea5 <vector101>:
.globl vector101
vector101:
  pushl $0
80107ea5:	6a 00                	push   $0x0
  pushl $101
80107ea7:	6a 65                	push   $0x65
  jmp alltraps
80107ea9:	e9 27 f6 ff ff       	jmp    801074d5 <alltraps>

80107eae <vector102>:
.globl vector102
vector102:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $102
80107eb0:	6a 66                	push   $0x66
  jmp alltraps
80107eb2:	e9 1e f6 ff ff       	jmp    801074d5 <alltraps>

80107eb7 <vector103>:
.globl vector103
vector103:
  pushl $0
80107eb7:	6a 00                	push   $0x0
  pushl $103
80107eb9:	6a 67                	push   $0x67
  jmp alltraps
80107ebb:	e9 15 f6 ff ff       	jmp    801074d5 <alltraps>

80107ec0 <vector104>:
.globl vector104
vector104:
  pushl $0
80107ec0:	6a 00                	push   $0x0
  pushl $104
80107ec2:	6a 68                	push   $0x68
  jmp alltraps
80107ec4:	e9 0c f6 ff ff       	jmp    801074d5 <alltraps>

80107ec9 <vector105>:
.globl vector105
vector105:
  pushl $0
80107ec9:	6a 00                	push   $0x0
  pushl $105
80107ecb:	6a 69                	push   $0x69
  jmp alltraps
80107ecd:	e9 03 f6 ff ff       	jmp    801074d5 <alltraps>

80107ed2 <vector106>:
.globl vector106
vector106:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $106
80107ed4:	6a 6a                	push   $0x6a
  jmp alltraps
80107ed6:	e9 fa f5 ff ff       	jmp    801074d5 <alltraps>

80107edb <vector107>:
.globl vector107
vector107:
  pushl $0
80107edb:	6a 00                	push   $0x0
  pushl $107
80107edd:	6a 6b                	push   $0x6b
  jmp alltraps
80107edf:	e9 f1 f5 ff ff       	jmp    801074d5 <alltraps>

80107ee4 <vector108>:
.globl vector108
vector108:
  pushl $0
80107ee4:	6a 00                	push   $0x0
  pushl $108
80107ee6:	6a 6c                	push   $0x6c
  jmp alltraps
80107ee8:	e9 e8 f5 ff ff       	jmp    801074d5 <alltraps>

80107eed <vector109>:
.globl vector109
vector109:
  pushl $0
80107eed:	6a 00                	push   $0x0
  pushl $109
80107eef:	6a 6d                	push   $0x6d
  jmp alltraps
80107ef1:	e9 df f5 ff ff       	jmp    801074d5 <alltraps>

80107ef6 <vector110>:
.globl vector110
vector110:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $110
80107ef8:	6a 6e                	push   $0x6e
  jmp alltraps
80107efa:	e9 d6 f5 ff ff       	jmp    801074d5 <alltraps>

80107eff <vector111>:
.globl vector111
vector111:
  pushl $0
80107eff:	6a 00                	push   $0x0
  pushl $111
80107f01:	6a 6f                	push   $0x6f
  jmp alltraps
80107f03:	e9 cd f5 ff ff       	jmp    801074d5 <alltraps>

80107f08 <vector112>:
.globl vector112
vector112:
  pushl $0
80107f08:	6a 00                	push   $0x0
  pushl $112
80107f0a:	6a 70                	push   $0x70
  jmp alltraps
80107f0c:	e9 c4 f5 ff ff       	jmp    801074d5 <alltraps>

80107f11 <vector113>:
.globl vector113
vector113:
  pushl $0
80107f11:	6a 00                	push   $0x0
  pushl $113
80107f13:	6a 71                	push   $0x71
  jmp alltraps
80107f15:	e9 bb f5 ff ff       	jmp    801074d5 <alltraps>

80107f1a <vector114>:
.globl vector114
vector114:
  pushl $0
80107f1a:	6a 00                	push   $0x0
  pushl $114
80107f1c:	6a 72                	push   $0x72
  jmp alltraps
80107f1e:	e9 b2 f5 ff ff       	jmp    801074d5 <alltraps>

80107f23 <vector115>:
.globl vector115
vector115:
  pushl $0
80107f23:	6a 00                	push   $0x0
  pushl $115
80107f25:	6a 73                	push   $0x73
  jmp alltraps
80107f27:	e9 a9 f5 ff ff       	jmp    801074d5 <alltraps>

80107f2c <vector116>:
.globl vector116
vector116:
  pushl $0
80107f2c:	6a 00                	push   $0x0
  pushl $116
80107f2e:	6a 74                	push   $0x74
  jmp alltraps
80107f30:	e9 a0 f5 ff ff       	jmp    801074d5 <alltraps>

80107f35 <vector117>:
.globl vector117
vector117:
  pushl $0
80107f35:	6a 00                	push   $0x0
  pushl $117
80107f37:	6a 75                	push   $0x75
  jmp alltraps
80107f39:	e9 97 f5 ff ff       	jmp    801074d5 <alltraps>

80107f3e <vector118>:
.globl vector118
vector118:
  pushl $0
80107f3e:	6a 00                	push   $0x0
  pushl $118
80107f40:	6a 76                	push   $0x76
  jmp alltraps
80107f42:	e9 8e f5 ff ff       	jmp    801074d5 <alltraps>

80107f47 <vector119>:
.globl vector119
vector119:
  pushl $0
80107f47:	6a 00                	push   $0x0
  pushl $119
80107f49:	6a 77                	push   $0x77
  jmp alltraps
80107f4b:	e9 85 f5 ff ff       	jmp    801074d5 <alltraps>

80107f50 <vector120>:
.globl vector120
vector120:
  pushl $0
80107f50:	6a 00                	push   $0x0
  pushl $120
80107f52:	6a 78                	push   $0x78
  jmp alltraps
80107f54:	e9 7c f5 ff ff       	jmp    801074d5 <alltraps>

80107f59 <vector121>:
.globl vector121
vector121:
  pushl $0
80107f59:	6a 00                	push   $0x0
  pushl $121
80107f5b:	6a 79                	push   $0x79
  jmp alltraps
80107f5d:	e9 73 f5 ff ff       	jmp    801074d5 <alltraps>

80107f62 <vector122>:
.globl vector122
vector122:
  pushl $0
80107f62:	6a 00                	push   $0x0
  pushl $122
80107f64:	6a 7a                	push   $0x7a
  jmp alltraps
80107f66:	e9 6a f5 ff ff       	jmp    801074d5 <alltraps>

80107f6b <vector123>:
.globl vector123
vector123:
  pushl $0
80107f6b:	6a 00                	push   $0x0
  pushl $123
80107f6d:	6a 7b                	push   $0x7b
  jmp alltraps
80107f6f:	e9 61 f5 ff ff       	jmp    801074d5 <alltraps>

80107f74 <vector124>:
.globl vector124
vector124:
  pushl $0
80107f74:	6a 00                	push   $0x0
  pushl $124
80107f76:	6a 7c                	push   $0x7c
  jmp alltraps
80107f78:	e9 58 f5 ff ff       	jmp    801074d5 <alltraps>

80107f7d <vector125>:
.globl vector125
vector125:
  pushl $0
80107f7d:	6a 00                	push   $0x0
  pushl $125
80107f7f:	6a 7d                	push   $0x7d
  jmp alltraps
80107f81:	e9 4f f5 ff ff       	jmp    801074d5 <alltraps>

80107f86 <vector126>:
.globl vector126
vector126:
  pushl $0
80107f86:	6a 00                	push   $0x0
  pushl $126
80107f88:	6a 7e                	push   $0x7e
  jmp alltraps
80107f8a:	e9 46 f5 ff ff       	jmp    801074d5 <alltraps>

80107f8f <vector127>:
.globl vector127
vector127:
  pushl $0
80107f8f:	6a 00                	push   $0x0
  pushl $127
80107f91:	6a 7f                	push   $0x7f
  jmp alltraps
80107f93:	e9 3d f5 ff ff       	jmp    801074d5 <alltraps>

80107f98 <vector128>:
.globl vector128
vector128:
  pushl $0
80107f98:	6a 00                	push   $0x0
  pushl $128
80107f9a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107f9f:	e9 31 f5 ff ff       	jmp    801074d5 <alltraps>

80107fa4 <vector129>:
.globl vector129
vector129:
  pushl $0
80107fa4:	6a 00                	push   $0x0
  pushl $129
80107fa6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107fab:	e9 25 f5 ff ff       	jmp    801074d5 <alltraps>

80107fb0 <vector130>:
.globl vector130
vector130:
  pushl $0
80107fb0:	6a 00                	push   $0x0
  pushl $130
80107fb2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107fb7:	e9 19 f5 ff ff       	jmp    801074d5 <alltraps>

80107fbc <vector131>:
.globl vector131
vector131:
  pushl $0
80107fbc:	6a 00                	push   $0x0
  pushl $131
80107fbe:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107fc3:	e9 0d f5 ff ff       	jmp    801074d5 <alltraps>

80107fc8 <vector132>:
.globl vector132
vector132:
  pushl $0
80107fc8:	6a 00                	push   $0x0
  pushl $132
80107fca:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107fcf:	e9 01 f5 ff ff       	jmp    801074d5 <alltraps>

80107fd4 <vector133>:
.globl vector133
vector133:
  pushl $0
80107fd4:	6a 00                	push   $0x0
  pushl $133
80107fd6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107fdb:	e9 f5 f4 ff ff       	jmp    801074d5 <alltraps>

80107fe0 <vector134>:
.globl vector134
vector134:
  pushl $0
80107fe0:	6a 00                	push   $0x0
  pushl $134
80107fe2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107fe7:	e9 e9 f4 ff ff       	jmp    801074d5 <alltraps>

80107fec <vector135>:
.globl vector135
vector135:
  pushl $0
80107fec:	6a 00                	push   $0x0
  pushl $135
80107fee:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107ff3:	e9 dd f4 ff ff       	jmp    801074d5 <alltraps>

80107ff8 <vector136>:
.globl vector136
vector136:
  pushl $0
80107ff8:	6a 00                	push   $0x0
  pushl $136
80107ffa:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107fff:	e9 d1 f4 ff ff       	jmp    801074d5 <alltraps>

80108004 <vector137>:
.globl vector137
vector137:
  pushl $0
80108004:	6a 00                	push   $0x0
  pushl $137
80108006:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010800b:	e9 c5 f4 ff ff       	jmp    801074d5 <alltraps>

80108010 <vector138>:
.globl vector138
vector138:
  pushl $0
80108010:	6a 00                	push   $0x0
  pushl $138
80108012:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108017:	e9 b9 f4 ff ff       	jmp    801074d5 <alltraps>

8010801c <vector139>:
.globl vector139
vector139:
  pushl $0
8010801c:	6a 00                	push   $0x0
  pushl $139
8010801e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108023:	e9 ad f4 ff ff       	jmp    801074d5 <alltraps>

80108028 <vector140>:
.globl vector140
vector140:
  pushl $0
80108028:	6a 00                	push   $0x0
  pushl $140
8010802a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010802f:	e9 a1 f4 ff ff       	jmp    801074d5 <alltraps>

80108034 <vector141>:
.globl vector141
vector141:
  pushl $0
80108034:	6a 00                	push   $0x0
  pushl $141
80108036:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010803b:	e9 95 f4 ff ff       	jmp    801074d5 <alltraps>

80108040 <vector142>:
.globl vector142
vector142:
  pushl $0
80108040:	6a 00                	push   $0x0
  pushl $142
80108042:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108047:	e9 89 f4 ff ff       	jmp    801074d5 <alltraps>

8010804c <vector143>:
.globl vector143
vector143:
  pushl $0
8010804c:	6a 00                	push   $0x0
  pushl $143
8010804e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108053:	e9 7d f4 ff ff       	jmp    801074d5 <alltraps>

80108058 <vector144>:
.globl vector144
vector144:
  pushl $0
80108058:	6a 00                	push   $0x0
  pushl $144
8010805a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010805f:	e9 71 f4 ff ff       	jmp    801074d5 <alltraps>

80108064 <vector145>:
.globl vector145
vector145:
  pushl $0
80108064:	6a 00                	push   $0x0
  pushl $145
80108066:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010806b:	e9 65 f4 ff ff       	jmp    801074d5 <alltraps>

80108070 <vector146>:
.globl vector146
vector146:
  pushl $0
80108070:	6a 00                	push   $0x0
  pushl $146
80108072:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108077:	e9 59 f4 ff ff       	jmp    801074d5 <alltraps>

8010807c <vector147>:
.globl vector147
vector147:
  pushl $0
8010807c:	6a 00                	push   $0x0
  pushl $147
8010807e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108083:	e9 4d f4 ff ff       	jmp    801074d5 <alltraps>

80108088 <vector148>:
.globl vector148
vector148:
  pushl $0
80108088:	6a 00                	push   $0x0
  pushl $148
8010808a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010808f:	e9 41 f4 ff ff       	jmp    801074d5 <alltraps>

80108094 <vector149>:
.globl vector149
vector149:
  pushl $0
80108094:	6a 00                	push   $0x0
  pushl $149
80108096:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010809b:	e9 35 f4 ff ff       	jmp    801074d5 <alltraps>

801080a0 <vector150>:
.globl vector150
vector150:
  pushl $0
801080a0:	6a 00                	push   $0x0
  pushl $150
801080a2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801080a7:	e9 29 f4 ff ff       	jmp    801074d5 <alltraps>

801080ac <vector151>:
.globl vector151
vector151:
  pushl $0
801080ac:	6a 00                	push   $0x0
  pushl $151
801080ae:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801080b3:	e9 1d f4 ff ff       	jmp    801074d5 <alltraps>

801080b8 <vector152>:
.globl vector152
vector152:
  pushl $0
801080b8:	6a 00                	push   $0x0
  pushl $152
801080ba:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801080bf:	e9 11 f4 ff ff       	jmp    801074d5 <alltraps>

801080c4 <vector153>:
.globl vector153
vector153:
  pushl $0
801080c4:	6a 00                	push   $0x0
  pushl $153
801080c6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801080cb:	e9 05 f4 ff ff       	jmp    801074d5 <alltraps>

801080d0 <vector154>:
.globl vector154
vector154:
  pushl $0
801080d0:	6a 00                	push   $0x0
  pushl $154
801080d2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801080d7:	e9 f9 f3 ff ff       	jmp    801074d5 <alltraps>

801080dc <vector155>:
.globl vector155
vector155:
  pushl $0
801080dc:	6a 00                	push   $0x0
  pushl $155
801080de:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801080e3:	e9 ed f3 ff ff       	jmp    801074d5 <alltraps>

801080e8 <vector156>:
.globl vector156
vector156:
  pushl $0
801080e8:	6a 00                	push   $0x0
  pushl $156
801080ea:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801080ef:	e9 e1 f3 ff ff       	jmp    801074d5 <alltraps>

801080f4 <vector157>:
.globl vector157
vector157:
  pushl $0
801080f4:	6a 00                	push   $0x0
  pushl $157
801080f6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801080fb:	e9 d5 f3 ff ff       	jmp    801074d5 <alltraps>

80108100 <vector158>:
.globl vector158
vector158:
  pushl $0
80108100:	6a 00                	push   $0x0
  pushl $158
80108102:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108107:	e9 c9 f3 ff ff       	jmp    801074d5 <alltraps>

8010810c <vector159>:
.globl vector159
vector159:
  pushl $0
8010810c:	6a 00                	push   $0x0
  pushl $159
8010810e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108113:	e9 bd f3 ff ff       	jmp    801074d5 <alltraps>

80108118 <vector160>:
.globl vector160
vector160:
  pushl $0
80108118:	6a 00                	push   $0x0
  pushl $160
8010811a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010811f:	e9 b1 f3 ff ff       	jmp    801074d5 <alltraps>

80108124 <vector161>:
.globl vector161
vector161:
  pushl $0
80108124:	6a 00                	push   $0x0
  pushl $161
80108126:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010812b:	e9 a5 f3 ff ff       	jmp    801074d5 <alltraps>

80108130 <vector162>:
.globl vector162
vector162:
  pushl $0
80108130:	6a 00                	push   $0x0
  pushl $162
80108132:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108137:	e9 99 f3 ff ff       	jmp    801074d5 <alltraps>

8010813c <vector163>:
.globl vector163
vector163:
  pushl $0
8010813c:	6a 00                	push   $0x0
  pushl $163
8010813e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108143:	e9 8d f3 ff ff       	jmp    801074d5 <alltraps>

80108148 <vector164>:
.globl vector164
vector164:
  pushl $0
80108148:	6a 00                	push   $0x0
  pushl $164
8010814a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010814f:	e9 81 f3 ff ff       	jmp    801074d5 <alltraps>

80108154 <vector165>:
.globl vector165
vector165:
  pushl $0
80108154:	6a 00                	push   $0x0
  pushl $165
80108156:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010815b:	e9 75 f3 ff ff       	jmp    801074d5 <alltraps>

80108160 <vector166>:
.globl vector166
vector166:
  pushl $0
80108160:	6a 00                	push   $0x0
  pushl $166
80108162:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108167:	e9 69 f3 ff ff       	jmp    801074d5 <alltraps>

8010816c <vector167>:
.globl vector167
vector167:
  pushl $0
8010816c:	6a 00                	push   $0x0
  pushl $167
8010816e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108173:	e9 5d f3 ff ff       	jmp    801074d5 <alltraps>

80108178 <vector168>:
.globl vector168
vector168:
  pushl $0
80108178:	6a 00                	push   $0x0
  pushl $168
8010817a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010817f:	e9 51 f3 ff ff       	jmp    801074d5 <alltraps>

80108184 <vector169>:
.globl vector169
vector169:
  pushl $0
80108184:	6a 00                	push   $0x0
  pushl $169
80108186:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010818b:	e9 45 f3 ff ff       	jmp    801074d5 <alltraps>

80108190 <vector170>:
.globl vector170
vector170:
  pushl $0
80108190:	6a 00                	push   $0x0
  pushl $170
80108192:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108197:	e9 39 f3 ff ff       	jmp    801074d5 <alltraps>

8010819c <vector171>:
.globl vector171
vector171:
  pushl $0
8010819c:	6a 00                	push   $0x0
  pushl $171
8010819e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801081a3:	e9 2d f3 ff ff       	jmp    801074d5 <alltraps>

801081a8 <vector172>:
.globl vector172
vector172:
  pushl $0
801081a8:	6a 00                	push   $0x0
  pushl $172
801081aa:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801081af:	e9 21 f3 ff ff       	jmp    801074d5 <alltraps>

801081b4 <vector173>:
.globl vector173
vector173:
  pushl $0
801081b4:	6a 00                	push   $0x0
  pushl $173
801081b6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801081bb:	e9 15 f3 ff ff       	jmp    801074d5 <alltraps>

801081c0 <vector174>:
.globl vector174
vector174:
  pushl $0
801081c0:	6a 00                	push   $0x0
  pushl $174
801081c2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801081c7:	e9 09 f3 ff ff       	jmp    801074d5 <alltraps>

801081cc <vector175>:
.globl vector175
vector175:
  pushl $0
801081cc:	6a 00                	push   $0x0
  pushl $175
801081ce:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801081d3:	e9 fd f2 ff ff       	jmp    801074d5 <alltraps>

801081d8 <vector176>:
.globl vector176
vector176:
  pushl $0
801081d8:	6a 00                	push   $0x0
  pushl $176
801081da:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801081df:	e9 f1 f2 ff ff       	jmp    801074d5 <alltraps>

801081e4 <vector177>:
.globl vector177
vector177:
  pushl $0
801081e4:	6a 00                	push   $0x0
  pushl $177
801081e6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801081eb:	e9 e5 f2 ff ff       	jmp    801074d5 <alltraps>

801081f0 <vector178>:
.globl vector178
vector178:
  pushl $0
801081f0:	6a 00                	push   $0x0
  pushl $178
801081f2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801081f7:	e9 d9 f2 ff ff       	jmp    801074d5 <alltraps>

801081fc <vector179>:
.globl vector179
vector179:
  pushl $0
801081fc:	6a 00                	push   $0x0
  pushl $179
801081fe:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108203:	e9 cd f2 ff ff       	jmp    801074d5 <alltraps>

80108208 <vector180>:
.globl vector180
vector180:
  pushl $0
80108208:	6a 00                	push   $0x0
  pushl $180
8010820a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010820f:	e9 c1 f2 ff ff       	jmp    801074d5 <alltraps>

80108214 <vector181>:
.globl vector181
vector181:
  pushl $0
80108214:	6a 00                	push   $0x0
  pushl $181
80108216:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010821b:	e9 b5 f2 ff ff       	jmp    801074d5 <alltraps>

80108220 <vector182>:
.globl vector182
vector182:
  pushl $0
80108220:	6a 00                	push   $0x0
  pushl $182
80108222:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108227:	e9 a9 f2 ff ff       	jmp    801074d5 <alltraps>

8010822c <vector183>:
.globl vector183
vector183:
  pushl $0
8010822c:	6a 00                	push   $0x0
  pushl $183
8010822e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108233:	e9 9d f2 ff ff       	jmp    801074d5 <alltraps>

80108238 <vector184>:
.globl vector184
vector184:
  pushl $0
80108238:	6a 00                	push   $0x0
  pushl $184
8010823a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010823f:	e9 91 f2 ff ff       	jmp    801074d5 <alltraps>

80108244 <vector185>:
.globl vector185
vector185:
  pushl $0
80108244:	6a 00                	push   $0x0
  pushl $185
80108246:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010824b:	e9 85 f2 ff ff       	jmp    801074d5 <alltraps>

80108250 <vector186>:
.globl vector186
vector186:
  pushl $0
80108250:	6a 00                	push   $0x0
  pushl $186
80108252:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108257:	e9 79 f2 ff ff       	jmp    801074d5 <alltraps>

8010825c <vector187>:
.globl vector187
vector187:
  pushl $0
8010825c:	6a 00                	push   $0x0
  pushl $187
8010825e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108263:	e9 6d f2 ff ff       	jmp    801074d5 <alltraps>

80108268 <vector188>:
.globl vector188
vector188:
  pushl $0
80108268:	6a 00                	push   $0x0
  pushl $188
8010826a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010826f:	e9 61 f2 ff ff       	jmp    801074d5 <alltraps>

80108274 <vector189>:
.globl vector189
vector189:
  pushl $0
80108274:	6a 00                	push   $0x0
  pushl $189
80108276:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010827b:	e9 55 f2 ff ff       	jmp    801074d5 <alltraps>

80108280 <vector190>:
.globl vector190
vector190:
  pushl $0
80108280:	6a 00                	push   $0x0
  pushl $190
80108282:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108287:	e9 49 f2 ff ff       	jmp    801074d5 <alltraps>

8010828c <vector191>:
.globl vector191
vector191:
  pushl $0
8010828c:	6a 00                	push   $0x0
  pushl $191
8010828e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108293:	e9 3d f2 ff ff       	jmp    801074d5 <alltraps>

80108298 <vector192>:
.globl vector192
vector192:
  pushl $0
80108298:	6a 00                	push   $0x0
  pushl $192
8010829a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010829f:	e9 31 f2 ff ff       	jmp    801074d5 <alltraps>

801082a4 <vector193>:
.globl vector193
vector193:
  pushl $0
801082a4:	6a 00                	push   $0x0
  pushl $193
801082a6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801082ab:	e9 25 f2 ff ff       	jmp    801074d5 <alltraps>

801082b0 <vector194>:
.globl vector194
vector194:
  pushl $0
801082b0:	6a 00                	push   $0x0
  pushl $194
801082b2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801082b7:	e9 19 f2 ff ff       	jmp    801074d5 <alltraps>

801082bc <vector195>:
.globl vector195
vector195:
  pushl $0
801082bc:	6a 00                	push   $0x0
  pushl $195
801082be:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801082c3:	e9 0d f2 ff ff       	jmp    801074d5 <alltraps>

801082c8 <vector196>:
.globl vector196
vector196:
  pushl $0
801082c8:	6a 00                	push   $0x0
  pushl $196
801082ca:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801082cf:	e9 01 f2 ff ff       	jmp    801074d5 <alltraps>

801082d4 <vector197>:
.globl vector197
vector197:
  pushl $0
801082d4:	6a 00                	push   $0x0
  pushl $197
801082d6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801082db:	e9 f5 f1 ff ff       	jmp    801074d5 <alltraps>

801082e0 <vector198>:
.globl vector198
vector198:
  pushl $0
801082e0:	6a 00                	push   $0x0
  pushl $198
801082e2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801082e7:	e9 e9 f1 ff ff       	jmp    801074d5 <alltraps>

801082ec <vector199>:
.globl vector199
vector199:
  pushl $0
801082ec:	6a 00                	push   $0x0
  pushl $199
801082ee:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801082f3:	e9 dd f1 ff ff       	jmp    801074d5 <alltraps>

801082f8 <vector200>:
.globl vector200
vector200:
  pushl $0
801082f8:	6a 00                	push   $0x0
  pushl $200
801082fa:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801082ff:	e9 d1 f1 ff ff       	jmp    801074d5 <alltraps>

80108304 <vector201>:
.globl vector201
vector201:
  pushl $0
80108304:	6a 00                	push   $0x0
  pushl $201
80108306:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010830b:	e9 c5 f1 ff ff       	jmp    801074d5 <alltraps>

80108310 <vector202>:
.globl vector202
vector202:
  pushl $0
80108310:	6a 00                	push   $0x0
  pushl $202
80108312:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108317:	e9 b9 f1 ff ff       	jmp    801074d5 <alltraps>

8010831c <vector203>:
.globl vector203
vector203:
  pushl $0
8010831c:	6a 00                	push   $0x0
  pushl $203
8010831e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108323:	e9 ad f1 ff ff       	jmp    801074d5 <alltraps>

80108328 <vector204>:
.globl vector204
vector204:
  pushl $0
80108328:	6a 00                	push   $0x0
  pushl $204
8010832a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010832f:	e9 a1 f1 ff ff       	jmp    801074d5 <alltraps>

80108334 <vector205>:
.globl vector205
vector205:
  pushl $0
80108334:	6a 00                	push   $0x0
  pushl $205
80108336:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010833b:	e9 95 f1 ff ff       	jmp    801074d5 <alltraps>

80108340 <vector206>:
.globl vector206
vector206:
  pushl $0
80108340:	6a 00                	push   $0x0
  pushl $206
80108342:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108347:	e9 89 f1 ff ff       	jmp    801074d5 <alltraps>

8010834c <vector207>:
.globl vector207
vector207:
  pushl $0
8010834c:	6a 00                	push   $0x0
  pushl $207
8010834e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108353:	e9 7d f1 ff ff       	jmp    801074d5 <alltraps>

80108358 <vector208>:
.globl vector208
vector208:
  pushl $0
80108358:	6a 00                	push   $0x0
  pushl $208
8010835a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010835f:	e9 71 f1 ff ff       	jmp    801074d5 <alltraps>

80108364 <vector209>:
.globl vector209
vector209:
  pushl $0
80108364:	6a 00                	push   $0x0
  pushl $209
80108366:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010836b:	e9 65 f1 ff ff       	jmp    801074d5 <alltraps>

80108370 <vector210>:
.globl vector210
vector210:
  pushl $0
80108370:	6a 00                	push   $0x0
  pushl $210
80108372:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108377:	e9 59 f1 ff ff       	jmp    801074d5 <alltraps>

8010837c <vector211>:
.globl vector211
vector211:
  pushl $0
8010837c:	6a 00                	push   $0x0
  pushl $211
8010837e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108383:	e9 4d f1 ff ff       	jmp    801074d5 <alltraps>

80108388 <vector212>:
.globl vector212
vector212:
  pushl $0
80108388:	6a 00                	push   $0x0
  pushl $212
8010838a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010838f:	e9 41 f1 ff ff       	jmp    801074d5 <alltraps>

80108394 <vector213>:
.globl vector213
vector213:
  pushl $0
80108394:	6a 00                	push   $0x0
  pushl $213
80108396:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010839b:	e9 35 f1 ff ff       	jmp    801074d5 <alltraps>

801083a0 <vector214>:
.globl vector214
vector214:
  pushl $0
801083a0:	6a 00                	push   $0x0
  pushl $214
801083a2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801083a7:	e9 29 f1 ff ff       	jmp    801074d5 <alltraps>

801083ac <vector215>:
.globl vector215
vector215:
  pushl $0
801083ac:	6a 00                	push   $0x0
  pushl $215
801083ae:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801083b3:	e9 1d f1 ff ff       	jmp    801074d5 <alltraps>

801083b8 <vector216>:
.globl vector216
vector216:
  pushl $0
801083b8:	6a 00                	push   $0x0
  pushl $216
801083ba:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801083bf:	e9 11 f1 ff ff       	jmp    801074d5 <alltraps>

801083c4 <vector217>:
.globl vector217
vector217:
  pushl $0
801083c4:	6a 00                	push   $0x0
  pushl $217
801083c6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801083cb:	e9 05 f1 ff ff       	jmp    801074d5 <alltraps>

801083d0 <vector218>:
.globl vector218
vector218:
  pushl $0
801083d0:	6a 00                	push   $0x0
  pushl $218
801083d2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801083d7:	e9 f9 f0 ff ff       	jmp    801074d5 <alltraps>

801083dc <vector219>:
.globl vector219
vector219:
  pushl $0
801083dc:	6a 00                	push   $0x0
  pushl $219
801083de:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801083e3:	e9 ed f0 ff ff       	jmp    801074d5 <alltraps>

801083e8 <vector220>:
.globl vector220
vector220:
  pushl $0
801083e8:	6a 00                	push   $0x0
  pushl $220
801083ea:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801083ef:	e9 e1 f0 ff ff       	jmp    801074d5 <alltraps>

801083f4 <vector221>:
.globl vector221
vector221:
  pushl $0
801083f4:	6a 00                	push   $0x0
  pushl $221
801083f6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801083fb:	e9 d5 f0 ff ff       	jmp    801074d5 <alltraps>

80108400 <vector222>:
.globl vector222
vector222:
  pushl $0
80108400:	6a 00                	push   $0x0
  pushl $222
80108402:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108407:	e9 c9 f0 ff ff       	jmp    801074d5 <alltraps>

8010840c <vector223>:
.globl vector223
vector223:
  pushl $0
8010840c:	6a 00                	push   $0x0
  pushl $223
8010840e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108413:	e9 bd f0 ff ff       	jmp    801074d5 <alltraps>

80108418 <vector224>:
.globl vector224
vector224:
  pushl $0
80108418:	6a 00                	push   $0x0
  pushl $224
8010841a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010841f:	e9 b1 f0 ff ff       	jmp    801074d5 <alltraps>

80108424 <vector225>:
.globl vector225
vector225:
  pushl $0
80108424:	6a 00                	push   $0x0
  pushl $225
80108426:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010842b:	e9 a5 f0 ff ff       	jmp    801074d5 <alltraps>

80108430 <vector226>:
.globl vector226
vector226:
  pushl $0
80108430:	6a 00                	push   $0x0
  pushl $226
80108432:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108437:	e9 99 f0 ff ff       	jmp    801074d5 <alltraps>

8010843c <vector227>:
.globl vector227
vector227:
  pushl $0
8010843c:	6a 00                	push   $0x0
  pushl $227
8010843e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108443:	e9 8d f0 ff ff       	jmp    801074d5 <alltraps>

80108448 <vector228>:
.globl vector228
vector228:
  pushl $0
80108448:	6a 00                	push   $0x0
  pushl $228
8010844a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010844f:	e9 81 f0 ff ff       	jmp    801074d5 <alltraps>

80108454 <vector229>:
.globl vector229
vector229:
  pushl $0
80108454:	6a 00                	push   $0x0
  pushl $229
80108456:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010845b:	e9 75 f0 ff ff       	jmp    801074d5 <alltraps>

80108460 <vector230>:
.globl vector230
vector230:
  pushl $0
80108460:	6a 00                	push   $0x0
  pushl $230
80108462:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108467:	e9 69 f0 ff ff       	jmp    801074d5 <alltraps>

8010846c <vector231>:
.globl vector231
vector231:
  pushl $0
8010846c:	6a 00                	push   $0x0
  pushl $231
8010846e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108473:	e9 5d f0 ff ff       	jmp    801074d5 <alltraps>

80108478 <vector232>:
.globl vector232
vector232:
  pushl $0
80108478:	6a 00                	push   $0x0
  pushl $232
8010847a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010847f:	e9 51 f0 ff ff       	jmp    801074d5 <alltraps>

80108484 <vector233>:
.globl vector233
vector233:
  pushl $0
80108484:	6a 00                	push   $0x0
  pushl $233
80108486:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010848b:	e9 45 f0 ff ff       	jmp    801074d5 <alltraps>

80108490 <vector234>:
.globl vector234
vector234:
  pushl $0
80108490:	6a 00                	push   $0x0
  pushl $234
80108492:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108497:	e9 39 f0 ff ff       	jmp    801074d5 <alltraps>

8010849c <vector235>:
.globl vector235
vector235:
  pushl $0
8010849c:	6a 00                	push   $0x0
  pushl $235
8010849e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801084a3:	e9 2d f0 ff ff       	jmp    801074d5 <alltraps>

801084a8 <vector236>:
.globl vector236
vector236:
  pushl $0
801084a8:	6a 00                	push   $0x0
  pushl $236
801084aa:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801084af:	e9 21 f0 ff ff       	jmp    801074d5 <alltraps>

801084b4 <vector237>:
.globl vector237
vector237:
  pushl $0
801084b4:	6a 00                	push   $0x0
  pushl $237
801084b6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801084bb:	e9 15 f0 ff ff       	jmp    801074d5 <alltraps>

801084c0 <vector238>:
.globl vector238
vector238:
  pushl $0
801084c0:	6a 00                	push   $0x0
  pushl $238
801084c2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801084c7:	e9 09 f0 ff ff       	jmp    801074d5 <alltraps>

801084cc <vector239>:
.globl vector239
vector239:
  pushl $0
801084cc:	6a 00                	push   $0x0
  pushl $239
801084ce:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801084d3:	e9 fd ef ff ff       	jmp    801074d5 <alltraps>

801084d8 <vector240>:
.globl vector240
vector240:
  pushl $0
801084d8:	6a 00                	push   $0x0
  pushl $240
801084da:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801084df:	e9 f1 ef ff ff       	jmp    801074d5 <alltraps>

801084e4 <vector241>:
.globl vector241
vector241:
  pushl $0
801084e4:	6a 00                	push   $0x0
  pushl $241
801084e6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801084eb:	e9 e5 ef ff ff       	jmp    801074d5 <alltraps>

801084f0 <vector242>:
.globl vector242
vector242:
  pushl $0
801084f0:	6a 00                	push   $0x0
  pushl $242
801084f2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801084f7:	e9 d9 ef ff ff       	jmp    801074d5 <alltraps>

801084fc <vector243>:
.globl vector243
vector243:
  pushl $0
801084fc:	6a 00                	push   $0x0
  pushl $243
801084fe:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108503:	e9 cd ef ff ff       	jmp    801074d5 <alltraps>

80108508 <vector244>:
.globl vector244
vector244:
  pushl $0
80108508:	6a 00                	push   $0x0
  pushl $244
8010850a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010850f:	e9 c1 ef ff ff       	jmp    801074d5 <alltraps>

80108514 <vector245>:
.globl vector245
vector245:
  pushl $0
80108514:	6a 00                	push   $0x0
  pushl $245
80108516:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010851b:	e9 b5 ef ff ff       	jmp    801074d5 <alltraps>

80108520 <vector246>:
.globl vector246
vector246:
  pushl $0
80108520:	6a 00                	push   $0x0
  pushl $246
80108522:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108527:	e9 a9 ef ff ff       	jmp    801074d5 <alltraps>

8010852c <vector247>:
.globl vector247
vector247:
  pushl $0
8010852c:	6a 00                	push   $0x0
  pushl $247
8010852e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108533:	e9 9d ef ff ff       	jmp    801074d5 <alltraps>

80108538 <vector248>:
.globl vector248
vector248:
  pushl $0
80108538:	6a 00                	push   $0x0
  pushl $248
8010853a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010853f:	e9 91 ef ff ff       	jmp    801074d5 <alltraps>

80108544 <vector249>:
.globl vector249
vector249:
  pushl $0
80108544:	6a 00                	push   $0x0
  pushl $249
80108546:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010854b:	e9 85 ef ff ff       	jmp    801074d5 <alltraps>

80108550 <vector250>:
.globl vector250
vector250:
  pushl $0
80108550:	6a 00                	push   $0x0
  pushl $250
80108552:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108557:	e9 79 ef ff ff       	jmp    801074d5 <alltraps>

8010855c <vector251>:
.globl vector251
vector251:
  pushl $0
8010855c:	6a 00                	push   $0x0
  pushl $251
8010855e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108563:	e9 6d ef ff ff       	jmp    801074d5 <alltraps>

80108568 <vector252>:
.globl vector252
vector252:
  pushl $0
80108568:	6a 00                	push   $0x0
  pushl $252
8010856a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010856f:	e9 61 ef ff ff       	jmp    801074d5 <alltraps>

80108574 <vector253>:
.globl vector253
vector253:
  pushl $0
80108574:	6a 00                	push   $0x0
  pushl $253
80108576:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010857b:	e9 55 ef ff ff       	jmp    801074d5 <alltraps>

80108580 <vector254>:
.globl vector254
vector254:
  pushl $0
80108580:	6a 00                	push   $0x0
  pushl $254
80108582:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108587:	e9 49 ef ff ff       	jmp    801074d5 <alltraps>

8010858c <vector255>:
.globl vector255
vector255:
  pushl $0
8010858c:	6a 00                	push   $0x0
  pushl $255
8010858e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108593:	e9 3d ef ff ff       	jmp    801074d5 <alltraps>

80108598 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108598:	55                   	push   %ebp
80108599:	89 e5                	mov    %esp,%ebp
8010859b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010859e:	8b 45 0c             	mov    0xc(%ebp),%eax
801085a1:	83 e8 01             	sub    $0x1,%eax
801085a4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801085a8:	8b 45 08             	mov    0x8(%ebp),%eax
801085ab:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801085af:	8b 45 08             	mov    0x8(%ebp),%eax
801085b2:	c1 e8 10             	shr    $0x10,%eax
801085b5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801085b9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801085bc:	0f 01 10             	lgdtl  (%eax)
}
801085bf:	90                   	nop
801085c0:	c9                   	leave  
801085c1:	c3                   	ret    

801085c2 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801085c2:	55                   	push   %ebp
801085c3:	89 e5                	mov    %esp,%ebp
801085c5:	83 ec 04             	sub    $0x4,%esp
801085c8:	8b 45 08             	mov    0x8(%ebp),%eax
801085cb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801085cf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085d3:	0f 00 d8             	ltr    %ax
}
801085d6:	90                   	nop
801085d7:	c9                   	leave  
801085d8:	c3                   	ret    

801085d9 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801085d9:	55                   	push   %ebp
801085da:	89 e5                	mov    %esp,%ebp
801085dc:	83 ec 04             	sub    $0x4,%esp
801085df:	8b 45 08             	mov    0x8(%ebp),%eax
801085e2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801085e6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085ea:	8e e8                	mov    %eax,%gs
}
801085ec:	90                   	nop
801085ed:	c9                   	leave  
801085ee:	c3                   	ret    

801085ef <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801085ef:	55                   	push   %ebp
801085f0:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801085f2:	8b 45 08             	mov    0x8(%ebp),%eax
801085f5:	0f 22 d8             	mov    %eax,%cr3
}
801085f8:	90                   	nop
801085f9:	5d                   	pop    %ebp
801085fa:	c3                   	ret    

801085fb <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801085fb:	55                   	push   %ebp
801085fc:	89 e5                	mov    %esp,%ebp
801085fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108601:	05 00 00 00 80       	add    $0x80000000,%eax
80108606:	5d                   	pop    %ebp
80108607:	c3                   	ret    

80108608 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108608:	55                   	push   %ebp
80108609:	89 e5                	mov    %esp,%ebp
8010860b:	8b 45 08             	mov    0x8(%ebp),%eax
8010860e:	05 00 00 00 80       	add    $0x80000000,%eax
80108613:	5d                   	pop    %ebp
80108614:	c3                   	ret    

80108615 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108615:	55                   	push   %ebp
80108616:	89 e5                	mov    %esp,%ebp
80108618:	53                   	push   %ebx
80108619:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010861c:	e8 b0 b1 ff ff       	call   801037d1 <cpunum>
80108621:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108627:	05 80 38 11 80       	add    $0x80113880,%eax
8010862c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108644:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010864f:	83 e2 f0             	and    $0xfffffff0,%edx
80108652:	83 ca 0a             	or     $0xa,%edx
80108655:	88 50 7d             	mov    %dl,0x7d(%eax)
80108658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010865f:	83 ca 10             	or     $0x10,%edx
80108662:	88 50 7d             	mov    %dl,0x7d(%eax)
80108665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108668:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010866c:	83 e2 9f             	and    $0xffffff9f,%edx
8010866f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108675:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108679:	83 ca 80             	or     $0xffffff80,%edx
8010867c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010867f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108682:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108686:	83 ca 0f             	or     $0xf,%edx
80108689:	88 50 7e             	mov    %dl,0x7e(%eax)
8010868c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108693:	83 e2 ef             	and    $0xffffffef,%edx
80108696:	88 50 7e             	mov    %dl,0x7e(%eax)
80108699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086a0:	83 e2 df             	and    $0xffffffdf,%edx
801086a3:	88 50 7e             	mov    %dl,0x7e(%eax)
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086ad:	83 ca 40             	or     $0x40,%edx
801086b0:	88 50 7e             	mov    %dl,0x7e(%eax)
801086b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086ba:	83 ca 80             	or     $0xffffff80,%edx
801086bd:	88 50 7e             	mov    %dl,0x7e(%eax)
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801086c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ca:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801086d1:	ff ff 
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801086dd:	00 00 
801086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801086e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ec:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086f3:	83 e2 f0             	and    $0xfffffff0,%edx
801086f6:	83 ca 02             	or     $0x2,%edx
801086f9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108702:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108709:	83 ca 10             	or     $0x10,%edx
8010870c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108715:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010871c:	83 e2 9f             	and    $0xffffff9f,%edx
8010871f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108728:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010872f:	83 ca 80             	or     $0xffffff80,%edx
80108732:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108742:	83 ca 0f             	or     $0xf,%edx
80108745:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010874b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108755:	83 e2 ef             	and    $0xffffffef,%edx
80108758:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010875e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108761:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108768:	83 e2 df             	and    $0xffffffdf,%edx
8010876b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108774:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010877b:	83 ca 40             	or     $0x40,%edx
8010877e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108787:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010878e:	83 ca 80             	or     $0xffffff80,%edx
80108791:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801087a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a4:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801087ab:	ff ff 
801087ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801087b7:	00 00 
801087b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bc:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801087c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087cd:	83 e2 f0             	and    $0xfffffff0,%edx
801087d0:	83 ca 0a             	or     $0xa,%edx
801087d3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087dc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087e3:	83 ca 10             	or     $0x10,%edx
801087e6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087f6:	83 ca 60             	or     $0x60,%edx
801087f9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108802:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108809:	83 ca 80             	or     $0xffffff80,%edx
8010880c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108815:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010881c:	83 ca 0f             	or     $0xf,%edx
8010881f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108828:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010882f:	83 e2 ef             	and    $0xffffffef,%edx
80108832:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108842:	83 e2 df             	and    $0xffffffdf,%edx
80108845:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010884b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108855:	83 ca 40             	or     $0x40,%edx
80108858:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010885e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108861:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108868:	83 ca 80             	or     $0xffffff80,%edx
8010886b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108874:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010887b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108885:	ff ff 
80108887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108891:	00 00 
80108893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108896:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010889d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088a7:	83 e2 f0             	and    $0xfffffff0,%edx
801088aa:	83 ca 02             	or     $0x2,%edx
801088ad:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088bd:	83 ca 10             	or     $0x10,%edx
801088c0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088d0:	83 ca 60             	or     $0x60,%edx
801088d3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088e3:	83 ca 80             	or     $0xffffff80,%edx
801088e6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ef:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088f6:	83 ca 0f             	or     $0xf,%edx
801088f9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108902:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108909:	83 e2 ef             	and    $0xffffffef,%edx
8010890c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108915:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010891c:	83 e2 df             	and    $0xffffffdf,%edx
8010891f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108928:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010892f:	83 ca 40             	or     $0x40,%edx
80108932:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108942:	83 ca 80             	or     $0xffffff80,%edx
80108945:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010894b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108958:	05 b4 00 00 00       	add    $0xb4,%eax
8010895d:	89 c3                	mov    %eax,%ebx
8010895f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108962:	05 b4 00 00 00       	add    $0xb4,%eax
80108967:	c1 e8 10             	shr    $0x10,%eax
8010896a:	89 c2                	mov    %eax,%edx
8010896c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896f:	05 b4 00 00 00       	add    $0xb4,%eax
80108974:	c1 e8 18             	shr    $0x18,%eax
80108977:	89 c1                	mov    %eax,%ecx
80108979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108983:	00 00 
80108985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108988:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010898f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108992:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089a2:	83 e2 f0             	and    $0xfffffff0,%edx
801089a5:	83 ca 02             	or     $0x2,%edx
801089a8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089b8:	83 ca 10             	or     $0x10,%edx
801089bb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089cb:	83 e2 9f             	and    $0xffffff9f,%edx
801089ce:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089de:	83 ca 80             	or     $0xffffff80,%edx
801089e1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ea:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089f1:	83 e2 f0             	and    $0xfffffff0,%edx
801089f4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a04:	83 e2 ef             	and    $0xffffffef,%edx
80108a07:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a10:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a17:	83 e2 df             	and    $0xffffffdf,%edx
80108a1a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a23:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a2a:	83 ca 40             	or     $0x40,%edx
80108a2d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a36:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a3d:	83 ca 80             	or     $0xffffff80,%edx
80108a40:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a49:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a52:	83 c0 70             	add    $0x70,%eax
80108a55:	83 ec 08             	sub    $0x8,%esp
80108a58:	6a 38                	push   $0x38
80108a5a:	50                   	push   %eax
80108a5b:	e8 38 fb ff ff       	call   80108598 <lgdt>
80108a60:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108a63:	83 ec 0c             	sub    $0xc,%esp
80108a66:	6a 18                	push   $0x18
80108a68:	e8 6c fb ff ff       	call   801085d9 <loadgs>
80108a6d:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a73:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108a79:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a80:	00 00 00 00 
}
80108a84:	90                   	nop
80108a85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a88:	c9                   	leave  
80108a89:	c3                   	ret    

80108a8a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a8a:	55                   	push   %ebp
80108a8b:	89 e5                	mov    %esp,%ebp
80108a8d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a93:	c1 e8 16             	shr    $0x16,%eax
80108a96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa0:	01 d0                	add    %edx,%eax
80108aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa8:	8b 00                	mov    (%eax),%eax
80108aaa:	83 e0 01             	and    $0x1,%eax
80108aad:	85 c0                	test   %eax,%eax
80108aaf:	74 18                	je     80108ac9 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab4:	8b 00                	mov    (%eax),%eax
80108ab6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108abb:	50                   	push   %eax
80108abc:	e8 47 fb ff ff       	call   80108608 <p2v>
80108ac1:	83 c4 04             	add    $0x4,%esp
80108ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108ac7:	eb 48                	jmp    80108b11 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108ac9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108acd:	74 0e                	je     80108add <walkpgdir+0x53>
80108acf:	e8 97 a9 ff ff       	call   8010346b <kalloc>
80108ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108ad7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108adb:	75 07                	jne    80108ae4 <walkpgdir+0x5a>
      return 0;
80108add:	b8 00 00 00 00       	mov    $0x0,%eax
80108ae2:	eb 44                	jmp    80108b28 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108ae4:	83 ec 04             	sub    $0x4,%esp
80108ae7:	68 00 10 00 00       	push   $0x1000
80108aec:	6a 00                	push   $0x0
80108aee:	ff 75 f4             	pushl  -0xc(%ebp)
80108af1:	e8 d4 d2 ff ff       	call   80105dca <memset>
80108af6:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108af9:	83 ec 0c             	sub    $0xc,%esp
80108afc:	ff 75 f4             	pushl  -0xc(%ebp)
80108aff:	e8 f7 fa ff ff       	call   801085fb <v2p>
80108b04:	83 c4 10             	add    $0x10,%esp
80108b07:	83 c8 07             	or     $0x7,%eax
80108b0a:	89 c2                	mov    %eax,%edx
80108b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b0f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108b11:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b14:	c1 e8 0c             	shr    $0xc,%eax
80108b17:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b26:	01 d0                	add    %edx,%eax
}
80108b28:	c9                   	leave  
80108b29:	c3                   	ret    

80108b2a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108b2a:	55                   	push   %ebp
80108b2b:	89 e5                	mov    %esp,%ebp
80108b2d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108b30:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108b3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b3e:	8b 45 10             	mov    0x10(%ebp),%eax
80108b41:	01 d0                	add    %edx,%eax
80108b43:	83 e8 01             	sub    $0x1,%eax
80108b46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108b4e:	83 ec 04             	sub    $0x4,%esp
80108b51:	6a 01                	push   $0x1
80108b53:	ff 75 f4             	pushl  -0xc(%ebp)
80108b56:	ff 75 08             	pushl  0x8(%ebp)
80108b59:	e8 2c ff ff ff       	call   80108a8a <walkpgdir>
80108b5e:	83 c4 10             	add    $0x10,%esp
80108b61:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b64:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b68:	75 07                	jne    80108b71 <mappages+0x47>
      return -1;
80108b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b6f:	eb 47                	jmp    80108bb8 <mappages+0x8e>
    if(*pte & PTE_P)
80108b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b74:	8b 00                	mov    (%eax),%eax
80108b76:	83 e0 01             	and    $0x1,%eax
80108b79:	85 c0                	test   %eax,%eax
80108b7b:	74 0d                	je     80108b8a <mappages+0x60>
      panic("remap");
80108b7d:	83 ec 0c             	sub    $0xc,%esp
80108b80:	68 98 9a 10 80       	push   $0x80109a98
80108b85:	e8 dc 79 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108b8a:	8b 45 18             	mov    0x18(%ebp),%eax
80108b8d:	0b 45 14             	or     0x14(%ebp),%eax
80108b90:	83 c8 01             	or     $0x1,%eax
80108b93:	89 c2                	mov    %eax,%edx
80108b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b98:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ba0:	74 10                	je     80108bb2 <mappages+0x88>
      break;
    a += PGSIZE;
80108ba2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108ba9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108bb0:	eb 9c                	jmp    80108b4e <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108bb2:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bb8:	c9                   	leave  
80108bb9:	c3                   	ret    

80108bba <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108bba:	55                   	push   %ebp
80108bbb:	89 e5                	mov    %esp,%ebp
80108bbd:	53                   	push   %ebx
80108bbe:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108bc1:	e8 a5 a8 ff ff       	call   8010346b <kalloc>
80108bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108bc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108bcd:	75 0a                	jne    80108bd9 <setupkvm+0x1f>
    return 0;
80108bcf:	b8 00 00 00 00       	mov    $0x0,%eax
80108bd4:	e9 8e 00 00 00       	jmp    80108c67 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108bd9:	83 ec 04             	sub    $0x4,%esp
80108bdc:	68 00 10 00 00       	push   $0x1000
80108be1:	6a 00                	push   $0x0
80108be3:	ff 75 f0             	pushl  -0x10(%ebp)
80108be6:	e8 df d1 ff ff       	call   80105dca <memset>
80108beb:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108bee:	83 ec 0c             	sub    $0xc,%esp
80108bf1:	68 00 00 00 0e       	push   $0xe000000
80108bf6:	e8 0d fa ff ff       	call   80108608 <p2v>
80108bfb:	83 c4 10             	add    $0x10,%esp
80108bfe:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108c03:	76 0d                	jbe    80108c12 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108c05:	83 ec 0c             	sub    $0xc,%esp
80108c08:	68 9e 9a 10 80       	push   $0x80109a9e
80108c0d:	e8 54 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c12:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108c19:	eb 40                	jmp    80108c5b <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c24:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2a:	8b 58 08             	mov    0x8(%eax),%ebx
80108c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c30:	8b 40 04             	mov    0x4(%eax),%eax
80108c33:	29 c3                	sub    %eax,%ebx
80108c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c38:	8b 00                	mov    (%eax),%eax
80108c3a:	83 ec 0c             	sub    $0xc,%esp
80108c3d:	51                   	push   %ecx
80108c3e:	52                   	push   %edx
80108c3f:	53                   	push   %ebx
80108c40:	50                   	push   %eax
80108c41:	ff 75 f0             	pushl  -0x10(%ebp)
80108c44:	e8 e1 fe ff ff       	call   80108b2a <mappages>
80108c49:	83 c4 20             	add    $0x20,%esp
80108c4c:	85 c0                	test   %eax,%eax
80108c4e:	79 07                	jns    80108c57 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108c50:	b8 00 00 00 00       	mov    $0x0,%eax
80108c55:	eb 10                	jmp    80108c67 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c57:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108c5b:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108c62:	72 b7                	jb     80108c1b <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108c67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c6a:	c9                   	leave  
80108c6b:	c3                   	ret    

80108c6c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108c6c:	55                   	push   %ebp
80108c6d:	89 e5                	mov    %esp,%ebp
80108c6f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108c72:	e8 43 ff ff ff       	call   80108bba <setupkvm>
80108c77:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108c7c:	e8 03 00 00 00       	call   80108c84 <switchkvm>
}
80108c81:	90                   	nop
80108c82:	c9                   	leave  
80108c83:	c3                   	ret    

80108c84 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108c84:	55                   	push   %ebp
80108c85:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c87:	a1 58 66 11 80       	mov    0x80116658,%eax
80108c8c:	50                   	push   %eax
80108c8d:	e8 69 f9 ff ff       	call   801085fb <v2p>
80108c92:	83 c4 04             	add    $0x4,%esp
80108c95:	50                   	push   %eax
80108c96:	e8 54 f9 ff ff       	call   801085ef <lcr3>
80108c9b:	83 c4 04             	add    $0x4,%esp
}
80108c9e:	90                   	nop
80108c9f:	c9                   	leave  
80108ca0:	c3                   	ret    

80108ca1 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108ca1:	55                   	push   %ebp
80108ca2:	89 e5                	mov    %esp,%ebp
80108ca4:	56                   	push   %esi
80108ca5:	53                   	push   %ebx
  pushcli();
80108ca6:	e8 19 d0 ff ff       	call   80105cc4 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108cab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108cb1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cb8:	83 c2 08             	add    $0x8,%edx
80108cbb:	89 d6                	mov    %edx,%esi
80108cbd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cc4:	83 c2 08             	add    $0x8,%edx
80108cc7:	c1 ea 10             	shr    $0x10,%edx
80108cca:	89 d3                	mov    %edx,%ebx
80108ccc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cd3:	83 c2 08             	add    $0x8,%edx
80108cd6:	c1 ea 18             	shr    $0x18,%edx
80108cd9:	89 d1                	mov    %edx,%ecx
80108cdb:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108ce2:	67 00 
80108ce4:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108ceb:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108cf1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cf8:	83 e2 f0             	and    $0xfffffff0,%edx
80108cfb:	83 ca 09             	or     $0x9,%edx
80108cfe:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d04:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d0b:	83 ca 10             	or     $0x10,%edx
80108d0e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d14:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d1b:	83 e2 9f             	and    $0xffffff9f,%edx
80108d1e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d24:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d2b:	83 ca 80             	or     $0xffffff80,%edx
80108d2e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d34:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d3b:	83 e2 f0             	and    $0xfffffff0,%edx
80108d3e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d44:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d4b:	83 e2 ef             	and    $0xffffffef,%edx
80108d4e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d54:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d5b:	83 e2 df             	and    $0xffffffdf,%edx
80108d5e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d64:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d6b:	83 ca 40             	or     $0x40,%edx
80108d6e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d74:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d7b:	83 e2 7f             	and    $0x7f,%edx
80108d7e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d84:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d8a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d90:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d97:	83 e2 ef             	and    $0xffffffef,%edx
80108d9a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108da0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108da6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108dac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108db2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108db9:	8b 52 08             	mov    0x8(%edx),%edx
80108dbc:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108dc2:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108dc5:	83 ec 0c             	sub    $0xc,%esp
80108dc8:	6a 30                	push   $0x30
80108dca:	e8 f3 f7 ff ff       	call   801085c2 <ltr>
80108dcf:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80108dd5:	8b 40 04             	mov    0x4(%eax),%eax
80108dd8:	85 c0                	test   %eax,%eax
80108dda:	75 0d                	jne    80108de9 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108ddc:	83 ec 0c             	sub    $0xc,%esp
80108ddf:	68 af 9a 10 80       	push   $0x80109aaf
80108de4:	e8 7d 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108de9:	8b 45 08             	mov    0x8(%ebp),%eax
80108dec:	8b 40 04             	mov    0x4(%eax),%eax
80108def:	83 ec 0c             	sub    $0xc,%esp
80108df2:	50                   	push   %eax
80108df3:	e8 03 f8 ff ff       	call   801085fb <v2p>
80108df8:	83 c4 10             	add    $0x10,%esp
80108dfb:	83 ec 0c             	sub    $0xc,%esp
80108dfe:	50                   	push   %eax
80108dff:	e8 eb f7 ff ff       	call   801085ef <lcr3>
80108e04:	83 c4 10             	add    $0x10,%esp
  popcli();
80108e07:	e8 fd ce ff ff       	call   80105d09 <popcli>
}
80108e0c:	90                   	nop
80108e0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108e10:	5b                   	pop    %ebx
80108e11:	5e                   	pop    %esi
80108e12:	5d                   	pop    %ebp
80108e13:	c3                   	ret    

80108e14 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108e14:	55                   	push   %ebp
80108e15:	89 e5                	mov    %esp,%ebp
80108e17:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108e1a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108e21:	76 0d                	jbe    80108e30 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108e23:	83 ec 0c             	sub    $0xc,%esp
80108e26:	68 c3 9a 10 80       	push   $0x80109ac3
80108e2b:	e8 36 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108e30:	e8 36 a6 ff ff       	call   8010346b <kalloc>
80108e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108e38:	83 ec 04             	sub    $0x4,%esp
80108e3b:	68 00 10 00 00       	push   $0x1000
80108e40:	6a 00                	push   $0x0
80108e42:	ff 75 f4             	pushl  -0xc(%ebp)
80108e45:	e8 80 cf ff ff       	call   80105dca <memset>
80108e4a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e4d:	83 ec 0c             	sub    $0xc,%esp
80108e50:	ff 75 f4             	pushl  -0xc(%ebp)
80108e53:	e8 a3 f7 ff ff       	call   801085fb <v2p>
80108e58:	83 c4 10             	add    $0x10,%esp
80108e5b:	83 ec 0c             	sub    $0xc,%esp
80108e5e:	6a 06                	push   $0x6
80108e60:	50                   	push   %eax
80108e61:	68 00 10 00 00       	push   $0x1000
80108e66:	6a 00                	push   $0x0
80108e68:	ff 75 08             	pushl  0x8(%ebp)
80108e6b:	e8 ba fc ff ff       	call   80108b2a <mappages>
80108e70:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108e73:	83 ec 04             	sub    $0x4,%esp
80108e76:	ff 75 10             	pushl  0x10(%ebp)
80108e79:	ff 75 0c             	pushl  0xc(%ebp)
80108e7c:	ff 75 f4             	pushl  -0xc(%ebp)
80108e7f:	e8 05 d0 ff ff       	call   80105e89 <memmove>
80108e84:	83 c4 10             	add    $0x10,%esp
}
80108e87:	90                   	nop
80108e88:	c9                   	leave  
80108e89:	c3                   	ret    

80108e8a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e8a:	55                   	push   %ebp
80108e8b:	89 e5                	mov    %esp,%ebp
80108e8d:	53                   	push   %ebx
80108e8e:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e91:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e94:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e99:	85 c0                	test   %eax,%eax
80108e9b:	74 0d                	je     80108eaa <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108e9d:	83 ec 0c             	sub    $0xc,%esp
80108ea0:	68 e0 9a 10 80       	push   $0x80109ae0
80108ea5:	e8 bc 76 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108eaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108eb1:	e9 95 00 00 00       	jmp    80108f4b <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108eb6:	8b 55 0c             	mov    0xc(%ebp),%edx
80108eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebc:	01 d0                	add    %edx,%eax
80108ebe:	83 ec 04             	sub    $0x4,%esp
80108ec1:	6a 00                	push   $0x0
80108ec3:	50                   	push   %eax
80108ec4:	ff 75 08             	pushl  0x8(%ebp)
80108ec7:	e8 be fb ff ff       	call   80108a8a <walkpgdir>
80108ecc:	83 c4 10             	add    $0x10,%esp
80108ecf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108ed2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ed6:	75 0d                	jne    80108ee5 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108ed8:	83 ec 0c             	sub    $0xc,%esp
80108edb:	68 03 9b 10 80       	push   $0x80109b03
80108ee0:	e8 81 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee8:	8b 00                	mov    (%eax),%eax
80108eea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108ef2:	8b 45 18             	mov    0x18(%ebp),%eax
80108ef5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108ef8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108efd:	77 0b                	ja     80108f0a <loaduvm+0x80>
      n = sz - i;
80108eff:	8b 45 18             	mov    0x18(%ebp),%eax
80108f02:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f08:	eb 07                	jmp    80108f11 <loaduvm+0x87>
    else
      n = PGSIZE;
80108f0a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108f11:	8b 55 14             	mov    0x14(%ebp),%edx
80108f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f17:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108f1a:	83 ec 0c             	sub    $0xc,%esp
80108f1d:	ff 75 e8             	pushl  -0x18(%ebp)
80108f20:	e8 e3 f6 ff ff       	call   80108608 <p2v>
80108f25:	83 c4 10             	add    $0x10,%esp
80108f28:	ff 75 f0             	pushl  -0x10(%ebp)
80108f2b:	53                   	push   %ebx
80108f2c:	50                   	push   %eax
80108f2d:	ff 75 10             	pushl  0x10(%ebp)
80108f30:	e8 3b 96 ff ff       	call   80102570 <readi>
80108f35:	83 c4 10             	add    $0x10,%esp
80108f38:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108f3b:	74 07                	je     80108f44 <loaduvm+0xba>
      return -1;
80108f3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f42:	eb 18                	jmp    80108f5c <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108f44:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f4e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108f51:	0f 82 5f ff ff ff    	jb     80108eb6 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108f57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f5f:	c9                   	leave  
80108f60:	c3                   	ret    

80108f61 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f61:	55                   	push   %ebp
80108f62:	89 e5                	mov    %esp,%ebp
80108f64:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f67:	8b 45 10             	mov    0x10(%ebp),%eax
80108f6a:	85 c0                	test   %eax,%eax
80108f6c:	79 0a                	jns    80108f78 <allocuvm+0x17>
    return 0;
80108f6e:	b8 00 00 00 00       	mov    $0x0,%eax
80108f73:	e9 b0 00 00 00       	jmp    80109028 <allocuvm+0xc7>
  if(newsz < oldsz)
80108f78:	8b 45 10             	mov    0x10(%ebp),%eax
80108f7b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f7e:	73 08                	jae    80108f88 <allocuvm+0x27>
    return oldsz;
80108f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f83:	e9 a0 00 00 00       	jmp    80109028 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108f88:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f8b:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108f98:	eb 7f                	jmp    80109019 <allocuvm+0xb8>
    mem = kalloc();
80108f9a:	e8 cc a4 ff ff       	call   8010346b <kalloc>
80108f9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108fa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108fa6:	75 2b                	jne    80108fd3 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108fa8:	83 ec 0c             	sub    $0xc,%esp
80108fab:	68 21 9b 10 80       	push   $0x80109b21
80108fb0:	e8 11 74 ff ff       	call   801003c6 <cprintf>
80108fb5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108fb8:	83 ec 04             	sub    $0x4,%esp
80108fbb:	ff 75 0c             	pushl  0xc(%ebp)
80108fbe:	ff 75 10             	pushl  0x10(%ebp)
80108fc1:	ff 75 08             	pushl  0x8(%ebp)
80108fc4:	e8 61 00 00 00       	call   8010902a <deallocuvm>
80108fc9:	83 c4 10             	add    $0x10,%esp
      return 0;
80108fcc:	b8 00 00 00 00       	mov    $0x0,%eax
80108fd1:	eb 55                	jmp    80109028 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108fd3:	83 ec 04             	sub    $0x4,%esp
80108fd6:	68 00 10 00 00       	push   $0x1000
80108fdb:	6a 00                	push   $0x0
80108fdd:	ff 75 f0             	pushl  -0x10(%ebp)
80108fe0:	e8 e5 cd ff ff       	call   80105dca <memset>
80108fe5:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108fe8:	83 ec 0c             	sub    $0xc,%esp
80108feb:	ff 75 f0             	pushl  -0x10(%ebp)
80108fee:	e8 08 f6 ff ff       	call   801085fb <v2p>
80108ff3:	83 c4 10             	add    $0x10,%esp
80108ff6:	89 c2                	mov    %eax,%edx
80108ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ffb:	83 ec 0c             	sub    $0xc,%esp
80108ffe:	6a 06                	push   $0x6
80109000:	52                   	push   %edx
80109001:	68 00 10 00 00       	push   $0x1000
80109006:	50                   	push   %eax
80109007:	ff 75 08             	pushl  0x8(%ebp)
8010900a:	e8 1b fb ff ff       	call   80108b2a <mappages>
8010900f:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109012:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010901f:	0f 82 75 ff ff ff    	jb     80108f9a <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109025:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109028:	c9                   	leave  
80109029:	c3                   	ret    

8010902a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010902a:	55                   	push   %ebp
8010902b:	89 e5                	mov    %esp,%ebp
8010902d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109030:	8b 45 10             	mov    0x10(%ebp),%eax
80109033:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109036:	72 08                	jb     80109040 <deallocuvm+0x16>
    return oldsz;
80109038:	8b 45 0c             	mov    0xc(%ebp),%eax
8010903b:	e9 a5 00 00 00       	jmp    801090e5 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109040:	8b 45 10             	mov    0x10(%ebp),%eax
80109043:	05 ff 0f 00 00       	add    $0xfff,%eax
80109048:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010904d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109050:	e9 81 00 00 00       	jmp    801090d6 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109058:	83 ec 04             	sub    $0x4,%esp
8010905b:	6a 00                	push   $0x0
8010905d:	50                   	push   %eax
8010905e:	ff 75 08             	pushl  0x8(%ebp)
80109061:	e8 24 fa ff ff       	call   80108a8a <walkpgdir>
80109066:	83 c4 10             	add    $0x10,%esp
80109069:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010906c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109070:	75 09                	jne    8010907b <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109072:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109079:	eb 54                	jmp    801090cf <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010907b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010907e:	8b 00                	mov    (%eax),%eax
80109080:	83 e0 01             	and    $0x1,%eax
80109083:	85 c0                	test   %eax,%eax
80109085:	74 48                	je     801090cf <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010908a:	8b 00                	mov    (%eax),%eax
8010908c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109091:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109094:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109098:	75 0d                	jne    801090a7 <deallocuvm+0x7d>
        panic("kfree");
8010909a:	83 ec 0c             	sub    $0xc,%esp
8010909d:	68 39 9b 10 80       	push   $0x80109b39
801090a2:	e8 bf 74 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801090a7:	83 ec 0c             	sub    $0xc,%esp
801090aa:	ff 75 ec             	pushl  -0x14(%ebp)
801090ad:	e8 56 f5 ff ff       	call   80108608 <p2v>
801090b2:	83 c4 10             	add    $0x10,%esp
801090b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801090b8:	83 ec 0c             	sub    $0xc,%esp
801090bb:	ff 75 e8             	pushl  -0x18(%ebp)
801090be:	e8 0b a3 ff ff       	call   801033ce <kfree>
801090c3:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801090c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801090cf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090dc:	0f 82 73 ff ff ff    	jb     80109055 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801090e2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090e5:	c9                   	leave  
801090e6:	c3                   	ret    

801090e7 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801090e7:	55                   	push   %ebp
801090e8:	89 e5                	mov    %esp,%ebp
801090ea:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801090ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801090f1:	75 0d                	jne    80109100 <freevm+0x19>
    panic("freevm: no pgdir");
801090f3:	83 ec 0c             	sub    $0xc,%esp
801090f6:	68 3f 9b 10 80       	push   $0x80109b3f
801090fb:	e8 66 74 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109100:	83 ec 04             	sub    $0x4,%esp
80109103:	6a 00                	push   $0x0
80109105:	68 00 00 00 80       	push   $0x80000000
8010910a:	ff 75 08             	pushl  0x8(%ebp)
8010910d:	e8 18 ff ff ff       	call   8010902a <deallocuvm>
80109112:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109115:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010911c:	eb 4f                	jmp    8010916d <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010911e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109121:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109128:	8b 45 08             	mov    0x8(%ebp),%eax
8010912b:	01 d0                	add    %edx,%eax
8010912d:	8b 00                	mov    (%eax),%eax
8010912f:	83 e0 01             	and    $0x1,%eax
80109132:	85 c0                	test   %eax,%eax
80109134:	74 33                	je     80109169 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109139:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109140:	8b 45 08             	mov    0x8(%ebp),%eax
80109143:	01 d0                	add    %edx,%eax
80109145:	8b 00                	mov    (%eax),%eax
80109147:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010914c:	83 ec 0c             	sub    $0xc,%esp
8010914f:	50                   	push   %eax
80109150:	e8 b3 f4 ff ff       	call   80108608 <p2v>
80109155:	83 c4 10             	add    $0x10,%esp
80109158:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010915b:	83 ec 0c             	sub    $0xc,%esp
8010915e:	ff 75 f0             	pushl  -0x10(%ebp)
80109161:	e8 68 a2 ff ff       	call   801033ce <kfree>
80109166:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109169:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010916d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109174:	76 a8                	jbe    8010911e <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109176:	83 ec 0c             	sub    $0xc,%esp
80109179:	ff 75 08             	pushl  0x8(%ebp)
8010917c:	e8 4d a2 ff ff       	call   801033ce <kfree>
80109181:	83 c4 10             	add    $0x10,%esp
}
80109184:	90                   	nop
80109185:	c9                   	leave  
80109186:	c3                   	ret    

80109187 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109187:	55                   	push   %ebp
80109188:	89 e5                	mov    %esp,%ebp
8010918a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010918d:	83 ec 04             	sub    $0x4,%esp
80109190:	6a 00                	push   $0x0
80109192:	ff 75 0c             	pushl  0xc(%ebp)
80109195:	ff 75 08             	pushl  0x8(%ebp)
80109198:	e8 ed f8 ff ff       	call   80108a8a <walkpgdir>
8010919d:	83 c4 10             	add    $0x10,%esp
801091a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801091a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801091a7:	75 0d                	jne    801091b6 <clearpteu+0x2f>
    panic("clearpteu");
801091a9:	83 ec 0c             	sub    $0xc,%esp
801091ac:	68 50 9b 10 80       	push   $0x80109b50
801091b1:	e8 b0 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801091b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b9:	8b 00                	mov    (%eax),%eax
801091bb:	83 e0 fb             	and    $0xfffffffb,%eax
801091be:	89 c2                	mov    %eax,%edx
801091c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c3:	89 10                	mov    %edx,(%eax)
}
801091c5:	90                   	nop
801091c6:	c9                   	leave  
801091c7:	c3                   	ret    

801091c8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801091c8:	55                   	push   %ebp
801091c9:	89 e5                	mov    %esp,%ebp
801091cb:	53                   	push   %ebx
801091cc:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801091cf:	e8 e6 f9 ff ff       	call   80108bba <setupkvm>
801091d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801091d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801091db:	75 0a                	jne    801091e7 <copyuvm+0x1f>
    return 0;
801091dd:	b8 00 00 00 00       	mov    $0x0,%eax
801091e2:	e9 f8 00 00 00       	jmp    801092df <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801091e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091ee:	e9 c4 00 00 00       	jmp    801092b7 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801091f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f6:	83 ec 04             	sub    $0x4,%esp
801091f9:	6a 00                	push   $0x0
801091fb:	50                   	push   %eax
801091fc:	ff 75 08             	pushl  0x8(%ebp)
801091ff:	e8 86 f8 ff ff       	call   80108a8a <walkpgdir>
80109204:	83 c4 10             	add    $0x10,%esp
80109207:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010920a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010920e:	75 0d                	jne    8010921d <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109210:	83 ec 0c             	sub    $0xc,%esp
80109213:	68 5a 9b 10 80       	push   $0x80109b5a
80109218:	e8 49 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010921d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109220:	8b 00                	mov    (%eax),%eax
80109222:	83 e0 01             	and    $0x1,%eax
80109225:	85 c0                	test   %eax,%eax
80109227:	75 0d                	jne    80109236 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109229:	83 ec 0c             	sub    $0xc,%esp
8010922c:	68 74 9b 10 80       	push   $0x80109b74
80109231:	e8 30 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109236:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109239:	8b 00                	mov    (%eax),%eax
8010923b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109240:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109243:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109246:	8b 00                	mov    (%eax),%eax
80109248:	25 ff 0f 00 00       	and    $0xfff,%eax
8010924d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109250:	e8 16 a2 ff ff       	call   8010346b <kalloc>
80109255:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109258:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010925c:	74 6a                	je     801092c8 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010925e:	83 ec 0c             	sub    $0xc,%esp
80109261:	ff 75 e8             	pushl  -0x18(%ebp)
80109264:	e8 9f f3 ff ff       	call   80108608 <p2v>
80109269:	83 c4 10             	add    $0x10,%esp
8010926c:	83 ec 04             	sub    $0x4,%esp
8010926f:	68 00 10 00 00       	push   $0x1000
80109274:	50                   	push   %eax
80109275:	ff 75 e0             	pushl  -0x20(%ebp)
80109278:	e8 0c cc ff ff       	call   80105e89 <memmove>
8010927d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109280:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109283:	83 ec 0c             	sub    $0xc,%esp
80109286:	ff 75 e0             	pushl  -0x20(%ebp)
80109289:	e8 6d f3 ff ff       	call   801085fb <v2p>
8010928e:	83 c4 10             	add    $0x10,%esp
80109291:	89 c2                	mov    %eax,%edx
80109293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109296:	83 ec 0c             	sub    $0xc,%esp
80109299:	53                   	push   %ebx
8010929a:	52                   	push   %edx
8010929b:	68 00 10 00 00       	push   $0x1000
801092a0:	50                   	push   %eax
801092a1:	ff 75 f0             	pushl  -0x10(%ebp)
801092a4:	e8 81 f8 ff ff       	call   80108b2a <mappages>
801092a9:	83 c4 20             	add    $0x20,%esp
801092ac:	85 c0                	test   %eax,%eax
801092ae:	78 1b                	js     801092cb <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801092b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801092b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092bd:	0f 82 30 ff ff ff    	jb     801091f3 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801092c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c6:	eb 17                	jmp    801092df <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801092c8:	90                   	nop
801092c9:	eb 01                	jmp    801092cc <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801092cb:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801092cc:	83 ec 0c             	sub    $0xc,%esp
801092cf:	ff 75 f0             	pushl  -0x10(%ebp)
801092d2:	e8 10 fe ff ff       	call   801090e7 <freevm>
801092d7:	83 c4 10             	add    $0x10,%esp
  return 0;
801092da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801092e2:	c9                   	leave  
801092e3:	c3                   	ret    

801092e4 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801092e4:	55                   	push   %ebp
801092e5:	89 e5                	mov    %esp,%ebp
801092e7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801092ea:	83 ec 04             	sub    $0x4,%esp
801092ed:	6a 00                	push   $0x0
801092ef:	ff 75 0c             	pushl  0xc(%ebp)
801092f2:	ff 75 08             	pushl  0x8(%ebp)
801092f5:	e8 90 f7 ff ff       	call   80108a8a <walkpgdir>
801092fa:	83 c4 10             	add    $0x10,%esp
801092fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109303:	8b 00                	mov    (%eax),%eax
80109305:	83 e0 01             	and    $0x1,%eax
80109308:	85 c0                	test   %eax,%eax
8010930a:	75 07                	jne    80109313 <uva2ka+0x2f>
    return 0;
8010930c:	b8 00 00 00 00       	mov    $0x0,%eax
80109311:	eb 29                	jmp    8010933c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109316:	8b 00                	mov    (%eax),%eax
80109318:	83 e0 04             	and    $0x4,%eax
8010931b:	85 c0                	test   %eax,%eax
8010931d:	75 07                	jne    80109326 <uva2ka+0x42>
    return 0;
8010931f:	b8 00 00 00 00       	mov    $0x0,%eax
80109324:	eb 16                	jmp    8010933c <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109329:	8b 00                	mov    (%eax),%eax
8010932b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109330:	83 ec 0c             	sub    $0xc,%esp
80109333:	50                   	push   %eax
80109334:	e8 cf f2 ff ff       	call   80108608 <p2v>
80109339:	83 c4 10             	add    $0x10,%esp
}
8010933c:	c9                   	leave  
8010933d:	c3                   	ret    

8010933e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010933e:	55                   	push   %ebp
8010933f:	89 e5                	mov    %esp,%ebp
80109341:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109344:	8b 45 10             	mov    0x10(%ebp),%eax
80109347:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010934a:	eb 7f                	jmp    801093cb <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010934c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010934f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109354:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109357:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010935a:	83 ec 08             	sub    $0x8,%esp
8010935d:	50                   	push   %eax
8010935e:	ff 75 08             	pushl  0x8(%ebp)
80109361:	e8 7e ff ff ff       	call   801092e4 <uva2ka>
80109366:	83 c4 10             	add    $0x10,%esp
80109369:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010936c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109370:	75 07                	jne    80109379 <copyout+0x3b>
      return -1;
80109372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109377:	eb 61                	jmp    801093da <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109379:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010937c:	2b 45 0c             	sub    0xc(%ebp),%eax
8010937f:	05 00 10 00 00       	add    $0x1000,%eax
80109384:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010938a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010938d:	76 06                	jbe    80109395 <copyout+0x57>
      n = len;
8010938f:	8b 45 14             	mov    0x14(%ebp),%eax
80109392:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109395:	8b 45 0c             	mov    0xc(%ebp),%eax
80109398:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010939b:	89 c2                	mov    %eax,%edx
8010939d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093a0:	01 d0                	add    %edx,%eax
801093a2:	83 ec 04             	sub    $0x4,%esp
801093a5:	ff 75 f0             	pushl  -0x10(%ebp)
801093a8:	ff 75 f4             	pushl  -0xc(%ebp)
801093ab:	50                   	push   %eax
801093ac:	e8 d8 ca ff ff       	call   80105e89 <memmove>
801093b1:	83 c4 10             	add    $0x10,%esp
    len -= n;
801093b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b7:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801093ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bd:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801093c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093c3:	05 00 10 00 00       	add    $0x1000,%eax
801093c8:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801093cb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801093cf:	0f 85 77 ff ff ff    	jne    8010934c <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801093d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093da:	c9                   	leave  
801093db:	c3                   	ret    
