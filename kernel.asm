
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

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
8010002d:	b8 e4 43 10 80       	mov    $0x801043e4,%eax
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
8010003d:	68 4c 94 10 80       	push   $0x8010944c
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 19 5b 00 00       	call   80105b65 <initlock>
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
801000c1:	e8 c1 5a 00 00       	call   80105b87 <acquire>
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
8010010c:	e8 dd 5a 00 00       	call   80105bee <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 62 57 00 00       	call   8010588e <sleep>
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
80100188:	e8 61 5a 00 00       	call   80105bee <release>
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
801001aa:	68 53 94 10 80       	push   $0x80109453
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
801001e2:	e8 32 2f 00 00       	call   80103119 <iderw>
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
80100204:	68 64 94 10 80       	push   $0x80109464
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
80100223:	e8 f1 2e 00 00       	call   80103119 <iderw>
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
80100243:	68 6b 94 10 80       	push   $0x8010946b
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 2d 59 00 00       	call   80105b87 <acquire>
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
801002b9:	e8 bb 56 00 00       	call   80105979 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 20 59 00 00       	call   80105bee <release>
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
801003e2:	e8 a0 57 00 00       	call   80105b87 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 72 94 10 80       	push   $0x80109472
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
801004cd:	c7 45 ec 7b 94 10 80 	movl   $0x8010947b,-0x14(%ebp)
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
8010055b:	e8 8e 56 00 00       	call   80105bee <release>
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
8010058b:	68 82 94 10 80       	push   $0x80109482
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
801005aa:	68 91 94 10 80       	push   $0x80109491
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 79 56 00 00       	call   80105c40 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 93 94 10 80       	push   $0x80109493
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
801006ca:	68 97 94 10 80       	push   $0x80109497
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
801006f7:	e8 ad 57 00 00       	call   80105ea9 <memmove>
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
80100721:	e8 c4 56 00 00       	call   80105dea <memset>
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
801007b6:	e8 18 73 00 00       	call   80107ad3 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 0b 73 00 00       	call   80107ad3 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 fe 72 00 00       	call   80107ad3 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 ee 72 00 00       	call   80107ad3 <uartputc>
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
8010080e:	e8 74 53 00 00       	call   80105b87 <acquire>
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
8010084d:	a1 e8 1a 11 80       	mov    0x80111ae8,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 e8 1a 11 80       	mov    %eax,0x80111ae8
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
8010086a:	8b 15 e8 1a 11 80    	mov    0x80111ae8,%edx
80100870:	a1 e4 1a 11 80       	mov    0x80111ae4,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 e8 1a 11 80       	mov    0x80111ae8,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 60 1a 11 80 	movzbl -0x7feee5a0(%eax),%eax
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
80100898:	8b 15 e8 1a 11 80    	mov    0x80111ae8,%edx
8010089e:	a1 e4 1a 11 80       	mov    0x80111ae4,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 e8 1a 11 80       	mov    0x80111ae8,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 e8 1a 11 80       	mov    %eax,0x80111ae8
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
801008d7:	8b 15 e8 1a 11 80    	mov    0x80111ae8,%edx
801008dd:	a1 e0 1a 11 80       	mov    0x80111ae0,%eax
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
801008fe:	a1 e8 1a 11 80       	mov    0x80111ae8,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 e8 1a 11 80    	mov    %edx,0x80111ae8
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 60 1a 11 80    	mov    %dl,-0x7feee5a0(%eax)
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
80100932:	a1 e8 1a 11 80       	mov    0x80111ae8,%eax
80100937:	8b 15 e0 1a 11 80    	mov    0x80111ae0,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 e8 1a 11 80       	mov    0x80111ae8,%eax
80100949:	a3 e4 1a 11 80       	mov    %eax,0x80111ae4
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 e0 1a 11 80       	push   $0x80111ae0
80100956:	e8 1e 50 00 00       	call   80105979 <wakeup>
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
80100979:	e8 70 52 00 00       	call   80105bee <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 a8 50 00 00       	call   80105a34 <procdump>
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
8010099b:	e8 f3 16 00 00       	call   80102093 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 d1 51 00 00       	call   80105b87 <acquire>
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
801009d3:	e8 16 52 00 00       	call   80105bee <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        //cprintf("cRead \n");
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 0c 15 00 00       	call   80101ef2 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 e0 1a 11 80       	push   $0x80111ae0
80100a00:	e8 89 4e 00 00       	call   8010588e <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp
//cprintf("consoleread \n");
  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 e0 1a 11 80    	mov    0x80111ae0,%edx
80100a0e:	a1 e4 1a 11 80       	mov    0x80111ae4,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 e0 1a 11 80       	mov    0x80111ae0,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 e0 1a 11 80    	mov    %edx,0x80111ae0
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 60 1a 11 80 	movzbl -0x7feee5a0(%eax),%eax
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
80100a43:	a1 e0 1a 11 80       	mov    0x80111ae0,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 e0 1a 11 80       	mov    %eax,0x80111ae0
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
80100a7e:	e8 6b 51 00 00       	call   80105bee <release>
80100a83:	83 c4 10             	add    $0x10,%esp
          //    cprintf("cRead2 \n");

  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 61 14 00 00       	call   80101ef2 <ilock>
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
80100aac:	e8 e2 15 00 00       	call   80102093 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 c6 50 00 00       	call   80105b87 <acquire>
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
80100afe:	e8 eb 50 00 00       	call   80105bee <release>
80100b03:	83 c4 10             	add    $0x10,%esp
        //  cprintf("cWrite \n");

  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 e1 13 00 00       	call   80101ef2 <ilock>
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
80100b22:	68 aa 94 10 80       	push   $0x801094aa
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 34 50 00 00       	call   80105b65 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 ec 23 11 80 a0 	movl   $0x80100aa0,0x801123ec
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 e8 23 11 80 8f 	movl   $0x8010098f,0x801123e8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 07 3f 00 00       	call   80104a63 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 7b 27 00 00       	call   801032e6 <ioapicenable>
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
80100b8d:	e8 17 33 00 00       	call   80103ea9 <begin_op>
80100b92:	83 c4 10             	add    $0x10,%esp
  if((ip = namei(path)) == 0){
80100b95:	83 ec 0c             	sub    $0xc,%esp
80100b98:	ff 75 08             	pushl  0x8(%ebp)
80100b9b:	e8 6b 21 00 00       	call   80102d0b <namei>
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
80100bbf:	e8 ec 33 00 00       	call   80103fb0 <end_op>
80100bc4:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bcc:	e9 fa 03 00 00       	jmp    80100fcb <exec+0x45a>
  }
           // cprintf("exec \n");

  ilock(ip);
80100bd1:	83 ec 0c             	sub    $0xc,%esp
80100bd4:	ff 75 d8             	pushl  -0x28(%ebp)
80100bd7:	e8 16 13 00 00       	call   80101ef2 <ilock>
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
80100bf4:	e8 87 19 00 00       	call   80102580 <readi>
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
80100c16:	e8 0d 80 00 00       	call   80108c28 <setupkvm>
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
80100c54:	e8 27 19 00 00       	call   80102580 <readi>
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
80100c9c:	e8 2e 83 00 00       	call   80108fcf <allocuvm>
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
80100ccf:	e8 24 82 00 00       	call   80108ef8 <loaduvm>
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
80100d08:	e8 e8 14 00 00       	call   801021f5 <iunlockput>
80100d0d:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
80100d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d16:	8b 40 68             	mov    0x68(%eax),%eax
80100d19:	8b 40 50             	mov    0x50(%eax),%eax
80100d1c:	8b 40 14             	mov    0x14(%eax),%eax
80100d1f:	83 ec 0c             	sub    $0xc,%esp
80100d22:	50                   	push   %eax
80100d23:	e8 88 32 00 00       	call   80103fb0 <end_op>
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
80100d54:	e8 76 82 00 00       	call   80108fcf <allocuvm>
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
80100d78:	e8 78 84 00 00       	call   801091f5 <clearpteu>
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
80100db1:	e8 81 52 00 00       	call   80106037 <strlen>
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
80100dde:	e8 54 52 00 00       	call   80106037 <strlen>
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
80100e04:	e8 a3 85 00 00       	call   801093ac <copyout>
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
80100ea0:	e8 07 85 00 00       	call   801093ac <copyout>
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
80100ef1:	e8 f7 50 00 00       	call   80105fed <safestrcpy>
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
80100f47:	e8 c3 7d 00 00       	call   80108d0f <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 fb 81 00 00       	call   80109155 <freevm>
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
80100f8f:	e8 c1 81 00 00       	call   80109155 <freevm>
80100f94:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f97:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f9b:	74 29                	je     80100fc6 <exec+0x455>
    iunlockput(ip);
80100f9d:	83 ec 0c             	sub    $0xc,%esp
80100fa0:	ff 75 d8             	pushl  -0x28(%ebp)
80100fa3:	e8 4d 12 00 00       	call   801021f5 <iunlockput>
80100fa8:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80100fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fb1:	8b 40 68             	mov    0x68(%eax),%eax
80100fb4:	8b 40 50             	mov    0x50(%eax),%eax
80100fb7:	8b 40 14             	mov    0x14(%eax),%eax
80100fba:	83 ec 0c             	sub    $0xc,%esp
80100fbd:	50                   	push   %eax
80100fbe:	e8 ed 2f 00 00       	call   80103fb0 <end_op>
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
80100fd6:	68 b2 94 10 80       	push   $0x801094b2
80100fdb:	68 00 1b 11 80       	push   $0x80111b00
80100fe0:	e8 80 4b 00 00       	call   80105b65 <initlock>
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
80100ff4:	68 00 1b 11 80       	push   $0x80111b00
80100ff9:	e8 89 4b 00 00       	call   80105b87 <acquire>
80100ffe:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101001:	c7 45 f4 34 1b 11 80 	movl   $0x80111b34,-0xc(%ebp)
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
80101021:	68 00 1b 11 80       	push   $0x80111b00
80101026:	e8 c3 4b 00 00       	call   80105bee <release>
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
80101037:	b8 cc 23 11 80       	mov    $0x801123cc,%eax
8010103c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103f:	72 c9                	jb     8010100a <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	68 00 1b 11 80       	push   $0x80111b00
80101049:	e8 a0 4b 00 00       	call   80105bee <release>
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
80101061:	68 00 1b 11 80       	push   $0x80111b00
80101066:	e8 1c 4b 00 00       	call   80105b87 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 b9 94 10 80       	push   $0x801094b9
80101080:	e8 e1 f4 ff ff       	call   80100566 <panic>
  f->ref++;
80101085:	8b 45 08             	mov    0x8(%ebp),%eax
80101088:	8b 40 04             	mov    0x4(%eax),%eax
8010108b:	8d 50 01             	lea    0x1(%eax),%edx
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101094:	83 ec 0c             	sub    $0xc,%esp
80101097:	68 00 1b 11 80       	push   $0x80111b00
8010109c:	e8 4d 4b 00 00       	call   80105bee <release>
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
801010b2:	68 00 1b 11 80       	push   $0x80111b00
801010b7:	e8 cb 4a 00 00       	call   80105b87 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 c1 94 10 80       	push   $0x801094c1
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
801010f2:	68 00 1b 11 80       	push   $0x80111b00
801010f7:	e8 f2 4a 00 00       	call   80105bee <release>
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
80101142:	68 00 1b 11 80       	push   $0x80111b00
80101147:	e8 a2 4a 00 00       	call   80105bee <release>
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
80101166:	e8 61 3b 00 00       	call   80104ccc <pipeclose>
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
80101188:	e8 1c 2d 00 00       	call   80103ea9 <begin_op>
8010118d:	83 c4 10             	add    $0x10,%esp
    iput(ff.ip);
80101190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101193:	83 ec 0c             	sub    $0xc,%esp
80101196:	50                   	push   %eax
80101197:	e8 69 0f 00 00       	call   80102105 <iput>
8010119c:	83 c4 10             	add    $0x10,%esp
    end_op(f->ip->part->number);
8010119f:	8b 45 08             	mov    0x8(%ebp),%eax
801011a2:	8b 40 0e             	mov    0xe(%eax),%eax
801011a5:	8b 40 50             	mov    0x50(%eax),%eax
801011a8:	8b 40 14             	mov    0x14(%eax),%eax
801011ab:	83 ec 0c             	sub    $0xc,%esp
801011ae:	50                   	push   %eax
801011af:	e8 fc 2d 00 00       	call   80103fb0 <end_op>
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
801011d3:	e8 1a 0d 00 00       	call   80101ef2 <ilock>
801011d8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 40 0e             	mov    0xe(%eax),%eax
801011e1:	83 ec 08             	sub    $0x8,%esp
801011e4:	ff 75 0c             	pushl  0xc(%ebp)
801011e7:	50                   	push   %eax
801011e8:	e8 4d 13 00 00       	call   8010253a <stati>
801011ed:	83 c4 10             	add    $0x10,%esp
   // cprintf("filestat \n");

    iunlock(f->ip);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0e             	mov    0xe(%eax),%eax
801011f6:	83 ec 0c             	sub    $0xc,%esp
801011f9:	50                   	push   %eax
801011fa:	e8 94 0e 00 00       	call   80102093 <iunlock>
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
80101245:	e8 2a 3c 00 00       	call   80104e74 <piperead>
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
80101263:	e8 8a 0c 00 00       	call   80101ef2 <ilock>
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
80101280:	e8 fb 12 00 00       	call   80102580 <readi>
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
801012ac:	e8 e2 0d 00 00       	call   80102093 <iunlock>
801012b1:	83 c4 10             	add    $0x10,%esp
    return r;
801012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b7:	eb 0d                	jmp    801012c6 <fileread+0xb6>
  }
  panic("fileread");
801012b9:	83 ec 0c             	sub    $0xc,%esp
801012bc:	68 cb 94 10 80       	push   $0x801094cb
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
801012fe:	e8 73 3a 00 00       	call   80104d76 <pipewrite>
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
80101353:	e8 51 2b 00 00       	call   80103ea9 <begin_op>
80101358:	83 c4 10             	add    $0x10,%esp
      ilock(f->ip);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 40 0e             	mov    0xe(%eax),%eax
80101361:	83 ec 0c             	sub    $0xc,%esp
80101364:	50                   	push   %eax
80101365:	e8 88 0b 00 00       	call   80101ef2 <ilock>
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
80101388:	e8 93 13 00 00       	call   80102720 <writei>
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
801013b4:	e8 da 0c 00 00       	call   80102093 <iunlock>
801013b9:	83 c4 10             	add    $0x10,%esp
      end_op(f->ip->part->number);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	8b 40 0e             	mov    0xe(%eax),%eax
801013c2:	8b 40 50             	mov    0x50(%eax),%eax
801013c5:	8b 40 14             	mov    0x14(%eax),%eax
801013c8:	83 ec 0c             	sub    $0xc,%esp
801013cb:	50                   	push   %eax
801013cc:	e8 df 2b 00 00       	call   80103fb0 <end_op>
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
801013e5:	68 d4 94 10 80       	push   $0x801094d4
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
8010141b:	68 e4 94 10 80       	push   $0x801094e4
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
80101439:	05 00 18 11 80       	add    $0x80111800,%eax
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
8010146c:	e8 38 4a 00 00       	call   80105ea9 <memmove>
80101471:	83 c4 10             	add    $0x10,%esp
    sbs[partitionNumber].offset = mbrI.partitions[partitionNumber].offset;
80101474:	8b 45 0c             	mov    0xc(%ebp),%eax
80101477:	83 c0 1b             	add    $0x1b,%eax
8010147a:	c1 e0 04             	shl    $0x4,%eax
8010147d:	05 00 18 11 80       	add    $0x80111800,%eax
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
801014ce:	68 00 18 11 80       	push   $0x80111800
801014d3:	e8 d1 49 00 00       	call   80105ea9 <memmove>
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
80101519:	e8 cc 48 00 00       	call   80105dea <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp, partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 27 2d 00 00       	call   80104256 <log_write>
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
8010163f:	e8 12 2c 00 00       	call   80104256 <log_write>
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
801016ca:	68 f0 94 10 80       	push   $0x801094f0
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
80101787:	68 06 95 10 80       	push   $0x80109506
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
801017c3:	e8 8e 2a 00 00       	call   80104256 <log_write>
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
801017e5:	68 19 95 10 80       	push   $0x80109519
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
8010182a:	c7 45 f0 24 95 10 80 	movl   $0x80109524,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 28 95 10 80 	movl   $0x80109528,-0x10(%ebp)
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
80101889:	c7 45 ec 2b 95 10 80 	movl   $0x8010952b,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 2f 95 10 80       	push   $0x8010952f
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
801018e2:	68 44 95 10 80       	push   $0x80109544
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
80101909:	68 7a 95 10 80       	push   $0x8010957a
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
80101942:	05 00 18 11 80       	add    $0x80111800,%eax
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
80101970:	05 00 1a 11 80       	add    $0x80111a00,%eax
80101975:	89 08                	mov    %ecx,(%eax)
        partitions[i].flags = mbrI.partitions[i].flags;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	83 c0 1b             	add    $0x1b,%eax
8010197d:	c1 e0 04             	shl    $0x4,%eax
80101980:	05 00 18 11 80       	add    $0x80111800,%eax
80101985:	8b 48 0e             	mov    0xe(%eax),%ecx
80101988:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010198b:	89 d0                	mov    %edx,%eax
8010198d:	01 c0                	add    %eax,%eax
8010198f:	01 d0                	add    %edx,%eax
80101991:	c1 e0 03             	shl    $0x3,%eax
80101994:	05 00 1a 11 80       	add    $0x80111a00,%eax
80101999:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].type = mbrI.partitions[i].type;
8010199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199f:	83 c0 1b             	add    $0x1b,%eax
801019a2:	c1 e0 04             	shl    $0x4,%eax
801019a5:	05 00 18 11 80       	add    $0x80111800,%eax
801019aa:	8b 48 12             	mov    0x12(%eax),%ecx
801019ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019b0:	89 d0                	mov    %edx,%eax
801019b2:	01 c0                	add    %eax,%eax
801019b4:	01 d0                	add    %edx,%eax
801019b6:	c1 e0 03             	shl    $0x3,%eax
801019b9:	05 00 1a 11 80       	add    $0x80111a00,%eax
801019be:	89 48 08             	mov    %ecx,0x8(%eax)
        partitions[i].number = i;
801019c1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801019c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019c7:	89 d0                	mov    %edx,%eax
801019c9:	01 c0                	add    %eax,%eax
801019cb:	01 d0                	add    %edx,%eax
801019cd:	c1 e0 03             	shl    $0x3,%eax
801019d0:	05 10 1a 11 80       	add    $0x80111a10,%eax
801019d5:	89 48 04             	mov    %ecx,0x4(%eax)
        partitions[i].offset = mbrI.partitions[i].offset;
801019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019db:	83 c0 1b             	add    $0x1b,%eax
801019de:	c1 e0 04             	shl    $0x4,%eax
801019e1:	05 00 18 11 80       	add    $0x80111800,%eax
801019e6:	8b 48 16             	mov    0x16(%eax),%ecx
801019e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019ec:	89 d0                	mov    %edx,%eax
801019ee:	01 c0                	add    %eax,%eax
801019f0:	01 d0                	add    %edx,%eax
801019f2:	c1 e0 03             	shl    $0x3,%eax
801019f5:	05 00 1a 11 80       	add    $0x80111a00,%eax
801019fa:	89 48 0c             	mov    %ecx,0xc(%eax)
        partitions[i].size = mbrI.partitions[i].size;
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	83 c0 1b             	add    $0x1b,%eax
80101a03:	c1 e0 04             	shl    $0x4,%eax
80101a06:	05 00 18 11 80       	add    $0x80111800,%eax
80101a0b:	8b 48 1a             	mov    0x1a(%eax),%ecx
80101a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a11:	89 d0                	mov    %edx,%eax
80101a13:	01 c0                	add    %eax,%eax
80101a15:	01 d0                	add    %edx,%eax
80101a17:	c1 e0 03             	shl    $0x3,%eax
80101a1a:	05 10 1a 11 80       	add    $0x80111a10,%eax
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
    cprintf("kernal by Asaf and Ilana \n");
80101a3b:	83 ec 0c             	sub    $0xc,%esp
80101a3e:	68 85 95 10 80       	push   $0x80109585
80101a43:	e8 7e e9 ff ff       	call   801003c6 <cprintf>
80101a48:	83 c4 10             	add    $0x10,%esp
    initlock(&icache.lock, "icache");
80101a4b:	83 ec 08             	sub    $0x8,%esp
80101a4e:	68 a0 95 10 80       	push   $0x801095a0
80101a53:	68 60 24 11 80       	push   $0x80112460
80101a58:	e8 08 41 00 00       	call   80105b65 <initlock>
80101a5d:	83 c4 10             	add    $0x10,%esp

    rootNode = p->cwd;
80101a60:	8b 45 08             	mov    0x8(%ebp),%eax
80101a63:	8b 40 68             	mov    0x68(%eax),%eax
80101a66:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // acquire(&icache.lock);

    initMbr(dev);
80101a69:	83 ec 0c             	sub    $0xc,%esp
80101a6c:	ff 75 0c             	pushl  0xc(%ebp)
80101a6f:	e8 a5 fe ff ff       	call   80101919 <initMbr>
80101a74:	83 c4 10             	add    $0x10,%esp
    printMBR(&mbrI);
80101a77:	83 ec 0c             	sub    $0xc,%esp
80101a7a:	68 00 18 11 80       	push   $0x80111800
80101a7f:	e8 58 fd ff ff       	call   801017dc <printMBR>
80101a84:	83 c4 10             	add    $0x10,%esp
    cprintf("booting from %d \n", bootfrom);
80101a87:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a8c:	83 ec 08             	sub    $0x8,%esp
80101a8f:	50                   	push   %eax
80101a90:	68 a7 95 10 80       	push   $0x801095a7
80101a95:	e8 2c e9 ff ff       	call   801003c6 <cprintf>
80101a9a:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a9d:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101aa2:	83 f8 ff             	cmp    $0xffffffff,%eax
80101aa5:	75 0d                	jne    80101ab4 <iinit+0x82>
        panic("no bootable partition");
80101aa7:	83 ec 0c             	sub    $0xc,%esp
80101aaa:	68 b9 95 10 80       	push   $0x801095b9
80101aaf:	e8 b2 ea ff ff       	call   80100566 <panic>
    }
    rootNode->part = &(partitions[bootfrom]);
80101ab4:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
80101aba:	89 d0                	mov    %edx,%eax
80101abc:	01 c0                	add    %eax,%eax
80101abe:	01 d0                	add    %edx,%eax
80101ac0:	c1 e0 03             	shl    $0x3,%eax
80101ac3:	8d 90 00 1a 11 80    	lea    -0x7feee600(%eax),%edx
80101ac9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101acc:	89 50 50             	mov    %edx,0x50(%eax)
    int i;
    for (i = 0; i < NPARTITIONS; i++) {
80101acf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101ad6:	e9 89 00 00 00       	jmp    80101b64 <iinit+0x132>
        readsb(dev, i);
80101adb:	83 ec 08             	sub    $0x8,%esp
80101ade:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ae1:	ff 75 0c             	pushl  0xc(%ebp)
80101ae4:	e8 41 f9 ff ff       	call   8010142a <readsb>
80101ae9:	83 c4 10             	add    $0x10,%esp
        sb = sbs[i];
80101aec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101aef:	c1 e0 05             	shl    $0x5,%eax
80101af2:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101af7:	8b 10                	mov    (%eax),%edx
80101af9:	89 55 c0             	mov    %edx,-0x40(%ebp)
80101afc:	8b 50 04             	mov    0x4(%eax),%edx
80101aff:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80101b02:	8b 50 08             	mov    0x8(%eax),%edx
80101b05:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101b08:	8b 50 0c             	mov    0xc(%eax),%edx
80101b0b:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101b0e:	8b 50 10             	mov    0x10(%eax),%edx
80101b11:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b14:	8b 50 14             	mov    0x14(%eax),%edx
80101b17:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101b1a:	8b 50 18             	mov    0x18(%eax),%edx
80101b1d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101b20:	8b 40 1c             	mov    0x1c(%eax),%eax
80101b23:	89 45 dc             	mov    %eax,-0x24(%ebp)
        cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
80101b26:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101b29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101b2c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80101b2f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80101b32:	89 4d b0             	mov    %ecx,-0x50(%ebp)
80101b35:	8b 7d cc             	mov    -0x34(%ebp),%edi
80101b38:	8b 75 c8             	mov    -0x38(%ebp),%esi
80101b3b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
80101b3e:	8b 4d c0             	mov    -0x40(%ebp),%ecx
80101b41:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	52                   	push   %edx
80101b48:	ff 75 b4             	pushl  -0x4c(%ebp)
80101b4b:	ff 75 b0             	pushl  -0x50(%ebp)
80101b4e:	57                   	push   %edi
80101b4f:	56                   	push   %esi
80101b50:	53                   	push   %ebx
80101b51:	51                   	push   %ecx
80101b52:	50                   	push   %eax
80101b53:	68 d0 95 10 80       	push   $0x801095d0
80101b58:	e8 69 e8 ff ff       	call   801003c6 <cprintf>
80101b5d:	83 c4 30             	add    $0x30,%esp
    if (bootfrom == -1) {
        panic("no bootable partition");
    }
    rootNode->part = &(partitions[bootfrom]);
    int i;
    for (i = 0; i < NPARTITIONS; i++) {
80101b60:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101b64:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80101b68:	0f 8e 6d ff ff ff    	jle    80101adb <iinit+0xa9>

    // release(&icache.lock);

    // cprintf("root node init %d \n",rootNode->part->offset);

    return bootfrom;
80101b6e:	a1 18 a0 10 80       	mov    0x8010a018,%eax
}
80101b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b76:	5b                   	pop    %ebx
80101b77:	5e                   	pop    %esi
80101b78:	5f                   	pop    %edi
80101b79:	5d                   	pop    %ebp
80101b7a:	c3                   	ret    

80101b7b <ialloc>:

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
80101b7b:	55                   	push   %ebp
80101b7c:	89 e5                	mov    %esp,%ebp
80101b7e:	83 ec 48             	sub    $0x48,%esp
80101b81:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b84:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    // cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
80101b88:	8b 45 10             	mov    0x10(%ebp),%eax
80101b8b:	c1 e0 05             	shl    $0x5,%eax
80101b8e:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101b93:	8b 10                	mov    (%eax),%edx
80101b95:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101b98:	8b 50 04             	mov    0x4(%eax),%edx
80101b9b:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b9e:	8b 50 08             	mov    0x8(%eax),%edx
80101ba1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101ba4:	8b 50 0c             	mov    0xc(%eax),%edx
80101ba7:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101baa:	8b 50 10             	mov    0x10(%eax),%edx
80101bad:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101bb0:	8b 50 14             	mov    0x14(%eax),%edx
80101bb3:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101bb6:	8b 50 18             	mov    0x18(%eax),%edx
80101bb9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101bbc:	8b 40 1c             	mov    0x1c(%eax),%eax
80101bbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101bc2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101bc9:	e9 a9 00 00 00       	jmp    80101c77 <ialloc+0xfc>
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
80101bce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bd4:	89 d1                	mov    %edx,%ecx
80101bd6:	c1 e9 03             	shr    $0x3,%ecx
80101bd9:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101bdc:	01 ca                	add    %ecx,%edx
80101bde:	01 d0                	add    %edx,%eax
80101be0:	83 ec 08             	sub    $0x8,%esp
80101be3:	50                   	push   %eax
80101be4:	ff 75 08             	pushl  0x8(%ebp)
80101be7:	e8 ca e5 ff ff       	call   801001b6 <bread>
80101bec:	83 c4 10             	add    $0x10,%esp
80101bef:	89 45 f0             	mov    %eax,-0x10(%ebp)
        dip = (struct dinode*)bp->data + inum % IPB;
80101bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf5:	8d 50 18             	lea    0x18(%eax),%edx
80101bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bfb:	83 e0 07             	and    $0x7,%eax
80101bfe:	c1 e0 06             	shl    $0x6,%eax
80101c01:	01 d0                	add    %edx,%eax
80101c03:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (dip->type == 0) { // a free inode
80101c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c09:	0f b7 00             	movzwl (%eax),%eax
80101c0c:	66 85 c0             	test   %ax,%ax
80101c0f:	75 54                	jne    80101c65 <ialloc+0xea>
            memset(dip, 0, sizeof(*dip));
80101c11:	83 ec 04             	sub    $0x4,%esp
80101c14:	6a 40                	push   $0x40
80101c16:	6a 00                	push   $0x0
80101c18:	ff 75 ec             	pushl  -0x14(%ebp)
80101c1b:	e8 ca 41 00 00       	call   80105dea <memset>
80101c20:	83 c4 10             	add    $0x10,%esp
            dip->type = type;
80101c23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c26:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
80101c2a:	66 89 10             	mov    %dx,(%eax)
            log_write(bp, partitionNumber); // mark it allocated on the disk
80101c2d:	8b 45 10             	mov    0x10(%ebp),%eax
80101c30:	83 ec 08             	sub    $0x8,%esp
80101c33:	50                   	push   %eax
80101c34:	ff 75 f0             	pushl  -0x10(%ebp)
80101c37:	e8 1a 26 00 00       	call   80104256 <log_write>
80101c3c:	83 c4 10             	add    $0x10,%esp
            brelse(bp);
80101c3f:	83 ec 0c             	sub    $0xc,%esp
80101c42:	ff 75 f0             	pushl  -0x10(%ebp)
80101c45:	e8 e4 e5 ff ff       	call   8010022e <brelse>
80101c4a:	83 c4 10             	add    $0x10,%esp
            return iget(dev, inum, partitionNumber);
80101c4d:	8b 55 10             	mov    0x10(%ebp),%edx
80101c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c53:	83 ec 04             	sub    $0x4,%esp
80101c56:	52                   	push   %edx
80101c57:	50                   	push   %eax
80101c58:	ff 75 08             	pushl  0x8(%ebp)
80101c5b:	e8 42 01 00 00       	call   80101da2 <iget>
80101c60:	83 c4 10             	add    $0x10,%esp
80101c63:	eb 2d                	jmp    80101c92 <ialloc+0x117>
        }
        brelse(bp);
80101c65:	83 ec 0c             	sub    $0xc,%esp
80101c68:	ff 75 f0             	pushl  -0x10(%ebp)
80101c6b:	e8 be e5 ff ff       	call   8010022e <brelse>
80101c70:	83 c4 10             	add    $0x10,%esp
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101c73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7d:	39 c2                	cmp    %eax,%edx
80101c7f:	0f 87 49 ff ff ff    	ja     80101bce <ialloc+0x53>
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
80101c85:	83 ec 0c             	sub    $0xc,%esp
80101c88:	68 2d 96 10 80       	push   $0x8010962d
80101c8d:	e8 d4 e8 ff ff       	call   80100566 <panic>
}
80101c92:	c9                   	leave  
80101c93:	c3                   	ret    

80101c94 <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{
80101c94:	55                   	push   %ebp
80101c95:	89 e5                	mov    %esp,%ebp
80101c97:	83 ec 38             	sub    $0x38,%esp

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
80101c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9d:	8b 40 50             	mov    0x50(%eax),%eax
80101ca0:	8b 40 14             	mov    0x14(%eax),%eax
80101ca3:	c1 e0 05             	shl    $0x5,%eax
80101ca6:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101cab:	8b 10                	mov    (%eax),%edx
80101cad:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101cb0:	8b 50 04             	mov    0x4(%eax),%edx
80101cb3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101cb6:	8b 50 08             	mov    0x8(%eax),%edx
80101cb9:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101cbc:	8b 50 0c             	mov    0xc(%eax),%edx
80101cbf:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101cc2:	8b 50 10             	mov    0x10(%eax),%edx
80101cc5:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101cc8:	8b 50 14             	mov    0x14(%eax),%edx
80101ccb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101cce:	8b 50 18             	mov    0x18(%eax),%edx
80101cd1:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101cd4:	8b 40 1c             	mov    0x1c(%eax),%eax
80101cd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101cda:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	8b 40 04             	mov    0x4(%eax),%eax
80101ce3:	c1 e8 03             	shr    $0x3,%eax
80101ce6:	89 c1                	mov    %eax,%ecx
80101ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ceb:	01 c8                	add    %ecx,%eax
80101ced:	01 c2                	add    %eax,%edx
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	8b 00                	mov    (%eax),%eax
80101cf4:	83 ec 08             	sub    $0x8,%esp
80101cf7:	52                   	push   %edx
80101cf8:	50                   	push   %eax
80101cf9:	e8 b8 e4 ff ff       	call   801001b6 <bread>
80101cfe:	83 c4 10             	add    $0x10,%esp
80101d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum % IPB;
80101d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d07:	8d 50 18             	lea    0x18(%eax),%edx
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 40 04             	mov    0x4(%eax),%eax
80101d10:	83 e0 07             	and    $0x7,%eax
80101d13:	c1 e0 06             	shl    $0x6,%eax
80101d16:	01 d0                	add    %edx,%eax
80101d18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip->type = ip->type;
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d25:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101d28:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2b:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d32:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101d36:	8b 45 08             	mov    0x8(%ebp),%eax
80101d39:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d40:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4e:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101d52:	8b 45 08             	mov    0x8(%ebp),%eax
80101d55:	8b 50 18             	mov    0x18(%eax),%edx
80101d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5b:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d61:	8d 50 1c             	lea    0x1c(%eax),%edx
80101d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d67:	83 c0 0c             	add    $0xc,%eax
80101d6a:	83 ec 04             	sub    $0x4,%esp
80101d6d:	6a 34                	push   $0x34
80101d6f:	52                   	push   %edx
80101d70:	50                   	push   %eax
80101d71:	e8 33 41 00 00       	call   80105ea9 <memmove>
80101d76:	83 c4 10             	add    $0x10,%esp
    log_write(bp, ip->part->number);
80101d79:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7c:	8b 40 50             	mov    0x50(%eax),%eax
80101d7f:	8b 40 14             	mov    0x14(%eax),%eax
80101d82:	83 ec 08             	sub    $0x8,%esp
80101d85:	50                   	push   %eax
80101d86:	ff 75 f4             	pushl  -0xc(%ebp)
80101d89:	e8 c8 24 00 00       	call   80104256 <log_write>
80101d8e:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101d91:	83 ec 0c             	sub    $0xc,%esp
80101d94:	ff 75 f4             	pushl  -0xc(%ebp)
80101d97:	e8 92 e4 ff ff       	call   8010022e <brelse>
80101d9c:	83 c4 10             	add    $0x10,%esp
}
80101d9f:	90                   	nop
80101da0:	c9                   	leave  
80101da1:	c3                   	ret    

80101da2 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
80101da2:	55                   	push   %ebp
80101da3:	89 e5                	mov    %esp,%ebp
80101da5:	83 ec 18             	sub    $0x18,%esp
    struct inode* ip, *empty;

    acquire(&icache.lock);
80101da8:	83 ec 0c             	sub    $0xc,%esp
80101dab:	68 60 24 11 80       	push   $0x80112460
80101db0:	e8 d2 3d 00 00       	call   80105b87 <acquire>
80101db5:	83 c4 10             	add    $0x10,%esp
    // cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
80101db8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101dbf:	c7 45 f4 94 24 11 80 	movl   $0x80112494,-0xc(%ebp)
80101dc6:	eb 78                	jmp    80101e40 <iget+0x9e>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
80101dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dcb:	8b 40 08             	mov    0x8(%eax),%eax
80101dce:	85 c0                	test   %eax,%eax
80101dd0:	7e 54                	jle    80101e26 <iget+0x84>
80101dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd5:	8b 00                	mov    (%eax),%eax
80101dd7:	3b 45 08             	cmp    0x8(%ebp),%eax
80101dda:	75 4a                	jne    80101e26 <iget+0x84>
80101ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ddf:	8b 40 04             	mov    0x4(%eax),%eax
80101de2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101de5:	75 3f                	jne    80101e26 <iget+0x84>
80101de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dea:	8b 40 50             	mov    0x50(%eax),%eax
80101ded:	85 c0                	test   %eax,%eax
80101def:	74 35                	je     80101e26 <iget+0x84>
80101df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df4:	8b 40 50             	mov    0x50(%eax),%eax
80101df7:	8b 40 14             	mov    0x14(%eax),%eax
80101dfa:	3b 45 10             	cmp    0x10(%ebp),%eax
80101dfd:	75 27                	jne    80101e26 <iget+0x84>
            ip->ref++;
80101dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e02:	8b 40 08             	mov    0x8(%eax),%eax
80101e05:	8d 50 01             	lea    0x1(%eax),%edx
80101e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e0b:	89 50 08             	mov    %edx,0x8(%eax)
            release(&icache.lock);
80101e0e:	83 ec 0c             	sub    $0xc,%esp
80101e11:	68 60 24 11 80       	push   $0x80112460
80101e16:	e8 d3 3d 00 00       	call   80105bee <release>
80101e1b:	83 c4 10             	add    $0x10,%esp
            return ip;
80101e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e21:	e9 90 00 00 00       	jmp    80101eb6 <iget+0x114>
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101e26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e2a:	75 10                	jne    80101e3c <iget+0x9a>
80101e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e2f:	8b 40 08             	mov    0x8(%eax),%eax
80101e32:	85 c0                	test   %eax,%eax
80101e34:	75 06                	jne    80101e3c <iget+0x9a>
            empty = ip;
80101e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&icache.lock);
    // cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101e3c:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101e40:	81 7d f4 fc 34 11 80 	cmpl   $0x801134fc,-0xc(%ebp)
80101e47:	0f 82 7b ff ff ff    	jb     80101dc8 <iget+0x26>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
80101e4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e51:	75 0d                	jne    80101e60 <iget+0xbe>
        panic("iget: no inodes");
80101e53:	83 ec 0c             	sub    $0xc,%esp
80101e56:	68 3f 96 10 80       	push   $0x8010963f
80101e5b:	e8 06 e7 ff ff       	call   80100566 <panic>

    ip = empty;
80101e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e63:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip->dev = dev;
80101e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e69:	8b 55 08             	mov    0x8(%ebp),%edx
80101e6c:	89 10                	mov    %edx,(%eax)
    ip->inum = inum;
80101e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e71:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e74:	89 50 04             	mov    %edx,0x4(%eax)
    ip->part = &(partitions[partitionNumber]);
80101e77:	8b 55 10             	mov    0x10(%ebp),%edx
80101e7a:	89 d0                	mov    %edx,%eax
80101e7c:	01 c0                	add    %eax,%eax
80101e7e:	01 d0                	add    %edx,%eax
80101e80:	c1 e0 03             	shl    $0x3,%eax
80101e83:	8d 90 00 1a 11 80    	lea    -0x7feee600(%eax),%edx
80101e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e8c:	89 50 50             	mov    %edx,0x50(%eax)
    ip->ref = 1;
80101e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e92:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    ip->flags = 0;
80101e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    release(&icache.lock);
80101ea3:	83 ec 0c             	sub    $0xc,%esp
80101ea6:	68 60 24 11 80       	push   $0x80112460
80101eab:	e8 3e 3d 00 00       	call   80105bee <release>
80101eb0:	83 c4 10             	add    $0x10,%esp

    return ip;
80101eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101eb6:	c9                   	leave  
80101eb7:	c3                   	ret    

80101eb8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
80101eb8:	55                   	push   %ebp
80101eb9:	89 e5                	mov    %esp,%ebp
80101ebb:	83 ec 08             	sub    $0x8,%esp
    //   cprintf("idup \n");

    acquire(&icache.lock);
80101ebe:	83 ec 0c             	sub    $0xc,%esp
80101ec1:	68 60 24 11 80       	push   $0x80112460
80101ec6:	e8 bc 3c 00 00       	call   80105b87 <acquire>
80101ecb:	83 c4 10             	add    $0x10,%esp
    ip->ref++;
80101ece:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed1:	8b 40 08             	mov    0x8(%eax),%eax
80101ed4:	8d 50 01             	lea    0x1(%eax),%edx
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101edd:	83 ec 0c             	sub    $0xc,%esp
80101ee0:	68 60 24 11 80       	push   $0x80112460
80101ee5:	e8 04 3d 00 00       	call   80105bee <release>
80101eea:	83 c4 10             	add    $0x10,%esp
    return ip;
80101eed:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ef0:	c9                   	leave  
80101ef1:	c3                   	ret    

80101ef2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
80101ef2:	55                   	push   %ebp
80101ef3:	89 e5                	mov    %esp,%ebp
80101ef5:	83 ec 38             	sub    $0x38,%esp
    struct buf* bp;
    struct dinode* dip;
    //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
80101ef8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101efc:	74 0a                	je     80101f08 <ilock+0x16>
80101efe:	8b 45 08             	mov    0x8(%ebp),%eax
80101f01:	8b 40 08             	mov    0x8(%eax),%eax
80101f04:	85 c0                	test   %eax,%eax
80101f06:	7f 0d                	jg     80101f15 <ilock+0x23>
        panic("ilock");
80101f08:	83 ec 0c             	sub    $0xc,%esp
80101f0b:	68 4f 96 10 80       	push   $0x8010964f
80101f10:	e8 51 e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101f15:	83 ec 0c             	sub    $0xc,%esp
80101f18:	68 60 24 11 80       	push   $0x80112460
80101f1d:	e8 65 3c 00 00       	call   80105b87 <acquire>
80101f22:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f25:	eb 13                	jmp    80101f3a <ilock+0x48>
        sleep(ip, &icache.lock);
80101f27:	83 ec 08             	sub    $0x8,%esp
80101f2a:	68 60 24 11 80       	push   $0x80112460
80101f2f:	ff 75 08             	pushl  0x8(%ebp)
80101f32:	e8 57 39 00 00       	call   8010588e <sleep>
80101f37:	83 c4 10             	add    $0x10,%esp

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
80101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3d:	8b 40 0c             	mov    0xc(%eax),%eax
80101f40:	83 e0 01             	and    $0x1,%eax
80101f43:	85 c0                	test   %eax,%eax
80101f45:	75 e0                	jne    80101f27 <ilock+0x35>
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 40 0c             	mov    0xc(%eax),%eax
80101f4d:	83 c8 01             	or     $0x1,%eax
80101f50:	89 c2                	mov    %eax,%edx
80101f52:	8b 45 08             	mov    0x8(%ebp),%eax
80101f55:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101f58:	83 ec 0c             	sub    $0xc,%esp
80101f5b:	68 60 24 11 80       	push   $0x80112460
80101f60:	e8 89 3c 00 00       	call   80105bee <release>
80101f65:	83 c4 10             	add    $0x10,%esp

    if (!(ip->flags & I_VALID)) {
80101f68:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6b:	8b 40 0c             	mov    0xc(%eax),%eax
80101f6e:	83 e0 02             	and    $0x2,%eax
80101f71:	85 c0                	test   %eax,%eax
80101f73:	0f 85 17 01 00 00    	jne    80102090 <ilock+0x19e>
        struct superblock sb;
        sb = sbs[ip->part->number];
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 50             	mov    0x50(%eax),%eax
80101f7f:	8b 40 14             	mov    0x14(%eax),%eax
80101f82:	c1 e0 05             	shl    $0x5,%eax
80101f85:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101f8a:	8b 10                	mov    (%eax),%edx
80101f8c:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101f8f:	8b 50 04             	mov    0x4(%eax),%edx
80101f92:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101f95:	8b 50 08             	mov    0x8(%eax),%edx
80101f98:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101f9b:	8b 50 0c             	mov    0xc(%eax),%edx
80101f9e:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101fa1:	8b 50 10             	mov    0x10(%eax),%edx
80101fa4:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101fa7:	8b 50 14             	mov    0x14(%eax),%edx
80101faa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101fad:	8b 50 18             	mov    0x18(%eax),%edx
80101fb0:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101fb3:	8b 40 1c             	mov    0x1c(%eax),%eax
80101fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101fb9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbf:	8b 40 04             	mov    0x4(%eax),%eax
80101fc2:	c1 e8 03             	shr    $0x3,%eax
80101fc5:	89 c1                	mov    %eax,%ecx
80101fc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101fca:	01 c8                	add    %ecx,%eax
80101fcc:	01 c2                	add    %eax,%edx
80101fce:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd1:	8b 00                	mov    (%eax),%eax
80101fd3:	83 ec 08             	sub    $0x8,%esp
80101fd6:	52                   	push   %edx
80101fd7:	50                   	push   %eax
80101fd8:	e8 d9 e1 ff ff       	call   801001b6 <bread>
80101fdd:	83 c4 10             	add    $0x10,%esp
80101fe0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        dip = (struct dinode*)bp->data + ip->inum % IPB;
80101fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fe6:	8d 50 18             	lea    0x18(%eax),%edx
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	8b 40 04             	mov    0x4(%eax),%eax
80101fef:	83 e0 07             	and    $0x7,%eax
80101ff2:	c1 e0 06             	shl    $0x6,%eax
80101ff5:	01 d0                	add    %edx,%eax
80101ff7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ip->type = dip->type;
80101ffa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ffd:	0f b7 10             	movzwl (%eax),%edx
80102000:	8b 45 08             	mov    0x8(%ebp),%eax
80102003:	66 89 50 10          	mov    %dx,0x10(%eax)
        ip->major = dip->major;
80102007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200a:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010200e:	8b 45 08             	mov    0x8(%ebp),%eax
80102011:	66 89 50 12          	mov    %dx,0x12(%eax)
        ip->minor = dip->minor;
80102015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102018:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010201c:	8b 45 08             	mov    0x8(%ebp),%eax
8010201f:	66 89 50 14          	mov    %dx,0x14(%eax)
        ip->nlink = dip->nlink;
80102023:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102026:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010202a:	8b 45 08             	mov    0x8(%ebp),%eax
8010202d:	66 89 50 16          	mov    %dx,0x16(%eax)
        ip->size = dip->size;
80102031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102034:	8b 50 08             	mov    0x8(%eax),%edx
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	89 50 18             	mov    %edx,0x18(%eax)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010203d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102040:	8d 50 0c             	lea    0xc(%eax),%edx
80102043:	8b 45 08             	mov    0x8(%ebp),%eax
80102046:	83 c0 1c             	add    $0x1c,%eax
80102049:	83 ec 04             	sub    $0x4,%esp
8010204c:	6a 34                	push   $0x34
8010204e:	52                   	push   %edx
8010204f:	50                   	push   %eax
80102050:	e8 54 3e 00 00       	call   80105ea9 <memmove>
80102055:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80102058:	83 ec 0c             	sub    $0xc,%esp
8010205b:	ff 75 f4             	pushl  -0xc(%ebp)
8010205e:	e8 cb e1 ff ff       	call   8010022e <brelse>
80102063:	83 c4 10             	add    $0x10,%esp
        ip->flags |= I_VALID;
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	8b 40 0c             	mov    0xc(%eax),%eax
8010206c:	83 c8 02             	or     $0x2,%eax
8010206f:	89 c2                	mov    %eax,%edx
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	89 50 0c             	mov    %edx,0xc(%eax)
        if (ip->type == 0)
80102077:	8b 45 08             	mov    0x8(%ebp),%eax
8010207a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010207e:	66 85 c0             	test   %ax,%ax
80102081:	75 0d                	jne    80102090 <ilock+0x19e>
            panic("ilock: no type");
80102083:	83 ec 0c             	sub    $0xc,%esp
80102086:	68 55 96 10 80       	push   $0x80109655
8010208b:	e8 d6 e4 ff ff       	call   80100566 <panic>
    }
}
80102090:	90                   	nop
80102091:	c9                   	leave  
80102092:	c3                   	ret    

80102093 <iunlock>:

// Unlock the given inode.
void iunlock(struct inode* ip)
{
80102093:	55                   	push   %ebp
80102094:	89 e5                	mov    %esp,%ebp
80102096:	83 ec 08             	sub    $0x8,%esp
    //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
80102099:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010209d:	74 17                	je     801020b6 <iunlock+0x23>
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 40 0c             	mov    0xc(%eax),%eax
801020a5:	83 e0 01             	and    $0x1,%eax
801020a8:	85 c0                	test   %eax,%eax
801020aa:	74 0a                	je     801020b6 <iunlock+0x23>
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
801020af:	8b 40 08             	mov    0x8(%eax),%eax
801020b2:	85 c0                	test   %eax,%eax
801020b4:	7f 0d                	jg     801020c3 <iunlock+0x30>
        // cprintf("iunlock ilock%d ",ip);
        panic("iunlock");
801020b6:	83 ec 0c             	sub    $0xc,%esp
801020b9:	68 64 96 10 80       	push   $0x80109664
801020be:	e8 a3 e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020c3:	83 ec 0c             	sub    $0xc,%esp
801020c6:	68 60 24 11 80       	push   $0x80112460
801020cb:	e8 b7 3a 00 00       	call   80105b87 <acquire>
801020d0:	83 c4 10             	add    $0x10,%esp
    ip->flags &= ~I_BUSY;
801020d3:	8b 45 08             	mov    0x8(%ebp),%eax
801020d6:	8b 40 0c             	mov    0xc(%eax),%eax
801020d9:	83 e0 fe             	and    $0xfffffffe,%eax
801020dc:	89 c2                	mov    %eax,%edx
801020de:	8b 45 08             	mov    0x8(%ebp),%eax
801020e1:	89 50 0c             	mov    %edx,0xc(%eax)
    wakeup(ip);
801020e4:	83 ec 0c             	sub    $0xc,%esp
801020e7:	ff 75 08             	pushl  0x8(%ebp)
801020ea:	e8 8a 38 00 00       	call   80105979 <wakeup>
801020ef:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020f2:	83 ec 0c             	sub    $0xc,%esp
801020f5:	68 60 24 11 80       	push   $0x80112460
801020fa:	e8 ef 3a 00 00       	call   80105bee <release>
801020ff:	83 c4 10             	add    $0x10,%esp
}
80102102:	90                   	nop
80102103:	c9                   	leave  
80102104:	c3                   	ret    

80102105 <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
80102105:	55                   	push   %ebp
80102106:	89 e5                	mov    %esp,%ebp
80102108:	83 ec 08             	sub    $0x8,%esp
    // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
8010210b:	83 ec 0c             	sub    $0xc,%esp
8010210e:	68 60 24 11 80       	push   $0x80112460
80102113:	e8 6f 3a 00 00       	call   80105b87 <acquire>
80102118:	83 c4 10             	add    $0x10,%esp
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
8010211b:	8b 45 08             	mov    0x8(%ebp),%eax
8010211e:	8b 40 08             	mov    0x8(%eax),%eax
80102121:	83 f8 01             	cmp    $0x1,%eax
80102124:	0f 85 a9 00 00 00    	jne    801021d3 <iput+0xce>
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	8b 40 0c             	mov    0xc(%eax),%eax
80102130:	83 e0 02             	and    $0x2,%eax
80102133:	85 c0                	test   %eax,%eax
80102135:	0f 84 98 00 00 00    	je     801021d3 <iput+0xce>
8010213b:	8b 45 08             	mov    0x8(%ebp),%eax
8010213e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102142:	66 85 c0             	test   %ax,%ax
80102145:	0f 85 88 00 00 00    	jne    801021d3 <iput+0xce>
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
8010214b:	8b 45 08             	mov    0x8(%ebp),%eax
8010214e:	8b 40 0c             	mov    0xc(%eax),%eax
80102151:	83 e0 01             	and    $0x1,%eax
80102154:	85 c0                	test   %eax,%eax
80102156:	74 0d                	je     80102165 <iput+0x60>
            panic("iput busy");
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	68 6c 96 10 80       	push   $0x8010966c
80102160:	e8 01 e4 ff ff       	call   80100566 <panic>
        ip->flags |= I_BUSY;
80102165:	8b 45 08             	mov    0x8(%ebp),%eax
80102168:	8b 40 0c             	mov    0xc(%eax),%eax
8010216b:	83 c8 01             	or     $0x1,%eax
8010216e:	89 c2                	mov    %eax,%edx
80102170:	8b 45 08             	mov    0x8(%ebp),%eax
80102173:	89 50 0c             	mov    %edx,0xc(%eax)
        release(&icache.lock);
80102176:	83 ec 0c             	sub    $0xc,%esp
80102179:	68 60 24 11 80       	push   $0x80112460
8010217e:	e8 6b 3a 00 00       	call   80105bee <release>
80102183:	83 c4 10             	add    $0x10,%esp
        itrunc(ip);
80102186:	83 ec 0c             	sub    $0xc,%esp
80102189:	ff 75 08             	pushl  0x8(%ebp)
8010218c:	e8 1c 02 00 00       	call   801023ad <itrunc>
80102191:	83 c4 10             	add    $0x10,%esp
        ip->type = 0;
80102194:	8b 45 08             	mov    0x8(%ebp),%eax
80102197:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
        iupdate(ip);
8010219d:	83 ec 0c             	sub    $0xc,%esp
801021a0:	ff 75 08             	pushl  0x8(%ebp)
801021a3:	e8 ec fa ff ff       	call   80101c94 <iupdate>
801021a8:	83 c4 10             	add    $0x10,%esp
        acquire(&icache.lock);
801021ab:	83 ec 0c             	sub    $0xc,%esp
801021ae:	68 60 24 11 80       	push   $0x80112460
801021b3:	e8 cf 39 00 00       	call   80105b87 <acquire>
801021b8:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801021bb:	8b 45 08             	mov    0x8(%ebp),%eax
801021be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021c5:	83 ec 0c             	sub    $0xc,%esp
801021c8:	ff 75 08             	pushl  0x8(%ebp)
801021cb:	e8 a9 37 00 00       	call   80105979 <wakeup>
801021d0:	83 c4 10             	add    $0x10,%esp
    }
    ip->ref--;
801021d3:	8b 45 08             	mov    0x8(%ebp),%eax
801021d6:	8b 40 08             	mov    0x8(%eax),%eax
801021d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801021dc:	8b 45 08             	mov    0x8(%ebp),%eax
801021df:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
801021e2:	83 ec 0c             	sub    $0xc,%esp
801021e5:	68 60 24 11 80       	push   $0x80112460
801021ea:	e8 ff 39 00 00       	call   80105bee <release>
801021ef:	83 c4 10             	add    $0x10,%esp
}
801021f2:	90                   	nop
801021f3:	c9                   	leave  
801021f4:	c3                   	ret    

801021f5 <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
801021f5:	55                   	push   %ebp
801021f6:	89 e5                	mov    %esp,%ebp
801021f8:	83 ec 08             	sub    $0x8,%esp
    iunlock(ip);
801021fb:	83 ec 0c             	sub    $0xc,%esp
801021fe:	ff 75 08             	pushl  0x8(%ebp)
80102201:	e8 8d fe ff ff       	call   80102093 <iunlock>
80102206:	83 c4 10             	add    $0x10,%esp
    iput(ip);
80102209:	83 ec 0c             	sub    $0xc,%esp
8010220c:	ff 75 08             	pushl  0x8(%ebp)
8010220f:	e8 f1 fe ff ff       	call   80102105 <iput>
80102214:	83 c4 10             	add    $0x10,%esp
}
80102217:	90                   	nop
80102218:	c9                   	leave  
80102219:	c3                   	ret    

8010221a <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
8010221a:	55                   	push   %ebp
8010221b:	89 e5                	mov    %esp,%ebp
8010221d:	53                   	push   %ebx
8010221e:	83 ec 34             	sub    $0x34,%esp
    //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
    struct superblock sb;
    sb = sbs[ip->part->number];
80102221:	8b 45 08             	mov    0x8(%ebp),%eax
80102224:	8b 40 50             	mov    0x50(%eax),%eax
80102227:	8b 40 14             	mov    0x14(%eax),%eax
8010222a:	c1 e0 05             	shl    $0x5,%eax
8010222d:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102232:	8b 10                	mov    (%eax),%edx
80102234:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102237:	8b 50 04             	mov    0x4(%eax),%edx
8010223a:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010223d:	8b 50 08             	mov    0x8(%eax),%edx
80102240:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102243:	8b 50 0c             	mov    0xc(%eax),%edx
80102246:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102249:	8b 50 10             	mov    0x10(%eax),%edx
8010224c:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010224f:	8b 50 14             	mov    0x14(%eax),%edx
80102252:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102255:	8b 50 18             	mov    0x18(%eax),%edx
80102258:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010225b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010225e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (bn < NDIRECT) {
80102261:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102265:	77 4e                	ja     801022b5 <bmap+0x9b>
        if ((addr = ip->addrs[bn]) == 0)
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010226d:	83 c2 04             	add    $0x4,%edx
80102270:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102274:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102277:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010227b:	75 30                	jne    801022ad <bmap+0x93>
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	8b 40 50             	mov    0x50(%eax),%eax
80102283:	8b 40 14             	mov    0x14(%eax),%eax
80102286:	89 c2                	mov    %eax,%edx
80102288:	8b 45 08             	mov    0x8(%ebp),%eax
8010228b:	8b 00                	mov    (%eax),%eax
8010228d:	83 ec 08             	sub    $0x8,%esp
80102290:	52                   	push   %edx
80102291:	50                   	push   %eax
80102292:	e8 ac f2 ff ff       	call   80101543 <balloc>
80102297:	83 c4 10             	add    $0x10,%esp
8010229a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010229d:	8b 45 08             	mov    0x8(%ebp),%eax
801022a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801022a3:	8d 4a 04             	lea    0x4(%edx),%ecx
801022a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022a9:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
        // cprintf("addr %d \n ",addr);
        return addr;
801022ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b0:	e9 f3 00 00 00       	jmp    801023a8 <bmap+0x18e>
    }
    bn -= NDIRECT;
801022b5:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

    if (bn < NINDIRECT) {
801022b9:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801022bd:	0f 87 d8 00 00 00    	ja     8010239b <bmap+0x181>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801022c3:	8b 45 08             	mov    0x8(%ebp),%eax
801022c6:	8b 40 4c             	mov    0x4c(%eax),%eax
801022c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022d0:	75 29                	jne    801022fb <bmap+0xe1>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
801022d2:	8b 45 08             	mov    0x8(%ebp),%eax
801022d5:	8b 40 50             	mov    0x50(%eax),%eax
801022d8:	8b 40 14             	mov    0x14(%eax),%eax
801022db:	89 c2                	mov    %eax,%edx
801022dd:	8b 45 08             	mov    0x8(%ebp),%eax
801022e0:	8b 00                	mov    (%eax),%eax
801022e2:	83 ec 08             	sub    $0x8,%esp
801022e5:	52                   	push   %edx
801022e6:	50                   	push   %eax
801022e7:	e8 57 f2 ff ff       	call   80101543 <balloc>
801022ec:	83 c4 10             	add    $0x10,%esp
801022ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f8:	89 50 4c             	mov    %edx,0x4c(%eax)
        bp = bread(ip->dev, sb.offset + addr);
801022fb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102301:	01 c2                	add    %eax,%edx
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	8b 00                	mov    (%eax),%eax
80102308:	83 ec 08             	sub    $0x8,%esp
8010230b:	52                   	push   %edx
8010230c:	50                   	push   %eax
8010230d:	e8 a4 de ff ff       	call   801001b6 <bread>
80102312:	83 c4 10             	add    $0x10,%esp
80102315:	89 45 f0             	mov    %eax,-0x10(%ebp)
        a = (uint*)bp->data;
80102318:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010231b:	83 c0 18             	add    $0x18,%eax
8010231e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if ((addr = a[bn]) == 0) {
80102321:	8b 45 0c             	mov    0xc(%ebp),%eax
80102324:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010232b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010232e:	01 d0                	add    %edx,%eax
80102330:	8b 00                	mov    (%eax),%eax
80102332:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102335:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102339:	75 4d                	jne    80102388 <bmap+0x16e>
            a[bn] = addr = balloc(ip->dev, ip->part->number);
8010233b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010233e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102345:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102348:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010234b:	8b 45 08             	mov    0x8(%ebp),%eax
8010234e:	8b 40 50             	mov    0x50(%eax),%eax
80102351:	8b 40 14             	mov    0x14(%eax),%eax
80102354:	89 c2                	mov    %eax,%edx
80102356:	8b 45 08             	mov    0x8(%ebp),%eax
80102359:	8b 00                	mov    (%eax),%eax
8010235b:	83 ec 08             	sub    $0x8,%esp
8010235e:	52                   	push   %edx
8010235f:	50                   	push   %eax
80102360:	e8 de f1 ff ff       	call   80101543 <balloc>
80102365:	83 c4 10             	add    $0x10,%esp
80102368:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010236b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236e:	89 03                	mov    %eax,(%ebx)
            log_write(bp, ip->part->number);
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	8b 40 50             	mov    0x50(%eax),%eax
80102376:	8b 40 14             	mov    0x14(%eax),%eax
80102379:	83 ec 08             	sub    $0x8,%esp
8010237c:	50                   	push   %eax
8010237d:	ff 75 f0             	pushl  -0x10(%ebp)
80102380:	e8 d1 1e 00 00       	call   80104256 <log_write>
80102385:	83 c4 10             	add    $0x10,%esp
        }
        brelse(bp);
80102388:	83 ec 0c             	sub    $0xc,%esp
8010238b:	ff 75 f0             	pushl  -0x10(%ebp)
8010238e:	e8 9b de ff ff       	call   8010022e <brelse>
80102393:	83 c4 10             	add    $0x10,%esp
        return addr;
80102396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102399:	eb 0d                	jmp    801023a8 <bmap+0x18e>
    }

    panic("bmap: out of range");
8010239b:	83 ec 0c             	sub    $0xc,%esp
8010239e:	68 76 96 10 80       	push   $0x80109676
801023a3:	e8 be e1 ff ff       	call   80100566 <panic>
}
801023a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801023ab:	c9                   	leave  
801023ac:	c3                   	ret    

801023ad <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
801023ad:	55                   	push   %ebp
801023ae:	89 e5                	mov    %esp,%ebp
801023b0:	83 ec 38             	sub    $0x38,%esp

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb = sbs[ip->part->number];
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	8b 40 50             	mov    0x50(%eax),%eax
801023b9:	8b 40 14             	mov    0x14(%eax),%eax
801023bc:	c1 e0 05             	shl    $0x5,%eax
801023bf:	05 60 d6 10 80       	add    $0x8010d660,%eax
801023c4:	8b 10                	mov    (%eax),%edx
801023c6:	89 55 c8             	mov    %edx,-0x38(%ebp)
801023c9:	8b 50 04             	mov    0x4(%eax),%edx
801023cc:	89 55 cc             	mov    %edx,-0x34(%ebp)
801023cf:	8b 50 08             	mov    0x8(%eax),%edx
801023d2:	89 55 d0             	mov    %edx,-0x30(%ebp)
801023d5:	8b 50 0c             	mov    0xc(%eax),%edx
801023d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801023db:	8b 50 10             	mov    0x10(%eax),%edx
801023de:	89 55 d8             	mov    %edx,-0x28(%ebp)
801023e1:	8b 50 14             	mov    0x14(%eax),%edx
801023e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
801023e7:	8b 50 18             	mov    0x18(%eax),%edx
801023ea:	89 55 e0             	mov    %edx,-0x20(%ebp)
801023ed:	8b 40 1c             	mov    0x1c(%eax),%eax
801023f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < NDIRECT; i++) {
801023f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023fa:	eb 51                	jmp    8010244d <itrunc+0xa0>
        if (ip->addrs[i]) {
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102402:	83 c2 04             	add    $0x4,%edx
80102405:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102409:	85 c0                	test   %eax,%eax
8010240b:	74 3c                	je     80102449 <itrunc+0x9c>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
8010240d:	8b 45 08             	mov    0x8(%ebp),%eax
80102410:	8b 40 50             	mov    0x50(%eax),%eax
80102413:	8b 40 14             	mov    0x14(%eax),%eax
80102416:	89 c1                	mov    %eax,%ecx
80102418:	8b 45 08             	mov    0x8(%ebp),%eax
8010241b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010241e:	83 c2 04             	add    $0x4,%edx
80102421:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102425:	8b 55 08             	mov    0x8(%ebp),%edx
80102428:	8b 12                	mov    (%edx),%edx
8010242a:	83 ec 04             	sub    $0x4,%esp
8010242d:	51                   	push   %ecx
8010242e:	50                   	push   %eax
8010242f:	52                   	push   %edx
80102430:	e8 a1 f2 ff ff       	call   801016d6 <bfree>
80102435:	83 c4 10             	add    $0x10,%esp
            ip->addrs[i] = 0;
80102438:	8b 45 08             	mov    0x8(%ebp),%eax
8010243b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010243e:	83 c2 04             	add    $0x4,%edx
80102441:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80102448:	00 
    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb = sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
80102449:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010244d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102451:	7e a9                	jle    801023fc <itrunc+0x4f>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	8b 40 4c             	mov    0x4c(%eax),%eax
80102459:	85 c0                	test   %eax,%eax
8010245b:	0f 84 be 00 00 00    	je     8010251f <itrunc+0x172>
        bp = bread(ip->dev, sb.offset + ip->addrs[NDIRECT]);
80102461:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102464:	8b 45 08             	mov    0x8(%ebp),%eax
80102467:	8b 40 4c             	mov    0x4c(%eax),%eax
8010246a:	01 c2                	add    %eax,%edx
8010246c:	8b 45 08             	mov    0x8(%ebp),%eax
8010246f:	8b 00                	mov    (%eax),%eax
80102471:	83 ec 08             	sub    $0x8,%esp
80102474:	52                   	push   %edx
80102475:	50                   	push   %eax
80102476:	e8 3b dd ff ff       	call   801001b6 <bread>
8010247b:	83 c4 10             	add    $0x10,%esp
8010247e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        a = (uint*)bp->data;
80102481:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102484:	83 c0 18             	add    $0x18,%eax
80102487:	89 45 e8             	mov    %eax,-0x18(%ebp)
        for (j = 0; j < NINDIRECT; j++) {
8010248a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102491:	eb 48                	jmp    801024db <itrunc+0x12e>
            if (a[j])
80102493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102496:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010249d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024a0:	01 d0                	add    %edx,%eax
801024a2:	8b 00                	mov    (%eax),%eax
801024a4:	85 c0                	test   %eax,%eax
801024a6:	74 2f                	je     801024d7 <itrunc+0x12a>
                bfree(ip->dev, a[j], ip->part->number);
801024a8:	8b 45 08             	mov    0x8(%ebp),%eax
801024ab:	8b 40 50             	mov    0x50(%eax),%eax
801024ae:	8b 40 14             	mov    0x14(%eax),%eax
801024b1:	89 c1                	mov    %eax,%ecx
801024b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801024bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024c0:	01 d0                	add    %edx,%eax
801024c2:	8b 00                	mov    (%eax),%eax
801024c4:	8b 55 08             	mov    0x8(%ebp),%edx
801024c7:	8b 12                	mov    (%edx),%edx
801024c9:	83 ec 04             	sub    $0x4,%esp
801024cc:	51                   	push   %ecx
801024cd:	50                   	push   %eax
801024ce:	52                   	push   %edx
801024cf:	e8 02 f2 ff ff       	call   801016d6 <bfree>
801024d4:	83 c4 10             	add    $0x10,%esp
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset + ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
801024d7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801024db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024de:	83 f8 7f             	cmp    $0x7f,%eax
801024e1:	76 b0                	jbe    80102493 <itrunc+0xe6>
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
801024e3:	83 ec 0c             	sub    $0xc,%esp
801024e6:	ff 75 ec             	pushl  -0x14(%ebp)
801024e9:	e8 40 dd ff ff       	call   8010022e <brelse>
801024ee:	83 c4 10             	add    $0x10,%esp
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
801024f1:	8b 45 08             	mov    0x8(%ebp),%eax
801024f4:	8b 40 50             	mov    0x50(%eax),%eax
801024f7:	8b 40 14             	mov    0x14(%eax),%eax
801024fa:	89 c1                	mov    %eax,%ecx
801024fc:	8b 45 08             	mov    0x8(%ebp),%eax
801024ff:	8b 40 4c             	mov    0x4c(%eax),%eax
80102502:	8b 55 08             	mov    0x8(%ebp),%edx
80102505:	8b 12                	mov    (%edx),%edx
80102507:	83 ec 04             	sub    $0x4,%esp
8010250a:	51                   	push   %ecx
8010250b:	50                   	push   %eax
8010250c:	52                   	push   %edx
8010250d:	e8 c4 f1 ff ff       	call   801016d6 <bfree>
80102512:	83 c4 10             	add    $0x10,%esp
        ip->addrs[NDIRECT] = 0;
80102515:	8b 45 08             	mov    0x8(%ebp),%eax
80102518:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }

    ip->size = 0;
8010251f:	8b 45 08             	mov    0x8(%ebp),%eax
80102522:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    iupdate(ip);
80102529:	83 ec 0c             	sub    $0xc,%esp
8010252c:	ff 75 08             	pushl  0x8(%ebp)
8010252f:	e8 60 f7 ff ff       	call   80101c94 <iupdate>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	90                   	nop
80102538:	c9                   	leave  
80102539:	c3                   	ret    

8010253a <stati>:

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
    st->dev = ip->dev;
8010253d:	8b 45 08             	mov    0x8(%ebp),%eax
80102540:	8b 00                	mov    (%eax),%eax
80102542:	89 c2                	mov    %eax,%edx
80102544:	8b 45 0c             	mov    0xc(%ebp),%eax
80102547:	89 50 04             	mov    %edx,0x4(%eax)
    st->ino = ip->inum;
8010254a:	8b 45 08             	mov    0x8(%ebp),%eax
8010254d:	8b 50 04             	mov    0x4(%eax),%edx
80102550:	8b 45 0c             	mov    0xc(%ebp),%eax
80102553:	89 50 08             	mov    %edx,0x8(%eax)
    st->type = ip->type;
80102556:	8b 45 08             	mov    0x8(%ebp),%eax
80102559:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010255d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102560:	66 89 10             	mov    %dx,(%eax)
    st->nlink = ip->nlink;
80102563:	8b 45 08             	mov    0x8(%ebp),%eax
80102566:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010256a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010256d:	66 89 50 0c          	mov    %dx,0xc(%eax)
    st->size = ip->size;
80102571:	8b 45 08             	mov    0x8(%ebp),%eax
80102574:	8b 50 18             	mov    0x18(%eax),%edx
80102577:	8b 45 0c             	mov    0xc(%ebp),%eax
8010257a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010257d:	90                   	nop
8010257e:	5d                   	pop    %ebp
8010257f:	c3                   	ret    

80102580 <readi>:

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
80102580:	55                   	push   %ebp
80102581:	89 e5                	mov    %esp,%ebp
80102583:	83 ec 38             	sub    $0x38,%esp
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
    //      cprintf("readi \n");
    sb = sbs[ip->part->number];
80102586:	8b 45 08             	mov    0x8(%ebp),%eax
80102589:	8b 40 50             	mov    0x50(%eax),%eax
8010258c:	8b 40 14             	mov    0x14(%eax),%eax
8010258f:	c1 e0 05             	shl    $0x5,%eax
80102592:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102597:	8b 10                	mov    (%eax),%edx
80102599:	89 55 c8             	mov    %edx,-0x38(%ebp)
8010259c:	8b 50 04             	mov    0x4(%eax),%edx
8010259f:	89 55 cc             	mov    %edx,-0x34(%ebp)
801025a2:	8b 50 08             	mov    0x8(%eax),%edx
801025a5:	89 55 d0             	mov    %edx,-0x30(%ebp)
801025a8:	8b 50 0c             	mov    0xc(%eax),%edx
801025ab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801025ae:	8b 50 10             	mov    0x10(%eax),%edx
801025b1:	89 55 d8             	mov    %edx,-0x28(%ebp)
801025b4:	8b 50 14             	mov    0x14(%eax),%edx
801025b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
801025ba:	8b 50 18             	mov    0x18(%eax),%edx
801025bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
801025c0:	8b 40 1c             	mov    0x1c(%eax),%eax
801025c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ip->type == T_DEV) {
801025c6:	8b 45 08             	mov    0x8(%ebp),%eax
801025c9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025cd:	66 83 f8 03          	cmp    $0x3,%ax
801025d1:	75 5c                	jne    8010262f <readi+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801025d3:	8b 45 08             	mov    0x8(%ebp),%eax
801025d6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025da:	66 85 c0             	test   %ax,%ax
801025dd:	78 20                	js     801025ff <readi+0x7f>
801025df:	8b 45 08             	mov    0x8(%ebp),%eax
801025e2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025e6:	66 83 f8 09          	cmp    $0x9,%ax
801025ea:	7f 13                	jg     801025ff <readi+0x7f>
801025ec:	8b 45 08             	mov    0x8(%ebp),%eax
801025ef:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025f3:	98                   	cwtl   
801025f4:	8b 04 c5 e0 23 11 80 	mov    -0x7feedc20(,%eax,8),%eax
801025fb:	85 c0                	test   %eax,%eax
801025fd:	75 0a                	jne    80102609 <readi+0x89>
            return -1;
801025ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102604:	e9 15 01 00 00       	jmp    8010271e <readi+0x19e>
        return devsw[ip->major].read(ip, dst, n);
80102609:	8b 45 08             	mov    0x8(%ebp),%eax
8010260c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102610:	98                   	cwtl   
80102611:	8b 04 c5 e0 23 11 80 	mov    -0x7feedc20(,%eax,8),%eax
80102618:	8b 55 14             	mov    0x14(%ebp),%edx
8010261b:	83 ec 04             	sub    $0x4,%esp
8010261e:	52                   	push   %edx
8010261f:	ff 75 0c             	pushl  0xc(%ebp)
80102622:	ff 75 08             	pushl  0x8(%ebp)
80102625:	ff d0                	call   *%eax
80102627:	83 c4 10             	add    $0x10,%esp
8010262a:	e9 ef 00 00 00       	jmp    8010271e <readi+0x19e>
    }

    if (off > ip->size || off + n < off)
8010262f:	8b 45 08             	mov    0x8(%ebp),%eax
80102632:	8b 40 18             	mov    0x18(%eax),%eax
80102635:	3b 45 10             	cmp    0x10(%ebp),%eax
80102638:	72 0d                	jb     80102647 <readi+0xc7>
8010263a:	8b 55 10             	mov    0x10(%ebp),%edx
8010263d:	8b 45 14             	mov    0x14(%ebp),%eax
80102640:	01 d0                	add    %edx,%eax
80102642:	3b 45 10             	cmp    0x10(%ebp),%eax
80102645:	73 0a                	jae    80102651 <readi+0xd1>
        return -1;
80102647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010264c:	e9 cd 00 00 00       	jmp    8010271e <readi+0x19e>
    if (off + n > ip->size)
80102651:	8b 55 10             	mov    0x10(%ebp),%edx
80102654:	8b 45 14             	mov    0x14(%ebp),%eax
80102657:	01 c2                	add    %eax,%edx
80102659:	8b 45 08             	mov    0x8(%ebp),%eax
8010265c:	8b 40 18             	mov    0x18(%eax),%eax
8010265f:	39 c2                	cmp    %eax,%edx
80102661:	76 0c                	jbe    8010266f <readi+0xef>
        n = ip->size - off;
80102663:	8b 45 08             	mov    0x8(%ebp),%eax
80102666:	8b 40 18             	mov    0x18(%eax),%eax
80102669:	2b 45 10             	sub    0x10(%ebp),%eax
8010266c:	89 45 14             	mov    %eax,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
8010266f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102676:	e9 94 00 00 00       	jmp    8010270f <readi+0x18f>
        uint bmapOut = bmap(ip, off / BSIZE);
8010267b:	8b 45 10             	mov    0x10(%ebp),%eax
8010267e:	c1 e8 09             	shr    $0x9,%eax
80102681:	83 ec 08             	sub    $0x8,%esp
80102684:	50                   	push   %eax
80102685:	ff 75 08             	pushl  0x8(%ebp)
80102688:	e8 8d fb ff ff       	call   8010221a <bmap>
8010268d:	83 c4 10             	add    $0x10,%esp
80102690:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset + bmapOut);
80102693:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102699:	01 c2                	add    %eax,%edx
8010269b:	8b 45 08             	mov    0x8(%ebp),%eax
8010269e:	8b 00                	mov    (%eax),%eax
801026a0:	83 ec 08             	sub    $0x8,%esp
801026a3:	52                   	push   %edx
801026a4:	50                   	push   %eax
801026a5:	e8 0c db ff ff       	call   801001b6 <bread>
801026aa:	83 c4 10             	add    $0x10,%esp
801026ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
801026b0:	8b 45 10             	mov    0x10(%ebp),%eax
801026b3:	25 ff 01 00 00       	and    $0x1ff,%eax
801026b8:	ba 00 02 00 00       	mov    $0x200,%edx
801026bd:	29 c2                	sub    %eax,%edx
801026bf:	8b 45 14             	mov    0x14(%ebp),%eax
801026c2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801026c5:	39 c2                	cmp    %eax,%edx
801026c7:	0f 46 c2             	cmovbe %edx,%eax
801026ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(dst, bp->data + off % BSIZE, m);
801026cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026d0:	8d 50 18             	lea    0x18(%eax),%edx
801026d3:	8b 45 10             	mov    0x10(%ebp),%eax
801026d6:	25 ff 01 00 00       	and    $0x1ff,%eax
801026db:	01 d0                	add    %edx,%eax
801026dd:	83 ec 04             	sub    $0x4,%esp
801026e0:	ff 75 e8             	pushl  -0x18(%ebp)
801026e3:	50                   	push   %eax
801026e4:	ff 75 0c             	pushl  0xc(%ebp)
801026e7:	e8 bd 37 00 00       	call   80105ea9 <memmove>
801026ec:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801026ef:	83 ec 0c             	sub    $0xc,%esp
801026f2:	ff 75 ec             	pushl  -0x14(%ebp)
801026f5:	e8 34 db ff ff       	call   8010022e <brelse>
801026fa:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
801026fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102700:	01 45 f4             	add    %eax,-0xc(%ebp)
80102703:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102706:	01 45 10             	add    %eax,0x10(%ebp)
80102709:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010270c:	01 45 0c             	add    %eax,0xc(%ebp)
8010270f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102712:	3b 45 14             	cmp    0x14(%ebp),%eax
80102715:	0f 82 60 ff ff ff    	jb     8010267b <readi+0xfb>
        bp = bread(ip->dev, sb.offset + bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
8010271b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010271e:	c9                   	leave  
8010271f:	c3                   	ret    

80102720 <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
80102723:	83 ec 38             	sub    $0x38,%esp
    // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
    sb = sbs[ip->part->number];
80102726:	8b 45 08             	mov    0x8(%ebp),%eax
80102729:	8b 40 50             	mov    0x50(%eax),%eax
8010272c:	8b 40 14             	mov    0x14(%eax),%eax
8010272f:	c1 e0 05             	shl    $0x5,%eax
80102732:	05 60 d6 10 80       	add    $0x8010d660,%eax
80102737:	8b 10                	mov    (%eax),%edx
80102739:	89 55 c8             	mov    %edx,-0x38(%ebp)
8010273c:	8b 50 04             	mov    0x4(%eax),%edx
8010273f:	89 55 cc             	mov    %edx,-0x34(%ebp)
80102742:	8b 50 08             	mov    0x8(%eax),%edx
80102745:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102748:	8b 50 0c             	mov    0xc(%eax),%edx
8010274b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010274e:	8b 50 10             	mov    0x10(%eax),%edx
80102751:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102754:	8b 50 14             	mov    0x14(%eax),%edx
80102757:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010275a:	8b 50 18             	mov    0x18(%eax),%edx
8010275d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102760:	8b 40 1c             	mov    0x1c(%eax),%eax
80102763:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (ip->type == T_DEV) {
80102766:	8b 45 08             	mov    0x8(%ebp),%eax
80102769:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010276d:	66 83 f8 03          	cmp    $0x3,%ax
80102771:	75 5c                	jne    801027cf <writei+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010277a:	66 85 c0             	test   %ax,%ax
8010277d:	78 20                	js     8010279f <writei+0x7f>
8010277f:	8b 45 08             	mov    0x8(%ebp),%eax
80102782:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102786:	66 83 f8 09          	cmp    $0x9,%ax
8010278a:	7f 13                	jg     8010279f <writei+0x7f>
8010278c:	8b 45 08             	mov    0x8(%ebp),%eax
8010278f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102793:	98                   	cwtl   
80102794:	8b 04 c5 e4 23 11 80 	mov    -0x7feedc1c(,%eax,8),%eax
8010279b:	85 c0                	test   %eax,%eax
8010279d:	75 0a                	jne    801027a9 <writei+0x89>
            return -1;
8010279f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027a4:	e9 50 01 00 00       	jmp    801028f9 <writei+0x1d9>
        return devsw[ip->major].write(ip, src, n);
801027a9:	8b 45 08             	mov    0x8(%ebp),%eax
801027ac:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027b0:	98                   	cwtl   
801027b1:	8b 04 c5 e4 23 11 80 	mov    -0x7feedc1c(,%eax,8),%eax
801027b8:	8b 55 14             	mov    0x14(%ebp),%edx
801027bb:	83 ec 04             	sub    $0x4,%esp
801027be:	52                   	push   %edx
801027bf:	ff 75 0c             	pushl  0xc(%ebp)
801027c2:	ff 75 08             	pushl  0x8(%ebp)
801027c5:	ff d0                	call   *%eax
801027c7:	83 c4 10             	add    $0x10,%esp
801027ca:	e9 2a 01 00 00       	jmp    801028f9 <writei+0x1d9>
    }

    if (off > ip->size || off + n < off)
801027cf:	8b 45 08             	mov    0x8(%ebp),%eax
801027d2:	8b 40 18             	mov    0x18(%eax),%eax
801027d5:	3b 45 10             	cmp    0x10(%ebp),%eax
801027d8:	72 0d                	jb     801027e7 <writei+0xc7>
801027da:	8b 55 10             	mov    0x10(%ebp),%edx
801027dd:	8b 45 14             	mov    0x14(%ebp),%eax
801027e0:	01 d0                	add    %edx,%eax
801027e2:	3b 45 10             	cmp    0x10(%ebp),%eax
801027e5:	73 0a                	jae    801027f1 <writei+0xd1>
        return -1;
801027e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027ec:	e9 08 01 00 00       	jmp    801028f9 <writei+0x1d9>
    if (off + n > MAXFILE * BSIZE)
801027f1:	8b 55 10             	mov    0x10(%ebp),%edx
801027f4:	8b 45 14             	mov    0x14(%ebp),%eax
801027f7:	01 d0                	add    %edx,%eax
801027f9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801027fe:	76 0a                	jbe    8010280a <writei+0xea>
        return -1;
80102800:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102805:	e9 ef 00 00 00       	jmp    801028f9 <writei+0x1d9>

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
8010280a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102811:	e9 ac 00 00 00       	jmp    801028c2 <writei+0x1a2>
        uint bmapOut = bmap(ip, off / BSIZE);
80102816:	8b 45 10             	mov    0x10(%ebp),%eax
80102819:	c1 e8 09             	shr    $0x9,%eax
8010281c:	83 ec 08             	sub    $0x8,%esp
8010281f:	50                   	push   %eax
80102820:	ff 75 08             	pushl  0x8(%ebp)
80102823:	e8 f2 f9 ff ff       	call   8010221a <bmap>
80102828:	83 c4 10             	add    $0x10,%esp
8010282b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        bp = bread(ip->dev, sb.offset + bmapOut);
8010282e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102831:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102834:	01 c2                	add    %eax,%edx
80102836:	8b 45 08             	mov    0x8(%ebp),%eax
80102839:	8b 00                	mov    (%eax),%eax
8010283b:	83 ec 08             	sub    $0x8,%esp
8010283e:	52                   	push   %edx
8010283f:	50                   	push   %eax
80102840:	e8 71 d9 ff ff       	call   801001b6 <bread>
80102845:	83 c4 10             	add    $0x10,%esp
80102848:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
8010284b:	8b 45 10             	mov    0x10(%ebp),%eax
8010284e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102853:	ba 00 02 00 00       	mov    $0x200,%edx
80102858:	29 c2                	sub    %eax,%edx
8010285a:	8b 45 14             	mov    0x14(%ebp),%eax
8010285d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102860:	39 c2                	cmp    %eax,%edx
80102862:	0f 46 c2             	cmovbe %edx,%eax
80102865:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(bp->data + off % BSIZE, src, m);
80102868:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010286b:	8d 50 18             	lea    0x18(%eax),%edx
8010286e:	8b 45 10             	mov    0x10(%ebp),%eax
80102871:	25 ff 01 00 00       	and    $0x1ff,%eax
80102876:	01 d0                	add    %edx,%eax
80102878:	83 ec 04             	sub    $0x4,%esp
8010287b:	ff 75 e8             	pushl  -0x18(%ebp)
8010287e:	ff 75 0c             	pushl  0xc(%ebp)
80102881:	50                   	push   %eax
80102882:	e8 22 36 00 00       	call   80105ea9 <memmove>
80102887:	83 c4 10             	add    $0x10,%esp
        log_write(bp, ip->part->number);
8010288a:	8b 45 08             	mov    0x8(%ebp),%eax
8010288d:	8b 40 50             	mov    0x50(%eax),%eax
80102890:	8b 40 14             	mov    0x14(%eax),%eax
80102893:	83 ec 08             	sub    $0x8,%esp
80102896:	50                   	push   %eax
80102897:	ff 75 ec             	pushl  -0x14(%ebp)
8010289a:	e8 b7 19 00 00       	call   80104256 <log_write>
8010289f:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801028a2:	83 ec 0c             	sub    $0xc,%esp
801028a5:	ff 75 ec             	pushl  -0x14(%ebp)
801028a8:	e8 81 d9 ff ff       	call   8010022e <brelse>
801028ad:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801028b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028b3:	01 45 f4             	add    %eax,-0xc(%ebp)
801028b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028b9:	01 45 10             	add    %eax,0x10(%ebp)
801028bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028bf:	01 45 0c             	add    %eax,0xc(%ebp)
801028c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c5:	3b 45 14             	cmp    0x14(%ebp),%eax
801028c8:	0f 82 48 ff ff ff    	jb     80102816 <writei+0xf6>
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp, ip->part->number);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
801028ce:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801028d2:	74 22                	je     801028f6 <writei+0x1d6>
801028d4:	8b 45 08             	mov    0x8(%ebp),%eax
801028d7:	8b 40 18             	mov    0x18(%eax),%eax
801028da:	3b 45 10             	cmp    0x10(%ebp),%eax
801028dd:	73 17                	jae    801028f6 <writei+0x1d6>
        ip->size = off;
801028df:	8b 45 08             	mov    0x8(%ebp),%eax
801028e2:	8b 55 10             	mov    0x10(%ebp),%edx
801028e5:	89 50 18             	mov    %edx,0x18(%eax)
        iupdate(ip);
801028e8:	83 ec 0c             	sub    $0xc,%esp
801028eb:	ff 75 08             	pushl  0x8(%ebp)
801028ee:	e8 a1 f3 ff ff       	call   80101c94 <iupdate>
801028f3:	83 c4 10             	add    $0x10,%esp
    }
    return n;
801028f6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801028f9:	c9                   	leave  
801028fa:	c3                   	ret    

801028fb <namecmp>:

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
801028fb:	55                   	push   %ebp
801028fc:	89 e5                	mov    %esp,%ebp
801028fe:	83 ec 08             	sub    $0x8,%esp
    return strncmp(s, t, DIRSIZ);
80102901:	83 ec 04             	sub    $0x4,%esp
80102904:	6a 0e                	push   $0xe
80102906:	ff 75 0c             	pushl  0xc(%ebp)
80102909:	ff 75 08             	pushl  0x8(%ebp)
8010290c:	e8 2e 36 00 00       	call   80105f3f <strncmp>
80102911:	83 c4 10             	add    $0x10,%esp
}
80102914:	c9                   	leave  
80102915:	c3                   	ret    

80102916 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
80102916:	55                   	push   %ebp
80102917:	89 e5                	mov    %esp,%ebp
80102919:	83 ec 28             	sub    $0x28,%esp

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
8010291c:	8b 45 08             	mov    0x8(%ebp),%eax
8010291f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102923:	66 83 f8 01          	cmp    $0x1,%ax
80102927:	74 0d                	je     80102936 <dirlookup+0x20>
        panic("dirlookup not DIR");
80102929:	83 ec 0c             	sub    $0xc,%esp
8010292c:	68 89 96 10 80       	push   $0x80109689
80102931:	e8 30 dc ff ff       	call   80100566 <panic>

    for (off = 0; off < dp->size; off += sizeof(de)) {
80102936:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010293d:	e9 85 00 00 00       	jmp    801029c7 <dirlookup+0xb1>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102942:	6a 10                	push   $0x10
80102944:	ff 75 f4             	pushl  -0xc(%ebp)
80102947:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010294a:	50                   	push   %eax
8010294b:	ff 75 08             	pushl  0x8(%ebp)
8010294e:	e8 2d fc ff ff       	call   80102580 <readi>
80102953:	83 c4 10             	add    $0x10,%esp
80102956:	83 f8 10             	cmp    $0x10,%eax
80102959:	74 0d                	je     80102968 <dirlookup+0x52>
            panic("dirlink read");
8010295b:	83 ec 0c             	sub    $0xc,%esp
8010295e:	68 9b 96 10 80       	push   $0x8010969b
80102963:	e8 fe db ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102968:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010296c:	66 85 c0             	test   %ax,%ax
8010296f:	74 51                	je     801029c2 <dirlookup+0xac>
            continue;
        if (namecmp(name, de.name) == 0) {
80102971:	83 ec 08             	sub    $0x8,%esp
80102974:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102977:	83 c0 02             	add    $0x2,%eax
8010297a:	50                   	push   %eax
8010297b:	ff 75 0c             	pushl  0xc(%ebp)
8010297e:	e8 78 ff ff ff       	call   801028fb <namecmp>
80102983:	83 c4 10             	add    $0x10,%esp
80102986:	85 c0                	test   %eax,%eax
80102988:	75 39                	jne    801029c3 <dirlookup+0xad>
            // entry matches path element
            if (poff)
8010298a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010298e:	74 08                	je     80102998 <dirlookup+0x82>
                *poff = off;
80102990:	8b 45 10             	mov    0x10(%ebp),%eax
80102993:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102996:	89 10                	mov    %edx,(%eax)
            inum = de.inum;
80102998:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010299c:	0f b7 c0             	movzwl %ax,%eax
8010299f:	89 45 f0             	mov    %eax,-0x10(%ebp)
            return iget(dp->dev, inum, dp->part->number);
801029a2:	8b 45 08             	mov    0x8(%ebp),%eax
801029a5:	8b 40 50             	mov    0x50(%eax),%eax
801029a8:	8b 50 14             	mov    0x14(%eax),%edx
801029ab:	8b 45 08             	mov    0x8(%ebp),%eax
801029ae:	8b 00                	mov    (%eax),%eax
801029b0:	83 ec 04             	sub    $0x4,%esp
801029b3:	52                   	push   %edx
801029b4:	ff 75 f0             	pushl  -0x10(%ebp)
801029b7:	50                   	push   %eax
801029b8:	e8 e5 f3 ff ff       	call   80101da2 <iget>
801029bd:	83 c4 10             	add    $0x10,%esp
801029c0:	eb 19                	jmp    801029db <dirlookup+0xc5>

    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            continue;
801029c2:	90                   	nop
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801029c3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801029c7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ca:	8b 40 18             	mov    0x18(%eax),%eax
801029cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801029d0:	0f 87 6c ff ff ff    	ja     80102942 <dirlookup+0x2c>
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
801029d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029db:	c9                   	leave  
801029dc:	c3                   	ret    

801029dd <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
801029dd:	55                   	push   %ebp
801029de:	89 e5                	mov    %esp,%ebp
801029e0:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
801029e3:	83 ec 04             	sub    $0x4,%esp
801029e6:	6a 00                	push   $0x0
801029e8:	ff 75 0c             	pushl  0xc(%ebp)
801029eb:	ff 75 08             	pushl  0x8(%ebp)
801029ee:	e8 23 ff ff ff       	call   80102916 <dirlookup>
801029f3:	83 c4 10             	add    $0x10,%esp
801029f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801029f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801029fd:	74 18                	je     80102a17 <dirlink+0x3a>
        iput(ip);
801029ff:	83 ec 0c             	sub    $0xc,%esp
80102a02:	ff 75 f0             	pushl  -0x10(%ebp)
80102a05:	e8 fb f6 ff ff       	call   80102105 <iput>
80102a0a:	83 c4 10             	add    $0x10,%esp
        return -1;
80102a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a12:	e9 9c 00 00 00       	jmp    80102ab3 <dirlink+0xd6>
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a1e:	eb 39                	jmp    80102a59 <dirlink+0x7c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a23:	6a 10                	push   $0x10
80102a25:	50                   	push   %eax
80102a26:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a29:	50                   	push   %eax
80102a2a:	ff 75 08             	pushl  0x8(%ebp)
80102a2d:	e8 4e fb ff ff       	call   80102580 <readi>
80102a32:	83 c4 10             	add    $0x10,%esp
80102a35:	83 f8 10             	cmp    $0x10,%eax
80102a38:	74 0d                	je     80102a47 <dirlink+0x6a>
            panic("dirlink read");
80102a3a:	83 ec 0c             	sub    $0xc,%esp
80102a3d:	68 9b 96 10 80       	push   $0x8010969b
80102a42:	e8 1f db ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102a47:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102a4b:	66 85 c0             	test   %ax,%ax
80102a4e:	74 18                	je     80102a68 <dirlink+0x8b>
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a53:	83 c0 10             	add    $0x10,%eax
80102a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a59:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5c:	8b 50 18             	mov    0x18(%eax),%edx
80102a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a62:	39 c2                	cmp    %eax,%edx
80102a64:	77 ba                	ja     80102a20 <dirlink+0x43>
80102a66:	eb 01                	jmp    80102a69 <dirlink+0x8c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            break;
80102a68:	90                   	nop
    }

    strncpy(de.name, name, DIRSIZ);
80102a69:	83 ec 04             	sub    $0x4,%esp
80102a6c:	6a 0e                	push   $0xe
80102a6e:	ff 75 0c             	pushl  0xc(%ebp)
80102a71:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a74:	83 c0 02             	add    $0x2,%eax
80102a77:	50                   	push   %eax
80102a78:	e8 18 35 00 00       	call   80105f95 <strncpy>
80102a7d:	83 c4 10             	add    $0x10,%esp
    de.inum = inum;
80102a80:	8b 45 10             	mov    0x10(%ebp),%eax
80102a83:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8a:	6a 10                	push   $0x10
80102a8c:	50                   	push   %eax
80102a8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a90:	50                   	push   %eax
80102a91:	ff 75 08             	pushl  0x8(%ebp)
80102a94:	e8 87 fc ff ff       	call   80102720 <writei>
80102a99:	83 c4 10             	add    $0x10,%esp
80102a9c:	83 f8 10             	cmp    $0x10,%eax
80102a9f:	74 0d                	je     80102aae <dirlink+0xd1>
        panic("dirlink");
80102aa1:	83 ec 0c             	sub    $0xc,%esp
80102aa4:	68 a8 96 10 80       	push   $0x801096a8
80102aa9:	e8 b8 da ff ff       	call   80100566 <panic>

    return 0;
80102aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ab3:	c9                   	leave  
80102ab4:	c3                   	ret    

80102ab5 <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
80102ab5:	55                   	push   %ebp
80102ab6:	89 e5                	mov    %esp,%ebp
80102ab8:	83 ec 18             	sub    $0x18,%esp

    char* s;
    int len;

    while (*path == '/')
80102abb:	eb 04                	jmp    80102ac1 <skipelem+0xc>
        path++;
80102abd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{

    char* s;
    int len;

    while (*path == '/')
80102ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac4:	0f b6 00             	movzbl (%eax),%eax
80102ac7:	3c 2f                	cmp    $0x2f,%al
80102ac9:	74 f2                	je     80102abd <skipelem+0x8>
        path++;
    if (*path == 0)
80102acb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ace:	0f b6 00             	movzbl (%eax),%eax
80102ad1:	84 c0                	test   %al,%al
80102ad3:	75 07                	jne    80102adc <skipelem+0x27>
        return 0;
80102ad5:	b8 00 00 00 00       	mov    $0x0,%eax
80102ada:	eb 7b                	jmp    80102b57 <skipelem+0xa2>
    s = path;
80102adc:	8b 45 08             	mov    0x8(%ebp),%eax
80102adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (*path != '/' && *path != 0)
80102ae2:	eb 04                	jmp    80102ae8 <skipelem+0x33>
        path++;
80102ae4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
80102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80102aeb:	0f b6 00             	movzbl (%eax),%eax
80102aee:	3c 2f                	cmp    $0x2f,%al
80102af0:	74 0a                	je     80102afc <skipelem+0x47>
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	0f b6 00             	movzbl (%eax),%eax
80102af8:	84 c0                	test   %al,%al
80102afa:	75 e8                	jne    80102ae4 <skipelem+0x2f>
        path++;
    len = path - s;
80102afc:	8b 55 08             	mov    0x8(%ebp),%edx
80102aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b02:	29 c2                	sub    %eax,%edx
80102b04:	89 d0                	mov    %edx,%eax
80102b06:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (len >= DIRSIZ)
80102b09:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102b0d:	7e 15                	jle    80102b24 <skipelem+0x6f>
        memmove(name, s, DIRSIZ);
80102b0f:	83 ec 04             	sub    $0x4,%esp
80102b12:	6a 0e                	push   $0xe
80102b14:	ff 75 f4             	pushl  -0xc(%ebp)
80102b17:	ff 75 0c             	pushl  0xc(%ebp)
80102b1a:	e8 8a 33 00 00       	call   80105ea9 <memmove>
80102b1f:	83 c4 10             	add    $0x10,%esp
80102b22:	eb 26                	jmp    80102b4a <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b27:	83 ec 04             	sub    $0x4,%esp
80102b2a:	50                   	push   %eax
80102b2b:	ff 75 f4             	pushl  -0xc(%ebp)
80102b2e:	ff 75 0c             	pushl  0xc(%ebp)
80102b31:	e8 73 33 00 00       	call   80105ea9 <memmove>
80102b36:	83 c4 10             	add    $0x10,%esp
        name[len] = 0;
80102b39:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b3f:	01 d0                	add    %edx,%eax
80102b41:	c6 00 00             	movb   $0x0,(%eax)
    }
    while (*path == '/')
80102b44:	eb 04                	jmp    80102b4a <skipelem+0x95>
        path++;
80102b46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4d:	0f b6 00             	movzbl (%eax),%eax
80102b50:	3c 2f                	cmp    $0x2f,%al
80102b52:	74 f2                	je     80102b46 <skipelem+0x91>
        path++;
    return path;
80102b54:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102b57:	c9                   	leave  
80102b58:	c3                   	ret    

80102b59 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, int ignoreMounts, char* name)
{
80102b59:	55                   	push   %ebp
80102b5a:	89 e5                	mov    %esp,%ebp
80102b5c:	83 ec 18             	sub    $0x18,%esp
    // cprintf("namex \n");

    struct inode* ip, *next;
    // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
80102b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b62:	0f b6 00             	movzbl (%eax),%eax
80102b65:	3c 2f                	cmp    $0x2f,%al
80102b67:	75 1d                	jne    80102b86 <namex+0x2d>
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
80102b69:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80102b6e:	83 ec 04             	sub    $0x4,%esp
80102b71:	50                   	push   %eax
80102b72:	6a 01                	push   $0x1
80102b74:	6a 00                	push   $0x0
80102b76:	e8 27 f2 ff ff       	call   80101da2 <iget>
80102b7b:	83 c4 10             	add    $0x10,%esp
80102b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b81:	e9 47 01 00 00       	jmp    80102ccd <namex+0x174>
    else
        ip = idup(proc->cwd);
80102b86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102b8c:	8b 40 68             	mov    0x68(%eax),%eax
80102b8f:	83 ec 0c             	sub    $0xc,%esp
80102b92:	50                   	push   %eax
80102b93:	e8 20 f3 ff ff       	call   80101eb8 <idup>
80102b98:	83 c4 10             	add    $0x10,%esp
80102b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while ((path = skipelem(path, name)) != 0) {
80102b9e:	e9 2a 01 00 00       	jmp    80102ccd <namex+0x174>
//cprintf("namex path %s \n",path);
        ilock(ip);
80102ba3:	83 ec 0c             	sub    $0xc,%esp
80102ba6:	ff 75 f4             	pushl  -0xc(%ebp)
80102ba9:	e8 44 f3 ff ff       	call   80101ef2 <ilock>
80102bae:	83 c4 10             	add    $0x10,%esp
        if (ip->type != T_DIR) {
80102bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102bb8:	66 83 f8 01          	cmp    $0x1,%ax
80102bbc:	74 18                	je     80102bd6 <namex+0x7d>
            iunlockput(ip);
80102bbe:	83 ec 0c             	sub    $0xc,%esp
80102bc1:	ff 75 f4             	pushl  -0xc(%ebp)
80102bc4:	e8 2c f6 ff ff       	call   801021f5 <iunlockput>
80102bc9:	83 c4 10             	add    $0x10,%esp
            return 0;
80102bcc:	b8 00 00 00 00       	mov    $0x0,%eax
80102bd1:	e9 33 01 00 00       	jmp    80102d09 <namex+0x1b0>
        }
        if (nameiparent && *path == '\0') {
80102bd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bda:	74 20                	je     80102bfc <namex+0xa3>
80102bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdf:	0f b6 00             	movzbl (%eax),%eax
80102be2:	84 c0                	test   %al,%al
80102be4:	75 16                	jne    80102bfc <namex+0xa3>
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
80102be6:	83 ec 0c             	sub    $0xc,%esp
80102be9:	ff 75 f4             	pushl  -0xc(%ebp)
80102bec:	e8 a2 f4 ff ff       	call   80102093 <iunlock>
80102bf1:	83 c4 10             	add    $0x10,%esp
            return ip;
80102bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bf7:	e9 0d 01 00 00       	jmp    80102d09 <namex+0x1b0>
        }

        if ((next = dirlookup(ip, name, 0)) == 0) {
80102bfc:	83 ec 04             	sub    $0x4,%esp
80102bff:	6a 00                	push   $0x0
80102c01:	ff 75 14             	pushl  0x14(%ebp)
80102c04:	ff 75 f4             	pushl  -0xc(%ebp)
80102c07:	e8 0a fd ff ff       	call   80102916 <dirlookup>
80102c0c:	83 c4 10             	add    $0x10,%esp
80102c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102c16:	75 18                	jne    80102c30 <namex+0xd7>
           // cprintf("next is zero \n");
            iunlockput(ip);
80102c18:	83 ec 0c             	sub    $0xc,%esp
80102c1b:	ff 75 f4             	pushl  -0xc(%ebp)
80102c1e:	e8 d2 f5 ff ff       	call   801021f5 <iunlockput>
80102c23:	83 c4 10             	add    $0x10,%esp
            return 0;
80102c26:	b8 00 00 00 00       	mov    $0x0,%eax
80102c2b:	e9 d9 00 00 00       	jmp    80102d09 <namex+0x1b0>
        }
        iunlockput(ip);
80102c30:	83 ec 0c             	sub    $0xc,%esp
80102c33:	ff 75 f4             	pushl  -0xc(%ebp)
80102c36:	e8 ba f5 ff ff       	call   801021f5 <iunlockput>
80102c3b:	83 c4 10             	add    $0x10,%esp
        ilock(next);
80102c3e:	83 ec 0c             	sub    $0xc,%esp
80102c41:	ff 75 f0             	pushl  -0x10(%ebp)
80102c44:	e8 a9 f2 ff ff       	call   80101ef2 <ilock>
80102c49:	83 c4 10             	add    $0x10,%esp
       //  cprintf("next %d , type %d major %d minor %d \n",next->inum,next->type,next->major,next->minor);
        if (!ignoreMounts && next->type == T_DIR && next->major != 0 && next->major != MOUNTING_POINT) {
80102c4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c50:	75 17                	jne    80102c69 <namex+0x110>
80102c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c55:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c59:	66 83 f8 01          	cmp    $0x1,%ax
80102c5d:	75 0a                	jne    80102c69 <namex+0x110>
80102c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c62:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c66:	66 85 c0             	test   %ax,%ax
         //   cprintf("major used ,we are fucked \n");
        }
        // handle mounting points

        if (!ignoreMounts  && next->type == T_DIR && next->major == MOUNTING_POINT) {
80102c69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c6d:	75 4a                	jne    80102cb9 <namex+0x160>
80102c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c72:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c76:	66 83 f8 01          	cmp    $0x1,%ax
80102c7a:	75 3d                	jne    80102cb9 <namex+0x160>
80102c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c7f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c83:	66 83 f8 01          	cmp    $0x1,%ax
80102c87:	75 30                	jne    80102cb9 <namex+0x160>
           // cprintf("got into condition \n");
                        iunlock(next);
80102c89:	83 ec 0c             	sub    $0xc,%esp
80102c8c:	ff 75 f0             	pushl  -0x10(%ebp)
80102c8f:	e8 ff f3 ff ff       	call   80102093 <iunlock>
80102c94:	83 c4 10             	add    $0x10,%esp

            // iunlockput(ip);
            uint partitionNumnber = next->minor;
80102c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c9a:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80102c9e:	98                   	cwtl   
80102c9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
            ip = iget(ROOTDEV, 1, partitionNumnber);
80102ca2:	83 ec 04             	sub    $0x4,%esp
80102ca5:	ff 75 ec             	pushl  -0x14(%ebp)
80102ca8:	6a 01                	push   $0x1
80102caa:	6a 00                	push   $0x0
80102cac:	e8 f1 f0 ff ff       	call   80101da2 <iget>
80102cb1:	83 c4 10             	add    $0x10,%esp
80102cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (!ignoreMounts && next->type == T_DIR && next->major != 0 && next->major != MOUNTING_POINT) {
         //   cprintf("major used ,we are fucked \n");
        }
        // handle mounting points

        if (!ignoreMounts  && next->type == T_DIR && next->major == MOUNTING_POINT) {
80102cb7:	eb 14                	jmp    80102ccd <namex+0x174>
            // iunlockput(ip);
            uint partitionNumnber = next->minor;
            ip = iget(ROOTDEV, 1, partitionNumnber);
        }
        else{
            iunlock(next);
80102cb9:	83 ec 0c             	sub    $0xc,%esp
80102cbc:	ff 75 f0             	pushl  -0x10(%ebp)
80102cbf:	e8 cf f3 ff ff       	call   80102093 <iunlock>
80102cc4:	83 c4 10             	add    $0x10,%esp

        // testing

        ip = next;
80102cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102ccd:	83 ec 08             	sub    $0x8,%esp
80102cd0:	ff 75 14             	pushl  0x14(%ebp)
80102cd3:	ff 75 08             	pushl  0x8(%ebp)
80102cd6:	e8 da fd ff ff       	call   80102ab5 <skipelem>
80102cdb:	83 c4 10             	add    $0x10,%esp
80102cde:	89 45 08             	mov    %eax,0x8(%ebp)
80102ce1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ce5:	0f 85 b8 fe ff ff    	jne    80102ba3 <namex+0x4a>

        ip = next;
    }
        }
       
    if (nameiparent) {
80102ceb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102cef:	74 15                	je     80102d06 <namex+0x1ad>
        iput(ip);
80102cf1:	83 ec 0c             	sub    $0xc,%esp
80102cf4:	ff 75 f4             	pushl  -0xc(%ebp)
80102cf7:	e8 09 f4 ff ff       	call   80102105 <iput>
80102cfc:	83 c4 10             	add    $0x10,%esp
        return 0;
80102cff:	b8 00 00 00 00       	mov    $0x0,%eax
80102d04:	eb 03                	jmp    80102d09 <namex+0x1b0>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d09:	c9                   	leave  
80102d0a:	c3                   	ret    

80102d0b <namei>:

struct inode* namei(char* path)
{
80102d0b:	55                   	push   %ebp
80102d0c:	89 e5                	mov    %esp,%ebp
80102d0e:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 0, name);
80102d11:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d14:	50                   	push   %eax
80102d15:	6a 00                	push   $0x0
80102d17:	6a 00                	push   $0x0
80102d19:	ff 75 08             	pushl  0x8(%ebp)
80102d1c:	e8 38 fe ff ff       	call   80102b59 <namex>
80102d21:	83 c4 10             	add    $0x10,%esp
}
80102d24:	c9                   	leave  
80102d25:	c3                   	ret    

80102d26 <nameiIgnoreMounts>:

struct inode* nameiIgnoreMounts(char* path)
{
80102d26:	55                   	push   %ebp
80102d27:	89 e5                	mov    %esp,%ebp
80102d29:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 1, name);
80102d2c:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d2f:	50                   	push   %eax
80102d30:	6a 01                	push   $0x1
80102d32:	6a 00                	push   $0x0
80102d34:	ff 75 08             	pushl  0x8(%ebp)
80102d37:	e8 1d fe ff ff       	call   80102b59 <namex>
80102d3c:	83 c4 10             	add    $0x10,%esp
}
80102d3f:	c9                   	leave  
80102d40:	c3                   	ret    

80102d41 <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102d41:	55                   	push   %ebp
80102d42:	89 e5                	mov    %esp,%ebp
80102d44:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, 0, name);
80102d47:	ff 75 0c             	pushl  0xc(%ebp)
80102d4a:	6a 00                	push   $0x0
80102d4c:	6a 01                	push   $0x1
80102d4e:	ff 75 08             	pushl  0x8(%ebp)
80102d51:	e8 03 fe ff ff       	call   80102b59 <namex>
80102d56:	83 c4 10             	add    $0x10,%esp
}
80102d59:	c9                   	leave  
80102d5a:	c3                   	ret    

80102d5b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d5b:	55                   	push   %ebp
80102d5c:	89 e5                	mov    %esp,%ebp
80102d5e:	83 ec 14             	sub    $0x14,%esp
80102d61:	8b 45 08             	mov    0x8(%ebp),%eax
80102d64:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d68:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d6c:	89 c2                	mov    %eax,%edx
80102d6e:	ec                   	in     (%dx),%al
80102d6f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d72:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d76:	c9                   	leave  
80102d77:	c3                   	ret    

80102d78 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d78:	55                   	push   %ebp
80102d79:	89 e5                	mov    %esp,%ebp
80102d7b:	57                   	push   %edi
80102d7c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d83:	8b 45 10             	mov    0x10(%ebp),%eax
80102d86:	89 cb                	mov    %ecx,%ebx
80102d88:	89 df                	mov    %ebx,%edi
80102d8a:	89 c1                	mov    %eax,%ecx
80102d8c:	fc                   	cld    
80102d8d:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d8f:	89 c8                	mov    %ecx,%eax
80102d91:	89 fb                	mov    %edi,%ebx
80102d93:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d96:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d99:	90                   	nop
80102d9a:	5b                   	pop    %ebx
80102d9b:	5f                   	pop    %edi
80102d9c:	5d                   	pop    %ebp
80102d9d:	c3                   	ret    

80102d9e <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d9e:	55                   	push   %ebp
80102d9f:	89 e5                	mov    %esp,%ebp
80102da1:	83 ec 08             	sub    $0x8,%esp
80102da4:	8b 55 08             	mov    0x8(%ebp),%edx
80102da7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102daa:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102dae:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102db1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102db5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102db9:	ee                   	out    %al,(%dx)
}
80102dba:	90                   	nop
80102dbb:	c9                   	leave  
80102dbc:	c3                   	ret    

80102dbd <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102dbd:	55                   	push   %ebp
80102dbe:	89 e5                	mov    %esp,%ebp
80102dc0:	56                   	push   %esi
80102dc1:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102dc2:	8b 55 08             	mov    0x8(%ebp),%edx
80102dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102dc8:	8b 45 10             	mov    0x10(%ebp),%eax
80102dcb:	89 cb                	mov    %ecx,%ebx
80102dcd:	89 de                	mov    %ebx,%esi
80102dcf:	89 c1                	mov    %eax,%ecx
80102dd1:	fc                   	cld    
80102dd2:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102dd4:	89 c8                	mov    %ecx,%eax
80102dd6:	89 f3                	mov    %esi,%ebx
80102dd8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102ddb:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102dde:	90                   	nop
80102ddf:	5b                   	pop    %ebx
80102de0:	5e                   	pop    %esi
80102de1:	5d                   	pop    %ebp
80102de2:	c3                   	ret    

80102de3 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102de3:	55                   	push   %ebp
80102de4:	89 e5                	mov    %esp,%ebp
80102de6:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102de9:	90                   	nop
80102dea:	68 f7 01 00 00       	push   $0x1f7
80102def:	e8 67 ff ff ff       	call   80102d5b <inb>
80102df4:	83 c4 04             	add    $0x4,%esp
80102df7:	0f b6 c0             	movzbl %al,%eax
80102dfa:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102dfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e00:	25 c0 00 00 00       	and    $0xc0,%eax
80102e05:	83 f8 40             	cmp    $0x40,%eax
80102e08:	75 e0                	jne    80102dea <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102e0a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e0e:	74 11                	je     80102e21 <idewait+0x3e>
80102e10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e13:	83 e0 21             	and    $0x21,%eax
80102e16:	85 c0                	test   %eax,%eax
80102e18:	74 07                	je     80102e21 <idewait+0x3e>
    return -1;
80102e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e1f:	eb 05                	jmp    80102e26 <idewait+0x43>
  return 0;
80102e21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e26:	c9                   	leave  
80102e27:	c3                   	ret    

80102e28 <ideinit>:

void
ideinit(void)
{
80102e28:	55                   	push   %ebp
80102e29:	89 e5                	mov    %esp,%ebp
80102e2b:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102e2e:	83 ec 08             	sub    $0x8,%esp
80102e31:	68 ba 96 10 80       	push   $0x801096ba
80102e36:	68 00 c6 10 80       	push   $0x8010c600
80102e3b:	e8 25 2d 00 00       	call   80105b65 <initlock>
80102e40:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e43:	83 ec 0c             	sub    $0xc,%esp
80102e46:	6a 0e                	push   $0xe
80102e48:	e8 16 1c 00 00       	call   80104a63 <picenable>
80102e4d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e50:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102e55:	83 e8 01             	sub    $0x1,%eax
80102e58:	83 ec 08             	sub    $0x8,%esp
80102e5b:	50                   	push   %eax
80102e5c:	6a 0e                	push   $0xe
80102e5e:	e8 83 04 00 00       	call   801032e6 <ioapicenable>
80102e63:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102e66:	83 ec 0c             	sub    $0xc,%esp
80102e69:	6a 00                	push   $0x0
80102e6b:	e8 73 ff ff ff       	call   80102de3 <idewait>
80102e70:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e73:	83 ec 08             	sub    $0x8,%esp
80102e76:	68 f0 00 00 00       	push   $0xf0
80102e7b:	68 f6 01 00 00       	push   $0x1f6
80102e80:	e8 19 ff ff ff       	call   80102d9e <outb>
80102e85:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102e88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e8f:	eb 24                	jmp    80102eb5 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102e91:	83 ec 0c             	sub    $0xc,%esp
80102e94:	68 f7 01 00 00       	push   $0x1f7
80102e99:	e8 bd fe ff ff       	call   80102d5b <inb>
80102e9e:	83 c4 10             	add    $0x10,%esp
80102ea1:	84 c0                	test   %al,%al
80102ea3:	74 0c                	je     80102eb1 <ideinit+0x89>
      havedisk1 = 1;
80102ea5:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102eac:	00 00 00 
      break;
80102eaf:	eb 0d                	jmp    80102ebe <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102eb1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102eb5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102ebc:	7e d3                	jle    80102e91 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102ebe:	83 ec 08             	sub    $0x8,%esp
80102ec1:	68 e0 00 00 00       	push   $0xe0
80102ec6:	68 f6 01 00 00       	push   $0x1f6
80102ecb:	e8 ce fe ff ff       	call   80102d9e <outb>
80102ed0:	83 c4 10             	add    $0x10,%esp
}
80102ed3:	90                   	nop
80102ed4:	c9                   	leave  
80102ed5:	c3                   	ret    

80102ed6 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102ed6:	55                   	push   %ebp
80102ed7:	89 e5                	mov    %esp,%ebp
80102ed9:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102edc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ee0:	75 0d                	jne    80102eef <idestart+0x19>
    panic("idestart");
80102ee2:	83 ec 0c             	sub    $0xc,%esp
80102ee5:	68 be 96 10 80       	push   $0x801096be
80102eea:	e8 77 d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102eef:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef2:	8b 40 08             	mov    0x8(%eax),%eax
80102ef5:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102efa:	76 1d                	jbe    80102f19 <idestart+0x43>
      cprintf("block %d \n");
80102efc:	83 ec 0c             	sub    $0xc,%esp
80102eff:	68 c7 96 10 80       	push   $0x801096c7
80102f04:	e8 bd d4 ff ff       	call   801003c6 <cprintf>
80102f09:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102f0c:	83 ec 0c             	sub    $0xc,%esp
80102f0f:	68 d2 96 10 80       	push   $0x801096d2
80102f14:	e8 4d d6 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102f19:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102f20:	8b 45 08             	mov    0x8(%ebp),%eax
80102f23:	8b 50 08             	mov    0x8(%eax),%edx
80102f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f29:	0f af c2             	imul   %edx,%eax
80102f2c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f2f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f33:	7e 0d                	jle    80102f42 <idestart+0x6c>
80102f35:	83 ec 0c             	sub    $0xc,%esp
80102f38:	68 be 96 10 80       	push   $0x801096be
80102f3d:	e8 24 d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102f42:	83 ec 0c             	sub    $0xc,%esp
80102f45:	6a 00                	push   $0x0
80102f47:	e8 97 fe ff ff       	call   80102de3 <idewait>
80102f4c:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f4f:	83 ec 08             	sub    $0x8,%esp
80102f52:	6a 00                	push   $0x0
80102f54:	68 f6 03 00 00       	push   $0x3f6
80102f59:	e8 40 fe ff ff       	call   80102d9e <outb>
80102f5e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f64:	0f b6 c0             	movzbl %al,%eax
80102f67:	83 ec 08             	sub    $0x8,%esp
80102f6a:	50                   	push   %eax
80102f6b:	68 f2 01 00 00       	push   $0x1f2
80102f70:	e8 29 fe ff ff       	call   80102d9e <outb>
80102f75:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f7b:	0f b6 c0             	movzbl %al,%eax
80102f7e:	83 ec 08             	sub    $0x8,%esp
80102f81:	50                   	push   %eax
80102f82:	68 f3 01 00 00       	push   $0x1f3
80102f87:	e8 12 fe ff ff       	call   80102d9e <outb>
80102f8c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f92:	c1 f8 08             	sar    $0x8,%eax
80102f95:	0f b6 c0             	movzbl %al,%eax
80102f98:	83 ec 08             	sub    $0x8,%esp
80102f9b:	50                   	push   %eax
80102f9c:	68 f4 01 00 00       	push   $0x1f4
80102fa1:	e8 f8 fd ff ff       	call   80102d9e <outb>
80102fa6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fac:	c1 f8 10             	sar    $0x10,%eax
80102faf:	0f b6 c0             	movzbl %al,%eax
80102fb2:	83 ec 08             	sub    $0x8,%esp
80102fb5:	50                   	push   %eax
80102fb6:	68 f5 01 00 00       	push   $0x1f5
80102fbb:	e8 de fd ff ff       	call   80102d9e <outb>
80102fc0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fc6:	8b 40 04             	mov    0x4(%eax),%eax
80102fc9:	83 e0 01             	and    $0x1,%eax
80102fcc:	c1 e0 04             	shl    $0x4,%eax
80102fcf:	89 c2                	mov    %eax,%edx
80102fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fd4:	c1 f8 18             	sar    $0x18,%eax
80102fd7:	83 e0 0f             	and    $0xf,%eax
80102fda:	09 d0                	or     %edx,%eax
80102fdc:	83 c8 e0             	or     $0xffffffe0,%eax
80102fdf:	0f b6 c0             	movzbl %al,%eax
80102fe2:	83 ec 08             	sub    $0x8,%esp
80102fe5:	50                   	push   %eax
80102fe6:	68 f6 01 00 00       	push   $0x1f6
80102feb:	e8 ae fd ff ff       	call   80102d9e <outb>
80102ff0:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ff6:	8b 00                	mov    (%eax),%eax
80102ff8:	83 e0 04             	and    $0x4,%eax
80102ffb:	85 c0                	test   %eax,%eax
80102ffd:	74 30                	je     8010302f <idestart+0x159>
    outb(0x1f7, IDE_CMD_WRITE);
80102fff:	83 ec 08             	sub    $0x8,%esp
80103002:	6a 30                	push   $0x30
80103004:	68 f7 01 00 00       	push   $0x1f7
80103009:	e8 90 fd ff ff       	call   80102d9e <outb>
8010300e:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80103011:	8b 45 08             	mov    0x8(%ebp),%eax
80103014:	83 c0 18             	add    $0x18,%eax
80103017:	83 ec 04             	sub    $0x4,%esp
8010301a:	68 80 00 00 00       	push   $0x80
8010301f:	50                   	push   %eax
80103020:	68 f0 01 00 00       	push   $0x1f0
80103025:	e8 93 fd ff ff       	call   80102dbd <outsl>
8010302a:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010302d:	eb 12                	jmp    80103041 <idestart+0x16b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010302f:	83 ec 08             	sub    $0x8,%esp
80103032:	6a 20                	push   $0x20
80103034:	68 f7 01 00 00       	push   $0x1f7
80103039:	e8 60 fd ff ff       	call   80102d9e <outb>
8010303e:	83 c4 10             	add    $0x10,%esp
  }
}
80103041:	90                   	nop
80103042:	c9                   	leave  
80103043:	c3                   	ret    

80103044 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80103044:	55                   	push   %ebp
80103045:	89 e5                	mov    %esp,%ebp
80103047:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010304a:	83 ec 0c             	sub    $0xc,%esp
8010304d:	68 00 c6 10 80       	push   $0x8010c600
80103052:	e8 30 2b 00 00       	call   80105b87 <acquire>
80103057:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010305a:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010305f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103066:	75 15                	jne    8010307d <ideintr+0x39>
    release(&idelock);
80103068:	83 ec 0c             	sub    $0xc,%esp
8010306b:	68 00 c6 10 80       	push   $0x8010c600
80103070:	e8 79 2b 00 00       	call   80105bee <release>
80103075:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80103078:	e9 9a 00 00 00       	jmp    80103117 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010307d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103080:	8b 40 14             	mov    0x14(%eax),%eax
80103083:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010308b:	8b 00                	mov    (%eax),%eax
8010308d:	83 e0 04             	and    $0x4,%eax
80103090:	85 c0                	test   %eax,%eax
80103092:	75 2d                	jne    801030c1 <ideintr+0x7d>
80103094:	83 ec 0c             	sub    $0xc,%esp
80103097:	6a 01                	push   $0x1
80103099:	e8 45 fd ff ff       	call   80102de3 <idewait>
8010309e:	83 c4 10             	add    $0x10,%esp
801030a1:	85 c0                	test   %eax,%eax
801030a3:	78 1c                	js     801030c1 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801030a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030a8:	83 c0 18             	add    $0x18,%eax
801030ab:	83 ec 04             	sub    $0x4,%esp
801030ae:	68 80 00 00 00       	push   $0x80
801030b3:	50                   	push   %eax
801030b4:	68 f0 01 00 00       	push   $0x1f0
801030b9:	e8 ba fc ff ff       	call   80102d78 <insl>
801030be:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801030c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c4:	8b 00                	mov    (%eax),%eax
801030c6:	83 c8 02             	or     $0x2,%eax
801030c9:	89 c2                	mov    %eax,%edx
801030cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030ce:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030d3:	8b 00                	mov    (%eax),%eax
801030d5:	83 e0 fb             	and    $0xfffffffb,%eax
801030d8:	89 c2                	mov    %eax,%edx
801030da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030dd:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801030df:	83 ec 0c             	sub    $0xc,%esp
801030e2:	ff 75 f4             	pushl  -0xc(%ebp)
801030e5:	e8 8f 28 00 00       	call   80105979 <wakeup>
801030ea:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
801030ed:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030f2:	85 c0                	test   %eax,%eax
801030f4:	74 11                	je     80103107 <ideintr+0xc3>
            //cprintf("ideintr \n");
                idestart(idequeue);
801030f6:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	50                   	push   %eax
801030ff:	e8 d2 fd ff ff       	call   80102ed6 <idestart>
80103104:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
80103107:	83 ec 0c             	sub    $0xc,%esp
8010310a:	68 00 c6 10 80       	push   $0x8010c600
8010310f:	e8 da 2a 00 00       	call   80105bee <release>
80103114:	83 c4 10             	add    $0x10,%esp
}
80103117:	c9                   	leave  
80103118:	c3                   	ret    

80103119 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103119:	55                   	push   %ebp
8010311a:	89 e5                	mov    %esp,%ebp
8010311c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010311f:	8b 45 08             	mov    0x8(%ebp),%eax
80103122:	8b 00                	mov    (%eax),%eax
80103124:	83 e0 01             	and    $0x1,%eax
80103127:	85 c0                	test   %eax,%eax
80103129:	75 0d                	jne    80103138 <iderw+0x1f>
    panic("iderw: buf not busy");
8010312b:	83 ec 0c             	sub    $0xc,%esp
8010312e:	68 e4 96 10 80       	push   $0x801096e4
80103133:	e8 2e d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103138:	8b 45 08             	mov    0x8(%ebp),%eax
8010313b:	8b 00                	mov    (%eax),%eax
8010313d:	83 e0 06             	and    $0x6,%eax
80103140:	83 f8 02             	cmp    $0x2,%eax
80103143:	75 0d                	jne    80103152 <iderw+0x39>
    panic("iderw: nothing to do");
80103145:	83 ec 0c             	sub    $0xc,%esp
80103148:	68 f8 96 10 80       	push   $0x801096f8
8010314d:	e8 14 d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80103152:	8b 45 08             	mov    0x8(%ebp),%eax
80103155:	8b 40 04             	mov    0x4(%eax),%eax
80103158:	85 c0                	test   %eax,%eax
8010315a:	74 16                	je     80103172 <iderw+0x59>
8010315c:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80103161:	85 c0                	test   %eax,%eax
80103163:	75 0d                	jne    80103172 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80103165:	83 ec 0c             	sub    $0xc,%esp
80103168:	68 0d 97 10 80       	push   $0x8010970d
8010316d:	e8 f4 d3 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80103172:	83 ec 0c             	sub    $0xc,%esp
80103175:	68 00 c6 10 80       	push   $0x8010c600
8010317a:	e8 08 2a 00 00       	call   80105b87 <acquire>
8010317f:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80103182:	8b 45 08             	mov    0x8(%ebp),%eax
80103185:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010318c:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80103193:	eb 0b                	jmp    801031a0 <iderw+0x87>
80103195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103198:	8b 00                	mov    (%eax),%eax
8010319a:	83 c0 14             	add    $0x14,%eax
8010319d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801031a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a3:	8b 00                	mov    (%eax),%eax
801031a5:	85 c0                	test   %eax,%eax
801031a7:	75 ec                	jne    80103195 <iderw+0x7c>
    ;
  *pp = b;
801031a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ac:	8b 55 08             	mov    0x8(%ebp),%edx
801031af:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
801031b1:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801031b6:	3b 45 08             	cmp    0x8(%ebp),%eax
801031b9:	75 23                	jne    801031de <iderw+0xc5>
     // cprintf("iderw \n");
          idestart(b);
801031bb:	83 ec 0c             	sub    $0xc,%esp
801031be:	ff 75 08             	pushl  0x8(%ebp)
801031c1:	e8 10 fd ff ff       	call   80102ed6 <idestart>
801031c6:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031c9:	eb 13                	jmp    801031de <iderw+0xc5>
    sleep(b, &idelock);
801031cb:	83 ec 08             	sub    $0x8,%esp
801031ce:	68 00 c6 10 80       	push   $0x8010c600
801031d3:	ff 75 08             	pushl  0x8(%ebp)
801031d6:	e8 b3 26 00 00       	call   8010588e <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031de:	8b 45 08             	mov    0x8(%ebp),%eax
801031e1:	8b 00                	mov    (%eax),%eax
801031e3:	83 e0 06             	and    $0x6,%eax
801031e6:	83 f8 02             	cmp    $0x2,%eax
801031e9:	75 e0                	jne    801031cb <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801031eb:	83 ec 0c             	sub    $0xc,%esp
801031ee:	68 00 c6 10 80       	push   $0x8010c600
801031f3:	e8 f6 29 00 00       	call   80105bee <release>
801031f8:	83 c4 10             	add    $0x10,%esp
}
801031fb:	90                   	nop
801031fc:	c9                   	leave  
801031fd:	c3                   	ret    

801031fe <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801031fe:	55                   	push   %ebp
801031ff:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103201:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103206:	8b 55 08             	mov    0x8(%ebp),%edx
80103209:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010320b:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103210:	8b 40 10             	mov    0x10(%eax),%eax
}
80103213:	5d                   	pop    %ebp
80103214:	c3                   	ret    

80103215 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80103215:	55                   	push   %ebp
80103216:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103218:	a1 fc 34 11 80       	mov    0x801134fc,%eax
8010321d:	8b 55 08             	mov    0x8(%ebp),%edx
80103220:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80103222:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103227:	8b 55 0c             	mov    0xc(%ebp),%edx
8010322a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010322d:	90                   	nop
8010322e:	5d                   	pop    %ebp
8010322f:	c3                   	ret    

80103230 <ioapicinit>:

void
ioapicinit(void)
{
80103230:	55                   	push   %ebp
80103231:	89 e5                	mov    %esp,%ebp
80103233:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80103236:	a1 64 38 11 80       	mov    0x80113864,%eax
8010323b:	85 c0                	test   %eax,%eax
8010323d:	0f 84 a0 00 00 00    	je     801032e3 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80103243:	c7 05 fc 34 11 80 00 	movl   $0xfec00000,0x801134fc
8010324a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010324d:	6a 01                	push   $0x1
8010324f:	e8 aa ff ff ff       	call   801031fe <ioapicread>
80103254:	83 c4 04             	add    $0x4,%esp
80103257:	c1 e8 10             	shr    $0x10,%eax
8010325a:	25 ff 00 00 00       	and    $0xff,%eax
8010325f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80103262:	6a 00                	push   $0x0
80103264:	e8 95 ff ff ff       	call   801031fe <ioapicread>
80103269:	83 c4 04             	add    $0x4,%esp
8010326c:	c1 e8 18             	shr    $0x18,%eax
8010326f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80103272:	0f b6 05 60 38 11 80 	movzbl 0x80113860,%eax
80103279:	0f b6 c0             	movzbl %al,%eax
8010327c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010327f:	74 10                	je     80103291 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80103281:	83 ec 0c             	sub    $0xc,%esp
80103284:	68 2c 97 10 80       	push   $0x8010972c
80103289:	e8 38 d1 ff ff       	call   801003c6 <cprintf>
8010328e:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103291:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103298:	eb 3f                	jmp    801032d9 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329d:	83 c0 20             	add    $0x20,%eax
801032a0:	0d 00 00 01 00       	or     $0x10000,%eax
801032a5:	89 c2                	mov    %eax,%edx
801032a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032aa:	83 c0 08             	add    $0x8,%eax
801032ad:	01 c0                	add    %eax,%eax
801032af:	83 ec 08             	sub    $0x8,%esp
801032b2:	52                   	push   %edx
801032b3:	50                   	push   %eax
801032b4:	e8 5c ff ff ff       	call   80103215 <ioapicwrite>
801032b9:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801032bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032bf:	83 c0 08             	add    $0x8,%eax
801032c2:	01 c0                	add    %eax,%eax
801032c4:	83 c0 01             	add    $0x1,%eax
801032c7:	83 ec 08             	sub    $0x8,%esp
801032ca:	6a 00                	push   $0x0
801032cc:	50                   	push   %eax
801032cd:	e8 43 ff ff ff       	call   80103215 <ioapicwrite>
801032d2:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801032df:	7e b9                	jle    8010329a <ioapicinit+0x6a>
801032e1:	eb 01                	jmp    801032e4 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801032e3:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801032e4:	c9                   	leave  
801032e5:	c3                   	ret    

801032e6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801032e6:	55                   	push   %ebp
801032e7:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801032e9:	a1 64 38 11 80       	mov    0x80113864,%eax
801032ee:	85 c0                	test   %eax,%eax
801032f0:	74 39                	je     8010332b <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801032f2:	8b 45 08             	mov    0x8(%ebp),%eax
801032f5:	83 c0 20             	add    $0x20,%eax
801032f8:	89 c2                	mov    %eax,%edx
801032fa:	8b 45 08             	mov    0x8(%ebp),%eax
801032fd:	83 c0 08             	add    $0x8,%eax
80103300:	01 c0                	add    %eax,%eax
80103302:	52                   	push   %edx
80103303:	50                   	push   %eax
80103304:	e8 0c ff ff ff       	call   80103215 <ioapicwrite>
80103309:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010330c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010330f:	c1 e0 18             	shl    $0x18,%eax
80103312:	89 c2                	mov    %eax,%edx
80103314:	8b 45 08             	mov    0x8(%ebp),%eax
80103317:	83 c0 08             	add    $0x8,%eax
8010331a:	01 c0                	add    %eax,%eax
8010331c:	83 c0 01             	add    $0x1,%eax
8010331f:	52                   	push   %edx
80103320:	50                   	push   %eax
80103321:	e8 ef fe ff ff       	call   80103215 <ioapicwrite>
80103326:	83 c4 08             	add    $0x8,%esp
80103329:	eb 01                	jmp    8010332c <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
8010332b:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
8010332c:	c9                   	leave  
8010332d:	c3                   	ret    

8010332e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010332e:	55                   	push   %ebp
8010332f:	89 e5                	mov    %esp,%ebp
80103331:	8b 45 08             	mov    0x8(%ebp),%eax
80103334:	05 00 00 00 80       	add    $0x80000000,%eax
80103339:	5d                   	pop    %ebp
8010333a:	c3                   	ret    

8010333b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010333b:	55                   	push   %ebp
8010333c:	89 e5                	mov    %esp,%ebp
8010333e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80103341:	83 ec 08             	sub    $0x8,%esp
80103344:	68 5e 97 10 80       	push   $0x8010975e
80103349:	68 00 35 11 80       	push   $0x80113500
8010334e:	e8 12 28 00 00       	call   80105b65 <initlock>
80103353:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80103356:	c7 05 34 35 11 80 00 	movl   $0x0,0x80113534
8010335d:	00 00 00 
  freerange(vstart, vend);
80103360:	83 ec 08             	sub    $0x8,%esp
80103363:	ff 75 0c             	pushl  0xc(%ebp)
80103366:	ff 75 08             	pushl  0x8(%ebp)
80103369:	e8 2a 00 00 00       	call   80103398 <freerange>
8010336e:	83 c4 10             	add    $0x10,%esp
}
80103371:	90                   	nop
80103372:	c9                   	leave  
80103373:	c3                   	ret    

80103374 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80103374:	55                   	push   %ebp
80103375:	89 e5                	mov    %esp,%ebp
80103377:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010337a:	83 ec 08             	sub    $0x8,%esp
8010337d:	ff 75 0c             	pushl  0xc(%ebp)
80103380:	ff 75 08             	pushl  0x8(%ebp)
80103383:	e8 10 00 00 00       	call   80103398 <freerange>
80103388:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
8010338b:	c7 05 34 35 11 80 01 	movl   $0x1,0x80113534
80103392:	00 00 00 
}
80103395:	90                   	nop
80103396:	c9                   	leave  
80103397:	c3                   	ret    

80103398 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103398:	55                   	push   %ebp
80103399:	89 e5                	mov    %esp,%ebp
8010339b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010339e:	8b 45 08             	mov    0x8(%ebp),%eax
801033a1:	05 ff 0f 00 00       	add    $0xfff,%eax
801033a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801033ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033ae:	eb 15                	jmp    801033c5 <freerange+0x2d>
    kfree(p);
801033b0:	83 ec 0c             	sub    $0xc,%esp
801033b3:	ff 75 f4             	pushl  -0xc(%ebp)
801033b6:	e8 1a 00 00 00       	call   801033d5 <kfree>
801033bb:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033be:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801033c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c8:	05 00 10 00 00       	add    $0x1000,%eax
801033cd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801033d0:	76 de                	jbe    801033b0 <freerange+0x18>
    kfree(p);
}
801033d2:	90                   	nop
801033d3:	c9                   	leave  
801033d4:	c3                   	ret    

801033d5 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801033d5:	55                   	push   %ebp
801033d6:	89 e5                	mov    %esp,%ebp
801033d8:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801033db:	8b 45 08             	mov    0x8(%ebp),%eax
801033de:	25 ff 0f 00 00       	and    $0xfff,%eax
801033e3:	85 c0                	test   %eax,%eax
801033e5:	75 1b                	jne    80103402 <kfree+0x2d>
801033e7:	81 7d 08 5c 66 11 80 	cmpl   $0x8011665c,0x8(%ebp)
801033ee:	72 12                	jb     80103402 <kfree+0x2d>
801033f0:	ff 75 08             	pushl  0x8(%ebp)
801033f3:	e8 36 ff ff ff       	call   8010332e <v2p>
801033f8:	83 c4 04             	add    $0x4,%esp
801033fb:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103400:	76 0d                	jbe    8010340f <kfree+0x3a>
    panic("kfree");
80103402:	83 ec 0c             	sub    $0xc,%esp
80103405:	68 63 97 10 80       	push   $0x80109763
8010340a:	e8 57 d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010340f:	83 ec 04             	sub    $0x4,%esp
80103412:	68 00 10 00 00       	push   $0x1000
80103417:	6a 01                	push   $0x1
80103419:	ff 75 08             	pushl  0x8(%ebp)
8010341c:	e8 c9 29 00 00       	call   80105dea <memset>
80103421:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80103424:	a1 34 35 11 80       	mov    0x80113534,%eax
80103429:	85 c0                	test   %eax,%eax
8010342b:	74 10                	je     8010343d <kfree+0x68>
    acquire(&kmem.lock);
8010342d:	83 ec 0c             	sub    $0xc,%esp
80103430:	68 00 35 11 80       	push   $0x80113500
80103435:	e8 4d 27 00 00       	call   80105b87 <acquire>
8010343a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010343d:	8b 45 08             	mov    0x8(%ebp),%eax
80103440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103443:	8b 15 38 35 11 80    	mov    0x80113538,%edx
80103449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010344c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
80103456:	a1 34 35 11 80       	mov    0x80113534,%eax
8010345b:	85 c0                	test   %eax,%eax
8010345d:	74 10                	je     8010346f <kfree+0x9a>
    release(&kmem.lock);
8010345f:	83 ec 0c             	sub    $0xc,%esp
80103462:	68 00 35 11 80       	push   $0x80113500
80103467:	e8 82 27 00 00       	call   80105bee <release>
8010346c:	83 c4 10             	add    $0x10,%esp
}
8010346f:	90                   	nop
80103470:	c9                   	leave  
80103471:	c3                   	ret    

80103472 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103472:	55                   	push   %ebp
80103473:	89 e5                	mov    %esp,%ebp
80103475:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103478:	a1 34 35 11 80       	mov    0x80113534,%eax
8010347d:	85 c0                	test   %eax,%eax
8010347f:	74 10                	je     80103491 <kalloc+0x1f>
    acquire(&kmem.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 00 35 11 80       	push   $0x80113500
80103489:	e8 f9 26 00 00       	call   80105b87 <acquire>
8010348e:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80103491:	a1 38 35 11 80       	mov    0x80113538,%eax
80103496:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103499:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010349d:	74 0a                	je     801034a9 <kalloc+0x37>
    kmem.freelist = r->next;
8010349f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034a2:	8b 00                	mov    (%eax),%eax
801034a4:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
801034a9:	a1 34 35 11 80       	mov    0x80113534,%eax
801034ae:	85 c0                	test   %eax,%eax
801034b0:	74 10                	je     801034c2 <kalloc+0x50>
    release(&kmem.lock);
801034b2:	83 ec 0c             	sub    $0xc,%esp
801034b5:	68 00 35 11 80       	push   $0x80113500
801034ba:	e8 2f 27 00 00       	call   80105bee <release>
801034bf:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801034c5:	c9                   	leave  
801034c6:	c3                   	ret    

801034c7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034c7:	55                   	push   %ebp
801034c8:	89 e5                	mov    %esp,%ebp
801034ca:	83 ec 14             	sub    $0x14,%esp
801034cd:	8b 45 08             	mov    0x8(%ebp),%eax
801034d0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034d4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034d8:	89 c2                	mov    %eax,%edx
801034da:	ec                   	in     (%dx),%al
801034db:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034de:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034e2:	c9                   	leave  
801034e3:	c3                   	ret    

801034e4 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801034e4:	55                   	push   %ebp
801034e5:	89 e5                	mov    %esp,%ebp
801034e7:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801034ea:	6a 64                	push   $0x64
801034ec:	e8 d6 ff ff ff       	call   801034c7 <inb>
801034f1:	83 c4 04             	add    $0x4,%esp
801034f4:	0f b6 c0             	movzbl %al,%eax
801034f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801034fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034fd:	83 e0 01             	and    $0x1,%eax
80103500:	85 c0                	test   %eax,%eax
80103502:	75 0a                	jne    8010350e <kbdgetc+0x2a>
    return -1;
80103504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103509:	e9 23 01 00 00       	jmp    80103631 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010350e:	6a 60                	push   $0x60
80103510:	e8 b2 ff ff ff       	call   801034c7 <inb>
80103515:	83 c4 04             	add    $0x4,%esp
80103518:	0f b6 c0             	movzbl %al,%eax
8010351b:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010351e:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103525:	75 17                	jne    8010353e <kbdgetc+0x5a>
    shift |= E0ESC;
80103527:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010352c:	83 c8 40             	or     $0x40,%eax
8010352f:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103534:	b8 00 00 00 00       	mov    $0x0,%eax
80103539:	e9 f3 00 00 00       	jmp    80103631 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010353e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103541:	25 80 00 00 00       	and    $0x80,%eax
80103546:	85 c0                	test   %eax,%eax
80103548:	74 45                	je     8010358f <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010354a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010354f:	83 e0 40             	and    $0x40,%eax
80103552:	85 c0                	test   %eax,%eax
80103554:	75 08                	jne    8010355e <kbdgetc+0x7a>
80103556:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103559:	83 e0 7f             	and    $0x7f,%eax
8010355c:	eb 03                	jmp    80103561 <kbdgetc+0x7d>
8010355e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103561:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103564:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103567:	05 40 a0 10 80       	add    $0x8010a040,%eax
8010356c:	0f b6 00             	movzbl (%eax),%eax
8010356f:	83 c8 40             	or     $0x40,%eax
80103572:	0f b6 c0             	movzbl %al,%eax
80103575:	f7 d0                	not    %eax
80103577:	89 c2                	mov    %eax,%edx
80103579:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010357e:	21 d0                	and    %edx,%eax
80103580:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103585:	b8 00 00 00 00       	mov    $0x0,%eax
8010358a:	e9 a2 00 00 00       	jmp    80103631 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010358f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103594:	83 e0 40             	and    $0x40,%eax
80103597:	85 c0                	test   %eax,%eax
80103599:	74 14                	je     801035af <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010359b:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801035a2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035a7:	83 e0 bf             	and    $0xffffffbf,%eax
801035aa:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
801035af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035b2:	05 40 a0 10 80       	add    $0x8010a040,%eax
801035b7:	0f b6 00             	movzbl (%eax),%eax
801035ba:	0f b6 d0             	movzbl %al,%edx
801035bd:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035c2:	09 d0                	or     %edx,%eax
801035c4:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801035c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035cc:	05 40 a1 10 80       	add    $0x8010a140,%eax
801035d1:	0f b6 00             	movzbl (%eax),%eax
801035d4:	0f b6 d0             	movzbl %al,%edx
801035d7:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035dc:	31 d0                	xor    %edx,%eax
801035de:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801035e3:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035e8:	83 e0 03             	and    $0x3,%eax
801035eb:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
801035f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035f5:	01 d0                	add    %edx,%eax
801035f7:	0f b6 00             	movzbl (%eax),%eax
801035fa:	0f b6 c0             	movzbl %al,%eax
801035fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103600:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103605:	83 e0 08             	and    $0x8,%eax
80103608:	85 c0                	test   %eax,%eax
8010360a:	74 22                	je     8010362e <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010360c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103610:	76 0c                	jbe    8010361e <kbdgetc+0x13a>
80103612:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103616:	77 06                	ja     8010361e <kbdgetc+0x13a>
      c += 'A' - 'a';
80103618:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010361c:	eb 10                	jmp    8010362e <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010361e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103622:	76 0a                	jbe    8010362e <kbdgetc+0x14a>
80103624:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103628:	77 04                	ja     8010362e <kbdgetc+0x14a>
      c += 'a' - 'A';
8010362a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010362e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103631:	c9                   	leave  
80103632:	c3                   	ret    

80103633 <kbdintr>:

void
kbdintr(void)
{
80103633:	55                   	push   %ebp
80103634:	89 e5                	mov    %esp,%ebp
80103636:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103639:	83 ec 0c             	sub    $0xc,%esp
8010363c:	68 e4 34 10 80       	push   $0x801034e4
80103641:	e8 b3 d1 ff ff       	call   801007f9 <consoleintr>
80103646:	83 c4 10             	add    $0x10,%esp
}
80103649:	90                   	nop
8010364a:	c9                   	leave  
8010364b:	c3                   	ret    

8010364c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010364c:	55                   	push   %ebp
8010364d:	89 e5                	mov    %esp,%ebp
8010364f:	83 ec 14             	sub    $0x14,%esp
80103652:	8b 45 08             	mov    0x8(%ebp),%eax
80103655:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103659:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010365d:	89 c2                	mov    %eax,%edx
8010365f:	ec                   	in     (%dx),%al
80103660:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103663:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103667:	c9                   	leave  
80103668:	c3                   	ret    

80103669 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103669:	55                   	push   %ebp
8010366a:	89 e5                	mov    %esp,%ebp
8010366c:	83 ec 08             	sub    $0x8,%esp
8010366f:	8b 55 08             	mov    0x8(%ebp),%edx
80103672:	8b 45 0c             	mov    0xc(%ebp),%eax
80103675:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103679:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010367c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103680:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103684:	ee                   	out    %al,(%dx)
}
80103685:	90                   	nop
80103686:	c9                   	leave  
80103687:	c3                   	ret    

80103688 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103688:	55                   	push   %ebp
80103689:	89 e5                	mov    %esp,%ebp
8010368b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010368e:	9c                   	pushf  
8010368f:	58                   	pop    %eax
80103690:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103693:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010369b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036a0:	8b 55 08             	mov    0x8(%ebp),%edx
801036a3:	c1 e2 02             	shl    $0x2,%edx
801036a6:	01 c2                	add    %eax,%edx
801036a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ab:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801036ad:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036b2:	83 c0 20             	add    $0x20,%eax
801036b5:	8b 00                	mov    (%eax),%eax
}
801036b7:	90                   	nop
801036b8:	5d                   	pop    %ebp
801036b9:	c3                   	ret    

801036ba <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801036ba:	55                   	push   %ebp
801036bb:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801036bd:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036c2:	85 c0                	test   %eax,%eax
801036c4:	0f 84 0b 01 00 00    	je     801037d5 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801036ca:	68 3f 01 00 00       	push   $0x13f
801036cf:	6a 3c                	push   $0x3c
801036d1:	e8 c2 ff ff ff       	call   80103698 <lapicw>
801036d6:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801036d9:	6a 0b                	push   $0xb
801036db:	68 f8 00 00 00       	push   $0xf8
801036e0:	e8 b3 ff ff ff       	call   80103698 <lapicw>
801036e5:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801036e8:	68 20 00 02 00       	push   $0x20020
801036ed:	68 c8 00 00 00       	push   $0xc8
801036f2:	e8 a1 ff ff ff       	call   80103698 <lapicw>
801036f7:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801036fa:	68 80 96 98 00       	push   $0x989680
801036ff:	68 e0 00 00 00       	push   $0xe0
80103704:	e8 8f ff ff ff       	call   80103698 <lapicw>
80103709:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010370c:	68 00 00 01 00       	push   $0x10000
80103711:	68 d4 00 00 00       	push   $0xd4
80103716:	e8 7d ff ff ff       	call   80103698 <lapicw>
8010371b:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010371e:	68 00 00 01 00       	push   $0x10000
80103723:	68 d8 00 00 00       	push   $0xd8
80103728:	e8 6b ff ff ff       	call   80103698 <lapicw>
8010372d:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103730:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103735:	83 c0 30             	add    $0x30,%eax
80103738:	8b 00                	mov    (%eax),%eax
8010373a:	c1 e8 10             	shr    $0x10,%eax
8010373d:	0f b6 c0             	movzbl %al,%eax
80103740:	83 f8 03             	cmp    $0x3,%eax
80103743:	76 12                	jbe    80103757 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103745:	68 00 00 01 00       	push   $0x10000
8010374a:	68 d0 00 00 00       	push   $0xd0
8010374f:	e8 44 ff ff ff       	call   80103698 <lapicw>
80103754:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103757:	6a 33                	push   $0x33
80103759:	68 dc 00 00 00       	push   $0xdc
8010375e:	e8 35 ff ff ff       	call   80103698 <lapicw>
80103763:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103766:	6a 00                	push   $0x0
80103768:	68 a0 00 00 00       	push   $0xa0
8010376d:	e8 26 ff ff ff       	call   80103698 <lapicw>
80103772:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103775:	6a 00                	push   $0x0
80103777:	68 a0 00 00 00       	push   $0xa0
8010377c:	e8 17 ff ff ff       	call   80103698 <lapicw>
80103781:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103784:	6a 00                	push   $0x0
80103786:	6a 2c                	push   $0x2c
80103788:	e8 0b ff ff ff       	call   80103698 <lapicw>
8010378d:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103790:	6a 00                	push   $0x0
80103792:	68 c4 00 00 00       	push   $0xc4
80103797:	e8 fc fe ff ff       	call   80103698 <lapicw>
8010379c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010379f:	68 00 85 08 00       	push   $0x88500
801037a4:	68 c0 00 00 00       	push   $0xc0
801037a9:	e8 ea fe ff ff       	call   80103698 <lapicw>
801037ae:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801037b1:	90                   	nop
801037b2:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801037b7:	05 00 03 00 00       	add    $0x300,%eax
801037bc:	8b 00                	mov    (%eax),%eax
801037be:	25 00 10 00 00       	and    $0x1000,%eax
801037c3:	85 c0                	test   %eax,%eax
801037c5:	75 eb                	jne    801037b2 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801037c7:	6a 00                	push   $0x0
801037c9:	6a 20                	push   $0x20
801037cb:	e8 c8 fe ff ff       	call   80103698 <lapicw>
801037d0:	83 c4 08             	add    $0x8,%esp
801037d3:	eb 01                	jmp    801037d6 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801037d5:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801037d6:	c9                   	leave  
801037d7:	c3                   	ret    

801037d8 <cpunum>:

int
cpunum(void)
{
801037d8:	55                   	push   %ebp
801037d9:	89 e5                	mov    %esp,%ebp
801037db:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801037de:	e8 a5 fe ff ff       	call   80103688 <readeflags>
801037e3:	25 00 02 00 00       	and    $0x200,%eax
801037e8:	85 c0                	test   %eax,%eax
801037ea:	74 26                	je     80103812 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801037ec:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801037f1:	8d 50 01             	lea    0x1(%eax),%edx
801037f4:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
801037fa:	85 c0                	test   %eax,%eax
801037fc:	75 14                	jne    80103812 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801037fe:	8b 45 04             	mov    0x4(%ebp),%eax
80103801:	83 ec 08             	sub    $0x8,%esp
80103804:	50                   	push   %eax
80103805:	68 6c 97 10 80       	push   $0x8010976c
8010380a:	e8 b7 cb ff ff       	call   801003c6 <cprintf>
8010380f:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103812:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103817:	85 c0                	test   %eax,%eax
80103819:	74 0f                	je     8010382a <cpunum+0x52>
    return lapic[ID]>>24;
8010381b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103820:	83 c0 20             	add    $0x20,%eax
80103823:	8b 00                	mov    (%eax),%eax
80103825:	c1 e8 18             	shr    $0x18,%eax
80103828:	eb 05                	jmp    8010382f <cpunum+0x57>
  return 0;
8010382a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010382f:	c9                   	leave  
80103830:	c3                   	ret    

80103831 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103831:	55                   	push   %ebp
80103832:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103834:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103839:	85 c0                	test   %eax,%eax
8010383b:	74 0c                	je     80103849 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010383d:	6a 00                	push   $0x0
8010383f:	6a 2c                	push   $0x2c
80103841:	e8 52 fe ff ff       	call   80103698 <lapicw>
80103846:	83 c4 08             	add    $0x8,%esp
}
80103849:	90                   	nop
8010384a:	c9                   	leave  
8010384b:	c3                   	ret    

8010384c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010384c:	55                   	push   %ebp
8010384d:	89 e5                	mov    %esp,%ebp
}
8010384f:	90                   	nop
80103850:	5d                   	pop    %ebp
80103851:	c3                   	ret    

80103852 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103852:	55                   	push   %ebp
80103853:	89 e5                	mov    %esp,%ebp
80103855:	83 ec 14             	sub    $0x14,%esp
80103858:	8b 45 08             	mov    0x8(%ebp),%eax
8010385b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010385e:	6a 0f                	push   $0xf
80103860:	6a 70                	push   $0x70
80103862:	e8 02 fe ff ff       	call   80103669 <outb>
80103867:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010386a:	6a 0a                	push   $0xa
8010386c:	6a 71                	push   $0x71
8010386e:	e8 f6 fd ff ff       	call   80103669 <outb>
80103873:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103876:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010387d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103880:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103885:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103888:	83 c0 02             	add    $0x2,%eax
8010388b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010388e:	c1 ea 04             	shr    $0x4,%edx
80103891:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103894:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103898:	c1 e0 18             	shl    $0x18,%eax
8010389b:	50                   	push   %eax
8010389c:	68 c4 00 00 00       	push   $0xc4
801038a1:	e8 f2 fd ff ff       	call   80103698 <lapicw>
801038a6:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801038a9:	68 00 c5 00 00       	push   $0xc500
801038ae:	68 c0 00 00 00       	push   $0xc0
801038b3:	e8 e0 fd ff ff       	call   80103698 <lapicw>
801038b8:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801038bb:	68 c8 00 00 00       	push   $0xc8
801038c0:	e8 87 ff ff ff       	call   8010384c <microdelay>
801038c5:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801038c8:	68 00 85 00 00       	push   $0x8500
801038cd:	68 c0 00 00 00       	push   $0xc0
801038d2:	e8 c1 fd ff ff       	call   80103698 <lapicw>
801038d7:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038da:	6a 64                	push   $0x64
801038dc:	e8 6b ff ff ff       	call   8010384c <microdelay>
801038e1:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038eb:	eb 3d                	jmp    8010392a <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801038ed:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038f1:	c1 e0 18             	shl    $0x18,%eax
801038f4:	50                   	push   %eax
801038f5:	68 c4 00 00 00       	push   $0xc4
801038fa:	e8 99 fd ff ff       	call   80103698 <lapicw>
801038ff:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103902:	8b 45 0c             	mov    0xc(%ebp),%eax
80103905:	c1 e8 0c             	shr    $0xc,%eax
80103908:	80 cc 06             	or     $0x6,%ah
8010390b:	50                   	push   %eax
8010390c:	68 c0 00 00 00       	push   $0xc0
80103911:	e8 82 fd ff ff       	call   80103698 <lapicw>
80103916:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103919:	68 c8 00 00 00       	push   $0xc8
8010391e:	e8 29 ff ff ff       	call   8010384c <microdelay>
80103923:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103926:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010392a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010392e:	7e bd                	jle    801038ed <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103930:	90                   	nop
80103931:	c9                   	leave  
80103932:	c3                   	ret    

80103933 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103933:	55                   	push   %ebp
80103934:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103936:	8b 45 08             	mov    0x8(%ebp),%eax
80103939:	0f b6 c0             	movzbl %al,%eax
8010393c:	50                   	push   %eax
8010393d:	6a 70                	push   $0x70
8010393f:	e8 25 fd ff ff       	call   80103669 <outb>
80103944:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103947:	68 c8 00 00 00       	push   $0xc8
8010394c:	e8 fb fe ff ff       	call   8010384c <microdelay>
80103951:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103954:	6a 71                	push   $0x71
80103956:	e8 f1 fc ff ff       	call   8010364c <inb>
8010395b:	83 c4 04             	add    $0x4,%esp
8010395e:	0f b6 c0             	movzbl %al,%eax
}
80103961:	c9                   	leave  
80103962:	c3                   	ret    

80103963 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103963:	55                   	push   %ebp
80103964:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103966:	6a 00                	push   $0x0
80103968:	e8 c6 ff ff ff       	call   80103933 <cmos_read>
8010396d:	83 c4 04             	add    $0x4,%esp
80103970:	89 c2                	mov    %eax,%edx
80103972:	8b 45 08             	mov    0x8(%ebp),%eax
80103975:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103977:	6a 02                	push   $0x2
80103979:	e8 b5 ff ff ff       	call   80103933 <cmos_read>
8010397e:	83 c4 04             	add    $0x4,%esp
80103981:	89 c2                	mov    %eax,%edx
80103983:	8b 45 08             	mov    0x8(%ebp),%eax
80103986:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103989:	6a 04                	push   $0x4
8010398b:	e8 a3 ff ff ff       	call   80103933 <cmos_read>
80103990:	83 c4 04             	add    $0x4,%esp
80103993:	89 c2                	mov    %eax,%edx
80103995:	8b 45 08             	mov    0x8(%ebp),%eax
80103998:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010399b:	6a 07                	push   $0x7
8010399d:	e8 91 ff ff ff       	call   80103933 <cmos_read>
801039a2:	83 c4 04             	add    $0x4,%esp
801039a5:	89 c2                	mov    %eax,%edx
801039a7:	8b 45 08             	mov    0x8(%ebp),%eax
801039aa:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801039ad:	6a 08                	push   $0x8
801039af:	e8 7f ff ff ff       	call   80103933 <cmos_read>
801039b4:	83 c4 04             	add    $0x4,%esp
801039b7:	89 c2                	mov    %eax,%edx
801039b9:	8b 45 08             	mov    0x8(%ebp),%eax
801039bc:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801039bf:	6a 09                	push   $0x9
801039c1:	e8 6d ff ff ff       	call   80103933 <cmos_read>
801039c6:	83 c4 04             	add    $0x4,%esp
801039c9:	89 c2                	mov    %eax,%edx
801039cb:	8b 45 08             	mov    0x8(%ebp),%eax
801039ce:	89 50 14             	mov    %edx,0x14(%eax)
}
801039d1:	90                   	nop
801039d2:	c9                   	leave  
801039d3:	c3                   	ret    

801039d4 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039d4:	55                   	push   %ebp
801039d5:	89 e5                	mov    %esp,%ebp
801039d7:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039da:	6a 0b                	push   $0xb
801039dc:	e8 52 ff ff ff       	call   80103933 <cmos_read>
801039e1:	83 c4 04             	add    $0x4,%esp
801039e4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ea:	83 e0 04             	and    $0x4,%eax
801039ed:	85 c0                	test   %eax,%eax
801039ef:	0f 94 c0             	sete   %al
801039f2:	0f b6 c0             	movzbl %al,%eax
801039f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039f8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039fb:	50                   	push   %eax
801039fc:	e8 62 ff ff ff       	call   80103963 <fill_rtcdate>
80103a01:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103a04:	6a 0a                	push   $0xa
80103a06:	e8 28 ff ff ff       	call   80103933 <cmos_read>
80103a0b:	83 c4 04             	add    $0x4,%esp
80103a0e:	25 80 00 00 00       	and    $0x80,%eax
80103a13:	85 c0                	test   %eax,%eax
80103a15:	75 27                	jne    80103a3e <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103a17:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a1a:	50                   	push   %eax
80103a1b:	e8 43 ff ff ff       	call   80103963 <fill_rtcdate>
80103a20:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a23:	83 ec 04             	sub    $0x4,%esp
80103a26:	6a 18                	push   $0x18
80103a28:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a2b:	50                   	push   %eax
80103a2c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a2f:	50                   	push   %eax
80103a30:	e8 1c 24 00 00       	call   80105e51 <memcmp>
80103a35:	83 c4 10             	add    $0x10,%esp
80103a38:	85 c0                	test   %eax,%eax
80103a3a:	74 05                	je     80103a41 <cmostime+0x6d>
80103a3c:	eb ba                	jmp    801039f8 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a3e:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a3f:	eb b7                	jmp    801039f8 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103a41:	90                   	nop
  }

  // convert
  if (bcd) {
80103a42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a46:	0f 84 b4 00 00 00    	je     80103b00 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a4f:	c1 e8 04             	shr    $0x4,%eax
80103a52:	89 c2                	mov    %eax,%edx
80103a54:	89 d0                	mov    %edx,%eax
80103a56:	c1 e0 02             	shl    $0x2,%eax
80103a59:	01 d0                	add    %edx,%eax
80103a5b:	01 c0                	add    %eax,%eax
80103a5d:	89 c2                	mov    %eax,%edx
80103a5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a62:	83 e0 0f             	and    $0xf,%eax
80103a65:	01 d0                	add    %edx,%eax
80103a67:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a6d:	c1 e8 04             	shr    $0x4,%eax
80103a70:	89 c2                	mov    %eax,%edx
80103a72:	89 d0                	mov    %edx,%eax
80103a74:	c1 e0 02             	shl    $0x2,%eax
80103a77:	01 d0                	add    %edx,%eax
80103a79:	01 c0                	add    %eax,%eax
80103a7b:	89 c2                	mov    %eax,%edx
80103a7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a80:	83 e0 0f             	and    $0xf,%eax
80103a83:	01 d0                	add    %edx,%eax
80103a85:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a8b:	c1 e8 04             	shr    $0x4,%eax
80103a8e:	89 c2                	mov    %eax,%edx
80103a90:	89 d0                	mov    %edx,%eax
80103a92:	c1 e0 02             	shl    $0x2,%eax
80103a95:	01 d0                	add    %edx,%eax
80103a97:	01 c0                	add    %eax,%eax
80103a99:	89 c2                	mov    %eax,%edx
80103a9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a9e:	83 e0 0f             	and    $0xf,%eax
80103aa1:	01 d0                	add    %edx,%eax
80103aa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103aa9:	c1 e8 04             	shr    $0x4,%eax
80103aac:	89 c2                	mov    %eax,%edx
80103aae:	89 d0                	mov    %edx,%eax
80103ab0:	c1 e0 02             	shl    $0x2,%eax
80103ab3:	01 d0                	add    %edx,%eax
80103ab5:	01 c0                	add    %eax,%eax
80103ab7:	89 c2                	mov    %eax,%edx
80103ab9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103abc:	83 e0 0f             	and    $0xf,%eax
80103abf:	01 d0                	add    %edx,%eax
80103ac1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103ac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ac7:	c1 e8 04             	shr    $0x4,%eax
80103aca:	89 c2                	mov    %eax,%edx
80103acc:	89 d0                	mov    %edx,%eax
80103ace:	c1 e0 02             	shl    $0x2,%eax
80103ad1:	01 d0                	add    %edx,%eax
80103ad3:	01 c0                	add    %eax,%eax
80103ad5:	89 c2                	mov    %eax,%edx
80103ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ada:	83 e0 0f             	and    $0xf,%eax
80103add:	01 d0                	add    %edx,%eax
80103adf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103ae2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae5:	c1 e8 04             	shr    $0x4,%eax
80103ae8:	89 c2                	mov    %eax,%edx
80103aea:	89 d0                	mov    %edx,%eax
80103aec:	c1 e0 02             	shl    $0x2,%eax
80103aef:	01 d0                	add    %edx,%eax
80103af1:	01 c0                	add    %eax,%eax
80103af3:	89 c2                	mov    %eax,%edx
80103af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af8:	83 e0 0f             	and    $0xf,%eax
80103afb:	01 d0                	add    %edx,%eax
80103afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103b00:	8b 45 08             	mov    0x8(%ebp),%eax
80103b03:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103b06:	89 10                	mov    %edx,(%eax)
80103b08:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103b0b:	89 50 04             	mov    %edx,0x4(%eax)
80103b0e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103b11:	89 50 08             	mov    %edx,0x8(%eax)
80103b14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b17:	89 50 0c             	mov    %edx,0xc(%eax)
80103b1a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b1d:	89 50 10             	mov    %edx,0x10(%eax)
80103b20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b23:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b26:	8b 45 08             	mov    0x8(%ebp),%eax
80103b29:	8b 40 14             	mov    0x14(%eax),%eax
80103b2c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b32:	8b 45 08             	mov    0x8(%ebp),%eax
80103b35:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b38:	90                   	nop
80103b39:	c9                   	leave  
80103b3a:	c3                   	ret    

80103b3b <initlog>:
static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
80103b3b:	55                   	push   %ebp
80103b3c:	89 e5                	mov    %esp,%ebp
80103b3e:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103b41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b48:	e9 b1 00 00 00       	jmp    80103bfe <initlog+0xc3>
    if(mbrI.partitions[i].size > 0){
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	83 c0 1b             	add    $0x1b,%eax
80103b53:	c1 e0 04             	shl    $0x4,%eax
80103b56:	05 00 18 11 80       	add    $0x80111800,%eax
80103b5b:	8b 40 1a             	mov    0x1a(%eax),%eax
80103b5e:	85 c0                	test   %eax,%eax
80103b60:	0f 84 94 00 00 00    	je     80103bfa <initlog+0xbf>
        initlock(&logs[i].lock, "log");
80103b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b69:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b6f:	05 40 35 11 80       	add    $0x80113540,%eax
80103b74:	83 ec 08             	sub    $0x8,%esp
80103b77:	68 98 97 10 80       	push   $0x80109798
80103b7c:	50                   	push   %eax
80103b7d:	e8 e3 1f 00 00       	call   80105b65 <initlock>
80103b82:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b88:	c1 e0 05             	shl    $0x5,%eax
80103b8b:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b90:	8b 50 0c             	mov    0xc(%eax),%edx
80103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b96:	c1 e0 05             	shl    $0x5,%eax
80103b99:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b9e:	8b 00                	mov    (%eax),%eax
80103ba0:	01 d0                	add    %edx,%eax
80103ba2:	89 c2                	mov    %eax,%edx
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bad:	05 70 35 11 80       	add    $0x80113570,%eax
80103bb2:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb8:	c1 e0 05             	shl    $0x5,%eax
80103bbb:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103bc0:	8b 40 0c             	mov    0xc(%eax),%eax
80103bc3:	89 c2                	mov    %eax,%edx
80103bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bce:	05 70 35 11 80       	add    $0x80113570,%eax
80103bd3:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bdf:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103be5:	8b 45 08             	mov    0x8(%ebp),%eax
80103be8:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bee:	83 ec 0c             	sub    $0xc,%esp
80103bf1:	50                   	push   %eax
80103bf2:	e8 6a 02 00 00       	call   80103e61 <recover_from_log>
80103bf7:	83 c4 10             	add    $0x10,%esp
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103bfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bfe:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103c02:	0f 8e 45 ff ff ff    	jle    80103b4d <initlog+0x12>
  recover_from_log(i);
    }
     
}
 
}
80103c08:	90                   	nop
80103c09:	c9                   	leave  
80103c0a:	c3                   	ret    

80103c0b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103c0b:	55                   	push   %ebp
80103c0c:	89 e5                	mov    %esp,%ebp
80103c0e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103c11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c18:	e9 c0 00 00 00       	jmp    80103cdd <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c20:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c26:	05 70 35 11 80       	add    $0x80113570,%eax
80103c2b:	8b 50 04             	mov    0x4(%eax),%edx
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	01 d0                	add    %edx,%eax
80103c33:	83 c0 01             	add    $0x1,%eax
80103c36:	89 c2                	mov    %eax,%edx
80103c38:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c41:	05 80 35 11 80       	add    $0x80113580,%eax
80103c46:	8b 40 04             	mov    0x4(%eax),%eax
80103c49:	83 ec 08             	sub    $0x8,%esp
80103c4c:	52                   	push   %edx
80103c4d:	50                   	push   %eax
80103c4e:	e8 63 c5 ff ff       	call   801001b6 <bread>
80103c53:	83 c4 10             	add    $0x10,%esp
80103c56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c59:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5c:	6b d0 31             	imul   $0x31,%eax,%edx
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	01 d0                	add    %edx,%eax
80103c64:	83 c0 10             	add    $0x10,%eax
80103c67:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c6e:	89 c2                	mov    %eax,%edx
80103c70:	8b 45 08             	mov    0x8(%ebp),%eax
80103c73:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c79:	05 80 35 11 80       	add    $0x80113580,%eax
80103c7e:	8b 40 04             	mov    0x4(%eax),%eax
80103c81:	83 ec 08             	sub    $0x8,%esp
80103c84:	52                   	push   %edx
80103c85:	50                   	push   %eax
80103c86:	e8 2b c5 ff ff       	call   801001b6 <bread>
80103c8b:	83 c4 10             	add    $0x10,%esp
80103c8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c94:	8d 50 18             	lea    0x18(%eax),%edx
80103c97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c9a:	83 c0 18             	add    $0x18,%eax
80103c9d:	83 ec 04             	sub    $0x4,%esp
80103ca0:	68 00 02 00 00       	push   $0x200
80103ca5:	52                   	push   %edx
80103ca6:	50                   	push   %eax
80103ca7:	e8 fd 21 00 00       	call   80105ea9 <memmove>
80103cac:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103caf:	83 ec 0c             	sub    $0xc,%esp
80103cb2:	ff 75 ec             	pushl  -0x14(%ebp)
80103cb5:	e8 35 c5 ff ff       	call   801001ef <bwrite>
80103cba:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103cbd:	83 ec 0c             	sub    $0xc,%esp
80103cc0:	ff 75 f0             	pushl  -0x10(%ebp)
80103cc3:	e8 66 c5 ff ff       	call   8010022e <brelse>
80103cc8:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103ccb:	83 ec 0c             	sub    $0xc,%esp
80103cce:	ff 75 ec             	pushl  -0x14(%ebp)
80103cd1:	e8 58 c5 ff ff       	call   8010022e <brelse>
80103cd6:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103cd9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ce6:	05 80 35 11 80       	add    $0x80113580,%eax
80103ceb:	8b 40 08             	mov    0x8(%eax),%eax
80103cee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cf1:	0f 8f 26 ff ff ff    	jg     80103c1d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103cf7:	90                   	nop
80103cf8:	c9                   	leave  
80103cf9:	c3                   	ret    

80103cfa <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103cfa:	55                   	push   %ebp
80103cfb:	89 e5                	mov    %esp,%ebp
80103cfd:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d00:	8b 45 08             	mov    0x8(%ebp),%eax
80103d03:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d09:	05 70 35 11 80       	add    $0x80113570,%eax
80103d0e:	8b 40 04             	mov    0x4(%eax),%eax
80103d11:	89 c2                	mov    %eax,%edx
80103d13:	8b 45 08             	mov    0x8(%ebp),%eax
80103d16:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d1c:	05 80 35 11 80       	add    $0x80113580,%eax
80103d21:	8b 40 04             	mov    0x4(%eax),%eax
80103d24:	83 ec 08             	sub    $0x8,%esp
80103d27:	52                   	push   %edx
80103d28:	50                   	push   %eax
80103d29:	e8 88 c4 ff ff       	call   801001b6 <bread>
80103d2e:	83 c4 10             	add    $0x10,%esp
80103d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d37:	83 c0 18             	add    $0x18,%eax
80103d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d40:	8b 00                	mov    (%eax),%eax
80103d42:	8b 55 08             	mov    0x8(%ebp),%edx
80103d45:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d4b:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d51:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d5b:	eb 23                	jmp    80103d80 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d63:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d67:	8b 55 08             	mov    0x8(%ebp),%edx
80103d6a:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d70:	01 ca                	add    %ecx,%edx
80103d72:	83 c2 10             	add    $0x10,%edx
80103d75:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d80:	8b 45 08             	mov    0x8(%ebp),%eax
80103d83:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d89:	05 80 35 11 80       	add    $0x80113580,%eax
80103d8e:	8b 40 08             	mov    0x8(%eax),%eax
80103d91:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d94:	7f c7                	jg     80103d5d <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d96:	83 ec 0c             	sub    $0xc,%esp
80103d99:	ff 75 f0             	pushl  -0x10(%ebp)
80103d9c:	e8 8d c4 ff ff       	call   8010022e <brelse>
80103da1:	83 c4 10             	add    $0x10,%esp
}
80103da4:	90                   	nop
80103da5:	c9                   	leave  
80103da6:	c3                   	ret    

80103da7 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103da7:	55                   	push   %ebp
80103da8:	89 e5                	mov    %esp,%ebp
80103daa:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103dad:	8b 45 08             	mov    0x8(%ebp),%eax
80103db0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103db6:	05 70 35 11 80       	add    $0x80113570,%eax
80103dbb:	8b 40 04             	mov    0x4(%eax),%eax
80103dbe:	89 c2                	mov    %eax,%edx
80103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dc9:	05 80 35 11 80       	add    $0x80113580,%eax
80103dce:	8b 40 04             	mov    0x4(%eax),%eax
80103dd1:	83 ec 08             	sub    $0x8,%esp
80103dd4:	52                   	push   %edx
80103dd5:	50                   	push   %eax
80103dd6:	e8 db c3 ff ff       	call   801001b6 <bread>
80103ddb:	83 c4 10             	add    $0x10,%esp
80103dde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de4:	83 c0 18             	add    $0x18,%eax
80103de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103dea:	8b 45 08             	mov    0x8(%ebp),%eax
80103ded:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103df3:	05 80 35 11 80       	add    $0x80113580,%eax
80103df8:	8b 50 08             	mov    0x8(%eax),%edx
80103dfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dfe:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e07:	eb 23                	jmp    80103e2c <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103e09:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0c:	6b d0 31             	imul   $0x31,%eax,%edx
80103e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e12:	01 d0                	add    %edx,%eax
80103e14:	83 c0 10             	add    $0x10,%eax
80103e17:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103e1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e24:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e35:	05 80 35 11 80       	add    $0x80113580,%eax
80103e3a:	8b 40 08             	mov    0x8(%eax),%eax
80103e3d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e40:	7f c7                	jg     80103e09 <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e42:	83 ec 0c             	sub    $0xc,%esp
80103e45:	ff 75 f0             	pushl  -0x10(%ebp)
80103e48:	e8 a2 c3 ff ff       	call   801001ef <bwrite>
80103e4d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e50:	83 ec 0c             	sub    $0xc,%esp
80103e53:	ff 75 f0             	pushl  -0x10(%ebp)
80103e56:	e8 d3 c3 ff ff       	call   8010022e <brelse>
80103e5b:	83 c4 10             	add    $0x10,%esp
}
80103e5e:	90                   	nop
80103e5f:	c9                   	leave  
80103e60:	c3                   	ret    

80103e61 <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e61:	55                   	push   %ebp
80103e62:	89 e5                	mov    %esp,%ebp
80103e64:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e67:	83 ec 0c             	sub    $0xc,%esp
80103e6a:	ff 75 08             	pushl  0x8(%ebp)
80103e6d:	e8 88 fe ff ff       	call   80103cfa <read_head>
80103e72:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e75:	83 ec 0c             	sub    $0xc,%esp
80103e78:	ff 75 08             	pushl  0x8(%ebp)
80103e7b:	e8 8b fd ff ff       	call   80103c0b <install_trans>
80103e80:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e83:	8b 45 08             	mov    0x8(%ebp),%eax
80103e86:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e8c:	05 80 35 11 80       	add    $0x80113580,%eax
80103e91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103e98:	83 ec 0c             	sub    $0xc,%esp
80103e9b:	ff 75 08             	pushl  0x8(%ebp)
80103e9e:	e8 04 ff ff ff       	call   80103da7 <write_head>
80103ea3:	83 c4 10             	add    $0x10,%esp
}
80103ea6:	90                   	nop
80103ea7:	c9                   	leave  
80103ea8:	c3                   	ret    

80103ea9 <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103ea9:	55                   	push   %ebp
80103eaa:	89 e5                	mov    %esp,%ebp
80103eac:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eb8:	05 40 35 11 80       	add    $0x80113540,%eax
80103ebd:	83 ec 0c             	sub    $0xc,%esp
80103ec0:	50                   	push   %eax
80103ec1:	e8 c1 1c 00 00       	call   80105b87 <acquire>
80103ec6:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecc:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ed2:	05 80 35 11 80       	add    $0x80113580,%eax
80103ed7:	8b 00                	mov    (%eax),%eax
80103ed9:	85 c0                	test   %eax,%eax
80103edb:	74 2c                	je     80103f09 <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103edd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ee6:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ef5:	05 40 35 11 80       	add    $0x80113540,%eax
80103efa:	83 ec 08             	sub    $0x8,%esp
80103efd:	52                   	push   %edx
80103efe:	50                   	push   %eax
80103eff:	e8 8a 19 00 00       	call   8010588e <sleep>
80103f04:	83 c4 10             	add    $0x10,%esp
80103f07:	eb c0                	jmp    80103ec9 <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103f09:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f12:	05 80 35 11 80       	add    $0x80113580,%eax
80103f17:	8b 48 08             	mov    0x8(%eax),%ecx
80103f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f23:	05 70 35 11 80       	add    $0x80113570,%eax
80103f28:	8b 40 0c             	mov    0xc(%eax),%eax
80103f2b:	8d 50 01             	lea    0x1(%eax),%edx
80103f2e:	89 d0                	mov    %edx,%eax
80103f30:	c1 e0 02             	shl    $0x2,%eax
80103f33:	01 d0                	add    %edx,%eax
80103f35:	01 c0                	add    %eax,%eax
80103f37:	01 c8                	add    %ecx,%eax
80103f39:	83 f8 1e             	cmp    $0x1e,%eax
80103f3c:	7e 2f                	jle    80103f6d <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f41:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f47:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f50:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f56:	05 40 35 11 80       	add    $0x80113540,%eax
80103f5b:	83 ec 08             	sub    $0x8,%esp
80103f5e:	52                   	push   %edx
80103f5f:	50                   	push   %eax
80103f60:	e8 29 19 00 00       	call   8010588e <sleep>
80103f65:	83 c4 10             	add    $0x10,%esp
80103f68:	e9 5c ff ff ff       	jmp    80103ec9 <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f70:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f76:	05 70 35 11 80       	add    $0x80113570,%eax
80103f7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103f7e:	8d 50 01             	lea    0x1(%eax),%edx
80103f81:	8b 45 08             	mov    0x8(%ebp),%eax
80103f84:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f8a:	05 70 35 11 80       	add    $0x80113570,%eax
80103f8f:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103f92:	8b 45 08             	mov    0x8(%ebp),%eax
80103f95:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f9b:	05 40 35 11 80       	add    $0x80113540,%eax
80103fa0:	83 ec 0c             	sub    $0xc,%esp
80103fa3:	50                   	push   %eax
80103fa4:	e8 45 1c 00 00       	call   80105bee <release>
80103fa9:	83 c4 10             	add    $0x10,%esp
      break;
80103fac:	90                   	nop
    }
  }
}
80103fad:	90                   	nop
80103fae:	c9                   	leave  
80103faf:	c3                   	ret    

80103fb0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103fb0:	55                   	push   %ebp
80103fb1:	89 e5                	mov    %esp,%ebp
80103fb3:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103fb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fc6:	05 40 35 11 80       	add    $0x80113540,%eax
80103fcb:	83 ec 0c             	sub    $0xc,%esp
80103fce:	50                   	push   %eax
80103fcf:	e8 b3 1b 00 00       	call   80105b87 <acquire>
80103fd4:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fda:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fe0:	05 70 35 11 80       	add    $0x80113570,%eax
80103fe5:	8b 40 0c             	mov    0xc(%eax),%eax
80103fe8:	8d 50 ff             	lea    -0x1(%eax),%edx
80103feb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fee:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ff4:	05 70 35 11 80       	add    $0x80113570,%eax
80103ff9:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80103ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fff:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104005:	05 80 35 11 80       	add    $0x80113580,%eax
8010400a:	8b 00                	mov    (%eax),%eax
8010400c:	85 c0                	test   %eax,%eax
8010400e:	74 0d                	je     8010401d <end_op+0x6d>
    panic("log.committing");
80104010:	83 ec 0c             	sub    $0xc,%esp
80104013:	68 9c 97 10 80       	push   $0x8010979c
80104018:	e8 49 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
8010401d:	8b 45 08             	mov    0x8(%ebp),%eax
80104020:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104026:	05 70 35 11 80       	add    $0x80113570,%eax
8010402b:	8b 40 0c             	mov    0xc(%eax),%eax
8010402e:	85 c0                	test   %eax,%eax
80104030:	75 1d                	jne    8010404f <end_op+0x9f>
    do_commit = 1;
80104032:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80104039:	8b 45 08             	mov    0x8(%ebp),%eax
8010403c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104042:	05 80 35 11 80       	add    $0x80113580,%eax
80104047:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
8010404d:	eb 1a                	jmp    80104069 <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104058:	05 40 35 11 80       	add    $0x80113540,%eax
8010405d:	83 ec 0c             	sub    $0xc,%esp
80104060:	50                   	push   %eax
80104061:	e8 13 19 00 00       	call   80105979 <wakeup>
80104066:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104072:	05 40 35 11 80       	add    $0x80113540,%eax
80104077:	83 ec 0c             	sub    $0xc,%esp
8010407a:	50                   	push   %eax
8010407b:	e8 6e 1b 00 00       	call   80105bee <release>
80104080:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80104083:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104087:	74 70                	je     801040f9 <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80104089:	83 ec 0c             	sub    $0xc,%esp
8010408c:	ff 75 08             	pushl  0x8(%ebp)
8010408f:	e8 57 01 00 00       	call   801041eb <commit>
80104094:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
80104097:	8b 45 08             	mov    0x8(%ebp),%eax
8010409a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040a0:	05 40 35 11 80       	add    $0x80113540,%eax
801040a5:	83 ec 0c             	sub    $0xc,%esp
801040a8:	50                   	push   %eax
801040a9:	e8 d9 1a 00 00       	call   80105b87 <acquire>
801040ae:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
801040b1:	8b 45 08             	mov    0x8(%ebp),%eax
801040b4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040ba:	05 80 35 11 80       	add    $0x80113580,%eax
801040bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
801040c5:	8b 45 08             	mov    0x8(%ebp),%eax
801040c8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040ce:	05 40 35 11 80       	add    $0x80113540,%eax
801040d3:	83 ec 0c             	sub    $0xc,%esp
801040d6:	50                   	push   %eax
801040d7:	e8 9d 18 00 00       	call   80105979 <wakeup>
801040dc:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040df:	8b 45 08             	mov    0x8(%ebp),%eax
801040e2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040e8:	05 40 35 11 80       	add    $0x80113540,%eax
801040ed:	83 ec 0c             	sub    $0xc,%esp
801040f0:	50                   	push   %eax
801040f1:	e8 f8 1a 00 00       	call   80105bee <release>
801040f6:	83 c4 10             	add    $0x10,%esp
  }
}
801040f9:	90                   	nop
801040fa:	c9                   	leave  
801040fb:	c3                   	ret    

801040fc <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
801040fc:	55                   	push   %ebp
801040fd:	89 e5                	mov    %esp,%ebp
801040ff:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80104102:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104109:	e9 c0 00 00 00       	jmp    801041ce <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104117:	05 70 35 11 80       	add    $0x80113570,%eax
8010411c:	8b 50 04             	mov    0x4(%eax),%edx
8010411f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104122:	01 d0                	add    %edx,%eax
80104124:	83 c0 01             	add    $0x1,%eax
80104127:	89 c2                	mov    %eax,%edx
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104132:	05 80 35 11 80       	add    $0x80113580,%eax
80104137:	8b 40 04             	mov    0x4(%eax),%eax
8010413a:	83 ec 08             	sub    $0x8,%esp
8010413d:	52                   	push   %edx
8010413e:	50                   	push   %eax
8010413f:	e8 72 c0 ff ff       	call   801001b6 <bread>
80104144:	83 c4 10             	add    $0x10,%esp
80104147:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
8010414a:	8b 45 08             	mov    0x8(%ebp),%eax
8010414d:	6b d0 31             	imul   $0x31,%eax,%edx
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	01 d0                	add    %edx,%eax
80104155:	83 c0 10             	add    $0x10,%eax
80104158:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
8010415f:	89 c2                	mov    %eax,%edx
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010416a:	05 80 35 11 80       	add    $0x80113580,%eax
8010416f:	8b 40 04             	mov    0x4(%eax),%eax
80104172:	83 ec 08             	sub    $0x8,%esp
80104175:	52                   	push   %edx
80104176:	50                   	push   %eax
80104177:	e8 3a c0 ff ff       	call   801001b6 <bread>
8010417c:	83 c4 10             	add    $0x10,%esp
8010417f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80104182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104185:	8d 50 18             	lea    0x18(%eax),%edx
80104188:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010418b:	83 c0 18             	add    $0x18,%eax
8010418e:	83 ec 04             	sub    $0x4,%esp
80104191:	68 00 02 00 00       	push   $0x200
80104196:	52                   	push   %edx
80104197:	50                   	push   %eax
80104198:	e8 0c 1d 00 00       	call   80105ea9 <memmove>
8010419d:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801041a0:	83 ec 0c             	sub    $0xc,%esp
801041a3:	ff 75 f0             	pushl  -0x10(%ebp)
801041a6:	e8 44 c0 ff ff       	call   801001ef <bwrite>
801041ab:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801041ae:	83 ec 0c             	sub    $0xc,%esp
801041b1:	ff 75 ec             	pushl  -0x14(%ebp)
801041b4:	e8 75 c0 ff ff       	call   8010022e <brelse>
801041b9:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801041bc:	83 ec 0c             	sub    $0xc,%esp
801041bf:	ff 75 f0             	pushl  -0x10(%ebp)
801041c2:	e8 67 c0 ff ff       	call   8010022e <brelse>
801041c7:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801041ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041ce:	8b 45 08             	mov    0x8(%ebp),%eax
801041d1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041d7:	05 80 35 11 80       	add    $0x80113580,%eax
801041dc:	8b 40 08             	mov    0x8(%eax),%eax
801041df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041e2:	0f 8f 26 ff ff ff    	jg     8010410e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041e8:	90                   	nop
801041e9:	c9                   	leave  
801041ea:	c3                   	ret    

801041eb <commit>:

static void
commit(uint partitionNumber)
{
801041eb:	55                   	push   %ebp
801041ec:	89 e5                	mov    %esp,%ebp
801041ee:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
801041f1:	8b 45 08             	mov    0x8(%ebp),%eax
801041f4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041fa:	05 80 35 11 80       	add    $0x80113580,%eax
801041ff:	8b 40 08             	mov    0x8(%eax),%eax
80104202:	85 c0                	test   %eax,%eax
80104204:	7e 4d                	jle    80104253 <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
80104206:	83 ec 0c             	sub    $0xc,%esp
80104209:	ff 75 08             	pushl  0x8(%ebp)
8010420c:	e8 eb fe ff ff       	call   801040fc <write_log>
80104211:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
80104214:	83 ec 0c             	sub    $0xc,%esp
80104217:	ff 75 08             	pushl  0x8(%ebp)
8010421a:	e8 88 fb ff ff       	call   80103da7 <write_head>
8010421f:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
80104222:	83 ec 0c             	sub    $0xc,%esp
80104225:	ff 75 08             	pushl  0x8(%ebp)
80104228:	e8 de f9 ff ff       	call   80103c0b <install_trans>
8010422d:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104230:	8b 45 08             	mov    0x8(%ebp),%eax
80104233:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104239:	05 80 35 11 80       	add    $0x80113580,%eax
8010423e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
80104245:	83 ec 0c             	sub    $0xc,%esp
80104248:	ff 75 08             	pushl  0x8(%ebp)
8010424b:	e8 57 fb ff ff       	call   80103da7 <write_head>
80104250:	83 c4 10             	add    $0x10,%esp
  }
}
80104253:	90                   	nop
80104254:	c9                   	leave  
80104255:	c3                   	ret    

80104256 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
80104256:	55                   	push   %ebp
80104257:	89 e5                	mov    %esp,%ebp
80104259:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
8010425c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010425f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104265:	05 80 35 11 80       	add    $0x80113580,%eax
8010426a:	8b 40 08             	mov    0x8(%eax),%eax
8010426d:	83 f8 1d             	cmp    $0x1d,%eax
80104270:	7f 2a                	jg     8010429c <log_write+0x46>
80104272:	8b 45 0c             	mov    0xc(%ebp),%eax
80104275:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010427b:	05 80 35 11 80       	add    $0x80113580,%eax
80104280:	8b 40 08             	mov    0x8(%eax),%eax
80104283:	8b 55 0c             	mov    0xc(%ebp),%edx
80104286:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
8010428c:	81 c2 70 35 11 80    	add    $0x80113570,%edx
80104292:	8b 52 08             	mov    0x8(%edx),%edx
80104295:	83 ea 01             	sub    $0x1,%edx
80104298:	39 d0                	cmp    %edx,%eax
8010429a:	7c 0d                	jl     801042a9 <log_write+0x53>
    panic("too big a transaction");
8010429c:	83 ec 0c             	sub    $0xc,%esp
8010429f:	68 ab 97 10 80       	push   $0x801097ab
801042a4:	e8 bd c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
801042a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ac:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042b2:	05 70 35 11 80       	add    $0x80113570,%eax
801042b7:	8b 40 0c             	mov    0xc(%eax),%eax
801042ba:	85 c0                	test   %eax,%eax
801042bc:	7f 0d                	jg     801042cb <log_write+0x75>
    panic("log_write outside of trans");
801042be:	83 ec 0c             	sub    $0xc,%esp
801042c1:	68 c1 97 10 80       	push   $0x801097c1
801042c6:	e8 9b c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
801042cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ce:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042d4:	05 40 35 11 80       	add    $0x80113540,%eax
801042d9:	83 ec 0c             	sub    $0xc,%esp
801042dc:	50                   	push   %eax
801042dd:	e8 a5 18 00 00       	call   80105b87 <acquire>
801042e2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042ec:	eb 25                	jmp    80104313 <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801042f1:	6b d0 31             	imul   $0x31,%eax,%edx
801042f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f7:	01 d0                	add    %edx,%eax
801042f9:	83 c0 10             	add    $0x10,%eax
801042fc:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104303:	89 c2                	mov    %eax,%edx
80104305:	8b 45 08             	mov    0x8(%ebp),%eax
80104308:	8b 40 08             	mov    0x8(%eax),%eax
8010430b:	39 c2                	cmp    %eax,%edx
8010430d:	74 1c                	je     8010432b <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
8010430f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104313:	8b 45 0c             	mov    0xc(%ebp),%eax
80104316:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010431c:	05 80 35 11 80       	add    $0x80113580,%eax
80104321:	8b 40 08             	mov    0x8(%eax),%eax
80104324:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104327:	7f c5                	jg     801042ee <log_write+0x98>
80104329:	eb 01                	jmp    8010432c <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
8010432b:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
8010432c:	8b 45 08             	mov    0x8(%ebp),%eax
8010432f:	8b 40 08             	mov    0x8(%eax),%eax
80104332:	89 c1                	mov    %eax,%ecx
80104334:	8b 45 0c             	mov    0xc(%ebp),%eax
80104337:	6b d0 31             	imul   $0x31,%eax,%edx
8010433a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433d:	01 d0                	add    %edx,%eax
8010433f:	83 c0 10             	add    $0x10,%eax
80104342:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
80104349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010434c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104352:	05 80 35 11 80       	add    $0x80113580,%eax
80104357:	8b 40 08             	mov    0x8(%eax),%eax
8010435a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010435d:	75 25                	jne    80104384 <log_write+0x12e>
    logs[partitionNumber].lh.n++;
8010435f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104362:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104368:	05 80 35 11 80       	add    $0x80113580,%eax
8010436d:	8b 40 08             	mov    0x8(%eax),%eax
80104370:	8d 50 01             	lea    0x1(%eax),%edx
80104373:	8b 45 0c             	mov    0xc(%ebp),%eax
80104376:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010437c:	05 80 35 11 80       	add    $0x80113580,%eax
80104381:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
80104384:	8b 45 08             	mov    0x8(%ebp),%eax
80104387:	8b 00                	mov    (%eax),%eax
80104389:	83 c8 04             	or     $0x4,%eax
8010438c:	89 c2                	mov    %eax,%edx
8010438e:	8b 45 08             	mov    0x8(%ebp),%eax
80104391:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
80104393:	8b 45 0c             	mov    0xc(%ebp),%eax
80104396:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010439c:	05 40 35 11 80       	add    $0x80113540,%eax
801043a1:	83 ec 0c             	sub    $0xc,%esp
801043a4:	50                   	push   %eax
801043a5:	e8 44 18 00 00       	call   80105bee <release>
801043aa:	83 c4 10             	add    $0x10,%esp
}
801043ad:	90                   	nop
801043ae:	c9                   	leave  
801043af:	c3                   	ret    

801043b0 <v2p>:
801043b0:	55                   	push   %ebp
801043b1:	89 e5                	mov    %esp,%ebp
801043b3:	8b 45 08             	mov    0x8(%ebp),%eax
801043b6:	05 00 00 00 80       	add    $0x80000000,%eax
801043bb:	5d                   	pop    %ebp
801043bc:	c3                   	ret    

801043bd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801043bd:	55                   	push   %ebp
801043be:	89 e5                	mov    %esp,%ebp
801043c0:	8b 45 08             	mov    0x8(%ebp),%eax
801043c3:	05 00 00 00 80       	add    $0x80000000,%eax
801043c8:	5d                   	pop    %ebp
801043c9:	c3                   	ret    

801043ca <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801043ca:	55                   	push   %ebp
801043cb:	89 e5                	mov    %esp,%ebp
801043cd:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043d0:	8b 55 08             	mov    0x8(%ebp),%edx
801043d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801043d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043d9:	f0 87 02             	lock xchg %eax,(%edx)
801043dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043e2:	c9                   	leave  
801043e3:	c3                   	ret    

801043e4 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043e4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043e8:	83 e4 f0             	and    $0xfffffff0,%esp
801043eb:	ff 71 fc             	pushl  -0x4(%ecx)
801043ee:	55                   	push   %ebp
801043ef:	89 e5                	mov    %esp,%ebp
801043f1:	51                   	push   %ecx
801043f2:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801043f5:	83 ec 08             	sub    $0x8,%esp
801043f8:	68 00 00 40 80       	push   $0x80400000
801043fd:	68 5c 66 11 80       	push   $0x8011665c
80104402:	e8 34 ef ff ff       	call   8010333b <kinit1>
80104407:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010440a:	e8 cb 48 00 00       	call   80108cda <kvmalloc>
  mpinit();        // collect info about this machine
8010440f:	e8 26 04 00 00       	call   8010483a <mpinit>
  lapicinit();
80104414:	e8 a1 f2 ff ff       	call   801036ba <lapicinit>
  seginit();       // set up segments
80104419:	e8 65 42 00 00       	call   80108683 <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
8010441e:	e8 6d 06 00 00       	call   80104a90 <picinit>
  ioapicinit();    // another interrupt controller
80104423:	e8 08 ee ff ff       	call   80103230 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104428:	e8 ec c6 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
8010442d:	e8 ad 35 00 00       	call   801079df <uartinit>
  pinit();         // process table
80104432:	e8 56 0b 00 00       	call   80104f8d <pinit>
  tvinit();        // trap vectors
80104437:	e8 6d 31 00 00       	call   801075a9 <tvinit>
  binit();         // buffer cache
8010443c:	e8 f3 bb ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80104441:	e8 87 cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
80104446:	e8 dd e9 ff ff       	call   80102e28 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
8010444b:	a1 64 38 11 80       	mov    0x80113864,%eax
80104450:	85 c0                	test   %eax,%eax
80104452:	75 05                	jne    80104459 <main+0x75>
    timerinit();   // uniprocessor timer
80104454:	e8 ad 30 00 00       	call   80107506 <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80104459:	e8 7f 00 00 00       	call   801044dd <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010445e:	83 ec 08             	sub    $0x8,%esp
80104461:	68 00 00 00 8e       	push   $0x8e000000
80104466:	68 00 00 40 80       	push   $0x80400000
8010446b:	e8 04 ef ff ff       	call   80103374 <kinit2>
80104470:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
80104473:	e8 39 0c 00 00       	call   801050b1 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
80104478:	e8 1a 00 00 00       	call   80104497 <mpmain>

8010447d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010447d:	55                   	push   %ebp
8010447e:	89 e5                	mov    %esp,%ebp
80104480:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104483:	e8 6a 48 00 00       	call   80108cf2 <switchkvm>
  seginit();
80104488:	e8 f6 41 00 00       	call   80108683 <seginit>
  lapicinit();
8010448d:	e8 28 f2 ff ff       	call   801036ba <lapicinit>
  mpmain();
80104492:	e8 00 00 00 00       	call   80104497 <mpmain>

80104497 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104497:	55                   	push   %ebp
80104498:	89 e5                	mov    %esp,%ebp
8010449a:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010449d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044a3:	0f b6 00             	movzbl (%eax),%eax
801044a6:	0f b6 c0             	movzbl %al,%eax
801044a9:	83 ec 08             	sub    $0x8,%esp
801044ac:	50                   	push   %eax
801044ad:	68 dc 97 10 80       	push   $0x801097dc
801044b2:	e8 0f bf ff ff       	call   801003c6 <cprintf>
801044b7:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801044ba:	e8 60 32 00 00       	call   8010771f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801044bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044c5:	05 a8 00 00 00       	add    $0xa8,%eax
801044ca:	83 ec 08             	sub    $0x8,%esp
801044cd:	6a 01                	push   $0x1
801044cf:	50                   	push   %eax
801044d0:	e8 f5 fe ff ff       	call   801043ca <xchg>
801044d5:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044d8:	e8 ab 11 00 00       	call   80105688 <scheduler>

801044dd <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044dd:	55                   	push   %ebp
801044de:	89 e5                	mov    %esp,%ebp
801044e0:	53                   	push   %ebx
801044e1:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044e4:	68 00 70 00 00       	push   $0x7000
801044e9:	e8 cf fe ff ff       	call   801043bd <p2v>
801044ee:	83 c4 04             	add    $0x4,%esp
801044f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801044f4:	b8 8a 00 00 00       	mov    $0x8a,%eax
801044f9:	83 ec 04             	sub    $0x4,%esp
801044fc:	50                   	push   %eax
801044fd:	68 0c c5 10 80       	push   $0x8010c50c
80104502:	ff 75 f0             	pushl  -0x10(%ebp)
80104505:	e8 9f 19 00 00       	call   80105ea9 <memmove>
8010450a:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010450d:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
80104514:	e9 90 00 00 00       	jmp    801045a9 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80104519:	e8 ba f2 ff ff       	call   801037d8 <cpunum>
8010451e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104524:	05 80 38 11 80       	add    $0x80113880,%eax
80104529:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010452c:	74 73                	je     801045a1 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010452e:	e8 3f ef ff ff       	call   80103472 <kalloc>
80104533:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104539:	83 e8 04             	sub    $0x4,%eax
8010453c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010453f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104545:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454a:	83 e8 08             	sub    $0x8,%eax
8010454d:	c7 00 7d 44 10 80    	movl   $0x8010447d,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104556:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104559:	83 ec 0c             	sub    $0xc,%esp
8010455c:	68 00 b0 10 80       	push   $0x8010b000
80104561:	e8 4a fe ff ff       	call   801043b0 <v2p>
80104566:	83 c4 10             	add    $0x10,%esp
80104569:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010456b:	83 ec 0c             	sub    $0xc,%esp
8010456e:	ff 75 f0             	pushl  -0x10(%ebp)
80104571:	e8 3a fe ff ff       	call   801043b0 <v2p>
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	89 c2                	mov    %eax,%edx
8010457b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457e:	0f b6 00             	movzbl (%eax),%eax
80104581:	0f b6 c0             	movzbl %al,%eax
80104584:	83 ec 08             	sub    $0x8,%esp
80104587:	52                   	push   %edx
80104588:	50                   	push   %eax
80104589:	e8 c4 f2 ff ff       	call   80103852 <lapicstartap>
8010458e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104591:	90                   	nop
80104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104595:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010459b:	85 c0                	test   %eax,%eax
8010459d:	74 f3                	je     80104592 <startothers+0xb5>
8010459f:	eb 01                	jmp    801045a2 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801045a1:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801045a2:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801045a9:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801045ae:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801045b4:	05 80 38 11 80       	add    $0x80113880,%eax
801045b9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801045bc:	0f 87 57 ff ff ff    	ja     80104519 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801045c2:	90                   	nop
801045c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045c6:	c9                   	leave  
801045c7:	c3                   	ret    

801045c8 <p2v>:
801045c8:	55                   	push   %ebp
801045c9:	89 e5                	mov    %esp,%ebp
801045cb:	8b 45 08             	mov    0x8(%ebp),%eax
801045ce:	05 00 00 00 80       	add    $0x80000000,%eax
801045d3:	5d                   	pop    %ebp
801045d4:	c3                   	ret    

801045d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045d5:	55                   	push   %ebp
801045d6:	89 e5                	mov    %esp,%ebp
801045d8:	83 ec 14             	sub    $0x14,%esp
801045db:	8b 45 08             	mov    0x8(%ebp),%eax
801045de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045e6:	89 c2                	mov    %eax,%edx
801045e8:	ec                   	in     (%dx),%al
801045e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801045f0:	c9                   	leave  
801045f1:	c3                   	ret    

801045f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045f2:	55                   	push   %ebp
801045f3:	89 e5                	mov    %esp,%ebp
801045f5:	83 ec 08             	sub    $0x8,%esp
801045f8:	8b 55 08             	mov    0x8(%ebp),%edx
801045fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801045fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104602:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104605:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104609:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010460d:	ee                   	out    %al,(%dx)
}
8010460e:	90                   	nop
8010460f:	c9                   	leave  
80104610:	c3                   	ret    

80104611 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80104611:	55                   	push   %ebp
80104612:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104614:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104619:	89 c2                	mov    %eax,%edx
8010461b:	b8 80 38 11 80       	mov    $0x80113880,%eax
80104620:	29 c2                	sub    %eax,%edx
80104622:	89 d0                	mov    %edx,%eax
80104624:	c1 f8 02             	sar    $0x2,%eax
80104627:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010462d:	5d                   	pop    %ebp
8010462e:	c3                   	ret    

8010462f <sum>:

static uchar
sum(uchar *addr, int len)
{
8010462f:	55                   	push   %ebp
80104630:	89 e5                	mov    %esp,%ebp
80104632:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104635:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010463c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104643:	eb 15                	jmp    8010465a <sum+0x2b>
    sum += addr[i];
80104645:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104648:	8b 45 08             	mov    0x8(%ebp),%eax
8010464b:	01 d0                	add    %edx,%eax
8010464d:	0f b6 00             	movzbl (%eax),%eax
80104650:	0f b6 c0             	movzbl %al,%eax
80104653:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104656:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010465a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010465d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104660:	7c e3                	jl     80104645 <sum+0x16>
    sum += addr[i];
  return sum;
80104662:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104665:	c9                   	leave  
80104666:	c3                   	ret    

80104667 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104667:	55                   	push   %ebp
80104668:	89 e5                	mov    %esp,%ebp
8010466a:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010466d:	ff 75 08             	pushl  0x8(%ebp)
80104670:	e8 53 ff ff ff       	call   801045c8 <p2v>
80104675:	83 c4 04             	add    $0x4,%esp
80104678:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010467b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010467e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104681:	01 d0                	add    %edx,%eax
80104683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104686:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104689:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010468c:	eb 36                	jmp    801046c4 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010468e:	83 ec 04             	sub    $0x4,%esp
80104691:	6a 04                	push   $0x4
80104693:	68 f0 97 10 80       	push   $0x801097f0
80104698:	ff 75 f4             	pushl  -0xc(%ebp)
8010469b:	e8 b1 17 00 00       	call   80105e51 <memcmp>
801046a0:	83 c4 10             	add    $0x10,%esp
801046a3:	85 c0                	test   %eax,%eax
801046a5:	75 19                	jne    801046c0 <mpsearch1+0x59>
801046a7:	83 ec 08             	sub    $0x8,%esp
801046aa:	6a 10                	push   $0x10
801046ac:	ff 75 f4             	pushl  -0xc(%ebp)
801046af:	e8 7b ff ff ff       	call   8010462f <sum>
801046b4:	83 c4 10             	add    $0x10,%esp
801046b7:	84 c0                	test   %al,%al
801046b9:	75 05                	jne    801046c0 <mpsearch1+0x59>
      return (struct mp*)p;
801046bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046be:	eb 11                	jmp    801046d1 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801046c0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801046c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046ca:	72 c2                	jb     8010468e <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801046cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046d1:	c9                   	leave  
801046d2:	c3                   	ret    

801046d3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046d3:	55                   	push   %ebp
801046d4:	89 e5                	mov    %esp,%ebp
801046d6:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046d9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e3:	83 c0 0f             	add    $0xf,%eax
801046e6:	0f b6 00             	movzbl (%eax),%eax
801046e9:	0f b6 c0             	movzbl %al,%eax
801046ec:	c1 e0 08             	shl    $0x8,%eax
801046ef:	89 c2                	mov    %eax,%edx
801046f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f4:	83 c0 0e             	add    $0xe,%eax
801046f7:	0f b6 00             	movzbl (%eax),%eax
801046fa:	0f b6 c0             	movzbl %al,%eax
801046fd:	09 d0                	or     %edx,%eax
801046ff:	c1 e0 04             	shl    $0x4,%eax
80104702:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104705:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104709:	74 21                	je     8010472c <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010470b:	83 ec 08             	sub    $0x8,%esp
8010470e:	68 00 04 00 00       	push   $0x400
80104713:	ff 75 f0             	pushl  -0x10(%ebp)
80104716:	e8 4c ff ff ff       	call   80104667 <mpsearch1>
8010471b:	83 c4 10             	add    $0x10,%esp
8010471e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104721:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104725:	74 51                	je     80104778 <mpsearch+0xa5>
      return mp;
80104727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010472a:	eb 61                	jmp    8010478d <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010472c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472f:	83 c0 14             	add    $0x14,%eax
80104732:	0f b6 00             	movzbl (%eax),%eax
80104735:	0f b6 c0             	movzbl %al,%eax
80104738:	c1 e0 08             	shl    $0x8,%eax
8010473b:	89 c2                	mov    %eax,%edx
8010473d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104740:	83 c0 13             	add    $0x13,%eax
80104743:	0f b6 00             	movzbl (%eax),%eax
80104746:	0f b6 c0             	movzbl %al,%eax
80104749:	09 d0                	or     %edx,%eax
8010474b:	c1 e0 0a             	shl    $0xa,%eax
8010474e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104754:	2d 00 04 00 00       	sub    $0x400,%eax
80104759:	83 ec 08             	sub    $0x8,%esp
8010475c:	68 00 04 00 00       	push   $0x400
80104761:	50                   	push   %eax
80104762:	e8 00 ff ff ff       	call   80104667 <mpsearch1>
80104767:	83 c4 10             	add    $0x10,%esp
8010476a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010476d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104771:	74 05                	je     80104778 <mpsearch+0xa5>
      return mp;
80104773:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104776:	eb 15                	jmp    8010478d <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104778:	83 ec 08             	sub    $0x8,%esp
8010477b:	68 00 00 01 00       	push   $0x10000
80104780:	68 00 00 0f 00       	push   $0xf0000
80104785:	e8 dd fe ff ff       	call   80104667 <mpsearch1>
8010478a:	83 c4 10             	add    $0x10,%esp
}
8010478d:	c9                   	leave  
8010478e:	c3                   	ret    

8010478f <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010478f:	55                   	push   %ebp
80104790:	89 e5                	mov    %esp,%ebp
80104792:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104795:	e8 39 ff ff ff       	call   801046d3 <mpsearch>
8010479a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010479d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047a1:	74 0a                	je     801047ad <mpconfig+0x1e>
801047a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a6:	8b 40 04             	mov    0x4(%eax),%eax
801047a9:	85 c0                	test   %eax,%eax
801047ab:	75 0a                	jne    801047b7 <mpconfig+0x28>
    return 0;
801047ad:	b8 00 00 00 00       	mov    $0x0,%eax
801047b2:	e9 81 00 00 00       	jmp    80104838 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ba:	8b 40 04             	mov    0x4(%eax),%eax
801047bd:	83 ec 0c             	sub    $0xc,%esp
801047c0:	50                   	push   %eax
801047c1:	e8 02 fe ff ff       	call   801045c8 <p2v>
801047c6:	83 c4 10             	add    $0x10,%esp
801047c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801047cc:	83 ec 04             	sub    $0x4,%esp
801047cf:	6a 04                	push   $0x4
801047d1:	68 f5 97 10 80       	push   $0x801097f5
801047d6:	ff 75 f0             	pushl  -0x10(%ebp)
801047d9:	e8 73 16 00 00       	call   80105e51 <memcmp>
801047de:	83 c4 10             	add    $0x10,%esp
801047e1:	85 c0                	test   %eax,%eax
801047e3:	74 07                	je     801047ec <mpconfig+0x5d>
    return 0;
801047e5:	b8 00 00 00 00       	mov    $0x0,%eax
801047ea:	eb 4c                	jmp    80104838 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ef:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047f3:	3c 01                	cmp    $0x1,%al
801047f5:	74 12                	je     80104809 <mpconfig+0x7a>
801047f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047fa:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047fe:	3c 04                	cmp    $0x4,%al
80104800:	74 07                	je     80104809 <mpconfig+0x7a>
    return 0;
80104802:	b8 00 00 00 00       	mov    $0x0,%eax
80104807:	eb 2f                	jmp    80104838 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010480c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104810:	0f b7 c0             	movzwl %ax,%eax
80104813:	83 ec 08             	sub    $0x8,%esp
80104816:	50                   	push   %eax
80104817:	ff 75 f0             	pushl  -0x10(%ebp)
8010481a:	e8 10 fe ff ff       	call   8010462f <sum>
8010481f:	83 c4 10             	add    $0x10,%esp
80104822:	84 c0                	test   %al,%al
80104824:	74 07                	je     8010482d <mpconfig+0x9e>
    return 0;
80104826:	b8 00 00 00 00       	mov    $0x0,%eax
8010482b:	eb 0b                	jmp    80104838 <mpconfig+0xa9>
  *pmp = mp;
8010482d:	8b 45 08             	mov    0x8(%ebp),%eax
80104830:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104833:	89 10                	mov    %edx,(%eax)
  return conf;
80104835:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104838:	c9                   	leave  
80104839:	c3                   	ret    

8010483a <mpinit>:

void
mpinit(void)
{
8010483a:	55                   	push   %ebp
8010483b:	89 e5                	mov    %esp,%ebp
8010483d:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104840:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
80104847:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104850:	50                   	push   %eax
80104851:	e8 39 ff ff ff       	call   8010478f <mpconfig>
80104856:	83 c4 10             	add    $0x10,%esp
80104859:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010485c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104860:	0f 84 96 01 00 00    	je     801049fc <mpinit+0x1c2>
    return;
  ismp = 1;
80104866:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
8010486d:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104873:	8b 40 24             	mov    0x24(%eax),%eax
80104876:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010487b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010487e:	83 c0 2c             	add    $0x2c,%eax
80104881:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104887:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010488b:	0f b7 d0             	movzwl %ax,%edx
8010488e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104891:	01 d0                	add    %edx,%eax
80104893:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104896:	e9 f2 00 00 00       	jmp    8010498d <mpinit+0x153>
    switch(*p){
8010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489e:	0f b6 00             	movzbl (%eax),%eax
801048a1:	0f b6 c0             	movzbl %al,%eax
801048a4:	83 f8 04             	cmp    $0x4,%eax
801048a7:	0f 87 bc 00 00 00    	ja     80104969 <mpinit+0x12f>
801048ad:	8b 04 85 38 98 10 80 	mov    -0x7fef67c8(,%eax,4),%eax
801048b4:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801048b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801048bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048bf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048c3:	0f b6 d0             	movzbl %al,%edx
801048c6:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048cb:	39 c2                	cmp    %eax,%edx
801048cd:	74 2b                	je     801048fa <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048d2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048d6:	0f b6 d0             	movzbl %al,%edx
801048d9:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048de:	83 ec 04             	sub    $0x4,%esp
801048e1:	52                   	push   %edx
801048e2:	50                   	push   %eax
801048e3:	68 fa 97 10 80       	push   $0x801097fa
801048e8:	e8 d9 ba ff ff       	call   801003c6 <cprintf>
801048ed:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801048f0:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
801048f7:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801048fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048fd:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104901:	0f b6 c0             	movzbl %al,%eax
80104904:	83 e0 02             	and    $0x2,%eax
80104907:	85 c0                	test   %eax,%eax
80104909:	74 15                	je     80104920 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
8010490b:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104910:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104916:	05 80 38 11 80       	add    $0x80113880,%eax
8010491b:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104920:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104925:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
8010492b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104931:	05 80 38 11 80       	add    $0x80113880,%eax
80104936:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104938:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010493d:	83 c0 01             	add    $0x1,%eax
80104940:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
80104945:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104949:	eb 42                	jmp    8010498d <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010494b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104951:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104954:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104958:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
8010495d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104961:	eb 2a                	jmp    8010498d <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104963:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104967:	eb 24                	jmp    8010498d <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	0f b6 00             	movzbl (%eax),%eax
8010496f:	0f b6 c0             	movzbl %al,%eax
80104972:	83 ec 08             	sub    $0x8,%esp
80104975:	50                   	push   %eax
80104976:	68 18 98 10 80       	push   $0x80109818
8010497b:	e8 46 ba ff ff       	call   801003c6 <cprintf>
80104980:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104983:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
8010498a:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010498d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104990:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104993:	0f 82 02 ff ff ff    	jb     8010489b <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104999:	a1 64 38 11 80       	mov    0x80113864,%eax
8010499e:	85 c0                	test   %eax,%eax
801049a0:	75 1d                	jne    801049bf <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801049a2:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
801049a9:	00 00 00 
    lapic = 0;
801049ac:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
801049b3:	00 00 00 
    ioapicid = 0;
801049b6:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
801049bd:	eb 3e                	jmp    801049fd <mpinit+0x1c3>
  }

  if(mp->imcrp){
801049bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801049c6:	84 c0                	test   %al,%al
801049c8:	74 33                	je     801049fd <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801049ca:	83 ec 08             	sub    $0x8,%esp
801049cd:	6a 70                	push   $0x70
801049cf:	6a 22                	push   $0x22
801049d1:	e8 1c fc ff ff       	call   801045f2 <outb>
801049d6:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049d9:	83 ec 0c             	sub    $0xc,%esp
801049dc:	6a 23                	push   $0x23
801049de:	e8 f2 fb ff ff       	call   801045d5 <inb>
801049e3:	83 c4 10             	add    $0x10,%esp
801049e6:	83 c8 01             	or     $0x1,%eax
801049e9:	0f b6 c0             	movzbl %al,%eax
801049ec:	83 ec 08             	sub    $0x8,%esp
801049ef:	50                   	push   %eax
801049f0:	6a 23                	push   $0x23
801049f2:	e8 fb fb ff ff       	call   801045f2 <outb>
801049f7:	83 c4 10             	add    $0x10,%esp
801049fa:	eb 01                	jmp    801049fd <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801049fc:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801049fd:	c9                   	leave  
801049fe:	c3                   	ret    

801049ff <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801049ff:	55                   	push   %ebp
80104a00:	89 e5                	mov    %esp,%ebp
80104a02:	83 ec 08             	sub    $0x8,%esp
80104a05:	8b 55 08             	mov    0x8(%ebp),%edx
80104a08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a0b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104a0f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104a12:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104a16:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104a1a:	ee                   	out    %al,(%dx)
}
80104a1b:	90                   	nop
80104a1c:	c9                   	leave  
80104a1d:	c3                   	ret    

80104a1e <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104a1e:	55                   	push   %ebp
80104a1f:	89 e5                	mov    %esp,%ebp
80104a21:	83 ec 04             	sub    $0x4,%esp
80104a24:	8b 45 08             	mov    0x8(%ebp),%eax
80104a27:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104a2b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a2f:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a35:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a39:	0f b6 c0             	movzbl %al,%eax
80104a3c:	50                   	push   %eax
80104a3d:	6a 21                	push   $0x21
80104a3f:	e8 bb ff ff ff       	call   801049ff <outb>
80104a44:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a47:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a4b:	66 c1 e8 08          	shr    $0x8,%ax
80104a4f:	0f b6 c0             	movzbl %al,%eax
80104a52:	50                   	push   %eax
80104a53:	68 a1 00 00 00       	push   $0xa1
80104a58:	e8 a2 ff ff ff       	call   801049ff <outb>
80104a5d:	83 c4 08             	add    $0x8,%esp
}
80104a60:	90                   	nop
80104a61:	c9                   	leave  
80104a62:	c3                   	ret    

80104a63 <picenable>:

void
picenable(int irq)
{
80104a63:	55                   	push   %ebp
80104a64:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a66:	8b 45 08             	mov    0x8(%ebp),%eax
80104a69:	ba 01 00 00 00       	mov    $0x1,%edx
80104a6e:	89 c1                	mov    %eax,%ecx
80104a70:	d3 e2                	shl    %cl,%edx
80104a72:	89 d0                	mov    %edx,%eax
80104a74:	f7 d0                	not    %eax
80104a76:	89 c2                	mov    %eax,%edx
80104a78:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a7f:	21 d0                	and    %edx,%eax
80104a81:	0f b7 c0             	movzwl %ax,%eax
80104a84:	50                   	push   %eax
80104a85:	e8 94 ff ff ff       	call   80104a1e <picsetmask>
80104a8a:	83 c4 04             	add    $0x4,%esp
}
80104a8d:	90                   	nop
80104a8e:	c9                   	leave  
80104a8f:	c3                   	ret    

80104a90 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104a90:	55                   	push   %ebp
80104a91:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104a93:	68 ff 00 00 00       	push   $0xff
80104a98:	6a 21                	push   $0x21
80104a9a:	e8 60 ff ff ff       	call   801049ff <outb>
80104a9f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104aa2:	68 ff 00 00 00       	push   $0xff
80104aa7:	68 a1 00 00 00       	push   $0xa1
80104aac:	e8 4e ff ff ff       	call   801049ff <outb>
80104ab1:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104ab4:	6a 11                	push   $0x11
80104ab6:	6a 20                	push   $0x20
80104ab8:	e8 42 ff ff ff       	call   801049ff <outb>
80104abd:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104ac0:	6a 20                	push   $0x20
80104ac2:	6a 21                	push   $0x21
80104ac4:	e8 36 ff ff ff       	call   801049ff <outb>
80104ac9:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104acc:	6a 04                	push   $0x4
80104ace:	6a 21                	push   $0x21
80104ad0:	e8 2a ff ff ff       	call   801049ff <outb>
80104ad5:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104ad8:	6a 03                	push   $0x3
80104ada:	6a 21                	push   $0x21
80104adc:	e8 1e ff ff ff       	call   801049ff <outb>
80104ae1:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104ae4:	6a 11                	push   $0x11
80104ae6:	68 a0 00 00 00       	push   $0xa0
80104aeb:	e8 0f ff ff ff       	call   801049ff <outb>
80104af0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104af3:	6a 28                	push   $0x28
80104af5:	68 a1 00 00 00       	push   $0xa1
80104afa:	e8 00 ff ff ff       	call   801049ff <outb>
80104aff:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104b02:	6a 02                	push   $0x2
80104b04:	68 a1 00 00 00       	push   $0xa1
80104b09:	e8 f1 fe ff ff       	call   801049ff <outb>
80104b0e:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104b11:	6a 03                	push   $0x3
80104b13:	68 a1 00 00 00       	push   $0xa1
80104b18:	e8 e2 fe ff ff       	call   801049ff <outb>
80104b1d:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104b20:	6a 68                	push   $0x68
80104b22:	6a 20                	push   $0x20
80104b24:	e8 d6 fe ff ff       	call   801049ff <outb>
80104b29:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104b2c:	6a 0a                	push   $0xa
80104b2e:	6a 20                	push   $0x20
80104b30:	e8 ca fe ff ff       	call   801049ff <outb>
80104b35:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b38:	6a 68                	push   $0x68
80104b3a:	68 a0 00 00 00       	push   $0xa0
80104b3f:	e8 bb fe ff ff       	call   801049ff <outb>
80104b44:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b47:	6a 0a                	push   $0xa
80104b49:	68 a0 00 00 00       	push   $0xa0
80104b4e:	e8 ac fe ff ff       	call   801049ff <outb>
80104b53:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b56:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b5d:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b61:	74 13                	je     80104b76 <picinit+0xe6>
    picsetmask(irqmask);
80104b63:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b6a:	0f b7 c0             	movzwl %ax,%eax
80104b6d:	50                   	push   %eax
80104b6e:	e8 ab fe ff ff       	call   80104a1e <picsetmask>
80104b73:	83 c4 04             	add    $0x4,%esp
}
80104b76:	90                   	nop
80104b77:	c9                   	leave  
80104b78:	c3                   	ret    

80104b79 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b79:	55                   	push   %ebp
80104b7a:	89 e5                	mov    %esp,%ebp
80104b7c:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b92:	8b 10                	mov    (%eax),%edx
80104b94:	8b 45 08             	mov    0x8(%ebp),%eax
80104b97:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104b99:	e8 4d c4 ff ff       	call   80100feb <filealloc>
80104b9e:	89 c2                	mov    %eax,%edx
80104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba3:	89 10                	mov    %edx,(%eax)
80104ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba8:	8b 00                	mov    (%eax),%eax
80104baa:	85 c0                	test   %eax,%eax
80104bac:	0f 84 cb 00 00 00    	je     80104c7d <pipealloc+0x104>
80104bb2:	e8 34 c4 ff ff       	call   80100feb <filealloc>
80104bb7:	89 c2                	mov    %eax,%edx
80104bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bbc:	89 10                	mov    %edx,(%eax)
80104bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc1:	8b 00                	mov    (%eax),%eax
80104bc3:	85 c0                	test   %eax,%eax
80104bc5:	0f 84 b2 00 00 00    	je     80104c7d <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104bcb:	e8 a2 e8 ff ff       	call   80103472 <kalloc>
80104bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bd7:	0f 84 9f 00 00 00    	je     80104c7c <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104be7:	00 00 00 
  p->writeopen = 1;
80104bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bed:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104bf4:	00 00 00 
  p->nwrite = 0;
80104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfa:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104c01:	00 00 00 
  p->nread = 0;
80104c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c07:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104c0e:	00 00 00 
  initlock(&p->lock, "pipe");
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	83 ec 08             	sub    $0x8,%esp
80104c17:	68 4c 98 10 80       	push   $0x8010984c
80104c1c:	50                   	push   %eax
80104c1d:	e8 43 0f 00 00       	call   80105b65 <initlock>
80104c22:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104c25:	8b 45 08             	mov    0x8(%ebp),%eax
80104c28:	8b 00                	mov    (%eax),%eax
80104c2a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c30:	8b 45 08             	mov    0x8(%ebp),%eax
80104c33:	8b 00                	mov    (%eax),%eax
80104c35:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c39:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3c:	8b 00                	mov    (%eax),%eax
80104c3e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c42:	8b 45 08             	mov    0x8(%ebp),%eax
80104c45:	8b 00                	mov    (%eax),%eax
80104c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c4a:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c50:	8b 00                	mov    (%eax),%eax
80104c52:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c58:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c5b:	8b 00                	mov    (%eax),%eax
80104c5d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c61:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c64:	8b 00                	mov    (%eax),%eax
80104c66:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c6d:	8b 00                	mov    (%eax),%eax
80104c6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c72:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c75:	b8 00 00 00 00       	mov    $0x0,%eax
80104c7a:	eb 4e                	jmp    80104cca <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c7c:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c81:	74 0e                	je     80104c91 <pipealloc+0x118>
    kfree((char*)p);
80104c83:	83 ec 0c             	sub    $0xc,%esp
80104c86:	ff 75 f4             	pushl  -0xc(%ebp)
80104c89:	e8 47 e7 ff ff       	call   801033d5 <kfree>
80104c8e:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104c91:	8b 45 08             	mov    0x8(%ebp),%eax
80104c94:	8b 00                	mov    (%eax),%eax
80104c96:	85 c0                	test   %eax,%eax
80104c98:	74 11                	je     80104cab <pipealloc+0x132>
    fileclose(*f0);
80104c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9d:	8b 00                	mov    (%eax),%eax
80104c9f:	83 ec 0c             	sub    $0xc,%esp
80104ca2:	50                   	push   %eax
80104ca3:	e8 01 c4 ff ff       	call   801010a9 <fileclose>
80104ca8:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104cab:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cae:	8b 00                	mov    (%eax),%eax
80104cb0:	85 c0                	test   %eax,%eax
80104cb2:	74 11                	je     80104cc5 <pipealloc+0x14c>
    fileclose(*f1);
80104cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb7:	8b 00                	mov    (%eax),%eax
80104cb9:	83 ec 0c             	sub    $0xc,%esp
80104cbc:	50                   	push   %eax
80104cbd:	e8 e7 c3 ff ff       	call   801010a9 <fileclose>
80104cc2:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cca:	c9                   	leave  
80104ccb:	c3                   	ret    

80104ccc <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104ccc:	55                   	push   %ebp
80104ccd:	89 e5                	mov    %esp,%ebp
80104ccf:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd5:	83 ec 0c             	sub    $0xc,%esp
80104cd8:	50                   	push   %eax
80104cd9:	e8 a9 0e 00 00       	call   80105b87 <acquire>
80104cde:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104ce1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ce5:	74 23                	je     80104d0a <pipeclose+0x3e>
    p->writeopen = 0;
80104ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cea:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104cf1:	00 00 00 
    wakeup(&p->nread);
80104cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf7:	05 34 02 00 00       	add    $0x234,%eax
80104cfc:	83 ec 0c             	sub    $0xc,%esp
80104cff:	50                   	push   %eax
80104d00:	e8 74 0c 00 00       	call   80105979 <wakeup>
80104d05:	83 c4 10             	add    $0x10,%esp
80104d08:	eb 21                	jmp    80104d2b <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104d14:	00 00 00 
    wakeup(&p->nwrite);
80104d17:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1a:	05 38 02 00 00       	add    $0x238,%eax
80104d1f:	83 ec 0c             	sub    $0xc,%esp
80104d22:	50                   	push   %eax
80104d23:	e8 51 0c 00 00       	call   80105979 <wakeup>
80104d28:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d34:	85 c0                	test   %eax,%eax
80104d36:	75 2c                	jne    80104d64 <pipeclose+0x98>
80104d38:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d41:	85 c0                	test   %eax,%eax
80104d43:	75 1f                	jne    80104d64 <pipeclose+0x98>
    release(&p->lock);
80104d45:	8b 45 08             	mov    0x8(%ebp),%eax
80104d48:	83 ec 0c             	sub    $0xc,%esp
80104d4b:	50                   	push   %eax
80104d4c:	e8 9d 0e 00 00       	call   80105bee <release>
80104d51:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d54:	83 ec 0c             	sub    $0xc,%esp
80104d57:	ff 75 08             	pushl  0x8(%ebp)
80104d5a:	e8 76 e6 ff ff       	call   801033d5 <kfree>
80104d5f:	83 c4 10             	add    $0x10,%esp
80104d62:	eb 0f                	jmp    80104d73 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d64:	8b 45 08             	mov    0x8(%ebp),%eax
80104d67:	83 ec 0c             	sub    $0xc,%esp
80104d6a:	50                   	push   %eax
80104d6b:	e8 7e 0e 00 00       	call   80105bee <release>
80104d70:	83 c4 10             	add    $0x10,%esp
}
80104d73:	90                   	nop
80104d74:	c9                   	leave  
80104d75:	c3                   	ret    

80104d76 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d76:	55                   	push   %ebp
80104d77:	89 e5                	mov    %esp,%ebp
80104d79:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7f:	83 ec 0c             	sub    $0xc,%esp
80104d82:	50                   	push   %eax
80104d83:	e8 ff 0d 00 00       	call   80105b87 <acquire>
80104d88:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d92:	e9 ad 00 00 00       	jmp    80104e44 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104d97:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104da0:	85 c0                	test   %eax,%eax
80104da2:	74 0d                	je     80104db1 <pipewrite+0x3b>
80104da4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104daa:	8b 40 24             	mov    0x24(%eax),%eax
80104dad:	85 c0                	test   %eax,%eax
80104daf:	74 19                	je     80104dca <pipewrite+0x54>
        release(&p->lock);
80104db1:	8b 45 08             	mov    0x8(%ebp),%eax
80104db4:	83 ec 0c             	sub    $0xc,%esp
80104db7:	50                   	push   %eax
80104db8:	e8 31 0e 00 00       	call   80105bee <release>
80104dbd:	83 c4 10             	add    $0x10,%esp
        return -1;
80104dc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dc5:	e9 a8 00 00 00       	jmp    80104e72 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104dca:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcd:	05 34 02 00 00       	add    $0x234,%eax
80104dd2:	83 ec 0c             	sub    $0xc,%esp
80104dd5:	50                   	push   %eax
80104dd6:	e8 9e 0b 00 00       	call   80105979 <wakeup>
80104ddb:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104dde:	8b 45 08             	mov    0x8(%ebp),%eax
80104de1:	8b 55 08             	mov    0x8(%ebp),%edx
80104de4:	81 c2 38 02 00 00    	add    $0x238,%edx
80104dea:	83 ec 08             	sub    $0x8,%esp
80104ded:	50                   	push   %eax
80104dee:	52                   	push   %edx
80104def:	e8 9a 0a 00 00       	call   8010588e <sleep>
80104df4:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104df7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfa:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104e00:	8b 45 08             	mov    0x8(%ebp),%eax
80104e03:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104e09:	05 00 02 00 00       	add    $0x200,%eax
80104e0e:	39 c2                	cmp    %eax,%edx
80104e10:	74 85                	je     80104d97 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104e12:	8b 45 08             	mov    0x8(%ebp),%eax
80104e15:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e1b:	8d 48 01             	lea    0x1(%eax),%ecx
80104e1e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e21:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104e27:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e2c:	89 c1                	mov    %eax,%ecx
80104e2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e31:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e34:	01 d0                	add    %edx,%eax
80104e36:	0f b6 10             	movzbl (%eax),%edx
80104e39:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e47:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e4a:	7c ab                	jl     80104df7 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4f:	05 34 02 00 00       	add    $0x234,%eax
80104e54:	83 ec 0c             	sub    $0xc,%esp
80104e57:	50                   	push   %eax
80104e58:	e8 1c 0b 00 00       	call   80105979 <wakeup>
80104e5d:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e60:	8b 45 08             	mov    0x8(%ebp),%eax
80104e63:	83 ec 0c             	sub    $0xc,%esp
80104e66:	50                   	push   %eax
80104e67:	e8 82 0d 00 00       	call   80105bee <release>
80104e6c:	83 c4 10             	add    $0x10,%esp
  return n;
80104e6f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e72:	c9                   	leave  
80104e73:	c3                   	ret    

80104e74 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e74:	55                   	push   %ebp
80104e75:	89 e5                	mov    %esp,%ebp
80104e77:	53                   	push   %ebx
80104e78:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7e:	83 ec 0c             	sub    $0xc,%esp
80104e81:	50                   	push   %eax
80104e82:	e8 00 0d 00 00       	call   80105b87 <acquire>
80104e87:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e8a:	eb 3f                	jmp    80104ecb <piperead+0x57>
    if(proc->killed){
80104e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e92:	8b 40 24             	mov    0x24(%eax),%eax
80104e95:	85 c0                	test   %eax,%eax
80104e97:	74 19                	je     80104eb2 <piperead+0x3e>
      release(&p->lock);
80104e99:	8b 45 08             	mov    0x8(%ebp),%eax
80104e9c:	83 ec 0c             	sub    $0xc,%esp
80104e9f:	50                   	push   %eax
80104ea0:	e8 49 0d 00 00       	call   80105bee <release>
80104ea5:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ead:	e9 bf 00 00 00       	jmp    80104f71 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb5:	8b 55 08             	mov    0x8(%ebp),%edx
80104eb8:	81 c2 34 02 00 00    	add    $0x234,%edx
80104ebe:	83 ec 08             	sub    $0x8,%esp
80104ec1:	50                   	push   %eax
80104ec2:	52                   	push   %edx
80104ec3:	e8 c6 09 00 00       	call   8010588e <sleep>
80104ec8:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ece:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104edd:	39 c2                	cmp    %eax,%edx
80104edf:	75 0d                	jne    80104eee <piperead+0x7a>
80104ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104eea:	85 c0                	test   %eax,%eax
80104eec:	75 9e                	jne    80104e8c <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104eee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ef5:	eb 49                	jmp    80104f40 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80104efa:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104f00:	8b 45 08             	mov    0x8(%ebp),%eax
80104f03:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104f09:	39 c2                	cmp    %eax,%edx
80104f0b:	74 3d                	je     80104f4a <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104f0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f13:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104f16:	8b 45 08             	mov    0x8(%ebp),%eax
80104f19:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104f1f:	8d 48 01             	lea    0x1(%eax),%ecx
80104f22:	8b 55 08             	mov    0x8(%ebp),%edx
80104f25:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104f2b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f30:	89 c2                	mov    %eax,%edx
80104f32:	8b 45 08             	mov    0x8(%ebp),%eax
80104f35:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f3a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f43:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f46:	7c af                	jl     80104ef7 <piperead+0x83>
80104f48:	eb 01                	jmp    80104f4b <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f4a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4e:	05 38 02 00 00       	add    $0x238,%eax
80104f53:	83 ec 0c             	sub    $0xc,%esp
80104f56:	50                   	push   %eax
80104f57:	e8 1d 0a 00 00       	call   80105979 <wakeup>
80104f5c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f62:	83 ec 0c             	sub    $0xc,%esp
80104f65:	50                   	push   %eax
80104f66:	e8 83 0c 00 00       	call   80105bee <release>
80104f6b:	83 c4 10             	add    $0x10,%esp
  return i;
80104f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f74:	c9                   	leave  
80104f75:	c3                   	ret    

80104f76 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f76:	55                   	push   %ebp
80104f77:	89 e5                	mov    %esp,%ebp
80104f79:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f7c:	9c                   	pushf  
80104f7d:	58                   	pop    %eax
80104f7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f84:	c9                   	leave  
80104f85:	c3                   	ret    

80104f86 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f86:	55                   	push   %ebp
80104f87:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f89:	fb                   	sti    
}
80104f8a:	90                   	nop
80104f8b:	5d                   	pop    %ebp
80104f8c:	c3                   	ret    

80104f8d <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104f93:	83 ec 08             	sub    $0x8,%esp
80104f96:	68 51 98 10 80       	push   $0x80109851
80104f9b:	68 80 3e 11 80       	push   $0x80113e80
80104fa0:	e8 c0 0b 00 00       	call   80105b65 <initlock>
80104fa5:	83 c4 10             	add    $0x10,%esp
}
80104fa8:	90                   	nop
80104fa9:	c9                   	leave  
80104faa:	c3                   	ret    

80104fab <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104fab:	55                   	push   %ebp
80104fac:	89 e5                	mov    %esp,%ebp
80104fae:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104fb1:	83 ec 0c             	sub    $0xc,%esp
80104fb4:	68 80 3e 11 80       	push   $0x80113e80
80104fb9:	e8 c9 0b 00 00       	call   80105b87 <acquire>
80104fbe:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fc1:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104fc8:	eb 0e                	jmp    80104fd8 <allocproc+0x2d>
    if(p->state == UNUSED)
80104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcd:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd0:	85 c0                	test   %eax,%eax
80104fd2:	74 27                	je     80104ffb <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fd4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fd8:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fdf:	72 e9                	jb     80104fca <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104fe1:	83 ec 0c             	sub    $0xc,%esp
80104fe4:	68 80 3e 11 80       	push   $0x80113e80
80104fe9:	e8 00 0c 00 00       	call   80105bee <release>
80104fee:	83 c4 10             	add    $0x10,%esp
  return 0;
80104ff1:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff6:	e9 b4 00 00 00       	jmp    801050af <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104ffb:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fff:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80105006:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010500b:	8d 50 01             	lea    0x1(%eax),%edx
8010500e:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80105014:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105017:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010501a:	83 ec 0c             	sub    $0xc,%esp
8010501d:	68 80 3e 11 80       	push   $0x80113e80
80105022:	e8 c7 0b 00 00       	call   80105bee <release>
80105027:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010502a:	e8 43 e4 ff ff       	call   80103472 <kalloc>
8010502f:	89 c2                	mov    %eax,%edx
80105031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105034:	89 50 08             	mov    %edx,0x8(%eax)
80105037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503a:	8b 40 08             	mov    0x8(%eax),%eax
8010503d:	85 c0                	test   %eax,%eax
8010503f:	75 11                	jne    80105052 <allocproc+0xa7>
    p->state = UNUSED;
80105041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105044:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010504b:	b8 00 00 00 00       	mov    $0x0,%eax
80105050:	eb 5d                	jmp    801050af <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80105052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105055:	8b 40 08             	mov    0x8(%eax),%eax
80105058:	05 00 10 00 00       	add    $0x1000,%eax
8010505d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105060:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80105064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105067:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010506a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010506d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80105071:	ba 63 75 10 80       	mov    $0x80107563,%edx
80105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105079:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010507b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105082:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105085:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80105088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010508e:	83 ec 04             	sub    $0x4,%esp
80105091:	6a 14                	push   $0x14
80105093:	6a 00                	push   $0x0
80105095:	50                   	push   %eax
80105096:	e8 4f 0d 00 00       	call   80105dea <memset>
8010509b:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010509e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a1:	8b 40 1c             	mov    0x1c(%eax),%eax
801050a4:	ba 24 58 10 80       	mov    $0x80105824,%edx
801050a9:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801050ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801050af:	c9                   	leave  
801050b0:	c3                   	ret    

801050b1 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801050b1:	55                   	push   %ebp
801050b2:	89 e5                	mov    %esp,%ebp
801050b4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801050b7:	e8 ef fe ff ff       	call   80104fab <allocproc>
801050bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801050bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c2:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801050c7:	e8 5c 3b 00 00       	call   80108c28 <setupkvm>
801050cc:	89 c2                	mov    %eax,%edx
801050ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d1:	89 50 04             	mov    %edx,0x4(%eax)
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	8b 40 04             	mov    0x4(%eax),%eax
801050da:	85 c0                	test   %eax,%eax
801050dc:	75 0d                	jne    801050eb <userinit+0x3a>
    panic("userinit: out of memory?");
801050de:	83 ec 0c             	sub    $0xc,%esp
801050e1:	68 58 98 10 80       	push   $0x80109858
801050e6:	e8 7b b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050eb:	ba 2c 00 00 00       	mov    $0x2c,%edx
801050f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f3:	8b 40 04             	mov    0x4(%eax),%eax
801050f6:	83 ec 04             	sub    $0x4,%esp
801050f9:	52                   	push   %edx
801050fa:	68 e0 c4 10 80       	push   $0x8010c4e0
801050ff:	50                   	push   %eax
80105100:	e8 7d 3d 00 00       	call   80108e82 <inituvm>
80105105:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80105108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80105111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105114:	8b 40 18             	mov    0x18(%eax),%eax
80105117:	83 ec 04             	sub    $0x4,%esp
8010511a:	6a 4c                	push   $0x4c
8010511c:	6a 00                	push   $0x0
8010511e:	50                   	push   %eax
8010511f:	e8 c6 0c 00 00       	call   80105dea <memset>
80105124:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80105127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512a:	8b 40 18             	mov    0x18(%eax),%eax
8010512d:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105136:	8b 40 18             	mov    0x18(%eax),%eax
80105139:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010513f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105142:	8b 40 18             	mov    0x18(%eax),%eax
80105145:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105148:	8b 52 18             	mov    0x18(%edx),%edx
8010514b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010514f:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80105153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105156:	8b 40 18             	mov    0x18(%eax),%eax
80105159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010515c:	8b 52 18             	mov    0x18(%edx),%edx
8010515f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105163:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80105167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516a:	8b 40 18             	mov    0x18(%eax),%eax
8010516d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80105174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105177:	8b 40 18             	mov    0x18(%eax),%eax
8010517a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80105181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105184:	8b 40 18             	mov    0x18(%eax),%eax
80105187:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010518e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105191:	83 c0 6c             	add    $0x6c,%eax
80105194:	83 ec 04             	sub    $0x4,%esp
80105197:	6a 10                	push   $0x10
80105199:	68 71 98 10 80       	push   $0x80109871
8010519e:	50                   	push   %eax
8010519f:	e8 49 0e 00 00       	call   80105fed <safestrcpy>
801051a4:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801051a7:	83 ec 0c             	sub    $0xc,%esp
801051aa:	68 7a 98 10 80       	push   $0x8010987a
801051af:	e8 57 db ff ff       	call   80102d0b <namei>
801051b4:	83 c4 10             	add    $0x10,%esp
801051b7:	89 c2                	mov    %eax,%edx
801051b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bc:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
801051bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801051c9:	90                   	nop
801051ca:	c9                   	leave  
801051cb:	c3                   	ret    

801051cc <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801051cc:	55                   	push   %ebp
801051cd:	89 e5                	mov    %esp,%ebp
801051cf:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d8:	8b 00                	mov    (%eax),%eax
801051da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051e1:	7e 31                	jle    80105214 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051e3:	8b 55 08             	mov    0x8(%ebp),%edx
801051e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e9:	01 c2                	add    %eax,%edx
801051eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051f1:	8b 40 04             	mov    0x4(%eax),%eax
801051f4:	83 ec 04             	sub    $0x4,%esp
801051f7:	52                   	push   %edx
801051f8:	ff 75 f4             	pushl  -0xc(%ebp)
801051fb:	50                   	push   %eax
801051fc:	e8 ce 3d 00 00       	call   80108fcf <allocuvm>
80105201:	83 c4 10             	add    $0x10,%esp
80105204:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105207:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010520b:	75 3e                	jne    8010524b <growproc+0x7f>
      return -1;
8010520d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105212:	eb 59                	jmp    8010526d <growproc+0xa1>
  } else if(n < 0){
80105214:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105218:	79 31                	jns    8010524b <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010521a:	8b 55 08             	mov    0x8(%ebp),%edx
8010521d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105220:	01 c2                	add    %eax,%edx
80105222:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105228:	8b 40 04             	mov    0x4(%eax),%eax
8010522b:	83 ec 04             	sub    $0x4,%esp
8010522e:	52                   	push   %edx
8010522f:	ff 75 f4             	pushl  -0xc(%ebp)
80105232:	50                   	push   %eax
80105233:	e8 60 3e 00 00       	call   80109098 <deallocuvm>
80105238:	83 c4 10             	add    $0x10,%esp
8010523b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010523e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105242:	75 07                	jne    8010524b <growproc+0x7f>
      return -1;
80105244:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105249:	eb 22                	jmp    8010526d <growproc+0xa1>
  }
  proc->sz = sz;
8010524b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105251:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105254:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80105256:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010525c:	83 ec 0c             	sub    $0xc,%esp
8010525f:	50                   	push   %eax
80105260:	e8 aa 3a 00 00       	call   80108d0f <switchuvm>
80105265:	83 c4 10             	add    $0x10,%esp
  return 0;
80105268:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010526d:	c9                   	leave  
8010526e:	c3                   	ret    

8010526f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010526f:	55                   	push   %ebp
80105270:	89 e5                	mov    %esp,%ebp
80105272:	57                   	push   %edi
80105273:	56                   	push   %esi
80105274:	53                   	push   %ebx
80105275:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80105278:	e8 2e fd ff ff       	call   80104fab <allocproc>
8010527d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105280:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80105284:	75 0a                	jne    80105290 <fork+0x21>
    return -1;
80105286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528b:	e9 68 01 00 00       	jmp    801053f8 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80105290:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105296:	8b 10                	mov    (%eax),%edx
80105298:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010529e:	8b 40 04             	mov    0x4(%eax),%eax
801052a1:	83 ec 08             	sub    $0x8,%esp
801052a4:	52                   	push   %edx
801052a5:	50                   	push   %eax
801052a6:	e8 8b 3f 00 00       	call   80109236 <copyuvm>
801052ab:	83 c4 10             	add    $0x10,%esp
801052ae:	89 c2                	mov    %eax,%edx
801052b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052b3:	89 50 04             	mov    %edx,0x4(%eax)
801052b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052b9:	8b 40 04             	mov    0x4(%eax),%eax
801052bc:	85 c0                	test   %eax,%eax
801052be:	75 30                	jne    801052f0 <fork+0x81>
    kfree(np->kstack);
801052c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052c3:	8b 40 08             	mov    0x8(%eax),%eax
801052c6:	83 ec 0c             	sub    $0xc,%esp
801052c9:	50                   	push   %eax
801052ca:	e8 06 e1 ff ff       	call   801033d5 <kfree>
801052cf:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052d5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052eb:	e9 08 01 00 00       	jmp    801053f8 <fork+0x189>
  }
  np->sz = proc->sz;
801052f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f6:	8b 10                	mov    (%eax),%edx
801052f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052fb:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801052fd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105304:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105307:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010530a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010530d:	8b 50 18             	mov    0x18(%eax),%edx
80105310:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105316:	8b 40 18             	mov    0x18(%eax),%eax
80105319:	89 c3                	mov    %eax,%ebx
8010531b:	b8 13 00 00 00       	mov    $0x13,%eax
80105320:	89 d7                	mov    %edx,%edi
80105322:	89 de                	mov    %ebx,%esi
80105324:	89 c1                	mov    %eax,%ecx
80105326:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105328:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010532b:	8b 40 18             	mov    0x18(%eax),%eax
8010532e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105335:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010533c:	eb 43                	jmp    80105381 <fork+0x112>
    if(proc->ofile[i])
8010533e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105344:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105347:	83 c2 08             	add    $0x8,%edx
8010534a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010534e:	85 c0                	test   %eax,%eax
80105350:	74 2b                	je     8010537d <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80105352:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105358:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010535b:	83 c2 08             	add    $0x8,%edx
8010535e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105362:	83 ec 0c             	sub    $0xc,%esp
80105365:	50                   	push   %eax
80105366:	e8 ed bc ff ff       	call   80101058 <filedup>
8010536b:	83 c4 10             	add    $0x10,%esp
8010536e:	89 c1                	mov    %eax,%ecx
80105370:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105373:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105376:	83 c2 08             	add    $0x8,%edx
80105379:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010537d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105381:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105385:	7e b7                	jle    8010533e <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105387:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538d:	8b 40 68             	mov    0x68(%eax),%eax
80105390:	83 ec 0c             	sub    $0xc,%esp
80105393:	50                   	push   %eax
80105394:	e8 1f cb ff ff       	call   80101eb8 <idup>
80105399:	83 c4 10             	add    $0x10,%esp
8010539c:	89 c2                	mov    %eax,%edx
8010539e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053a1:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801053a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053aa:	8d 50 6c             	lea    0x6c(%eax),%edx
801053ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053b0:	83 c0 6c             	add    $0x6c,%eax
801053b3:	83 ec 04             	sub    $0x4,%esp
801053b6:	6a 10                	push   $0x10
801053b8:	52                   	push   %edx
801053b9:	50                   	push   %eax
801053ba:	e8 2e 0c 00 00       	call   80105fed <safestrcpy>
801053bf:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053c5:	8b 40 10             	mov    0x10(%eax),%eax
801053c8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053cb:	83 ec 0c             	sub    $0xc,%esp
801053ce:	68 80 3e 11 80       	push   $0x80113e80
801053d3:	e8 af 07 00 00       	call   80105b87 <acquire>
801053d8:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053de:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053e5:	83 ec 0c             	sub    $0xc,%esp
801053e8:	68 80 3e 11 80       	push   $0x80113e80
801053ed:	e8 fc 07 00 00       	call   80105bee <release>
801053f2:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801053f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801053f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053fb:	5b                   	pop    %ebx
801053fc:	5e                   	pop    %esi
801053fd:	5f                   	pop    %edi
801053fe:	5d                   	pop    %ebp
801053ff:	c3                   	ret    

80105400 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105400:	55                   	push   %ebp
80105401:	89 e5                	mov    %esp,%ebp
80105403:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105406:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010540d:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105412:	39 c2                	cmp    %eax,%edx
80105414:	75 0d                	jne    80105423 <exit+0x23>
    panic("init exiting");
80105416:	83 ec 0c             	sub    $0xc,%esp
80105419:	68 7c 98 10 80       	push   $0x8010987c
8010541e:	e8 43 b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105423:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010542a:	eb 48                	jmp    80105474 <exit+0x74>
    if(proc->ofile[fd]){
8010542c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105432:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105435:	83 c2 08             	add    $0x8,%edx
80105438:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010543c:	85 c0                	test   %eax,%eax
8010543e:	74 30                	je     80105470 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105440:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105446:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105449:	83 c2 08             	add    $0x8,%edx
8010544c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105450:	83 ec 0c             	sub    $0xc,%esp
80105453:	50                   	push   %eax
80105454:	e8 50 bc ff ff       	call   801010a9 <fileclose>
80105459:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010545c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105462:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105465:	83 c2 08             	add    $0x8,%edx
80105468:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010546f:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105470:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105474:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105478:	7e b2                	jle    8010542c <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
8010547a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105480:	8b 40 68             	mov    0x68(%eax),%eax
80105483:	8b 40 50             	mov    0x50(%eax),%eax
80105486:	8b 40 14             	mov    0x14(%eax),%eax
80105489:	83 ec 0c             	sub    $0xc,%esp
8010548c:	50                   	push   %eax
8010548d:	e8 17 ea ff ff       	call   80103ea9 <begin_op>
80105492:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80105495:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549b:	8b 40 68             	mov    0x68(%eax),%eax
8010549e:	83 ec 0c             	sub    $0xc,%esp
801054a1:	50                   	push   %eax
801054a2:	e8 5e cc ff ff       	call   80102105 <iput>
801054a7:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
801054aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b0:	8b 40 68             	mov    0x68(%eax),%eax
801054b3:	8b 40 50             	mov    0x50(%eax),%eax
801054b6:	8b 40 14             	mov    0x14(%eax),%eax
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	50                   	push   %eax
801054bd:	e8 ee ea ff ff       	call   80103fb0 <end_op>
801054c2:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
801054c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054cb:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054d2:	83 ec 0c             	sub    $0xc,%esp
801054d5:	68 80 3e 11 80       	push   $0x80113e80
801054da:	e8 a8 06 00 00       	call   80105b87 <acquire>
801054df:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e8:	8b 40 14             	mov    0x14(%eax),%eax
801054eb:	83 ec 0c             	sub    $0xc,%esp
801054ee:	50                   	push   %eax
801054ef:	e8 46 04 00 00       	call   8010593a <wakeup1>
801054f4:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054f7:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801054fe:	eb 3c                	jmp    8010553c <exit+0x13c>
    if(p->parent == proc){
80105500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105503:	8b 50 14             	mov    0x14(%eax),%edx
80105506:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010550c:	39 c2                	cmp    %eax,%edx
8010550e:	75 28                	jne    80105538 <exit+0x138>
      p->parent = initproc;
80105510:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80105516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105519:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010551c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551f:	8b 40 0c             	mov    0xc(%eax),%eax
80105522:	83 f8 05             	cmp    $0x5,%eax
80105525:	75 11                	jne    80105538 <exit+0x138>
        wakeup1(initproc);
80105527:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010552c:	83 ec 0c             	sub    $0xc,%esp
8010552f:	50                   	push   %eax
80105530:	e8 05 04 00 00       	call   8010593a <wakeup1>
80105535:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105538:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010553c:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105543:	72 bb                	jb     80105500 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105545:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010554b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105552:	e8 d6 01 00 00       	call   8010572d <sched>
  panic("zombie exit");
80105557:	83 ec 0c             	sub    $0xc,%esp
8010555a:	68 89 98 10 80       	push   $0x80109889
8010555f:	e8 02 b0 ff ff       	call   80100566 <panic>

80105564 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105564:	55                   	push   %ebp
80105565:	89 e5                	mov    %esp,%ebp
80105567:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010556a:	83 ec 0c             	sub    $0xc,%esp
8010556d:	68 80 3e 11 80       	push   $0x80113e80
80105572:	e8 10 06 00 00       	call   80105b87 <acquire>
80105577:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010557a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105581:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105588:	e9 a6 00 00 00       	jmp    80105633 <wait+0xcf>
      if(p->parent != proc)
8010558d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105590:	8b 50 14             	mov    0x14(%eax),%edx
80105593:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105599:	39 c2                	cmp    %eax,%edx
8010559b:	0f 85 8d 00 00 00    	jne    8010562e <wait+0xca>
        continue;
      havekids = 1;
801055a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ab:	8b 40 0c             	mov    0xc(%eax),%eax
801055ae:	83 f8 05             	cmp    $0x5,%eax
801055b1:	75 7c                	jne    8010562f <wait+0xcb>
        // Found one.
        pid = p->pid;
801055b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b6:	8b 40 10             	mov    0x10(%eax),%eax
801055b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bf:	8b 40 08             	mov    0x8(%eax),%eax
801055c2:	83 ec 0c             	sub    $0xc,%esp
801055c5:	50                   	push   %eax
801055c6:	e8 0a de ff ff       	call   801033d5 <kfree>
801055cb:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055db:	8b 40 04             	mov    0x4(%eax),%eax
801055de:	83 ec 0c             	sub    $0xc,%esp
801055e1:	50                   	push   %eax
801055e2:	e8 6e 3b 00 00       	call   80109155 <freevm>
801055e7:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801055f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801055fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105601:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010560f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105612:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105619:	83 ec 0c             	sub    $0xc,%esp
8010561c:	68 80 3e 11 80       	push   $0x80113e80
80105621:	e8 c8 05 00 00       	call   80105bee <release>
80105626:	83 c4 10             	add    $0x10,%esp
        return pid;
80105629:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010562c:	eb 58                	jmp    80105686 <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010562e:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010562f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105633:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010563a:	0f 82 4d ff ff ff    	jb     8010558d <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105640:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105644:	74 0d                	je     80105653 <wait+0xef>
80105646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010564c:	8b 40 24             	mov    0x24(%eax),%eax
8010564f:	85 c0                	test   %eax,%eax
80105651:	74 17                	je     8010566a <wait+0x106>
      release(&ptable.lock);
80105653:	83 ec 0c             	sub    $0xc,%esp
80105656:	68 80 3e 11 80       	push   $0x80113e80
8010565b:	e8 8e 05 00 00       	call   80105bee <release>
80105660:	83 c4 10             	add    $0x10,%esp
      return -1;
80105663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105668:	eb 1c                	jmp    80105686 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010566a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105670:	83 ec 08             	sub    $0x8,%esp
80105673:	68 80 3e 11 80       	push   $0x80113e80
80105678:	50                   	push   %eax
80105679:	e8 10 02 00 00       	call   8010588e <sleep>
8010567e:	83 c4 10             	add    $0x10,%esp
  }
80105681:	e9 f4 fe ff ff       	jmp    8010557a <wait+0x16>
}
80105686:	c9                   	leave  
80105687:	c3                   	ret    

80105688 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105688:	55                   	push   %ebp
80105689:	89 e5                	mov    %esp,%ebp
8010568b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010568e:	e8 f3 f8 ff ff       	call   80104f86 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105693:	83 ec 0c             	sub    $0xc,%esp
80105696:	68 80 3e 11 80       	push   $0x80113e80
8010569b:	e8 e7 04 00 00       	call   80105b87 <acquire>
801056a0:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056a3:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801056aa:	eb 63                	jmp    8010570f <scheduler+0x87>
      if(p->state != RUNNABLE)
801056ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056af:	8b 40 0c             	mov    0xc(%eax),%eax
801056b2:	83 f8 03             	cmp    $0x3,%eax
801056b5:	75 53                	jne    8010570a <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ba:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056c0:	83 ec 0c             	sub    $0xc,%esp
801056c3:	ff 75 f4             	pushl  -0xc(%ebp)
801056c6:	e8 44 36 00 00       	call   80108d0f <switchuvm>
801056cb:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056de:	8b 40 1c             	mov    0x1c(%eax),%eax
801056e1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056e8:	83 c2 04             	add    $0x4,%edx
801056eb:	83 ec 08             	sub    $0x8,%esp
801056ee:	50                   	push   %eax
801056ef:	52                   	push   %edx
801056f0:	e8 69 09 00 00       	call   8010605e <swtch>
801056f5:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801056f8:	e8 f5 35 00 00       	call   80108cf2 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801056fd:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105704:	00 00 00 00 
80105708:	eb 01                	jmp    8010570b <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010570a:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010570b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010570f:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105716:	72 94                	jb     801056ac <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105718:	83 ec 0c             	sub    $0xc,%esp
8010571b:	68 80 3e 11 80       	push   $0x80113e80
80105720:	e8 c9 04 00 00       	call   80105bee <release>
80105725:	83 c4 10             	add    $0x10,%esp

  }
80105728:	e9 61 ff ff ff       	jmp    8010568e <scheduler+0x6>

8010572d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010572d:	55                   	push   %ebp
8010572e:	89 e5                	mov    %esp,%ebp
80105730:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105733:	83 ec 0c             	sub    $0xc,%esp
80105736:	68 80 3e 11 80       	push   $0x80113e80
8010573b:	e8 7a 05 00 00       	call   80105cba <holding>
80105740:	83 c4 10             	add    $0x10,%esp
80105743:	85 c0                	test   %eax,%eax
80105745:	75 0d                	jne    80105754 <sched+0x27>
    panic("sched ptable.lock");
80105747:	83 ec 0c             	sub    $0xc,%esp
8010574a:	68 95 98 10 80       	push   $0x80109895
8010574f:	e8 12 ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105754:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010575a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105760:	83 f8 01             	cmp    $0x1,%eax
80105763:	74 0d                	je     80105772 <sched+0x45>
   panic("sched locks");
80105765:	83 ec 0c             	sub    $0xc,%esp
80105768:	68 a7 98 10 80       	push   $0x801098a7
8010576d:	e8 f4 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105772:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105778:	8b 40 0c             	mov    0xc(%eax),%eax
8010577b:	83 f8 04             	cmp    $0x4,%eax
8010577e:	75 0d                	jne    8010578d <sched+0x60>
    panic("sched running");
80105780:	83 ec 0c             	sub    $0xc,%esp
80105783:	68 b3 98 10 80       	push   $0x801098b3
80105788:	e8 d9 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010578d:	e8 e4 f7 ff ff       	call   80104f76 <readeflags>
80105792:	25 00 02 00 00       	and    $0x200,%eax
80105797:	85 c0                	test   %eax,%eax
80105799:	74 0d                	je     801057a8 <sched+0x7b>
    panic("sched interruptible");
8010579b:	83 ec 0c             	sub    $0xc,%esp
8010579e:	68 c1 98 10 80       	push   $0x801098c1
801057a3:	e8 be ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057ae:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057bd:	8b 40 04             	mov    0x4(%eax),%eax
801057c0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057c7:	83 c2 1c             	add    $0x1c,%edx
801057ca:	83 ec 08             	sub    $0x8,%esp
801057cd:	50                   	push   %eax
801057ce:	52                   	push   %edx
801057cf:	e8 8a 08 00 00       	call   8010605e <swtch>
801057d4:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057e0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057e6:	90                   	nop
801057e7:	c9                   	leave  
801057e8:	c3                   	ret    

801057e9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057e9:	55                   	push   %ebp
801057ea:	89 e5                	mov    %esp,%ebp
801057ec:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057ef:	83 ec 0c             	sub    $0xc,%esp
801057f2:	68 80 3e 11 80       	push   $0x80113e80
801057f7:	e8 8b 03 00 00       	call   80105b87 <acquire>
801057fc:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801057ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105805:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010580c:	e8 1c ff ff ff       	call   8010572d <sched>
  release(&ptable.lock);
80105811:	83 ec 0c             	sub    $0xc,%esp
80105814:	68 80 3e 11 80       	push   $0x80113e80
80105819:	e8 d0 03 00 00       	call   80105bee <release>
8010581e:	83 c4 10             	add    $0x10,%esp
}
80105821:	90                   	nop
80105822:	c9                   	leave  
80105823:	c3                   	ret    

80105824 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105824:	55                   	push   %ebp
80105825:	89 e5                	mov    %esp,%ebp
80105827:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010582a:	83 ec 0c             	sub    $0xc,%esp
8010582d:	68 80 3e 11 80       	push   $0x80113e80
80105832:	e8 b7 03 00 00       	call   80105bee <release>
80105837:	83 c4 10             	add    $0x10,%esp


  if (first) {
8010583a:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010583f:	85 c0                	test   %eax,%eax
80105841:	74 48                	je     8010588b <forkret+0x67>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105843:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
8010584a:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
8010584d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105853:	0f b6 00             	movzbl (%eax),%eax
80105856:	0f b6 c0             	movzbl %al,%eax
80105859:	83 ec 08             	sub    $0x8,%esp
8010585c:	50                   	push   %eax
8010585d:	68 d5 98 10 80       	push   $0x801098d5
80105862:	e8 5f ab ff ff       	call   801003c6 <cprintf>
80105867:	83 c4 10             	add    $0x10,%esp
iinit(proc,ROOTDEV);
8010586a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105870:	83 ec 08             	sub    $0x8,%esp
80105873:	6a 00                	push   $0x0
80105875:	50                   	push   %eax
80105876:	e8 b7 c1 ff ff       	call   80101a32 <iinit>
8010587b:	83 c4 10             	add    $0x10,%esp
    // iinitDone=1;
   // cprintf("boot from after iinit is %d \n",bootfrom);
    initlog(ROOTDEV);
8010587e:	83 ec 0c             	sub    $0xc,%esp
80105881:	6a 00                	push   $0x0
80105883:	e8 b3 e2 ff ff       	call   80103b3b <initlog>
80105888:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
8010588b:	90                   	nop
8010588c:	c9                   	leave  
8010588d:	c3                   	ret    

8010588e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010588e:	55                   	push   %ebp
8010588f:	89 e5                	mov    %esp,%ebp
80105891:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105894:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010589a:	85 c0                	test   %eax,%eax
8010589c:	75 0d                	jne    801058ab <sleep+0x1d>
    panic("sleep");
8010589e:	83 ec 0c             	sub    $0xc,%esp
801058a1:	68 e4 98 10 80       	push   $0x801098e4
801058a6:	e8 bb ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058af:	75 0d                	jne    801058be <sleep+0x30>
    panic("sleep without lk");
801058b1:	83 ec 0c             	sub    $0xc,%esp
801058b4:	68 ea 98 10 80       	push   $0x801098ea
801058b9:	e8 a8 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058be:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058c5:	74 1e                	je     801058e5 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058c7:	83 ec 0c             	sub    $0xc,%esp
801058ca:	68 80 3e 11 80       	push   $0x80113e80
801058cf:	e8 b3 02 00 00       	call   80105b87 <acquire>
801058d4:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058d7:	83 ec 0c             	sub    $0xc,%esp
801058da:	ff 75 0c             	pushl  0xc(%ebp)
801058dd:	e8 0c 03 00 00       	call   80105bee <release>
801058e2:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058eb:	8b 55 08             	mov    0x8(%ebp),%edx
801058ee:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801058fe:	e8 2a fe ff ff       	call   8010572d <sched>

  // Tidy up.
  proc->chan = 0;
80105903:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105909:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105910:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
80105917:	74 1e                	je     80105937 <sleep+0xa9>
    release(&ptable.lock);
80105919:	83 ec 0c             	sub    $0xc,%esp
8010591c:	68 80 3e 11 80       	push   $0x80113e80
80105921:	e8 c8 02 00 00       	call   80105bee <release>
80105926:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105929:	83 ec 0c             	sub    $0xc,%esp
8010592c:	ff 75 0c             	pushl  0xc(%ebp)
8010592f:	e8 53 02 00 00       	call   80105b87 <acquire>
80105934:	83 c4 10             	add    $0x10,%esp
  }
}
80105937:	90                   	nop
80105938:	c9                   	leave  
80105939:	c3                   	ret    

8010593a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010593a:	55                   	push   %ebp
8010593b:	89 e5                	mov    %esp,%ebp
8010593d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105940:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105947:	eb 24                	jmp    8010596d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105949:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010594c:	8b 40 0c             	mov    0xc(%eax),%eax
8010594f:	83 f8 02             	cmp    $0x2,%eax
80105952:	75 15                	jne    80105969 <wakeup1+0x2f>
80105954:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105957:	8b 40 20             	mov    0x20(%eax),%eax
8010595a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010595d:	75 0a                	jne    80105969 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010595f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105962:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105969:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010596d:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
80105974:	72 d3                	jb     80105949 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105976:	90                   	nop
80105977:	c9                   	leave  
80105978:	c3                   	ret    

80105979 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105979:	55                   	push   %ebp
8010597a:	89 e5                	mov    %esp,%ebp
8010597c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010597f:	83 ec 0c             	sub    $0xc,%esp
80105982:	68 80 3e 11 80       	push   $0x80113e80
80105987:	e8 fb 01 00 00       	call   80105b87 <acquire>
8010598c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	ff 75 08             	pushl  0x8(%ebp)
80105995:	e8 a0 ff ff ff       	call   8010593a <wakeup1>
8010599a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010599d:	83 ec 0c             	sub    $0xc,%esp
801059a0:	68 80 3e 11 80       	push   $0x80113e80
801059a5:	e8 44 02 00 00       	call   80105bee <release>
801059aa:	83 c4 10             	add    $0x10,%esp
}
801059ad:	90                   	nop
801059ae:	c9                   	leave  
801059af:	c3                   	ret    

801059b0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059b0:	55                   	push   %ebp
801059b1:	89 e5                	mov    %esp,%ebp
801059b3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059b6:	83 ec 0c             	sub    $0xc,%esp
801059b9:	68 80 3e 11 80       	push   $0x80113e80
801059be:	e8 c4 01 00 00       	call   80105b87 <acquire>
801059c3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059c6:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059cd:	eb 45                	jmp    80105a14 <kill+0x64>
    if(p->pid == pid){
801059cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d2:	8b 40 10             	mov    0x10(%eax),%eax
801059d5:	3b 45 08             	cmp    0x8(%ebp),%eax
801059d8:	75 36                	jne    80105a10 <kill+0x60>
      p->killed = 1;
801059da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059dd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e7:	8b 40 0c             	mov    0xc(%eax),%eax
801059ea:	83 f8 02             	cmp    $0x2,%eax
801059ed:	75 0a                	jne    801059f9 <kill+0x49>
        p->state = RUNNABLE;
801059ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801059f9:	83 ec 0c             	sub    $0xc,%esp
801059fc:	68 80 3e 11 80       	push   $0x80113e80
80105a01:	e8 e8 01 00 00       	call   80105bee <release>
80105a06:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a09:	b8 00 00 00 00       	mov    $0x0,%eax
80105a0e:	eb 22                	jmp    80105a32 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a10:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105a14:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105a1b:	72 b2                	jb     801059cf <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a1d:	83 ec 0c             	sub    $0xc,%esp
80105a20:	68 80 3e 11 80       	push   $0x80113e80
80105a25:	e8 c4 01 00 00       	call   80105bee <release>
80105a2a:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a32:	c9                   	leave  
80105a33:	c3                   	ret    

80105a34 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a34:	55                   	push   %ebp
80105a35:	89 e5                	mov    %esp,%ebp
80105a37:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a3a:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a41:	e9 d7 00 00 00       	jmp    80105b1d <procdump+0xe9>
    if(p->state == UNUSED)
80105a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a49:	8b 40 0c             	mov    0xc(%eax),%eax
80105a4c:	85 c0                	test   %eax,%eax
80105a4e:	0f 84 c4 00 00 00    	je     80105b18 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	8b 40 0c             	mov    0xc(%eax),%eax
80105a5a:	83 f8 05             	cmp    $0x5,%eax
80105a5d:	77 23                	ja     80105a82 <procdump+0x4e>
80105a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a62:	8b 40 0c             	mov    0xc(%eax),%eax
80105a65:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a6c:	85 c0                	test   %eax,%eax
80105a6e:	74 12                	je     80105a82 <procdump+0x4e>
      state = states[p->state];
80105a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a73:	8b 40 0c             	mov    0xc(%eax),%eax
80105a76:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a80:	eb 07                	jmp    80105a89 <procdump+0x55>
    else
      state = "???";
80105a82:	c7 45 ec fb 98 10 80 	movl   $0x801098fb,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8c:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a92:	8b 40 10             	mov    0x10(%eax),%eax
80105a95:	52                   	push   %edx
80105a96:	ff 75 ec             	pushl  -0x14(%ebp)
80105a99:	50                   	push   %eax
80105a9a:	68 ff 98 10 80       	push   $0x801098ff
80105a9f:	e8 22 a9 ff ff       	call   801003c6 <cprintf>
80105aa4:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aaa:	8b 40 0c             	mov    0xc(%eax),%eax
80105aad:	83 f8 02             	cmp    $0x2,%eax
80105ab0:	75 54                	jne    80105b06 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab5:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ab8:	8b 40 0c             	mov    0xc(%eax),%eax
80105abb:	83 c0 08             	add    $0x8,%eax
80105abe:	89 c2                	mov    %eax,%edx
80105ac0:	83 ec 08             	sub    $0x8,%esp
80105ac3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105ac6:	50                   	push   %eax
80105ac7:	52                   	push   %edx
80105ac8:	e8 73 01 00 00       	call   80105c40 <getcallerpcs>
80105acd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ad0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ad7:	eb 1c                	jmp    80105af5 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ae0:	83 ec 08             	sub    $0x8,%esp
80105ae3:	50                   	push   %eax
80105ae4:	68 08 99 10 80       	push   $0x80109908
80105ae9:	e8 d8 a8 ff ff       	call   801003c6 <cprintf>
80105aee:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105af1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105af5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105af9:	7f 0b                	jg     80105b06 <procdump+0xd2>
80105afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afe:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b02:	85 c0                	test   %eax,%eax
80105b04:	75 d3                	jne    80105ad9 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b06:	83 ec 0c             	sub    $0xc,%esp
80105b09:	68 0c 99 10 80       	push   $0x8010990c
80105b0e:	e8 b3 a8 ff ff       	call   801003c6 <cprintf>
80105b13:	83 c4 10             	add    $0x10,%esp
80105b16:	eb 01                	jmp    80105b19 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b18:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b19:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105b1d:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b24:	0f 82 1c ff ff ff    	jb     80105a46 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b2a:	90                   	nop
80105b2b:	c9                   	leave  
80105b2c:	c3                   	ret    

80105b2d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b2d:	55                   	push   %ebp
80105b2e:	89 e5                	mov    %esp,%ebp
80105b30:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b33:	9c                   	pushf  
80105b34:	58                   	pop    %eax
80105b35:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b3b:	c9                   	leave  
80105b3c:	c3                   	ret    

80105b3d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b3d:	55                   	push   %ebp
80105b3e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b40:	fa                   	cli    
}
80105b41:	90                   	nop
80105b42:	5d                   	pop    %ebp
80105b43:	c3                   	ret    

80105b44 <sti>:

static inline void
sti(void)
{
80105b44:	55                   	push   %ebp
80105b45:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b47:	fb                   	sti    
}
80105b48:	90                   	nop
80105b49:	5d                   	pop    %ebp
80105b4a:	c3                   	ret    

80105b4b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b4b:	55                   	push   %ebp
80105b4c:	89 e5                	mov    %esp,%ebp
80105b4e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b51:	8b 55 08             	mov    0x8(%ebp),%edx
80105b54:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b5a:	f0 87 02             	lock xchg %eax,(%edx)
80105b5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b63:	c9                   	leave  
80105b64:	c3                   	ret    

80105b65 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b65:	55                   	push   %ebp
80105b66:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b68:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b6e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b71:	8b 45 08             	mov    0x8(%ebp),%eax
80105b74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b84:	90                   	nop
80105b85:	5d                   	pop    %ebp
80105b86:	c3                   	ret    

80105b87 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b87:	55                   	push   %ebp
80105b88:	89 e5                	mov    %esp,%ebp
80105b8a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b8d:	e8 52 01 00 00       	call   80105ce4 <pushcli>
  if(holding(lk))
80105b92:	8b 45 08             	mov    0x8(%ebp),%eax
80105b95:	83 ec 0c             	sub    $0xc,%esp
80105b98:	50                   	push   %eax
80105b99:	e8 1c 01 00 00       	call   80105cba <holding>
80105b9e:	83 c4 10             	add    $0x10,%esp
80105ba1:	85 c0                	test   %eax,%eax
80105ba3:	74 0d                	je     80105bb2 <acquire+0x2b>
    panic("acquire");
80105ba5:	83 ec 0c             	sub    $0xc,%esp
80105ba8:	68 38 99 10 80       	push   $0x80109938
80105bad:	e8 b4 a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bb2:	90                   	nop
80105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb6:	83 ec 08             	sub    $0x8,%esp
80105bb9:	6a 01                	push   $0x1
80105bbb:	50                   	push   %eax
80105bbc:	e8 8a ff ff ff       	call   80105b4b <xchg>
80105bc1:	83 c4 10             	add    $0x10,%esp
80105bc4:	85 c0                	test   %eax,%eax
80105bc6:	75 eb                	jne    80105bb3 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bd2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd8:	83 c0 0c             	add    $0xc,%eax
80105bdb:	83 ec 08             	sub    $0x8,%esp
80105bde:	50                   	push   %eax
80105bdf:	8d 45 08             	lea    0x8(%ebp),%eax
80105be2:	50                   	push   %eax
80105be3:	e8 58 00 00 00       	call   80105c40 <getcallerpcs>
80105be8:	83 c4 10             	add    $0x10,%esp
}
80105beb:	90                   	nop
80105bec:	c9                   	leave  
80105bed:	c3                   	ret    

80105bee <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105bee:	55                   	push   %ebp
80105bef:	89 e5                	mov    %esp,%ebp
80105bf1:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bf4:	83 ec 0c             	sub    $0xc,%esp
80105bf7:	ff 75 08             	pushl  0x8(%ebp)
80105bfa:	e8 bb 00 00 00       	call   80105cba <holding>
80105bff:	83 c4 10             	add    $0x10,%esp
80105c02:	85 c0                	test   %eax,%eax
80105c04:	75 0d                	jne    80105c13 <release+0x25>
    panic("release");
80105c06:	83 ec 0c             	sub    $0xc,%esp
80105c09:	68 40 99 10 80       	push   $0x80109940
80105c0e:	e8 53 a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c13:	8b 45 08             	mov    0x8(%ebp),%eax
80105c16:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c27:	8b 45 08             	mov    0x8(%ebp),%eax
80105c2a:	83 ec 08             	sub    $0x8,%esp
80105c2d:	6a 00                	push   $0x0
80105c2f:	50                   	push   %eax
80105c30:	e8 16 ff ff ff       	call   80105b4b <xchg>
80105c35:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c38:	e8 ec 00 00 00       	call   80105d29 <popcli>
}
80105c3d:	90                   	nop
80105c3e:	c9                   	leave  
80105c3f:	c3                   	ret    

80105c40 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c40:	55                   	push   %ebp
80105c41:	89 e5                	mov    %esp,%ebp
80105c43:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c46:	8b 45 08             	mov    0x8(%ebp),%eax
80105c49:	83 e8 08             	sub    $0x8,%eax
80105c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c4f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c56:	eb 38                	jmp    80105c90 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c58:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c5c:	74 53                	je     80105cb1 <getcallerpcs+0x71>
80105c5e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c65:	76 4a                	jbe    80105cb1 <getcallerpcs+0x71>
80105c67:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c6b:	74 44                	je     80105cb1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c7a:	01 c2                	add    %eax,%edx
80105c7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c7f:	8b 40 04             	mov    0x4(%eax),%eax
80105c82:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c87:	8b 00                	mov    (%eax),%eax
80105c89:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c8c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c90:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c94:	7e c2                	jle    80105c58 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c96:	eb 19                	jmp    80105cb1 <getcallerpcs+0x71>
    pcs[i] = 0;
80105c98:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ca5:	01 d0                	add    %edx,%eax
80105ca7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cad:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cb1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cb5:	7e e1                	jle    80105c98 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cb7:	90                   	nop
80105cb8:	c9                   	leave  
80105cb9:	c3                   	ret    

80105cba <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cba:	55                   	push   %ebp
80105cbb:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc0:	8b 00                	mov    (%eax),%eax
80105cc2:	85 c0                	test   %eax,%eax
80105cc4:	74 17                	je     80105cdd <holding+0x23>
80105cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc9:	8b 50 08             	mov    0x8(%eax),%edx
80105ccc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cd2:	39 c2                	cmp    %eax,%edx
80105cd4:	75 07                	jne    80105cdd <holding+0x23>
80105cd6:	b8 01 00 00 00       	mov    $0x1,%eax
80105cdb:	eb 05                	jmp    80105ce2 <holding+0x28>
80105cdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce2:	5d                   	pop    %ebp
80105ce3:	c3                   	ret    

80105ce4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105ce4:	55                   	push   %ebp
80105ce5:	89 e5                	mov    %esp,%ebp
80105ce7:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105cea:	e8 3e fe ff ff       	call   80105b2d <readeflags>
80105cef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105cf2:	e8 46 fe ff ff       	call   80105b3d <cli>
  if(cpu->ncli++ == 0)
80105cf7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cfe:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d04:	8d 48 01             	lea    0x1(%eax),%ecx
80105d07:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d0d:	85 c0                	test   %eax,%eax
80105d0f:	75 15                	jne    80105d26 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d11:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d17:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d1a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d20:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d26:	90                   	nop
80105d27:	c9                   	leave  
80105d28:	c3                   	ret    

80105d29 <popcli>:

void
popcli(void)
{
80105d29:	55                   	push   %ebp
80105d2a:	89 e5                	mov    %esp,%ebp
80105d2c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d2f:	e8 f9 fd ff ff       	call   80105b2d <readeflags>
80105d34:	25 00 02 00 00       	and    $0x200,%eax
80105d39:	85 c0                	test   %eax,%eax
80105d3b:	74 0d                	je     80105d4a <popcli+0x21>
    panic("popcli - interruptible");
80105d3d:	83 ec 0c             	sub    $0xc,%esp
80105d40:	68 48 99 10 80       	push   $0x80109948
80105d45:	e8 1c a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d4a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d50:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d56:	83 ea 01             	sub    $0x1,%edx
80105d59:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d5f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d65:	85 c0                	test   %eax,%eax
80105d67:	79 0d                	jns    80105d76 <popcli+0x4d>
    panic("popcli");
80105d69:	83 ec 0c             	sub    $0xc,%esp
80105d6c:	68 5f 99 10 80       	push   $0x8010995f
80105d71:	e8 f0 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d76:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d7c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d82:	85 c0                	test   %eax,%eax
80105d84:	75 15                	jne    80105d9b <popcli+0x72>
80105d86:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d8c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d92:	85 c0                	test   %eax,%eax
80105d94:	74 05                	je     80105d9b <popcli+0x72>
    sti();
80105d96:	e8 a9 fd ff ff       	call   80105b44 <sti>
}
80105d9b:	90                   	nop
80105d9c:	c9                   	leave  
80105d9d:	c3                   	ret    

80105d9e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d9e:	55                   	push   %ebp
80105d9f:	89 e5                	mov    %esp,%ebp
80105da1:	57                   	push   %edi
80105da2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105da6:	8b 55 10             	mov    0x10(%ebp),%edx
80105da9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dac:	89 cb                	mov    %ecx,%ebx
80105dae:	89 df                	mov    %ebx,%edi
80105db0:	89 d1                	mov    %edx,%ecx
80105db2:	fc                   	cld    
80105db3:	f3 aa                	rep stos %al,%es:(%edi)
80105db5:	89 ca                	mov    %ecx,%edx
80105db7:	89 fb                	mov    %edi,%ebx
80105db9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dbc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dbf:	90                   	nop
80105dc0:	5b                   	pop    %ebx
80105dc1:	5f                   	pop    %edi
80105dc2:	5d                   	pop    %ebp
80105dc3:	c3                   	ret    

80105dc4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dc4:	55                   	push   %ebp
80105dc5:	89 e5                	mov    %esp,%ebp
80105dc7:	57                   	push   %edi
80105dc8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dcc:	8b 55 10             	mov    0x10(%ebp),%edx
80105dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd2:	89 cb                	mov    %ecx,%ebx
80105dd4:	89 df                	mov    %ebx,%edi
80105dd6:	89 d1                	mov    %edx,%ecx
80105dd8:	fc                   	cld    
80105dd9:	f3 ab                	rep stos %eax,%es:(%edi)
80105ddb:	89 ca                	mov    %ecx,%edx
80105ddd:	89 fb                	mov    %edi,%ebx
80105ddf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105de2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105de5:	90                   	nop
80105de6:	5b                   	pop    %ebx
80105de7:	5f                   	pop    %edi
80105de8:	5d                   	pop    %ebp
80105de9:	c3                   	ret    

80105dea <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105dea:	55                   	push   %ebp
80105deb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105ded:	8b 45 08             	mov    0x8(%ebp),%eax
80105df0:	83 e0 03             	and    $0x3,%eax
80105df3:	85 c0                	test   %eax,%eax
80105df5:	75 43                	jne    80105e3a <memset+0x50>
80105df7:	8b 45 10             	mov    0x10(%ebp),%eax
80105dfa:	83 e0 03             	and    $0x3,%eax
80105dfd:	85 c0                	test   %eax,%eax
80105dff:	75 39                	jne    80105e3a <memset+0x50>
    c &= 0xFF;
80105e01:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e08:	8b 45 10             	mov    0x10(%ebp),%eax
80105e0b:	c1 e8 02             	shr    $0x2,%eax
80105e0e:	89 c1                	mov    %eax,%ecx
80105e10:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e13:	c1 e0 18             	shl    $0x18,%eax
80105e16:	89 c2                	mov    %eax,%edx
80105e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1b:	c1 e0 10             	shl    $0x10,%eax
80105e1e:	09 c2                	or     %eax,%edx
80105e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e23:	c1 e0 08             	shl    $0x8,%eax
80105e26:	09 d0                	or     %edx,%eax
80105e28:	0b 45 0c             	or     0xc(%ebp),%eax
80105e2b:	51                   	push   %ecx
80105e2c:	50                   	push   %eax
80105e2d:	ff 75 08             	pushl  0x8(%ebp)
80105e30:	e8 8f ff ff ff       	call   80105dc4 <stosl>
80105e35:	83 c4 0c             	add    $0xc,%esp
80105e38:	eb 12                	jmp    80105e4c <memset+0x62>
  } else
    stosb(dst, c, n);
80105e3a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e3d:	50                   	push   %eax
80105e3e:	ff 75 0c             	pushl  0xc(%ebp)
80105e41:	ff 75 08             	pushl  0x8(%ebp)
80105e44:	e8 55 ff ff ff       	call   80105d9e <stosb>
80105e49:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e4c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e4f:	c9                   	leave  
80105e50:	c3                   	ret    

80105e51 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e51:	55                   	push   %ebp
80105e52:	89 e5                	mov    %esp,%ebp
80105e54:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e57:	8b 45 08             	mov    0x8(%ebp),%eax
80105e5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e60:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e63:	eb 30                	jmp    80105e95 <memcmp+0x44>
    if(*s1 != *s2)
80105e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e68:	0f b6 10             	movzbl (%eax),%edx
80105e6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e6e:	0f b6 00             	movzbl (%eax),%eax
80105e71:	38 c2                	cmp    %al,%dl
80105e73:	74 18                	je     80105e8d <memcmp+0x3c>
      return *s1 - *s2;
80105e75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e78:	0f b6 00             	movzbl (%eax),%eax
80105e7b:	0f b6 d0             	movzbl %al,%edx
80105e7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e81:	0f b6 00             	movzbl (%eax),%eax
80105e84:	0f b6 c0             	movzbl %al,%eax
80105e87:	29 c2                	sub    %eax,%edx
80105e89:	89 d0                	mov    %edx,%eax
80105e8b:	eb 1a                	jmp    80105ea7 <memcmp+0x56>
    s1++, s2++;
80105e8d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e91:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e95:	8b 45 10             	mov    0x10(%ebp),%eax
80105e98:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e9b:	89 55 10             	mov    %edx,0x10(%ebp)
80105e9e:	85 c0                	test   %eax,%eax
80105ea0:	75 c3                	jne    80105e65 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105ea2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ea7:	c9                   	leave  
80105ea8:	c3                   	ret    

80105ea9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ea9:	55                   	push   %ebp
80105eaa:	89 e5                	mov    %esp,%ebp
80105eac:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ebe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ec1:	73 54                	jae    80105f17 <memmove+0x6e>
80105ec3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ec6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec9:	01 d0                	add    %edx,%eax
80105ecb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ece:	76 47                	jbe    80105f17 <memmove+0x6e>
    s += n;
80105ed0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ed6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105edc:	eb 13                	jmp    80105ef1 <memmove+0x48>
      *--d = *--s;
80105ede:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105ee2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ee6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ee9:	0f b6 10             	movzbl (%eax),%edx
80105eec:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105eef:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105ef1:	8b 45 10             	mov    0x10(%ebp),%eax
80105ef4:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ef7:	89 55 10             	mov    %edx,0x10(%ebp)
80105efa:	85 c0                	test   %eax,%eax
80105efc:	75 e0                	jne    80105ede <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105efe:	eb 24                	jmp    80105f24 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f00:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f03:	8d 50 01             	lea    0x1(%eax),%edx
80105f06:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f09:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f0c:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f0f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f12:	0f b6 12             	movzbl (%edx),%edx
80105f15:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f17:	8b 45 10             	mov    0x10(%ebp),%eax
80105f1a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f1d:	89 55 10             	mov    %edx,0x10(%ebp)
80105f20:	85 c0                	test   %eax,%eax
80105f22:	75 dc                	jne    80105f00 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f24:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f27:	c9                   	leave  
80105f28:	c3                   	ret    

80105f29 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f29:	55                   	push   %ebp
80105f2a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f2c:	ff 75 10             	pushl  0x10(%ebp)
80105f2f:	ff 75 0c             	pushl  0xc(%ebp)
80105f32:	ff 75 08             	pushl  0x8(%ebp)
80105f35:	e8 6f ff ff ff       	call   80105ea9 <memmove>
80105f3a:	83 c4 0c             	add    $0xc,%esp
}
80105f3d:	c9                   	leave  
80105f3e:	c3                   	ret    

80105f3f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f3f:	55                   	push   %ebp
80105f40:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f42:	eb 0c                	jmp    80105f50 <strncmp+0x11>
    n--, p++, q++;
80105f44:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f48:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f4c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f54:	74 1a                	je     80105f70 <strncmp+0x31>
80105f56:	8b 45 08             	mov    0x8(%ebp),%eax
80105f59:	0f b6 00             	movzbl (%eax),%eax
80105f5c:	84 c0                	test   %al,%al
80105f5e:	74 10                	je     80105f70 <strncmp+0x31>
80105f60:	8b 45 08             	mov    0x8(%ebp),%eax
80105f63:	0f b6 10             	movzbl (%eax),%edx
80105f66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f69:	0f b6 00             	movzbl (%eax),%eax
80105f6c:	38 c2                	cmp    %al,%dl
80105f6e:	74 d4                	je     80105f44 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f74:	75 07                	jne    80105f7d <strncmp+0x3e>
    return 0;
80105f76:	b8 00 00 00 00       	mov    $0x0,%eax
80105f7b:	eb 16                	jmp    80105f93 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f80:	0f b6 00             	movzbl (%eax),%eax
80105f83:	0f b6 d0             	movzbl %al,%edx
80105f86:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f89:	0f b6 00             	movzbl (%eax),%eax
80105f8c:	0f b6 c0             	movzbl %al,%eax
80105f8f:	29 c2                	sub    %eax,%edx
80105f91:	89 d0                	mov    %edx,%eax
}
80105f93:	5d                   	pop    %ebp
80105f94:	c3                   	ret    

80105f95 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f95:	55                   	push   %ebp
80105f96:	89 e5                	mov    %esp,%ebp
80105f98:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105fa1:	90                   	nop
80105fa2:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fa8:	89 55 10             	mov    %edx,0x10(%ebp)
80105fab:	85 c0                	test   %eax,%eax
80105fad:	7e 2c                	jle    80105fdb <strncpy+0x46>
80105faf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb2:	8d 50 01             	lea    0x1(%eax),%edx
80105fb5:	89 55 08             	mov    %edx,0x8(%ebp)
80105fb8:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fbb:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fbe:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fc1:	0f b6 12             	movzbl (%edx),%edx
80105fc4:	88 10                	mov    %dl,(%eax)
80105fc6:	0f b6 00             	movzbl (%eax),%eax
80105fc9:	84 c0                	test   %al,%al
80105fcb:	75 d5                	jne    80105fa2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105fcd:	eb 0c                	jmp    80105fdb <strncpy+0x46>
    *s++ = 0;
80105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd2:	8d 50 01             	lea    0x1(%eax),%edx
80105fd5:	89 55 08             	mov    %edx,0x8(%ebp)
80105fd8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fdb:	8b 45 10             	mov    0x10(%ebp),%eax
80105fde:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fe1:	89 55 10             	mov    %edx,0x10(%ebp)
80105fe4:	85 c0                	test   %eax,%eax
80105fe6:	7f e7                	jg     80105fcf <strncpy+0x3a>
    *s++ = 0;
  return os;
80105fe8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105feb:	c9                   	leave  
80105fec:	c3                   	ret    

80105fed <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105ff9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ffd:	7f 05                	jg     80106004 <safestrcpy+0x17>
    return os;
80105fff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106002:	eb 31                	jmp    80106035 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106004:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106008:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010600c:	7e 1e                	jle    8010602c <safestrcpy+0x3f>
8010600e:	8b 45 08             	mov    0x8(%ebp),%eax
80106011:	8d 50 01             	lea    0x1(%eax),%edx
80106014:	89 55 08             	mov    %edx,0x8(%ebp)
80106017:	8b 55 0c             	mov    0xc(%ebp),%edx
8010601a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010601d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106020:	0f b6 12             	movzbl (%edx),%edx
80106023:	88 10                	mov    %dl,(%eax)
80106025:	0f b6 00             	movzbl (%eax),%eax
80106028:	84 c0                	test   %al,%al
8010602a:	75 d8                	jne    80106004 <safestrcpy+0x17>
    ;
  *s = 0;
8010602c:	8b 45 08             	mov    0x8(%ebp),%eax
8010602f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106032:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106035:	c9                   	leave  
80106036:	c3                   	ret    

80106037 <strlen>:

int
strlen(const char *s)
{
80106037:	55                   	push   %ebp
80106038:	89 e5                	mov    %esp,%ebp
8010603a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010603d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106044:	eb 04                	jmp    8010604a <strlen+0x13>
80106046:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010604a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010604d:	8b 45 08             	mov    0x8(%ebp),%eax
80106050:	01 d0                	add    %edx,%eax
80106052:	0f b6 00             	movzbl (%eax),%eax
80106055:	84 c0                	test   %al,%al
80106057:	75 ed                	jne    80106046 <strlen+0xf>
    ;
  return n;
80106059:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010605c:	c9                   	leave  
8010605d:	c3                   	ret    

8010605e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010605e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106062:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106066:	55                   	push   %ebp
  pushl %ebx
80106067:	53                   	push   %ebx
  pushl %esi
80106068:	56                   	push   %esi
  pushl %edi
80106069:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010606a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010606c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010606e:	5f                   	pop    %edi
  popl %esi
8010606f:	5e                   	pop    %esi
  popl %ebx
80106070:	5b                   	pop    %ebx
  popl %ebp
80106071:	5d                   	pop    %ebp
  ret
80106072:	c3                   	ret    

80106073 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106073:	55                   	push   %ebp
80106074:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106076:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010607c:	8b 00                	mov    (%eax),%eax
8010607e:	3b 45 08             	cmp    0x8(%ebp),%eax
80106081:	76 12                	jbe    80106095 <fetchint+0x22>
80106083:	8b 45 08             	mov    0x8(%ebp),%eax
80106086:	8d 50 04             	lea    0x4(%eax),%edx
80106089:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010608f:	8b 00                	mov    (%eax),%eax
80106091:	39 c2                	cmp    %eax,%edx
80106093:	76 07                	jbe    8010609c <fetchint+0x29>
    return -1;
80106095:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609a:	eb 0f                	jmp    801060ab <fetchint+0x38>
  *ip = *(int*)(addr);
8010609c:	8b 45 08             	mov    0x8(%ebp),%eax
8010609f:	8b 10                	mov    (%eax),%edx
801060a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801060a4:	89 10                	mov    %edx,(%eax)
  return 0;
801060a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ab:	5d                   	pop    %ebp
801060ac:	c3                   	ret    

801060ad <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060ad:	55                   	push   %ebp
801060ae:	89 e5                	mov    %esp,%ebp
801060b0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060b9:	8b 00                	mov    (%eax),%eax
801060bb:	3b 45 08             	cmp    0x8(%ebp),%eax
801060be:	77 07                	ja     801060c7 <fetchstr+0x1a>
    return -1;
801060c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c5:	eb 46                	jmp    8010610d <fetchstr+0x60>
  *pp = (char*)addr;
801060c7:	8b 55 08             	mov    0x8(%ebp),%edx
801060ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801060cd:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d5:	8b 00                	mov    (%eax),%eax
801060d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060da:	8b 45 0c             	mov    0xc(%ebp),%eax
801060dd:	8b 00                	mov    (%eax),%eax
801060df:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060e2:	eb 1c                	jmp    80106100 <fetchstr+0x53>
    if(*s == 0)
801060e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060e7:	0f b6 00             	movzbl (%eax),%eax
801060ea:	84 c0                	test   %al,%al
801060ec:	75 0e                	jne    801060fc <fetchstr+0x4f>
      return s - *pp;
801060ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f4:	8b 00                	mov    (%eax),%eax
801060f6:	29 c2                	sub    %eax,%edx
801060f8:	89 d0                	mov    %edx,%eax
801060fa:	eb 11                	jmp    8010610d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106100:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106103:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106106:	72 dc                	jb     801060e4 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010610d:	c9                   	leave  
8010610e:	c3                   	ret    

8010610f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010610f:	55                   	push   %ebp
80106110:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106112:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106118:	8b 40 18             	mov    0x18(%eax),%eax
8010611b:	8b 40 44             	mov    0x44(%eax),%eax
8010611e:	8b 55 08             	mov    0x8(%ebp),%edx
80106121:	c1 e2 02             	shl    $0x2,%edx
80106124:	01 d0                	add    %edx,%eax
80106126:	83 c0 04             	add    $0x4,%eax
80106129:	ff 75 0c             	pushl  0xc(%ebp)
8010612c:	50                   	push   %eax
8010612d:	e8 41 ff ff ff       	call   80106073 <fetchint>
80106132:	83 c4 08             	add    $0x8,%esp
}
80106135:	c9                   	leave  
80106136:	c3                   	ret    

80106137 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106137:	55                   	push   %ebp
80106138:	89 e5                	mov    %esp,%ebp
8010613a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010613d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106140:	50                   	push   %eax
80106141:	ff 75 08             	pushl  0x8(%ebp)
80106144:	e8 c6 ff ff ff       	call   8010610f <argint>
80106149:	83 c4 08             	add    $0x8,%esp
8010614c:	85 c0                	test   %eax,%eax
8010614e:	79 07                	jns    80106157 <argptr+0x20>
    return -1;
80106150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106155:	eb 3b                	jmp    80106192 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106157:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615d:	8b 00                	mov    (%eax),%eax
8010615f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106162:	39 d0                	cmp    %edx,%eax
80106164:	76 16                	jbe    8010617c <argptr+0x45>
80106166:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106169:	89 c2                	mov    %eax,%edx
8010616b:	8b 45 10             	mov    0x10(%ebp),%eax
8010616e:	01 c2                	add    %eax,%edx
80106170:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106176:	8b 00                	mov    (%eax),%eax
80106178:	39 c2                	cmp    %eax,%edx
8010617a:	76 07                	jbe    80106183 <argptr+0x4c>
    return -1;
8010617c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106181:	eb 0f                	jmp    80106192 <argptr+0x5b>
  *pp = (char*)i;
80106183:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106186:	89 c2                	mov    %eax,%edx
80106188:	8b 45 0c             	mov    0xc(%ebp),%eax
8010618b:	89 10                	mov    %edx,(%eax)
  return 0;
8010618d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106192:	c9                   	leave  
80106193:	c3                   	ret    

80106194 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106194:	55                   	push   %ebp
80106195:	89 e5                	mov    %esp,%ebp
80106197:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010619a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010619d:	50                   	push   %eax
8010619e:	ff 75 08             	pushl  0x8(%ebp)
801061a1:	e8 69 ff ff ff       	call   8010610f <argint>
801061a6:	83 c4 08             	add    $0x8,%esp
801061a9:	85 c0                	test   %eax,%eax
801061ab:	79 07                	jns    801061b4 <argstr+0x20>
    return -1;
801061ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b2:	eb 0f                	jmp    801061c3 <argstr+0x2f>
  return fetchstr(addr, pp);
801061b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061b7:	ff 75 0c             	pushl  0xc(%ebp)
801061ba:	50                   	push   %eax
801061bb:	e8 ed fe ff ff       	call   801060ad <fetchstr>
801061c0:	83 c4 08             	add    $0x8,%esp
}
801061c3:	c9                   	leave  
801061c4:	c3                   	ret    

801061c5 <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061c5:	55                   	push   %ebp
801061c6:	89 e5                	mov    %esp,%ebp
801061c8:	53                   	push   %ebx
801061c9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061d2:	8b 40 18             	mov    0x18(%eax),%eax
801061d5:	8b 40 1c             	mov    0x1c(%eax),%eax
801061d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061df:	7e 30                	jle    80106211 <syscall+0x4c>
801061e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e4:	83 f8 16             	cmp    $0x16,%eax
801061e7:	77 28                	ja     80106211 <syscall+0x4c>
801061e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ec:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061f3:	85 c0                	test   %eax,%eax
801061f5:	74 1a                	je     80106211 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061fd:	8b 58 18             	mov    0x18(%eax),%ebx
80106200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106203:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010620a:	ff d0                	call   *%eax
8010620c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010620f:	eb 34                	jmp    80106245 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106211:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106217:	8d 50 6c             	lea    0x6c(%eax),%edx
8010621a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106220:	8b 40 10             	mov    0x10(%eax),%eax
80106223:	ff 75 f4             	pushl  -0xc(%ebp)
80106226:	52                   	push   %edx
80106227:	50                   	push   %eax
80106228:	68 66 99 10 80       	push   $0x80109966
8010622d:	e8 94 a1 ff ff       	call   801003c6 <cprintf>
80106232:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106235:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010623b:	8b 40 18             	mov    0x18(%eax),%eax
8010623e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106245:	90                   	nop
80106246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106249:	c9                   	leave  
8010624a:	c3                   	ret    

8010624b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
8010624b:	55                   	push   %ebp
8010624c:	89 e5                	mov    %esp,%ebp
8010624e:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
80106251:	83 ec 08             	sub    $0x8,%esp
80106254:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106257:	50                   	push   %eax
80106258:	ff 75 08             	pushl  0x8(%ebp)
8010625b:	e8 af fe ff ff       	call   8010610f <argint>
80106260:	83 c4 10             	add    $0x10,%esp
80106263:	85 c0                	test   %eax,%eax
80106265:	79 07                	jns    8010626e <argfd+0x23>
        return -1;
80106267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626c:	eb 50                	jmp    801062be <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
8010626e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106271:	85 c0                	test   %eax,%eax
80106273:	78 21                	js     80106296 <argfd+0x4b>
80106275:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106278:	83 f8 0f             	cmp    $0xf,%eax
8010627b:	7f 19                	jg     80106296 <argfd+0x4b>
8010627d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106283:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106286:	83 c2 08             	add    $0x8,%edx
80106289:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010628d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106290:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106294:	75 07                	jne    8010629d <argfd+0x52>
        return -1;
80106296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629b:	eb 21                	jmp    801062be <argfd+0x73>
    if (pfd)
8010629d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062a1:	74 08                	je     801062ab <argfd+0x60>
        *pfd = fd;
801062a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801062a9:	89 10                	mov    %edx,(%eax)
    if (pf)
801062ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062af:	74 08                	je     801062b9 <argfd+0x6e>
        *pf = f;
801062b1:	8b 45 10             	mov    0x10(%ebp),%eax
801062b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b7:	89 10                	mov    %edx,(%eax)
    return 0;
801062b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062be:	c9                   	leave  
801062bf:	c3                   	ret    

801062c0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062c0:	55                   	push   %ebp
801062c1:	89 e5                	mov    %esp,%ebp
801062c3:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062cd:	eb 30                	jmp    801062ff <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062d8:	83 c2 08             	add    $0x8,%edx
801062db:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062df:	85 c0                	test   %eax,%eax
801062e1:	75 18                	jne    801062fb <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062ec:	8d 4a 08             	lea    0x8(%edx),%ecx
801062ef:	8b 55 08             	mov    0x8(%ebp),%edx
801062f2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801062f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062f9:	eb 0f                	jmp    8010630a <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062ff:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106303:	7e ca                	jle    801062cf <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
80106305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010630a:	c9                   	leave  
8010630b:	c3                   	ret    

8010630c <sys_dup>:

int sys_dup(void)
{
8010630c:	55                   	push   %ebp
8010630d:	89 e5                	mov    %esp,%ebp
8010630f:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
80106312:	83 ec 04             	sub    $0x4,%esp
80106315:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106318:	50                   	push   %eax
80106319:	6a 00                	push   $0x0
8010631b:	6a 00                	push   $0x0
8010631d:	e8 29 ff ff ff       	call   8010624b <argfd>
80106322:	83 c4 10             	add    $0x10,%esp
80106325:	85 c0                	test   %eax,%eax
80106327:	79 07                	jns    80106330 <sys_dup+0x24>
        return -1;
80106329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632e:	eb 31                	jmp    80106361 <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106330:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106333:	83 ec 0c             	sub    $0xc,%esp
80106336:	50                   	push   %eax
80106337:	e8 84 ff ff ff       	call   801062c0 <fdalloc>
8010633c:	83 c4 10             	add    $0x10,%esp
8010633f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106342:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106346:	79 07                	jns    8010634f <sys_dup+0x43>
        return -1;
80106348:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634d:	eb 12                	jmp    80106361 <sys_dup+0x55>
    filedup(f);
8010634f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106352:	83 ec 0c             	sub    $0xc,%esp
80106355:	50                   	push   %eax
80106356:	e8 fd ac ff ff       	call   80101058 <filedup>
8010635b:	83 c4 10             	add    $0x10,%esp
    return fd;
8010635e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106361:	c9                   	leave  
80106362:	c3                   	ret    

80106363 <sys_read>:

int sys_read(void)
{
80106363:	55                   	push   %ebp
80106364:	89 e5                	mov    %esp,%ebp
80106366:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106369:	83 ec 04             	sub    $0x4,%esp
8010636c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010636f:	50                   	push   %eax
80106370:	6a 00                	push   $0x0
80106372:	6a 00                	push   $0x0
80106374:	e8 d2 fe ff ff       	call   8010624b <argfd>
80106379:	83 c4 10             	add    $0x10,%esp
8010637c:	85 c0                	test   %eax,%eax
8010637e:	78 2e                	js     801063ae <sys_read+0x4b>
80106380:	83 ec 08             	sub    $0x8,%esp
80106383:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106386:	50                   	push   %eax
80106387:	6a 02                	push   $0x2
80106389:	e8 81 fd ff ff       	call   8010610f <argint>
8010638e:	83 c4 10             	add    $0x10,%esp
80106391:	85 c0                	test   %eax,%eax
80106393:	78 19                	js     801063ae <sys_read+0x4b>
80106395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106398:	83 ec 04             	sub    $0x4,%esp
8010639b:	50                   	push   %eax
8010639c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010639f:	50                   	push   %eax
801063a0:	6a 01                	push   $0x1
801063a2:	e8 90 fd ff ff       	call   80106137 <argptr>
801063a7:	83 c4 10             	add    $0x10,%esp
801063aa:	85 c0                	test   %eax,%eax
801063ac:	79 07                	jns    801063b5 <sys_read+0x52>
        return -1;
801063ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b3:	eb 17                	jmp    801063cc <sys_read+0x69>
    return fileread(f, p, n);
801063b5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063be:	83 ec 04             	sub    $0x4,%esp
801063c1:	51                   	push   %ecx
801063c2:	52                   	push   %edx
801063c3:	50                   	push   %eax
801063c4:	e8 47 ae ff ff       	call   80101210 <fileread>
801063c9:	83 c4 10             	add    $0x10,%esp
}
801063cc:	c9                   	leave  
801063cd:	c3                   	ret    

801063ce <sys_write>:

int sys_write(void)
{
801063ce:	55                   	push   %ebp
801063cf:	89 e5                	mov    %esp,%ebp
801063d1:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063d4:	83 ec 04             	sub    $0x4,%esp
801063d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063da:	50                   	push   %eax
801063db:	6a 00                	push   $0x0
801063dd:	6a 00                	push   $0x0
801063df:	e8 67 fe ff ff       	call   8010624b <argfd>
801063e4:	83 c4 10             	add    $0x10,%esp
801063e7:	85 c0                	test   %eax,%eax
801063e9:	78 2e                	js     80106419 <sys_write+0x4b>
801063eb:	83 ec 08             	sub    $0x8,%esp
801063ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f1:	50                   	push   %eax
801063f2:	6a 02                	push   $0x2
801063f4:	e8 16 fd ff ff       	call   8010610f <argint>
801063f9:	83 c4 10             	add    $0x10,%esp
801063fc:	85 c0                	test   %eax,%eax
801063fe:	78 19                	js     80106419 <sys_write+0x4b>
80106400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106403:	83 ec 04             	sub    $0x4,%esp
80106406:	50                   	push   %eax
80106407:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010640a:	50                   	push   %eax
8010640b:	6a 01                	push   $0x1
8010640d:	e8 25 fd ff ff       	call   80106137 <argptr>
80106412:	83 c4 10             	add    $0x10,%esp
80106415:	85 c0                	test   %eax,%eax
80106417:	79 07                	jns    80106420 <sys_write+0x52>
        return -1;
80106419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641e:	eb 17                	jmp    80106437 <sys_write+0x69>
    return filewrite(f, p, n);
80106420:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106423:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106429:	83 ec 04             	sub    $0x4,%esp
8010642c:	51                   	push   %ecx
8010642d:	52                   	push   %edx
8010642e:	50                   	push   %eax
8010642f:	e8 94 ae ff ff       	call   801012c8 <filewrite>
80106434:	83 c4 10             	add    $0x10,%esp
}
80106437:	c9                   	leave  
80106438:	c3                   	ret    

80106439 <sys_close>:

int sys_close(void)
{
80106439:	55                   	push   %ebp
8010643a:	89 e5                	mov    %esp,%ebp
8010643c:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
8010643f:	83 ec 04             	sub    $0x4,%esp
80106442:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106445:	50                   	push   %eax
80106446:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106449:	50                   	push   %eax
8010644a:	6a 00                	push   $0x0
8010644c:	e8 fa fd ff ff       	call   8010624b <argfd>
80106451:	83 c4 10             	add    $0x10,%esp
80106454:	85 c0                	test   %eax,%eax
80106456:	79 07                	jns    8010645f <sys_close+0x26>
        return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	eb 28                	jmp    80106487 <sys_close+0x4e>
    proc->ofile[fd] = 0;
8010645f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106465:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106468:	83 c2 08             	add    $0x8,%edx
8010646b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106472:	00 
    fileclose(f);
80106473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106476:	83 ec 0c             	sub    $0xc,%esp
80106479:	50                   	push   %eax
8010647a:	e8 2a ac ff ff       	call   801010a9 <fileclose>
8010647f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106482:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106487:	c9                   	leave  
80106488:	c3                   	ret    

80106489 <sys_fstat>:

int sys_fstat(void)
{
80106489:	55                   	push   %ebp
8010648a:	89 e5                	mov    %esp,%ebp
8010648c:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010648f:	83 ec 04             	sub    $0x4,%esp
80106492:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106495:	50                   	push   %eax
80106496:	6a 00                	push   $0x0
80106498:	6a 00                	push   $0x0
8010649a:	e8 ac fd ff ff       	call   8010624b <argfd>
8010649f:	83 c4 10             	add    $0x10,%esp
801064a2:	85 c0                	test   %eax,%eax
801064a4:	78 17                	js     801064bd <sys_fstat+0x34>
801064a6:	83 ec 04             	sub    $0x4,%esp
801064a9:	6a 14                	push   $0x14
801064ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ae:	50                   	push   %eax
801064af:	6a 01                	push   $0x1
801064b1:	e8 81 fc ff ff       	call   80106137 <argptr>
801064b6:	83 c4 10             	add    $0x10,%esp
801064b9:	85 c0                	test   %eax,%eax
801064bb:	79 07                	jns    801064c4 <sys_fstat+0x3b>
        return -1;
801064bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c2:	eb 13                	jmp    801064d7 <sys_fstat+0x4e>
    return filestat(f, st);
801064c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ca:	83 ec 08             	sub    $0x8,%esp
801064cd:	52                   	push   %edx
801064ce:	50                   	push   %eax
801064cf:	e8 e5 ac ff ff       	call   801011b9 <filestat>
801064d4:	83 c4 10             	add    $0x10,%esp
}
801064d7:	c9                   	leave  
801064d8:	c3                   	ret    

801064d9 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064d9:	55                   	push   %ebp
801064da:	89 e5                	mov    %esp,%ebp
801064dc:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064df:	83 ec 08             	sub    $0x8,%esp
801064e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064e5:	50                   	push   %eax
801064e6:	6a 00                	push   $0x0
801064e8:	e8 a7 fc ff ff       	call   80106194 <argstr>
801064ed:	83 c4 10             	add    $0x10,%esp
801064f0:	85 c0                	test   %eax,%eax
801064f2:	78 15                	js     80106509 <sys_link+0x30>
801064f4:	83 ec 08             	sub    $0x8,%esp
801064f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064fa:	50                   	push   %eax
801064fb:	6a 01                	push   $0x1
801064fd:	e8 92 fc ff ff       	call   80106194 <argstr>
80106502:	83 c4 10             	add    $0x10,%esp
80106505:	85 c0                	test   %eax,%eax
80106507:	79 0a                	jns    80106513 <sys_link+0x3a>
        return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	e9 da 01 00 00       	jmp    801066ed <sys_link+0x214>

    begin_op(proc->cwd->part->number);
80106513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106519:	8b 40 68             	mov    0x68(%eax),%eax
8010651c:	8b 40 50             	mov    0x50(%eax),%eax
8010651f:	8b 40 14             	mov    0x14(%eax),%eax
80106522:	83 ec 0c             	sub    $0xc,%esp
80106525:	50                   	push   %eax
80106526:	e8 7e d9 ff ff       	call   80103ea9 <begin_op>
8010652b:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
8010652e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106531:	83 ec 0c             	sub    $0xc,%esp
80106534:	50                   	push   %eax
80106535:	e8 d1 c7 ff ff       	call   80102d0b <namei>
8010653a:	83 c4 10             	add    $0x10,%esp
8010653d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106540:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106544:	75 25                	jne    8010656b <sys_link+0x92>
        end_op(proc->cwd->part->number);
80106546:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010654c:	8b 40 68             	mov    0x68(%eax),%eax
8010654f:	8b 40 50             	mov    0x50(%eax),%eax
80106552:	8b 40 14             	mov    0x14(%eax),%eax
80106555:	83 ec 0c             	sub    $0xc,%esp
80106558:	50                   	push   %eax
80106559:	e8 52 da ff ff       	call   80103fb0 <end_op>
8010655e:	83 c4 10             	add    $0x10,%esp
        return -1;
80106561:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106566:	e9 82 01 00 00       	jmp    801066ed <sys_link+0x214>
    }

    ilock(ip);
8010656b:	83 ec 0c             	sub    $0xc,%esp
8010656e:	ff 75 f4             	pushl  -0xc(%ebp)
80106571:	e8 7c b9 ff ff       	call   80101ef2 <ilock>
80106576:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106580:	66 83 f8 01          	cmp    $0x1,%ax
80106584:	75 33                	jne    801065b9 <sys_link+0xe0>
        iunlockput(ip);
80106586:	83 ec 0c             	sub    $0xc,%esp
80106589:	ff 75 f4             	pushl  -0xc(%ebp)
8010658c:	e8 64 bc ff ff       	call   801021f5 <iunlockput>
80106591:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106594:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010659a:	8b 40 68             	mov    0x68(%eax),%eax
8010659d:	8b 40 50             	mov    0x50(%eax),%eax
801065a0:	8b 40 14             	mov    0x14(%eax),%eax
801065a3:	83 ec 0c             	sub    $0xc,%esp
801065a6:	50                   	push   %eax
801065a7:	e8 04 da ff ff       	call   80103fb0 <end_op>
801065ac:	83 c4 10             	add    $0x10,%esp
        return -1;
801065af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b4:	e9 34 01 00 00       	jmp    801066ed <sys_link+0x214>
    }

    ip->nlink++;
801065b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065c0:	83 c0 01             	add    $0x1,%eax
801065c3:	89 c2                	mov    %eax,%edx
801065c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065cc:	83 ec 0c             	sub    $0xc,%esp
801065cf:	ff 75 f4             	pushl  -0xc(%ebp)
801065d2:	e8 bd b6 ff ff       	call   80101c94 <iupdate>
801065d7:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065da:	83 ec 0c             	sub    $0xc,%esp
801065dd:	ff 75 f4             	pushl  -0xc(%ebp)
801065e0:	e8 ae ba ff ff       	call   80102093 <iunlock>
801065e5:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065eb:	83 ec 08             	sub    $0x8,%esp
801065ee:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065f1:	52                   	push   %edx
801065f2:	50                   	push   %eax
801065f3:	e8 49 c7 ff ff       	call   80102d41 <nameiparent>
801065f8:	83 c4 10             	add    $0x10,%esp
801065fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106602:	0f 84 87 00 00 00    	je     8010668f <sys_link+0x1b6>
        goto bad;
    ilock(dp);
80106608:	83 ec 0c             	sub    $0xc,%esp
8010660b:	ff 75 f0             	pushl  -0x10(%ebp)
8010660e:	e8 df b8 ff ff       	call   80101ef2 <ilock>
80106613:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
80106616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106619:	8b 10                	mov    (%eax),%edx
8010661b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661e:	8b 00                	mov    (%eax),%eax
80106620:	39 c2                	cmp    %eax,%edx
80106622:	75 1d                	jne    80106641 <sys_link+0x168>
80106624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106627:	8b 40 04             	mov    0x4(%eax),%eax
8010662a:	83 ec 04             	sub    $0x4,%esp
8010662d:	50                   	push   %eax
8010662e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106631:	50                   	push   %eax
80106632:	ff 75 f0             	pushl  -0x10(%ebp)
80106635:	e8 a3 c3 ff ff       	call   801029dd <dirlink>
8010663a:	83 c4 10             	add    $0x10,%esp
8010663d:	85 c0                	test   %eax,%eax
8010663f:	79 10                	jns    80106651 <sys_link+0x178>
        iunlockput(dp);
80106641:	83 ec 0c             	sub    $0xc,%esp
80106644:	ff 75 f0             	pushl  -0x10(%ebp)
80106647:	e8 a9 bb ff ff       	call   801021f5 <iunlockput>
8010664c:	83 c4 10             	add    $0x10,%esp
        goto bad;
8010664f:	eb 3f                	jmp    80106690 <sys_link+0x1b7>
    }
    iunlockput(dp);
80106651:	83 ec 0c             	sub    $0xc,%esp
80106654:	ff 75 f0             	pushl  -0x10(%ebp)
80106657:	e8 99 bb ff ff       	call   801021f5 <iunlockput>
8010665c:	83 c4 10             	add    $0x10,%esp
    iput(ip);
8010665f:	83 ec 0c             	sub    $0xc,%esp
80106662:	ff 75 f4             	pushl  -0xc(%ebp)
80106665:	e8 9b ba ff ff       	call   80102105 <iput>
8010666a:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010666d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106673:	8b 40 68             	mov    0x68(%eax),%eax
80106676:	8b 40 50             	mov    0x50(%eax),%eax
80106679:	8b 40 14             	mov    0x14(%eax),%eax
8010667c:	83 ec 0c             	sub    $0xc,%esp
8010667f:	50                   	push   %eax
80106680:	e8 2b d9 ff ff       	call   80103fb0 <end_op>
80106685:	83 c4 10             	add    $0x10,%esp

    return 0;
80106688:	b8 00 00 00 00       	mov    $0x0,%eax
8010668d:	eb 5e                	jmp    801066ed <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
8010668f:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
80106690:	83 ec 0c             	sub    $0xc,%esp
80106693:	ff 75 f4             	pushl  -0xc(%ebp)
80106696:	e8 57 b8 ff ff       	call   80101ef2 <ilock>
8010669b:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
8010669e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066a5:	83 e8 01             	sub    $0x1,%eax
801066a8:	89 c2                	mov    %eax,%edx
801066aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ad:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801066b1:	83 ec 0c             	sub    $0xc,%esp
801066b4:	ff 75 f4             	pushl  -0xc(%ebp)
801066b7:	e8 d8 b5 ff ff       	call   80101c94 <iupdate>
801066bc:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066bf:	83 ec 0c             	sub    $0xc,%esp
801066c2:	ff 75 f4             	pushl  -0xc(%ebp)
801066c5:	e8 2b bb ff ff       	call   801021f5 <iunlockput>
801066ca:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066d3:	8b 40 68             	mov    0x68(%eax),%eax
801066d6:	8b 40 50             	mov    0x50(%eax),%eax
801066d9:	8b 40 14             	mov    0x14(%eax),%eax
801066dc:	83 ec 0c             	sub    $0xc,%esp
801066df:	50                   	push   %eax
801066e0:	e8 cb d8 ff ff       	call   80103fb0 <end_op>
801066e5:	83 c4 10             	add    $0x10,%esp
    return -1;
801066e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066ed:	c9                   	leave  
801066ee:	c3                   	ret    

801066ef <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066ef:	55                   	push   %ebp
801066f0:	89 e5                	mov    %esp,%ebp
801066f2:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801066f5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066fc:	eb 40                	jmp    8010673e <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106701:	6a 10                	push   $0x10
80106703:	50                   	push   %eax
80106704:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106707:	50                   	push   %eax
80106708:	ff 75 08             	pushl  0x8(%ebp)
8010670b:	e8 70 be ff ff       	call   80102580 <readi>
80106710:	83 c4 10             	add    $0x10,%esp
80106713:	83 f8 10             	cmp    $0x10,%eax
80106716:	74 0d                	je     80106725 <isdirempty+0x36>
            panic("isdirempty: readi");
80106718:	83 ec 0c             	sub    $0xc,%esp
8010671b:	68 82 99 10 80       	push   $0x80109982
80106720:	e8 41 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
80106725:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106729:	66 85 c0             	test   %ax,%ax
8010672c:	74 07                	je     80106735 <isdirempty+0x46>
            return 0;
8010672e:	b8 00 00 00 00       	mov    $0x0,%eax
80106733:	eb 1b                	jmp    80106750 <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80106735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106738:	83 c0 10             	add    $0x10,%eax
8010673b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010673e:	8b 45 08             	mov    0x8(%ebp),%eax
80106741:	8b 50 18             	mov    0x18(%eax),%edx
80106744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106747:	39 c2                	cmp    %eax,%edx
80106749:	77 b3                	ja     801066fe <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
8010674b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106750:	c9                   	leave  
80106751:	c3                   	ret    

80106752 <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
80106752:	55                   	push   %ebp
80106753:	89 e5                	mov    %esp,%ebp
80106755:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106758:	83 ec 08             	sub    $0x8,%esp
8010675b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010675e:	50                   	push   %eax
8010675f:	6a 00                	push   $0x0
80106761:	e8 2e fa ff ff       	call   80106194 <argstr>
80106766:	83 c4 10             	add    $0x10,%esp
80106769:	85 c0                	test   %eax,%eax
8010676b:	79 0a                	jns    80106777 <sys_unlink+0x25>
        return -1;
8010676d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106772:	e9 14 02 00 00       	jmp    8010698b <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
80106777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010677d:	8b 40 68             	mov    0x68(%eax),%eax
80106780:	8b 40 50             	mov    0x50(%eax),%eax
80106783:	8b 40 14             	mov    0x14(%eax),%eax
80106786:	83 ec 0c             	sub    $0xc,%esp
80106789:	50                   	push   %eax
8010678a:	e8 1a d7 ff ff       	call   80103ea9 <begin_op>
8010678f:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
80106792:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106795:	83 ec 08             	sub    $0x8,%esp
80106798:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010679b:	52                   	push   %edx
8010679c:	50                   	push   %eax
8010679d:	e8 9f c5 ff ff       	call   80102d41 <nameiparent>
801067a2:	83 c4 10             	add    $0x10,%esp
801067a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ac:	75 25                	jne    801067d3 <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
801067ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067b4:	8b 40 68             	mov    0x68(%eax),%eax
801067b7:	8b 40 50             	mov    0x50(%eax),%eax
801067ba:	8b 40 14             	mov    0x14(%eax),%eax
801067bd:	83 ec 0c             	sub    $0xc,%esp
801067c0:	50                   	push   %eax
801067c1:	e8 ea d7 ff ff       	call   80103fb0 <end_op>
801067c6:	83 c4 10             	add    $0x10,%esp
        return -1;
801067c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ce:	e9 b8 01 00 00       	jmp    8010698b <sys_unlink+0x239>
    }

    ilock(dp);
801067d3:	83 ec 0c             	sub    $0xc,%esp
801067d6:	ff 75 f4             	pushl  -0xc(%ebp)
801067d9:	e8 14 b7 ff ff       	call   80101ef2 <ilock>
801067de:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067e1:	83 ec 08             	sub    $0x8,%esp
801067e4:	68 94 99 10 80       	push   $0x80109994
801067e9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067ec:	50                   	push   %eax
801067ed:	e8 09 c1 ff ff       	call   801028fb <namecmp>
801067f2:	83 c4 10             	add    $0x10,%esp
801067f5:	85 c0                	test   %eax,%eax
801067f7:	0f 84 60 01 00 00    	je     8010695d <sys_unlink+0x20b>
801067fd:	83 ec 08             	sub    $0x8,%esp
80106800:	68 96 99 10 80       	push   $0x80109996
80106805:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106808:	50                   	push   %eax
80106809:	e8 ed c0 ff ff       	call   801028fb <namecmp>
8010680e:	83 c4 10             	add    $0x10,%esp
80106811:	85 c0                	test   %eax,%eax
80106813:	0f 84 44 01 00 00    	je     8010695d <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
80106819:	83 ec 04             	sub    $0x4,%esp
8010681c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010681f:	50                   	push   %eax
80106820:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106823:	50                   	push   %eax
80106824:	ff 75 f4             	pushl  -0xc(%ebp)
80106827:	e8 ea c0 ff ff       	call   80102916 <dirlookup>
8010682c:	83 c4 10             	add    $0x10,%esp
8010682f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106832:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106836:	0f 84 20 01 00 00    	je     8010695c <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
8010683c:	83 ec 0c             	sub    $0xc,%esp
8010683f:	ff 75 f0             	pushl  -0x10(%ebp)
80106842:	e8 ab b6 ff ff       	call   80101ef2 <ilock>
80106847:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
8010684a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010684d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106851:	66 85 c0             	test   %ax,%ax
80106854:	7f 0d                	jg     80106863 <sys_unlink+0x111>
        panic("unlink: nlink < 1");
80106856:	83 ec 0c             	sub    $0xc,%esp
80106859:	68 99 99 10 80       	push   $0x80109999
8010685e:	e8 03 9d ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
80106863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106866:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010686a:	66 83 f8 01          	cmp    $0x1,%ax
8010686e:	75 25                	jne    80106895 <sys_unlink+0x143>
80106870:	83 ec 0c             	sub    $0xc,%esp
80106873:	ff 75 f0             	pushl  -0x10(%ebp)
80106876:	e8 74 fe ff ff       	call   801066ef <isdirempty>
8010687b:	83 c4 10             	add    $0x10,%esp
8010687e:	85 c0                	test   %eax,%eax
80106880:	75 13                	jne    80106895 <sys_unlink+0x143>
        iunlockput(ip);
80106882:	83 ec 0c             	sub    $0xc,%esp
80106885:	ff 75 f0             	pushl  -0x10(%ebp)
80106888:	e8 68 b9 ff ff       	call   801021f5 <iunlockput>
8010688d:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106890:	e9 c8 00 00 00       	jmp    8010695d <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
80106895:	83 ec 04             	sub    $0x4,%esp
80106898:	6a 10                	push   $0x10
8010689a:	6a 00                	push   $0x0
8010689c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010689f:	50                   	push   %eax
801068a0:	e8 45 f5 ff ff       	call   80105dea <memset>
801068a5:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801068a8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801068ab:	6a 10                	push   $0x10
801068ad:	50                   	push   %eax
801068ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068b1:	50                   	push   %eax
801068b2:	ff 75 f4             	pushl  -0xc(%ebp)
801068b5:	e8 66 be ff ff       	call   80102720 <writei>
801068ba:	83 c4 10             	add    $0x10,%esp
801068bd:	83 f8 10             	cmp    $0x10,%eax
801068c0:	74 0d                	je     801068cf <sys_unlink+0x17d>
        panic("unlink: writei");
801068c2:	83 ec 0c             	sub    $0xc,%esp
801068c5:	68 ab 99 10 80       	push   $0x801099ab
801068ca:	e8 97 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068d2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068d6:	66 83 f8 01          	cmp    $0x1,%ax
801068da:	75 21                	jne    801068fd <sys_unlink+0x1ab>
        dp->nlink--;
801068dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068df:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068e3:	83 e8 01             	sub    $0x1,%eax
801068e6:	89 c2                	mov    %eax,%edx
801068e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068eb:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068ef:	83 ec 0c             	sub    $0xc,%esp
801068f2:	ff 75 f4             	pushl  -0xc(%ebp)
801068f5:	e8 9a b3 ff ff       	call   80101c94 <iupdate>
801068fa:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
801068fd:	83 ec 0c             	sub    $0xc,%esp
80106900:	ff 75 f4             	pushl  -0xc(%ebp)
80106903:	e8 ed b8 ff ff       	call   801021f5 <iunlockput>
80106908:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
8010690b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010690e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106912:	83 e8 01             	sub    $0x1,%eax
80106915:	89 c2                	mov    %eax,%edx
80106917:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010691a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
8010691e:	83 ec 0c             	sub    $0xc,%esp
80106921:	ff 75 f0             	pushl  -0x10(%ebp)
80106924:	e8 6b b3 ff ff       	call   80101c94 <iupdate>
80106929:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010692c:	83 ec 0c             	sub    $0xc,%esp
8010692f:	ff 75 f0             	pushl  -0x10(%ebp)
80106932:	e8 be b8 ff ff       	call   801021f5 <iunlockput>
80106937:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010693a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106940:	8b 40 68             	mov    0x68(%eax),%eax
80106943:	8b 40 50             	mov    0x50(%eax),%eax
80106946:	8b 40 14             	mov    0x14(%eax),%eax
80106949:	83 ec 0c             	sub    $0xc,%esp
8010694c:	50                   	push   %eax
8010694d:	e8 5e d6 ff ff       	call   80103fb0 <end_op>
80106952:	83 c4 10             	add    $0x10,%esp

    return 0;
80106955:	b8 00 00 00 00       	mov    $0x0,%eax
8010695a:	eb 2f                	jmp    8010698b <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
8010695c:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
8010695d:	83 ec 0c             	sub    $0xc,%esp
80106960:	ff 75 f4             	pushl  -0xc(%ebp)
80106963:	e8 8d b8 ff ff       	call   801021f5 <iunlockput>
80106968:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
8010696b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106971:	8b 40 68             	mov    0x68(%eax),%eax
80106974:	8b 40 50             	mov    0x50(%eax),%eax
80106977:	8b 40 14             	mov    0x14(%eax),%eax
8010697a:	83 ec 0c             	sub    $0xc,%esp
8010697d:	50                   	push   %eax
8010697e:	e8 2d d6 ff ff       	call   80103fb0 <end_op>
80106983:	83 c4 10             	add    $0x10,%esp
    return -1;
80106986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010698b:	c9                   	leave  
8010698c:	c3                   	ret    

8010698d <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
8010698d:	55                   	push   %ebp
8010698e:	89 e5                	mov    %esp,%ebp
80106990:	83 ec 38             	sub    $0x38,%esp
80106993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106996:	8b 55 10             	mov    0x10(%ebp),%edx
80106999:	8b 45 14             	mov    0x14(%ebp),%eax
8010699c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801069a0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801069a4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
  //   cprintf("path %s\n",path);
    if ((dp = nameiparent(path, name)) == 0)
801069a8:	83 ec 08             	sub    $0x8,%esp
801069ab:	8d 45 de             	lea    -0x22(%ebp),%eax
801069ae:	50                   	push   %eax
801069af:	ff 75 08             	pushl  0x8(%ebp)
801069b2:	e8 8a c3 ff ff       	call   80102d41 <nameiparent>
801069b7:	83 c4 10             	add    $0x10,%esp
801069ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069c1:	75 0a                	jne    801069cd <create+0x40>
        return 0;
801069c3:	b8 00 00 00 00       	mov    $0x0,%eax
801069c8:	e9 fe 01 00 00       	jmp    80106bcb <create+0x23e>
        
             //cprintf("name %s  \n",name);

    ilock(dp);
801069cd:	83 ec 0c             	sub    $0xc,%esp
801069d0:	ff 75 f4             	pushl  -0xc(%ebp)
801069d3:	e8 1a b5 ff ff       	call   80101ef2 <ilock>
801069d8:	83 c4 10             	add    $0x10,%esp
    if(dp->part->number!=proc->cwd->part->number){
801069db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069de:	8b 40 50             	mov    0x50(%eax),%eax
801069e1:	8b 50 14             	mov    0x14(%eax),%edx
801069e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069ea:	8b 40 68             	mov    0x68(%eax),%eax
801069ed:	8b 40 50             	mov    0x50(%eax),%eax
801069f0:	8b 40 14             	mov    0x14(%eax),%eax
801069f3:	39 c2                	cmp    %eax,%edx
801069f5:	74 15                	je     80106a0c <create+0x7f>
        begin_op(dp->part->number);
801069f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069fa:	8b 40 50             	mov    0x50(%eax),%eax
801069fd:	8b 40 14             	mov    0x14(%eax),%eax
80106a00:	83 ec 0c             	sub    $0xc,%esp
80106a03:	50                   	push   %eax
80106a04:	e8 a0 d4 ff ff       	call   80103ea9 <begin_op>
80106a09:	83 c4 10             	add    $0x10,%esp
    }
    if ((ip = dirlookup(dp, name, &off)) != 0) {
80106a0c:	83 ec 04             	sub    $0x4,%esp
80106a0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a12:	50                   	push   %eax
80106a13:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a16:	50                   	push   %eax
80106a17:	ff 75 f4             	pushl  -0xc(%ebp)
80106a1a:	e8 f7 be ff ff       	call   80102916 <dirlookup>
80106a1f:	83 c4 10             	add    $0x10,%esp
80106a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a29:	74 50                	je     80106a7b <create+0xee>
        iunlockput(dp);
80106a2b:	83 ec 0c             	sub    $0xc,%esp
80106a2e:	ff 75 f4             	pushl  -0xc(%ebp)
80106a31:	e8 bf b7 ff ff       	call   801021f5 <iunlockput>
80106a36:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80106a39:	83 ec 0c             	sub    $0xc,%esp
80106a3c:	ff 75 f0             	pushl  -0x10(%ebp)
80106a3f:	e8 ae b4 ff ff       	call   80101ef2 <ilock>
80106a44:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
80106a47:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a4c:	75 15                	jne    80106a63 <create+0xd6>
80106a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a51:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a55:	66 83 f8 02          	cmp    $0x2,%ax
80106a59:	75 08                	jne    80106a63 <create+0xd6>
            return ip;
80106a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a5e:	e9 68 01 00 00       	jmp    80106bcb <create+0x23e>
        iunlockput(ip);
80106a63:	83 ec 0c             	sub    $0xc,%esp
80106a66:	ff 75 f0             	pushl  -0x10(%ebp)
80106a69:	e8 87 b7 ff ff       	call   801021f5 <iunlockput>
80106a6e:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a71:	b8 00 00 00 00       	mov    $0x0,%eax
80106a76:	e9 50 01 00 00       	jmp    80106bcb <create+0x23e>
    }
   // cprintf("dp is %d , %d \n",dp->inum, dp->part->number);
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7e:	8b 40 50             	mov    0x50(%eax),%eax
80106a81:	8b 40 14             	mov    0x14(%eax),%eax
80106a84:	89 c1                	mov    %eax,%ecx
80106a86:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8d:	8b 00                	mov    (%eax),%eax
80106a8f:	83 ec 04             	sub    $0x4,%esp
80106a92:	51                   	push   %ecx
80106a93:	52                   	push   %edx
80106a94:	50                   	push   %eax
80106a95:	e8 e1 b0 ff ff       	call   80101b7b <ialloc>
80106a9a:	83 c4 10             	add    $0x10,%esp
80106a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106aa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aa4:	75 0d                	jne    80106ab3 <create+0x126>
        panic("create: ialloc");
80106aa6:	83 ec 0c             	sub    $0xc,%esp
80106aa9:	68 ba 99 10 80       	push   $0x801099ba
80106aae:	e8 b3 9a ff ff       	call   80100566 <panic>

    ilock(ip);
80106ab3:	83 ec 0c             	sub    $0xc,%esp
80106ab6:	ff 75 f0             	pushl  -0x10(%ebp)
80106ab9:	e8 34 b4 ff ff       	call   80101ef2 <ilock>
80106abe:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ac4:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106ac8:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106acf:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106ad3:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ada:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    //cprintf("ip is %d , %d \n",ip->inum,ip->part->number);
    iupdate(ip);
80106ae0:	83 ec 0c             	sub    $0xc,%esp
80106ae3:	ff 75 f0             	pushl  -0x10(%ebp)
80106ae6:	e8 a9 b1 ff ff       	call   80101c94 <iupdate>
80106aeb:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106aee:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106af3:	75 6a                	jne    80106b5f <create+0x1d2>
        dp->nlink++;     // for ".."
80106af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106afc:	83 c0 01             	add    $0x1,%eax
80106aff:	89 c2                	mov    %eax,%edx
80106b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b04:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106b08:	83 ec 0c             	sub    $0xc,%esp
80106b0b:	ff 75 f4             	pushl  -0xc(%ebp)
80106b0e:	e8 81 b1 ff ff       	call   80101c94 <iupdate>
80106b13:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b19:	8b 40 04             	mov    0x4(%eax),%eax
80106b1c:	83 ec 04             	sub    $0x4,%esp
80106b1f:	50                   	push   %eax
80106b20:	68 94 99 10 80       	push   $0x80109994
80106b25:	ff 75 f0             	pushl  -0x10(%ebp)
80106b28:	e8 b0 be ff ff       	call   801029dd <dirlink>
80106b2d:	83 c4 10             	add    $0x10,%esp
80106b30:	85 c0                	test   %eax,%eax
80106b32:	78 1e                	js     80106b52 <create+0x1c5>
80106b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b37:	8b 40 04             	mov    0x4(%eax),%eax
80106b3a:	83 ec 04             	sub    $0x4,%esp
80106b3d:	50                   	push   %eax
80106b3e:	68 96 99 10 80       	push   $0x80109996
80106b43:	ff 75 f0             	pushl  -0x10(%ebp)
80106b46:	e8 92 be ff ff       	call   801029dd <dirlink>
80106b4b:	83 c4 10             	add    $0x10,%esp
80106b4e:	85 c0                	test   %eax,%eax
80106b50:	79 0d                	jns    80106b5f <create+0x1d2>
            panic("create dots");
80106b52:	83 ec 0c             	sub    $0xc,%esp
80106b55:	68 c9 99 10 80       	push   $0x801099c9
80106b5a:	e8 07 9a ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b62:	8b 40 04             	mov    0x4(%eax),%eax
80106b65:	83 ec 04             	sub    $0x4,%esp
80106b68:	50                   	push   %eax
80106b69:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b6c:	50                   	push   %eax
80106b6d:	ff 75 f4             	pushl  -0xc(%ebp)
80106b70:	e8 68 be ff ff       	call   801029dd <dirlink>
80106b75:	83 c4 10             	add    $0x10,%esp
80106b78:	85 c0                	test   %eax,%eax
80106b7a:	79 0d                	jns    80106b89 <create+0x1fc>
        panic("create: dirlink");
80106b7c:	83 ec 0c             	sub    $0xc,%esp
80106b7f:	68 d5 99 10 80       	push   $0x801099d5
80106b84:	e8 dd 99 ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b89:	83 ec 0c             	sub    $0xc,%esp
80106b8c:	ff 75 f4             	pushl  -0xc(%ebp)
80106b8f:	e8 61 b6 ff ff       	call   801021f5 <iunlockput>
80106b94:	83 c4 10             	add    $0x10,%esp
    
     if(dp->part->number!=proc->cwd->part->number){
80106b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9a:	8b 40 50             	mov    0x50(%eax),%eax
80106b9d:	8b 50 14             	mov    0x14(%eax),%edx
80106ba0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba6:	8b 40 68             	mov    0x68(%eax),%eax
80106ba9:	8b 40 50             	mov    0x50(%eax),%eax
80106bac:	8b 40 14             	mov    0x14(%eax),%eax
80106baf:	39 c2                	cmp    %eax,%edx
80106bb1:	74 15                	je     80106bc8 <create+0x23b>
        end_op(dp->part->number);
80106bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb6:	8b 40 50             	mov    0x50(%eax),%eax
80106bb9:	8b 40 14             	mov    0x14(%eax),%eax
80106bbc:	83 ec 0c             	sub    $0xc,%esp
80106bbf:	50                   	push   %eax
80106bc0:	e8 eb d3 ff ff       	call   80103fb0 <end_op>
80106bc5:	83 c4 10             	add    $0x10,%esp
    }
    return ip;
80106bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106bcb:	c9                   	leave  
80106bcc:	c3                   	ret    

80106bcd <sys_open>:

int sys_open(void)
{
80106bcd:	55                   	push   %ebp
80106bce:	89 e5                	mov    %esp,%ebp
80106bd0:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106bd3:	83 ec 08             	sub    $0x8,%esp
80106bd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bd9:	50                   	push   %eax
80106bda:	6a 00                	push   $0x0
80106bdc:	e8 b3 f5 ff ff       	call   80106194 <argstr>
80106be1:	83 c4 10             	add    $0x10,%esp
80106be4:	85 c0                	test   %eax,%eax
80106be6:	78 15                	js     80106bfd <sys_open+0x30>
80106be8:	83 ec 08             	sub    $0x8,%esp
80106beb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bee:	50                   	push   %eax
80106bef:	6a 01                	push   $0x1
80106bf1:	e8 19 f5 ff ff       	call   8010610f <argint>
80106bf6:	83 c4 10             	add    $0x10,%esp
80106bf9:	85 c0                	test   %eax,%eax
80106bfb:	79 07                	jns    80106c04 <sys_open+0x37>
        return -1;
80106bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c02:	eb 13                	jmp    80106c17 <sys_open+0x4a>

    return openFile(path, omode);
80106c04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0a:	83 ec 08             	sub    $0x8,%esp
80106c0d:	52                   	push   %edx
80106c0e:	50                   	push   %eax
80106c0f:	e8 05 00 00 00       	call   80106c19 <openFile>
80106c14:	83 c4 10             	add    $0x10,%esp
}
80106c17:	c9                   	leave  
80106c18:	c3                   	ret    

80106c19 <openFile>:

int openFile(char* path, int omode)
{
80106c19:	55                   	push   %ebp
80106c1a:	89 e5                	mov    %esp,%ebp
80106c1c:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106c1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c25:	8b 40 68             	mov    0x68(%eax),%eax
80106c28:	8b 40 50             	mov    0x50(%eax),%eax
80106c2b:	8b 40 14             	mov    0x14(%eax),%eax
80106c2e:	83 ec 0c             	sub    $0xc,%esp
80106c31:	50                   	push   %eax
80106c32:	e8 72 d2 ff ff       	call   80103ea9 <begin_op>
80106c37:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c3d:	25 00 02 00 00       	and    $0x200,%eax
80106c42:	85 c0                	test   %eax,%eax
80106c44:	74 43                	je     80106c89 <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106c46:	6a 00                	push   $0x0
80106c48:	6a 00                	push   $0x0
80106c4a:	6a 02                	push   $0x2
80106c4c:	ff 75 08             	pushl  0x8(%ebp)
80106c4f:	e8 39 fd ff ff       	call   8010698d <create>
80106c54:	83 c4 10             	add    $0x10,%esp
80106c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106c5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c5e:	0f 85 b5 00 00 00    	jne    80106d19 <openFile+0x100>
            end_op(proc->cwd->part->number);
80106c64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c6a:	8b 40 68             	mov    0x68(%eax),%eax
80106c6d:	8b 40 50             	mov    0x50(%eax),%eax
80106c70:	8b 40 14             	mov    0x14(%eax),%eax
80106c73:	83 ec 0c             	sub    $0xc,%esp
80106c76:	50                   	push   %eax
80106c77:	e8 34 d3 ff ff       	call   80103fb0 <end_op>
80106c7c:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c84:	e9 7f 01 00 00       	jmp    80106e08 <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c89:	83 ec 0c             	sub    $0xc,%esp
80106c8c:	ff 75 08             	pushl  0x8(%ebp)
80106c8f:	e8 77 c0 ff ff       	call   80102d0b <namei>
80106c94:	83 c4 10             	add    $0x10,%esp
80106c97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c9e:	75 25                	jne    80106cc5 <openFile+0xac>
            end_op(proc->cwd->part->number);
80106ca0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca6:	8b 40 68             	mov    0x68(%eax),%eax
80106ca9:	8b 40 50             	mov    0x50(%eax),%eax
80106cac:	8b 40 14             	mov    0x14(%eax),%eax
80106caf:	83 ec 0c             	sub    $0xc,%esp
80106cb2:	50                   	push   %eax
80106cb3:	e8 f8 d2 ff ff       	call   80103fb0 <end_op>
80106cb8:	83 c4 10             	add    $0x10,%esp
            return -1;
80106cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc0:	e9 43 01 00 00       	jmp    80106e08 <openFile+0x1ef>
        }
        ilock(ip);
80106cc5:	83 ec 0c             	sub    $0xc,%esp
80106cc8:	ff 75 f4             	pushl  -0xc(%ebp)
80106ccb:	e8 22 b2 ff ff       	call   80101ef2 <ilock>
80106cd0:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106cda:	66 83 f8 01          	cmp    $0x1,%ax
80106cde:	75 39                	jne    80106d19 <openFile+0x100>
80106ce0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106ce4:	74 33                	je     80106d19 <openFile+0x100>
            iunlockput(ip);
80106ce6:	83 ec 0c             	sub    $0xc,%esp
80106ce9:	ff 75 f4             	pushl  -0xc(%ebp)
80106cec:	e8 04 b5 ff ff       	call   801021f5 <iunlockput>
80106cf1:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106cf4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cfa:	8b 40 68             	mov    0x68(%eax),%eax
80106cfd:	8b 40 50             	mov    0x50(%eax),%eax
80106d00:	8b 40 14             	mov    0x14(%eax),%eax
80106d03:	83 ec 0c             	sub    $0xc,%esp
80106d06:	50                   	push   %eax
80106d07:	e8 a4 d2 ff ff       	call   80103fb0 <end_op>
80106d0c:	83 c4 10             	add    $0x10,%esp
            return -1;
80106d0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d14:	e9 ef 00 00 00       	jmp    80106e08 <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106d19:	e8 cd a2 ff ff       	call   80100feb <filealloc>
80106d1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d25:	74 17                	je     80106d3e <openFile+0x125>
80106d27:	83 ec 0c             	sub    $0xc,%esp
80106d2a:	ff 75 f0             	pushl  -0x10(%ebp)
80106d2d:	e8 8e f5 ff ff       	call   801062c0 <fdalloc>
80106d32:	83 c4 10             	add    $0x10,%esp
80106d35:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106d38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106d3c:	79 47                	jns    80106d85 <openFile+0x16c>
        if (f)
80106d3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d42:	74 0e                	je     80106d52 <openFile+0x139>
            fileclose(f);
80106d44:	83 ec 0c             	sub    $0xc,%esp
80106d47:	ff 75 f0             	pushl  -0x10(%ebp)
80106d4a:	e8 5a a3 ff ff       	call   801010a9 <fileclose>
80106d4f:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106d52:	83 ec 0c             	sub    $0xc,%esp
80106d55:	ff 75 f4             	pushl  -0xc(%ebp)
80106d58:	e8 98 b4 ff ff       	call   801021f5 <iunlockput>
80106d5d:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106d60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d66:	8b 40 68             	mov    0x68(%eax),%eax
80106d69:	8b 40 50             	mov    0x50(%eax),%eax
80106d6c:	8b 40 14             	mov    0x14(%eax),%eax
80106d6f:	83 ec 0c             	sub    $0xc,%esp
80106d72:	50                   	push   %eax
80106d73:	e8 38 d2 ff ff       	call   80103fb0 <end_op>
80106d78:	83 c4 10             	add    $0x10,%esp
        return -1;
80106d7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d80:	e9 83 00 00 00       	jmp    80106e08 <openFile+0x1ef>
    }
    iunlock(ip);
80106d85:	83 ec 0c             	sub    $0xc,%esp
80106d88:	ff 75 f4             	pushl  -0xc(%ebp)
80106d8b:	e8 03 b3 ff ff       	call   80102093 <iunlock>
80106d90:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106d93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d99:	8b 40 68             	mov    0x68(%eax),%eax
80106d9c:	8b 40 50             	mov    0x50(%eax),%eax
80106d9f:	8b 40 14             	mov    0x14(%eax),%eax
80106da2:	83 ec 0c             	sub    $0xc,%esp
80106da5:	50                   	push   %eax
80106da6:	e8 05 d2 ff ff       	call   80103fb0 <end_op>
80106dab:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106db1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106dbd:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc3:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dcd:	83 e0 01             	and    $0x1,%eax
80106dd0:	85 c0                	test   %eax,%eax
80106dd2:	0f 94 c0             	sete   %al
80106dd5:	89 c2                	mov    %eax,%edx
80106dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dda:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106de0:	83 e0 01             	and    $0x1,%eax
80106de3:	85 c0                	test   %eax,%eax
80106de5:	75 0a                	jne    80106df1 <openFile+0x1d8>
80106de7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dea:	83 e0 02             	and    $0x2,%eax
80106ded:	85 c0                	test   %eax,%eax
80106def:	74 07                	je     80106df8 <openFile+0x1df>
80106df1:	b8 01 00 00 00       	mov    $0x1,%eax
80106df6:	eb 05                	jmp    80106dfd <openFile+0x1e4>
80106df8:	b8 00 00 00 00       	mov    $0x0,%eax
80106dfd:	89 c2                	mov    %eax,%edx
80106dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e02:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106e05:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106e08:	c9                   	leave  
80106e09:	c3                   	ret    

80106e0a <sys_mkdir>:

int sys_mkdir(void)
{
80106e0a:	55                   	push   %ebp
80106e0b:	89 e5                	mov    %esp,%ebp
80106e0d:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106e10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e16:	8b 40 68             	mov    0x68(%eax),%eax
80106e19:	8b 40 50             	mov    0x50(%eax),%eax
80106e1c:	8b 40 14             	mov    0x14(%eax),%eax
80106e1f:	83 ec 0c             	sub    $0xc,%esp
80106e22:	50                   	push   %eax
80106e23:	e8 81 d0 ff ff       	call   80103ea9 <begin_op>
80106e28:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106e2b:	83 ec 08             	sub    $0x8,%esp
80106e2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e31:	50                   	push   %eax
80106e32:	6a 00                	push   $0x0
80106e34:	e8 5b f3 ff ff       	call   80106194 <argstr>
80106e39:	83 c4 10             	add    $0x10,%esp
80106e3c:	85 c0                	test   %eax,%eax
80106e3e:	78 1b                	js     80106e5b <sys_mkdir+0x51>
80106e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e43:	6a 00                	push   $0x0
80106e45:	6a 00                	push   $0x0
80106e47:	6a 01                	push   $0x1
80106e49:	50                   	push   %eax
80106e4a:	e8 3e fb ff ff       	call   8010698d <create>
80106e4f:	83 c4 10             	add    $0x10,%esp
80106e52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e59:	75 22                	jne    80106e7d <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106e5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e61:	8b 40 68             	mov    0x68(%eax),%eax
80106e64:	8b 40 50             	mov    0x50(%eax),%eax
80106e67:	8b 40 14             	mov    0x14(%eax),%eax
80106e6a:	83 ec 0c             	sub    $0xc,%esp
80106e6d:	50                   	push   %eax
80106e6e:	e8 3d d1 ff ff       	call   80103fb0 <end_op>
80106e73:	83 c4 10             	add    $0x10,%esp
        return -1;
80106e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e7b:	eb 2e                	jmp    80106eab <sys_mkdir+0xa1>
    }
    //cprintf("returned \n");
    iunlockput(ip);
80106e7d:	83 ec 0c             	sub    $0xc,%esp
80106e80:	ff 75 f4             	pushl  -0xc(%ebp)
80106e83:	e8 6d b3 ff ff       	call   801021f5 <iunlockput>
80106e88:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e91:	8b 40 68             	mov    0x68(%eax),%eax
80106e94:	8b 40 50             	mov    0x50(%eax),%eax
80106e97:	8b 40 14             	mov    0x14(%eax),%eax
80106e9a:	83 ec 0c             	sub    $0xc,%esp
80106e9d:	50                   	push   %eax
80106e9e:	e8 0d d1 ff ff       	call   80103fb0 <end_op>
80106ea3:	83 c4 10             	add    $0x10,%esp
    return 0;
80106ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106eab:	c9                   	leave  
80106eac:	c3                   	ret    

80106ead <sys_mknod>:

int sys_mknod(void)
{
80106ead:	55                   	push   %ebp
80106eae:	89 e5                	mov    %esp,%ebp
80106eb0:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106eb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eb9:	8b 40 68             	mov    0x68(%eax),%eax
80106ebc:	8b 40 50             	mov    0x50(%eax),%eax
80106ebf:	8b 40 14             	mov    0x14(%eax),%eax
80106ec2:	83 ec 0c             	sub    $0xc,%esp
80106ec5:	50                   	push   %eax
80106ec6:	e8 de cf ff ff       	call   80103ea9 <begin_op>
80106ecb:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106ece:	83 ec 08             	sub    $0x8,%esp
80106ed1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ed4:	50                   	push   %eax
80106ed5:	6a 00                	push   $0x0
80106ed7:	e8 b8 f2 ff ff       	call   80106194 <argstr>
80106edc:	83 c4 10             	add    $0x10,%esp
80106edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ee2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ee6:	78 4f                	js     80106f37 <sys_mknod+0x8a>
80106ee8:	83 ec 08             	sub    $0x8,%esp
80106eeb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106eee:	50                   	push   %eax
80106eef:	6a 01                	push   $0x1
80106ef1:	e8 19 f2 ff ff       	call   8010610f <argint>
80106ef6:	83 c4 10             	add    $0x10,%esp
80106ef9:	85 c0                	test   %eax,%eax
80106efb:	78 3a                	js     80106f37 <sys_mknod+0x8a>
80106efd:	83 ec 08             	sub    $0x8,%esp
80106f00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f03:	50                   	push   %eax
80106f04:	6a 02                	push   $0x2
80106f06:	e8 04 f2 ff ff       	call   8010610f <argint>
80106f0b:	83 c4 10             	add    $0x10,%esp
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	78 25                	js     80106f37 <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f15:	0f bf c8             	movswl %ax,%ecx
80106f18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f1b:	0f bf d0             	movswl %ax,%edx
80106f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106f21:	51                   	push   %ecx
80106f22:	52                   	push   %edx
80106f23:	6a 03                	push   $0x3
80106f25:	50                   	push   %eax
80106f26:	e8 62 fa ff ff       	call   8010698d <create>
80106f2b:	83 c4 10             	add    $0x10,%esp
80106f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106f31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f35:	75 22                	jne    80106f59 <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106f37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f3d:	8b 40 68             	mov    0x68(%eax),%eax
80106f40:	8b 40 50             	mov    0x50(%eax),%eax
80106f43:	8b 40 14             	mov    0x14(%eax),%eax
80106f46:	83 ec 0c             	sub    $0xc,%esp
80106f49:	50                   	push   %eax
80106f4a:	e8 61 d0 ff ff       	call   80103fb0 <end_op>
80106f4f:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f57:	eb 2e                	jmp    80106f87 <sys_mknod+0xda>
    }
    iunlockput(ip);
80106f59:	83 ec 0c             	sub    $0xc,%esp
80106f5c:	ff 75 f0             	pushl  -0x10(%ebp)
80106f5f:	e8 91 b2 ff ff       	call   801021f5 <iunlockput>
80106f64:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106f67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f6d:	8b 40 68             	mov    0x68(%eax),%eax
80106f70:	8b 40 50             	mov    0x50(%eax),%eax
80106f73:	8b 40 14             	mov    0x14(%eax),%eax
80106f76:	83 ec 0c             	sub    $0xc,%esp
80106f79:	50                   	push   %eax
80106f7a:	e8 31 d0 ff ff       	call   80103fb0 <end_op>
80106f7f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f87:	c9                   	leave  
80106f88:	c3                   	ret    

80106f89 <sys_chdir>:

int sys_chdir(void)
{
80106f89:	55                   	push   %ebp
80106f8a:	89 e5                	mov    %esp,%ebp
80106f8c:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;


    begin_op(proc->cwd->part->number);
80106f8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f95:	8b 40 68             	mov    0x68(%eax),%eax
80106f98:	8b 40 50             	mov    0x50(%eax),%eax
80106f9b:	8b 40 14             	mov    0x14(%eax),%eax
80106f9e:	83 ec 0c             	sub    $0xc,%esp
80106fa1:	50                   	push   %eax
80106fa2:	e8 02 cf ff ff       	call   80103ea9 <begin_op>
80106fa7:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106faa:	83 ec 08             	sub    $0x8,%esp
80106fad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fb0:	50                   	push   %eax
80106fb1:	6a 00                	push   $0x0
80106fb3:	e8 dc f1 ff ff       	call   80106194 <argstr>
80106fb8:	83 c4 10             	add    $0x10,%esp
80106fbb:	85 c0                	test   %eax,%eax
80106fbd:	78 18                	js     80106fd7 <sys_chdir+0x4e>
80106fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fc2:	83 ec 0c             	sub    $0xc,%esp
80106fc5:	50                   	push   %eax
80106fc6:	e8 40 bd ff ff       	call   80102d0b <namei>
80106fcb:	83 c4 10             	add    $0x10,%esp
80106fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fd5:	75 25                	jne    80106ffc <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106fd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fdd:	8b 40 68             	mov    0x68(%eax),%eax
80106fe0:	8b 40 50             	mov    0x50(%eax),%eax
80106fe3:	8b 40 14             	mov    0x14(%eax),%eax
80106fe6:	83 ec 0c             	sub    $0xc,%esp
80106fe9:	50                   	push   %eax
80106fea:	e8 c1 cf ff ff       	call   80103fb0 <end_op>
80106fef:	83 c4 10             	add    $0x10,%esp
        return -1;
80106ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff7:	e9 9a 00 00 00       	jmp    80107096 <sys_chdir+0x10d>
    }
    //cprintf("cd path %s \n",path);
    ilock(ip);
80106ffc:	83 ec 0c             	sub    $0xc,%esp
80106fff:	ff 75 f4             	pushl  -0xc(%ebp)
80107002:	e8 eb ae ff ff       	call   80101ef2 <ilock>
80107007:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
8010700a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107011:	66 83 f8 01          	cmp    $0x1,%ax
80107015:	74 30                	je     80107047 <sys_chdir+0xbe>
        iunlockput(ip);
80107017:	83 ec 0c             	sub    $0xc,%esp
8010701a:	ff 75 f4             	pushl  -0xc(%ebp)
8010701d:	e8 d3 b1 ff ff       	call   801021f5 <iunlockput>
80107022:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80107025:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010702b:	8b 40 68             	mov    0x68(%eax),%eax
8010702e:	8b 40 50             	mov    0x50(%eax),%eax
80107031:	8b 40 14             	mov    0x14(%eax),%eax
80107034:	83 ec 0c             	sub    $0xc,%esp
80107037:	50                   	push   %eax
80107038:	e8 73 cf ff ff       	call   80103fb0 <end_op>
8010703d:	83 c4 10             	add    $0x10,%esp
        return -1;
80107040:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107045:	eb 4f                	jmp    80107096 <sys_chdir+0x10d>
    }
    iunlock(ip);
80107047:	83 ec 0c             	sub    $0xc,%esp
8010704a:	ff 75 f4             	pushl  -0xc(%ebp)
8010704d:	e8 41 b0 ff ff       	call   80102093 <iunlock>
80107052:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80107055:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010705b:	8b 40 68             	mov    0x68(%eax),%eax
8010705e:	83 ec 0c             	sub    $0xc,%esp
80107061:	50                   	push   %eax
80107062:	e8 9e b0 ff ff       	call   80102105 <iput>
80107067:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
8010706a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107070:	8b 40 68             	mov    0x68(%eax),%eax
80107073:	8b 40 50             	mov    0x50(%eax),%eax
80107076:	8b 40 14             	mov    0x14(%eax),%eax
80107079:	83 ec 0c             	sub    $0xc,%esp
8010707c:	50                   	push   %eax
8010707d:	e8 2e cf ff ff       	call   80103fb0 <end_op>
80107082:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
80107085:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010708b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010708e:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
80107091:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107096:	c9                   	leave  
80107097:	c3                   	ret    

80107098 <sys_exec>:

int sys_exec(void)
{
80107098:	55                   	push   %ebp
80107099:	89 e5                	mov    %esp,%ebp
8010709b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
801070a1:	83 ec 08             	sub    $0x8,%esp
801070a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070a7:	50                   	push   %eax
801070a8:	6a 00                	push   $0x0
801070aa:	e8 e5 f0 ff ff       	call   80106194 <argstr>
801070af:	83 c4 10             	add    $0x10,%esp
801070b2:	85 c0                	test   %eax,%eax
801070b4:	78 18                	js     801070ce <sys_exec+0x36>
801070b6:	83 ec 08             	sub    $0x8,%esp
801070b9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801070bf:	50                   	push   %eax
801070c0:	6a 01                	push   $0x1
801070c2:	e8 48 f0 ff ff       	call   8010610f <argint>
801070c7:	83 c4 10             	add    $0x10,%esp
801070ca:	85 c0                	test   %eax,%eax
801070cc:	79 0a                	jns    801070d8 <sys_exec+0x40>
        return -1;
801070ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d3:	e9 c6 00 00 00       	jmp    8010719e <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
801070d8:	83 ec 04             	sub    $0x4,%esp
801070db:	68 80 00 00 00       	push   $0x80
801070e0:	6a 00                	push   $0x0
801070e2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801070e8:	50                   	push   %eax
801070e9:	e8 fc ec ff ff       	call   80105dea <memset>
801070ee:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
801070f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
801070f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fb:	83 f8 1f             	cmp    $0x1f,%eax
801070fe:	76 0a                	jbe    8010710a <sys_exec+0x72>
            return -1;
80107100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107105:	e9 94 00 00 00       	jmp    8010719e <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
8010710a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710d:	c1 e0 02             	shl    $0x2,%eax
80107110:	89 c2                	mov    %eax,%edx
80107112:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107118:	01 c2                	add    %eax,%edx
8010711a:	83 ec 08             	sub    $0x8,%esp
8010711d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107123:	50                   	push   %eax
80107124:	52                   	push   %edx
80107125:	e8 49 ef ff ff       	call   80106073 <fetchint>
8010712a:	83 c4 10             	add    $0x10,%esp
8010712d:	85 c0                	test   %eax,%eax
8010712f:	79 07                	jns    80107138 <sys_exec+0xa0>
            return -1;
80107131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107136:	eb 66                	jmp    8010719e <sys_exec+0x106>
        if (uarg == 0) {
80107138:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010713e:	85 c0                	test   %eax,%eax
80107140:	75 27                	jne    80107169 <sys_exec+0xd1>
            argv[i] = 0;
80107142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107145:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010714c:	00 00 00 00 
            break;
80107150:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
80107151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107154:	83 ec 08             	sub    $0x8,%esp
80107157:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010715d:	52                   	push   %edx
8010715e:	50                   	push   %eax
8010715f:	e8 0d 9a ff ff       	call   80100b71 <exec>
80107164:	83 c4 10             	add    $0x10,%esp
80107167:	eb 35                	jmp    8010719e <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80107169:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010716f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107172:	c1 e2 02             	shl    $0x2,%edx
80107175:	01 c2                	add    %eax,%edx
80107177:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010717d:	83 ec 08             	sub    $0x8,%esp
80107180:	52                   	push   %edx
80107181:	50                   	push   %eax
80107182:	e8 26 ef ff ff       	call   801060ad <fetchstr>
80107187:	83 c4 10             	add    $0x10,%esp
8010718a:	85 c0                	test   %eax,%eax
8010718c:	79 07                	jns    80107195 <sys_exec+0xfd>
            return -1;
8010718e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107193:	eb 09                	jmp    8010719e <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
80107195:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
80107199:	e9 5a ff ff ff       	jmp    801070f8 <sys_exec+0x60>
    return exec(path, argv);
}
8010719e:	c9                   	leave  
8010719f:	c3                   	ret    

801071a0 <sys_pipe>:

int sys_pipe(void)
{
801071a0:	55                   	push   %ebp
801071a1:	89 e5                	mov    %esp,%ebp
801071a3:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
801071a6:	83 ec 04             	sub    $0x4,%esp
801071a9:	6a 08                	push   $0x8
801071ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
801071ae:	50                   	push   %eax
801071af:	6a 00                	push   $0x0
801071b1:	e8 81 ef ff ff       	call   80106137 <argptr>
801071b6:	83 c4 10             	add    $0x10,%esp
801071b9:	85 c0                	test   %eax,%eax
801071bb:	79 0a                	jns    801071c7 <sys_pipe+0x27>
        return -1;
801071bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c2:	e9 af 00 00 00       	jmp    80107276 <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
801071c7:	83 ec 08             	sub    $0x8,%esp
801071ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801071cd:	50                   	push   %eax
801071ce:	8d 45 e8             	lea    -0x18(%ebp),%eax
801071d1:	50                   	push   %eax
801071d2:	e8 a2 d9 ff ff       	call   80104b79 <pipealloc>
801071d7:	83 c4 10             	add    $0x10,%esp
801071da:	85 c0                	test   %eax,%eax
801071dc:	79 0a                	jns    801071e8 <sys_pipe+0x48>
        return -1;
801071de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e3:	e9 8e 00 00 00       	jmp    80107276 <sys_pipe+0xd6>
    fd0 = -1;
801071e8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
801071ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071f2:	83 ec 0c             	sub    $0xc,%esp
801071f5:	50                   	push   %eax
801071f6:	e8 c5 f0 ff ff       	call   801062c0 <fdalloc>
801071fb:	83 c4 10             	add    $0x10,%esp
801071fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107201:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107205:	78 18                	js     8010721f <sys_pipe+0x7f>
80107207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010720a:	83 ec 0c             	sub    $0xc,%esp
8010720d:	50                   	push   %eax
8010720e:	e8 ad f0 ff ff       	call   801062c0 <fdalloc>
80107213:	83 c4 10             	add    $0x10,%esp
80107216:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107219:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010721d:	79 3f                	jns    8010725e <sys_pipe+0xbe>
        if (fd0 >= 0)
8010721f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107223:	78 14                	js     80107239 <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
80107225:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010722b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010722e:	83 c2 08             	add    $0x8,%edx
80107231:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107238:	00 
        fileclose(rf);
80107239:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010723c:	83 ec 0c             	sub    $0xc,%esp
8010723f:	50                   	push   %eax
80107240:	e8 64 9e ff ff       	call   801010a9 <fileclose>
80107245:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
80107248:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010724b:	83 ec 0c             	sub    $0xc,%esp
8010724e:	50                   	push   %eax
8010724f:	e8 55 9e ff ff       	call   801010a9 <fileclose>
80107254:	83 c4 10             	add    $0x10,%esp
        return -1;
80107257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010725c:	eb 18                	jmp    80107276 <sys_pipe+0xd6>
    }
    fd[0] = fd0;
8010725e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107261:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107264:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
80107266:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107269:	8d 50 04             	lea    0x4(%eax),%edx
8010726c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010726f:	89 02                	mov    %eax,(%edx)
    return 0;
80107271:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107276:	c9                   	leave  
80107277:	c3                   	ret    

80107278 <sys_mount>:

int sys_mount(void)
{
80107278:	55                   	push   %ebp
80107279:	89 e5                	mov    %esp,%ebp
8010727b:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
8010727e:	83 ec 08             	sub    $0x8,%esp
80107281:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107284:	50                   	push   %eax
80107285:	6a 00                	push   $0x0
80107287:	e8 08 ef ff ff       	call   80106194 <argstr>
8010728c:	83 c4 10             	add    $0x10,%esp
8010728f:	85 c0                	test   %eax,%eax
80107291:	78 1d                	js     801072b0 <sys_mount+0x38>
80107293:	83 ec 08             	sub    $0x8,%esp
80107296:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107299:	50                   	push   %eax
8010729a:	6a 01                	push   $0x1
8010729c:	e8 6e ee ff ff       	call   8010610f <argint>
801072a1:	83 c4 10             	add    $0x10,%esp
801072a4:	85 c0                	test   %eax,%eax
801072a6:	78 08                	js     801072b0 <sys_mount+0x38>
801072a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072ab:	83 f8 04             	cmp    $0x4,%eax
801072ae:	76 0a                	jbe    801072ba <sys_mount+0x42>
        return -1;
801072b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072b5:	e9 a4 00 00 00       	jmp    8010735e <sys_mount+0xe6>
    }
    //cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);

    i=nameiIgnoreMounts(path);
801072ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072bd:	83 ec 0c             	sub    $0xc,%esp
801072c0:	50                   	push   %eax
801072c1:	e8 60 ba ff ff       	call   80102d26 <nameiIgnoreMounts>
801072c6:	83 c4 10             	add    $0x10,%esp
801072c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
801072cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072d0:	75 0a                	jne    801072dc <sys_mount+0x64>
        return -1;
801072d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072d7:	e9 82 00 00 00       	jmp    8010735e <sys_mount+0xe6>
    }
    ilock(i);
801072dc:	83 ec 0c             	sub    $0xc,%esp
801072df:	ff 75 f4             	pushl  -0xc(%ebp)
801072e2:	e8 0b ac ff ff       	call   80101ef2 <ilock>
801072e7:	83 c4 10             	add    $0x10,%esp
    if(i->type!=T_DIR){
801072ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ed:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801072f1:	66 83 f8 01          	cmp    $0x1,%ax
801072f5:	74 07                	je     801072fe <sys_mount+0x86>
        return -1;
801072f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072fc:	eb 60                	jmp    8010735e <sys_mount+0xe6>
    }
    i->major=MOUNTING_POINT;
801072fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107301:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
80107307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010730a:	89 c2                	mov    %eax,%edx
8010730c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730f:	66 89 50 14          	mov    %dx,0x14(%eax)
    begin_op(i->part->number);
80107313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107316:	8b 40 50             	mov    0x50(%eax),%eax
80107319:	8b 40 14             	mov    0x14(%eax),%eax
8010731c:	83 ec 0c             	sub    $0xc,%esp
8010731f:	50                   	push   %eax
80107320:	e8 84 cb ff ff       	call   80103ea9 <begin_op>
80107325:	83 c4 10             	add    $0x10,%esp
    iupdate(i);
80107328:	83 ec 0c             	sub    $0xc,%esp
8010732b:	ff 75 f4             	pushl  -0xc(%ebp)
8010732e:	e8 61 a9 ff ff       	call   80101c94 <iupdate>
80107333:	83 c4 10             	add    $0x10,%esp
    end_op(i->part->number);
80107336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107339:	8b 40 50             	mov    0x50(%eax),%eax
8010733c:	8b 40 14             	mov    0x14(%eax),%eax
8010733f:	83 ec 0c             	sub    $0xc,%esp
80107342:	50                   	push   %eax
80107343:	e8 68 cc ff ff       	call   80103fb0 <end_op>
80107348:	83 c4 10             	add    $0x10,%esp
    iunlockput(i);
8010734b:	83 ec 0c             	sub    $0xc,%esp
8010734e:	ff 75 f4             	pushl  -0xc(%ebp)
80107351:	e8 9f ae ff ff       	call   801021f5 <iunlockput>
80107356:	83 c4 10             	add    $0x10,%esp
   // cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);
    return 0;
80107359:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010735e:	c9                   	leave  
8010735f:	c3                   	ret    

80107360 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80107360:	55                   	push   %ebp
80107361:	89 e5                	mov    %esp,%ebp
80107363:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107366:	e8 04 df ff ff       	call   8010526f <fork>
}
8010736b:	c9                   	leave  
8010736c:	c3                   	ret    

8010736d <sys_exit>:

int
sys_exit(void)
{
8010736d:	55                   	push   %ebp
8010736e:	89 e5                	mov    %esp,%ebp
80107370:	83 ec 08             	sub    $0x8,%esp
  exit();
80107373:	e8 88 e0 ff ff       	call   80105400 <exit>
  return 0;  // not reached
80107378:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010737d:	c9                   	leave  
8010737e:	c3                   	ret    

8010737f <sys_wait>:

int
sys_wait(void)
{
8010737f:	55                   	push   %ebp
80107380:	89 e5                	mov    %esp,%ebp
80107382:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107385:	e8 da e1 ff ff       	call   80105564 <wait>
}
8010738a:	c9                   	leave  
8010738b:	c3                   	ret    

8010738c <sys_kill>:

int
sys_kill(void)
{
8010738c:	55                   	push   %ebp
8010738d:	89 e5                	mov    %esp,%ebp
8010738f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107392:	83 ec 08             	sub    $0x8,%esp
80107395:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107398:	50                   	push   %eax
80107399:	6a 00                	push   $0x0
8010739b:	e8 6f ed ff ff       	call   8010610f <argint>
801073a0:	83 c4 10             	add    $0x10,%esp
801073a3:	85 c0                	test   %eax,%eax
801073a5:	79 07                	jns    801073ae <sys_kill+0x22>
    return -1;
801073a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ac:	eb 0f                	jmp    801073bd <sys_kill+0x31>
  return kill(pid);
801073ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b1:	83 ec 0c             	sub    $0xc,%esp
801073b4:	50                   	push   %eax
801073b5:	e8 f6 e5 ff ff       	call   801059b0 <kill>
801073ba:	83 c4 10             	add    $0x10,%esp
}
801073bd:	c9                   	leave  
801073be:	c3                   	ret    

801073bf <sys_getpid>:

int
sys_getpid(void)
{
801073bf:	55                   	push   %ebp
801073c0:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801073c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c8:	8b 40 10             	mov    0x10(%eax),%eax
}
801073cb:	5d                   	pop    %ebp
801073cc:	c3                   	ret    

801073cd <sys_sbrk>:

int
sys_sbrk(void)
{
801073cd:	55                   	push   %ebp
801073ce:	89 e5                	mov    %esp,%ebp
801073d0:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801073d3:	83 ec 08             	sub    $0x8,%esp
801073d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073d9:	50                   	push   %eax
801073da:	6a 00                	push   $0x0
801073dc:	e8 2e ed ff ff       	call   8010610f <argint>
801073e1:	83 c4 10             	add    $0x10,%esp
801073e4:	85 c0                	test   %eax,%eax
801073e6:	79 07                	jns    801073ef <sys_sbrk+0x22>
    return -1;
801073e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ed:	eb 28                	jmp    80107417 <sys_sbrk+0x4a>
  addr = proc->sz;
801073ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073f5:	8b 00                	mov    (%eax),%eax
801073f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801073fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073fd:	83 ec 0c             	sub    $0xc,%esp
80107400:	50                   	push   %eax
80107401:	e8 c6 dd ff ff       	call   801051cc <growproc>
80107406:	83 c4 10             	add    $0x10,%esp
80107409:	85 c0                	test   %eax,%eax
8010740b:	79 07                	jns    80107414 <sys_sbrk+0x47>
    return -1;
8010740d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107412:	eb 03                	jmp    80107417 <sys_sbrk+0x4a>
  return addr;
80107414:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107417:	c9                   	leave  
80107418:	c3                   	ret    

80107419 <sys_sleep>:

int
sys_sleep(void)
{
80107419:	55                   	push   %ebp
8010741a:	89 e5                	mov    %esp,%ebp
8010741c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010741f:	83 ec 08             	sub    $0x8,%esp
80107422:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107425:	50                   	push   %eax
80107426:	6a 00                	push   $0x0
80107428:	e8 e2 ec ff ff       	call   8010610f <argint>
8010742d:	83 c4 10             	add    $0x10,%esp
80107430:	85 c0                	test   %eax,%eax
80107432:	79 07                	jns    8010743b <sys_sleep+0x22>
    return -1;
80107434:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107439:	eb 77                	jmp    801074b2 <sys_sleep+0x99>
  acquire(&tickslock);
8010743b:	83 ec 0c             	sub    $0xc,%esp
8010743e:	68 c0 5d 11 80       	push   $0x80115dc0
80107443:	e8 3f e7 ff ff       	call   80105b87 <acquire>
80107448:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010744b:	a1 00 66 11 80       	mov    0x80116600,%eax
80107450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107453:	eb 39                	jmp    8010748e <sys_sleep+0x75>
    if(proc->killed){
80107455:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010745b:	8b 40 24             	mov    0x24(%eax),%eax
8010745e:	85 c0                	test   %eax,%eax
80107460:	74 17                	je     80107479 <sys_sleep+0x60>
      release(&tickslock);
80107462:	83 ec 0c             	sub    $0xc,%esp
80107465:	68 c0 5d 11 80       	push   $0x80115dc0
8010746a:	e8 7f e7 ff ff       	call   80105bee <release>
8010746f:	83 c4 10             	add    $0x10,%esp
      return -1;
80107472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107477:	eb 39                	jmp    801074b2 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107479:	83 ec 08             	sub    $0x8,%esp
8010747c:	68 c0 5d 11 80       	push   $0x80115dc0
80107481:	68 00 66 11 80       	push   $0x80116600
80107486:	e8 03 e4 ff ff       	call   8010588e <sleep>
8010748b:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010748e:	a1 00 66 11 80       	mov    0x80116600,%eax
80107493:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107496:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107499:	39 d0                	cmp    %edx,%eax
8010749b:	72 b8                	jb     80107455 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010749d:	83 ec 0c             	sub    $0xc,%esp
801074a0:	68 c0 5d 11 80       	push   $0x80115dc0
801074a5:	e8 44 e7 ff ff       	call   80105bee <release>
801074aa:	83 c4 10             	add    $0x10,%esp
  return 0;
801074ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074b2:	c9                   	leave  
801074b3:	c3                   	ret    

801074b4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801074b4:	55                   	push   %ebp
801074b5:	89 e5                	mov    %esp,%ebp
801074b7:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801074ba:	83 ec 0c             	sub    $0xc,%esp
801074bd:	68 c0 5d 11 80       	push   $0x80115dc0
801074c2:	e8 c0 e6 ff ff       	call   80105b87 <acquire>
801074c7:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801074ca:	a1 00 66 11 80       	mov    0x80116600,%eax
801074cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801074d2:	83 ec 0c             	sub    $0xc,%esp
801074d5:	68 c0 5d 11 80       	push   $0x80115dc0
801074da:	e8 0f e7 ff ff       	call   80105bee <release>
801074df:	83 c4 10             	add    $0x10,%esp
  return xticks;
801074e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801074e5:	c9                   	leave  
801074e6:	c3                   	ret    

801074e7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801074e7:	55                   	push   %ebp
801074e8:	89 e5                	mov    %esp,%ebp
801074ea:	83 ec 08             	sub    $0x8,%esp
801074ed:	8b 55 08             	mov    0x8(%ebp),%edx
801074f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801074f3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801074f7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801074fa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801074fe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107502:	ee                   	out    %al,(%dx)
}
80107503:	90                   	nop
80107504:	c9                   	leave  
80107505:	c3                   	ret    

80107506 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107506:	55                   	push   %ebp
80107507:	89 e5                	mov    %esp,%ebp
80107509:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010750c:	6a 34                	push   $0x34
8010750e:	6a 43                	push   $0x43
80107510:	e8 d2 ff ff ff       	call   801074e7 <outb>
80107515:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107518:	68 9c 00 00 00       	push   $0x9c
8010751d:	6a 40                	push   $0x40
8010751f:	e8 c3 ff ff ff       	call   801074e7 <outb>
80107524:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107527:	6a 2e                	push   $0x2e
80107529:	6a 40                	push   $0x40
8010752b:	e8 b7 ff ff ff       	call   801074e7 <outb>
80107530:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107533:	83 ec 0c             	sub    $0xc,%esp
80107536:	6a 00                	push   $0x0
80107538:	e8 26 d5 ff ff       	call   80104a63 <picenable>
8010753d:	83 c4 10             	add    $0x10,%esp
}
80107540:	90                   	nop
80107541:	c9                   	leave  
80107542:	c3                   	ret    

80107543 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107543:	1e                   	push   %ds
  pushl %es
80107544:	06                   	push   %es
  pushl %fs
80107545:	0f a0                	push   %fs
  pushl %gs
80107547:	0f a8                	push   %gs
  pushal
80107549:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010754a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010754e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107550:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107552:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107556:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107558:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010755a:	54                   	push   %esp
  call trap
8010755b:	e8 d7 01 00 00       	call   80107737 <trap>
  addl $4, %esp
80107560:	83 c4 04             	add    $0x4,%esp

80107563 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107563:	61                   	popa   
  popl %gs
80107564:	0f a9                	pop    %gs
  popl %fs
80107566:	0f a1                	pop    %fs
  popl %es
80107568:	07                   	pop    %es
  popl %ds
80107569:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010756a:	83 c4 08             	add    $0x8,%esp
  iret
8010756d:	cf                   	iret   

8010756e <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010756e:	55                   	push   %ebp
8010756f:	89 e5                	mov    %esp,%ebp
80107571:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107574:	8b 45 0c             	mov    0xc(%ebp),%eax
80107577:	83 e8 01             	sub    $0x1,%eax
8010757a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010757e:	8b 45 08             	mov    0x8(%ebp),%eax
80107581:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107585:	8b 45 08             	mov    0x8(%ebp),%eax
80107588:	c1 e8 10             	shr    $0x10,%eax
8010758b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010758f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107592:	0f 01 18             	lidtl  (%eax)
}
80107595:	90                   	nop
80107596:	c9                   	leave  
80107597:	c3                   	ret    

80107598 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107598:	55                   	push   %ebp
80107599:	89 e5                	mov    %esp,%ebp
8010759b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010759e:	0f 20 d0             	mov    %cr2,%eax
801075a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801075a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801075a7:	c9                   	leave  
801075a8:	c3                   	ret    

801075a9 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801075a9:	55                   	push   %ebp
801075aa:	89 e5                	mov    %esp,%ebp
801075ac:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801075af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801075b6:	e9 c3 00 00 00       	jmp    8010767e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801075bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075be:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
801075c5:	89 c2                	mov    %eax,%edx
801075c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ca:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
801075d1:	80 
801075d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d5:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
801075dc:	80 08 00 
801075df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e2:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
801075e9:	80 
801075ea:	83 e2 e0             	and    $0xffffffe0,%edx
801075ed:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
801075f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f7:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
801075fe:	80 
801075ff:	83 e2 1f             	and    $0x1f,%edx
80107602:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
80107609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760c:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107613:	80 
80107614:	83 e2 f0             	and    $0xfffffff0,%edx
80107617:	83 ca 0e             	or     $0xe,%edx
8010761a:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107624:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
8010762b:	80 
8010762c:	83 e2 ef             	and    $0xffffffef,%edx
8010762f:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107639:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107640:	80 
80107641:	83 e2 9f             	and    $0xffffff9f,%edx
80107644:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107655:	80 
80107656:	83 ca 80             	or     $0xffffff80,%edx
80107659:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107663:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010766a:	c1 e8 10             	shr    $0x10,%eax
8010766d:	89 c2                	mov    %eax,%edx
8010766f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107672:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
80107679:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010767a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010767e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107685:	0f 8e 30 ff ff ff    	jle    801075bb <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010768b:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107690:	66 a3 00 60 11 80    	mov    %ax,0x80116000
80107696:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
8010769d:	08 00 
8010769f:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801076a6:	83 e0 e0             	and    $0xffffffe0,%eax
801076a9:	a2 04 60 11 80       	mov    %al,0x80116004
801076ae:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801076b5:	83 e0 1f             	and    $0x1f,%eax
801076b8:	a2 04 60 11 80       	mov    %al,0x80116004
801076bd:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076c4:	83 c8 0f             	or     $0xf,%eax
801076c7:	a2 05 60 11 80       	mov    %al,0x80116005
801076cc:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076d3:	83 e0 ef             	and    $0xffffffef,%eax
801076d6:	a2 05 60 11 80       	mov    %al,0x80116005
801076db:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076e2:	83 c8 60             	or     $0x60,%eax
801076e5:	a2 05 60 11 80       	mov    %al,0x80116005
801076ea:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076f1:	83 c8 80             	or     $0xffffff80,%eax
801076f4:	a2 05 60 11 80       	mov    %al,0x80116005
801076f9:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
801076fe:	c1 e8 10             	shr    $0x10,%eax
80107701:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
80107707:	83 ec 08             	sub    $0x8,%esp
8010770a:	68 e8 99 10 80       	push   $0x801099e8
8010770f:	68 c0 5d 11 80       	push   $0x80115dc0
80107714:	e8 4c e4 ff ff       	call   80105b65 <initlock>
80107719:	83 c4 10             	add    $0x10,%esp
}
8010771c:	90                   	nop
8010771d:	c9                   	leave  
8010771e:	c3                   	ret    

8010771f <idtinit>:

void
idtinit(void)
{
8010771f:	55                   	push   %ebp
80107720:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107722:	68 00 08 00 00       	push   $0x800
80107727:	68 00 5e 11 80       	push   $0x80115e00
8010772c:	e8 3d fe ff ff       	call   8010756e <lidt>
80107731:	83 c4 08             	add    $0x8,%esp
}
80107734:	90                   	nop
80107735:	c9                   	leave  
80107736:	c3                   	ret    

80107737 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107737:	55                   	push   %ebp
80107738:	89 e5                	mov    %esp,%ebp
8010773a:	57                   	push   %edi
8010773b:	56                   	push   %esi
8010773c:	53                   	push   %ebx
8010773d:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107740:	8b 45 08             	mov    0x8(%ebp),%eax
80107743:	8b 40 30             	mov    0x30(%eax),%eax
80107746:	83 f8 40             	cmp    $0x40,%eax
80107749:	75 3e                	jne    80107789 <trap+0x52>
    if(proc->killed)
8010774b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107751:	8b 40 24             	mov    0x24(%eax),%eax
80107754:	85 c0                	test   %eax,%eax
80107756:	74 05                	je     8010775d <trap+0x26>
      exit();
80107758:	e8 a3 dc ff ff       	call   80105400 <exit>
    proc->tf = tf;
8010775d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107763:	8b 55 08             	mov    0x8(%ebp),%edx
80107766:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107769:	e8 57 ea ff ff       	call   801061c5 <syscall>
    if(proc->killed)
8010776e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107774:	8b 40 24             	mov    0x24(%eax),%eax
80107777:	85 c0                	test   %eax,%eax
80107779:	0f 84 1b 02 00 00    	je     8010799a <trap+0x263>
      exit();
8010777f:	e8 7c dc ff ff       	call   80105400 <exit>
    return;
80107784:	e9 11 02 00 00       	jmp    8010799a <trap+0x263>
  }

  switch(tf->trapno){
80107789:	8b 45 08             	mov    0x8(%ebp),%eax
8010778c:	8b 40 30             	mov    0x30(%eax),%eax
8010778f:	83 e8 20             	sub    $0x20,%eax
80107792:	83 f8 1f             	cmp    $0x1f,%eax
80107795:	0f 87 c0 00 00 00    	ja     8010785b <trap+0x124>
8010779b:	8b 04 85 90 9a 10 80 	mov    -0x7fef6570(,%eax,4),%eax
801077a2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801077a4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077aa:	0f b6 00             	movzbl (%eax),%eax
801077ad:	84 c0                	test   %al,%al
801077af:	75 3d                	jne    801077ee <trap+0xb7>
      acquire(&tickslock);
801077b1:	83 ec 0c             	sub    $0xc,%esp
801077b4:	68 c0 5d 11 80       	push   $0x80115dc0
801077b9:	e8 c9 e3 ff ff       	call   80105b87 <acquire>
801077be:	83 c4 10             	add    $0x10,%esp
      ticks++;
801077c1:	a1 00 66 11 80       	mov    0x80116600,%eax
801077c6:	83 c0 01             	add    $0x1,%eax
801077c9:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
801077ce:	83 ec 0c             	sub    $0xc,%esp
801077d1:	68 00 66 11 80       	push   $0x80116600
801077d6:	e8 9e e1 ff ff       	call   80105979 <wakeup>
801077db:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801077de:	83 ec 0c             	sub    $0xc,%esp
801077e1:	68 c0 5d 11 80       	push   $0x80115dc0
801077e6:	e8 03 e4 ff ff       	call   80105bee <release>
801077eb:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801077ee:	e8 3e c0 ff ff       	call   80103831 <lapiceoi>
    break;
801077f3:	e9 1c 01 00 00       	jmp    80107914 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801077f8:	e8 47 b8 ff ff       	call   80103044 <ideintr>
    lapiceoi();
801077fd:	e8 2f c0 ff ff       	call   80103831 <lapiceoi>
    break;
80107802:	e9 0d 01 00 00       	jmp    80107914 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107807:	e8 27 be ff ff       	call   80103633 <kbdintr>
    lapiceoi();
8010780c:	e8 20 c0 ff ff       	call   80103831 <lapiceoi>
    break;
80107811:	e9 fe 00 00 00       	jmp    80107914 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107816:	e8 60 03 00 00       	call   80107b7b <uartintr>
    lapiceoi();
8010781b:	e8 11 c0 ff ff       	call   80103831 <lapiceoi>
    break;
80107820:	e9 ef 00 00 00       	jmp    80107914 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107825:	8b 45 08             	mov    0x8(%ebp),%eax
80107828:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010782b:	8b 45 08             	mov    0x8(%ebp),%eax
8010782e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107832:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107835:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010783b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010783e:	0f b6 c0             	movzbl %al,%eax
80107841:	51                   	push   %ecx
80107842:	52                   	push   %edx
80107843:	50                   	push   %eax
80107844:	68 f0 99 10 80       	push   $0x801099f0
80107849:	e8 78 8b ff ff       	call   801003c6 <cprintf>
8010784e:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107851:	e8 db bf ff ff       	call   80103831 <lapiceoi>
    break;
80107856:	e9 b9 00 00 00       	jmp    80107914 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010785b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107861:	85 c0                	test   %eax,%eax
80107863:	74 11                	je     80107876 <trap+0x13f>
80107865:	8b 45 08             	mov    0x8(%ebp),%eax
80107868:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010786c:	0f b7 c0             	movzwl %ax,%eax
8010786f:	83 e0 03             	and    $0x3,%eax
80107872:	85 c0                	test   %eax,%eax
80107874:	75 40                	jne    801078b6 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107876:	e8 1d fd ff ff       	call   80107598 <rcr2>
8010787b:	89 c3                	mov    %eax,%ebx
8010787d:	8b 45 08             	mov    0x8(%ebp),%eax
80107880:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107883:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107889:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010788c:	0f b6 d0             	movzbl %al,%edx
8010788f:	8b 45 08             	mov    0x8(%ebp),%eax
80107892:	8b 40 30             	mov    0x30(%eax),%eax
80107895:	83 ec 0c             	sub    $0xc,%esp
80107898:	53                   	push   %ebx
80107899:	51                   	push   %ecx
8010789a:	52                   	push   %edx
8010789b:	50                   	push   %eax
8010789c:	68 14 9a 10 80       	push   $0x80109a14
801078a1:	e8 20 8b ff ff       	call   801003c6 <cprintf>
801078a6:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801078a9:	83 ec 0c             	sub    $0xc,%esp
801078ac:	68 46 9a 10 80       	push   $0x80109a46
801078b1:	e8 b0 8c ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078b6:	e8 dd fc ff ff       	call   80107598 <rcr2>
801078bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801078be:	8b 45 08             	mov    0x8(%ebp),%eax
801078c1:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078c4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078ca:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078cd:	0f b6 d8             	movzbl %al,%ebx
801078d0:	8b 45 08             	mov    0x8(%ebp),%eax
801078d3:	8b 48 34             	mov    0x34(%eax),%ecx
801078d6:	8b 45 08             	mov    0x8(%ebp),%eax
801078d9:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078e2:	8d 78 6c             	lea    0x6c(%eax),%edi
801078e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078eb:	8b 40 10             	mov    0x10(%eax),%eax
801078ee:	ff 75 e4             	pushl  -0x1c(%ebp)
801078f1:	56                   	push   %esi
801078f2:	53                   	push   %ebx
801078f3:	51                   	push   %ecx
801078f4:	52                   	push   %edx
801078f5:	57                   	push   %edi
801078f6:	50                   	push   %eax
801078f7:	68 4c 9a 10 80       	push   $0x80109a4c
801078fc:	e8 c5 8a ff ff       	call   801003c6 <cprintf>
80107901:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107904:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010790a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107911:	eb 01                	jmp    80107914 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107913:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107914:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010791a:	85 c0                	test   %eax,%eax
8010791c:	74 24                	je     80107942 <trap+0x20b>
8010791e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107924:	8b 40 24             	mov    0x24(%eax),%eax
80107927:	85 c0                	test   %eax,%eax
80107929:	74 17                	je     80107942 <trap+0x20b>
8010792b:	8b 45 08             	mov    0x8(%ebp),%eax
8010792e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107932:	0f b7 c0             	movzwl %ax,%eax
80107935:	83 e0 03             	and    $0x3,%eax
80107938:	83 f8 03             	cmp    $0x3,%eax
8010793b:	75 05                	jne    80107942 <trap+0x20b>
    exit();
8010793d:	e8 be da ff ff       	call   80105400 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107948:	85 c0                	test   %eax,%eax
8010794a:	74 1e                	je     8010796a <trap+0x233>
8010794c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107952:	8b 40 0c             	mov    0xc(%eax),%eax
80107955:	83 f8 04             	cmp    $0x4,%eax
80107958:	75 10                	jne    8010796a <trap+0x233>
8010795a:	8b 45 08             	mov    0x8(%ebp),%eax
8010795d:	8b 40 30             	mov    0x30(%eax),%eax
80107960:	83 f8 20             	cmp    $0x20,%eax
80107963:	75 05                	jne    8010796a <trap+0x233>
    yield();
80107965:	e8 7f de ff ff       	call   801057e9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010796a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107970:	85 c0                	test   %eax,%eax
80107972:	74 27                	je     8010799b <trap+0x264>
80107974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010797a:	8b 40 24             	mov    0x24(%eax),%eax
8010797d:	85 c0                	test   %eax,%eax
8010797f:	74 1a                	je     8010799b <trap+0x264>
80107981:	8b 45 08             	mov    0x8(%ebp),%eax
80107984:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107988:	0f b7 c0             	movzwl %ax,%eax
8010798b:	83 e0 03             	and    $0x3,%eax
8010798e:	83 f8 03             	cmp    $0x3,%eax
80107991:	75 08                	jne    8010799b <trap+0x264>
    exit();
80107993:	e8 68 da ff ff       	call   80105400 <exit>
80107998:	eb 01                	jmp    8010799b <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010799a:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010799b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010799e:	5b                   	pop    %ebx
8010799f:	5e                   	pop    %esi
801079a0:	5f                   	pop    %edi
801079a1:	5d                   	pop    %ebp
801079a2:	c3                   	ret    

801079a3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801079a3:	55                   	push   %ebp
801079a4:	89 e5                	mov    %esp,%ebp
801079a6:	83 ec 14             	sub    $0x14,%esp
801079a9:	8b 45 08             	mov    0x8(%ebp),%eax
801079ac:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801079b0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801079b4:	89 c2                	mov    %eax,%edx
801079b6:	ec                   	in     (%dx),%al
801079b7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801079ba:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801079be:	c9                   	leave  
801079bf:	c3                   	ret    

801079c0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801079c0:	55                   	push   %ebp
801079c1:	89 e5                	mov    %esp,%ebp
801079c3:	83 ec 08             	sub    $0x8,%esp
801079c6:	8b 55 08             	mov    0x8(%ebp),%edx
801079c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801079cc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801079d0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801079d3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801079d7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801079db:	ee                   	out    %al,(%dx)
}
801079dc:	90                   	nop
801079dd:	c9                   	leave  
801079de:	c3                   	ret    

801079df <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801079df:	55                   	push   %ebp
801079e0:	89 e5                	mov    %esp,%ebp
801079e2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801079e5:	6a 00                	push   $0x0
801079e7:	68 fa 03 00 00       	push   $0x3fa
801079ec:	e8 cf ff ff ff       	call   801079c0 <outb>
801079f1:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801079f4:	68 80 00 00 00       	push   $0x80
801079f9:	68 fb 03 00 00       	push   $0x3fb
801079fe:	e8 bd ff ff ff       	call   801079c0 <outb>
80107a03:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107a06:	6a 0c                	push   $0xc
80107a08:	68 f8 03 00 00       	push   $0x3f8
80107a0d:	e8 ae ff ff ff       	call   801079c0 <outb>
80107a12:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107a15:	6a 00                	push   $0x0
80107a17:	68 f9 03 00 00       	push   $0x3f9
80107a1c:	e8 9f ff ff ff       	call   801079c0 <outb>
80107a21:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107a24:	6a 03                	push   $0x3
80107a26:	68 fb 03 00 00       	push   $0x3fb
80107a2b:	e8 90 ff ff ff       	call   801079c0 <outb>
80107a30:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107a33:	6a 00                	push   $0x0
80107a35:	68 fc 03 00 00       	push   $0x3fc
80107a3a:	e8 81 ff ff ff       	call   801079c0 <outb>
80107a3f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107a42:	6a 01                	push   $0x1
80107a44:	68 f9 03 00 00       	push   $0x3f9
80107a49:	e8 72 ff ff ff       	call   801079c0 <outb>
80107a4e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107a51:	68 fd 03 00 00       	push   $0x3fd
80107a56:	e8 48 ff ff ff       	call   801079a3 <inb>
80107a5b:	83 c4 04             	add    $0x4,%esp
80107a5e:	3c ff                	cmp    $0xff,%al
80107a60:	74 6e                	je     80107ad0 <uartinit+0xf1>
    return;
  uart = 1;
80107a62:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107a69:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107a6c:	68 fa 03 00 00       	push   $0x3fa
80107a71:	e8 2d ff ff ff       	call   801079a3 <inb>
80107a76:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107a79:	68 f8 03 00 00       	push   $0x3f8
80107a7e:	e8 20 ff ff ff       	call   801079a3 <inb>
80107a83:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107a86:	83 ec 0c             	sub    $0xc,%esp
80107a89:	6a 04                	push   $0x4
80107a8b:	e8 d3 cf ff ff       	call   80104a63 <picenable>
80107a90:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107a93:	83 ec 08             	sub    $0x8,%esp
80107a96:	6a 00                	push   $0x0
80107a98:	6a 04                	push   $0x4
80107a9a:	e8 47 b8 ff ff       	call   801032e6 <ioapicenable>
80107a9f:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107aa2:	c7 45 f4 10 9b 10 80 	movl   $0x80109b10,-0xc(%ebp)
80107aa9:	eb 19                	jmp    80107ac4 <uartinit+0xe5>
    uartputc(*p);
80107aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aae:	0f b6 00             	movzbl (%eax),%eax
80107ab1:	0f be c0             	movsbl %al,%eax
80107ab4:	83 ec 0c             	sub    $0xc,%esp
80107ab7:	50                   	push   %eax
80107ab8:	e8 16 00 00 00       	call   80107ad3 <uartputc>
80107abd:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107ac0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	0f b6 00             	movzbl (%eax),%eax
80107aca:	84 c0                	test   %al,%al
80107acc:	75 dd                	jne    80107aab <uartinit+0xcc>
80107ace:	eb 01                	jmp    80107ad1 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107ad0:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107ad1:	c9                   	leave  
80107ad2:	c3                   	ret    

80107ad3 <uartputc>:

void
uartputc(int c)
{
80107ad3:	55                   	push   %ebp
80107ad4:	89 e5                	mov    %esp,%ebp
80107ad6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107ad9:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107ade:	85 c0                	test   %eax,%eax
80107ae0:	74 53                	je     80107b35 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ae9:	eb 11                	jmp    80107afc <uartputc+0x29>
    microdelay(10);
80107aeb:	83 ec 0c             	sub    $0xc,%esp
80107aee:	6a 0a                	push   $0xa
80107af0:	e8 57 bd ff ff       	call   8010384c <microdelay>
80107af5:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107af8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107afc:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b00:	7f 1a                	jg     80107b1c <uartputc+0x49>
80107b02:	83 ec 0c             	sub    $0xc,%esp
80107b05:	68 fd 03 00 00       	push   $0x3fd
80107b0a:	e8 94 fe ff ff       	call   801079a3 <inb>
80107b0f:	83 c4 10             	add    $0x10,%esp
80107b12:	0f b6 c0             	movzbl %al,%eax
80107b15:	83 e0 20             	and    $0x20,%eax
80107b18:	85 c0                	test   %eax,%eax
80107b1a:	74 cf                	je     80107aeb <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b1f:	0f b6 c0             	movzbl %al,%eax
80107b22:	83 ec 08             	sub    $0x8,%esp
80107b25:	50                   	push   %eax
80107b26:	68 f8 03 00 00       	push   $0x3f8
80107b2b:	e8 90 fe ff ff       	call   801079c0 <outb>
80107b30:	83 c4 10             	add    $0x10,%esp
80107b33:	eb 01                	jmp    80107b36 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107b35:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107b36:	c9                   	leave  
80107b37:	c3                   	ret    

80107b38 <uartgetc>:

static int
uartgetc(void)
{
80107b38:	55                   	push   %ebp
80107b39:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107b3b:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107b40:	85 c0                	test   %eax,%eax
80107b42:	75 07                	jne    80107b4b <uartgetc+0x13>
    return -1;
80107b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b49:	eb 2e                	jmp    80107b79 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107b4b:	68 fd 03 00 00       	push   $0x3fd
80107b50:	e8 4e fe ff ff       	call   801079a3 <inb>
80107b55:	83 c4 04             	add    $0x4,%esp
80107b58:	0f b6 c0             	movzbl %al,%eax
80107b5b:	83 e0 01             	and    $0x1,%eax
80107b5e:	85 c0                	test   %eax,%eax
80107b60:	75 07                	jne    80107b69 <uartgetc+0x31>
    return -1;
80107b62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b67:	eb 10                	jmp    80107b79 <uartgetc+0x41>
  return inb(COM1+0);
80107b69:	68 f8 03 00 00       	push   $0x3f8
80107b6e:	e8 30 fe ff ff       	call   801079a3 <inb>
80107b73:	83 c4 04             	add    $0x4,%esp
80107b76:	0f b6 c0             	movzbl %al,%eax
}
80107b79:	c9                   	leave  
80107b7a:	c3                   	ret    

80107b7b <uartintr>:

void
uartintr(void)
{
80107b7b:	55                   	push   %ebp
80107b7c:	89 e5                	mov    %esp,%ebp
80107b7e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107b81:	83 ec 0c             	sub    $0xc,%esp
80107b84:	68 38 7b 10 80       	push   $0x80107b38
80107b89:	e8 6b 8c ff ff       	call   801007f9 <consoleintr>
80107b8e:	83 c4 10             	add    $0x10,%esp
}
80107b91:	90                   	nop
80107b92:	c9                   	leave  
80107b93:	c3                   	ret    

80107b94 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $0
80107b96:	6a 00                	push   $0x0
  jmp alltraps
80107b98:	e9 a6 f9 ff ff       	jmp    80107543 <alltraps>

80107b9d <vector1>:
.globl vector1
vector1:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $1
80107b9f:	6a 01                	push   $0x1
  jmp alltraps
80107ba1:	e9 9d f9 ff ff       	jmp    80107543 <alltraps>

80107ba6 <vector2>:
.globl vector2
vector2:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $2
80107ba8:	6a 02                	push   $0x2
  jmp alltraps
80107baa:	e9 94 f9 ff ff       	jmp    80107543 <alltraps>

80107baf <vector3>:
.globl vector3
vector3:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $3
80107bb1:	6a 03                	push   $0x3
  jmp alltraps
80107bb3:	e9 8b f9 ff ff       	jmp    80107543 <alltraps>

80107bb8 <vector4>:
.globl vector4
vector4:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $4
80107bba:	6a 04                	push   $0x4
  jmp alltraps
80107bbc:	e9 82 f9 ff ff       	jmp    80107543 <alltraps>

80107bc1 <vector5>:
.globl vector5
vector5:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $5
80107bc3:	6a 05                	push   $0x5
  jmp alltraps
80107bc5:	e9 79 f9 ff ff       	jmp    80107543 <alltraps>

80107bca <vector6>:
.globl vector6
vector6:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $6
80107bcc:	6a 06                	push   $0x6
  jmp alltraps
80107bce:	e9 70 f9 ff ff       	jmp    80107543 <alltraps>

80107bd3 <vector7>:
.globl vector7
vector7:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $7
80107bd5:	6a 07                	push   $0x7
  jmp alltraps
80107bd7:	e9 67 f9 ff ff       	jmp    80107543 <alltraps>

80107bdc <vector8>:
.globl vector8
vector8:
  pushl $8
80107bdc:	6a 08                	push   $0x8
  jmp alltraps
80107bde:	e9 60 f9 ff ff       	jmp    80107543 <alltraps>

80107be3 <vector9>:
.globl vector9
vector9:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $9
80107be5:	6a 09                	push   $0x9
  jmp alltraps
80107be7:	e9 57 f9 ff ff       	jmp    80107543 <alltraps>

80107bec <vector10>:
.globl vector10
vector10:
  pushl $10
80107bec:	6a 0a                	push   $0xa
  jmp alltraps
80107bee:	e9 50 f9 ff ff       	jmp    80107543 <alltraps>

80107bf3 <vector11>:
.globl vector11
vector11:
  pushl $11
80107bf3:	6a 0b                	push   $0xb
  jmp alltraps
80107bf5:	e9 49 f9 ff ff       	jmp    80107543 <alltraps>

80107bfa <vector12>:
.globl vector12
vector12:
  pushl $12
80107bfa:	6a 0c                	push   $0xc
  jmp alltraps
80107bfc:	e9 42 f9 ff ff       	jmp    80107543 <alltraps>

80107c01 <vector13>:
.globl vector13
vector13:
  pushl $13
80107c01:	6a 0d                	push   $0xd
  jmp alltraps
80107c03:	e9 3b f9 ff ff       	jmp    80107543 <alltraps>

80107c08 <vector14>:
.globl vector14
vector14:
  pushl $14
80107c08:	6a 0e                	push   $0xe
  jmp alltraps
80107c0a:	e9 34 f9 ff ff       	jmp    80107543 <alltraps>

80107c0f <vector15>:
.globl vector15
vector15:
  pushl $0
80107c0f:	6a 00                	push   $0x0
  pushl $15
80107c11:	6a 0f                	push   $0xf
  jmp alltraps
80107c13:	e9 2b f9 ff ff       	jmp    80107543 <alltraps>

80107c18 <vector16>:
.globl vector16
vector16:
  pushl $0
80107c18:	6a 00                	push   $0x0
  pushl $16
80107c1a:	6a 10                	push   $0x10
  jmp alltraps
80107c1c:	e9 22 f9 ff ff       	jmp    80107543 <alltraps>

80107c21 <vector17>:
.globl vector17
vector17:
  pushl $17
80107c21:	6a 11                	push   $0x11
  jmp alltraps
80107c23:	e9 1b f9 ff ff       	jmp    80107543 <alltraps>

80107c28 <vector18>:
.globl vector18
vector18:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $18
80107c2a:	6a 12                	push   $0x12
  jmp alltraps
80107c2c:	e9 12 f9 ff ff       	jmp    80107543 <alltraps>

80107c31 <vector19>:
.globl vector19
vector19:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $19
80107c33:	6a 13                	push   $0x13
  jmp alltraps
80107c35:	e9 09 f9 ff ff       	jmp    80107543 <alltraps>

80107c3a <vector20>:
.globl vector20
vector20:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $20
80107c3c:	6a 14                	push   $0x14
  jmp alltraps
80107c3e:	e9 00 f9 ff ff       	jmp    80107543 <alltraps>

80107c43 <vector21>:
.globl vector21
vector21:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $21
80107c45:	6a 15                	push   $0x15
  jmp alltraps
80107c47:	e9 f7 f8 ff ff       	jmp    80107543 <alltraps>

80107c4c <vector22>:
.globl vector22
vector22:
  pushl $0
80107c4c:	6a 00                	push   $0x0
  pushl $22
80107c4e:	6a 16                	push   $0x16
  jmp alltraps
80107c50:	e9 ee f8 ff ff       	jmp    80107543 <alltraps>

80107c55 <vector23>:
.globl vector23
vector23:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $23
80107c57:	6a 17                	push   $0x17
  jmp alltraps
80107c59:	e9 e5 f8 ff ff       	jmp    80107543 <alltraps>

80107c5e <vector24>:
.globl vector24
vector24:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $24
80107c60:	6a 18                	push   $0x18
  jmp alltraps
80107c62:	e9 dc f8 ff ff       	jmp    80107543 <alltraps>

80107c67 <vector25>:
.globl vector25
vector25:
  pushl $0
80107c67:	6a 00                	push   $0x0
  pushl $25
80107c69:	6a 19                	push   $0x19
  jmp alltraps
80107c6b:	e9 d3 f8 ff ff       	jmp    80107543 <alltraps>

80107c70 <vector26>:
.globl vector26
vector26:
  pushl $0
80107c70:	6a 00                	push   $0x0
  pushl $26
80107c72:	6a 1a                	push   $0x1a
  jmp alltraps
80107c74:	e9 ca f8 ff ff       	jmp    80107543 <alltraps>

80107c79 <vector27>:
.globl vector27
vector27:
  pushl $0
80107c79:	6a 00                	push   $0x0
  pushl $27
80107c7b:	6a 1b                	push   $0x1b
  jmp alltraps
80107c7d:	e9 c1 f8 ff ff       	jmp    80107543 <alltraps>

80107c82 <vector28>:
.globl vector28
vector28:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $28
80107c84:	6a 1c                	push   $0x1c
  jmp alltraps
80107c86:	e9 b8 f8 ff ff       	jmp    80107543 <alltraps>

80107c8b <vector29>:
.globl vector29
vector29:
  pushl $0
80107c8b:	6a 00                	push   $0x0
  pushl $29
80107c8d:	6a 1d                	push   $0x1d
  jmp alltraps
80107c8f:	e9 af f8 ff ff       	jmp    80107543 <alltraps>

80107c94 <vector30>:
.globl vector30
vector30:
  pushl $0
80107c94:	6a 00                	push   $0x0
  pushl $30
80107c96:	6a 1e                	push   $0x1e
  jmp alltraps
80107c98:	e9 a6 f8 ff ff       	jmp    80107543 <alltraps>

80107c9d <vector31>:
.globl vector31
vector31:
  pushl $0
80107c9d:	6a 00                	push   $0x0
  pushl $31
80107c9f:	6a 1f                	push   $0x1f
  jmp alltraps
80107ca1:	e9 9d f8 ff ff       	jmp    80107543 <alltraps>

80107ca6 <vector32>:
.globl vector32
vector32:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $32
80107ca8:	6a 20                	push   $0x20
  jmp alltraps
80107caa:	e9 94 f8 ff ff       	jmp    80107543 <alltraps>

80107caf <vector33>:
.globl vector33
vector33:
  pushl $0
80107caf:	6a 00                	push   $0x0
  pushl $33
80107cb1:	6a 21                	push   $0x21
  jmp alltraps
80107cb3:	e9 8b f8 ff ff       	jmp    80107543 <alltraps>

80107cb8 <vector34>:
.globl vector34
vector34:
  pushl $0
80107cb8:	6a 00                	push   $0x0
  pushl $34
80107cba:	6a 22                	push   $0x22
  jmp alltraps
80107cbc:	e9 82 f8 ff ff       	jmp    80107543 <alltraps>

80107cc1 <vector35>:
.globl vector35
vector35:
  pushl $0
80107cc1:	6a 00                	push   $0x0
  pushl $35
80107cc3:	6a 23                	push   $0x23
  jmp alltraps
80107cc5:	e9 79 f8 ff ff       	jmp    80107543 <alltraps>

80107cca <vector36>:
.globl vector36
vector36:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $36
80107ccc:	6a 24                	push   $0x24
  jmp alltraps
80107cce:	e9 70 f8 ff ff       	jmp    80107543 <alltraps>

80107cd3 <vector37>:
.globl vector37
vector37:
  pushl $0
80107cd3:	6a 00                	push   $0x0
  pushl $37
80107cd5:	6a 25                	push   $0x25
  jmp alltraps
80107cd7:	e9 67 f8 ff ff       	jmp    80107543 <alltraps>

80107cdc <vector38>:
.globl vector38
vector38:
  pushl $0
80107cdc:	6a 00                	push   $0x0
  pushl $38
80107cde:	6a 26                	push   $0x26
  jmp alltraps
80107ce0:	e9 5e f8 ff ff       	jmp    80107543 <alltraps>

80107ce5 <vector39>:
.globl vector39
vector39:
  pushl $0
80107ce5:	6a 00                	push   $0x0
  pushl $39
80107ce7:	6a 27                	push   $0x27
  jmp alltraps
80107ce9:	e9 55 f8 ff ff       	jmp    80107543 <alltraps>

80107cee <vector40>:
.globl vector40
vector40:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $40
80107cf0:	6a 28                	push   $0x28
  jmp alltraps
80107cf2:	e9 4c f8 ff ff       	jmp    80107543 <alltraps>

80107cf7 <vector41>:
.globl vector41
vector41:
  pushl $0
80107cf7:	6a 00                	push   $0x0
  pushl $41
80107cf9:	6a 29                	push   $0x29
  jmp alltraps
80107cfb:	e9 43 f8 ff ff       	jmp    80107543 <alltraps>

80107d00 <vector42>:
.globl vector42
vector42:
  pushl $0
80107d00:	6a 00                	push   $0x0
  pushl $42
80107d02:	6a 2a                	push   $0x2a
  jmp alltraps
80107d04:	e9 3a f8 ff ff       	jmp    80107543 <alltraps>

80107d09 <vector43>:
.globl vector43
vector43:
  pushl $0
80107d09:	6a 00                	push   $0x0
  pushl $43
80107d0b:	6a 2b                	push   $0x2b
  jmp alltraps
80107d0d:	e9 31 f8 ff ff       	jmp    80107543 <alltraps>

80107d12 <vector44>:
.globl vector44
vector44:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $44
80107d14:	6a 2c                	push   $0x2c
  jmp alltraps
80107d16:	e9 28 f8 ff ff       	jmp    80107543 <alltraps>

80107d1b <vector45>:
.globl vector45
vector45:
  pushl $0
80107d1b:	6a 00                	push   $0x0
  pushl $45
80107d1d:	6a 2d                	push   $0x2d
  jmp alltraps
80107d1f:	e9 1f f8 ff ff       	jmp    80107543 <alltraps>

80107d24 <vector46>:
.globl vector46
vector46:
  pushl $0
80107d24:	6a 00                	push   $0x0
  pushl $46
80107d26:	6a 2e                	push   $0x2e
  jmp alltraps
80107d28:	e9 16 f8 ff ff       	jmp    80107543 <alltraps>

80107d2d <vector47>:
.globl vector47
vector47:
  pushl $0
80107d2d:	6a 00                	push   $0x0
  pushl $47
80107d2f:	6a 2f                	push   $0x2f
  jmp alltraps
80107d31:	e9 0d f8 ff ff       	jmp    80107543 <alltraps>

80107d36 <vector48>:
.globl vector48
vector48:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $48
80107d38:	6a 30                	push   $0x30
  jmp alltraps
80107d3a:	e9 04 f8 ff ff       	jmp    80107543 <alltraps>

80107d3f <vector49>:
.globl vector49
vector49:
  pushl $0
80107d3f:	6a 00                	push   $0x0
  pushl $49
80107d41:	6a 31                	push   $0x31
  jmp alltraps
80107d43:	e9 fb f7 ff ff       	jmp    80107543 <alltraps>

80107d48 <vector50>:
.globl vector50
vector50:
  pushl $0
80107d48:	6a 00                	push   $0x0
  pushl $50
80107d4a:	6a 32                	push   $0x32
  jmp alltraps
80107d4c:	e9 f2 f7 ff ff       	jmp    80107543 <alltraps>

80107d51 <vector51>:
.globl vector51
vector51:
  pushl $0
80107d51:	6a 00                	push   $0x0
  pushl $51
80107d53:	6a 33                	push   $0x33
  jmp alltraps
80107d55:	e9 e9 f7 ff ff       	jmp    80107543 <alltraps>

80107d5a <vector52>:
.globl vector52
vector52:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $52
80107d5c:	6a 34                	push   $0x34
  jmp alltraps
80107d5e:	e9 e0 f7 ff ff       	jmp    80107543 <alltraps>

80107d63 <vector53>:
.globl vector53
vector53:
  pushl $0
80107d63:	6a 00                	push   $0x0
  pushl $53
80107d65:	6a 35                	push   $0x35
  jmp alltraps
80107d67:	e9 d7 f7 ff ff       	jmp    80107543 <alltraps>

80107d6c <vector54>:
.globl vector54
vector54:
  pushl $0
80107d6c:	6a 00                	push   $0x0
  pushl $54
80107d6e:	6a 36                	push   $0x36
  jmp alltraps
80107d70:	e9 ce f7 ff ff       	jmp    80107543 <alltraps>

80107d75 <vector55>:
.globl vector55
vector55:
  pushl $0
80107d75:	6a 00                	push   $0x0
  pushl $55
80107d77:	6a 37                	push   $0x37
  jmp alltraps
80107d79:	e9 c5 f7 ff ff       	jmp    80107543 <alltraps>

80107d7e <vector56>:
.globl vector56
vector56:
  pushl $0
80107d7e:	6a 00                	push   $0x0
  pushl $56
80107d80:	6a 38                	push   $0x38
  jmp alltraps
80107d82:	e9 bc f7 ff ff       	jmp    80107543 <alltraps>

80107d87 <vector57>:
.globl vector57
vector57:
  pushl $0
80107d87:	6a 00                	push   $0x0
  pushl $57
80107d89:	6a 39                	push   $0x39
  jmp alltraps
80107d8b:	e9 b3 f7 ff ff       	jmp    80107543 <alltraps>

80107d90 <vector58>:
.globl vector58
vector58:
  pushl $0
80107d90:	6a 00                	push   $0x0
  pushl $58
80107d92:	6a 3a                	push   $0x3a
  jmp alltraps
80107d94:	e9 aa f7 ff ff       	jmp    80107543 <alltraps>

80107d99 <vector59>:
.globl vector59
vector59:
  pushl $0
80107d99:	6a 00                	push   $0x0
  pushl $59
80107d9b:	6a 3b                	push   $0x3b
  jmp alltraps
80107d9d:	e9 a1 f7 ff ff       	jmp    80107543 <alltraps>

80107da2 <vector60>:
.globl vector60
vector60:
  pushl $0
80107da2:	6a 00                	push   $0x0
  pushl $60
80107da4:	6a 3c                	push   $0x3c
  jmp alltraps
80107da6:	e9 98 f7 ff ff       	jmp    80107543 <alltraps>

80107dab <vector61>:
.globl vector61
vector61:
  pushl $0
80107dab:	6a 00                	push   $0x0
  pushl $61
80107dad:	6a 3d                	push   $0x3d
  jmp alltraps
80107daf:	e9 8f f7 ff ff       	jmp    80107543 <alltraps>

80107db4 <vector62>:
.globl vector62
vector62:
  pushl $0
80107db4:	6a 00                	push   $0x0
  pushl $62
80107db6:	6a 3e                	push   $0x3e
  jmp alltraps
80107db8:	e9 86 f7 ff ff       	jmp    80107543 <alltraps>

80107dbd <vector63>:
.globl vector63
vector63:
  pushl $0
80107dbd:	6a 00                	push   $0x0
  pushl $63
80107dbf:	6a 3f                	push   $0x3f
  jmp alltraps
80107dc1:	e9 7d f7 ff ff       	jmp    80107543 <alltraps>

80107dc6 <vector64>:
.globl vector64
vector64:
  pushl $0
80107dc6:	6a 00                	push   $0x0
  pushl $64
80107dc8:	6a 40                	push   $0x40
  jmp alltraps
80107dca:	e9 74 f7 ff ff       	jmp    80107543 <alltraps>

80107dcf <vector65>:
.globl vector65
vector65:
  pushl $0
80107dcf:	6a 00                	push   $0x0
  pushl $65
80107dd1:	6a 41                	push   $0x41
  jmp alltraps
80107dd3:	e9 6b f7 ff ff       	jmp    80107543 <alltraps>

80107dd8 <vector66>:
.globl vector66
vector66:
  pushl $0
80107dd8:	6a 00                	push   $0x0
  pushl $66
80107dda:	6a 42                	push   $0x42
  jmp alltraps
80107ddc:	e9 62 f7 ff ff       	jmp    80107543 <alltraps>

80107de1 <vector67>:
.globl vector67
vector67:
  pushl $0
80107de1:	6a 00                	push   $0x0
  pushl $67
80107de3:	6a 43                	push   $0x43
  jmp alltraps
80107de5:	e9 59 f7 ff ff       	jmp    80107543 <alltraps>

80107dea <vector68>:
.globl vector68
vector68:
  pushl $0
80107dea:	6a 00                	push   $0x0
  pushl $68
80107dec:	6a 44                	push   $0x44
  jmp alltraps
80107dee:	e9 50 f7 ff ff       	jmp    80107543 <alltraps>

80107df3 <vector69>:
.globl vector69
vector69:
  pushl $0
80107df3:	6a 00                	push   $0x0
  pushl $69
80107df5:	6a 45                	push   $0x45
  jmp alltraps
80107df7:	e9 47 f7 ff ff       	jmp    80107543 <alltraps>

80107dfc <vector70>:
.globl vector70
vector70:
  pushl $0
80107dfc:	6a 00                	push   $0x0
  pushl $70
80107dfe:	6a 46                	push   $0x46
  jmp alltraps
80107e00:	e9 3e f7 ff ff       	jmp    80107543 <alltraps>

80107e05 <vector71>:
.globl vector71
vector71:
  pushl $0
80107e05:	6a 00                	push   $0x0
  pushl $71
80107e07:	6a 47                	push   $0x47
  jmp alltraps
80107e09:	e9 35 f7 ff ff       	jmp    80107543 <alltraps>

80107e0e <vector72>:
.globl vector72
vector72:
  pushl $0
80107e0e:	6a 00                	push   $0x0
  pushl $72
80107e10:	6a 48                	push   $0x48
  jmp alltraps
80107e12:	e9 2c f7 ff ff       	jmp    80107543 <alltraps>

80107e17 <vector73>:
.globl vector73
vector73:
  pushl $0
80107e17:	6a 00                	push   $0x0
  pushl $73
80107e19:	6a 49                	push   $0x49
  jmp alltraps
80107e1b:	e9 23 f7 ff ff       	jmp    80107543 <alltraps>

80107e20 <vector74>:
.globl vector74
vector74:
  pushl $0
80107e20:	6a 00                	push   $0x0
  pushl $74
80107e22:	6a 4a                	push   $0x4a
  jmp alltraps
80107e24:	e9 1a f7 ff ff       	jmp    80107543 <alltraps>

80107e29 <vector75>:
.globl vector75
vector75:
  pushl $0
80107e29:	6a 00                	push   $0x0
  pushl $75
80107e2b:	6a 4b                	push   $0x4b
  jmp alltraps
80107e2d:	e9 11 f7 ff ff       	jmp    80107543 <alltraps>

80107e32 <vector76>:
.globl vector76
vector76:
  pushl $0
80107e32:	6a 00                	push   $0x0
  pushl $76
80107e34:	6a 4c                	push   $0x4c
  jmp alltraps
80107e36:	e9 08 f7 ff ff       	jmp    80107543 <alltraps>

80107e3b <vector77>:
.globl vector77
vector77:
  pushl $0
80107e3b:	6a 00                	push   $0x0
  pushl $77
80107e3d:	6a 4d                	push   $0x4d
  jmp alltraps
80107e3f:	e9 ff f6 ff ff       	jmp    80107543 <alltraps>

80107e44 <vector78>:
.globl vector78
vector78:
  pushl $0
80107e44:	6a 00                	push   $0x0
  pushl $78
80107e46:	6a 4e                	push   $0x4e
  jmp alltraps
80107e48:	e9 f6 f6 ff ff       	jmp    80107543 <alltraps>

80107e4d <vector79>:
.globl vector79
vector79:
  pushl $0
80107e4d:	6a 00                	push   $0x0
  pushl $79
80107e4f:	6a 4f                	push   $0x4f
  jmp alltraps
80107e51:	e9 ed f6 ff ff       	jmp    80107543 <alltraps>

80107e56 <vector80>:
.globl vector80
vector80:
  pushl $0
80107e56:	6a 00                	push   $0x0
  pushl $80
80107e58:	6a 50                	push   $0x50
  jmp alltraps
80107e5a:	e9 e4 f6 ff ff       	jmp    80107543 <alltraps>

80107e5f <vector81>:
.globl vector81
vector81:
  pushl $0
80107e5f:	6a 00                	push   $0x0
  pushl $81
80107e61:	6a 51                	push   $0x51
  jmp alltraps
80107e63:	e9 db f6 ff ff       	jmp    80107543 <alltraps>

80107e68 <vector82>:
.globl vector82
vector82:
  pushl $0
80107e68:	6a 00                	push   $0x0
  pushl $82
80107e6a:	6a 52                	push   $0x52
  jmp alltraps
80107e6c:	e9 d2 f6 ff ff       	jmp    80107543 <alltraps>

80107e71 <vector83>:
.globl vector83
vector83:
  pushl $0
80107e71:	6a 00                	push   $0x0
  pushl $83
80107e73:	6a 53                	push   $0x53
  jmp alltraps
80107e75:	e9 c9 f6 ff ff       	jmp    80107543 <alltraps>

80107e7a <vector84>:
.globl vector84
vector84:
  pushl $0
80107e7a:	6a 00                	push   $0x0
  pushl $84
80107e7c:	6a 54                	push   $0x54
  jmp alltraps
80107e7e:	e9 c0 f6 ff ff       	jmp    80107543 <alltraps>

80107e83 <vector85>:
.globl vector85
vector85:
  pushl $0
80107e83:	6a 00                	push   $0x0
  pushl $85
80107e85:	6a 55                	push   $0x55
  jmp alltraps
80107e87:	e9 b7 f6 ff ff       	jmp    80107543 <alltraps>

80107e8c <vector86>:
.globl vector86
vector86:
  pushl $0
80107e8c:	6a 00                	push   $0x0
  pushl $86
80107e8e:	6a 56                	push   $0x56
  jmp alltraps
80107e90:	e9 ae f6 ff ff       	jmp    80107543 <alltraps>

80107e95 <vector87>:
.globl vector87
vector87:
  pushl $0
80107e95:	6a 00                	push   $0x0
  pushl $87
80107e97:	6a 57                	push   $0x57
  jmp alltraps
80107e99:	e9 a5 f6 ff ff       	jmp    80107543 <alltraps>

80107e9e <vector88>:
.globl vector88
vector88:
  pushl $0
80107e9e:	6a 00                	push   $0x0
  pushl $88
80107ea0:	6a 58                	push   $0x58
  jmp alltraps
80107ea2:	e9 9c f6 ff ff       	jmp    80107543 <alltraps>

80107ea7 <vector89>:
.globl vector89
vector89:
  pushl $0
80107ea7:	6a 00                	push   $0x0
  pushl $89
80107ea9:	6a 59                	push   $0x59
  jmp alltraps
80107eab:	e9 93 f6 ff ff       	jmp    80107543 <alltraps>

80107eb0 <vector90>:
.globl vector90
vector90:
  pushl $0
80107eb0:	6a 00                	push   $0x0
  pushl $90
80107eb2:	6a 5a                	push   $0x5a
  jmp alltraps
80107eb4:	e9 8a f6 ff ff       	jmp    80107543 <alltraps>

80107eb9 <vector91>:
.globl vector91
vector91:
  pushl $0
80107eb9:	6a 00                	push   $0x0
  pushl $91
80107ebb:	6a 5b                	push   $0x5b
  jmp alltraps
80107ebd:	e9 81 f6 ff ff       	jmp    80107543 <alltraps>

80107ec2 <vector92>:
.globl vector92
vector92:
  pushl $0
80107ec2:	6a 00                	push   $0x0
  pushl $92
80107ec4:	6a 5c                	push   $0x5c
  jmp alltraps
80107ec6:	e9 78 f6 ff ff       	jmp    80107543 <alltraps>

80107ecb <vector93>:
.globl vector93
vector93:
  pushl $0
80107ecb:	6a 00                	push   $0x0
  pushl $93
80107ecd:	6a 5d                	push   $0x5d
  jmp alltraps
80107ecf:	e9 6f f6 ff ff       	jmp    80107543 <alltraps>

80107ed4 <vector94>:
.globl vector94
vector94:
  pushl $0
80107ed4:	6a 00                	push   $0x0
  pushl $94
80107ed6:	6a 5e                	push   $0x5e
  jmp alltraps
80107ed8:	e9 66 f6 ff ff       	jmp    80107543 <alltraps>

80107edd <vector95>:
.globl vector95
vector95:
  pushl $0
80107edd:	6a 00                	push   $0x0
  pushl $95
80107edf:	6a 5f                	push   $0x5f
  jmp alltraps
80107ee1:	e9 5d f6 ff ff       	jmp    80107543 <alltraps>

80107ee6 <vector96>:
.globl vector96
vector96:
  pushl $0
80107ee6:	6a 00                	push   $0x0
  pushl $96
80107ee8:	6a 60                	push   $0x60
  jmp alltraps
80107eea:	e9 54 f6 ff ff       	jmp    80107543 <alltraps>

80107eef <vector97>:
.globl vector97
vector97:
  pushl $0
80107eef:	6a 00                	push   $0x0
  pushl $97
80107ef1:	6a 61                	push   $0x61
  jmp alltraps
80107ef3:	e9 4b f6 ff ff       	jmp    80107543 <alltraps>

80107ef8 <vector98>:
.globl vector98
vector98:
  pushl $0
80107ef8:	6a 00                	push   $0x0
  pushl $98
80107efa:	6a 62                	push   $0x62
  jmp alltraps
80107efc:	e9 42 f6 ff ff       	jmp    80107543 <alltraps>

80107f01 <vector99>:
.globl vector99
vector99:
  pushl $0
80107f01:	6a 00                	push   $0x0
  pushl $99
80107f03:	6a 63                	push   $0x63
  jmp alltraps
80107f05:	e9 39 f6 ff ff       	jmp    80107543 <alltraps>

80107f0a <vector100>:
.globl vector100
vector100:
  pushl $0
80107f0a:	6a 00                	push   $0x0
  pushl $100
80107f0c:	6a 64                	push   $0x64
  jmp alltraps
80107f0e:	e9 30 f6 ff ff       	jmp    80107543 <alltraps>

80107f13 <vector101>:
.globl vector101
vector101:
  pushl $0
80107f13:	6a 00                	push   $0x0
  pushl $101
80107f15:	6a 65                	push   $0x65
  jmp alltraps
80107f17:	e9 27 f6 ff ff       	jmp    80107543 <alltraps>

80107f1c <vector102>:
.globl vector102
vector102:
  pushl $0
80107f1c:	6a 00                	push   $0x0
  pushl $102
80107f1e:	6a 66                	push   $0x66
  jmp alltraps
80107f20:	e9 1e f6 ff ff       	jmp    80107543 <alltraps>

80107f25 <vector103>:
.globl vector103
vector103:
  pushl $0
80107f25:	6a 00                	push   $0x0
  pushl $103
80107f27:	6a 67                	push   $0x67
  jmp alltraps
80107f29:	e9 15 f6 ff ff       	jmp    80107543 <alltraps>

80107f2e <vector104>:
.globl vector104
vector104:
  pushl $0
80107f2e:	6a 00                	push   $0x0
  pushl $104
80107f30:	6a 68                	push   $0x68
  jmp alltraps
80107f32:	e9 0c f6 ff ff       	jmp    80107543 <alltraps>

80107f37 <vector105>:
.globl vector105
vector105:
  pushl $0
80107f37:	6a 00                	push   $0x0
  pushl $105
80107f39:	6a 69                	push   $0x69
  jmp alltraps
80107f3b:	e9 03 f6 ff ff       	jmp    80107543 <alltraps>

80107f40 <vector106>:
.globl vector106
vector106:
  pushl $0
80107f40:	6a 00                	push   $0x0
  pushl $106
80107f42:	6a 6a                	push   $0x6a
  jmp alltraps
80107f44:	e9 fa f5 ff ff       	jmp    80107543 <alltraps>

80107f49 <vector107>:
.globl vector107
vector107:
  pushl $0
80107f49:	6a 00                	push   $0x0
  pushl $107
80107f4b:	6a 6b                	push   $0x6b
  jmp alltraps
80107f4d:	e9 f1 f5 ff ff       	jmp    80107543 <alltraps>

80107f52 <vector108>:
.globl vector108
vector108:
  pushl $0
80107f52:	6a 00                	push   $0x0
  pushl $108
80107f54:	6a 6c                	push   $0x6c
  jmp alltraps
80107f56:	e9 e8 f5 ff ff       	jmp    80107543 <alltraps>

80107f5b <vector109>:
.globl vector109
vector109:
  pushl $0
80107f5b:	6a 00                	push   $0x0
  pushl $109
80107f5d:	6a 6d                	push   $0x6d
  jmp alltraps
80107f5f:	e9 df f5 ff ff       	jmp    80107543 <alltraps>

80107f64 <vector110>:
.globl vector110
vector110:
  pushl $0
80107f64:	6a 00                	push   $0x0
  pushl $110
80107f66:	6a 6e                	push   $0x6e
  jmp alltraps
80107f68:	e9 d6 f5 ff ff       	jmp    80107543 <alltraps>

80107f6d <vector111>:
.globl vector111
vector111:
  pushl $0
80107f6d:	6a 00                	push   $0x0
  pushl $111
80107f6f:	6a 6f                	push   $0x6f
  jmp alltraps
80107f71:	e9 cd f5 ff ff       	jmp    80107543 <alltraps>

80107f76 <vector112>:
.globl vector112
vector112:
  pushl $0
80107f76:	6a 00                	push   $0x0
  pushl $112
80107f78:	6a 70                	push   $0x70
  jmp alltraps
80107f7a:	e9 c4 f5 ff ff       	jmp    80107543 <alltraps>

80107f7f <vector113>:
.globl vector113
vector113:
  pushl $0
80107f7f:	6a 00                	push   $0x0
  pushl $113
80107f81:	6a 71                	push   $0x71
  jmp alltraps
80107f83:	e9 bb f5 ff ff       	jmp    80107543 <alltraps>

80107f88 <vector114>:
.globl vector114
vector114:
  pushl $0
80107f88:	6a 00                	push   $0x0
  pushl $114
80107f8a:	6a 72                	push   $0x72
  jmp alltraps
80107f8c:	e9 b2 f5 ff ff       	jmp    80107543 <alltraps>

80107f91 <vector115>:
.globl vector115
vector115:
  pushl $0
80107f91:	6a 00                	push   $0x0
  pushl $115
80107f93:	6a 73                	push   $0x73
  jmp alltraps
80107f95:	e9 a9 f5 ff ff       	jmp    80107543 <alltraps>

80107f9a <vector116>:
.globl vector116
vector116:
  pushl $0
80107f9a:	6a 00                	push   $0x0
  pushl $116
80107f9c:	6a 74                	push   $0x74
  jmp alltraps
80107f9e:	e9 a0 f5 ff ff       	jmp    80107543 <alltraps>

80107fa3 <vector117>:
.globl vector117
vector117:
  pushl $0
80107fa3:	6a 00                	push   $0x0
  pushl $117
80107fa5:	6a 75                	push   $0x75
  jmp alltraps
80107fa7:	e9 97 f5 ff ff       	jmp    80107543 <alltraps>

80107fac <vector118>:
.globl vector118
vector118:
  pushl $0
80107fac:	6a 00                	push   $0x0
  pushl $118
80107fae:	6a 76                	push   $0x76
  jmp alltraps
80107fb0:	e9 8e f5 ff ff       	jmp    80107543 <alltraps>

80107fb5 <vector119>:
.globl vector119
vector119:
  pushl $0
80107fb5:	6a 00                	push   $0x0
  pushl $119
80107fb7:	6a 77                	push   $0x77
  jmp alltraps
80107fb9:	e9 85 f5 ff ff       	jmp    80107543 <alltraps>

80107fbe <vector120>:
.globl vector120
vector120:
  pushl $0
80107fbe:	6a 00                	push   $0x0
  pushl $120
80107fc0:	6a 78                	push   $0x78
  jmp alltraps
80107fc2:	e9 7c f5 ff ff       	jmp    80107543 <alltraps>

80107fc7 <vector121>:
.globl vector121
vector121:
  pushl $0
80107fc7:	6a 00                	push   $0x0
  pushl $121
80107fc9:	6a 79                	push   $0x79
  jmp alltraps
80107fcb:	e9 73 f5 ff ff       	jmp    80107543 <alltraps>

80107fd0 <vector122>:
.globl vector122
vector122:
  pushl $0
80107fd0:	6a 00                	push   $0x0
  pushl $122
80107fd2:	6a 7a                	push   $0x7a
  jmp alltraps
80107fd4:	e9 6a f5 ff ff       	jmp    80107543 <alltraps>

80107fd9 <vector123>:
.globl vector123
vector123:
  pushl $0
80107fd9:	6a 00                	push   $0x0
  pushl $123
80107fdb:	6a 7b                	push   $0x7b
  jmp alltraps
80107fdd:	e9 61 f5 ff ff       	jmp    80107543 <alltraps>

80107fe2 <vector124>:
.globl vector124
vector124:
  pushl $0
80107fe2:	6a 00                	push   $0x0
  pushl $124
80107fe4:	6a 7c                	push   $0x7c
  jmp alltraps
80107fe6:	e9 58 f5 ff ff       	jmp    80107543 <alltraps>

80107feb <vector125>:
.globl vector125
vector125:
  pushl $0
80107feb:	6a 00                	push   $0x0
  pushl $125
80107fed:	6a 7d                	push   $0x7d
  jmp alltraps
80107fef:	e9 4f f5 ff ff       	jmp    80107543 <alltraps>

80107ff4 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ff4:	6a 00                	push   $0x0
  pushl $126
80107ff6:	6a 7e                	push   $0x7e
  jmp alltraps
80107ff8:	e9 46 f5 ff ff       	jmp    80107543 <alltraps>

80107ffd <vector127>:
.globl vector127
vector127:
  pushl $0
80107ffd:	6a 00                	push   $0x0
  pushl $127
80107fff:	6a 7f                	push   $0x7f
  jmp alltraps
80108001:	e9 3d f5 ff ff       	jmp    80107543 <alltraps>

80108006 <vector128>:
.globl vector128
vector128:
  pushl $0
80108006:	6a 00                	push   $0x0
  pushl $128
80108008:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010800d:	e9 31 f5 ff ff       	jmp    80107543 <alltraps>

80108012 <vector129>:
.globl vector129
vector129:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $129
80108014:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108019:	e9 25 f5 ff ff       	jmp    80107543 <alltraps>

8010801e <vector130>:
.globl vector130
vector130:
  pushl $0
8010801e:	6a 00                	push   $0x0
  pushl $130
80108020:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108025:	e9 19 f5 ff ff       	jmp    80107543 <alltraps>

8010802a <vector131>:
.globl vector131
vector131:
  pushl $0
8010802a:	6a 00                	push   $0x0
  pushl $131
8010802c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108031:	e9 0d f5 ff ff       	jmp    80107543 <alltraps>

80108036 <vector132>:
.globl vector132
vector132:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $132
80108038:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010803d:	e9 01 f5 ff ff       	jmp    80107543 <alltraps>

80108042 <vector133>:
.globl vector133
vector133:
  pushl $0
80108042:	6a 00                	push   $0x0
  pushl $133
80108044:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108049:	e9 f5 f4 ff ff       	jmp    80107543 <alltraps>

8010804e <vector134>:
.globl vector134
vector134:
  pushl $0
8010804e:	6a 00                	push   $0x0
  pushl $134
80108050:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108055:	e9 e9 f4 ff ff       	jmp    80107543 <alltraps>

8010805a <vector135>:
.globl vector135
vector135:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $135
8010805c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108061:	e9 dd f4 ff ff       	jmp    80107543 <alltraps>

80108066 <vector136>:
.globl vector136
vector136:
  pushl $0
80108066:	6a 00                	push   $0x0
  pushl $136
80108068:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010806d:	e9 d1 f4 ff ff       	jmp    80107543 <alltraps>

80108072 <vector137>:
.globl vector137
vector137:
  pushl $0
80108072:	6a 00                	push   $0x0
  pushl $137
80108074:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108079:	e9 c5 f4 ff ff       	jmp    80107543 <alltraps>

8010807e <vector138>:
.globl vector138
vector138:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $138
80108080:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108085:	e9 b9 f4 ff ff       	jmp    80107543 <alltraps>

8010808a <vector139>:
.globl vector139
vector139:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $139
8010808c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108091:	e9 ad f4 ff ff       	jmp    80107543 <alltraps>

80108096 <vector140>:
.globl vector140
vector140:
  pushl $0
80108096:	6a 00                	push   $0x0
  pushl $140
80108098:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010809d:	e9 a1 f4 ff ff       	jmp    80107543 <alltraps>

801080a2 <vector141>:
.globl vector141
vector141:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $141
801080a4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801080a9:	e9 95 f4 ff ff       	jmp    80107543 <alltraps>

801080ae <vector142>:
.globl vector142
vector142:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $142
801080b0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801080b5:	e9 89 f4 ff ff       	jmp    80107543 <alltraps>

801080ba <vector143>:
.globl vector143
vector143:
  pushl $0
801080ba:	6a 00                	push   $0x0
  pushl $143
801080bc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801080c1:	e9 7d f4 ff ff       	jmp    80107543 <alltraps>

801080c6 <vector144>:
.globl vector144
vector144:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $144
801080c8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801080cd:	e9 71 f4 ff ff       	jmp    80107543 <alltraps>

801080d2 <vector145>:
.globl vector145
vector145:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $145
801080d4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801080d9:	e9 65 f4 ff ff       	jmp    80107543 <alltraps>

801080de <vector146>:
.globl vector146
vector146:
  pushl $0
801080de:	6a 00                	push   $0x0
  pushl $146
801080e0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801080e5:	e9 59 f4 ff ff       	jmp    80107543 <alltraps>

801080ea <vector147>:
.globl vector147
vector147:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $147
801080ec:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801080f1:	e9 4d f4 ff ff       	jmp    80107543 <alltraps>

801080f6 <vector148>:
.globl vector148
vector148:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $148
801080f8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801080fd:	e9 41 f4 ff ff       	jmp    80107543 <alltraps>

80108102 <vector149>:
.globl vector149
vector149:
  pushl $0
80108102:	6a 00                	push   $0x0
  pushl $149
80108104:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108109:	e9 35 f4 ff ff       	jmp    80107543 <alltraps>

8010810e <vector150>:
.globl vector150
vector150:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $150
80108110:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108115:	e9 29 f4 ff ff       	jmp    80107543 <alltraps>

8010811a <vector151>:
.globl vector151
vector151:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $151
8010811c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108121:	e9 1d f4 ff ff       	jmp    80107543 <alltraps>

80108126 <vector152>:
.globl vector152
vector152:
  pushl $0
80108126:	6a 00                	push   $0x0
  pushl $152
80108128:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010812d:	e9 11 f4 ff ff       	jmp    80107543 <alltraps>

80108132 <vector153>:
.globl vector153
vector153:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $153
80108134:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108139:	e9 05 f4 ff ff       	jmp    80107543 <alltraps>

8010813e <vector154>:
.globl vector154
vector154:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $154
80108140:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108145:	e9 f9 f3 ff ff       	jmp    80107543 <alltraps>

8010814a <vector155>:
.globl vector155
vector155:
  pushl $0
8010814a:	6a 00                	push   $0x0
  pushl $155
8010814c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108151:	e9 ed f3 ff ff       	jmp    80107543 <alltraps>

80108156 <vector156>:
.globl vector156
vector156:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $156
80108158:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010815d:	e9 e1 f3 ff ff       	jmp    80107543 <alltraps>

80108162 <vector157>:
.globl vector157
vector157:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $157
80108164:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108169:	e9 d5 f3 ff ff       	jmp    80107543 <alltraps>

8010816e <vector158>:
.globl vector158
vector158:
  pushl $0
8010816e:	6a 00                	push   $0x0
  pushl $158
80108170:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108175:	e9 c9 f3 ff ff       	jmp    80107543 <alltraps>

8010817a <vector159>:
.globl vector159
vector159:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $159
8010817c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108181:	e9 bd f3 ff ff       	jmp    80107543 <alltraps>

80108186 <vector160>:
.globl vector160
vector160:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $160
80108188:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010818d:	e9 b1 f3 ff ff       	jmp    80107543 <alltraps>

80108192 <vector161>:
.globl vector161
vector161:
  pushl $0
80108192:	6a 00                	push   $0x0
  pushl $161
80108194:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108199:	e9 a5 f3 ff ff       	jmp    80107543 <alltraps>

8010819e <vector162>:
.globl vector162
vector162:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $162
801081a0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801081a5:	e9 99 f3 ff ff       	jmp    80107543 <alltraps>

801081aa <vector163>:
.globl vector163
vector163:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $163
801081ac:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801081b1:	e9 8d f3 ff ff       	jmp    80107543 <alltraps>

801081b6 <vector164>:
.globl vector164
vector164:
  pushl $0
801081b6:	6a 00                	push   $0x0
  pushl $164
801081b8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801081bd:	e9 81 f3 ff ff       	jmp    80107543 <alltraps>

801081c2 <vector165>:
.globl vector165
vector165:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $165
801081c4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801081c9:	e9 75 f3 ff ff       	jmp    80107543 <alltraps>

801081ce <vector166>:
.globl vector166
vector166:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $166
801081d0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801081d5:	e9 69 f3 ff ff       	jmp    80107543 <alltraps>

801081da <vector167>:
.globl vector167
vector167:
  pushl $0
801081da:	6a 00                	push   $0x0
  pushl $167
801081dc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801081e1:	e9 5d f3 ff ff       	jmp    80107543 <alltraps>

801081e6 <vector168>:
.globl vector168
vector168:
  pushl $0
801081e6:	6a 00                	push   $0x0
  pushl $168
801081e8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801081ed:	e9 51 f3 ff ff       	jmp    80107543 <alltraps>

801081f2 <vector169>:
.globl vector169
vector169:
  pushl $0
801081f2:	6a 00                	push   $0x0
  pushl $169
801081f4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801081f9:	e9 45 f3 ff ff       	jmp    80107543 <alltraps>

801081fe <vector170>:
.globl vector170
vector170:
  pushl $0
801081fe:	6a 00                	push   $0x0
  pushl $170
80108200:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108205:	e9 39 f3 ff ff       	jmp    80107543 <alltraps>

8010820a <vector171>:
.globl vector171
vector171:
  pushl $0
8010820a:	6a 00                	push   $0x0
  pushl $171
8010820c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108211:	e9 2d f3 ff ff       	jmp    80107543 <alltraps>

80108216 <vector172>:
.globl vector172
vector172:
  pushl $0
80108216:	6a 00                	push   $0x0
  pushl $172
80108218:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010821d:	e9 21 f3 ff ff       	jmp    80107543 <alltraps>

80108222 <vector173>:
.globl vector173
vector173:
  pushl $0
80108222:	6a 00                	push   $0x0
  pushl $173
80108224:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108229:	e9 15 f3 ff ff       	jmp    80107543 <alltraps>

8010822e <vector174>:
.globl vector174
vector174:
  pushl $0
8010822e:	6a 00                	push   $0x0
  pushl $174
80108230:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108235:	e9 09 f3 ff ff       	jmp    80107543 <alltraps>

8010823a <vector175>:
.globl vector175
vector175:
  pushl $0
8010823a:	6a 00                	push   $0x0
  pushl $175
8010823c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108241:	e9 fd f2 ff ff       	jmp    80107543 <alltraps>

80108246 <vector176>:
.globl vector176
vector176:
  pushl $0
80108246:	6a 00                	push   $0x0
  pushl $176
80108248:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010824d:	e9 f1 f2 ff ff       	jmp    80107543 <alltraps>

80108252 <vector177>:
.globl vector177
vector177:
  pushl $0
80108252:	6a 00                	push   $0x0
  pushl $177
80108254:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108259:	e9 e5 f2 ff ff       	jmp    80107543 <alltraps>

8010825e <vector178>:
.globl vector178
vector178:
  pushl $0
8010825e:	6a 00                	push   $0x0
  pushl $178
80108260:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108265:	e9 d9 f2 ff ff       	jmp    80107543 <alltraps>

8010826a <vector179>:
.globl vector179
vector179:
  pushl $0
8010826a:	6a 00                	push   $0x0
  pushl $179
8010826c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108271:	e9 cd f2 ff ff       	jmp    80107543 <alltraps>

80108276 <vector180>:
.globl vector180
vector180:
  pushl $0
80108276:	6a 00                	push   $0x0
  pushl $180
80108278:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010827d:	e9 c1 f2 ff ff       	jmp    80107543 <alltraps>

80108282 <vector181>:
.globl vector181
vector181:
  pushl $0
80108282:	6a 00                	push   $0x0
  pushl $181
80108284:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108289:	e9 b5 f2 ff ff       	jmp    80107543 <alltraps>

8010828e <vector182>:
.globl vector182
vector182:
  pushl $0
8010828e:	6a 00                	push   $0x0
  pushl $182
80108290:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108295:	e9 a9 f2 ff ff       	jmp    80107543 <alltraps>

8010829a <vector183>:
.globl vector183
vector183:
  pushl $0
8010829a:	6a 00                	push   $0x0
  pushl $183
8010829c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801082a1:	e9 9d f2 ff ff       	jmp    80107543 <alltraps>

801082a6 <vector184>:
.globl vector184
vector184:
  pushl $0
801082a6:	6a 00                	push   $0x0
  pushl $184
801082a8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801082ad:	e9 91 f2 ff ff       	jmp    80107543 <alltraps>

801082b2 <vector185>:
.globl vector185
vector185:
  pushl $0
801082b2:	6a 00                	push   $0x0
  pushl $185
801082b4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801082b9:	e9 85 f2 ff ff       	jmp    80107543 <alltraps>

801082be <vector186>:
.globl vector186
vector186:
  pushl $0
801082be:	6a 00                	push   $0x0
  pushl $186
801082c0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801082c5:	e9 79 f2 ff ff       	jmp    80107543 <alltraps>

801082ca <vector187>:
.globl vector187
vector187:
  pushl $0
801082ca:	6a 00                	push   $0x0
  pushl $187
801082cc:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801082d1:	e9 6d f2 ff ff       	jmp    80107543 <alltraps>

801082d6 <vector188>:
.globl vector188
vector188:
  pushl $0
801082d6:	6a 00                	push   $0x0
  pushl $188
801082d8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801082dd:	e9 61 f2 ff ff       	jmp    80107543 <alltraps>

801082e2 <vector189>:
.globl vector189
vector189:
  pushl $0
801082e2:	6a 00                	push   $0x0
  pushl $189
801082e4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801082e9:	e9 55 f2 ff ff       	jmp    80107543 <alltraps>

801082ee <vector190>:
.globl vector190
vector190:
  pushl $0
801082ee:	6a 00                	push   $0x0
  pushl $190
801082f0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801082f5:	e9 49 f2 ff ff       	jmp    80107543 <alltraps>

801082fa <vector191>:
.globl vector191
vector191:
  pushl $0
801082fa:	6a 00                	push   $0x0
  pushl $191
801082fc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108301:	e9 3d f2 ff ff       	jmp    80107543 <alltraps>

80108306 <vector192>:
.globl vector192
vector192:
  pushl $0
80108306:	6a 00                	push   $0x0
  pushl $192
80108308:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010830d:	e9 31 f2 ff ff       	jmp    80107543 <alltraps>

80108312 <vector193>:
.globl vector193
vector193:
  pushl $0
80108312:	6a 00                	push   $0x0
  pushl $193
80108314:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108319:	e9 25 f2 ff ff       	jmp    80107543 <alltraps>

8010831e <vector194>:
.globl vector194
vector194:
  pushl $0
8010831e:	6a 00                	push   $0x0
  pushl $194
80108320:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108325:	e9 19 f2 ff ff       	jmp    80107543 <alltraps>

8010832a <vector195>:
.globl vector195
vector195:
  pushl $0
8010832a:	6a 00                	push   $0x0
  pushl $195
8010832c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108331:	e9 0d f2 ff ff       	jmp    80107543 <alltraps>

80108336 <vector196>:
.globl vector196
vector196:
  pushl $0
80108336:	6a 00                	push   $0x0
  pushl $196
80108338:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010833d:	e9 01 f2 ff ff       	jmp    80107543 <alltraps>

80108342 <vector197>:
.globl vector197
vector197:
  pushl $0
80108342:	6a 00                	push   $0x0
  pushl $197
80108344:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108349:	e9 f5 f1 ff ff       	jmp    80107543 <alltraps>

8010834e <vector198>:
.globl vector198
vector198:
  pushl $0
8010834e:	6a 00                	push   $0x0
  pushl $198
80108350:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108355:	e9 e9 f1 ff ff       	jmp    80107543 <alltraps>

8010835a <vector199>:
.globl vector199
vector199:
  pushl $0
8010835a:	6a 00                	push   $0x0
  pushl $199
8010835c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108361:	e9 dd f1 ff ff       	jmp    80107543 <alltraps>

80108366 <vector200>:
.globl vector200
vector200:
  pushl $0
80108366:	6a 00                	push   $0x0
  pushl $200
80108368:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010836d:	e9 d1 f1 ff ff       	jmp    80107543 <alltraps>

80108372 <vector201>:
.globl vector201
vector201:
  pushl $0
80108372:	6a 00                	push   $0x0
  pushl $201
80108374:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108379:	e9 c5 f1 ff ff       	jmp    80107543 <alltraps>

8010837e <vector202>:
.globl vector202
vector202:
  pushl $0
8010837e:	6a 00                	push   $0x0
  pushl $202
80108380:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108385:	e9 b9 f1 ff ff       	jmp    80107543 <alltraps>

8010838a <vector203>:
.globl vector203
vector203:
  pushl $0
8010838a:	6a 00                	push   $0x0
  pushl $203
8010838c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108391:	e9 ad f1 ff ff       	jmp    80107543 <alltraps>

80108396 <vector204>:
.globl vector204
vector204:
  pushl $0
80108396:	6a 00                	push   $0x0
  pushl $204
80108398:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010839d:	e9 a1 f1 ff ff       	jmp    80107543 <alltraps>

801083a2 <vector205>:
.globl vector205
vector205:
  pushl $0
801083a2:	6a 00                	push   $0x0
  pushl $205
801083a4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801083a9:	e9 95 f1 ff ff       	jmp    80107543 <alltraps>

801083ae <vector206>:
.globl vector206
vector206:
  pushl $0
801083ae:	6a 00                	push   $0x0
  pushl $206
801083b0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801083b5:	e9 89 f1 ff ff       	jmp    80107543 <alltraps>

801083ba <vector207>:
.globl vector207
vector207:
  pushl $0
801083ba:	6a 00                	push   $0x0
  pushl $207
801083bc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801083c1:	e9 7d f1 ff ff       	jmp    80107543 <alltraps>

801083c6 <vector208>:
.globl vector208
vector208:
  pushl $0
801083c6:	6a 00                	push   $0x0
  pushl $208
801083c8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801083cd:	e9 71 f1 ff ff       	jmp    80107543 <alltraps>

801083d2 <vector209>:
.globl vector209
vector209:
  pushl $0
801083d2:	6a 00                	push   $0x0
  pushl $209
801083d4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801083d9:	e9 65 f1 ff ff       	jmp    80107543 <alltraps>

801083de <vector210>:
.globl vector210
vector210:
  pushl $0
801083de:	6a 00                	push   $0x0
  pushl $210
801083e0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801083e5:	e9 59 f1 ff ff       	jmp    80107543 <alltraps>

801083ea <vector211>:
.globl vector211
vector211:
  pushl $0
801083ea:	6a 00                	push   $0x0
  pushl $211
801083ec:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801083f1:	e9 4d f1 ff ff       	jmp    80107543 <alltraps>

801083f6 <vector212>:
.globl vector212
vector212:
  pushl $0
801083f6:	6a 00                	push   $0x0
  pushl $212
801083f8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801083fd:	e9 41 f1 ff ff       	jmp    80107543 <alltraps>

80108402 <vector213>:
.globl vector213
vector213:
  pushl $0
80108402:	6a 00                	push   $0x0
  pushl $213
80108404:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108409:	e9 35 f1 ff ff       	jmp    80107543 <alltraps>

8010840e <vector214>:
.globl vector214
vector214:
  pushl $0
8010840e:	6a 00                	push   $0x0
  pushl $214
80108410:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108415:	e9 29 f1 ff ff       	jmp    80107543 <alltraps>

8010841a <vector215>:
.globl vector215
vector215:
  pushl $0
8010841a:	6a 00                	push   $0x0
  pushl $215
8010841c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108421:	e9 1d f1 ff ff       	jmp    80107543 <alltraps>

80108426 <vector216>:
.globl vector216
vector216:
  pushl $0
80108426:	6a 00                	push   $0x0
  pushl $216
80108428:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010842d:	e9 11 f1 ff ff       	jmp    80107543 <alltraps>

80108432 <vector217>:
.globl vector217
vector217:
  pushl $0
80108432:	6a 00                	push   $0x0
  pushl $217
80108434:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108439:	e9 05 f1 ff ff       	jmp    80107543 <alltraps>

8010843e <vector218>:
.globl vector218
vector218:
  pushl $0
8010843e:	6a 00                	push   $0x0
  pushl $218
80108440:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108445:	e9 f9 f0 ff ff       	jmp    80107543 <alltraps>

8010844a <vector219>:
.globl vector219
vector219:
  pushl $0
8010844a:	6a 00                	push   $0x0
  pushl $219
8010844c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108451:	e9 ed f0 ff ff       	jmp    80107543 <alltraps>

80108456 <vector220>:
.globl vector220
vector220:
  pushl $0
80108456:	6a 00                	push   $0x0
  pushl $220
80108458:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010845d:	e9 e1 f0 ff ff       	jmp    80107543 <alltraps>

80108462 <vector221>:
.globl vector221
vector221:
  pushl $0
80108462:	6a 00                	push   $0x0
  pushl $221
80108464:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108469:	e9 d5 f0 ff ff       	jmp    80107543 <alltraps>

8010846e <vector222>:
.globl vector222
vector222:
  pushl $0
8010846e:	6a 00                	push   $0x0
  pushl $222
80108470:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108475:	e9 c9 f0 ff ff       	jmp    80107543 <alltraps>

8010847a <vector223>:
.globl vector223
vector223:
  pushl $0
8010847a:	6a 00                	push   $0x0
  pushl $223
8010847c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108481:	e9 bd f0 ff ff       	jmp    80107543 <alltraps>

80108486 <vector224>:
.globl vector224
vector224:
  pushl $0
80108486:	6a 00                	push   $0x0
  pushl $224
80108488:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010848d:	e9 b1 f0 ff ff       	jmp    80107543 <alltraps>

80108492 <vector225>:
.globl vector225
vector225:
  pushl $0
80108492:	6a 00                	push   $0x0
  pushl $225
80108494:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108499:	e9 a5 f0 ff ff       	jmp    80107543 <alltraps>

8010849e <vector226>:
.globl vector226
vector226:
  pushl $0
8010849e:	6a 00                	push   $0x0
  pushl $226
801084a0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801084a5:	e9 99 f0 ff ff       	jmp    80107543 <alltraps>

801084aa <vector227>:
.globl vector227
vector227:
  pushl $0
801084aa:	6a 00                	push   $0x0
  pushl $227
801084ac:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801084b1:	e9 8d f0 ff ff       	jmp    80107543 <alltraps>

801084b6 <vector228>:
.globl vector228
vector228:
  pushl $0
801084b6:	6a 00                	push   $0x0
  pushl $228
801084b8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801084bd:	e9 81 f0 ff ff       	jmp    80107543 <alltraps>

801084c2 <vector229>:
.globl vector229
vector229:
  pushl $0
801084c2:	6a 00                	push   $0x0
  pushl $229
801084c4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801084c9:	e9 75 f0 ff ff       	jmp    80107543 <alltraps>

801084ce <vector230>:
.globl vector230
vector230:
  pushl $0
801084ce:	6a 00                	push   $0x0
  pushl $230
801084d0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801084d5:	e9 69 f0 ff ff       	jmp    80107543 <alltraps>

801084da <vector231>:
.globl vector231
vector231:
  pushl $0
801084da:	6a 00                	push   $0x0
  pushl $231
801084dc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801084e1:	e9 5d f0 ff ff       	jmp    80107543 <alltraps>

801084e6 <vector232>:
.globl vector232
vector232:
  pushl $0
801084e6:	6a 00                	push   $0x0
  pushl $232
801084e8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801084ed:	e9 51 f0 ff ff       	jmp    80107543 <alltraps>

801084f2 <vector233>:
.globl vector233
vector233:
  pushl $0
801084f2:	6a 00                	push   $0x0
  pushl $233
801084f4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801084f9:	e9 45 f0 ff ff       	jmp    80107543 <alltraps>

801084fe <vector234>:
.globl vector234
vector234:
  pushl $0
801084fe:	6a 00                	push   $0x0
  pushl $234
80108500:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108505:	e9 39 f0 ff ff       	jmp    80107543 <alltraps>

8010850a <vector235>:
.globl vector235
vector235:
  pushl $0
8010850a:	6a 00                	push   $0x0
  pushl $235
8010850c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108511:	e9 2d f0 ff ff       	jmp    80107543 <alltraps>

80108516 <vector236>:
.globl vector236
vector236:
  pushl $0
80108516:	6a 00                	push   $0x0
  pushl $236
80108518:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010851d:	e9 21 f0 ff ff       	jmp    80107543 <alltraps>

80108522 <vector237>:
.globl vector237
vector237:
  pushl $0
80108522:	6a 00                	push   $0x0
  pushl $237
80108524:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108529:	e9 15 f0 ff ff       	jmp    80107543 <alltraps>

8010852e <vector238>:
.globl vector238
vector238:
  pushl $0
8010852e:	6a 00                	push   $0x0
  pushl $238
80108530:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108535:	e9 09 f0 ff ff       	jmp    80107543 <alltraps>

8010853a <vector239>:
.globl vector239
vector239:
  pushl $0
8010853a:	6a 00                	push   $0x0
  pushl $239
8010853c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108541:	e9 fd ef ff ff       	jmp    80107543 <alltraps>

80108546 <vector240>:
.globl vector240
vector240:
  pushl $0
80108546:	6a 00                	push   $0x0
  pushl $240
80108548:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010854d:	e9 f1 ef ff ff       	jmp    80107543 <alltraps>

80108552 <vector241>:
.globl vector241
vector241:
  pushl $0
80108552:	6a 00                	push   $0x0
  pushl $241
80108554:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108559:	e9 e5 ef ff ff       	jmp    80107543 <alltraps>

8010855e <vector242>:
.globl vector242
vector242:
  pushl $0
8010855e:	6a 00                	push   $0x0
  pushl $242
80108560:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108565:	e9 d9 ef ff ff       	jmp    80107543 <alltraps>

8010856a <vector243>:
.globl vector243
vector243:
  pushl $0
8010856a:	6a 00                	push   $0x0
  pushl $243
8010856c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108571:	e9 cd ef ff ff       	jmp    80107543 <alltraps>

80108576 <vector244>:
.globl vector244
vector244:
  pushl $0
80108576:	6a 00                	push   $0x0
  pushl $244
80108578:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010857d:	e9 c1 ef ff ff       	jmp    80107543 <alltraps>

80108582 <vector245>:
.globl vector245
vector245:
  pushl $0
80108582:	6a 00                	push   $0x0
  pushl $245
80108584:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108589:	e9 b5 ef ff ff       	jmp    80107543 <alltraps>

8010858e <vector246>:
.globl vector246
vector246:
  pushl $0
8010858e:	6a 00                	push   $0x0
  pushl $246
80108590:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108595:	e9 a9 ef ff ff       	jmp    80107543 <alltraps>

8010859a <vector247>:
.globl vector247
vector247:
  pushl $0
8010859a:	6a 00                	push   $0x0
  pushl $247
8010859c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801085a1:	e9 9d ef ff ff       	jmp    80107543 <alltraps>

801085a6 <vector248>:
.globl vector248
vector248:
  pushl $0
801085a6:	6a 00                	push   $0x0
  pushl $248
801085a8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801085ad:	e9 91 ef ff ff       	jmp    80107543 <alltraps>

801085b2 <vector249>:
.globl vector249
vector249:
  pushl $0
801085b2:	6a 00                	push   $0x0
  pushl $249
801085b4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801085b9:	e9 85 ef ff ff       	jmp    80107543 <alltraps>

801085be <vector250>:
.globl vector250
vector250:
  pushl $0
801085be:	6a 00                	push   $0x0
  pushl $250
801085c0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801085c5:	e9 79 ef ff ff       	jmp    80107543 <alltraps>

801085ca <vector251>:
.globl vector251
vector251:
  pushl $0
801085ca:	6a 00                	push   $0x0
  pushl $251
801085cc:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801085d1:	e9 6d ef ff ff       	jmp    80107543 <alltraps>

801085d6 <vector252>:
.globl vector252
vector252:
  pushl $0
801085d6:	6a 00                	push   $0x0
  pushl $252
801085d8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801085dd:	e9 61 ef ff ff       	jmp    80107543 <alltraps>

801085e2 <vector253>:
.globl vector253
vector253:
  pushl $0
801085e2:	6a 00                	push   $0x0
  pushl $253
801085e4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801085e9:	e9 55 ef ff ff       	jmp    80107543 <alltraps>

801085ee <vector254>:
.globl vector254
vector254:
  pushl $0
801085ee:	6a 00                	push   $0x0
  pushl $254
801085f0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801085f5:	e9 49 ef ff ff       	jmp    80107543 <alltraps>

801085fa <vector255>:
.globl vector255
vector255:
  pushl $0
801085fa:	6a 00                	push   $0x0
  pushl $255
801085fc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108601:	e9 3d ef ff ff       	jmp    80107543 <alltraps>

80108606 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108606:	55                   	push   %ebp
80108607:	89 e5                	mov    %esp,%ebp
80108609:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010860c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010860f:	83 e8 01             	sub    $0x1,%eax
80108612:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108616:	8b 45 08             	mov    0x8(%ebp),%eax
80108619:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010861d:	8b 45 08             	mov    0x8(%ebp),%eax
80108620:	c1 e8 10             	shr    $0x10,%eax
80108623:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108627:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010862a:	0f 01 10             	lgdtl  (%eax)
}
8010862d:	90                   	nop
8010862e:	c9                   	leave  
8010862f:	c3                   	ret    

80108630 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108630:	55                   	push   %ebp
80108631:	89 e5                	mov    %esp,%ebp
80108633:	83 ec 04             	sub    $0x4,%esp
80108636:	8b 45 08             	mov    0x8(%ebp),%eax
80108639:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010863d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108641:	0f 00 d8             	ltr    %ax
}
80108644:	90                   	nop
80108645:	c9                   	leave  
80108646:	c3                   	ret    

80108647 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108647:	55                   	push   %ebp
80108648:	89 e5                	mov    %esp,%ebp
8010864a:	83 ec 04             	sub    $0x4,%esp
8010864d:	8b 45 08             	mov    0x8(%ebp),%eax
80108650:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108654:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108658:	8e e8                	mov    %eax,%gs
}
8010865a:	90                   	nop
8010865b:	c9                   	leave  
8010865c:	c3                   	ret    

8010865d <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010865d:	55                   	push   %ebp
8010865e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108660:	8b 45 08             	mov    0x8(%ebp),%eax
80108663:	0f 22 d8             	mov    %eax,%cr3
}
80108666:	90                   	nop
80108667:	5d                   	pop    %ebp
80108668:	c3                   	ret    

80108669 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108669:	55                   	push   %ebp
8010866a:	89 e5                	mov    %esp,%ebp
8010866c:	8b 45 08             	mov    0x8(%ebp),%eax
8010866f:	05 00 00 00 80       	add    $0x80000000,%eax
80108674:	5d                   	pop    %ebp
80108675:	c3                   	ret    

80108676 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108676:	55                   	push   %ebp
80108677:	89 e5                	mov    %esp,%ebp
80108679:	8b 45 08             	mov    0x8(%ebp),%eax
8010867c:	05 00 00 00 80       	add    $0x80000000,%eax
80108681:	5d                   	pop    %ebp
80108682:	c3                   	ret    

80108683 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108683:	55                   	push   %ebp
80108684:	89 e5                	mov    %esp,%ebp
80108686:	53                   	push   %ebx
80108687:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010868a:	e8 49 b1 ff ff       	call   801037d8 <cpunum>
8010868f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108695:	05 80 38 11 80       	add    $0x80113880,%eax
8010869a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010869d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801086af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801086b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086bd:	83 e2 f0             	and    $0xfffffff0,%edx
801086c0:	83 ca 0a             	or     $0xa,%edx
801086c3:	88 50 7d             	mov    %dl,0x7d(%eax)
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086cd:	83 ca 10             	or     $0x10,%edx
801086d0:	88 50 7d             	mov    %dl,0x7d(%eax)
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086da:	83 e2 9f             	and    $0xffffff9f,%edx
801086dd:	88 50 7d             	mov    %dl,0x7d(%eax)
801086e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086e7:	83 ca 80             	or     $0xffffff80,%edx
801086ea:	88 50 7d             	mov    %dl,0x7d(%eax)
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086f4:	83 ca 0f             	or     $0xf,%edx
801086f7:	88 50 7e             	mov    %dl,0x7e(%eax)
801086fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108701:	83 e2 ef             	and    $0xffffffef,%edx
80108704:	88 50 7e             	mov    %dl,0x7e(%eax)
80108707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010870e:	83 e2 df             	and    $0xffffffdf,%edx
80108711:	88 50 7e             	mov    %dl,0x7e(%eax)
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010871b:	83 ca 40             	or     $0x40,%edx
8010871e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108724:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108728:	83 ca 80             	or     $0xffffff80,%edx
8010872b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010872e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108731:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108738:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010873f:	ff ff 
80108741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108744:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010874b:	00 00 
8010874d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108750:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108761:	83 e2 f0             	and    $0xfffffff0,%edx
80108764:	83 ca 02             	or     $0x2,%edx
80108767:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010876d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108770:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108777:	83 ca 10             	or     $0x10,%edx
8010877a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010878a:	83 e2 9f             	and    $0xffffff9f,%edx
8010878d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108796:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010879d:	83 ca 80             	or     $0xffffff80,%edx
801087a0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087b0:	83 ca 0f             	or     $0xf,%edx
801087b3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087c3:	83 e2 ef             	and    $0xffffffef,%edx
801087c6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087d6:	83 e2 df             	and    $0xffffffdf,%edx
801087d9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087e9:	83 ca 40             	or     $0x40,%edx
801087ec:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087fc:	83 ca 80             	or     $0xffffff80,%edx
801087ff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108808:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010880f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108812:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108819:	ff ff 
8010881b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108825:	00 00 
80108827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108834:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010883b:	83 e2 f0             	and    $0xfffffff0,%edx
8010883e:	83 ca 0a             	or     $0xa,%edx
80108841:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108851:	83 ca 10             	or     $0x10,%edx
80108854:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010885a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108864:	83 ca 60             	or     $0x60,%edx
80108867:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010886d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108870:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108877:	83 ca 80             	or     $0xffffff80,%edx
8010887a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108883:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010888a:	83 ca 0f             	or     $0xf,%edx
8010888d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108896:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010889d:	83 e2 ef             	and    $0xffffffef,%edx
801088a0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088b0:	83 e2 df             	and    $0xffffffdf,%edx
801088b3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088c3:	83 ca 40             	or     $0x40,%edx
801088c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088d6:	83 ca 80             	or     $0xffffff80,%edx
801088d9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e2:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801088f3:	ff ff 
801088f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f8:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801088ff:	00 00 
80108901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108904:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010890b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108915:	83 e2 f0             	and    $0xfffffff0,%edx
80108918:	83 ca 02             	or     $0x2,%edx
8010891b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108924:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010892b:	83 ca 10             	or     $0x10,%edx
8010892e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108937:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010893e:	83 ca 60             	or     $0x60,%edx
80108941:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108951:	83 ca 80             	or     $0xffffff80,%edx
80108954:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010895a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108964:	83 ca 0f             	or     $0xf,%edx
80108967:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010896d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108970:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108977:	83 e2 ef             	and    $0xffffffef,%edx
8010897a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108983:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010898a:	83 e2 df             	and    $0xffffffdf,%edx
8010898d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108996:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010899d:	83 ca 40             	or     $0x40,%edx
801089a0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089b0:	83 ca 80             	or     $0xffffff80,%edx
801089b3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bc:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c6:	05 b4 00 00 00       	add    $0xb4,%eax
801089cb:	89 c3                	mov    %eax,%ebx
801089cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d0:	05 b4 00 00 00       	add    $0xb4,%eax
801089d5:	c1 e8 10             	shr    $0x10,%eax
801089d8:	89 c2                	mov    %eax,%edx
801089da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089dd:	05 b4 00 00 00       	add    $0xb4,%eax
801089e2:	c1 e8 18             	shr    $0x18,%eax
801089e5:	89 c1                	mov    %eax,%ecx
801089e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ea:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801089f1:	00 00 
801089f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f6:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801089fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a00:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a09:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a10:	83 e2 f0             	and    $0xfffffff0,%edx
80108a13:	83 ca 02             	or     $0x2,%edx
80108a16:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a26:	83 ca 10             	or     $0x10,%edx
80108a29:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a32:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a39:	83 e2 9f             	and    $0xffffff9f,%edx
80108a3c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a45:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a4c:	83 ca 80             	or     $0xffffff80,%edx
80108a4f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a58:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a5f:	83 e2 f0             	and    $0xfffffff0,%edx
80108a62:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a72:	83 e2 ef             	and    $0xffffffef,%edx
80108a75:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a85:	83 e2 df             	and    $0xffffffdf,%edx
80108a88:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a91:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a98:	83 ca 40             	or     $0x40,%edx
80108a9b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108aab:	83 ca 80             	or     $0xffffff80,%edx
80108aae:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab7:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac0:	83 c0 70             	add    $0x70,%eax
80108ac3:	83 ec 08             	sub    $0x8,%esp
80108ac6:	6a 38                	push   $0x38
80108ac8:	50                   	push   %eax
80108ac9:	e8 38 fb ff ff       	call   80108606 <lgdt>
80108ace:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108ad1:	83 ec 0c             	sub    $0xc,%esp
80108ad4:	6a 18                	push   $0x18
80108ad6:	e8 6c fb ff ff       	call   80108647 <loadgs>
80108adb:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae1:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108ae7:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108aee:	00 00 00 00 
}
80108af2:	90                   	nop
80108af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108af6:	c9                   	leave  
80108af7:	c3                   	ret    

80108af8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108af8:	55                   	push   %ebp
80108af9:	89 e5                	mov    %esp,%ebp
80108afb:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108afe:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b01:	c1 e8 16             	shr    $0x16,%eax
80108b04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b0e:	01 d0                	add    %edx,%eax
80108b10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b16:	8b 00                	mov    (%eax),%eax
80108b18:	83 e0 01             	and    $0x1,%eax
80108b1b:	85 c0                	test   %eax,%eax
80108b1d:	74 18                	je     80108b37 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b22:	8b 00                	mov    (%eax),%eax
80108b24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b29:	50                   	push   %eax
80108b2a:	e8 47 fb ff ff       	call   80108676 <p2v>
80108b2f:	83 c4 04             	add    $0x4,%esp
80108b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b35:	eb 48                	jmp    80108b7f <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108b37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108b3b:	74 0e                	je     80108b4b <walkpgdir+0x53>
80108b3d:	e8 30 a9 ff ff       	call   80103472 <kalloc>
80108b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108b49:	75 07                	jne    80108b52 <walkpgdir+0x5a>
      return 0;
80108b4b:	b8 00 00 00 00       	mov    $0x0,%eax
80108b50:	eb 44                	jmp    80108b96 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108b52:	83 ec 04             	sub    $0x4,%esp
80108b55:	68 00 10 00 00       	push   $0x1000
80108b5a:	6a 00                	push   $0x0
80108b5c:	ff 75 f4             	pushl  -0xc(%ebp)
80108b5f:	e8 86 d2 ff ff       	call   80105dea <memset>
80108b64:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108b67:	83 ec 0c             	sub    $0xc,%esp
80108b6a:	ff 75 f4             	pushl  -0xc(%ebp)
80108b6d:	e8 f7 fa ff ff       	call   80108669 <v2p>
80108b72:	83 c4 10             	add    $0x10,%esp
80108b75:	83 c8 07             	or     $0x7,%eax
80108b78:	89 c2                	mov    %eax,%edx
80108b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b82:	c1 e8 0c             	shr    $0xc,%eax
80108b85:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b94:	01 d0                	add    %edx,%eax
}
80108b96:	c9                   	leave  
80108b97:	c3                   	ret    

80108b98 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108b98:	55                   	push   %ebp
80108b99:	89 e5                	mov    %esp,%ebp
80108b9b:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108ba9:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bac:	8b 45 10             	mov    0x10(%ebp),%eax
80108baf:	01 d0                	add    %edx,%eax
80108bb1:	83 e8 01             	sub    $0x1,%eax
80108bb4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108bbc:	83 ec 04             	sub    $0x4,%esp
80108bbf:	6a 01                	push   $0x1
80108bc1:	ff 75 f4             	pushl  -0xc(%ebp)
80108bc4:	ff 75 08             	pushl  0x8(%ebp)
80108bc7:	e8 2c ff ff ff       	call   80108af8 <walkpgdir>
80108bcc:	83 c4 10             	add    $0x10,%esp
80108bcf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108bd2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bd6:	75 07                	jne    80108bdf <mappages+0x47>
      return -1;
80108bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bdd:	eb 47                	jmp    80108c26 <mappages+0x8e>
    if(*pte & PTE_P)
80108bdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be2:	8b 00                	mov    (%eax),%eax
80108be4:	83 e0 01             	and    $0x1,%eax
80108be7:	85 c0                	test   %eax,%eax
80108be9:	74 0d                	je     80108bf8 <mappages+0x60>
      panic("remap");
80108beb:	83 ec 0c             	sub    $0xc,%esp
80108bee:	68 18 9b 10 80       	push   $0x80109b18
80108bf3:	e8 6e 79 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108bf8:	8b 45 18             	mov    0x18(%ebp),%eax
80108bfb:	0b 45 14             	or     0x14(%ebp),%eax
80108bfe:	83 c8 01             	or     $0x1,%eax
80108c01:	89 c2                	mov    %eax,%edx
80108c03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c06:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c0e:	74 10                	je     80108c20 <mappages+0x88>
      break;
    a += PGSIZE;
80108c10:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108c17:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108c1e:	eb 9c                	jmp    80108bbc <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108c20:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108c21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c26:	c9                   	leave  
80108c27:	c3                   	ret    

80108c28 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108c28:	55                   	push   %ebp
80108c29:	89 e5                	mov    %esp,%ebp
80108c2b:	53                   	push   %ebx
80108c2c:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108c2f:	e8 3e a8 ff ff       	call   80103472 <kalloc>
80108c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c3b:	75 0a                	jne    80108c47 <setupkvm+0x1f>
    return 0;
80108c3d:	b8 00 00 00 00       	mov    $0x0,%eax
80108c42:	e9 8e 00 00 00       	jmp    80108cd5 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108c47:	83 ec 04             	sub    $0x4,%esp
80108c4a:	68 00 10 00 00       	push   $0x1000
80108c4f:	6a 00                	push   $0x0
80108c51:	ff 75 f0             	pushl  -0x10(%ebp)
80108c54:	e8 91 d1 ff ff       	call   80105dea <memset>
80108c59:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108c5c:	83 ec 0c             	sub    $0xc,%esp
80108c5f:	68 00 00 00 0e       	push   $0xe000000
80108c64:	e8 0d fa ff ff       	call   80108676 <p2v>
80108c69:	83 c4 10             	add    $0x10,%esp
80108c6c:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108c71:	76 0d                	jbe    80108c80 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108c73:	83 ec 0c             	sub    $0xc,%esp
80108c76:	68 1e 9b 10 80       	push   $0x80109b1e
80108c7b:	e8 e6 78 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c80:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108c87:	eb 40                	jmp    80108cc9 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c92:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c98:	8b 58 08             	mov    0x8(%eax),%ebx
80108c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9e:	8b 40 04             	mov    0x4(%eax),%eax
80108ca1:	29 c3                	sub    %eax,%ebx
80108ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca6:	8b 00                	mov    (%eax),%eax
80108ca8:	83 ec 0c             	sub    $0xc,%esp
80108cab:	51                   	push   %ecx
80108cac:	52                   	push   %edx
80108cad:	53                   	push   %ebx
80108cae:	50                   	push   %eax
80108caf:	ff 75 f0             	pushl  -0x10(%ebp)
80108cb2:	e8 e1 fe ff ff       	call   80108b98 <mappages>
80108cb7:	83 c4 20             	add    $0x20,%esp
80108cba:	85 c0                	test   %eax,%eax
80108cbc:	79 07                	jns    80108cc5 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108cbe:	b8 00 00 00 00       	mov    $0x0,%eax
80108cc3:	eb 10                	jmp    80108cd5 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108cc5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108cc9:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108cd0:	72 b7                	jb     80108c89 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108cd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cd8:	c9                   	leave  
80108cd9:	c3                   	ret    

80108cda <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108cda:	55                   	push   %ebp
80108cdb:	89 e5                	mov    %esp,%ebp
80108cdd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108ce0:	e8 43 ff ff ff       	call   80108c28 <setupkvm>
80108ce5:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108cea:	e8 03 00 00 00       	call   80108cf2 <switchkvm>
}
80108cef:	90                   	nop
80108cf0:	c9                   	leave  
80108cf1:	c3                   	ret    

80108cf2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108cf2:	55                   	push   %ebp
80108cf3:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108cf5:	a1 58 66 11 80       	mov    0x80116658,%eax
80108cfa:	50                   	push   %eax
80108cfb:	e8 69 f9 ff ff       	call   80108669 <v2p>
80108d00:	83 c4 04             	add    $0x4,%esp
80108d03:	50                   	push   %eax
80108d04:	e8 54 f9 ff ff       	call   8010865d <lcr3>
80108d09:	83 c4 04             	add    $0x4,%esp
}
80108d0c:	90                   	nop
80108d0d:	c9                   	leave  
80108d0e:	c3                   	ret    

80108d0f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108d0f:	55                   	push   %ebp
80108d10:	89 e5                	mov    %esp,%ebp
80108d12:	56                   	push   %esi
80108d13:	53                   	push   %ebx
  pushcli();
80108d14:	e8 cb cf ff ff       	call   80105ce4 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108d19:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d1f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d26:	83 c2 08             	add    $0x8,%edx
80108d29:	89 d6                	mov    %edx,%esi
80108d2b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d32:	83 c2 08             	add    $0x8,%edx
80108d35:	c1 ea 10             	shr    $0x10,%edx
80108d38:	89 d3                	mov    %edx,%ebx
80108d3a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d41:	83 c2 08             	add    $0x8,%edx
80108d44:	c1 ea 18             	shr    $0x18,%edx
80108d47:	89 d1                	mov    %edx,%ecx
80108d49:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108d50:	67 00 
80108d52:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108d59:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108d5f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d66:	83 e2 f0             	and    $0xfffffff0,%edx
80108d69:	83 ca 09             	or     $0x9,%edx
80108d6c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d72:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d79:	83 ca 10             	or     $0x10,%edx
80108d7c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d82:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d89:	83 e2 9f             	and    $0xffffff9f,%edx
80108d8c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d92:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d99:	83 ca 80             	or     $0xffffff80,%edx
80108d9c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108da2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108da9:	83 e2 f0             	and    $0xfffffff0,%edx
80108dac:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108db2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108db9:	83 e2 ef             	and    $0xffffffef,%edx
80108dbc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dc2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108dc9:	83 e2 df             	and    $0xffffffdf,%edx
80108dcc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dd2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108dd9:	83 ca 40             	or     $0x40,%edx
80108ddc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108de2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108de9:	83 e2 7f             	and    $0x7f,%edx
80108dec:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108df2:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108df8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108dfe:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e05:	83 e2 ef             	and    $0xffffffef,%edx
80108e08:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108e0e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e14:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108e1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e20:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e27:	8b 52 08             	mov    0x8(%edx),%edx
80108e2a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108e30:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108e33:	83 ec 0c             	sub    $0xc,%esp
80108e36:	6a 30                	push   $0x30
80108e38:	e8 f3 f7 ff ff       	call   80108630 <ltr>
80108e3d:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108e40:	8b 45 08             	mov    0x8(%ebp),%eax
80108e43:	8b 40 04             	mov    0x4(%eax),%eax
80108e46:	85 c0                	test   %eax,%eax
80108e48:	75 0d                	jne    80108e57 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108e4a:	83 ec 0c             	sub    $0xc,%esp
80108e4d:	68 2f 9b 10 80       	push   $0x80109b2f
80108e52:	e8 0f 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108e57:	8b 45 08             	mov    0x8(%ebp),%eax
80108e5a:	8b 40 04             	mov    0x4(%eax),%eax
80108e5d:	83 ec 0c             	sub    $0xc,%esp
80108e60:	50                   	push   %eax
80108e61:	e8 03 f8 ff ff       	call   80108669 <v2p>
80108e66:	83 c4 10             	add    $0x10,%esp
80108e69:	83 ec 0c             	sub    $0xc,%esp
80108e6c:	50                   	push   %eax
80108e6d:	e8 eb f7 ff ff       	call   8010865d <lcr3>
80108e72:	83 c4 10             	add    $0x10,%esp
  popcli();
80108e75:	e8 af ce ff ff       	call   80105d29 <popcli>
}
80108e7a:	90                   	nop
80108e7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108e7e:	5b                   	pop    %ebx
80108e7f:	5e                   	pop    %esi
80108e80:	5d                   	pop    %ebp
80108e81:	c3                   	ret    

80108e82 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108e82:	55                   	push   %ebp
80108e83:	89 e5                	mov    %esp,%ebp
80108e85:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108e88:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108e8f:	76 0d                	jbe    80108e9e <inituvm+0x1c>
    panic("inituvm: more than a page");
80108e91:	83 ec 0c             	sub    $0xc,%esp
80108e94:	68 43 9b 10 80       	push   $0x80109b43
80108e99:	e8 c8 76 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108e9e:	e8 cf a5 ff ff       	call   80103472 <kalloc>
80108ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108ea6:	83 ec 04             	sub    $0x4,%esp
80108ea9:	68 00 10 00 00       	push   $0x1000
80108eae:	6a 00                	push   $0x0
80108eb0:	ff 75 f4             	pushl  -0xc(%ebp)
80108eb3:	e8 32 cf ff ff       	call   80105dea <memset>
80108eb8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ebb:	83 ec 0c             	sub    $0xc,%esp
80108ebe:	ff 75 f4             	pushl  -0xc(%ebp)
80108ec1:	e8 a3 f7 ff ff       	call   80108669 <v2p>
80108ec6:	83 c4 10             	add    $0x10,%esp
80108ec9:	83 ec 0c             	sub    $0xc,%esp
80108ecc:	6a 06                	push   $0x6
80108ece:	50                   	push   %eax
80108ecf:	68 00 10 00 00       	push   $0x1000
80108ed4:	6a 00                	push   $0x0
80108ed6:	ff 75 08             	pushl  0x8(%ebp)
80108ed9:	e8 ba fc ff ff       	call   80108b98 <mappages>
80108ede:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108ee1:	83 ec 04             	sub    $0x4,%esp
80108ee4:	ff 75 10             	pushl  0x10(%ebp)
80108ee7:	ff 75 0c             	pushl  0xc(%ebp)
80108eea:	ff 75 f4             	pushl  -0xc(%ebp)
80108eed:	e8 b7 cf ff ff       	call   80105ea9 <memmove>
80108ef2:	83 c4 10             	add    $0x10,%esp
}
80108ef5:	90                   	nop
80108ef6:	c9                   	leave  
80108ef7:	c3                   	ret    

80108ef8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108ef8:	55                   	push   %ebp
80108ef9:	89 e5                	mov    %esp,%ebp
80108efb:	53                   	push   %ebx
80108efc:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108eff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f02:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f07:	85 c0                	test   %eax,%eax
80108f09:	74 0d                	je     80108f18 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108f0b:	83 ec 0c             	sub    $0xc,%esp
80108f0e:	68 60 9b 10 80       	push   $0x80109b60
80108f13:	e8 4e 76 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108f18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f1f:	e9 95 00 00 00       	jmp    80108fb9 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108f24:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2a:	01 d0                	add    %edx,%eax
80108f2c:	83 ec 04             	sub    $0x4,%esp
80108f2f:	6a 00                	push   $0x0
80108f31:	50                   	push   %eax
80108f32:	ff 75 08             	pushl  0x8(%ebp)
80108f35:	e8 be fb ff ff       	call   80108af8 <walkpgdir>
80108f3a:	83 c4 10             	add    $0x10,%esp
80108f3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f44:	75 0d                	jne    80108f53 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108f46:	83 ec 0c             	sub    $0xc,%esp
80108f49:	68 83 9b 10 80       	push   $0x80109b83
80108f4e:	e8 13 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f56:	8b 00                	mov    (%eax),%eax
80108f58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108f60:	8b 45 18             	mov    0x18(%ebp),%eax
80108f63:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f66:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108f6b:	77 0b                	ja     80108f78 <loaduvm+0x80>
      n = sz - i;
80108f6d:	8b 45 18             	mov    0x18(%ebp),%eax
80108f70:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f73:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f76:	eb 07                	jmp    80108f7f <loaduvm+0x87>
    else
      n = PGSIZE;
80108f78:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108f7f:	8b 55 14             	mov    0x14(%ebp),%edx
80108f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f85:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108f88:	83 ec 0c             	sub    $0xc,%esp
80108f8b:	ff 75 e8             	pushl  -0x18(%ebp)
80108f8e:	e8 e3 f6 ff ff       	call   80108676 <p2v>
80108f93:	83 c4 10             	add    $0x10,%esp
80108f96:	ff 75 f0             	pushl  -0x10(%ebp)
80108f99:	53                   	push   %ebx
80108f9a:	50                   	push   %eax
80108f9b:	ff 75 10             	pushl  0x10(%ebp)
80108f9e:	e8 dd 95 ff ff       	call   80102580 <readi>
80108fa3:	83 c4 10             	add    $0x10,%esp
80108fa6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108fa9:	74 07                	je     80108fb2 <loaduvm+0xba>
      return -1;
80108fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fb0:	eb 18                	jmp    80108fca <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108fb2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fbc:	3b 45 18             	cmp    0x18(%ebp),%eax
80108fbf:	0f 82 5f ff ff ff    	jb     80108f24 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108fc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108fca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108fcd:	c9                   	leave  
80108fce:	c3                   	ret    

80108fcf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fcf:	55                   	push   %ebp
80108fd0:	89 e5                	mov    %esp,%ebp
80108fd2:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80108fd8:	85 c0                	test   %eax,%eax
80108fda:	79 0a                	jns    80108fe6 <allocuvm+0x17>
    return 0;
80108fdc:	b8 00 00 00 00       	mov    $0x0,%eax
80108fe1:	e9 b0 00 00 00       	jmp    80109096 <allocuvm+0xc7>
  if(newsz < oldsz)
80108fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80108fe9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fec:	73 08                	jae    80108ff6 <allocuvm+0x27>
    return oldsz;
80108fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ff1:	e9 a0 00 00 00       	jmp    80109096 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ff9:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ffe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109003:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109006:	eb 7f                	jmp    80109087 <allocuvm+0xb8>
    mem = kalloc();
80109008:	e8 65 a4 ff ff       	call   80103472 <kalloc>
8010900d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109010:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109014:	75 2b                	jne    80109041 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109016:	83 ec 0c             	sub    $0xc,%esp
80109019:	68 a1 9b 10 80       	push   $0x80109ba1
8010901e:	e8 a3 73 ff ff       	call   801003c6 <cprintf>
80109023:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109026:	83 ec 04             	sub    $0x4,%esp
80109029:	ff 75 0c             	pushl  0xc(%ebp)
8010902c:	ff 75 10             	pushl  0x10(%ebp)
8010902f:	ff 75 08             	pushl  0x8(%ebp)
80109032:	e8 61 00 00 00       	call   80109098 <deallocuvm>
80109037:	83 c4 10             	add    $0x10,%esp
      return 0;
8010903a:	b8 00 00 00 00       	mov    $0x0,%eax
8010903f:	eb 55                	jmp    80109096 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109041:	83 ec 04             	sub    $0x4,%esp
80109044:	68 00 10 00 00       	push   $0x1000
80109049:	6a 00                	push   $0x0
8010904b:	ff 75 f0             	pushl  -0x10(%ebp)
8010904e:	e8 97 cd ff ff       	call   80105dea <memset>
80109053:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109056:	83 ec 0c             	sub    $0xc,%esp
80109059:	ff 75 f0             	pushl  -0x10(%ebp)
8010905c:	e8 08 f6 ff ff       	call   80108669 <v2p>
80109061:	83 c4 10             	add    $0x10,%esp
80109064:	89 c2                	mov    %eax,%edx
80109066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109069:	83 ec 0c             	sub    $0xc,%esp
8010906c:	6a 06                	push   $0x6
8010906e:	52                   	push   %edx
8010906f:	68 00 10 00 00       	push   $0x1000
80109074:	50                   	push   %eax
80109075:	ff 75 08             	pushl  0x8(%ebp)
80109078:	e8 1b fb ff ff       	call   80108b98 <mappages>
8010907d:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109080:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010908a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010908d:	0f 82 75 ff ff ff    	jb     80109008 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109093:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109096:	c9                   	leave  
80109097:	c3                   	ret    

80109098 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109098:	55                   	push   %ebp
80109099:	89 e5                	mov    %esp,%ebp
8010909b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010909e:	8b 45 10             	mov    0x10(%ebp),%eax
801090a1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090a4:	72 08                	jb     801090ae <deallocuvm+0x16>
    return oldsz;
801090a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801090a9:	e9 a5 00 00 00       	jmp    80109153 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801090ae:	8b 45 10             	mov    0x10(%ebp),%eax
801090b1:	05 ff 0f 00 00       	add    $0xfff,%eax
801090b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801090be:	e9 81 00 00 00       	jmp    80109144 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801090c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c6:	83 ec 04             	sub    $0x4,%esp
801090c9:	6a 00                	push   $0x0
801090cb:	50                   	push   %eax
801090cc:	ff 75 08             	pushl  0x8(%ebp)
801090cf:	e8 24 fa ff ff       	call   80108af8 <walkpgdir>
801090d4:	83 c4 10             	add    $0x10,%esp
801090d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801090da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801090de:	75 09                	jne    801090e9 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801090e0:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801090e7:	eb 54                	jmp    8010913d <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801090e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ec:	8b 00                	mov    (%eax),%eax
801090ee:	83 e0 01             	and    $0x1,%eax
801090f1:	85 c0                	test   %eax,%eax
801090f3:	74 48                	je     8010913d <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801090f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f8:	8b 00                	mov    (%eax),%eax
801090fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109102:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109106:	75 0d                	jne    80109115 <deallocuvm+0x7d>
        panic("kfree");
80109108:	83 ec 0c             	sub    $0xc,%esp
8010910b:	68 b9 9b 10 80       	push   $0x80109bb9
80109110:	e8 51 74 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109115:	83 ec 0c             	sub    $0xc,%esp
80109118:	ff 75 ec             	pushl  -0x14(%ebp)
8010911b:	e8 56 f5 ff ff       	call   80108676 <p2v>
80109120:	83 c4 10             	add    $0x10,%esp
80109123:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109126:	83 ec 0c             	sub    $0xc,%esp
80109129:	ff 75 e8             	pushl  -0x18(%ebp)
8010912c:	e8 a4 a2 ff ff       	call   801033d5 <kfree>
80109131:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109137:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010913d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109147:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010914a:	0f 82 73 ff ff ff    	jb     801090c3 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109150:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109153:	c9                   	leave  
80109154:	c3                   	ret    

80109155 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109155:	55                   	push   %ebp
80109156:	89 e5                	mov    %esp,%ebp
80109158:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010915b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010915f:	75 0d                	jne    8010916e <freevm+0x19>
    panic("freevm: no pgdir");
80109161:	83 ec 0c             	sub    $0xc,%esp
80109164:	68 bf 9b 10 80       	push   $0x80109bbf
80109169:	e8 f8 73 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010916e:	83 ec 04             	sub    $0x4,%esp
80109171:	6a 00                	push   $0x0
80109173:	68 00 00 00 80       	push   $0x80000000
80109178:	ff 75 08             	pushl  0x8(%ebp)
8010917b:	e8 18 ff ff ff       	call   80109098 <deallocuvm>
80109180:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010918a:	eb 4f                	jmp    801091db <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010918c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109196:	8b 45 08             	mov    0x8(%ebp),%eax
80109199:	01 d0                	add    %edx,%eax
8010919b:	8b 00                	mov    (%eax),%eax
8010919d:	83 e0 01             	and    $0x1,%eax
801091a0:	85 c0                	test   %eax,%eax
801091a2:	74 33                	je     801091d7 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801091a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091ae:	8b 45 08             	mov    0x8(%ebp),%eax
801091b1:	01 d0                	add    %edx,%eax
801091b3:	8b 00                	mov    (%eax),%eax
801091b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091ba:	83 ec 0c             	sub    $0xc,%esp
801091bd:	50                   	push   %eax
801091be:	e8 b3 f4 ff ff       	call   80108676 <p2v>
801091c3:	83 c4 10             	add    $0x10,%esp
801091c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801091c9:	83 ec 0c             	sub    $0xc,%esp
801091cc:	ff 75 f0             	pushl  -0x10(%ebp)
801091cf:	e8 01 a2 ff ff       	call   801033d5 <kfree>
801091d4:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801091d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091db:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801091e2:	76 a8                	jbe    8010918c <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801091e4:	83 ec 0c             	sub    $0xc,%esp
801091e7:	ff 75 08             	pushl  0x8(%ebp)
801091ea:	e8 e6 a1 ff ff       	call   801033d5 <kfree>
801091ef:	83 c4 10             	add    $0x10,%esp
}
801091f2:	90                   	nop
801091f3:	c9                   	leave  
801091f4:	c3                   	ret    

801091f5 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801091f5:	55                   	push   %ebp
801091f6:	89 e5                	mov    %esp,%ebp
801091f8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801091fb:	83 ec 04             	sub    $0x4,%esp
801091fe:	6a 00                	push   $0x0
80109200:	ff 75 0c             	pushl  0xc(%ebp)
80109203:	ff 75 08             	pushl  0x8(%ebp)
80109206:	e8 ed f8 ff ff       	call   80108af8 <walkpgdir>
8010920b:	83 c4 10             	add    $0x10,%esp
8010920e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109211:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109215:	75 0d                	jne    80109224 <clearpteu+0x2f>
    panic("clearpteu");
80109217:	83 ec 0c             	sub    $0xc,%esp
8010921a:	68 d0 9b 10 80       	push   $0x80109bd0
8010921f:	e8 42 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109227:	8b 00                	mov    (%eax),%eax
80109229:	83 e0 fb             	and    $0xfffffffb,%eax
8010922c:	89 c2                	mov    %eax,%edx
8010922e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109231:	89 10                	mov    %edx,(%eax)
}
80109233:	90                   	nop
80109234:	c9                   	leave  
80109235:	c3                   	ret    

80109236 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109236:	55                   	push   %ebp
80109237:	89 e5                	mov    %esp,%ebp
80109239:	53                   	push   %ebx
8010923a:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010923d:	e8 e6 f9 ff ff       	call   80108c28 <setupkvm>
80109242:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109245:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109249:	75 0a                	jne    80109255 <copyuvm+0x1f>
    return 0;
8010924b:	b8 00 00 00 00       	mov    $0x0,%eax
80109250:	e9 f8 00 00 00       	jmp    8010934d <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109255:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010925c:	e9 c4 00 00 00       	jmp    80109325 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109264:	83 ec 04             	sub    $0x4,%esp
80109267:	6a 00                	push   $0x0
80109269:	50                   	push   %eax
8010926a:	ff 75 08             	pushl  0x8(%ebp)
8010926d:	e8 86 f8 ff ff       	call   80108af8 <walkpgdir>
80109272:	83 c4 10             	add    $0x10,%esp
80109275:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109278:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010927c:	75 0d                	jne    8010928b <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010927e:	83 ec 0c             	sub    $0xc,%esp
80109281:	68 da 9b 10 80       	push   $0x80109bda
80109286:	e8 db 72 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010928b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010928e:	8b 00                	mov    (%eax),%eax
80109290:	83 e0 01             	and    $0x1,%eax
80109293:	85 c0                	test   %eax,%eax
80109295:	75 0d                	jne    801092a4 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109297:	83 ec 0c             	sub    $0xc,%esp
8010929a:	68 f4 9b 10 80       	push   $0x80109bf4
8010929f:	e8 c2 72 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801092a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092a7:	8b 00                	mov    (%eax),%eax
801092a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801092b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092b4:	8b 00                	mov    (%eax),%eax
801092b6:	25 ff 0f 00 00       	and    $0xfff,%eax
801092bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801092be:	e8 af a1 ff ff       	call   80103472 <kalloc>
801092c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801092c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801092ca:	74 6a                	je     80109336 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801092cc:	83 ec 0c             	sub    $0xc,%esp
801092cf:	ff 75 e8             	pushl  -0x18(%ebp)
801092d2:	e8 9f f3 ff ff       	call   80108676 <p2v>
801092d7:	83 c4 10             	add    $0x10,%esp
801092da:	83 ec 04             	sub    $0x4,%esp
801092dd:	68 00 10 00 00       	push   $0x1000
801092e2:	50                   	push   %eax
801092e3:	ff 75 e0             	pushl  -0x20(%ebp)
801092e6:	e8 be cb ff ff       	call   80105ea9 <memmove>
801092eb:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801092ee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801092f1:	83 ec 0c             	sub    $0xc,%esp
801092f4:	ff 75 e0             	pushl  -0x20(%ebp)
801092f7:	e8 6d f3 ff ff       	call   80108669 <v2p>
801092fc:	83 c4 10             	add    $0x10,%esp
801092ff:	89 c2                	mov    %eax,%edx
80109301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109304:	83 ec 0c             	sub    $0xc,%esp
80109307:	53                   	push   %ebx
80109308:	52                   	push   %edx
80109309:	68 00 10 00 00       	push   $0x1000
8010930e:	50                   	push   %eax
8010930f:	ff 75 f0             	pushl  -0x10(%ebp)
80109312:	e8 81 f8 ff ff       	call   80108b98 <mappages>
80109317:	83 c4 20             	add    $0x20,%esp
8010931a:	85 c0                	test   %eax,%eax
8010931c:	78 1b                	js     80109339 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010931e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109328:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010932b:	0f 82 30 ff ff ff    	jb     80109261 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109331:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109334:	eb 17                	jmp    8010934d <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109336:	90                   	nop
80109337:	eb 01                	jmp    8010933a <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109339:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010933a:	83 ec 0c             	sub    $0xc,%esp
8010933d:	ff 75 f0             	pushl  -0x10(%ebp)
80109340:	e8 10 fe ff ff       	call   80109155 <freevm>
80109345:	83 c4 10             	add    $0x10,%esp
  return 0;
80109348:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010934d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109350:	c9                   	leave  
80109351:	c3                   	ret    

80109352 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109352:	55                   	push   %ebp
80109353:	89 e5                	mov    %esp,%ebp
80109355:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109358:	83 ec 04             	sub    $0x4,%esp
8010935b:	6a 00                	push   $0x0
8010935d:	ff 75 0c             	pushl  0xc(%ebp)
80109360:	ff 75 08             	pushl  0x8(%ebp)
80109363:	e8 90 f7 ff ff       	call   80108af8 <walkpgdir>
80109368:	83 c4 10             	add    $0x10,%esp
8010936b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010936e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109371:	8b 00                	mov    (%eax),%eax
80109373:	83 e0 01             	and    $0x1,%eax
80109376:	85 c0                	test   %eax,%eax
80109378:	75 07                	jne    80109381 <uva2ka+0x2f>
    return 0;
8010937a:	b8 00 00 00 00       	mov    $0x0,%eax
8010937f:	eb 29                	jmp    801093aa <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109384:	8b 00                	mov    (%eax),%eax
80109386:	83 e0 04             	and    $0x4,%eax
80109389:	85 c0                	test   %eax,%eax
8010938b:	75 07                	jne    80109394 <uva2ka+0x42>
    return 0;
8010938d:	b8 00 00 00 00       	mov    $0x0,%eax
80109392:	eb 16                	jmp    801093aa <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109397:	8b 00                	mov    (%eax),%eax
80109399:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010939e:	83 ec 0c             	sub    $0xc,%esp
801093a1:	50                   	push   %eax
801093a2:	e8 cf f2 ff ff       	call   80108676 <p2v>
801093a7:	83 c4 10             	add    $0x10,%esp
}
801093aa:	c9                   	leave  
801093ab:	c3                   	ret    

801093ac <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801093ac:	55                   	push   %ebp
801093ad:	89 e5                	mov    %esp,%ebp
801093af:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801093b2:	8b 45 10             	mov    0x10(%ebp),%eax
801093b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801093b8:	eb 7f                	jmp    80109439 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801093ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801093bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801093c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093c8:	83 ec 08             	sub    $0x8,%esp
801093cb:	50                   	push   %eax
801093cc:	ff 75 08             	pushl  0x8(%ebp)
801093cf:	e8 7e ff ff ff       	call   80109352 <uva2ka>
801093d4:	83 c4 10             	add    $0x10,%esp
801093d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801093da:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801093de:	75 07                	jne    801093e7 <copyout+0x3b>
      return -1;
801093e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093e5:	eb 61                	jmp    80109448 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801093e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093ea:	2b 45 0c             	sub    0xc(%ebp),%eax
801093ed:	05 00 10 00 00       	add    $0x1000,%eax
801093f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801093f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f8:	3b 45 14             	cmp    0x14(%ebp),%eax
801093fb:	76 06                	jbe    80109403 <copyout+0x57>
      n = len;
801093fd:	8b 45 14             	mov    0x14(%ebp),%eax
80109400:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109403:	8b 45 0c             	mov    0xc(%ebp),%eax
80109406:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109409:	89 c2                	mov    %eax,%edx
8010940b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010940e:	01 d0                	add    %edx,%eax
80109410:	83 ec 04             	sub    $0x4,%esp
80109413:	ff 75 f0             	pushl  -0x10(%ebp)
80109416:	ff 75 f4             	pushl  -0xc(%ebp)
80109419:	50                   	push   %eax
8010941a:	e8 8a ca ff ff       	call   80105ea9 <memmove>
8010941f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109425:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010942e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109431:	05 00 10 00 00       	add    $0x1000,%eax
80109436:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109439:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010943d:	0f 85 77 ff ff ff    	jne    801093ba <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109443:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109448:	c9                   	leave  
80109449:	c3                   	ret    
