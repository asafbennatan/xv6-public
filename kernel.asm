
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
8010002d:	b8 dd 43 10 80       	mov    $0x801043dd,%eax
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
8010003d:	68 e4 93 10 80       	push   $0x801093e4
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 12 5b 00 00       	call   80105b5e <initlock>
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
801000c1:	e8 ba 5a 00 00       	call   80105b80 <acquire>
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
8010010c:	e8 d6 5a 00 00       	call   80105be7 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 5b 57 00 00       	call   80105887 <sleep>
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
80100188:	e8 5a 5a 00 00       	call   80105be7 <release>
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
801001aa:	68 eb 93 10 80       	push   $0x801093eb
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
80100204:	68 fc 93 10 80       	push   $0x801093fc
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
80100243:	68 03 94 10 80       	push   $0x80109403
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 26 59 00 00       	call   80105b80 <acquire>
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
801002b9:	e8 b4 56 00 00       	call   80105972 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 19 59 00 00       	call   80105be7 <release>
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
801003e2:	e8 99 57 00 00       	call   80105b80 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 0a 94 10 80       	push   $0x8010940a
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
801004cd:	c7 45 ec 13 94 10 80 	movl   $0x80109413,-0x14(%ebp)
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
8010055b:	e8 87 56 00 00       	call   80105be7 <release>
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
8010058b:	68 1a 94 10 80       	push   $0x8010941a
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
801005aa:	68 29 94 10 80       	push   $0x80109429
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 72 56 00 00       	call   80105c39 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 2b 94 10 80       	push   $0x8010942b
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
801006ca:	68 2f 94 10 80       	push   $0x8010942f
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
801006f7:	e8 a6 57 00 00       	call   80105ea2 <memmove>
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
80100721:	e8 bd 56 00 00       	call   80105de3 <memset>
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
801007b6:	e8 af 72 00 00       	call   80107a6a <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 a2 72 00 00       	call   80107a6a <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 95 72 00 00       	call   80107a6a <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 85 72 00 00       	call   80107a6a <uartputc>
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
8010080e:	e8 6d 53 00 00       	call   80105b80 <acquire>
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
80100956:	e8 17 50 00 00       	call   80105972 <wakeup>
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
80100979:	e8 69 52 00 00       	call   80105be7 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 a1 50 00 00       	call   80105a2d <procdump>
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
801009b1:	e8 ca 51 00 00       	call   80105b80 <acquire>
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
801009d3:	e8 0f 52 00 00       	call   80105be7 <release>
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
801009fb:	68 e0 1a 11 80       	push   $0x80111ae0
80100a00:	e8 82 4e 00 00       	call   80105887 <sleep>
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
80100a7e:	e8 64 51 00 00       	call   80105be7 <release>
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
80100abc:	e8 bf 50 00 00       	call   80105b80 <acquire>
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
80100afe:	e8 e4 50 00 00       	call   80105be7 <release>
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
80100b22:	68 42 94 10 80       	push   $0x80109442
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 2d 50 00 00       	call   80105b5e <initlock>
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
80100b57:	e8 00 3f 00 00       	call   80104a5c <picenable>
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
80100b8d:	e8 10 33 00 00       	call   80103ea2 <begin_op>
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
80100bbf:	e8 e5 33 00 00       	call   80103fa9 <end_op>
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
80100c16:	e8 a4 7f 00 00       	call   80108bbf <setupkvm>
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
80100c9c:	e8 c5 82 00 00       	call   80108f66 <allocuvm>
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
80100ccf:	e8 bb 81 00 00       	call   80108e8f <loaduvm>
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
80100d23:	e8 81 32 00 00       	call   80103fa9 <end_op>
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
80100d54:	e8 0d 82 00 00       	call   80108f66 <allocuvm>
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
80100d78:	e8 0f 84 00 00       	call   8010918c <clearpteu>
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
80100db1:	e8 7a 52 00 00       	call   80106030 <strlen>
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
80100dde:	e8 4d 52 00 00       	call   80106030 <strlen>
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
80100e04:	e8 3a 85 00 00       	call   80109343 <copyout>
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
80100ea0:	e8 9e 84 00 00       	call   80109343 <copyout>
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
80100ef1:	e8 f0 50 00 00       	call   80105fe6 <safestrcpy>
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
80100f47:	e8 5a 7d 00 00       	call   80108ca6 <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 92 81 00 00       	call   801090ec <freevm>
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
80100f8f:	e8 58 81 00 00       	call   801090ec <freevm>
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
80100fbe:	e8 e6 2f 00 00       	call   80103fa9 <end_op>
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
80100fd6:	68 4a 94 10 80       	push   $0x8010944a
80100fdb:	68 00 1b 11 80       	push   $0x80111b00
80100fe0:	e8 79 4b 00 00       	call   80105b5e <initlock>
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
80100ff9:	e8 82 4b 00 00       	call   80105b80 <acquire>
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
80101026:	e8 bc 4b 00 00       	call   80105be7 <release>
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
80101049:	e8 99 4b 00 00       	call   80105be7 <release>
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
80101066:	e8 15 4b 00 00       	call   80105b80 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 51 94 10 80       	push   $0x80109451
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
8010109c:	e8 46 4b 00 00       	call   80105be7 <release>
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
801010b7:	e8 c4 4a 00 00       	call   80105b80 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 59 94 10 80       	push   $0x80109459
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
801010f7:	e8 eb 4a 00 00       	call   80105be7 <release>
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
80101147:	e8 9b 4a 00 00       	call   80105be7 <release>
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
80101166:	e8 5a 3b 00 00       	call   80104cc5 <pipeclose>
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
80101188:	e8 15 2d 00 00       	call   80103ea2 <begin_op>
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
801011af:	e8 f5 2d 00 00       	call   80103fa9 <end_op>
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
80101245:	e8 23 3c 00 00       	call   80104e6d <piperead>
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
801012bc:	68 63 94 10 80       	push   $0x80109463
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
801012fe:	e8 6c 3a 00 00       	call   80104d6f <pipewrite>
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
80101353:	e8 4a 2b 00 00       	call   80103ea2 <begin_op>
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
801013cc:	e8 d8 2b 00 00       	call   80103fa9 <end_op>
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
801013e5:	68 6c 94 10 80       	push   $0x8010946c
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
8010141b:	68 7c 94 10 80       	push   $0x8010947c
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
8010146c:	e8 31 4a 00 00       	call   80105ea2 <memmove>
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
801014d3:	e8 ca 49 00 00       	call   80105ea2 <memmove>
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
80101519:	e8 c5 48 00 00       	call   80105de3 <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp, partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 20 2d 00 00       	call   8010424f <log_write>
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
8010163f:	e8 0b 2c 00 00       	call   8010424f <log_write>
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
801016ca:	68 88 94 10 80       	push   $0x80109488
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
80101787:	68 9e 94 10 80       	push   $0x8010949e
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
801017c3:	e8 87 2a 00 00       	call   8010424f <log_write>
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
801017e5:	68 b1 94 10 80       	push   $0x801094b1
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
8010182a:	c7 45 f0 bc 94 10 80 	movl   $0x801094bc,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 c0 94 10 80 	movl   $0x801094c0,-0x10(%ebp)
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
80101889:	c7 45 ec c3 94 10 80 	movl   $0x801094c3,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 c7 94 10 80       	push   $0x801094c7
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
801018e2:	68 dc 94 10 80       	push   $0x801094dc
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
80101909:	68 12 95 10 80       	push   $0x80109512
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

    initlock(&icache.lock, "icache");
80101a3b:	83 ec 08             	sub    $0x8,%esp
80101a3e:	68 1d 95 10 80       	push   $0x8010951d
80101a43:	68 60 24 11 80       	push   $0x80112460
80101a48:	e8 11 41 00 00       	call   80105b5e <initlock>
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
80101a6a:	68 00 18 11 80       	push   $0x80111800
80101a6f:	e8 68 fd ff ff       	call   801017dc <printMBR>
80101a74:	83 c4 10             	add    $0x10,%esp
    cprintf("booting from %d \n", bootfrom);
80101a77:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a7c:	83 ec 08             	sub    $0x8,%esp
80101a7f:	50                   	push   %eax
80101a80:	68 24 95 10 80       	push   $0x80109524
80101a85:	e8 3c e9 ff ff       	call   801003c6 <cprintf>
80101a8a:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a8d:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a92:	83 f8 ff             	cmp    $0xffffffff,%eax
80101a95:	75 0d                	jne    80101aa4 <iinit+0x72>
        panic("no bootable partition");
80101a97:	83 ec 0c             	sub    $0xc,%esp
80101a9a:	68 36 95 10 80       	push   $0x80109536
80101a9f:	e8 c2 ea ff ff       	call   80100566 <panic>
    }
    rootNode->part = &(partitions[bootfrom]);
80101aa4:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
80101aaa:	89 d0                	mov    %edx,%eax
80101aac:	01 c0                	add    %eax,%eax
80101aae:	01 d0                	add    %edx,%eax
80101ab0:	c1 e0 03             	shl    $0x3,%eax
80101ab3:	8d 90 00 1a 11 80    	lea    -0x7feee600(%eax),%edx
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
80101b43:	68 4c 95 10 80       	push   $0x8010954c
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
80101c0b:	e8 d3 41 00 00       	call   80105de3 <memset>
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
80101c27:	e8 23 26 00 00       	call   8010424f <log_write>
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
80101c78:	68 a9 95 10 80       	push   $0x801095a9
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
80101d61:	e8 3c 41 00 00       	call   80105ea2 <memmove>
80101d66:	83 c4 10             	add    $0x10,%esp
    log_write(bp, ip->part->number);
80101d69:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6c:	8b 40 50             	mov    0x50(%eax),%eax
80101d6f:	8b 40 14             	mov    0x14(%eax),%eax
80101d72:	83 ec 08             	sub    $0x8,%esp
80101d75:	50                   	push   %eax
80101d76:	ff 75 f4             	pushl  -0xc(%ebp)
80101d79:	e8 d1 24 00 00       	call   8010424f <log_write>
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
80101da0:	e8 db 3d 00 00       	call   80105b80 <acquire>
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
80101e06:	e8 dc 3d 00 00       	call   80105be7 <release>
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
80101e46:	68 bb 95 10 80       	push   $0x801095bb
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
80101e73:	8d 90 00 1a 11 80    	lea    -0x7feee600(%eax),%edx
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
80101e9b:	e8 47 3d 00 00       	call   80105be7 <release>
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
80101eb6:	e8 c5 3c 00 00       	call   80105b80 <acquire>
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
80101ed5:	e8 0d 3d 00 00       	call   80105be7 <release>
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
80101efb:	68 cb 95 10 80       	push   $0x801095cb
80101f00:	e8 61 e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101f05:	83 ec 0c             	sub    $0xc,%esp
80101f08:	68 60 24 11 80       	push   $0x80112460
80101f0d:	e8 6e 3c 00 00       	call   80105b80 <acquire>
80101f12:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f15:	eb 13                	jmp    80101f2a <ilock+0x48>
        sleep(ip, &icache.lock);
80101f17:	83 ec 08             	sub    $0x8,%esp
80101f1a:	68 60 24 11 80       	push   $0x80112460
80101f1f:	ff 75 08             	pushl  0x8(%ebp)
80101f22:	e8 60 39 00 00       	call   80105887 <sleep>
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
80101f50:	e8 92 3c 00 00       	call   80105be7 <release>
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
80102040:	e8 5d 3e 00 00       	call   80105ea2 <memmove>
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
80102076:	68 d1 95 10 80       	push   $0x801095d1
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
801020a9:	68 e0 95 10 80       	push   $0x801095e0
801020ae:	e8 b3 e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020b3:	83 ec 0c             	sub    $0xc,%esp
801020b6:	68 60 24 11 80       	push   $0x80112460
801020bb:	e8 c0 3a 00 00       	call   80105b80 <acquire>
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
801020da:	e8 93 38 00 00       	call   80105972 <wakeup>
801020df:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020e2:	83 ec 0c             	sub    $0xc,%esp
801020e5:	68 60 24 11 80       	push   $0x80112460
801020ea:	e8 f8 3a 00 00       	call   80105be7 <release>
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
80102103:	e8 78 3a 00 00       	call   80105b80 <acquire>
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
8010214b:	68 e8 95 10 80       	push   $0x801095e8
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
8010216e:	e8 74 3a 00 00       	call   80105be7 <release>
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
801021a3:	e8 d8 39 00 00       	call   80105b80 <acquire>
801021a8:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801021ab:	8b 45 08             	mov    0x8(%ebp),%eax
801021ae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021b5:	83 ec 0c             	sub    $0xc,%esp
801021b8:	ff 75 08             	pushl  0x8(%ebp)
801021bb:	e8 b2 37 00 00       	call   80105972 <wakeup>
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
801021da:	e8 08 3a 00 00       	call   80105be7 <release>
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
80102370:	e8 da 1e 00 00       	call   8010424f <log_write>
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
8010238e:	68 f2 95 10 80       	push   $0x801095f2
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
801025e4:	8b 04 c5 e0 23 11 80 	mov    -0x7feedc20(,%eax,8),%eax
801025eb:	85 c0                	test   %eax,%eax
801025ed:	75 0a                	jne    801025f9 <readi+0x89>
            return -1;
801025ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025f4:	e9 15 01 00 00       	jmp    8010270e <readi+0x19e>
        return devsw[ip->major].read(ip, dst, n);
801025f9:	8b 45 08             	mov    0x8(%ebp),%eax
801025fc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102600:	98                   	cwtl   
80102601:	8b 04 c5 e0 23 11 80 	mov    -0x7feedc20(,%eax,8),%eax
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
801026d7:	e8 c6 37 00 00       	call   80105ea2 <memmove>
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
80102784:	8b 04 c5 e4 23 11 80 	mov    -0x7feedc1c(,%eax,8),%eax
8010278b:	85 c0                	test   %eax,%eax
8010278d:	75 0a                	jne    80102799 <writei+0x89>
            return -1;
8010278f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102794:	e9 50 01 00 00       	jmp    801028e9 <writei+0x1d9>
        return devsw[ip->major].write(ip, src, n);
80102799:	8b 45 08             	mov    0x8(%ebp),%eax
8010279c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027a0:	98                   	cwtl   
801027a1:	8b 04 c5 e4 23 11 80 	mov    -0x7feedc1c(,%eax,8),%eax
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
80102872:	e8 2b 36 00 00       	call   80105ea2 <memmove>
80102877:	83 c4 10             	add    $0x10,%esp
        log_write(bp, ip->part->number);
8010287a:	8b 45 08             	mov    0x8(%ebp),%eax
8010287d:	8b 40 50             	mov    0x50(%eax),%eax
80102880:	8b 40 14             	mov    0x14(%eax),%eax
80102883:	83 ec 08             	sub    $0x8,%esp
80102886:	50                   	push   %eax
80102887:	ff 75 ec             	pushl  -0x14(%ebp)
8010288a:	e8 c0 19 00 00       	call   8010424f <log_write>
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
801028fc:	e8 37 36 00 00       	call   80105f38 <strncmp>
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
8010291c:	68 05 96 10 80       	push   $0x80109605
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
8010294e:	68 17 96 10 80       	push   $0x80109617
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
80102a2d:	68 17 96 10 80       	push   $0x80109617
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
80102a68:	e8 21 35 00 00       	call   80105f8e <strncpy>
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
80102a94:	68 24 96 10 80       	push   $0x80109624
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
80102b0a:	e8 93 33 00 00       	call   80105ea2 <memmove>
80102b0f:	83 c4 10             	add    $0x10,%esp
80102b12:	eb 26                	jmp    80102b3a <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b17:	83 ec 04             	sub    $0x4,%esp
80102b1a:	50                   	push   %eax
80102b1b:	ff 75 f4             	pushl  -0xc(%ebp)
80102b1e:	ff 75 0c             	pushl  0xc(%ebp)
80102b21:	e8 7c 33 00 00       	call   80105ea2 <memmove>
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
80102b64:	6a 01                	push   $0x1
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
80102ca0:	6a 01                	push   $0x1
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
80102e2a:	68 36 96 10 80       	push   $0x80109636
80102e2f:	68 00 c6 10 80       	push   $0x8010c600
80102e34:	e8 25 2d 00 00       	call   80105b5e <initlock>
80102e39:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e3c:	83 ec 0c             	sub    $0xc,%esp
80102e3f:	6a 0e                	push   $0xe
80102e41:	e8 16 1c 00 00       	call   80104a5c <picenable>
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
80102ede:	68 3a 96 10 80       	push   $0x8010963a
80102ee3:	e8 7e d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80102eeb:	8b 40 08             	mov    0x8(%eax),%eax
80102eee:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102ef3:	76 1d                	jbe    80102f12 <idestart+0x43>
      cprintf("block %d \n");
80102ef5:	83 ec 0c             	sub    $0xc,%esp
80102ef8:	68 43 96 10 80       	push   $0x80109643
80102efd:	e8 c4 d4 ff ff       	call   801003c6 <cprintf>
80102f02:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102f05:	83 ec 0c             	sub    $0xc,%esp
80102f08:	68 4e 96 10 80       	push   $0x8010964e
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
80102f31:	68 3a 96 10 80       	push   $0x8010963a
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
8010304b:	e8 30 2b 00 00       	call   80105b80 <acquire>
80103050:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80103053:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103058:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010305b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010305f:	75 15                	jne    80103076 <ideintr+0x39>
    release(&idelock);
80103061:	83 ec 0c             	sub    $0xc,%esp
80103064:	68 00 c6 10 80       	push   $0x8010c600
80103069:	e8 79 2b 00 00       	call   80105be7 <release>
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
801030de:	e8 8f 28 00 00       	call   80105972 <wakeup>
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
80103108:	e8 da 2a 00 00       	call   80105be7 <release>
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
80103127:	68 60 96 10 80       	push   $0x80109660
8010312c:	e8 35 d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103131:	8b 45 08             	mov    0x8(%ebp),%eax
80103134:	8b 00                	mov    (%eax),%eax
80103136:	83 e0 06             	and    $0x6,%eax
80103139:	83 f8 02             	cmp    $0x2,%eax
8010313c:	75 0d                	jne    8010314b <iderw+0x39>
    panic("iderw: nothing to do");
8010313e:	83 ec 0c             	sub    $0xc,%esp
80103141:	68 74 96 10 80       	push   $0x80109674
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
80103161:	68 89 96 10 80       	push   $0x80109689
80103166:	e8 fb d3 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 00 c6 10 80       	push   $0x8010c600
80103173:	e8 08 2a 00 00       	call   80105b80 <acquire>
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
801031cf:	e8 b3 26 00 00       	call   80105887 <sleep>
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
801031ec:	e8 f6 29 00 00       	call   80105be7 <release>
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
8010327d:	68 a8 96 10 80       	push   $0x801096a8
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
8010333d:	68 da 96 10 80       	push   $0x801096da
80103342:	68 00 35 11 80       	push   $0x80113500
80103347:	e8 12 28 00 00       	call   80105b5e <initlock>
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
801033fe:	68 df 96 10 80       	push   $0x801096df
80103403:	e8 5e d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103408:	83 ec 04             	sub    $0x4,%esp
8010340b:	68 00 10 00 00       	push   $0x1000
80103410:	6a 01                	push   $0x1
80103412:	ff 75 08             	pushl  0x8(%ebp)
80103415:	e8 c9 29 00 00       	call   80105de3 <memset>
8010341a:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010341d:	a1 34 35 11 80       	mov    0x80113534,%eax
80103422:	85 c0                	test   %eax,%eax
80103424:	74 10                	je     80103436 <kfree+0x68>
    acquire(&kmem.lock);
80103426:	83 ec 0c             	sub    $0xc,%esp
80103429:	68 00 35 11 80       	push   $0x80113500
8010342e:	e8 4d 27 00 00       	call   80105b80 <acquire>
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
80103460:	e8 82 27 00 00       	call   80105be7 <release>
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
80103482:	e8 f9 26 00 00       	call   80105b80 <acquire>
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
801034b3:	e8 2f 27 00 00       	call   80105be7 <release>
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
801037fe:	68 e8 96 10 80       	push   $0x801096e8
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
80103a29:	e8 1c 24 00 00       	call   80105e4a <memcmp>
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
80103b41:	e9 b1 00 00 00       	jmp    80103bf7 <initlog+0xc3>
    if(mbrI.partitions[i].size > 0){
80103b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b49:	83 c0 1b             	add    $0x1b,%eax
80103b4c:	c1 e0 04             	shl    $0x4,%eax
80103b4f:	05 00 18 11 80       	add    $0x80111800,%eax
80103b54:	8b 40 1a             	mov    0x1a(%eax),%eax
80103b57:	85 c0                	test   %eax,%eax
80103b59:	0f 84 94 00 00 00    	je     80103bf3 <initlog+0xbf>
        initlock(&logs[i].lock, "log");
80103b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b62:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b68:	05 40 35 11 80       	add    $0x80113540,%eax
80103b6d:	83 ec 08             	sub    $0x8,%esp
80103b70:	68 14 97 10 80       	push   $0x80109714
80103b75:	50                   	push   %eax
80103b76:	e8 e3 1f 00 00       	call   80105b5e <initlock>
80103b7b:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	c1 e0 05             	shl    $0x5,%eax
80103b84:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b89:	8b 50 0c             	mov    0xc(%eax),%edx
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	c1 e0 05             	shl    $0x5,%eax
80103b92:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b97:	8b 00                	mov    (%eax),%eax
80103b99:	01 d0                	add    %edx,%eax
80103b9b:	89 c2                	mov    %eax,%edx
80103b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ba6:	05 70 35 11 80       	add    $0x80113570,%eax
80103bab:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb1:	c1 e0 05             	shl    $0x5,%eax
80103bb4:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103bb9:	8b 40 0c             	mov    0xc(%eax),%eax
80103bbc:	89 c2                	mov    %eax,%edx
80103bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bc7:	05 70 35 11 80       	add    $0x80113570,%eax
80103bcc:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bd8:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103bde:	8b 45 08             	mov    0x8(%ebp),%eax
80103be1:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be7:	83 ec 0c             	sub    $0xc,%esp
80103bea:	50                   	push   %eax
80103beb:	e8 6a 02 00 00       	call   80103e5a <recover_from_log>
80103bf0:	83 c4 10             	add    $0x10,%esp
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103bf3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bf7:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103bfb:	0f 8e 45 ff ff ff    	jle    80103b46 <initlog+0x12>
  recover_from_log(i);
    }
     
}
 
}
80103c01:	90                   	nop
80103c02:	c9                   	leave  
80103c03:	c3                   	ret    

80103c04 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103c04:	55                   	push   %ebp
80103c05:	89 e5                	mov    %esp,%ebp
80103c07:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103c0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c11:	e9 c0 00 00 00       	jmp    80103cd6 <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103c16:	8b 45 08             	mov    0x8(%ebp),%eax
80103c19:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c1f:	05 70 35 11 80       	add    $0x80113570,%eax
80103c24:	8b 50 04             	mov    0x4(%eax),%edx
80103c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2a:	01 d0                	add    %edx,%eax
80103c2c:	83 c0 01             	add    $0x1,%eax
80103c2f:	89 c2                	mov    %eax,%edx
80103c31:	8b 45 08             	mov    0x8(%ebp),%eax
80103c34:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c3a:	05 80 35 11 80       	add    $0x80113580,%eax
80103c3f:	8b 40 04             	mov    0x4(%eax),%eax
80103c42:	83 ec 08             	sub    $0x8,%esp
80103c45:	52                   	push   %edx
80103c46:	50                   	push   %eax
80103c47:	e8 6a c5 ff ff       	call   801001b6 <bread>
80103c4c:	83 c4 10             	add    $0x10,%esp
80103c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c52:	8b 45 08             	mov    0x8(%ebp),%eax
80103c55:	6b d0 31             	imul   $0x31,%eax,%edx
80103c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5b:	01 d0                	add    %edx,%eax
80103c5d:	83 c0 10             	add    $0x10,%eax
80103c60:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c67:	89 c2                	mov    %eax,%edx
80103c69:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c72:	05 80 35 11 80       	add    $0x80113580,%eax
80103c77:	8b 40 04             	mov    0x4(%eax),%eax
80103c7a:	83 ec 08             	sub    $0x8,%esp
80103c7d:	52                   	push   %edx
80103c7e:	50                   	push   %eax
80103c7f:	e8 32 c5 ff ff       	call   801001b6 <bread>
80103c84:	83 c4 10             	add    $0x10,%esp
80103c87:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8d:	8d 50 18             	lea    0x18(%eax),%edx
80103c90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c93:	83 c0 18             	add    $0x18,%eax
80103c96:	83 ec 04             	sub    $0x4,%esp
80103c99:	68 00 02 00 00       	push   $0x200
80103c9e:	52                   	push   %edx
80103c9f:	50                   	push   %eax
80103ca0:	e8 fd 21 00 00       	call   80105ea2 <memmove>
80103ca5:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103ca8:	83 ec 0c             	sub    $0xc,%esp
80103cab:	ff 75 ec             	pushl  -0x14(%ebp)
80103cae:	e8 3c c5 ff ff       	call   801001ef <bwrite>
80103cb3:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103cb6:	83 ec 0c             	sub    $0xc,%esp
80103cb9:	ff 75 f0             	pushl  -0x10(%ebp)
80103cbc:	e8 6d c5 ff ff       	call   8010022e <brelse>
80103cc1:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103cc4:	83 ec 0c             	sub    $0xc,%esp
80103cc7:	ff 75 ec             	pushl  -0x14(%ebp)
80103cca:	e8 5f c5 ff ff       	call   8010022e <brelse>
80103ccf:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103cd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cdf:	05 80 35 11 80       	add    $0x80113580,%eax
80103ce4:	8b 40 08             	mov    0x8(%eax),%eax
80103ce7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cea:	0f 8f 26 ff ff ff    	jg     80103c16 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103cf0:	90                   	nop
80103cf1:	c9                   	leave  
80103cf2:	c3                   	ret    

80103cf3 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103cf3:	55                   	push   %ebp
80103cf4:	89 e5                	mov    %esp,%ebp
80103cf6:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfc:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d02:	05 70 35 11 80       	add    $0x80113570,%eax
80103d07:	8b 40 04             	mov    0x4(%eax),%eax
80103d0a:	89 c2                	mov    %eax,%edx
80103d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d15:	05 80 35 11 80       	add    $0x80113580,%eax
80103d1a:	8b 40 04             	mov    0x4(%eax),%eax
80103d1d:	83 ec 08             	sub    $0x8,%esp
80103d20:	52                   	push   %edx
80103d21:	50                   	push   %eax
80103d22:	e8 8f c4 ff ff       	call   801001b6 <bread>
80103d27:	83 c4 10             	add    $0x10,%esp
80103d2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d30:	83 c0 18             	add    $0x18,%eax
80103d33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d39:	8b 00                	mov    (%eax),%eax
80103d3b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d3e:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d44:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d4a:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d54:	eb 23                	jmp    80103d79 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d5c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d60:	8b 55 08             	mov    0x8(%ebp),%edx
80103d63:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d69:	01 ca                	add    %ecx,%edx
80103d6b:	83 c2 10             	add    $0x10,%edx
80103d6e:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d79:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d82:	05 80 35 11 80       	add    $0x80113580,%eax
80103d87:	8b 40 08             	mov    0x8(%eax),%eax
80103d8a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d8d:	7f c7                	jg     80103d56 <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d8f:	83 ec 0c             	sub    $0xc,%esp
80103d92:	ff 75 f0             	pushl  -0x10(%ebp)
80103d95:	e8 94 c4 ff ff       	call   8010022e <brelse>
80103d9a:	83 c4 10             	add    $0x10,%esp
}
80103d9d:	90                   	nop
80103d9e:	c9                   	leave  
80103d9f:	c3                   	ret    

80103da0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103da0:	55                   	push   %ebp
80103da1:	89 e5                	mov    %esp,%ebp
80103da3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103da6:	8b 45 08             	mov    0x8(%ebp),%eax
80103da9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103daf:	05 70 35 11 80       	add    $0x80113570,%eax
80103db4:	8b 40 04             	mov    0x4(%eax),%eax
80103db7:	89 c2                	mov    %eax,%edx
80103db9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbc:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dc2:	05 80 35 11 80       	add    $0x80113580,%eax
80103dc7:	8b 40 04             	mov    0x4(%eax),%eax
80103dca:	83 ec 08             	sub    $0x8,%esp
80103dcd:	52                   	push   %edx
80103dce:	50                   	push   %eax
80103dcf:	e8 e2 c3 ff ff       	call   801001b6 <bread>
80103dd4:	83 c4 10             	add    $0x10,%esp
80103dd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ddd:	83 c0 18             	add    $0x18,%eax
80103de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103de3:	8b 45 08             	mov    0x8(%ebp),%eax
80103de6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dec:	05 80 35 11 80       	add    $0x80113580,%eax
80103df1:	8b 50 08             	mov    0x8(%eax),%edx
80103df4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103df7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103df9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e00:	eb 23                	jmp    80103e25 <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103e02:	8b 45 08             	mov    0x8(%ebp),%eax
80103e05:	6b d0 31             	imul   $0x31,%eax,%edx
80103e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0b:	01 d0                	add    %edx,%eax
80103e0d:	83 c0 10             	add    $0x10,%eax
80103e10:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e1d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e25:	8b 45 08             	mov    0x8(%ebp),%eax
80103e28:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e2e:	05 80 35 11 80       	add    $0x80113580,%eax
80103e33:	8b 40 08             	mov    0x8(%eax),%eax
80103e36:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e39:	7f c7                	jg     80103e02 <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	ff 75 f0             	pushl  -0x10(%ebp)
80103e41:	e8 a9 c3 ff ff       	call   801001ef <bwrite>
80103e46:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e49:	83 ec 0c             	sub    $0xc,%esp
80103e4c:	ff 75 f0             	pushl  -0x10(%ebp)
80103e4f:	e8 da c3 ff ff       	call   8010022e <brelse>
80103e54:	83 c4 10             	add    $0x10,%esp
}
80103e57:	90                   	nop
80103e58:	c9                   	leave  
80103e59:	c3                   	ret    

80103e5a <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e5a:	55                   	push   %ebp
80103e5b:	89 e5                	mov    %esp,%ebp
80103e5d:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e60:	83 ec 0c             	sub    $0xc,%esp
80103e63:	ff 75 08             	pushl  0x8(%ebp)
80103e66:	e8 88 fe ff ff       	call   80103cf3 <read_head>
80103e6b:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e6e:	83 ec 0c             	sub    $0xc,%esp
80103e71:	ff 75 08             	pushl  0x8(%ebp)
80103e74:	e8 8b fd ff ff       	call   80103c04 <install_trans>
80103e79:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e85:	05 80 35 11 80       	add    $0x80113580,%eax
80103e8a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103e91:	83 ec 0c             	sub    $0xc,%esp
80103e94:	ff 75 08             	pushl  0x8(%ebp)
80103e97:	e8 04 ff ff ff       	call   80103da0 <write_head>
80103e9c:	83 c4 10             	add    $0x10,%esp
}
80103e9f:	90                   	nop
80103ea0:	c9                   	leave  
80103ea1:	c3                   	ret    

80103ea2 <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103ea2:	55                   	push   %ebp
80103ea3:	89 e5                	mov    %esp,%ebp
80103ea5:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80103eab:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eb1:	05 40 35 11 80       	add    $0x80113540,%eax
80103eb6:	83 ec 0c             	sub    $0xc,%esp
80103eb9:	50                   	push   %eax
80103eba:	e8 c1 1c 00 00       	call   80105b80 <acquire>
80103ebf:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ecb:	05 80 35 11 80       	add    $0x80113580,%eax
80103ed0:	8b 00                	mov    (%eax),%eax
80103ed2:	85 c0                	test   %eax,%eax
80103ed4:	74 2c                	je     80103f02 <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103edf:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eee:	05 40 35 11 80       	add    $0x80113540,%eax
80103ef3:	83 ec 08             	sub    $0x8,%esp
80103ef6:	52                   	push   %edx
80103ef7:	50                   	push   %eax
80103ef8:	e8 8a 19 00 00       	call   80105887 <sleep>
80103efd:	83 c4 10             	add    $0x10,%esp
80103f00:	eb c0                	jmp    80103ec2 <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103f02:	8b 45 08             	mov    0x8(%ebp),%eax
80103f05:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f0b:	05 80 35 11 80       	add    $0x80113580,%eax
80103f10:	8b 48 08             	mov    0x8(%eax),%ecx
80103f13:	8b 45 08             	mov    0x8(%ebp),%eax
80103f16:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f1c:	05 70 35 11 80       	add    $0x80113570,%eax
80103f21:	8b 40 0c             	mov    0xc(%eax),%eax
80103f24:	8d 50 01             	lea    0x1(%eax),%edx
80103f27:	89 d0                	mov    %edx,%eax
80103f29:	c1 e0 02             	shl    $0x2,%eax
80103f2c:	01 d0                	add    %edx,%eax
80103f2e:	01 c0                	add    %eax,%eax
80103f30:	01 c8                	add    %ecx,%eax
80103f32:	83 f8 1e             	cmp    $0x1e,%eax
80103f35:	7e 2f                	jle    80103f66 <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f37:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f40:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f46:	8b 45 08             	mov    0x8(%ebp),%eax
80103f49:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f4f:	05 40 35 11 80       	add    $0x80113540,%eax
80103f54:	83 ec 08             	sub    $0x8,%esp
80103f57:	52                   	push   %edx
80103f58:	50                   	push   %eax
80103f59:	e8 29 19 00 00       	call   80105887 <sleep>
80103f5e:	83 c4 10             	add    $0x10,%esp
80103f61:	e9 5c ff ff ff       	jmp    80103ec2 <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f66:	8b 45 08             	mov    0x8(%ebp),%eax
80103f69:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f6f:	05 70 35 11 80       	add    $0x80113570,%eax
80103f74:	8b 40 0c             	mov    0xc(%eax),%eax
80103f77:	8d 50 01             	lea    0x1(%eax),%edx
80103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f83:	05 70 35 11 80       	add    $0x80113570,%eax
80103f88:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f94:	05 40 35 11 80       	add    $0x80113540,%eax
80103f99:	83 ec 0c             	sub    $0xc,%esp
80103f9c:	50                   	push   %eax
80103f9d:	e8 45 1c 00 00       	call   80105be7 <release>
80103fa2:	83 c4 10             	add    $0x10,%esp
      break;
80103fa5:	90                   	nop
    }
  }
}
80103fa6:	90                   	nop
80103fa7:	c9                   	leave  
80103fa8:	c3                   	ret    

80103fa9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103fa9:	55                   	push   %ebp
80103faa:	89 e5                	mov    %esp,%ebp
80103fac:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103faf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fbf:	05 40 35 11 80       	add    $0x80113540,%eax
80103fc4:	83 ec 0c             	sub    $0xc,%esp
80103fc7:	50                   	push   %eax
80103fc8:	e8 b3 1b 00 00       	call   80105b80 <acquire>
80103fcd:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fd9:	05 70 35 11 80       	add    $0x80113570,%eax
80103fde:	8b 40 0c             	mov    0xc(%eax),%eax
80103fe1:	8d 50 ff             	lea    -0x1(%eax),%edx
80103fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fed:	05 70 35 11 80       	add    $0x80113570,%eax
80103ff2:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ffe:	05 80 35 11 80       	add    $0x80113580,%eax
80104003:	8b 00                	mov    (%eax),%eax
80104005:	85 c0                	test   %eax,%eax
80104007:	74 0d                	je     80104016 <end_op+0x6d>
    panic("log.committing");
80104009:	83 ec 0c             	sub    $0xc,%esp
8010400c:	68 18 97 10 80       	push   $0x80109718
80104011:	e8 50 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
80104016:	8b 45 08             	mov    0x8(%ebp),%eax
80104019:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010401f:	05 70 35 11 80       	add    $0x80113570,%eax
80104024:	8b 40 0c             	mov    0xc(%eax),%eax
80104027:	85 c0                	test   %eax,%eax
80104029:	75 1d                	jne    80104048 <end_op+0x9f>
    do_commit = 1;
8010402b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80104032:	8b 45 08             	mov    0x8(%ebp),%eax
80104035:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010403b:	05 80 35 11 80       	add    $0x80113580,%eax
80104040:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80104046:	eb 1a                	jmp    80104062 <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
80104048:	8b 45 08             	mov    0x8(%ebp),%eax
8010404b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104051:	05 40 35 11 80       	add    $0x80113540,%eax
80104056:	83 ec 0c             	sub    $0xc,%esp
80104059:	50                   	push   %eax
8010405a:	e8 13 19 00 00       	call   80105972 <wakeup>
8010405f:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
80104062:	8b 45 08             	mov    0x8(%ebp),%eax
80104065:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010406b:	05 40 35 11 80       	add    $0x80113540,%eax
80104070:	83 ec 0c             	sub    $0xc,%esp
80104073:	50                   	push   %eax
80104074:	e8 6e 1b 00 00       	call   80105be7 <release>
80104079:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010407c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104080:	74 70                	je     801040f2 <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80104082:	83 ec 0c             	sub    $0xc,%esp
80104085:	ff 75 08             	pushl  0x8(%ebp)
80104088:	e8 57 01 00 00       	call   801041e4 <commit>
8010408d:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
80104090:	8b 45 08             	mov    0x8(%ebp),%eax
80104093:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104099:	05 40 35 11 80       	add    $0x80113540,%eax
8010409e:	83 ec 0c             	sub    $0xc,%esp
801040a1:	50                   	push   %eax
801040a2:	e8 d9 1a 00 00       	call   80105b80 <acquire>
801040a7:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040b3:	05 80 35 11 80       	add    $0x80113580,%eax
801040b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
801040be:	8b 45 08             	mov    0x8(%ebp),%eax
801040c1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040c7:	05 40 35 11 80       	add    $0x80113540,%eax
801040cc:	83 ec 0c             	sub    $0xc,%esp
801040cf:	50                   	push   %eax
801040d0:	e8 9d 18 00 00       	call   80105972 <wakeup>
801040d5:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040e1:	05 40 35 11 80       	add    $0x80113540,%eax
801040e6:	83 ec 0c             	sub    $0xc,%esp
801040e9:	50                   	push   %eax
801040ea:	e8 f8 1a 00 00       	call   80105be7 <release>
801040ef:	83 c4 10             	add    $0x10,%esp
  }
}
801040f2:	90                   	nop
801040f3:	c9                   	leave  
801040f4:	c3                   	ret    

801040f5 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
801040f5:	55                   	push   %ebp
801040f6:	89 e5                	mov    %esp,%ebp
801040f8:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801040fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104102:	e9 c0 00 00 00       	jmp    801041c7 <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104110:	05 70 35 11 80       	add    $0x80113570,%eax
80104115:	8b 50 04             	mov    0x4(%eax),%edx
80104118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411b:	01 d0                	add    %edx,%eax
8010411d:	83 c0 01             	add    $0x1,%eax
80104120:	89 c2                	mov    %eax,%edx
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010412b:	05 80 35 11 80       	add    $0x80113580,%eax
80104130:	8b 40 04             	mov    0x4(%eax),%eax
80104133:	83 ec 08             	sub    $0x8,%esp
80104136:	52                   	push   %edx
80104137:	50                   	push   %eax
80104138:	e8 79 c0 ff ff       	call   801001b6 <bread>
8010413d:	83 c4 10             	add    $0x10,%esp
80104140:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	6b d0 31             	imul   $0x31,%eax,%edx
80104149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414c:	01 d0                	add    %edx,%eax
8010414e:	83 c0 10             	add    $0x10,%eax
80104151:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104158:	89 c2                	mov    %eax,%edx
8010415a:	8b 45 08             	mov    0x8(%ebp),%eax
8010415d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104163:	05 80 35 11 80       	add    $0x80113580,%eax
80104168:	8b 40 04             	mov    0x4(%eax),%eax
8010416b:	83 ec 08             	sub    $0x8,%esp
8010416e:	52                   	push   %edx
8010416f:	50                   	push   %eax
80104170:	e8 41 c0 ff ff       	call   801001b6 <bread>
80104175:	83 c4 10             	add    $0x10,%esp
80104178:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010417b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010417e:	8d 50 18             	lea    0x18(%eax),%edx
80104181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104184:	83 c0 18             	add    $0x18,%eax
80104187:	83 ec 04             	sub    $0x4,%esp
8010418a:	68 00 02 00 00       	push   $0x200
8010418f:	52                   	push   %edx
80104190:	50                   	push   %eax
80104191:	e8 0c 1d 00 00       	call   80105ea2 <memmove>
80104196:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80104199:	83 ec 0c             	sub    $0xc,%esp
8010419c:	ff 75 f0             	pushl  -0x10(%ebp)
8010419f:	e8 4b c0 ff ff       	call   801001ef <bwrite>
801041a4:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801041a7:	83 ec 0c             	sub    $0xc,%esp
801041aa:	ff 75 ec             	pushl  -0x14(%ebp)
801041ad:	e8 7c c0 ff ff       	call   8010022e <brelse>
801041b2:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801041b5:	83 ec 0c             	sub    $0xc,%esp
801041b8:	ff 75 f0             	pushl  -0x10(%ebp)
801041bb:	e8 6e c0 ff ff       	call   8010022e <brelse>
801041c0:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801041c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041c7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ca:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041d0:	05 80 35 11 80       	add    $0x80113580,%eax
801041d5:	8b 40 08             	mov    0x8(%eax),%eax
801041d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041db:	0f 8f 26 ff ff ff    	jg     80104107 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041e1:	90                   	nop
801041e2:	c9                   	leave  
801041e3:	c3                   	ret    

801041e4 <commit>:

static void
commit(uint partitionNumber)
{
801041e4:	55                   	push   %ebp
801041e5:	89 e5                	mov    %esp,%ebp
801041e7:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
801041ea:	8b 45 08             	mov    0x8(%ebp),%eax
801041ed:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041f3:	05 80 35 11 80       	add    $0x80113580,%eax
801041f8:	8b 40 08             	mov    0x8(%eax),%eax
801041fb:	85 c0                	test   %eax,%eax
801041fd:	7e 4d                	jle    8010424c <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
801041ff:	83 ec 0c             	sub    $0xc,%esp
80104202:	ff 75 08             	pushl  0x8(%ebp)
80104205:	e8 eb fe ff ff       	call   801040f5 <write_log>
8010420a:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
8010420d:	83 ec 0c             	sub    $0xc,%esp
80104210:	ff 75 08             	pushl  0x8(%ebp)
80104213:	e8 88 fb ff ff       	call   80103da0 <write_head>
80104218:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
8010421b:	83 ec 0c             	sub    $0xc,%esp
8010421e:	ff 75 08             	pushl  0x8(%ebp)
80104221:	e8 de f9 ff ff       	call   80103c04 <install_trans>
80104226:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104232:	05 80 35 11 80       	add    $0x80113580,%eax
80104237:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
8010423e:	83 ec 0c             	sub    $0xc,%esp
80104241:	ff 75 08             	pushl  0x8(%ebp)
80104244:	e8 57 fb ff ff       	call   80103da0 <write_head>
80104249:	83 c4 10             	add    $0x10,%esp
  }
}
8010424c:	90                   	nop
8010424d:	c9                   	leave  
8010424e:	c3                   	ret    

8010424f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
8010424f:	55                   	push   %ebp
80104250:	89 e5                	mov    %esp,%ebp
80104252:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
80104255:	8b 45 0c             	mov    0xc(%ebp),%eax
80104258:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010425e:	05 80 35 11 80       	add    $0x80113580,%eax
80104263:	8b 40 08             	mov    0x8(%eax),%eax
80104266:	83 f8 1d             	cmp    $0x1d,%eax
80104269:	7f 2a                	jg     80104295 <log_write+0x46>
8010426b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104274:	05 80 35 11 80       	add    $0x80113580,%eax
80104279:	8b 40 08             	mov    0x8(%eax),%eax
8010427c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010427f:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80104285:	81 c2 70 35 11 80    	add    $0x80113570,%edx
8010428b:	8b 52 08             	mov    0x8(%edx),%edx
8010428e:	83 ea 01             	sub    $0x1,%edx
80104291:	39 d0                	cmp    %edx,%eax
80104293:	7c 0d                	jl     801042a2 <log_write+0x53>
    panic("too big a transaction");
80104295:	83 ec 0c             	sub    $0xc,%esp
80104298:	68 27 97 10 80       	push   $0x80109727
8010429d:	e8 c4 c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
801042a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801042a5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042ab:	05 70 35 11 80       	add    $0x80113570,%eax
801042b0:	8b 40 0c             	mov    0xc(%eax),%eax
801042b3:	85 c0                	test   %eax,%eax
801042b5:	7f 0d                	jg     801042c4 <log_write+0x75>
    panic("log_write outside of trans");
801042b7:	83 ec 0c             	sub    $0xc,%esp
801042ba:	68 3d 97 10 80       	push   $0x8010973d
801042bf:	e8 a2 c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
801042c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801042c7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042cd:	05 40 35 11 80       	add    $0x80113540,%eax
801042d2:	83 ec 0c             	sub    $0xc,%esp
801042d5:	50                   	push   %eax
801042d6:	e8 a5 18 00 00       	call   80105b80 <acquire>
801042db:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042e5:	eb 25                	jmp    8010430c <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ea:	6b d0 31             	imul   $0x31,%eax,%edx
801042ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f0:	01 d0                	add    %edx,%eax
801042f2:	83 c0 10             	add    $0x10,%eax
801042f5:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
801042fc:	89 c2                	mov    %eax,%edx
801042fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104301:	8b 40 08             	mov    0x8(%eax),%eax
80104304:	39 c2                	cmp    %eax,%edx
80104306:	74 1c                	je     80104324 <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80104308:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010430c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010430f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104315:	05 80 35 11 80       	add    $0x80113580,%eax
8010431a:	8b 40 08             	mov    0x8(%eax),%eax
8010431d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104320:	7f c5                	jg     801042e7 <log_write+0x98>
80104322:	eb 01                	jmp    80104325 <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
80104324:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
80104325:	8b 45 08             	mov    0x8(%ebp),%eax
80104328:	8b 40 08             	mov    0x8(%eax),%eax
8010432b:	89 c1                	mov    %eax,%ecx
8010432d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104330:	6b d0 31             	imul   $0x31,%eax,%edx
80104333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104336:	01 d0                	add    %edx,%eax
80104338:	83 c0 10             	add    $0x10,%eax
8010433b:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
80104342:	8b 45 0c             	mov    0xc(%ebp),%eax
80104345:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010434b:	05 80 35 11 80       	add    $0x80113580,%eax
80104350:	8b 40 08             	mov    0x8(%eax),%eax
80104353:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104356:	75 25                	jne    8010437d <log_write+0x12e>
    logs[partitionNumber].lh.n++;
80104358:	8b 45 0c             	mov    0xc(%ebp),%eax
8010435b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104361:	05 80 35 11 80       	add    $0x80113580,%eax
80104366:	8b 40 08             	mov    0x8(%eax),%eax
80104369:	8d 50 01             	lea    0x1(%eax),%edx
8010436c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010436f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104375:	05 80 35 11 80       	add    $0x80113580,%eax
8010437a:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
8010437d:	8b 45 08             	mov    0x8(%ebp),%eax
80104380:	8b 00                	mov    (%eax),%eax
80104382:	83 c8 04             	or     $0x4,%eax
80104385:	89 c2                	mov    %eax,%edx
80104387:	8b 45 08             	mov    0x8(%ebp),%eax
8010438a:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
8010438c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010438f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104395:	05 40 35 11 80       	add    $0x80113540,%eax
8010439a:	83 ec 0c             	sub    $0xc,%esp
8010439d:	50                   	push   %eax
8010439e:	e8 44 18 00 00       	call   80105be7 <release>
801043a3:	83 c4 10             	add    $0x10,%esp
}
801043a6:	90                   	nop
801043a7:	c9                   	leave  
801043a8:	c3                   	ret    

801043a9 <v2p>:
801043a9:	55                   	push   %ebp
801043aa:	89 e5                	mov    %esp,%ebp
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	05 00 00 00 80       	add    $0x80000000,%eax
801043b4:	5d                   	pop    %ebp
801043b5:	c3                   	ret    

801043b6 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801043b6:	55                   	push   %ebp
801043b7:	89 e5                	mov    %esp,%ebp
801043b9:	8b 45 08             	mov    0x8(%ebp),%eax
801043bc:	05 00 00 00 80       	add    $0x80000000,%eax
801043c1:	5d                   	pop    %ebp
801043c2:	c3                   	ret    

801043c3 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801043c3:	55                   	push   %ebp
801043c4:	89 e5                	mov    %esp,%ebp
801043c6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043c9:	8b 55 08             	mov    0x8(%ebp),%edx
801043cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801043cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043d2:	f0 87 02             	lock xchg %eax,(%edx)
801043d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043db:	c9                   	leave  
801043dc:	c3                   	ret    

801043dd <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043dd:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043e1:	83 e4 f0             	and    $0xfffffff0,%esp
801043e4:	ff 71 fc             	pushl  -0x4(%ecx)
801043e7:	55                   	push   %ebp
801043e8:	89 e5                	mov    %esp,%ebp
801043ea:	51                   	push   %ecx
801043eb:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801043ee:	83 ec 08             	sub    $0x8,%esp
801043f1:	68 00 00 40 80       	push   $0x80400000
801043f6:	68 5c 66 11 80       	push   $0x8011665c
801043fb:	e8 34 ef ff ff       	call   80103334 <kinit1>
80104400:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80104403:	e8 69 48 00 00       	call   80108c71 <kvmalloc>
  mpinit();        // collect info about this machine
80104408:	e8 26 04 00 00       	call   80104833 <mpinit>
  lapicinit();
8010440d:	e8 a1 f2 ff ff       	call   801036b3 <lapicinit>
  seginit();       // set up segments
80104412:	e8 03 42 00 00       	call   8010861a <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
80104417:	e8 6d 06 00 00       	call   80104a89 <picinit>
  ioapicinit();    // another interrupt controller
8010441c:	e8 08 ee ff ff       	call   80103229 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104421:	e8 f3 c6 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80104426:	e8 4b 35 00 00       	call   80107976 <uartinit>
  pinit();         // process table
8010442b:	e8 56 0b 00 00       	call   80104f86 <pinit>
  tvinit();        // trap vectors
80104430:	e8 0b 31 00 00       	call   80107540 <tvinit>
  binit();         // buffer cache
80104435:	e8 fa bb ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
8010443a:	e8 8e cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
8010443f:	e8 dd e9 ff ff       	call   80102e21 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
80104444:	a1 64 38 11 80       	mov    0x80113864,%eax
80104449:	85 c0                	test   %eax,%eax
8010444b:	75 05                	jne    80104452 <main+0x75>
    timerinit();   // uniprocessor timer
8010444d:	e8 4b 30 00 00       	call   8010749d <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80104452:	e8 7f 00 00 00       	call   801044d6 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104457:	83 ec 08             	sub    $0x8,%esp
8010445a:	68 00 00 00 8e       	push   $0x8e000000
8010445f:	68 00 00 40 80       	push   $0x80400000
80104464:	e8 04 ef ff ff       	call   8010336d <kinit2>
80104469:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
8010446c:	e8 39 0c 00 00       	call   801050aa <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
80104471:	e8 1a 00 00 00       	call   80104490 <mpmain>

80104476 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104476:	55                   	push   %ebp
80104477:	89 e5                	mov    %esp,%ebp
80104479:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010447c:	e8 08 48 00 00       	call   80108c89 <switchkvm>
  seginit();
80104481:	e8 94 41 00 00       	call   8010861a <seginit>
  lapicinit();
80104486:	e8 28 f2 ff ff       	call   801036b3 <lapicinit>
  mpmain();
8010448b:	e8 00 00 00 00       	call   80104490 <mpmain>

80104490 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104490:	55                   	push   %ebp
80104491:	89 e5                	mov    %esp,%ebp
80104493:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80104496:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010449c:	0f b6 00             	movzbl (%eax),%eax
8010449f:	0f b6 c0             	movzbl %al,%eax
801044a2:	83 ec 08             	sub    $0x8,%esp
801044a5:	50                   	push   %eax
801044a6:	68 58 97 10 80       	push   $0x80109758
801044ab:	e8 16 bf ff ff       	call   801003c6 <cprintf>
801044b0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801044b3:	e8 fe 31 00 00       	call   801076b6 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801044b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044be:	05 a8 00 00 00       	add    $0xa8,%eax
801044c3:	83 ec 08             	sub    $0x8,%esp
801044c6:	6a 01                	push   $0x1
801044c8:	50                   	push   %eax
801044c9:	e8 f5 fe ff ff       	call   801043c3 <xchg>
801044ce:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044d1:	e8 ab 11 00 00       	call   80105681 <scheduler>

801044d6 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044d6:	55                   	push   %ebp
801044d7:	89 e5                	mov    %esp,%ebp
801044d9:	53                   	push   %ebx
801044da:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044dd:	68 00 70 00 00       	push   $0x7000
801044e2:	e8 cf fe ff ff       	call   801043b6 <p2v>
801044e7:	83 c4 04             	add    $0x4,%esp
801044ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801044ed:	b8 8a 00 00 00       	mov    $0x8a,%eax
801044f2:	83 ec 04             	sub    $0x4,%esp
801044f5:	50                   	push   %eax
801044f6:	68 0c c5 10 80       	push   $0x8010c50c
801044fb:	ff 75 f0             	pushl  -0x10(%ebp)
801044fe:	e8 9f 19 00 00       	call   80105ea2 <memmove>
80104503:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80104506:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
8010450d:	e9 90 00 00 00       	jmp    801045a2 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80104512:	e8 ba f2 ff ff       	call   801037d1 <cpunum>
80104517:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010451d:	05 80 38 11 80       	add    $0x80113880,%eax
80104522:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104525:	74 73                	je     8010459a <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104527:	e8 3f ef ff ff       	call   8010346b <kalloc>
8010452c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010452f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104532:	83 e8 04             	sub    $0x4,%eax
80104535:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104538:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010453e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104540:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104543:	83 e8 08             	sub    $0x8,%eax
80104546:	c7 00 76 44 10 80    	movl   $0x80104476,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104552:	83 ec 0c             	sub    $0xc,%esp
80104555:	68 00 b0 10 80       	push   $0x8010b000
8010455a:	e8 4a fe ff ff       	call   801043a9 <v2p>
8010455f:	83 c4 10             	add    $0x10,%esp
80104562:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104564:	83 ec 0c             	sub    $0xc,%esp
80104567:	ff 75 f0             	pushl  -0x10(%ebp)
8010456a:	e8 3a fe ff ff       	call   801043a9 <v2p>
8010456f:	83 c4 10             	add    $0x10,%esp
80104572:	89 c2                	mov    %eax,%edx
80104574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104577:	0f b6 00             	movzbl (%eax),%eax
8010457a:	0f b6 c0             	movzbl %al,%eax
8010457d:	83 ec 08             	sub    $0x8,%esp
80104580:	52                   	push   %edx
80104581:	50                   	push   %eax
80104582:	e8 c4 f2 ff ff       	call   8010384b <lapicstartap>
80104587:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010458a:	90                   	nop
8010458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104594:	85 c0                	test   %eax,%eax
80104596:	74 f3                	je     8010458b <startothers+0xb5>
80104598:	eb 01                	jmp    8010459b <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010459a:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010459b:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801045a2:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801045a7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801045ad:	05 80 38 11 80       	add    $0x80113880,%eax
801045b2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801045b5:	0f 87 57 ff ff ff    	ja     80104512 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801045bb:	90                   	nop
801045bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045bf:	c9                   	leave  
801045c0:	c3                   	ret    

801045c1 <p2v>:
801045c1:	55                   	push   %ebp
801045c2:	89 e5                	mov    %esp,%ebp
801045c4:	8b 45 08             	mov    0x8(%ebp),%eax
801045c7:	05 00 00 00 80       	add    $0x80000000,%eax
801045cc:	5d                   	pop    %ebp
801045cd:	c3                   	ret    

801045ce <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045ce:	55                   	push   %ebp
801045cf:	89 e5                	mov    %esp,%ebp
801045d1:	83 ec 14             	sub    $0x14,%esp
801045d4:	8b 45 08             	mov    0x8(%ebp),%eax
801045d7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045db:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045df:	89 c2                	mov    %eax,%edx
801045e1:	ec                   	in     (%dx),%al
801045e2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045e5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801045e9:	c9                   	leave  
801045ea:	c3                   	ret    

801045eb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045eb:	55                   	push   %ebp
801045ec:	89 e5                	mov    %esp,%ebp
801045ee:	83 ec 08             	sub    $0x8,%esp
801045f1:	8b 55 08             	mov    0x8(%ebp),%edx
801045f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801045f7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045fb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045fe:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104602:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104606:	ee                   	out    %al,(%dx)
}
80104607:	90                   	nop
80104608:	c9                   	leave  
80104609:	c3                   	ret    

8010460a <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010460a:	55                   	push   %ebp
8010460b:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010460d:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104612:	89 c2                	mov    %eax,%edx
80104614:	b8 80 38 11 80       	mov    $0x80113880,%eax
80104619:	29 c2                	sub    %eax,%edx
8010461b:	89 d0                	mov    %edx,%eax
8010461d:	c1 f8 02             	sar    $0x2,%eax
80104620:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104626:	5d                   	pop    %ebp
80104627:	c3                   	ret    

80104628 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104628:	55                   	push   %ebp
80104629:	89 e5                	mov    %esp,%ebp
8010462b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010462e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104635:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010463c:	eb 15                	jmp    80104653 <sum+0x2b>
    sum += addr[i];
8010463e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104641:	8b 45 08             	mov    0x8(%ebp),%eax
80104644:	01 d0                	add    %edx,%eax
80104646:	0f b6 00             	movzbl (%eax),%eax
80104649:	0f b6 c0             	movzbl %al,%eax
8010464c:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010464f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104653:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104656:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104659:	7c e3                	jl     8010463e <sum+0x16>
    sum += addr[i];
  return sum;
8010465b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010465e:	c9                   	leave  
8010465f:	c3                   	ret    

80104660 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104660:	55                   	push   %ebp
80104661:	89 e5                	mov    %esp,%ebp
80104663:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104666:	ff 75 08             	pushl  0x8(%ebp)
80104669:	e8 53 ff ff ff       	call   801045c1 <p2v>
8010466e:	83 c4 04             	add    $0x4,%esp
80104671:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104674:	8b 55 0c             	mov    0xc(%ebp),%edx
80104677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010467a:	01 d0                	add    %edx,%eax
8010467c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010467f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104682:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104685:	eb 36                	jmp    801046bd <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104687:	83 ec 04             	sub    $0x4,%esp
8010468a:	6a 04                	push   $0x4
8010468c:	68 6c 97 10 80       	push   $0x8010976c
80104691:	ff 75 f4             	pushl  -0xc(%ebp)
80104694:	e8 b1 17 00 00       	call   80105e4a <memcmp>
80104699:	83 c4 10             	add    $0x10,%esp
8010469c:	85 c0                	test   %eax,%eax
8010469e:	75 19                	jne    801046b9 <mpsearch1+0x59>
801046a0:	83 ec 08             	sub    $0x8,%esp
801046a3:	6a 10                	push   $0x10
801046a5:	ff 75 f4             	pushl  -0xc(%ebp)
801046a8:	e8 7b ff ff ff       	call   80104628 <sum>
801046ad:	83 c4 10             	add    $0x10,%esp
801046b0:	84 c0                	test   %al,%al
801046b2:	75 05                	jne    801046b9 <mpsearch1+0x59>
      return (struct mp*)p;
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	eb 11                	jmp    801046ca <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801046b9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801046bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046c3:	72 c2                	jb     80104687 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801046c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046ca:	c9                   	leave  
801046cb:	c3                   	ret    

801046cc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046cc:	55                   	push   %ebp
801046cd:	89 e5                	mov    %esp,%ebp
801046cf:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046d2:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dc:	83 c0 0f             	add    $0xf,%eax
801046df:	0f b6 00             	movzbl (%eax),%eax
801046e2:	0f b6 c0             	movzbl %al,%eax
801046e5:	c1 e0 08             	shl    $0x8,%eax
801046e8:	89 c2                	mov    %eax,%edx
801046ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ed:	83 c0 0e             	add    $0xe,%eax
801046f0:	0f b6 00             	movzbl (%eax),%eax
801046f3:	0f b6 c0             	movzbl %al,%eax
801046f6:	09 d0                	or     %edx,%eax
801046f8:	c1 e0 04             	shl    $0x4,%eax
801046fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801046fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104702:	74 21                	je     80104725 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80104704:	83 ec 08             	sub    $0x8,%esp
80104707:	68 00 04 00 00       	push   $0x400
8010470c:	ff 75 f0             	pushl  -0x10(%ebp)
8010470f:	e8 4c ff ff ff       	call   80104660 <mpsearch1>
80104714:	83 c4 10             	add    $0x10,%esp
80104717:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010471a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010471e:	74 51                	je     80104771 <mpsearch+0xa5>
      return mp;
80104720:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104723:	eb 61                	jmp    80104786 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104728:	83 c0 14             	add    $0x14,%eax
8010472b:	0f b6 00             	movzbl (%eax),%eax
8010472e:	0f b6 c0             	movzbl %al,%eax
80104731:	c1 e0 08             	shl    $0x8,%eax
80104734:	89 c2                	mov    %eax,%edx
80104736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104739:	83 c0 13             	add    $0x13,%eax
8010473c:	0f b6 00             	movzbl (%eax),%eax
8010473f:	0f b6 c0             	movzbl %al,%eax
80104742:	09 d0                	or     %edx,%eax
80104744:	c1 e0 0a             	shl    $0xa,%eax
80104747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010474a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010474d:	2d 00 04 00 00       	sub    $0x400,%eax
80104752:	83 ec 08             	sub    $0x8,%esp
80104755:	68 00 04 00 00       	push   $0x400
8010475a:	50                   	push   %eax
8010475b:	e8 00 ff ff ff       	call   80104660 <mpsearch1>
80104760:	83 c4 10             	add    $0x10,%esp
80104763:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104766:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010476a:	74 05                	je     80104771 <mpsearch+0xa5>
      return mp;
8010476c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010476f:	eb 15                	jmp    80104786 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104771:	83 ec 08             	sub    $0x8,%esp
80104774:	68 00 00 01 00       	push   $0x10000
80104779:	68 00 00 0f 00       	push   $0xf0000
8010477e:	e8 dd fe ff ff       	call   80104660 <mpsearch1>
80104783:	83 c4 10             	add    $0x10,%esp
}
80104786:	c9                   	leave  
80104787:	c3                   	ret    

80104788 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104788:	55                   	push   %ebp
80104789:	89 e5                	mov    %esp,%ebp
8010478b:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010478e:	e8 39 ff ff ff       	call   801046cc <mpsearch>
80104793:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104796:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010479a:	74 0a                	je     801047a6 <mpconfig+0x1e>
8010479c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479f:	8b 40 04             	mov    0x4(%eax),%eax
801047a2:	85 c0                	test   %eax,%eax
801047a4:	75 0a                	jne    801047b0 <mpconfig+0x28>
    return 0;
801047a6:	b8 00 00 00 00       	mov    $0x0,%eax
801047ab:	e9 81 00 00 00       	jmp    80104831 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801047b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b3:	8b 40 04             	mov    0x4(%eax),%eax
801047b6:	83 ec 0c             	sub    $0xc,%esp
801047b9:	50                   	push   %eax
801047ba:	e8 02 fe ff ff       	call   801045c1 <p2v>
801047bf:	83 c4 10             	add    $0x10,%esp
801047c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801047c5:	83 ec 04             	sub    $0x4,%esp
801047c8:	6a 04                	push   $0x4
801047ca:	68 71 97 10 80       	push   $0x80109771
801047cf:	ff 75 f0             	pushl  -0x10(%ebp)
801047d2:	e8 73 16 00 00       	call   80105e4a <memcmp>
801047d7:	83 c4 10             	add    $0x10,%esp
801047da:	85 c0                	test   %eax,%eax
801047dc:	74 07                	je     801047e5 <mpconfig+0x5d>
    return 0;
801047de:	b8 00 00 00 00       	mov    $0x0,%eax
801047e3:	eb 4c                	jmp    80104831 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e8:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047ec:	3c 01                	cmp    $0x1,%al
801047ee:	74 12                	je     80104802 <mpconfig+0x7a>
801047f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f3:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047f7:	3c 04                	cmp    $0x4,%al
801047f9:	74 07                	je     80104802 <mpconfig+0x7a>
    return 0;
801047fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104800:	eb 2f                	jmp    80104831 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104805:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104809:	0f b7 c0             	movzwl %ax,%eax
8010480c:	83 ec 08             	sub    $0x8,%esp
8010480f:	50                   	push   %eax
80104810:	ff 75 f0             	pushl  -0x10(%ebp)
80104813:	e8 10 fe ff ff       	call   80104628 <sum>
80104818:	83 c4 10             	add    $0x10,%esp
8010481b:	84 c0                	test   %al,%al
8010481d:	74 07                	je     80104826 <mpconfig+0x9e>
    return 0;
8010481f:	b8 00 00 00 00       	mov    $0x0,%eax
80104824:	eb 0b                	jmp    80104831 <mpconfig+0xa9>
  *pmp = mp;
80104826:	8b 45 08             	mov    0x8(%ebp),%eax
80104829:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010482c:	89 10                	mov    %edx,(%eax)
  return conf;
8010482e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104831:	c9                   	leave  
80104832:	c3                   	ret    

80104833 <mpinit>:

void
mpinit(void)
{
80104833:	55                   	push   %ebp
80104834:	89 e5                	mov    %esp,%ebp
80104836:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104839:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
80104840:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104843:	83 ec 0c             	sub    $0xc,%esp
80104846:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104849:	50                   	push   %eax
8010484a:	e8 39 ff ff ff       	call   80104788 <mpconfig>
8010484f:	83 c4 10             	add    $0x10,%esp
80104852:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104855:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104859:	0f 84 96 01 00 00    	je     801049f5 <mpinit+0x1c2>
    return;
  ismp = 1;
8010485f:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
80104866:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486c:	8b 40 24             	mov    0x24(%eax),%eax
8010486f:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104877:	83 c0 2c             	add    $0x2c,%eax
8010487a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010487d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104880:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104884:	0f b7 d0             	movzwl %ax,%edx
80104887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010488a:	01 d0                	add    %edx,%eax
8010488c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010488f:	e9 f2 00 00 00       	jmp    80104986 <mpinit+0x153>
    switch(*p){
80104894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104897:	0f b6 00             	movzbl (%eax),%eax
8010489a:	0f b6 c0             	movzbl %al,%eax
8010489d:	83 f8 04             	cmp    $0x4,%eax
801048a0:	0f 87 bc 00 00 00    	ja     80104962 <mpinit+0x12f>
801048a6:	8b 04 85 b4 97 10 80 	mov    -0x7fef684c(,%eax,4),%eax
801048ad:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801048af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801048b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048b8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048bc:	0f b6 d0             	movzbl %al,%edx
801048bf:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048c4:	39 c2                	cmp    %eax,%edx
801048c6:	74 2b                	je     801048f3 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048cb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048cf:	0f b6 d0             	movzbl %al,%edx
801048d2:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048d7:	83 ec 04             	sub    $0x4,%esp
801048da:	52                   	push   %edx
801048db:	50                   	push   %eax
801048dc:	68 76 97 10 80       	push   $0x80109776
801048e1:	e8 e0 ba ff ff       	call   801003c6 <cprintf>
801048e6:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801048e9:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
801048f0:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801048f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048f6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801048fa:	0f b6 c0             	movzbl %al,%eax
801048fd:	83 e0 02             	and    $0x2,%eax
80104900:	85 c0                	test   %eax,%eax
80104902:	74 15                	je     80104919 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104904:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104909:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010490f:	05 80 38 11 80       	add    $0x80113880,%eax
80104914:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104919:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010491e:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
80104924:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010492a:	05 80 38 11 80       	add    $0x80113880,%eax
8010492f:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104931:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104936:	83 c0 01             	add    $0x1,%eax
80104939:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
8010493e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104942:	eb 42                	jmp    80104986 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104947:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010494a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010494d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104951:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
80104956:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010495a:	eb 2a                	jmp    80104986 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010495c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104960:	eb 24                	jmp    80104986 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104965:	0f b6 00             	movzbl (%eax),%eax
80104968:	0f b6 c0             	movzbl %al,%eax
8010496b:	83 ec 08             	sub    $0x8,%esp
8010496e:	50                   	push   %eax
8010496f:	68 94 97 10 80       	push   $0x80109794
80104974:	e8 4d ba ff ff       	call   801003c6 <cprintf>
80104979:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010497c:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
80104983:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104989:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010498c:	0f 82 02 ff ff ff    	jb     80104894 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104992:	a1 64 38 11 80       	mov    0x80113864,%eax
80104997:	85 c0                	test   %eax,%eax
80104999:	75 1d                	jne    801049b8 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
8010499b:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
801049a2:	00 00 00 
    lapic = 0;
801049a5:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
801049ac:	00 00 00 
    ioapicid = 0;
801049af:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
801049b6:	eb 3e                	jmp    801049f6 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801049b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049bb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801049bf:	84 c0                	test   %al,%al
801049c1:	74 33                	je     801049f6 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801049c3:	83 ec 08             	sub    $0x8,%esp
801049c6:	6a 70                	push   $0x70
801049c8:	6a 22                	push   $0x22
801049ca:	e8 1c fc ff ff       	call   801045eb <outb>
801049cf:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049d2:	83 ec 0c             	sub    $0xc,%esp
801049d5:	6a 23                	push   $0x23
801049d7:	e8 f2 fb ff ff       	call   801045ce <inb>
801049dc:	83 c4 10             	add    $0x10,%esp
801049df:	83 c8 01             	or     $0x1,%eax
801049e2:	0f b6 c0             	movzbl %al,%eax
801049e5:	83 ec 08             	sub    $0x8,%esp
801049e8:	50                   	push   %eax
801049e9:	6a 23                	push   $0x23
801049eb:	e8 fb fb ff ff       	call   801045eb <outb>
801049f0:	83 c4 10             	add    $0x10,%esp
801049f3:	eb 01                	jmp    801049f6 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801049f5:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801049f6:	c9                   	leave  
801049f7:	c3                   	ret    

801049f8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801049f8:	55                   	push   %ebp
801049f9:	89 e5                	mov    %esp,%ebp
801049fb:	83 ec 08             	sub    $0x8,%esp
801049fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104a01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a04:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104a08:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104a0b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104a0f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104a13:	ee                   	out    %al,(%dx)
}
80104a14:	90                   	nop
80104a15:	c9                   	leave  
80104a16:	c3                   	ret    

80104a17 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104a17:	55                   	push   %ebp
80104a18:	89 e5                	mov    %esp,%ebp
80104a1a:	83 ec 04             	sub    $0x4,%esp
80104a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a20:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104a24:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a28:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a2e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a32:	0f b6 c0             	movzbl %al,%eax
80104a35:	50                   	push   %eax
80104a36:	6a 21                	push   $0x21
80104a38:	e8 bb ff ff ff       	call   801049f8 <outb>
80104a3d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a40:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a44:	66 c1 e8 08          	shr    $0x8,%ax
80104a48:	0f b6 c0             	movzbl %al,%eax
80104a4b:	50                   	push   %eax
80104a4c:	68 a1 00 00 00       	push   $0xa1
80104a51:	e8 a2 ff ff ff       	call   801049f8 <outb>
80104a56:	83 c4 08             	add    $0x8,%esp
}
80104a59:	90                   	nop
80104a5a:	c9                   	leave  
80104a5b:	c3                   	ret    

80104a5c <picenable>:

void
picenable(int irq)
{
80104a5c:	55                   	push   %ebp
80104a5d:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a62:	ba 01 00 00 00       	mov    $0x1,%edx
80104a67:	89 c1                	mov    %eax,%ecx
80104a69:	d3 e2                	shl    %cl,%edx
80104a6b:	89 d0                	mov    %edx,%eax
80104a6d:	f7 d0                	not    %eax
80104a6f:	89 c2                	mov    %eax,%edx
80104a71:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a78:	21 d0                	and    %edx,%eax
80104a7a:	0f b7 c0             	movzwl %ax,%eax
80104a7d:	50                   	push   %eax
80104a7e:	e8 94 ff ff ff       	call   80104a17 <picsetmask>
80104a83:	83 c4 04             	add    $0x4,%esp
}
80104a86:	90                   	nop
80104a87:	c9                   	leave  
80104a88:	c3                   	ret    

80104a89 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104a89:	55                   	push   %ebp
80104a8a:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104a8c:	68 ff 00 00 00       	push   $0xff
80104a91:	6a 21                	push   $0x21
80104a93:	e8 60 ff ff ff       	call   801049f8 <outb>
80104a98:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104a9b:	68 ff 00 00 00       	push   $0xff
80104aa0:	68 a1 00 00 00       	push   $0xa1
80104aa5:	e8 4e ff ff ff       	call   801049f8 <outb>
80104aaa:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104aad:	6a 11                	push   $0x11
80104aaf:	6a 20                	push   $0x20
80104ab1:	e8 42 ff ff ff       	call   801049f8 <outb>
80104ab6:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104ab9:	6a 20                	push   $0x20
80104abb:	6a 21                	push   $0x21
80104abd:	e8 36 ff ff ff       	call   801049f8 <outb>
80104ac2:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104ac5:	6a 04                	push   $0x4
80104ac7:	6a 21                	push   $0x21
80104ac9:	e8 2a ff ff ff       	call   801049f8 <outb>
80104ace:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104ad1:	6a 03                	push   $0x3
80104ad3:	6a 21                	push   $0x21
80104ad5:	e8 1e ff ff ff       	call   801049f8 <outb>
80104ada:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104add:	6a 11                	push   $0x11
80104adf:	68 a0 00 00 00       	push   $0xa0
80104ae4:	e8 0f ff ff ff       	call   801049f8 <outb>
80104ae9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104aec:	6a 28                	push   $0x28
80104aee:	68 a1 00 00 00       	push   $0xa1
80104af3:	e8 00 ff ff ff       	call   801049f8 <outb>
80104af8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104afb:	6a 02                	push   $0x2
80104afd:	68 a1 00 00 00       	push   $0xa1
80104b02:	e8 f1 fe ff ff       	call   801049f8 <outb>
80104b07:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104b0a:	6a 03                	push   $0x3
80104b0c:	68 a1 00 00 00       	push   $0xa1
80104b11:	e8 e2 fe ff ff       	call   801049f8 <outb>
80104b16:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104b19:	6a 68                	push   $0x68
80104b1b:	6a 20                	push   $0x20
80104b1d:	e8 d6 fe ff ff       	call   801049f8 <outb>
80104b22:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104b25:	6a 0a                	push   $0xa
80104b27:	6a 20                	push   $0x20
80104b29:	e8 ca fe ff ff       	call   801049f8 <outb>
80104b2e:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b31:	6a 68                	push   $0x68
80104b33:	68 a0 00 00 00       	push   $0xa0
80104b38:	e8 bb fe ff ff       	call   801049f8 <outb>
80104b3d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b40:	6a 0a                	push   $0xa
80104b42:	68 a0 00 00 00       	push   $0xa0
80104b47:	e8 ac fe ff ff       	call   801049f8 <outb>
80104b4c:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b4f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b56:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b5a:	74 13                	je     80104b6f <picinit+0xe6>
    picsetmask(irqmask);
80104b5c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b63:	0f b7 c0             	movzwl %ax,%eax
80104b66:	50                   	push   %eax
80104b67:	e8 ab fe ff ff       	call   80104a17 <picsetmask>
80104b6c:	83 c4 04             	add    $0x4,%esp
}
80104b6f:	90                   	nop
80104b70:	c9                   	leave  
80104b71:	c3                   	ret    

80104b72 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b72:	55                   	push   %ebp
80104b73:	89 e5                	mov    %esp,%ebp
80104b75:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b88:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8b:	8b 10                	mov    (%eax),%edx
80104b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b90:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104b92:	e8 54 c4 ff ff       	call   80100feb <filealloc>
80104b97:	89 c2                	mov    %eax,%edx
80104b99:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9c:	89 10                	mov    %edx,(%eax)
80104b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba1:	8b 00                	mov    (%eax),%eax
80104ba3:	85 c0                	test   %eax,%eax
80104ba5:	0f 84 cb 00 00 00    	je     80104c76 <pipealloc+0x104>
80104bab:	e8 3b c4 ff ff       	call   80100feb <filealloc>
80104bb0:	89 c2                	mov    %eax,%edx
80104bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb5:	89 10                	mov    %edx,(%eax)
80104bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bba:	8b 00                	mov    (%eax),%eax
80104bbc:	85 c0                	test   %eax,%eax
80104bbe:	0f 84 b2 00 00 00    	je     80104c76 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104bc4:	e8 a2 e8 ff ff       	call   8010346b <kalloc>
80104bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bd0:	0f 84 9f 00 00 00    	je     80104c75 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd9:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104be0:	00 00 00 
  p->writeopen = 1;
80104be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104bed:	00 00 00 
  p->nwrite = 0;
80104bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf3:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104bfa:	00 00 00 
  p->nread = 0;
80104bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c00:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104c07:	00 00 00 
  initlock(&p->lock, "pipe");
80104c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0d:	83 ec 08             	sub    $0x8,%esp
80104c10:	68 c8 97 10 80       	push   $0x801097c8
80104c15:	50                   	push   %eax
80104c16:	e8 43 0f 00 00       	call   80105b5e <initlock>
80104c1b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c21:	8b 00                	mov    (%eax),%eax
80104c23:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c29:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2c:	8b 00                	mov    (%eax),%eax
80104c2e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c32:	8b 45 08             	mov    0x8(%ebp),%eax
80104c35:	8b 00                	mov    (%eax),%eax
80104c37:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3e:	8b 00                	mov    (%eax),%eax
80104c40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c43:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c46:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c49:	8b 00                	mov    (%eax),%eax
80104c4b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c54:	8b 00                	mov    (%eax),%eax
80104c56:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c5d:	8b 00                	mov    (%eax),%eax
80104c5f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c63:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c66:	8b 00                	mov    (%eax),%eax
80104c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c6b:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c6e:	b8 00 00 00 00       	mov    $0x0,%eax
80104c73:	eb 4e                	jmp    80104cc3 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c75:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c7a:	74 0e                	je     80104c8a <pipealloc+0x118>
    kfree((char*)p);
80104c7c:	83 ec 0c             	sub    $0xc,%esp
80104c7f:	ff 75 f4             	pushl  -0xc(%ebp)
80104c82:	e8 47 e7 ff ff       	call   801033ce <kfree>
80104c87:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8d:	8b 00                	mov    (%eax),%eax
80104c8f:	85 c0                	test   %eax,%eax
80104c91:	74 11                	je     80104ca4 <pipealloc+0x132>
    fileclose(*f0);
80104c93:	8b 45 08             	mov    0x8(%ebp),%eax
80104c96:	8b 00                	mov    (%eax),%eax
80104c98:	83 ec 0c             	sub    $0xc,%esp
80104c9b:	50                   	push   %eax
80104c9c:	e8 08 c4 ff ff       	call   801010a9 <fileclose>
80104ca1:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ca7:	8b 00                	mov    (%eax),%eax
80104ca9:	85 c0                	test   %eax,%eax
80104cab:	74 11                	je     80104cbe <pipealloc+0x14c>
    fileclose(*f1);
80104cad:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb0:	8b 00                	mov    (%eax),%eax
80104cb2:	83 ec 0c             	sub    $0xc,%esp
80104cb5:	50                   	push   %eax
80104cb6:	e8 ee c3 ff ff       	call   801010a9 <fileclose>
80104cbb:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cc3:	c9                   	leave  
80104cc4:	c3                   	ret    

80104cc5 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104cc5:	55                   	push   %ebp
80104cc6:	89 e5                	mov    %esp,%ebp
80104cc8:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cce:	83 ec 0c             	sub    $0xc,%esp
80104cd1:	50                   	push   %eax
80104cd2:	e8 a9 0e 00 00       	call   80105b80 <acquire>
80104cd7:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104cda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104cde:	74 23                	je     80104d03 <pipeclose+0x3e>
    p->writeopen = 0;
80104ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce3:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104cea:	00 00 00 
    wakeup(&p->nread);
80104ced:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf0:	05 34 02 00 00       	add    $0x234,%eax
80104cf5:	83 ec 0c             	sub    $0xc,%esp
80104cf8:	50                   	push   %eax
80104cf9:	e8 74 0c 00 00       	call   80105972 <wakeup>
80104cfe:	83 c4 10             	add    $0x10,%esp
80104d01:	eb 21                	jmp    80104d24 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104d03:	8b 45 08             	mov    0x8(%ebp),%eax
80104d06:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104d0d:	00 00 00 
    wakeup(&p->nwrite);
80104d10:	8b 45 08             	mov    0x8(%ebp),%eax
80104d13:	05 38 02 00 00       	add    $0x238,%eax
80104d18:	83 ec 0c             	sub    $0xc,%esp
80104d1b:	50                   	push   %eax
80104d1c:	e8 51 0c 00 00       	call   80105972 <wakeup>
80104d21:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104d24:	8b 45 08             	mov    0x8(%ebp),%eax
80104d27:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d2d:	85 c0                	test   %eax,%eax
80104d2f:	75 2c                	jne    80104d5d <pipeclose+0x98>
80104d31:	8b 45 08             	mov    0x8(%ebp),%eax
80104d34:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d3a:	85 c0                	test   %eax,%eax
80104d3c:	75 1f                	jne    80104d5d <pipeclose+0x98>
    release(&p->lock);
80104d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d41:	83 ec 0c             	sub    $0xc,%esp
80104d44:	50                   	push   %eax
80104d45:	e8 9d 0e 00 00       	call   80105be7 <release>
80104d4a:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d4d:	83 ec 0c             	sub    $0xc,%esp
80104d50:	ff 75 08             	pushl  0x8(%ebp)
80104d53:	e8 76 e6 ff ff       	call   801033ce <kfree>
80104d58:	83 c4 10             	add    $0x10,%esp
80104d5b:	eb 0f                	jmp    80104d6c <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d60:	83 ec 0c             	sub    $0xc,%esp
80104d63:	50                   	push   %eax
80104d64:	e8 7e 0e 00 00       	call   80105be7 <release>
80104d69:	83 c4 10             	add    $0x10,%esp
}
80104d6c:	90                   	nop
80104d6d:	c9                   	leave  
80104d6e:	c3                   	ret    

80104d6f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d6f:	55                   	push   %ebp
80104d70:	89 e5                	mov    %esp,%ebp
80104d72:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d75:	8b 45 08             	mov    0x8(%ebp),%eax
80104d78:	83 ec 0c             	sub    $0xc,%esp
80104d7b:	50                   	push   %eax
80104d7c:	e8 ff 0d 00 00       	call   80105b80 <acquire>
80104d81:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d8b:	e9 ad 00 00 00       	jmp    80104e3d <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104d90:	8b 45 08             	mov    0x8(%ebp),%eax
80104d93:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d99:	85 c0                	test   %eax,%eax
80104d9b:	74 0d                	je     80104daa <pipewrite+0x3b>
80104d9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da3:	8b 40 24             	mov    0x24(%eax),%eax
80104da6:	85 c0                	test   %eax,%eax
80104da8:	74 19                	je     80104dc3 <pipewrite+0x54>
        release(&p->lock);
80104daa:	8b 45 08             	mov    0x8(%ebp),%eax
80104dad:	83 ec 0c             	sub    $0xc,%esp
80104db0:	50                   	push   %eax
80104db1:	e8 31 0e 00 00       	call   80105be7 <release>
80104db6:	83 c4 10             	add    $0x10,%esp
        return -1;
80104db9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dbe:	e9 a8 00 00 00       	jmp    80104e6b <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc6:	05 34 02 00 00       	add    $0x234,%eax
80104dcb:	83 ec 0c             	sub    $0xc,%esp
80104dce:	50                   	push   %eax
80104dcf:	e8 9e 0b 00 00       	call   80105972 <wakeup>
80104dd4:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dda:	8b 55 08             	mov    0x8(%ebp),%edx
80104ddd:	81 c2 38 02 00 00    	add    $0x238,%edx
80104de3:	83 ec 08             	sub    $0x8,%esp
80104de6:	50                   	push   %eax
80104de7:	52                   	push   %edx
80104de8:	e8 9a 0a 00 00       	call   80105887 <sleep>
80104ded:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104df0:	8b 45 08             	mov    0x8(%ebp),%eax
80104df3:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104df9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfc:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104e02:	05 00 02 00 00       	add    $0x200,%eax
80104e07:	39 c2                	cmp    %eax,%edx
80104e09:	74 85                	je     80104d90 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e14:	8d 48 01             	lea    0x1(%eax),%ecx
80104e17:	8b 55 08             	mov    0x8(%ebp),%edx
80104e1a:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104e20:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e25:	89 c1                	mov    %eax,%ecx
80104e27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2d:	01 d0                	add    %edx,%eax
80104e2f:	0f b6 10             	movzbl (%eax),%edx
80104e32:	8b 45 08             	mov    0x8(%ebp),%eax
80104e35:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e40:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e43:	7c ab                	jl     80104df0 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e45:	8b 45 08             	mov    0x8(%ebp),%eax
80104e48:	05 34 02 00 00       	add    $0x234,%eax
80104e4d:	83 ec 0c             	sub    $0xc,%esp
80104e50:	50                   	push   %eax
80104e51:	e8 1c 0b 00 00       	call   80105972 <wakeup>
80104e56:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e59:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5c:	83 ec 0c             	sub    $0xc,%esp
80104e5f:	50                   	push   %eax
80104e60:	e8 82 0d 00 00       	call   80105be7 <release>
80104e65:	83 c4 10             	add    $0x10,%esp
  return n;
80104e68:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e6b:	c9                   	leave  
80104e6c:	c3                   	ret    

80104e6d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e6d:	55                   	push   %ebp
80104e6e:	89 e5                	mov    %esp,%ebp
80104e70:	53                   	push   %ebx
80104e71:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e74:	8b 45 08             	mov    0x8(%ebp),%eax
80104e77:	83 ec 0c             	sub    $0xc,%esp
80104e7a:	50                   	push   %eax
80104e7b:	e8 00 0d 00 00       	call   80105b80 <acquire>
80104e80:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e83:	eb 3f                	jmp    80104ec4 <piperead+0x57>
    if(proc->killed){
80104e85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e8b:	8b 40 24             	mov    0x24(%eax),%eax
80104e8e:	85 c0                	test   %eax,%eax
80104e90:	74 19                	je     80104eab <piperead+0x3e>
      release(&p->lock);
80104e92:	8b 45 08             	mov    0x8(%ebp),%eax
80104e95:	83 ec 0c             	sub    $0xc,%esp
80104e98:	50                   	push   %eax
80104e99:	e8 49 0d 00 00       	call   80105be7 <release>
80104e9e:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ea1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ea6:	e9 bf 00 00 00       	jmp    80104f6a <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104eab:	8b 45 08             	mov    0x8(%ebp),%eax
80104eae:	8b 55 08             	mov    0x8(%ebp),%edx
80104eb1:	81 c2 34 02 00 00    	add    $0x234,%edx
80104eb7:	83 ec 08             	sub    $0x8,%esp
80104eba:	50                   	push   %eax
80104ebb:	52                   	push   %edx
80104ebc:	e8 c6 09 00 00       	call   80105887 <sleep>
80104ec1:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ed6:	39 c2                	cmp    %eax,%edx
80104ed8:	75 0d                	jne    80104ee7 <piperead+0x7a>
80104eda:	8b 45 08             	mov    0x8(%ebp),%eax
80104edd:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ee3:	85 c0                	test   %eax,%eax
80104ee5:	75 9e                	jne    80104e85 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ee7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104eee:	eb 49                	jmp    80104f39 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef3:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80104efc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104f02:	39 c2                	cmp    %eax,%edx
80104f04:	74 3d                	je     80104f43 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104f06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f09:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f0c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f12:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104f18:	8d 48 01             	lea    0x1(%eax),%ecx
80104f1b:	8b 55 08             	mov    0x8(%ebp),%edx
80104f1e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104f24:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f29:	89 c2                	mov    %eax,%edx
80104f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2e:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f33:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3c:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f3f:	7c af                	jl     80104ef0 <piperead+0x83>
80104f41:	eb 01                	jmp    80104f44 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f43:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	05 38 02 00 00       	add    $0x238,%eax
80104f4c:	83 ec 0c             	sub    $0xc,%esp
80104f4f:	50                   	push   %eax
80104f50:	e8 1d 0a 00 00       	call   80105972 <wakeup>
80104f55:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f58:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5b:	83 ec 0c             	sub    $0xc,%esp
80104f5e:	50                   	push   %eax
80104f5f:	e8 83 0c 00 00       	call   80105be7 <release>
80104f64:	83 c4 10             	add    $0x10,%esp
  return i;
80104f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f6d:	c9                   	leave  
80104f6e:	c3                   	ret    

80104f6f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
80104f72:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f75:	9c                   	pushf  
80104f76:	58                   	pop    %eax
80104f77:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f7d:	c9                   	leave  
80104f7e:	c3                   	ret    

80104f7f <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f7f:	55                   	push   %ebp
80104f80:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f82:	fb                   	sti    
}
80104f83:	90                   	nop
80104f84:	5d                   	pop    %ebp
80104f85:	c3                   	ret    

80104f86 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f86:	55                   	push   %ebp
80104f87:	89 e5                	mov    %esp,%ebp
80104f89:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104f8c:	83 ec 08             	sub    $0x8,%esp
80104f8f:	68 cd 97 10 80       	push   $0x801097cd
80104f94:	68 80 3e 11 80       	push   $0x80113e80
80104f99:	e8 c0 0b 00 00       	call   80105b5e <initlock>
80104f9e:	83 c4 10             	add    $0x10,%esp
}
80104fa1:	90                   	nop
80104fa2:	c9                   	leave  
80104fa3:	c3                   	ret    

80104fa4 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104faa:	83 ec 0c             	sub    $0xc,%esp
80104fad:	68 80 3e 11 80       	push   $0x80113e80
80104fb2:	e8 c9 0b 00 00       	call   80105b80 <acquire>
80104fb7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fba:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104fc1:	eb 0e                	jmp    80104fd1 <allocproc+0x2d>
    if(p->state == UNUSED)
80104fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc6:	8b 40 0c             	mov    0xc(%eax),%eax
80104fc9:	85 c0                	test   %eax,%eax
80104fcb:	74 27                	je     80104ff4 <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fcd:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fd1:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fd8:	72 e9                	jb     80104fc3 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104fda:	83 ec 0c             	sub    $0xc,%esp
80104fdd:	68 80 3e 11 80       	push   $0x80113e80
80104fe2:	e8 00 0c 00 00       	call   80105be7 <release>
80104fe7:	83 c4 10             	add    $0x10,%esp
  return 0;
80104fea:	b8 00 00 00 00       	mov    $0x0,%eax
80104fef:	e9 b4 00 00 00       	jmp    801050a8 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104ff4:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104fff:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80105004:	8d 50 01             	lea    0x1(%eax),%edx
80105007:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
8010500d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105010:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80105013:	83 ec 0c             	sub    $0xc,%esp
80105016:	68 80 3e 11 80       	push   $0x80113e80
8010501b:	e8 c7 0b 00 00       	call   80105be7 <release>
80105020:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80105023:	e8 43 e4 ff ff       	call   8010346b <kalloc>
80105028:	89 c2                	mov    %eax,%edx
8010502a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502d:	89 50 08             	mov    %edx,0x8(%eax)
80105030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105033:	8b 40 08             	mov    0x8(%eax),%eax
80105036:	85 c0                	test   %eax,%eax
80105038:	75 11                	jne    8010504b <allocproc+0xa7>
    p->state = UNUSED;
8010503a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80105044:	b8 00 00 00 00       	mov    $0x0,%eax
80105049:	eb 5d                	jmp    801050a8 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
8010504b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504e:	8b 40 08             	mov    0x8(%eax),%eax
80105051:	05 00 10 00 00       	add    $0x1000,%eax
80105056:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105059:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010505d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105060:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105063:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80105066:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010506a:	ba fa 74 10 80       	mov    $0x801074fa,%edx
8010506f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105072:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80105074:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80105078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010507e:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80105081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105084:	8b 40 1c             	mov    0x1c(%eax),%eax
80105087:	83 ec 04             	sub    $0x4,%esp
8010508a:	6a 14                	push   $0x14
8010508c:	6a 00                	push   $0x0
8010508e:	50                   	push   %eax
8010508f:	e8 4f 0d 00 00       	call   80105de3 <memset>
80105094:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80105097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010509d:	ba 1d 58 10 80       	mov    $0x8010581d,%edx
801050a2:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801050a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801050a8:	c9                   	leave  
801050a9:	c3                   	ret    

801050aa <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801050aa:	55                   	push   %ebp
801050ab:	89 e5                	mov    %esp,%ebp
801050ad:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801050b0:	e8 ef fe ff ff       	call   80104fa4 <allocproc>
801050b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801050b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bb:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801050c0:	e8 fa 3a 00 00       	call   80108bbf <setupkvm>
801050c5:	89 c2                	mov    %eax,%edx
801050c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ca:	89 50 04             	mov    %edx,0x4(%eax)
801050cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d0:	8b 40 04             	mov    0x4(%eax),%eax
801050d3:	85 c0                	test   %eax,%eax
801050d5:	75 0d                	jne    801050e4 <userinit+0x3a>
    panic("userinit: out of memory?");
801050d7:	83 ec 0c             	sub    $0xc,%esp
801050da:	68 d4 97 10 80       	push   $0x801097d4
801050df:	e8 82 b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050e4:	ba 2c 00 00 00       	mov    $0x2c,%edx
801050e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ec:	8b 40 04             	mov    0x4(%eax),%eax
801050ef:	83 ec 04             	sub    $0x4,%esp
801050f2:	52                   	push   %edx
801050f3:	68 e0 c4 10 80       	push   $0x8010c4e0
801050f8:	50                   	push   %eax
801050f9:	e8 1b 3d 00 00       	call   80108e19 <inituvm>
801050fe:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105104:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010510a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510d:	8b 40 18             	mov    0x18(%eax),%eax
80105110:	83 ec 04             	sub    $0x4,%esp
80105113:	6a 4c                	push   $0x4c
80105115:	6a 00                	push   $0x0
80105117:	50                   	push   %eax
80105118:	e8 c6 0c 00 00       	call   80105de3 <memset>
8010511d:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80105120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105123:	8b 40 18             	mov    0x18(%eax),%eax
80105126:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512f:	8b 40 18             	mov    0x18(%eax),%eax
80105132:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80105138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513b:	8b 40 18             	mov    0x18(%eax),%eax
8010513e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105141:	8b 52 18             	mov    0x18(%edx),%edx
80105144:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105148:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010514c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514f:	8b 40 18             	mov    0x18(%eax),%eax
80105152:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105155:	8b 52 18             	mov    0x18(%edx),%edx
80105158:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010515c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80105160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105163:	8b 40 18             	mov    0x18(%eax),%eax
80105166:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010516d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105170:	8b 40 18             	mov    0x18(%eax),%eax
80105173:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010517a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517d:	8b 40 18             	mov    0x18(%eax),%eax
80105180:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518a:	83 c0 6c             	add    $0x6c,%eax
8010518d:	83 ec 04             	sub    $0x4,%esp
80105190:	6a 10                	push   $0x10
80105192:	68 ed 97 10 80       	push   $0x801097ed
80105197:	50                   	push   %eax
80105198:	e8 49 0e 00 00       	call   80105fe6 <safestrcpy>
8010519d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801051a0:	83 ec 0c             	sub    $0xc,%esp
801051a3:	68 f6 97 10 80       	push   $0x801097f6
801051a8:	e8 57 db ff ff       	call   80102d04 <namei>
801051ad:	83 c4 10             	add    $0x10,%esp
801051b0:	89 c2                	mov    %eax,%edx
801051b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b5:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
801051b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801051c2:	90                   	nop
801051c3:	c9                   	leave  
801051c4:	c3                   	ret    

801051c5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801051c5:	55                   	push   %ebp
801051c6:	89 e5                	mov    %esp,%ebp
801051c8:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d1:	8b 00                	mov    (%eax),%eax
801051d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051da:	7e 31                	jle    8010520d <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051dc:	8b 55 08             	mov    0x8(%ebp),%edx
801051df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e2:	01 c2                	add    %eax,%edx
801051e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ea:	8b 40 04             	mov    0x4(%eax),%eax
801051ed:	83 ec 04             	sub    $0x4,%esp
801051f0:	52                   	push   %edx
801051f1:	ff 75 f4             	pushl  -0xc(%ebp)
801051f4:	50                   	push   %eax
801051f5:	e8 6c 3d 00 00       	call   80108f66 <allocuvm>
801051fa:	83 c4 10             	add    $0x10,%esp
801051fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105200:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105204:	75 3e                	jne    80105244 <growproc+0x7f>
      return -1;
80105206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520b:	eb 59                	jmp    80105266 <growproc+0xa1>
  } else if(n < 0){
8010520d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105211:	79 31                	jns    80105244 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80105213:	8b 55 08             	mov    0x8(%ebp),%edx
80105216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105219:	01 c2                	add    %eax,%edx
8010521b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105221:	8b 40 04             	mov    0x4(%eax),%eax
80105224:	83 ec 04             	sub    $0x4,%esp
80105227:	52                   	push   %edx
80105228:	ff 75 f4             	pushl  -0xc(%ebp)
8010522b:	50                   	push   %eax
8010522c:	e8 fe 3d 00 00       	call   8010902f <deallocuvm>
80105231:	83 c4 10             	add    $0x10,%esp
80105234:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105237:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010523b:	75 07                	jne    80105244 <growproc+0x7f>
      return -1;
8010523d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105242:	eb 22                	jmp    80105266 <growproc+0xa1>
  }
  proc->sz = sz;
80105244:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010524a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010524d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010524f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105255:	83 ec 0c             	sub    $0xc,%esp
80105258:	50                   	push   %eax
80105259:	e8 48 3a 00 00       	call   80108ca6 <switchuvm>
8010525e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105261:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105266:	c9                   	leave  
80105267:	c3                   	ret    

80105268 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80105268:	55                   	push   %ebp
80105269:	89 e5                	mov    %esp,%ebp
8010526b:	57                   	push   %edi
8010526c:	56                   	push   %esi
8010526d:	53                   	push   %ebx
8010526e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80105271:	e8 2e fd ff ff       	call   80104fa4 <allocproc>
80105276:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105279:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010527d:	75 0a                	jne    80105289 <fork+0x21>
    return -1;
8010527f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105284:	e9 68 01 00 00       	jmp    801053f1 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80105289:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528f:	8b 10                	mov    (%eax),%edx
80105291:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105297:	8b 40 04             	mov    0x4(%eax),%eax
8010529a:	83 ec 08             	sub    $0x8,%esp
8010529d:	52                   	push   %edx
8010529e:	50                   	push   %eax
8010529f:	e8 29 3f 00 00       	call   801091cd <copyuvm>
801052a4:	83 c4 10             	add    $0x10,%esp
801052a7:	89 c2                	mov    %eax,%edx
801052a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052ac:	89 50 04             	mov    %edx,0x4(%eax)
801052af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052b2:	8b 40 04             	mov    0x4(%eax),%eax
801052b5:	85 c0                	test   %eax,%eax
801052b7:	75 30                	jne    801052e9 <fork+0x81>
    kfree(np->kstack);
801052b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052bc:	8b 40 08             	mov    0x8(%eax),%eax
801052bf:	83 ec 0c             	sub    $0xc,%esp
801052c2:	50                   	push   %eax
801052c3:	e8 06 e1 ff ff       	call   801033ce <kfree>
801052c8:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052d8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e4:	e9 08 01 00 00       	jmp    801053f1 <fork+0x189>
  }
  np->sz = proc->sz;
801052e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ef:	8b 10                	mov    (%eax),%edx
801052f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052f4:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801052f6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105300:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80105303:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105306:	8b 50 18             	mov    0x18(%eax),%edx
80105309:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010530f:	8b 40 18             	mov    0x18(%eax),%eax
80105312:	89 c3                	mov    %eax,%ebx
80105314:	b8 13 00 00 00       	mov    $0x13,%eax
80105319:	89 d7                	mov    %edx,%edi
8010531b:	89 de                	mov    %ebx,%esi
8010531d:	89 c1                	mov    %eax,%ecx
8010531f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105321:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105324:	8b 40 18             	mov    0x18(%eax),%eax
80105327:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010532e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105335:	eb 43                	jmp    8010537a <fork+0x112>
    if(proc->ofile[i])
80105337:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105340:	83 c2 08             	add    $0x8,%edx
80105343:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105347:	85 c0                	test   %eax,%eax
80105349:	74 2b                	je     80105376 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
8010534b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105354:	83 c2 08             	add    $0x8,%edx
80105357:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010535b:	83 ec 0c             	sub    $0xc,%esp
8010535e:	50                   	push   %eax
8010535f:	e8 f4 bc ff ff       	call   80101058 <filedup>
80105364:	83 c4 10             	add    $0x10,%esp
80105367:	89 c1                	mov    %eax,%ecx
80105369:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010536c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010536f:	83 c2 08             	add    $0x8,%edx
80105372:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105376:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010537a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010537e:	7e b7                	jle    80105337 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105380:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105386:	8b 40 68             	mov    0x68(%eax),%eax
80105389:	83 ec 0c             	sub    $0xc,%esp
8010538c:	50                   	push   %eax
8010538d:	e8 16 cb ff ff       	call   80101ea8 <idup>
80105392:	83 c4 10             	add    $0x10,%esp
80105395:	89 c2                	mov    %eax,%edx
80105397:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010539a:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010539d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a3:	8d 50 6c             	lea    0x6c(%eax),%edx
801053a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053a9:	83 c0 6c             	add    $0x6c,%eax
801053ac:	83 ec 04             	sub    $0x4,%esp
801053af:	6a 10                	push   $0x10
801053b1:	52                   	push   %edx
801053b2:	50                   	push   %eax
801053b3:	e8 2e 0c 00 00       	call   80105fe6 <safestrcpy>
801053b8:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053be:	8b 40 10             	mov    0x10(%eax),%eax
801053c1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053c4:	83 ec 0c             	sub    $0xc,%esp
801053c7:	68 80 3e 11 80       	push   $0x80113e80
801053cc:	e8 af 07 00 00       	call   80105b80 <acquire>
801053d1:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053d7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053de:	83 ec 0c             	sub    $0xc,%esp
801053e1:	68 80 3e 11 80       	push   $0x80113e80
801053e6:	e8 fc 07 00 00       	call   80105be7 <release>
801053eb:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801053ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801053f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053f4:	5b                   	pop    %ebx
801053f5:	5e                   	pop    %esi
801053f6:	5f                   	pop    %edi
801053f7:	5d                   	pop    %ebp
801053f8:	c3                   	ret    

801053f9 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801053f9:	55                   	push   %ebp
801053fa:	89 e5                	mov    %esp,%ebp
801053fc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801053ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105406:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010540b:	39 c2                	cmp    %eax,%edx
8010540d:	75 0d                	jne    8010541c <exit+0x23>
    panic("init exiting");
8010540f:	83 ec 0c             	sub    $0xc,%esp
80105412:	68 f8 97 10 80       	push   $0x801097f8
80105417:	e8 4a b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010541c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105423:	eb 48                	jmp    8010546d <exit+0x74>
    if(proc->ofile[fd]){
80105425:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010542e:	83 c2 08             	add    $0x8,%edx
80105431:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105435:	85 c0                	test   %eax,%eax
80105437:	74 30                	je     80105469 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105439:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105442:	83 c2 08             	add    $0x8,%edx
80105445:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105449:	83 ec 0c             	sub    $0xc,%esp
8010544c:	50                   	push   %eax
8010544d:	e8 57 bc ff ff       	call   801010a9 <fileclose>
80105452:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80105455:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010545b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010545e:	83 c2 08             	add    $0x8,%edx
80105461:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105468:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105469:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010546d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105471:	7e b2                	jle    80105425 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
80105473:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105479:	8b 40 68             	mov    0x68(%eax),%eax
8010547c:	8b 40 50             	mov    0x50(%eax),%eax
8010547f:	8b 40 14             	mov    0x14(%eax),%eax
80105482:	83 ec 0c             	sub    $0xc,%esp
80105485:	50                   	push   %eax
80105486:	e8 17 ea ff ff       	call   80103ea2 <begin_op>
8010548b:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
8010548e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105494:	8b 40 68             	mov    0x68(%eax),%eax
80105497:	83 ec 0c             	sub    $0xc,%esp
8010549a:	50                   	push   %eax
8010549b:	e8 55 cc ff ff       	call   801020f5 <iput>
801054a0:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
801054a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a9:	8b 40 68             	mov    0x68(%eax),%eax
801054ac:	8b 40 50             	mov    0x50(%eax),%eax
801054af:	8b 40 14             	mov    0x14(%eax),%eax
801054b2:	83 ec 0c             	sub    $0xc,%esp
801054b5:	50                   	push   %eax
801054b6:	e8 ee ea ff ff       	call   80103fa9 <end_op>
801054bb:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
801054be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c4:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054cb:	83 ec 0c             	sub    $0xc,%esp
801054ce:	68 80 3e 11 80       	push   $0x80113e80
801054d3:	e8 a8 06 00 00       	call   80105b80 <acquire>
801054d8:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e1:	8b 40 14             	mov    0x14(%eax),%eax
801054e4:	83 ec 0c             	sub    $0xc,%esp
801054e7:	50                   	push   %eax
801054e8:	e8 46 04 00 00       	call   80105933 <wakeup1>
801054ed:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054f0:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801054f7:	eb 3c                	jmp    80105535 <exit+0x13c>
    if(p->parent == proc){
801054f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054fc:	8b 50 14             	mov    0x14(%eax),%edx
801054ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105505:	39 c2                	cmp    %eax,%edx
80105507:	75 28                	jne    80105531 <exit+0x138>
      p->parent = initproc;
80105509:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
8010550f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105512:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105518:	8b 40 0c             	mov    0xc(%eax),%eax
8010551b:	83 f8 05             	cmp    $0x5,%eax
8010551e:	75 11                	jne    80105531 <exit+0x138>
        wakeup1(initproc);
80105520:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105525:	83 ec 0c             	sub    $0xc,%esp
80105528:	50                   	push   %eax
80105529:	e8 05 04 00 00       	call   80105933 <wakeup1>
8010552e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105531:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105535:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010553c:	72 bb                	jb     801054f9 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010553e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105544:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010554b:	e8 d6 01 00 00       	call   80105726 <sched>
  panic("zombie exit");
80105550:	83 ec 0c             	sub    $0xc,%esp
80105553:	68 05 98 10 80       	push   $0x80109805
80105558:	e8 09 b0 ff ff       	call   80100566 <panic>

8010555d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010555d:	55                   	push   %ebp
8010555e:	89 e5                	mov    %esp,%ebp
80105560:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105563:	83 ec 0c             	sub    $0xc,%esp
80105566:	68 80 3e 11 80       	push   $0x80113e80
8010556b:	e8 10 06 00 00       	call   80105b80 <acquire>
80105570:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105573:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010557a:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105581:	e9 a6 00 00 00       	jmp    8010562c <wait+0xcf>
      if(p->parent != proc)
80105586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105589:	8b 50 14             	mov    0x14(%eax),%edx
8010558c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105592:	39 c2                	cmp    %eax,%edx
80105594:	0f 85 8d 00 00 00    	jne    80105627 <wait+0xca>
        continue;
      havekids = 1;
8010559a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a4:	8b 40 0c             	mov    0xc(%eax),%eax
801055a7:	83 f8 05             	cmp    $0x5,%eax
801055aa:	75 7c                	jne    80105628 <wait+0xcb>
        // Found one.
        pid = p->pid;
801055ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055af:	8b 40 10             	mov    0x10(%eax),%eax
801055b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b8:	8b 40 08             	mov    0x8(%eax),%eax
801055bb:	83 ec 0c             	sub    $0xc,%esp
801055be:	50                   	push   %eax
801055bf:	e8 0a de ff ff       	call   801033ce <kfree>
801055c4:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	8b 40 04             	mov    0x4(%eax),%eax
801055d7:	83 ec 0c             	sub    $0xc,%esp
801055da:	50                   	push   %eax
801055db:	e8 0c 3b 00 00       	call   801090ec <freevm>
801055e0:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801055ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801055f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fa:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105604:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105612:	83 ec 0c             	sub    $0xc,%esp
80105615:	68 80 3e 11 80       	push   $0x80113e80
8010561a:	e8 c8 05 00 00       	call   80105be7 <release>
8010561f:	83 c4 10             	add    $0x10,%esp
        return pid;
80105622:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105625:	eb 58                	jmp    8010567f <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105627:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105628:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010562c:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105633:	0f 82 4d ff ff ff    	jb     80105586 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105639:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010563d:	74 0d                	je     8010564c <wait+0xef>
8010563f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105645:	8b 40 24             	mov    0x24(%eax),%eax
80105648:	85 c0                	test   %eax,%eax
8010564a:	74 17                	je     80105663 <wait+0x106>
      release(&ptable.lock);
8010564c:	83 ec 0c             	sub    $0xc,%esp
8010564f:	68 80 3e 11 80       	push   $0x80113e80
80105654:	e8 8e 05 00 00       	call   80105be7 <release>
80105659:	83 c4 10             	add    $0x10,%esp
      return -1;
8010565c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105661:	eb 1c                	jmp    8010567f <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105663:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105669:	83 ec 08             	sub    $0x8,%esp
8010566c:	68 80 3e 11 80       	push   $0x80113e80
80105671:	50                   	push   %eax
80105672:	e8 10 02 00 00       	call   80105887 <sleep>
80105677:	83 c4 10             	add    $0x10,%esp
  }
8010567a:	e9 f4 fe ff ff       	jmp    80105573 <wait+0x16>
}
8010567f:	c9                   	leave  
80105680:	c3                   	ret    

80105681 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105681:	55                   	push   %ebp
80105682:	89 e5                	mov    %esp,%ebp
80105684:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105687:	e8 f3 f8 ff ff       	call   80104f7f <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010568c:	83 ec 0c             	sub    $0xc,%esp
8010568f:	68 80 3e 11 80       	push   $0x80113e80
80105694:	e8 e7 04 00 00       	call   80105b80 <acquire>
80105699:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010569c:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801056a3:	eb 63                	jmp    80105708 <scheduler+0x87>
      if(p->state != RUNNABLE)
801056a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a8:	8b 40 0c             	mov    0xc(%eax),%eax
801056ab:	83 f8 03             	cmp    $0x3,%eax
801056ae:	75 53                	jne    80105703 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b3:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056b9:	83 ec 0c             	sub    $0xc,%esp
801056bc:	ff 75 f4             	pushl  -0xc(%ebp)
801056bf:	e8 e2 35 00 00       	call   80108ca6 <switchuvm>
801056c4:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ca:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d7:	8b 40 1c             	mov    0x1c(%eax),%eax
801056da:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056e1:	83 c2 04             	add    $0x4,%edx
801056e4:	83 ec 08             	sub    $0x8,%esp
801056e7:	50                   	push   %eax
801056e8:	52                   	push   %edx
801056e9:	e8 69 09 00 00       	call   80106057 <swtch>
801056ee:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801056f1:	e8 93 35 00 00       	call   80108c89 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801056f6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801056fd:	00 00 00 00 
80105701:	eb 01                	jmp    80105704 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105703:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105704:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105708:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010570f:	72 94                	jb     801056a5 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105711:	83 ec 0c             	sub    $0xc,%esp
80105714:	68 80 3e 11 80       	push   $0x80113e80
80105719:	e8 c9 04 00 00       	call   80105be7 <release>
8010571e:	83 c4 10             	add    $0x10,%esp

  }
80105721:	e9 61 ff ff ff       	jmp    80105687 <scheduler+0x6>

80105726 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105726:	55                   	push   %ebp
80105727:	89 e5                	mov    %esp,%ebp
80105729:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010572c:	83 ec 0c             	sub    $0xc,%esp
8010572f:	68 80 3e 11 80       	push   $0x80113e80
80105734:	e8 7a 05 00 00       	call   80105cb3 <holding>
80105739:	83 c4 10             	add    $0x10,%esp
8010573c:	85 c0                	test   %eax,%eax
8010573e:	75 0d                	jne    8010574d <sched+0x27>
    panic("sched ptable.lock");
80105740:	83 ec 0c             	sub    $0xc,%esp
80105743:	68 11 98 10 80       	push   $0x80109811
80105748:	e8 19 ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010574d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105753:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105759:	83 f8 01             	cmp    $0x1,%eax
8010575c:	74 0d                	je     8010576b <sched+0x45>
   panic("sched locks");
8010575e:	83 ec 0c             	sub    $0xc,%esp
80105761:	68 23 98 10 80       	push   $0x80109823
80105766:	e8 fb ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010576b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105771:	8b 40 0c             	mov    0xc(%eax),%eax
80105774:	83 f8 04             	cmp    $0x4,%eax
80105777:	75 0d                	jne    80105786 <sched+0x60>
    panic("sched running");
80105779:	83 ec 0c             	sub    $0xc,%esp
8010577c:	68 2f 98 10 80       	push   $0x8010982f
80105781:	e8 e0 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105786:	e8 e4 f7 ff ff       	call   80104f6f <readeflags>
8010578b:	25 00 02 00 00       	and    $0x200,%eax
80105790:	85 c0                	test   %eax,%eax
80105792:	74 0d                	je     801057a1 <sched+0x7b>
    panic("sched interruptible");
80105794:	83 ec 0c             	sub    $0xc,%esp
80105797:	68 3d 98 10 80       	push   $0x8010983d
8010579c:	e8 c5 ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057a1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057a7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057b0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057b6:	8b 40 04             	mov    0x4(%eax),%eax
801057b9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057c0:	83 c2 1c             	add    $0x1c,%edx
801057c3:	83 ec 08             	sub    $0x8,%esp
801057c6:	50                   	push   %eax
801057c7:	52                   	push   %edx
801057c8:	e8 8a 08 00 00       	call   80106057 <swtch>
801057cd:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057d0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057d9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057df:	90                   	nop
801057e0:	c9                   	leave  
801057e1:	c3                   	ret    

801057e2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057e2:	55                   	push   %ebp
801057e3:	89 e5                	mov    %esp,%ebp
801057e5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057e8:	83 ec 0c             	sub    $0xc,%esp
801057eb:	68 80 3e 11 80       	push   $0x80113e80
801057f0:	e8 8b 03 00 00       	call   80105b80 <acquire>
801057f5:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801057f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057fe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105805:	e8 1c ff ff ff       	call   80105726 <sched>
  release(&ptable.lock);
8010580a:	83 ec 0c             	sub    $0xc,%esp
8010580d:	68 80 3e 11 80       	push   $0x80113e80
80105812:	e8 d0 03 00 00       	call   80105be7 <release>
80105817:	83 c4 10             	add    $0x10,%esp
}
8010581a:	90                   	nop
8010581b:	c9                   	leave  
8010581c:	c3                   	ret    

8010581d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010581d:	55                   	push   %ebp
8010581e:	89 e5                	mov    %esp,%ebp
80105820:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105823:	83 ec 0c             	sub    $0xc,%esp
80105826:	68 80 3e 11 80       	push   $0x80113e80
8010582b:	e8 b7 03 00 00       	call   80105be7 <release>
80105830:	83 c4 10             	add    $0x10,%esp


  if (first) {
80105833:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105838:	85 c0                	test   %eax,%eax
8010583a:	74 48                	je     80105884 <forkret+0x67>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010583c:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105843:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
80105846:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010584c:	0f b6 00             	movzbl (%eax),%eax
8010584f:	0f b6 c0             	movzbl %al,%eax
80105852:	83 ec 08             	sub    $0x8,%esp
80105855:	50                   	push   %eax
80105856:	68 51 98 10 80       	push   $0x80109851
8010585b:	e8 66 ab ff ff       	call   801003c6 <cprintf>
80105860:	83 c4 10             	add    $0x10,%esp
iinit(proc,ROOTDEV);
80105863:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105869:	83 ec 08             	sub    $0x8,%esp
8010586c:	6a 01                	push   $0x1
8010586e:	50                   	push   %eax
8010586f:	e8 be c1 ff ff       	call   80101a32 <iinit>
80105874:	83 c4 10             	add    $0x10,%esp
    // iinitDone=1;
   // cprintf("boot from after iinit is %d \n",bootfrom);
    initlog(ROOTDEV);
80105877:	83 ec 0c             	sub    $0xc,%esp
8010587a:	6a 01                	push   $0x1
8010587c:	e8 b3 e2 ff ff       	call   80103b34 <initlog>
80105881:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
80105884:	90                   	nop
80105885:	c9                   	leave  
80105886:	c3                   	ret    

80105887 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105887:	55                   	push   %ebp
80105888:	89 e5                	mov    %esp,%ebp
8010588a:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010588d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105893:	85 c0                	test   %eax,%eax
80105895:	75 0d                	jne    801058a4 <sleep+0x1d>
    panic("sleep");
80105897:	83 ec 0c             	sub    $0xc,%esp
8010589a:	68 60 98 10 80       	push   $0x80109860
8010589f:	e8 c2 ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058a8:	75 0d                	jne    801058b7 <sleep+0x30>
    panic("sleep without lk");
801058aa:	83 ec 0c             	sub    $0xc,%esp
801058ad:	68 66 98 10 80       	push   $0x80109866
801058b2:	e8 af ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058b7:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058be:	74 1e                	je     801058de <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058c0:	83 ec 0c             	sub    $0xc,%esp
801058c3:	68 80 3e 11 80       	push   $0x80113e80
801058c8:	e8 b3 02 00 00       	call   80105b80 <acquire>
801058cd:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	ff 75 0c             	pushl  0xc(%ebp)
801058d6:	e8 0c 03 00 00       	call   80105be7 <release>
801058db:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e4:	8b 55 08             	mov    0x8(%ebp),%edx
801058e7:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801058f7:	e8 2a fe ff ff       	call   80105726 <sched>

  // Tidy up.
  proc->chan = 0;
801058fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105902:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105909:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
80105910:	74 1e                	je     80105930 <sleep+0xa9>
    release(&ptable.lock);
80105912:	83 ec 0c             	sub    $0xc,%esp
80105915:	68 80 3e 11 80       	push   $0x80113e80
8010591a:	e8 c8 02 00 00       	call   80105be7 <release>
8010591f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105922:	83 ec 0c             	sub    $0xc,%esp
80105925:	ff 75 0c             	pushl  0xc(%ebp)
80105928:	e8 53 02 00 00       	call   80105b80 <acquire>
8010592d:	83 c4 10             	add    $0x10,%esp
  }
}
80105930:	90                   	nop
80105931:	c9                   	leave  
80105932:	c3                   	ret    

80105933 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105933:	55                   	push   %ebp
80105934:	89 e5                	mov    %esp,%ebp
80105936:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105939:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105940:	eb 24                	jmp    80105966 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105942:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105945:	8b 40 0c             	mov    0xc(%eax),%eax
80105948:	83 f8 02             	cmp    $0x2,%eax
8010594b:	75 15                	jne    80105962 <wakeup1+0x2f>
8010594d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105950:	8b 40 20             	mov    0x20(%eax),%eax
80105953:	3b 45 08             	cmp    0x8(%ebp),%eax
80105956:	75 0a                	jne    80105962 <wakeup1+0x2f>
      p->state = RUNNABLE;
80105958:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010595b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105962:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80105966:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
8010596d:	72 d3                	jb     80105942 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010596f:	90                   	nop
80105970:	c9                   	leave  
80105971:	c3                   	ret    

80105972 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105972:	55                   	push   %ebp
80105973:	89 e5                	mov    %esp,%ebp
80105975:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105978:	83 ec 0c             	sub    $0xc,%esp
8010597b:	68 80 3e 11 80       	push   $0x80113e80
80105980:	e8 fb 01 00 00       	call   80105b80 <acquire>
80105985:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105988:	83 ec 0c             	sub    $0xc,%esp
8010598b:	ff 75 08             	pushl  0x8(%ebp)
8010598e:	e8 a0 ff ff ff       	call   80105933 <wakeup1>
80105993:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105996:	83 ec 0c             	sub    $0xc,%esp
80105999:	68 80 3e 11 80       	push   $0x80113e80
8010599e:	e8 44 02 00 00       	call   80105be7 <release>
801059a3:	83 c4 10             	add    $0x10,%esp
}
801059a6:	90                   	nop
801059a7:	c9                   	leave  
801059a8:	c3                   	ret    

801059a9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059a9:	55                   	push   %ebp
801059aa:	89 e5                	mov    %esp,%ebp
801059ac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059af:	83 ec 0c             	sub    $0xc,%esp
801059b2:	68 80 3e 11 80       	push   $0x80113e80
801059b7:	e8 c4 01 00 00       	call   80105b80 <acquire>
801059bc:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059bf:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059c6:	eb 45                	jmp    80105a0d <kill+0x64>
    if(p->pid == pid){
801059c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cb:	8b 40 10             	mov    0x10(%eax),%eax
801059ce:	3b 45 08             	cmp    0x8(%ebp),%eax
801059d1:	75 36                	jne    80105a09 <kill+0x60>
      p->killed = 1;
801059d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e0:	8b 40 0c             	mov    0xc(%eax),%eax
801059e3:	83 f8 02             	cmp    $0x2,%eax
801059e6:	75 0a                	jne    801059f2 <kill+0x49>
        p->state = RUNNABLE;
801059e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059eb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801059f2:	83 ec 0c             	sub    $0xc,%esp
801059f5:	68 80 3e 11 80       	push   $0x80113e80
801059fa:	e8 e8 01 00 00       	call   80105be7 <release>
801059ff:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a02:	b8 00 00 00 00       	mov    $0x0,%eax
80105a07:	eb 22                	jmp    80105a2b <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a09:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105a0d:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105a14:	72 b2                	jb     801059c8 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a16:	83 ec 0c             	sub    $0xc,%esp
80105a19:	68 80 3e 11 80       	push   $0x80113e80
80105a1e:	e8 c4 01 00 00       	call   80105be7 <release>
80105a23:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a2b:	c9                   	leave  
80105a2c:	c3                   	ret    

80105a2d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a2d:	55                   	push   %ebp
80105a2e:	89 e5                	mov    %esp,%ebp
80105a30:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a33:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a3a:	e9 d7 00 00 00       	jmp    80105b16 <procdump+0xe9>
    if(p->state == UNUSED)
80105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a42:	8b 40 0c             	mov    0xc(%eax),%eax
80105a45:	85 c0                	test   %eax,%eax
80105a47:	0f 84 c4 00 00 00    	je     80105b11 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a50:	8b 40 0c             	mov    0xc(%eax),%eax
80105a53:	83 f8 05             	cmp    $0x5,%eax
80105a56:	77 23                	ja     80105a7b <procdump+0x4e>
80105a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5b:	8b 40 0c             	mov    0xc(%eax),%eax
80105a5e:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a65:	85 c0                	test   %eax,%eax
80105a67:	74 12                	je     80105a7b <procdump+0x4e>
      state = states[p->state];
80105a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6c:	8b 40 0c             	mov    0xc(%eax),%eax
80105a6f:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a76:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a79:	eb 07                	jmp    80105a82 <procdump+0x55>
    else
      state = "???";
80105a7b:	c7 45 ec 77 98 10 80 	movl   $0x80109877,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a85:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8b:	8b 40 10             	mov    0x10(%eax),%eax
80105a8e:	52                   	push   %edx
80105a8f:	ff 75 ec             	pushl  -0x14(%ebp)
80105a92:	50                   	push   %eax
80105a93:	68 7b 98 10 80       	push   $0x8010987b
80105a98:	e8 29 a9 ff ff       	call   801003c6 <cprintf>
80105a9d:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa3:	8b 40 0c             	mov    0xc(%eax),%eax
80105aa6:	83 f8 02             	cmp    $0x2,%eax
80105aa9:	75 54                	jne    80105aff <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aae:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab4:	83 c0 08             	add    $0x8,%eax
80105ab7:	89 c2                	mov    %eax,%edx
80105ab9:	83 ec 08             	sub    $0x8,%esp
80105abc:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105abf:	50                   	push   %eax
80105ac0:	52                   	push   %edx
80105ac1:	e8 73 01 00 00       	call   80105c39 <getcallerpcs>
80105ac6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ac9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ad0:	eb 1c                	jmp    80105aee <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad5:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ad9:	83 ec 08             	sub    $0x8,%esp
80105adc:	50                   	push   %eax
80105add:	68 84 98 10 80       	push   $0x80109884
80105ae2:	e8 df a8 ff ff       	call   801003c6 <cprintf>
80105ae7:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105aee:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105af2:	7f 0b                	jg     80105aff <procdump+0xd2>
80105af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105afb:	85 c0                	test   %eax,%eax
80105afd:	75 d3                	jne    80105ad2 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105aff:	83 ec 0c             	sub    $0xc,%esp
80105b02:	68 88 98 10 80       	push   $0x80109888
80105b07:	e8 ba a8 ff ff       	call   801003c6 <cprintf>
80105b0c:	83 c4 10             	add    $0x10,%esp
80105b0f:	eb 01                	jmp    80105b12 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b11:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b12:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105b16:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b1d:	0f 82 1c ff ff ff    	jb     80105a3f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b23:	90                   	nop
80105b24:	c9                   	leave  
80105b25:	c3                   	ret    

80105b26 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b26:	55                   	push   %ebp
80105b27:	89 e5                	mov    %esp,%ebp
80105b29:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b2c:	9c                   	pushf  
80105b2d:	58                   	pop    %eax
80105b2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b34:	c9                   	leave  
80105b35:	c3                   	ret    

80105b36 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b36:	55                   	push   %ebp
80105b37:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b39:	fa                   	cli    
}
80105b3a:	90                   	nop
80105b3b:	5d                   	pop    %ebp
80105b3c:	c3                   	ret    

80105b3d <sti>:

static inline void
sti(void)
{
80105b3d:	55                   	push   %ebp
80105b3e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b40:	fb                   	sti    
}
80105b41:	90                   	nop
80105b42:	5d                   	pop    %ebp
80105b43:	c3                   	ret    

80105b44 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b44:	55                   	push   %ebp
80105b45:	89 e5                	mov    %esp,%ebp
80105b47:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b4a:	8b 55 08             	mov    0x8(%ebp),%edx
80105b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b53:	f0 87 02             	lock xchg %eax,(%edx)
80105b56:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b59:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b5c:	c9                   	leave  
80105b5d:	c3                   	ret    

80105b5e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b5e:	55                   	push   %ebp
80105b5f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b61:	8b 45 08             	mov    0x8(%ebp),%eax
80105b64:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b67:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b73:	8b 45 08             	mov    0x8(%ebp),%eax
80105b76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b7d:	90                   	nop
80105b7e:	5d                   	pop    %ebp
80105b7f:	c3                   	ret    

80105b80 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b80:	55                   	push   %ebp
80105b81:	89 e5                	mov    %esp,%ebp
80105b83:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b86:	e8 52 01 00 00       	call   80105cdd <pushcli>
  if(holding(lk))
80105b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8e:	83 ec 0c             	sub    $0xc,%esp
80105b91:	50                   	push   %eax
80105b92:	e8 1c 01 00 00       	call   80105cb3 <holding>
80105b97:	83 c4 10             	add    $0x10,%esp
80105b9a:	85 c0                	test   %eax,%eax
80105b9c:	74 0d                	je     80105bab <acquire+0x2b>
    panic("acquire");
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	68 b4 98 10 80       	push   $0x801098b4
80105ba6:	e8 bb a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bab:	90                   	nop
80105bac:	8b 45 08             	mov    0x8(%ebp),%eax
80105baf:	83 ec 08             	sub    $0x8,%esp
80105bb2:	6a 01                	push   $0x1
80105bb4:	50                   	push   %eax
80105bb5:	e8 8a ff ff ff       	call   80105b44 <xchg>
80105bba:	83 c4 10             	add    $0x10,%esp
80105bbd:	85 c0                	test   %eax,%eax
80105bbf:	75 eb                	jne    80105bac <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bcb:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bce:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd1:	83 c0 0c             	add    $0xc,%eax
80105bd4:	83 ec 08             	sub    $0x8,%esp
80105bd7:	50                   	push   %eax
80105bd8:	8d 45 08             	lea    0x8(%ebp),%eax
80105bdb:	50                   	push   %eax
80105bdc:	e8 58 00 00 00       	call   80105c39 <getcallerpcs>
80105be1:	83 c4 10             	add    $0x10,%esp
}
80105be4:	90                   	nop
80105be5:	c9                   	leave  
80105be6:	c3                   	ret    

80105be7 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105be7:	55                   	push   %ebp
80105be8:	89 e5                	mov    %esp,%ebp
80105bea:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bed:	83 ec 0c             	sub    $0xc,%esp
80105bf0:	ff 75 08             	pushl  0x8(%ebp)
80105bf3:	e8 bb 00 00 00       	call   80105cb3 <holding>
80105bf8:	83 c4 10             	add    $0x10,%esp
80105bfb:	85 c0                	test   %eax,%eax
80105bfd:	75 0d                	jne    80105c0c <release+0x25>
    panic("release");
80105bff:	83 ec 0c             	sub    $0xc,%esp
80105c02:	68 bc 98 10 80       	push   $0x801098bc
80105c07:	e8 5a a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c16:	8b 45 08             	mov    0x8(%ebp),%eax
80105c19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c20:	8b 45 08             	mov    0x8(%ebp),%eax
80105c23:	83 ec 08             	sub    $0x8,%esp
80105c26:	6a 00                	push   $0x0
80105c28:	50                   	push   %eax
80105c29:	e8 16 ff ff ff       	call   80105b44 <xchg>
80105c2e:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c31:	e8 ec 00 00 00       	call   80105d22 <popcli>
}
80105c36:	90                   	nop
80105c37:	c9                   	leave  
80105c38:	c3                   	ret    

80105c39 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c39:	55                   	push   %ebp
80105c3a:	89 e5                	mov    %esp,%ebp
80105c3c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c42:	83 e8 08             	sub    $0x8,%eax
80105c45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c48:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c4f:	eb 38                	jmp    80105c89 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c51:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c55:	74 53                	je     80105caa <getcallerpcs+0x71>
80105c57:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c5e:	76 4a                	jbe    80105caa <getcallerpcs+0x71>
80105c60:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c64:	74 44                	je     80105caa <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c70:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c73:	01 c2                	add    %eax,%edx
80105c75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c78:	8b 40 04             	mov    0x4(%eax),%eax
80105c7b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c80:	8b 00                	mov    (%eax),%eax
80105c82:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c85:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c89:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c8d:	7e c2                	jle    80105c51 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c8f:	eb 19                	jmp    80105caa <getcallerpcs+0x71>
    pcs[i] = 0;
80105c91:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c9e:	01 d0                	add    %edx,%eax
80105ca0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105ca6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105caa:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cae:	7e e1                	jle    80105c91 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cb0:	90                   	nop
80105cb1:	c9                   	leave  
80105cb2:	c3                   	ret    

80105cb3 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cb3:	55                   	push   %ebp
80105cb4:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb9:	8b 00                	mov    (%eax),%eax
80105cbb:	85 c0                	test   %eax,%eax
80105cbd:	74 17                	je     80105cd6 <holding+0x23>
80105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc2:	8b 50 08             	mov    0x8(%eax),%edx
80105cc5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ccb:	39 c2                	cmp    %eax,%edx
80105ccd:	75 07                	jne    80105cd6 <holding+0x23>
80105ccf:	b8 01 00 00 00       	mov    $0x1,%eax
80105cd4:	eb 05                	jmp    80105cdb <holding+0x28>
80105cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cdb:	5d                   	pop    %ebp
80105cdc:	c3                   	ret    

80105cdd <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105cdd:	55                   	push   %ebp
80105cde:	89 e5                	mov    %esp,%ebp
80105ce0:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105ce3:	e8 3e fe ff ff       	call   80105b26 <readeflags>
80105ce8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105ceb:	e8 46 fe ff ff       	call   80105b36 <cli>
  if(cpu->ncli++ == 0)
80105cf0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cf7:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105cfd:	8d 48 01             	lea    0x1(%eax),%ecx
80105d00:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d06:	85 c0                	test   %eax,%eax
80105d08:	75 15                	jne    80105d1f <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d0a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d10:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d13:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d19:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d1f:	90                   	nop
80105d20:	c9                   	leave  
80105d21:	c3                   	ret    

80105d22 <popcli>:

void
popcli(void)
{
80105d22:	55                   	push   %ebp
80105d23:	89 e5                	mov    %esp,%ebp
80105d25:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d28:	e8 f9 fd ff ff       	call   80105b26 <readeflags>
80105d2d:	25 00 02 00 00       	and    $0x200,%eax
80105d32:	85 c0                	test   %eax,%eax
80105d34:	74 0d                	je     80105d43 <popcli+0x21>
    panic("popcli - interruptible");
80105d36:	83 ec 0c             	sub    $0xc,%esp
80105d39:	68 c4 98 10 80       	push   $0x801098c4
80105d3e:	e8 23 a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d43:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d49:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d4f:	83 ea 01             	sub    $0x1,%edx
80105d52:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d58:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	79 0d                	jns    80105d6f <popcli+0x4d>
    panic("popcli");
80105d62:	83 ec 0c             	sub    $0xc,%esp
80105d65:	68 db 98 10 80       	push   $0x801098db
80105d6a:	e8 f7 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d6f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d75:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d7b:	85 c0                	test   %eax,%eax
80105d7d:	75 15                	jne    80105d94 <popcli+0x72>
80105d7f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d85:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d8b:	85 c0                	test   %eax,%eax
80105d8d:	74 05                	je     80105d94 <popcli+0x72>
    sti();
80105d8f:	e8 a9 fd ff ff       	call   80105b3d <sti>
}
80105d94:	90                   	nop
80105d95:	c9                   	leave  
80105d96:	c3                   	ret    

80105d97 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d97:	55                   	push   %ebp
80105d98:	89 e5                	mov    %esp,%ebp
80105d9a:	57                   	push   %edi
80105d9b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d9f:	8b 55 10             	mov    0x10(%ebp),%edx
80105da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105da5:	89 cb                	mov    %ecx,%ebx
80105da7:	89 df                	mov    %ebx,%edi
80105da9:	89 d1                	mov    %edx,%ecx
80105dab:	fc                   	cld    
80105dac:	f3 aa                	rep stos %al,%es:(%edi)
80105dae:	89 ca                	mov    %ecx,%edx
80105db0:	89 fb                	mov    %edi,%ebx
80105db2:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105db5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105db8:	90                   	nop
80105db9:	5b                   	pop    %ebx
80105dba:	5f                   	pop    %edi
80105dbb:	5d                   	pop    %ebp
80105dbc:	c3                   	ret    

80105dbd <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dbd:	55                   	push   %ebp
80105dbe:	89 e5                	mov    %esp,%ebp
80105dc0:	57                   	push   %edi
80105dc1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dc5:	8b 55 10             	mov    0x10(%ebp),%edx
80105dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dcb:	89 cb                	mov    %ecx,%ebx
80105dcd:	89 df                	mov    %ebx,%edi
80105dcf:	89 d1                	mov    %edx,%ecx
80105dd1:	fc                   	cld    
80105dd2:	f3 ab                	rep stos %eax,%es:(%edi)
80105dd4:	89 ca                	mov    %ecx,%edx
80105dd6:	89 fb                	mov    %edi,%ebx
80105dd8:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105ddb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dde:	90                   	nop
80105ddf:	5b                   	pop    %ebx
80105de0:	5f                   	pop    %edi
80105de1:	5d                   	pop    %ebp
80105de2:	c3                   	ret    

80105de3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105de3:	55                   	push   %ebp
80105de4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105de6:	8b 45 08             	mov    0x8(%ebp),%eax
80105de9:	83 e0 03             	and    $0x3,%eax
80105dec:	85 c0                	test   %eax,%eax
80105dee:	75 43                	jne    80105e33 <memset+0x50>
80105df0:	8b 45 10             	mov    0x10(%ebp),%eax
80105df3:	83 e0 03             	and    $0x3,%eax
80105df6:	85 c0                	test   %eax,%eax
80105df8:	75 39                	jne    80105e33 <memset+0x50>
    c &= 0xFF;
80105dfa:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e01:	8b 45 10             	mov    0x10(%ebp),%eax
80105e04:	c1 e8 02             	shr    $0x2,%eax
80105e07:	89 c1                	mov    %eax,%ecx
80105e09:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e0c:	c1 e0 18             	shl    $0x18,%eax
80105e0f:	89 c2                	mov    %eax,%edx
80105e11:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e14:	c1 e0 10             	shl    $0x10,%eax
80105e17:	09 c2                	or     %eax,%edx
80105e19:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1c:	c1 e0 08             	shl    $0x8,%eax
80105e1f:	09 d0                	or     %edx,%eax
80105e21:	0b 45 0c             	or     0xc(%ebp),%eax
80105e24:	51                   	push   %ecx
80105e25:	50                   	push   %eax
80105e26:	ff 75 08             	pushl  0x8(%ebp)
80105e29:	e8 8f ff ff ff       	call   80105dbd <stosl>
80105e2e:	83 c4 0c             	add    $0xc,%esp
80105e31:	eb 12                	jmp    80105e45 <memset+0x62>
  } else
    stosb(dst, c, n);
80105e33:	8b 45 10             	mov    0x10(%ebp),%eax
80105e36:	50                   	push   %eax
80105e37:	ff 75 0c             	pushl  0xc(%ebp)
80105e3a:	ff 75 08             	pushl  0x8(%ebp)
80105e3d:	e8 55 ff ff ff       	call   80105d97 <stosb>
80105e42:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e45:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e48:	c9                   	leave  
80105e49:	c3                   	ret    

80105e4a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e4a:	55                   	push   %ebp
80105e4b:	89 e5                	mov    %esp,%ebp
80105e4d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e50:	8b 45 08             	mov    0x8(%ebp),%eax
80105e53:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e59:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e5c:	eb 30                	jmp    80105e8e <memcmp+0x44>
    if(*s1 != *s2)
80105e5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e61:	0f b6 10             	movzbl (%eax),%edx
80105e64:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e67:	0f b6 00             	movzbl (%eax),%eax
80105e6a:	38 c2                	cmp    %al,%dl
80105e6c:	74 18                	je     80105e86 <memcmp+0x3c>
      return *s1 - *s2;
80105e6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e71:	0f b6 00             	movzbl (%eax),%eax
80105e74:	0f b6 d0             	movzbl %al,%edx
80105e77:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e7a:	0f b6 00             	movzbl (%eax),%eax
80105e7d:	0f b6 c0             	movzbl %al,%eax
80105e80:	29 c2                	sub    %eax,%edx
80105e82:	89 d0                	mov    %edx,%eax
80105e84:	eb 1a                	jmp    80105ea0 <memcmp+0x56>
    s1++, s2++;
80105e86:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e8a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e8e:	8b 45 10             	mov    0x10(%ebp),%eax
80105e91:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e94:	89 55 10             	mov    %edx,0x10(%ebp)
80105e97:	85 c0                	test   %eax,%eax
80105e99:	75 c3                	jne    80105e5e <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ea0:	c9                   	leave  
80105ea1:	c3                   	ret    

80105ea2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ea2:	55                   	push   %ebp
80105ea3:	89 e5                	mov    %esp,%ebp
80105ea5:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105eae:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eb7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105eba:	73 54                	jae    80105f10 <memmove+0x6e>
80105ebc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ebf:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec2:	01 d0                	add    %edx,%eax
80105ec4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ec7:	76 47                	jbe    80105f10 <memmove+0x6e>
    s += n;
80105ec9:	8b 45 10             	mov    0x10(%ebp),%eax
80105ecc:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105ed5:	eb 13                	jmp    80105eea <memmove+0x48>
      *--d = *--s;
80105ed7:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105edb:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ee2:	0f b6 10             	movzbl (%eax),%edx
80105ee5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ee8:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105eea:	8b 45 10             	mov    0x10(%ebp),%eax
80105eed:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ef0:	89 55 10             	mov    %edx,0x10(%ebp)
80105ef3:	85 c0                	test   %eax,%eax
80105ef5:	75 e0                	jne    80105ed7 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105ef7:	eb 24                	jmp    80105f1d <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105ef9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105efc:	8d 50 01             	lea    0x1(%eax),%edx
80105eff:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f02:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f05:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f08:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f0b:	0f b6 12             	movzbl (%edx),%edx
80105f0e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f10:	8b 45 10             	mov    0x10(%ebp),%eax
80105f13:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f16:	89 55 10             	mov    %edx,0x10(%ebp)
80105f19:	85 c0                	test   %eax,%eax
80105f1b:	75 dc                	jne    80105ef9 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f20:	c9                   	leave  
80105f21:	c3                   	ret    

80105f22 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f22:	55                   	push   %ebp
80105f23:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f25:	ff 75 10             	pushl  0x10(%ebp)
80105f28:	ff 75 0c             	pushl  0xc(%ebp)
80105f2b:	ff 75 08             	pushl  0x8(%ebp)
80105f2e:	e8 6f ff ff ff       	call   80105ea2 <memmove>
80105f33:	83 c4 0c             	add    $0xc,%esp
}
80105f36:	c9                   	leave  
80105f37:	c3                   	ret    

80105f38 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f38:	55                   	push   %ebp
80105f39:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f3b:	eb 0c                	jmp    80105f49 <strncmp+0x11>
    n--, p++, q++;
80105f3d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f41:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f45:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f4d:	74 1a                	je     80105f69 <strncmp+0x31>
80105f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f52:	0f b6 00             	movzbl (%eax),%eax
80105f55:	84 c0                	test   %al,%al
80105f57:	74 10                	je     80105f69 <strncmp+0x31>
80105f59:	8b 45 08             	mov    0x8(%ebp),%eax
80105f5c:	0f b6 10             	movzbl (%eax),%edx
80105f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f62:	0f b6 00             	movzbl (%eax),%eax
80105f65:	38 c2                	cmp    %al,%dl
80105f67:	74 d4                	je     80105f3d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f6d:	75 07                	jne    80105f76 <strncmp+0x3e>
    return 0;
80105f6f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f74:	eb 16                	jmp    80105f8c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f76:	8b 45 08             	mov    0x8(%ebp),%eax
80105f79:	0f b6 00             	movzbl (%eax),%eax
80105f7c:	0f b6 d0             	movzbl %al,%edx
80105f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f82:	0f b6 00             	movzbl (%eax),%eax
80105f85:	0f b6 c0             	movzbl %al,%eax
80105f88:	29 c2                	sub    %eax,%edx
80105f8a:	89 d0                	mov    %edx,%eax
}
80105f8c:	5d                   	pop    %ebp
80105f8d:	c3                   	ret    

80105f8e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f8e:	55                   	push   %ebp
80105f8f:	89 e5                	mov    %esp,%ebp
80105f91:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f94:	8b 45 08             	mov    0x8(%ebp),%eax
80105f97:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105f9a:	90                   	nop
80105f9b:	8b 45 10             	mov    0x10(%ebp),%eax
80105f9e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fa1:	89 55 10             	mov    %edx,0x10(%ebp)
80105fa4:	85 c0                	test   %eax,%eax
80105fa6:	7e 2c                	jle    80105fd4 <strncpy+0x46>
80105fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80105fab:	8d 50 01             	lea    0x1(%eax),%edx
80105fae:	89 55 08             	mov    %edx,0x8(%ebp)
80105fb1:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fb4:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fb7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fba:	0f b6 12             	movzbl (%edx),%edx
80105fbd:	88 10                	mov    %dl,(%eax)
80105fbf:	0f b6 00             	movzbl (%eax),%eax
80105fc2:	84 c0                	test   %al,%al
80105fc4:	75 d5                	jne    80105f9b <strncpy+0xd>
    ;
  while(n-- > 0)
80105fc6:	eb 0c                	jmp    80105fd4 <strncpy+0x46>
    *s++ = 0;
80105fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80105fcb:	8d 50 01             	lea    0x1(%eax),%edx
80105fce:	89 55 08             	mov    %edx,0x8(%ebp)
80105fd1:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80105fd7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fda:	89 55 10             	mov    %edx,0x10(%ebp)
80105fdd:	85 c0                	test   %eax,%eax
80105fdf:	7f e7                	jg     80105fc8 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fe4:	c9                   	leave  
80105fe5:	c3                   	ret    

80105fe6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105fe6:	55                   	push   %ebp
80105fe7:	89 e5                	mov    %esp,%ebp
80105fe9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fec:	8b 45 08             	mov    0x8(%ebp),%eax
80105fef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105ff2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ff6:	7f 05                	jg     80105ffd <safestrcpy+0x17>
    return os;
80105ff8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ffb:	eb 31                	jmp    8010602e <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105ffd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106001:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106005:	7e 1e                	jle    80106025 <safestrcpy+0x3f>
80106007:	8b 45 08             	mov    0x8(%ebp),%eax
8010600a:	8d 50 01             	lea    0x1(%eax),%edx
8010600d:	89 55 08             	mov    %edx,0x8(%ebp)
80106010:	8b 55 0c             	mov    0xc(%ebp),%edx
80106013:	8d 4a 01             	lea    0x1(%edx),%ecx
80106016:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106019:	0f b6 12             	movzbl (%edx),%edx
8010601c:	88 10                	mov    %dl,(%eax)
8010601e:	0f b6 00             	movzbl (%eax),%eax
80106021:	84 c0                	test   %al,%al
80106023:	75 d8                	jne    80105ffd <safestrcpy+0x17>
    ;
  *s = 0;
80106025:	8b 45 08             	mov    0x8(%ebp),%eax
80106028:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010602b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010602e:	c9                   	leave  
8010602f:	c3                   	ret    

80106030 <strlen>:

int
strlen(const char *s)
{
80106030:	55                   	push   %ebp
80106031:	89 e5                	mov    %esp,%ebp
80106033:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106036:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010603d:	eb 04                	jmp    80106043 <strlen+0x13>
8010603f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106043:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106046:	8b 45 08             	mov    0x8(%ebp),%eax
80106049:	01 d0                	add    %edx,%eax
8010604b:	0f b6 00             	movzbl (%eax),%eax
8010604e:	84 c0                	test   %al,%al
80106050:	75 ed                	jne    8010603f <strlen+0xf>
    ;
  return n;
80106052:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106055:	c9                   	leave  
80106056:	c3                   	ret    

80106057 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106057:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010605b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010605f:	55                   	push   %ebp
  pushl %ebx
80106060:	53                   	push   %ebx
  pushl %esi
80106061:	56                   	push   %esi
  pushl %edi
80106062:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106063:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106065:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106067:	5f                   	pop    %edi
  popl %esi
80106068:	5e                   	pop    %esi
  popl %ebx
80106069:	5b                   	pop    %ebx
  popl %ebp
8010606a:	5d                   	pop    %ebp
  ret
8010606b:	c3                   	ret    

8010606c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010606f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106075:	8b 00                	mov    (%eax),%eax
80106077:	3b 45 08             	cmp    0x8(%ebp),%eax
8010607a:	76 12                	jbe    8010608e <fetchint+0x22>
8010607c:	8b 45 08             	mov    0x8(%ebp),%eax
8010607f:	8d 50 04             	lea    0x4(%eax),%edx
80106082:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106088:	8b 00                	mov    (%eax),%eax
8010608a:	39 c2                	cmp    %eax,%edx
8010608c:	76 07                	jbe    80106095 <fetchint+0x29>
    return -1;
8010608e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106093:	eb 0f                	jmp    801060a4 <fetchint+0x38>
  *ip = *(int*)(addr);
80106095:	8b 45 08             	mov    0x8(%ebp),%eax
80106098:	8b 10                	mov    (%eax),%edx
8010609a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010609d:	89 10                	mov    %edx,(%eax)
  return 0;
8010609f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a4:	5d                   	pop    %ebp
801060a5:	c3                   	ret    

801060a6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060a6:	55                   	push   %ebp
801060a7:	89 e5                	mov    %esp,%ebp
801060a9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060b2:	8b 00                	mov    (%eax),%eax
801060b4:	3b 45 08             	cmp    0x8(%ebp),%eax
801060b7:	77 07                	ja     801060c0 <fetchstr+0x1a>
    return -1;
801060b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060be:	eb 46                	jmp    80106106 <fetchstr+0x60>
  *pp = (char*)addr;
801060c0:	8b 55 08             	mov    0x8(%ebp),%edx
801060c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060c6:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ce:	8b 00                	mov    (%eax),%eax
801060d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060d6:	8b 00                	mov    (%eax),%eax
801060d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060db:	eb 1c                	jmp    801060f9 <fetchstr+0x53>
    if(*s == 0)
801060dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060e0:	0f b6 00             	movzbl (%eax),%eax
801060e3:	84 c0                	test   %al,%al
801060e5:	75 0e                	jne    801060f5 <fetchstr+0x4f>
      return s - *pp;
801060e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ed:	8b 00                	mov    (%eax),%eax
801060ef:	29 c2                	sub    %eax,%edx
801060f1:	89 d0                	mov    %edx,%eax
801060f3:	eb 11                	jmp    80106106 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801060ff:	72 dc                	jb     801060dd <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106106:	c9                   	leave  
80106107:	c3                   	ret    

80106108 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106108:	55                   	push   %ebp
80106109:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010610b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106111:	8b 40 18             	mov    0x18(%eax),%eax
80106114:	8b 40 44             	mov    0x44(%eax),%eax
80106117:	8b 55 08             	mov    0x8(%ebp),%edx
8010611a:	c1 e2 02             	shl    $0x2,%edx
8010611d:	01 d0                	add    %edx,%eax
8010611f:	83 c0 04             	add    $0x4,%eax
80106122:	ff 75 0c             	pushl  0xc(%ebp)
80106125:	50                   	push   %eax
80106126:	e8 41 ff ff ff       	call   8010606c <fetchint>
8010612b:	83 c4 08             	add    $0x8,%esp
}
8010612e:	c9                   	leave  
8010612f:	c3                   	ret    

80106130 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106130:	55                   	push   %ebp
80106131:	89 e5                	mov    %esp,%ebp
80106133:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106136:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106139:	50                   	push   %eax
8010613a:	ff 75 08             	pushl  0x8(%ebp)
8010613d:	e8 c6 ff ff ff       	call   80106108 <argint>
80106142:	83 c4 08             	add    $0x8,%esp
80106145:	85 c0                	test   %eax,%eax
80106147:	79 07                	jns    80106150 <argptr+0x20>
    return -1;
80106149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614e:	eb 3b                	jmp    8010618b <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106156:	8b 00                	mov    (%eax),%eax
80106158:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010615b:	39 d0                	cmp    %edx,%eax
8010615d:	76 16                	jbe    80106175 <argptr+0x45>
8010615f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106162:	89 c2                	mov    %eax,%edx
80106164:	8b 45 10             	mov    0x10(%ebp),%eax
80106167:	01 c2                	add    %eax,%edx
80106169:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010616f:	8b 00                	mov    (%eax),%eax
80106171:	39 c2                	cmp    %eax,%edx
80106173:	76 07                	jbe    8010617c <argptr+0x4c>
    return -1;
80106175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617a:	eb 0f                	jmp    8010618b <argptr+0x5b>
  *pp = (char*)i;
8010617c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010617f:	89 c2                	mov    %eax,%edx
80106181:	8b 45 0c             	mov    0xc(%ebp),%eax
80106184:	89 10                	mov    %edx,(%eax)
  return 0;
80106186:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618b:	c9                   	leave  
8010618c:	c3                   	ret    

8010618d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010618d:	55                   	push   %ebp
8010618e:	89 e5                	mov    %esp,%ebp
80106190:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106193:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106196:	50                   	push   %eax
80106197:	ff 75 08             	pushl  0x8(%ebp)
8010619a:	e8 69 ff ff ff       	call   80106108 <argint>
8010619f:	83 c4 08             	add    $0x8,%esp
801061a2:	85 c0                	test   %eax,%eax
801061a4:	79 07                	jns    801061ad <argstr+0x20>
    return -1;
801061a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ab:	eb 0f                	jmp    801061bc <argstr+0x2f>
  return fetchstr(addr, pp);
801061ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061b0:	ff 75 0c             	pushl  0xc(%ebp)
801061b3:	50                   	push   %eax
801061b4:	e8 ed fe ff ff       	call   801060a6 <fetchstr>
801061b9:	83 c4 08             	add    $0x8,%esp
}
801061bc:	c9                   	leave  
801061bd:	c3                   	ret    

801061be <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061be:	55                   	push   %ebp
801061bf:	89 e5                	mov    %esp,%ebp
801061c1:	53                   	push   %ebx
801061c2:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061cb:	8b 40 18             	mov    0x18(%eax),%eax
801061ce:	8b 40 1c             	mov    0x1c(%eax),%eax
801061d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061d8:	7e 30                	jle    8010620a <syscall+0x4c>
801061da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dd:	83 f8 16             	cmp    $0x16,%eax
801061e0:	77 28                	ja     8010620a <syscall+0x4c>
801061e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e5:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061ec:	85 c0                	test   %eax,%eax
801061ee:	74 1a                	je     8010620a <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061f6:	8b 58 18             	mov    0x18(%eax),%ebx
801061f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fc:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106203:	ff d0                	call   *%eax
80106205:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106208:	eb 34                	jmp    8010623e <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010620a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106210:	8d 50 6c             	lea    0x6c(%eax),%edx
80106213:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106219:	8b 40 10             	mov    0x10(%eax),%eax
8010621c:	ff 75 f4             	pushl  -0xc(%ebp)
8010621f:	52                   	push   %edx
80106220:	50                   	push   %eax
80106221:	68 e2 98 10 80       	push   $0x801098e2
80106226:	e8 9b a1 ff ff       	call   801003c6 <cprintf>
8010622b:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010622e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106234:	8b 40 18             	mov    0x18(%eax),%eax
80106237:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010623e:	90                   	nop
8010623f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106242:	c9                   	leave  
80106243:	c3                   	ret    

80106244 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
80106244:	55                   	push   %ebp
80106245:	89 e5                	mov    %esp,%ebp
80106247:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
8010624a:	83 ec 08             	sub    $0x8,%esp
8010624d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106250:	50                   	push   %eax
80106251:	ff 75 08             	pushl  0x8(%ebp)
80106254:	e8 af fe ff ff       	call   80106108 <argint>
80106259:	83 c4 10             	add    $0x10,%esp
8010625c:	85 c0                	test   %eax,%eax
8010625e:	79 07                	jns    80106267 <argfd+0x23>
        return -1;
80106260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106265:	eb 50                	jmp    801062b7 <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
80106267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626a:	85 c0                	test   %eax,%eax
8010626c:	78 21                	js     8010628f <argfd+0x4b>
8010626e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106271:	83 f8 0f             	cmp    $0xf,%eax
80106274:	7f 19                	jg     8010628f <argfd+0x4b>
80106276:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010627c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010627f:	83 c2 08             	add    $0x8,%edx
80106282:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106286:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106289:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010628d:	75 07                	jne    80106296 <argfd+0x52>
        return -1;
8010628f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106294:	eb 21                	jmp    801062b7 <argfd+0x73>
    if (pfd)
80106296:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010629a:	74 08                	je     801062a4 <argfd+0x60>
        *pfd = fd;
8010629c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010629f:	8b 45 0c             	mov    0xc(%ebp),%eax
801062a2:	89 10                	mov    %edx,(%eax)
    if (pf)
801062a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062a8:	74 08                	je     801062b2 <argfd+0x6e>
        *pf = f;
801062aa:	8b 45 10             	mov    0x10(%ebp),%eax
801062ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b0:	89 10                	mov    %edx,(%eax)
    return 0;
801062b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062b7:	c9                   	leave  
801062b8:	c3                   	ret    

801062b9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062b9:	55                   	push   %ebp
801062ba:	89 e5                	mov    %esp,%ebp
801062bc:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062c6:	eb 30                	jmp    801062f8 <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062d1:	83 c2 08             	add    $0x8,%edx
801062d4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062d8:	85 c0                	test   %eax,%eax
801062da:	75 18                	jne    801062f4 <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062e5:	8d 4a 08             	lea    0x8(%edx),%ecx
801062e8:	8b 55 08             	mov    0x8(%ebp),%edx
801062eb:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801062ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062f2:	eb 0f                	jmp    80106303 <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062f8:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801062fc:	7e ca                	jle    801062c8 <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
801062fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106303:	c9                   	leave  
80106304:	c3                   	ret    

80106305 <sys_dup>:

int sys_dup(void)
{
80106305:	55                   	push   %ebp
80106306:	89 e5                	mov    %esp,%ebp
80106308:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
8010630b:	83 ec 04             	sub    $0x4,%esp
8010630e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106311:	50                   	push   %eax
80106312:	6a 00                	push   $0x0
80106314:	6a 00                	push   $0x0
80106316:	e8 29 ff ff ff       	call   80106244 <argfd>
8010631b:	83 c4 10             	add    $0x10,%esp
8010631e:	85 c0                	test   %eax,%eax
80106320:	79 07                	jns    80106329 <sys_dup+0x24>
        return -1;
80106322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106327:	eb 31                	jmp    8010635a <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632c:	83 ec 0c             	sub    $0xc,%esp
8010632f:	50                   	push   %eax
80106330:	e8 84 ff ff ff       	call   801062b9 <fdalloc>
80106335:	83 c4 10             	add    $0x10,%esp
80106338:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010633b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010633f:	79 07                	jns    80106348 <sys_dup+0x43>
        return -1;
80106341:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106346:	eb 12                	jmp    8010635a <sys_dup+0x55>
    filedup(f);
80106348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634b:	83 ec 0c             	sub    $0xc,%esp
8010634e:	50                   	push   %eax
8010634f:	e8 04 ad ff ff       	call   80101058 <filedup>
80106354:	83 c4 10             	add    $0x10,%esp
    return fd;
80106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010635a:	c9                   	leave  
8010635b:	c3                   	ret    

8010635c <sys_read>:

int sys_read(void)
{
8010635c:	55                   	push   %ebp
8010635d:	89 e5                	mov    %esp,%ebp
8010635f:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106362:	83 ec 04             	sub    $0x4,%esp
80106365:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106368:	50                   	push   %eax
80106369:	6a 00                	push   $0x0
8010636b:	6a 00                	push   $0x0
8010636d:	e8 d2 fe ff ff       	call   80106244 <argfd>
80106372:	83 c4 10             	add    $0x10,%esp
80106375:	85 c0                	test   %eax,%eax
80106377:	78 2e                	js     801063a7 <sys_read+0x4b>
80106379:	83 ec 08             	sub    $0x8,%esp
8010637c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010637f:	50                   	push   %eax
80106380:	6a 02                	push   $0x2
80106382:	e8 81 fd ff ff       	call   80106108 <argint>
80106387:	83 c4 10             	add    $0x10,%esp
8010638a:	85 c0                	test   %eax,%eax
8010638c:	78 19                	js     801063a7 <sys_read+0x4b>
8010638e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106391:	83 ec 04             	sub    $0x4,%esp
80106394:	50                   	push   %eax
80106395:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106398:	50                   	push   %eax
80106399:	6a 01                	push   $0x1
8010639b:	e8 90 fd ff ff       	call   80106130 <argptr>
801063a0:	83 c4 10             	add    $0x10,%esp
801063a3:	85 c0                	test   %eax,%eax
801063a5:	79 07                	jns    801063ae <sys_read+0x52>
        return -1;
801063a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ac:	eb 17                	jmp    801063c5 <sys_read+0x69>
    return fileread(f, p, n);
801063ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b7:	83 ec 04             	sub    $0x4,%esp
801063ba:	51                   	push   %ecx
801063bb:	52                   	push   %edx
801063bc:	50                   	push   %eax
801063bd:	e8 4e ae ff ff       	call   80101210 <fileread>
801063c2:	83 c4 10             	add    $0x10,%esp
}
801063c5:	c9                   	leave  
801063c6:	c3                   	ret    

801063c7 <sys_write>:

int sys_write(void)
{
801063c7:	55                   	push   %ebp
801063c8:	89 e5                	mov    %esp,%ebp
801063ca:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063cd:	83 ec 04             	sub    $0x4,%esp
801063d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063d3:	50                   	push   %eax
801063d4:	6a 00                	push   $0x0
801063d6:	6a 00                	push   $0x0
801063d8:	e8 67 fe ff ff       	call   80106244 <argfd>
801063dd:	83 c4 10             	add    $0x10,%esp
801063e0:	85 c0                	test   %eax,%eax
801063e2:	78 2e                	js     80106412 <sys_write+0x4b>
801063e4:	83 ec 08             	sub    $0x8,%esp
801063e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ea:	50                   	push   %eax
801063eb:	6a 02                	push   $0x2
801063ed:	e8 16 fd ff ff       	call   80106108 <argint>
801063f2:	83 c4 10             	add    $0x10,%esp
801063f5:	85 c0                	test   %eax,%eax
801063f7:	78 19                	js     80106412 <sys_write+0x4b>
801063f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fc:	83 ec 04             	sub    $0x4,%esp
801063ff:	50                   	push   %eax
80106400:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106403:	50                   	push   %eax
80106404:	6a 01                	push   $0x1
80106406:	e8 25 fd ff ff       	call   80106130 <argptr>
8010640b:	83 c4 10             	add    $0x10,%esp
8010640e:	85 c0                	test   %eax,%eax
80106410:	79 07                	jns    80106419 <sys_write+0x52>
        return -1;
80106412:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106417:	eb 17                	jmp    80106430 <sys_write+0x69>
    return filewrite(f, p, n);
80106419:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010641c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010641f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106422:	83 ec 04             	sub    $0x4,%esp
80106425:	51                   	push   %ecx
80106426:	52                   	push   %edx
80106427:	50                   	push   %eax
80106428:	e8 9b ae ff ff       	call   801012c8 <filewrite>
8010642d:	83 c4 10             	add    $0x10,%esp
}
80106430:	c9                   	leave  
80106431:	c3                   	ret    

80106432 <sys_close>:

int sys_close(void)
{
80106432:	55                   	push   %ebp
80106433:	89 e5                	mov    %esp,%ebp
80106435:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
80106438:	83 ec 04             	sub    $0x4,%esp
8010643b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010643e:	50                   	push   %eax
8010643f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106442:	50                   	push   %eax
80106443:	6a 00                	push   $0x0
80106445:	e8 fa fd ff ff       	call   80106244 <argfd>
8010644a:	83 c4 10             	add    $0x10,%esp
8010644d:	85 c0                	test   %eax,%eax
8010644f:	79 07                	jns    80106458 <sys_close+0x26>
        return -1;
80106451:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106456:	eb 28                	jmp    80106480 <sys_close+0x4e>
    proc->ofile[fd] = 0;
80106458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010645e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106461:	83 c2 08             	add    $0x8,%edx
80106464:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010646b:	00 
    fileclose(f);
8010646c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646f:	83 ec 0c             	sub    $0xc,%esp
80106472:	50                   	push   %eax
80106473:	e8 31 ac ff ff       	call   801010a9 <fileclose>
80106478:	83 c4 10             	add    $0x10,%esp
    return 0;
8010647b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106480:	c9                   	leave  
80106481:	c3                   	ret    

80106482 <sys_fstat>:

int sys_fstat(void)
{
80106482:	55                   	push   %ebp
80106483:	89 e5                	mov    %esp,%ebp
80106485:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106488:	83 ec 04             	sub    $0x4,%esp
8010648b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010648e:	50                   	push   %eax
8010648f:	6a 00                	push   $0x0
80106491:	6a 00                	push   $0x0
80106493:	e8 ac fd ff ff       	call   80106244 <argfd>
80106498:	83 c4 10             	add    $0x10,%esp
8010649b:	85 c0                	test   %eax,%eax
8010649d:	78 17                	js     801064b6 <sys_fstat+0x34>
8010649f:	83 ec 04             	sub    $0x4,%esp
801064a2:	6a 14                	push   $0x14
801064a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064a7:	50                   	push   %eax
801064a8:	6a 01                	push   $0x1
801064aa:	e8 81 fc ff ff       	call   80106130 <argptr>
801064af:	83 c4 10             	add    $0x10,%esp
801064b2:	85 c0                	test   %eax,%eax
801064b4:	79 07                	jns    801064bd <sys_fstat+0x3b>
        return -1;
801064b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bb:	eb 13                	jmp    801064d0 <sys_fstat+0x4e>
    return filestat(f, st);
801064bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c3:	83 ec 08             	sub    $0x8,%esp
801064c6:	52                   	push   %edx
801064c7:	50                   	push   %eax
801064c8:	e8 ec ac ff ff       	call   801011b9 <filestat>
801064cd:	83 c4 10             	add    $0x10,%esp
}
801064d0:	c9                   	leave  
801064d1:	c3                   	ret    

801064d2 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064d2:	55                   	push   %ebp
801064d3:	89 e5                	mov    %esp,%ebp
801064d5:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064d8:	83 ec 08             	sub    $0x8,%esp
801064db:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064de:	50                   	push   %eax
801064df:	6a 00                	push   $0x0
801064e1:	e8 a7 fc ff ff       	call   8010618d <argstr>
801064e6:	83 c4 10             	add    $0x10,%esp
801064e9:	85 c0                	test   %eax,%eax
801064eb:	78 15                	js     80106502 <sys_link+0x30>
801064ed:	83 ec 08             	sub    $0x8,%esp
801064f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064f3:	50                   	push   %eax
801064f4:	6a 01                	push   $0x1
801064f6:	e8 92 fc ff ff       	call   8010618d <argstr>
801064fb:	83 c4 10             	add    $0x10,%esp
801064fe:	85 c0                	test   %eax,%eax
80106500:	79 0a                	jns    8010650c <sys_link+0x3a>
        return -1;
80106502:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106507:	e9 da 01 00 00       	jmp    801066e6 <sys_link+0x214>

    begin_op(proc->cwd->part->number);
8010650c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106512:	8b 40 68             	mov    0x68(%eax),%eax
80106515:	8b 40 50             	mov    0x50(%eax),%eax
80106518:	8b 40 14             	mov    0x14(%eax),%eax
8010651b:	83 ec 0c             	sub    $0xc,%esp
8010651e:	50                   	push   %eax
8010651f:	e8 7e d9 ff ff       	call   80103ea2 <begin_op>
80106524:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
80106527:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010652a:	83 ec 0c             	sub    $0xc,%esp
8010652d:	50                   	push   %eax
8010652e:	e8 d1 c7 ff ff       	call   80102d04 <namei>
80106533:	83 c4 10             	add    $0x10,%esp
80106536:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106539:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010653d:	75 25                	jne    80106564 <sys_link+0x92>
        end_op(proc->cwd->part->number);
8010653f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106545:	8b 40 68             	mov    0x68(%eax),%eax
80106548:	8b 40 50             	mov    0x50(%eax),%eax
8010654b:	8b 40 14             	mov    0x14(%eax),%eax
8010654e:	83 ec 0c             	sub    $0xc,%esp
80106551:	50                   	push   %eax
80106552:	e8 52 da ff ff       	call   80103fa9 <end_op>
80106557:	83 c4 10             	add    $0x10,%esp
        return -1;
8010655a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655f:	e9 82 01 00 00       	jmp    801066e6 <sys_link+0x214>
    }

    ilock(ip);
80106564:	83 ec 0c             	sub    $0xc,%esp
80106567:	ff 75 f4             	pushl  -0xc(%ebp)
8010656a:	e8 73 b9 ff ff       	call   80101ee2 <ilock>
8010656f:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106575:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106579:	66 83 f8 01          	cmp    $0x1,%ax
8010657d:	75 33                	jne    801065b2 <sys_link+0xe0>
        iunlockput(ip);
8010657f:	83 ec 0c             	sub    $0xc,%esp
80106582:	ff 75 f4             	pushl  -0xc(%ebp)
80106585:	e8 5b bc ff ff       	call   801021e5 <iunlockput>
8010658a:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
8010658d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106593:	8b 40 68             	mov    0x68(%eax),%eax
80106596:	8b 40 50             	mov    0x50(%eax),%eax
80106599:	8b 40 14             	mov    0x14(%eax),%eax
8010659c:	83 ec 0c             	sub    $0xc,%esp
8010659f:	50                   	push   %eax
801065a0:	e8 04 da ff ff       	call   80103fa9 <end_op>
801065a5:	83 c4 10             	add    $0x10,%esp
        return -1;
801065a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ad:	e9 34 01 00 00       	jmp    801066e6 <sys_link+0x214>
    }

    ip->nlink++;
801065b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065b9:	83 c0 01             	add    $0x1,%eax
801065bc:	89 c2                	mov    %eax,%edx
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c1:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065c5:	83 ec 0c             	sub    $0xc,%esp
801065c8:	ff 75 f4             	pushl  -0xc(%ebp)
801065cb:	e8 b4 b6 ff ff       	call   80101c84 <iupdate>
801065d0:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065d3:	83 ec 0c             	sub    $0xc,%esp
801065d6:	ff 75 f4             	pushl  -0xc(%ebp)
801065d9:	e8 a5 ba ff ff       	call   80102083 <iunlock>
801065de:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065e4:	83 ec 08             	sub    $0x8,%esp
801065e7:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065ea:	52                   	push   %edx
801065eb:	50                   	push   %eax
801065ec:	e8 49 c7 ff ff       	call   80102d3a <nameiparent>
801065f1:	83 c4 10             	add    $0x10,%esp
801065f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065fb:	0f 84 87 00 00 00    	je     80106688 <sys_link+0x1b6>
        goto bad;
    ilock(dp);
80106601:	83 ec 0c             	sub    $0xc,%esp
80106604:	ff 75 f0             	pushl  -0x10(%ebp)
80106607:	e8 d6 b8 ff ff       	call   80101ee2 <ilock>
8010660c:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
8010660f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106612:	8b 10                	mov    (%eax),%edx
80106614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106617:	8b 00                	mov    (%eax),%eax
80106619:	39 c2                	cmp    %eax,%edx
8010661b:	75 1d                	jne    8010663a <sys_link+0x168>
8010661d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106620:	8b 40 04             	mov    0x4(%eax),%eax
80106623:	83 ec 04             	sub    $0x4,%esp
80106626:	50                   	push   %eax
80106627:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010662a:	50                   	push   %eax
8010662b:	ff 75 f0             	pushl  -0x10(%ebp)
8010662e:	e8 9a c3 ff ff       	call   801029cd <dirlink>
80106633:	83 c4 10             	add    $0x10,%esp
80106636:	85 c0                	test   %eax,%eax
80106638:	79 10                	jns    8010664a <sys_link+0x178>
        iunlockput(dp);
8010663a:	83 ec 0c             	sub    $0xc,%esp
8010663d:	ff 75 f0             	pushl  -0x10(%ebp)
80106640:	e8 a0 bb ff ff       	call   801021e5 <iunlockput>
80106645:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106648:	eb 3f                	jmp    80106689 <sys_link+0x1b7>
    }
    iunlockput(dp);
8010664a:	83 ec 0c             	sub    $0xc,%esp
8010664d:	ff 75 f0             	pushl  -0x10(%ebp)
80106650:	e8 90 bb ff ff       	call   801021e5 <iunlockput>
80106655:	83 c4 10             	add    $0x10,%esp
    iput(ip);
80106658:	83 ec 0c             	sub    $0xc,%esp
8010665b:	ff 75 f4             	pushl  -0xc(%ebp)
8010665e:	e8 92 ba ff ff       	call   801020f5 <iput>
80106663:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106666:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010666c:	8b 40 68             	mov    0x68(%eax),%eax
8010666f:	8b 40 50             	mov    0x50(%eax),%eax
80106672:	8b 40 14             	mov    0x14(%eax),%eax
80106675:	83 ec 0c             	sub    $0xc,%esp
80106678:	50                   	push   %eax
80106679:	e8 2b d9 ff ff       	call   80103fa9 <end_op>
8010667e:	83 c4 10             	add    $0x10,%esp

    return 0;
80106681:	b8 00 00 00 00       	mov    $0x0,%eax
80106686:	eb 5e                	jmp    801066e6 <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
80106688:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
80106689:	83 ec 0c             	sub    $0xc,%esp
8010668c:	ff 75 f4             	pushl  -0xc(%ebp)
8010668f:	e8 4e b8 ff ff       	call   80101ee2 <ilock>
80106694:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
80106697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010669e:	83 e8 01             	sub    $0x1,%eax
801066a1:	89 c2                	mov    %eax,%edx
801066a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801066aa:	83 ec 0c             	sub    $0xc,%esp
801066ad:	ff 75 f4             	pushl  -0xc(%ebp)
801066b0:	e8 cf b5 ff ff       	call   80101c84 <iupdate>
801066b5:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066b8:	83 ec 0c             	sub    $0xc,%esp
801066bb:	ff 75 f4             	pushl  -0xc(%ebp)
801066be:	e8 22 bb ff ff       	call   801021e5 <iunlockput>
801066c3:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066cc:	8b 40 68             	mov    0x68(%eax),%eax
801066cf:	8b 40 50             	mov    0x50(%eax),%eax
801066d2:	8b 40 14             	mov    0x14(%eax),%eax
801066d5:	83 ec 0c             	sub    $0xc,%esp
801066d8:	50                   	push   %eax
801066d9:	e8 cb d8 ff ff       	call   80103fa9 <end_op>
801066de:	83 c4 10             	add    $0x10,%esp
    return -1;
801066e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066e6:	c9                   	leave  
801066e7:	c3                   	ret    

801066e8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066e8:	55                   	push   %ebp
801066e9:	89 e5                	mov    %esp,%ebp
801066eb:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801066ee:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066f5:	eb 40                	jmp    80106737 <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fa:	6a 10                	push   $0x10
801066fc:	50                   	push   %eax
801066fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106700:	50                   	push   %eax
80106701:	ff 75 08             	pushl  0x8(%ebp)
80106704:	e8 67 be ff ff       	call   80102570 <readi>
80106709:	83 c4 10             	add    $0x10,%esp
8010670c:	83 f8 10             	cmp    $0x10,%eax
8010670f:	74 0d                	je     8010671e <isdirempty+0x36>
            panic("isdirempty: readi");
80106711:	83 ec 0c             	sub    $0xc,%esp
80106714:	68 fe 98 10 80       	push   $0x801098fe
80106719:	e8 48 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
8010671e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106722:	66 85 c0             	test   %ax,%ax
80106725:	74 07                	je     8010672e <isdirempty+0x46>
            return 0;
80106727:	b8 00 00 00 00       	mov    $0x0,%eax
8010672c:	eb 1b                	jmp    80106749 <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
8010672e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106731:	83 c0 10             	add    $0x10,%eax
80106734:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106737:	8b 45 08             	mov    0x8(%ebp),%eax
8010673a:	8b 50 18             	mov    0x18(%eax),%edx
8010673d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106740:	39 c2                	cmp    %eax,%edx
80106742:	77 b3                	ja     801066f7 <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
80106744:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106749:	c9                   	leave  
8010674a:	c3                   	ret    

8010674b <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
8010674b:	55                   	push   %ebp
8010674c:	89 e5                	mov    %esp,%ebp
8010674e:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106751:	83 ec 08             	sub    $0x8,%esp
80106754:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106757:	50                   	push   %eax
80106758:	6a 00                	push   $0x0
8010675a:	e8 2e fa ff ff       	call   8010618d <argstr>
8010675f:	83 c4 10             	add    $0x10,%esp
80106762:	85 c0                	test   %eax,%eax
80106764:	79 0a                	jns    80106770 <sys_unlink+0x25>
        return -1;
80106766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676b:	e9 14 02 00 00       	jmp    80106984 <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
80106770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106776:	8b 40 68             	mov    0x68(%eax),%eax
80106779:	8b 40 50             	mov    0x50(%eax),%eax
8010677c:	8b 40 14             	mov    0x14(%eax),%eax
8010677f:	83 ec 0c             	sub    $0xc,%esp
80106782:	50                   	push   %eax
80106783:	e8 1a d7 ff ff       	call   80103ea2 <begin_op>
80106788:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
8010678b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010678e:	83 ec 08             	sub    $0x8,%esp
80106791:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106794:	52                   	push   %edx
80106795:	50                   	push   %eax
80106796:	e8 9f c5 ff ff       	call   80102d3a <nameiparent>
8010679b:	83 c4 10             	add    $0x10,%esp
8010679e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a5:	75 25                	jne    801067cc <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
801067a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067ad:	8b 40 68             	mov    0x68(%eax),%eax
801067b0:	8b 40 50             	mov    0x50(%eax),%eax
801067b3:	8b 40 14             	mov    0x14(%eax),%eax
801067b6:	83 ec 0c             	sub    $0xc,%esp
801067b9:	50                   	push   %eax
801067ba:	e8 ea d7 ff ff       	call   80103fa9 <end_op>
801067bf:	83 c4 10             	add    $0x10,%esp
        return -1;
801067c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c7:	e9 b8 01 00 00       	jmp    80106984 <sys_unlink+0x239>
    }

    ilock(dp);
801067cc:	83 ec 0c             	sub    $0xc,%esp
801067cf:	ff 75 f4             	pushl  -0xc(%ebp)
801067d2:	e8 0b b7 ff ff       	call   80101ee2 <ilock>
801067d7:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067da:	83 ec 08             	sub    $0x8,%esp
801067dd:	68 10 99 10 80       	push   $0x80109910
801067e2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067e5:	50                   	push   %eax
801067e6:	e8 00 c1 ff ff       	call   801028eb <namecmp>
801067eb:	83 c4 10             	add    $0x10,%esp
801067ee:	85 c0                	test   %eax,%eax
801067f0:	0f 84 60 01 00 00    	je     80106956 <sys_unlink+0x20b>
801067f6:	83 ec 08             	sub    $0x8,%esp
801067f9:	68 12 99 10 80       	push   $0x80109912
801067fe:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106801:	50                   	push   %eax
80106802:	e8 e4 c0 ff ff       	call   801028eb <namecmp>
80106807:	83 c4 10             	add    $0x10,%esp
8010680a:	85 c0                	test   %eax,%eax
8010680c:	0f 84 44 01 00 00    	je     80106956 <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
80106812:	83 ec 04             	sub    $0x4,%esp
80106815:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106818:	50                   	push   %eax
80106819:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010681c:	50                   	push   %eax
8010681d:	ff 75 f4             	pushl  -0xc(%ebp)
80106820:	e8 e1 c0 ff ff       	call   80102906 <dirlookup>
80106825:	83 c4 10             	add    $0x10,%esp
80106828:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010682b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010682f:	0f 84 20 01 00 00    	je     80106955 <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
80106835:	83 ec 0c             	sub    $0xc,%esp
80106838:	ff 75 f0             	pushl  -0x10(%ebp)
8010683b:	e8 a2 b6 ff ff       	call   80101ee2 <ilock>
80106840:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
80106843:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106846:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010684a:	66 85 c0             	test   %ax,%ax
8010684d:	7f 0d                	jg     8010685c <sys_unlink+0x111>
        panic("unlink: nlink < 1");
8010684f:	83 ec 0c             	sub    $0xc,%esp
80106852:	68 15 99 10 80       	push   $0x80109915
80106857:	e8 0a 9d ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
8010685c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106863:	66 83 f8 01          	cmp    $0x1,%ax
80106867:	75 25                	jne    8010688e <sys_unlink+0x143>
80106869:	83 ec 0c             	sub    $0xc,%esp
8010686c:	ff 75 f0             	pushl  -0x10(%ebp)
8010686f:	e8 74 fe ff ff       	call   801066e8 <isdirempty>
80106874:	83 c4 10             	add    $0x10,%esp
80106877:	85 c0                	test   %eax,%eax
80106879:	75 13                	jne    8010688e <sys_unlink+0x143>
        iunlockput(ip);
8010687b:	83 ec 0c             	sub    $0xc,%esp
8010687e:	ff 75 f0             	pushl  -0x10(%ebp)
80106881:	e8 5f b9 ff ff       	call   801021e5 <iunlockput>
80106886:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106889:	e9 c8 00 00 00       	jmp    80106956 <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
8010688e:	83 ec 04             	sub    $0x4,%esp
80106891:	6a 10                	push   $0x10
80106893:	6a 00                	push   $0x0
80106895:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106898:	50                   	push   %eax
80106899:	e8 45 f5 ff ff       	call   80105de3 <memset>
8010689e:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801068a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801068a4:	6a 10                	push   $0x10
801068a6:	50                   	push   %eax
801068a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068aa:	50                   	push   %eax
801068ab:	ff 75 f4             	pushl  -0xc(%ebp)
801068ae:	e8 5d be ff ff       	call   80102710 <writei>
801068b3:	83 c4 10             	add    $0x10,%esp
801068b6:	83 f8 10             	cmp    $0x10,%eax
801068b9:	74 0d                	je     801068c8 <sys_unlink+0x17d>
        panic("unlink: writei");
801068bb:	83 ec 0c             	sub    $0xc,%esp
801068be:	68 27 99 10 80       	push   $0x80109927
801068c3:	e8 9e 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068cb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068cf:	66 83 f8 01          	cmp    $0x1,%ax
801068d3:	75 21                	jne    801068f6 <sys_unlink+0x1ab>
        dp->nlink--;
801068d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068dc:	83 e8 01             	sub    $0x1,%eax
801068df:	89 c2                	mov    %eax,%edx
801068e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e4:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068e8:	83 ec 0c             	sub    $0xc,%esp
801068eb:	ff 75 f4             	pushl  -0xc(%ebp)
801068ee:	e8 91 b3 ff ff       	call   80101c84 <iupdate>
801068f3:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
801068f6:	83 ec 0c             	sub    $0xc,%esp
801068f9:	ff 75 f4             	pushl  -0xc(%ebp)
801068fc:	e8 e4 b8 ff ff       	call   801021e5 <iunlockput>
80106901:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
80106904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106907:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010690b:	83 e8 01             	sub    $0x1,%eax
8010690e:	89 c2                	mov    %eax,%edx
80106910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106913:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
80106917:	83 ec 0c             	sub    $0xc,%esp
8010691a:	ff 75 f0             	pushl  -0x10(%ebp)
8010691d:	e8 62 b3 ff ff       	call   80101c84 <iupdate>
80106922:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106925:	83 ec 0c             	sub    $0xc,%esp
80106928:	ff 75 f0             	pushl  -0x10(%ebp)
8010692b:	e8 b5 b8 ff ff       	call   801021e5 <iunlockput>
80106930:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106933:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106939:	8b 40 68             	mov    0x68(%eax),%eax
8010693c:	8b 40 50             	mov    0x50(%eax),%eax
8010693f:	8b 40 14             	mov    0x14(%eax),%eax
80106942:	83 ec 0c             	sub    $0xc,%esp
80106945:	50                   	push   %eax
80106946:	e8 5e d6 ff ff       	call   80103fa9 <end_op>
8010694b:	83 c4 10             	add    $0x10,%esp

    return 0;
8010694e:	b8 00 00 00 00       	mov    $0x0,%eax
80106953:	eb 2f                	jmp    80106984 <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
80106955:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
80106956:	83 ec 0c             	sub    $0xc,%esp
80106959:	ff 75 f4             	pushl  -0xc(%ebp)
8010695c:	e8 84 b8 ff ff       	call   801021e5 <iunlockput>
80106961:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106964:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696a:	8b 40 68             	mov    0x68(%eax),%eax
8010696d:	8b 40 50             	mov    0x50(%eax),%eax
80106970:	8b 40 14             	mov    0x14(%eax),%eax
80106973:	83 ec 0c             	sub    $0xc,%esp
80106976:	50                   	push   %eax
80106977:	e8 2d d6 ff ff       	call   80103fa9 <end_op>
8010697c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010697f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106984:	c9                   	leave  
80106985:	c3                   	ret    

80106986 <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
80106986:	55                   	push   %ebp
80106987:	89 e5                	mov    %esp,%ebp
80106989:	83 ec 38             	sub    $0x38,%esp
8010698c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010698f:	8b 55 10             	mov    0x10(%ebp),%edx
80106992:	8b 45 14             	mov    0x14(%ebp),%eax
80106995:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106999:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010699d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
    // cprintf("path %d  \n",path);
    if ((dp = nameiparent(path, name)) == 0)
801069a1:	83 ec 08             	sub    $0x8,%esp
801069a4:	8d 45 de             	lea    -0x22(%ebp),%eax
801069a7:	50                   	push   %eax
801069a8:	ff 75 08             	pushl  0x8(%ebp)
801069ab:	e8 8a c3 ff ff       	call   80102d3a <nameiparent>
801069b0:	83 c4 10             	add    $0x10,%esp
801069b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069ba:	75 0a                	jne    801069c6 <create+0x40>
        return 0;
801069bc:	b8 00 00 00 00       	mov    $0x0,%eax
801069c1:	e9 9c 01 00 00       	jmp    80106b62 <create+0x1dc>
    ilock(dp);
801069c6:	83 ec 0c             	sub    $0xc,%esp
801069c9:	ff 75 f4             	pushl  -0xc(%ebp)
801069cc:	e8 11 b5 ff ff       	call   80101ee2 <ilock>
801069d1:	83 c4 10             	add    $0x10,%esp

    if ((ip = dirlookup(dp, name, &off)) != 0) {
801069d4:	83 ec 04             	sub    $0x4,%esp
801069d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069da:	50                   	push   %eax
801069db:	8d 45 de             	lea    -0x22(%ebp),%eax
801069de:	50                   	push   %eax
801069df:	ff 75 f4             	pushl  -0xc(%ebp)
801069e2:	e8 1f bf ff ff       	call   80102906 <dirlookup>
801069e7:	83 c4 10             	add    $0x10,%esp
801069ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069f1:	74 50                	je     80106a43 <create+0xbd>
        iunlockput(dp);
801069f3:	83 ec 0c             	sub    $0xc,%esp
801069f6:	ff 75 f4             	pushl  -0xc(%ebp)
801069f9:	e8 e7 b7 ff ff       	call   801021e5 <iunlockput>
801069fe:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80106a01:	83 ec 0c             	sub    $0xc,%esp
80106a04:	ff 75 f0             	pushl  -0x10(%ebp)
80106a07:	e8 d6 b4 ff ff       	call   80101ee2 <ilock>
80106a0c:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
80106a0f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a14:	75 15                	jne    80106a2b <create+0xa5>
80106a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a19:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a1d:	66 83 f8 02          	cmp    $0x2,%ax
80106a21:	75 08                	jne    80106a2b <create+0xa5>
            return ip;
80106a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a26:	e9 37 01 00 00       	jmp    80106b62 <create+0x1dc>
        iunlockput(ip);
80106a2b:	83 ec 0c             	sub    $0xc,%esp
80106a2e:	ff 75 f0             	pushl  -0x10(%ebp)
80106a31:	e8 af b7 ff ff       	call   801021e5 <iunlockput>
80106a36:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a39:	b8 00 00 00 00       	mov    $0x0,%eax
80106a3e:	e9 1f 01 00 00       	jmp    80106b62 <create+0x1dc>
    }
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a46:	8b 40 50             	mov    0x50(%eax),%eax
80106a49:	8b 40 14             	mov    0x14(%eax),%eax
80106a4c:	89 c1                	mov    %eax,%ecx
80106a4e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a55:	8b 00                	mov    (%eax),%eax
80106a57:	83 ec 04             	sub    $0x4,%esp
80106a5a:	51                   	push   %ecx
80106a5b:	52                   	push   %edx
80106a5c:	50                   	push   %eax
80106a5d:	e8 09 b1 ff ff       	call   80101b6b <ialloc>
80106a62:	83 c4 10             	add    $0x10,%esp
80106a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a6c:	75 0d                	jne    80106a7b <create+0xf5>
        panic("create: ialloc");
80106a6e:	83 ec 0c             	sub    $0xc,%esp
80106a71:	68 36 99 10 80       	push   $0x80109936
80106a76:	e8 eb 9a ff ff       	call   80100566 <panic>

    ilock(ip);
80106a7b:	83 ec 0c             	sub    $0xc,%esp
80106a7e:	ff 75 f0             	pushl  -0x10(%ebp)
80106a81:	e8 5c b4 ff ff       	call   80101ee2 <ilock>
80106a86:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a8c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a90:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a97:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a9b:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aa2:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    iupdate(ip);
80106aa8:	83 ec 0c             	sub    $0xc,%esp
80106aab:	ff 75 f0             	pushl  -0x10(%ebp)
80106aae:	e8 d1 b1 ff ff       	call   80101c84 <iupdate>
80106ab3:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106ab6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106abb:	75 6a                	jne    80106b27 <create+0x1a1>
        dp->nlink++;     // for ".."
80106abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ac4:	83 c0 01             	add    $0x1,%eax
80106ac7:	89 c2                	mov    %eax,%edx
80106ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106acc:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106ad0:	83 ec 0c             	sub    $0xc,%esp
80106ad3:	ff 75 f4             	pushl  -0xc(%ebp)
80106ad6:	e8 a9 b1 ff ff       	call   80101c84 <iupdate>
80106adb:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ae1:	8b 40 04             	mov    0x4(%eax),%eax
80106ae4:	83 ec 04             	sub    $0x4,%esp
80106ae7:	50                   	push   %eax
80106ae8:	68 10 99 10 80       	push   $0x80109910
80106aed:	ff 75 f0             	pushl  -0x10(%ebp)
80106af0:	e8 d8 be ff ff       	call   801029cd <dirlink>
80106af5:	83 c4 10             	add    $0x10,%esp
80106af8:	85 c0                	test   %eax,%eax
80106afa:	78 1e                	js     80106b1a <create+0x194>
80106afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aff:	8b 40 04             	mov    0x4(%eax),%eax
80106b02:	83 ec 04             	sub    $0x4,%esp
80106b05:	50                   	push   %eax
80106b06:	68 12 99 10 80       	push   $0x80109912
80106b0b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b0e:	e8 ba be ff ff       	call   801029cd <dirlink>
80106b13:	83 c4 10             	add    $0x10,%esp
80106b16:	85 c0                	test   %eax,%eax
80106b18:	79 0d                	jns    80106b27 <create+0x1a1>
            panic("create dots");
80106b1a:	83 ec 0c             	sub    $0xc,%esp
80106b1d:	68 45 99 10 80       	push   $0x80109945
80106b22:	e8 3f 9a ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b2a:	8b 40 04             	mov    0x4(%eax),%eax
80106b2d:	83 ec 04             	sub    $0x4,%esp
80106b30:	50                   	push   %eax
80106b31:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b34:	50                   	push   %eax
80106b35:	ff 75 f4             	pushl  -0xc(%ebp)
80106b38:	e8 90 be ff ff       	call   801029cd <dirlink>
80106b3d:	83 c4 10             	add    $0x10,%esp
80106b40:	85 c0                	test   %eax,%eax
80106b42:	79 0d                	jns    80106b51 <create+0x1cb>
        panic("create: dirlink");
80106b44:	83 ec 0c             	sub    $0xc,%esp
80106b47:	68 51 99 10 80       	push   $0x80109951
80106b4c:	e8 15 9a ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b51:	83 ec 0c             	sub    $0xc,%esp
80106b54:	ff 75 f4             	pushl  -0xc(%ebp)
80106b57:	e8 89 b6 ff ff       	call   801021e5 <iunlockput>
80106b5c:	83 c4 10             	add    $0x10,%esp

    return ip;
80106b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b62:	c9                   	leave  
80106b63:	c3                   	ret    

80106b64 <sys_open>:

int sys_open(void)
{
80106b64:	55                   	push   %ebp
80106b65:	89 e5                	mov    %esp,%ebp
80106b67:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b6a:	83 ec 08             	sub    $0x8,%esp
80106b6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b70:	50                   	push   %eax
80106b71:	6a 00                	push   $0x0
80106b73:	e8 15 f6 ff ff       	call   8010618d <argstr>
80106b78:	83 c4 10             	add    $0x10,%esp
80106b7b:	85 c0                	test   %eax,%eax
80106b7d:	78 15                	js     80106b94 <sys_open+0x30>
80106b7f:	83 ec 08             	sub    $0x8,%esp
80106b82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b85:	50                   	push   %eax
80106b86:	6a 01                	push   $0x1
80106b88:	e8 7b f5 ff ff       	call   80106108 <argint>
80106b8d:	83 c4 10             	add    $0x10,%esp
80106b90:	85 c0                	test   %eax,%eax
80106b92:	79 07                	jns    80106b9b <sys_open+0x37>
        return -1;
80106b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b99:	eb 13                	jmp    80106bae <sys_open+0x4a>

    return openFile(path, omode);
80106b9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba1:	83 ec 08             	sub    $0x8,%esp
80106ba4:	52                   	push   %edx
80106ba5:	50                   	push   %eax
80106ba6:	e8 05 00 00 00       	call   80106bb0 <openFile>
80106bab:	83 c4 10             	add    $0x10,%esp
}
80106bae:	c9                   	leave  
80106baf:	c3                   	ret    

80106bb0 <openFile>:

int openFile(char* path, int omode)
{
80106bb0:	55                   	push   %ebp
80106bb1:	89 e5                	mov    %esp,%ebp
80106bb3:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106bb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bbc:	8b 40 68             	mov    0x68(%eax),%eax
80106bbf:	8b 40 50             	mov    0x50(%eax),%eax
80106bc2:	8b 40 14             	mov    0x14(%eax),%eax
80106bc5:	83 ec 0c             	sub    $0xc,%esp
80106bc8:	50                   	push   %eax
80106bc9:	e8 d4 d2 ff ff       	call   80103ea2 <begin_op>
80106bce:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bd4:	25 00 02 00 00       	and    $0x200,%eax
80106bd9:	85 c0                	test   %eax,%eax
80106bdb:	74 43                	je     80106c20 <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106bdd:	6a 00                	push   $0x0
80106bdf:	6a 00                	push   $0x0
80106be1:	6a 02                	push   $0x2
80106be3:	ff 75 08             	pushl  0x8(%ebp)
80106be6:	e8 9b fd ff ff       	call   80106986 <create>
80106beb:	83 c4 10             	add    $0x10,%esp
80106bee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106bf1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bf5:	0f 85 b5 00 00 00    	jne    80106cb0 <openFile+0x100>
            end_op(proc->cwd->part->number);
80106bfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c01:	8b 40 68             	mov    0x68(%eax),%eax
80106c04:	8b 40 50             	mov    0x50(%eax),%eax
80106c07:	8b 40 14             	mov    0x14(%eax),%eax
80106c0a:	83 ec 0c             	sub    $0xc,%esp
80106c0d:	50                   	push   %eax
80106c0e:	e8 96 d3 ff ff       	call   80103fa9 <end_op>
80106c13:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c1b:	e9 7f 01 00 00       	jmp    80106d9f <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c20:	83 ec 0c             	sub    $0xc,%esp
80106c23:	ff 75 08             	pushl  0x8(%ebp)
80106c26:	e8 d9 c0 ff ff       	call   80102d04 <namei>
80106c2b:	83 c4 10             	add    $0x10,%esp
80106c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c35:	75 25                	jne    80106c5c <openFile+0xac>
            end_op(proc->cwd->part->number);
80106c37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c3d:	8b 40 68             	mov    0x68(%eax),%eax
80106c40:	8b 40 50             	mov    0x50(%eax),%eax
80106c43:	8b 40 14             	mov    0x14(%eax),%eax
80106c46:	83 ec 0c             	sub    $0xc,%esp
80106c49:	50                   	push   %eax
80106c4a:	e8 5a d3 ff ff       	call   80103fa9 <end_op>
80106c4f:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c57:	e9 43 01 00 00       	jmp    80106d9f <openFile+0x1ef>
        }
        ilock(ip);
80106c5c:	83 ec 0c             	sub    $0xc,%esp
80106c5f:	ff 75 f4             	pushl  -0xc(%ebp)
80106c62:	e8 7b b2 ff ff       	call   80101ee2 <ilock>
80106c67:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c71:	66 83 f8 01          	cmp    $0x1,%ax
80106c75:	75 39                	jne    80106cb0 <openFile+0x100>
80106c77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106c7b:	74 33                	je     80106cb0 <openFile+0x100>
            iunlockput(ip);
80106c7d:	83 ec 0c             	sub    $0xc,%esp
80106c80:	ff 75 f4             	pushl  -0xc(%ebp)
80106c83:	e8 5d b5 ff ff       	call   801021e5 <iunlockput>
80106c88:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106c8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c91:	8b 40 68             	mov    0x68(%eax),%eax
80106c94:	8b 40 50             	mov    0x50(%eax),%eax
80106c97:	8b 40 14             	mov    0x14(%eax),%eax
80106c9a:	83 ec 0c             	sub    $0xc,%esp
80106c9d:	50                   	push   %eax
80106c9e:	e8 06 d3 ff ff       	call   80103fa9 <end_op>
80106ca3:	83 c4 10             	add    $0x10,%esp
            return -1;
80106ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cab:	e9 ef 00 00 00       	jmp    80106d9f <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106cb0:	e8 36 a3 ff ff       	call   80100feb <filealloc>
80106cb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106cb8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cbc:	74 17                	je     80106cd5 <openFile+0x125>
80106cbe:	83 ec 0c             	sub    $0xc,%esp
80106cc1:	ff 75 f0             	pushl  -0x10(%ebp)
80106cc4:	e8 f0 f5 ff ff       	call   801062b9 <fdalloc>
80106cc9:	83 c4 10             	add    $0x10,%esp
80106ccc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106ccf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106cd3:	79 47                	jns    80106d1c <openFile+0x16c>
        if (f)
80106cd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cd9:	74 0e                	je     80106ce9 <openFile+0x139>
            fileclose(f);
80106cdb:	83 ec 0c             	sub    $0xc,%esp
80106cde:	ff 75 f0             	pushl  -0x10(%ebp)
80106ce1:	e8 c3 a3 ff ff       	call   801010a9 <fileclose>
80106ce6:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106ce9:	83 ec 0c             	sub    $0xc,%esp
80106cec:	ff 75 f4             	pushl  -0xc(%ebp)
80106cef:	e8 f1 b4 ff ff       	call   801021e5 <iunlockput>
80106cf4:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106cf7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cfd:	8b 40 68             	mov    0x68(%eax),%eax
80106d00:	8b 40 50             	mov    0x50(%eax),%eax
80106d03:	8b 40 14             	mov    0x14(%eax),%eax
80106d06:	83 ec 0c             	sub    $0xc,%esp
80106d09:	50                   	push   %eax
80106d0a:	e8 9a d2 ff ff       	call   80103fa9 <end_op>
80106d0f:	83 c4 10             	add    $0x10,%esp
        return -1;
80106d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d17:	e9 83 00 00 00       	jmp    80106d9f <openFile+0x1ef>
    }
    iunlock(ip);
80106d1c:	83 ec 0c             	sub    $0xc,%esp
80106d1f:	ff 75 f4             	pushl  -0xc(%ebp)
80106d22:	e8 5c b3 ff ff       	call   80102083 <iunlock>
80106d27:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106d2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d30:	8b 40 68             	mov    0x68(%eax),%eax
80106d33:	8b 40 50             	mov    0x50(%eax),%eax
80106d36:	8b 40 14             	mov    0x14(%eax),%eax
80106d39:	83 ec 0c             	sub    $0xc,%esp
80106d3c:	50                   	push   %eax
80106d3d:	e8 67 d2 ff ff       	call   80103fa9 <end_op>
80106d42:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d48:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d54:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d5a:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106d61:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d64:	83 e0 01             	and    $0x1,%eax
80106d67:	85 c0                	test   %eax,%eax
80106d69:	0f 94 c0             	sete   %al
80106d6c:	89 c2                	mov    %eax,%edx
80106d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d71:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d74:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d77:	83 e0 01             	and    $0x1,%eax
80106d7a:	85 c0                	test   %eax,%eax
80106d7c:	75 0a                	jne    80106d88 <openFile+0x1d8>
80106d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d81:	83 e0 02             	and    $0x2,%eax
80106d84:	85 c0                	test   %eax,%eax
80106d86:	74 07                	je     80106d8f <openFile+0x1df>
80106d88:	b8 01 00 00 00       	mov    $0x1,%eax
80106d8d:	eb 05                	jmp    80106d94 <openFile+0x1e4>
80106d8f:	b8 00 00 00 00       	mov    $0x0,%eax
80106d94:	89 c2                	mov    %eax,%edx
80106d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d99:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106d9f:	c9                   	leave  
80106da0:	c3                   	ret    

80106da1 <sys_mkdir>:

int sys_mkdir(void)
{
80106da1:	55                   	push   %ebp
80106da2:	89 e5                	mov    %esp,%ebp
80106da4:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dad:	8b 40 68             	mov    0x68(%eax),%eax
80106db0:	8b 40 50             	mov    0x50(%eax),%eax
80106db3:	8b 40 14             	mov    0x14(%eax),%eax
80106db6:	83 ec 0c             	sub    $0xc,%esp
80106db9:	50                   	push   %eax
80106dba:	e8 e3 d0 ff ff       	call   80103ea2 <begin_op>
80106dbf:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106dc2:	83 ec 08             	sub    $0x8,%esp
80106dc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dc8:	50                   	push   %eax
80106dc9:	6a 00                	push   $0x0
80106dcb:	e8 bd f3 ff ff       	call   8010618d <argstr>
80106dd0:	83 c4 10             	add    $0x10,%esp
80106dd3:	85 c0                	test   %eax,%eax
80106dd5:	78 1b                	js     80106df2 <sys_mkdir+0x51>
80106dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dda:	6a 00                	push   $0x0
80106ddc:	6a 00                	push   $0x0
80106dde:	6a 01                	push   $0x1
80106de0:	50                   	push   %eax
80106de1:	e8 a0 fb ff ff       	call   80106986 <create>
80106de6:	83 c4 10             	add    $0x10,%esp
80106de9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106dec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106df0:	75 22                	jne    80106e14 <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106df2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106df8:	8b 40 68             	mov    0x68(%eax),%eax
80106dfb:	8b 40 50             	mov    0x50(%eax),%eax
80106dfe:	8b 40 14             	mov    0x14(%eax),%eax
80106e01:	83 ec 0c             	sub    $0xc,%esp
80106e04:	50                   	push   %eax
80106e05:	e8 9f d1 ff ff       	call   80103fa9 <end_op>
80106e0a:	83 c4 10             	add    $0x10,%esp
        return -1;
80106e0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e12:	eb 2e                	jmp    80106e42 <sys_mkdir+0xa1>
    }
    iunlockput(ip);
80106e14:	83 ec 0c             	sub    $0xc,%esp
80106e17:	ff 75 f4             	pushl  -0xc(%ebp)
80106e1a:	e8 c6 b3 ff ff       	call   801021e5 <iunlockput>
80106e1f:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e28:	8b 40 68             	mov    0x68(%eax),%eax
80106e2b:	8b 40 50             	mov    0x50(%eax),%eax
80106e2e:	8b 40 14             	mov    0x14(%eax),%eax
80106e31:	83 ec 0c             	sub    $0xc,%esp
80106e34:	50                   	push   %eax
80106e35:	e8 6f d1 ff ff       	call   80103fa9 <end_op>
80106e3a:	83 c4 10             	add    $0x10,%esp
    return 0;
80106e3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e42:	c9                   	leave  
80106e43:	c3                   	ret    

80106e44 <sys_mknod>:

int sys_mknod(void)
{
80106e44:	55                   	push   %ebp
80106e45:	89 e5                	mov    %esp,%ebp
80106e47:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106e4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e50:	8b 40 68             	mov    0x68(%eax),%eax
80106e53:	8b 40 50             	mov    0x50(%eax),%eax
80106e56:	8b 40 14             	mov    0x14(%eax),%eax
80106e59:	83 ec 0c             	sub    $0xc,%esp
80106e5c:	50                   	push   %eax
80106e5d:	e8 40 d0 ff ff       	call   80103ea2 <begin_op>
80106e62:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106e65:	83 ec 08             	sub    $0x8,%esp
80106e68:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e6b:	50                   	push   %eax
80106e6c:	6a 00                	push   $0x0
80106e6e:	e8 1a f3 ff ff       	call   8010618d <argstr>
80106e73:	83 c4 10             	add    $0x10,%esp
80106e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e7d:	78 4f                	js     80106ece <sys_mknod+0x8a>
80106e7f:	83 ec 08             	sub    $0x8,%esp
80106e82:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e85:	50                   	push   %eax
80106e86:	6a 01                	push   $0x1
80106e88:	e8 7b f2 ff ff       	call   80106108 <argint>
80106e8d:	83 c4 10             	add    $0x10,%esp
80106e90:	85 c0                	test   %eax,%eax
80106e92:	78 3a                	js     80106ece <sys_mknod+0x8a>
80106e94:	83 ec 08             	sub    $0x8,%esp
80106e97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e9a:	50                   	push   %eax
80106e9b:	6a 02                	push   $0x2
80106e9d:	e8 66 f2 ff ff       	call   80106108 <argint>
80106ea2:	83 c4 10             	add    $0x10,%esp
80106ea5:	85 c0                	test   %eax,%eax
80106ea7:	78 25                	js     80106ece <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106eac:	0f bf c8             	movswl %ax,%ecx
80106eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106eb2:	0f bf d0             	movswl %ax,%edx
80106eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106eb8:	51                   	push   %ecx
80106eb9:	52                   	push   %edx
80106eba:	6a 03                	push   $0x3
80106ebc:	50                   	push   %eax
80106ebd:	e8 c4 fa ff ff       	call   80106986 <create>
80106ec2:	83 c4 10             	add    $0x10,%esp
80106ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ec8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ecc:	75 22                	jne    80106ef0 <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed4:	8b 40 68             	mov    0x68(%eax),%eax
80106ed7:	8b 40 50             	mov    0x50(%eax),%eax
80106eda:	8b 40 14             	mov    0x14(%eax),%eax
80106edd:	83 ec 0c             	sub    $0xc,%esp
80106ee0:	50                   	push   %eax
80106ee1:	e8 c3 d0 ff ff       	call   80103fa9 <end_op>
80106ee6:	83 c4 10             	add    $0x10,%esp
        return -1;
80106ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eee:	eb 2e                	jmp    80106f1e <sys_mknod+0xda>
    }
    iunlockput(ip);
80106ef0:	83 ec 0c             	sub    $0xc,%esp
80106ef3:	ff 75 f0             	pushl  -0x10(%ebp)
80106ef6:	e8 ea b2 ff ff       	call   801021e5 <iunlockput>
80106efb:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106efe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f04:	8b 40 68             	mov    0x68(%eax),%eax
80106f07:	8b 40 50             	mov    0x50(%eax),%eax
80106f0a:	8b 40 14             	mov    0x14(%eax),%eax
80106f0d:	83 ec 0c             	sub    $0xc,%esp
80106f10:	50                   	push   %eax
80106f11:	e8 93 d0 ff ff       	call   80103fa9 <end_op>
80106f16:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f1e:	c9                   	leave  
80106f1f:	c3                   	ret    

80106f20 <sys_chdir>:

int sys_chdir(void)
{
80106f20:	55                   	push   %ebp
80106f21:	89 e5                	mov    %esp,%ebp
80106f23:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;


    begin_op(proc->cwd->part->number);
80106f26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f2c:	8b 40 68             	mov    0x68(%eax),%eax
80106f2f:	8b 40 50             	mov    0x50(%eax),%eax
80106f32:	8b 40 14             	mov    0x14(%eax),%eax
80106f35:	83 ec 0c             	sub    $0xc,%esp
80106f38:	50                   	push   %eax
80106f39:	e8 64 cf ff ff       	call   80103ea2 <begin_op>
80106f3e:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106f41:	83 ec 08             	sub    $0x8,%esp
80106f44:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f47:	50                   	push   %eax
80106f48:	6a 00                	push   $0x0
80106f4a:	e8 3e f2 ff ff       	call   8010618d <argstr>
80106f4f:	83 c4 10             	add    $0x10,%esp
80106f52:	85 c0                	test   %eax,%eax
80106f54:	78 18                	js     80106f6e <sys_chdir+0x4e>
80106f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f59:	83 ec 0c             	sub    $0xc,%esp
80106f5c:	50                   	push   %eax
80106f5d:	e8 a2 bd ff ff       	call   80102d04 <namei>
80106f62:	83 c4 10             	add    $0x10,%esp
80106f65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f6c:	75 25                	jne    80106f93 <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106f6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f74:	8b 40 68             	mov    0x68(%eax),%eax
80106f77:	8b 40 50             	mov    0x50(%eax),%eax
80106f7a:	8b 40 14             	mov    0x14(%eax),%eax
80106f7d:	83 ec 0c             	sub    $0xc,%esp
80106f80:	50                   	push   %eax
80106f81:	e8 23 d0 ff ff       	call   80103fa9 <end_op>
80106f86:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f8e:	e9 9a 00 00 00       	jmp    8010702d <sys_chdir+0x10d>
    }
    //cprintf("cd path %s \n",path);
    ilock(ip);
80106f93:	83 ec 0c             	sub    $0xc,%esp
80106f96:	ff 75 f4             	pushl  -0xc(%ebp)
80106f99:	e8 44 af ff ff       	call   80101ee2 <ilock>
80106f9e:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
80106fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106fa8:	66 83 f8 01          	cmp    $0x1,%ax
80106fac:	74 30                	je     80106fde <sys_chdir+0xbe>
        iunlockput(ip);
80106fae:	83 ec 0c             	sub    $0xc,%esp
80106fb1:	ff 75 f4             	pushl  -0xc(%ebp)
80106fb4:	e8 2c b2 ff ff       	call   801021e5 <iunlockput>
80106fb9:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106fbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc2:	8b 40 68             	mov    0x68(%eax),%eax
80106fc5:	8b 40 50             	mov    0x50(%eax),%eax
80106fc8:	8b 40 14             	mov    0x14(%eax),%eax
80106fcb:	83 ec 0c             	sub    $0xc,%esp
80106fce:	50                   	push   %eax
80106fcf:	e8 d5 cf ff ff       	call   80103fa9 <end_op>
80106fd4:	83 c4 10             	add    $0x10,%esp
        return -1;
80106fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fdc:	eb 4f                	jmp    8010702d <sys_chdir+0x10d>
    }
    iunlock(ip);
80106fde:	83 ec 0c             	sub    $0xc,%esp
80106fe1:	ff 75 f4             	pushl  -0xc(%ebp)
80106fe4:	e8 9a b0 ff ff       	call   80102083 <iunlock>
80106fe9:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80106fec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ff2:	8b 40 68             	mov    0x68(%eax),%eax
80106ff5:	83 ec 0c             	sub    $0xc,%esp
80106ff8:	50                   	push   %eax
80106ff9:	e8 f7 b0 ff ff       	call   801020f5 <iput>
80106ffe:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80107001:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107007:	8b 40 68             	mov    0x68(%eax),%eax
8010700a:	8b 40 50             	mov    0x50(%eax),%eax
8010700d:	8b 40 14             	mov    0x14(%eax),%eax
80107010:	83 ec 0c             	sub    $0xc,%esp
80107013:	50                   	push   %eax
80107014:	e8 90 cf ff ff       	call   80103fa9 <end_op>
80107019:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
8010701c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107022:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107025:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
80107028:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010702d:	c9                   	leave  
8010702e:	c3                   	ret    

8010702f <sys_exec>:

int sys_exec(void)
{
8010702f:	55                   	push   %ebp
80107030:	89 e5                	mov    %esp,%ebp
80107032:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
80107038:	83 ec 08             	sub    $0x8,%esp
8010703b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010703e:	50                   	push   %eax
8010703f:	6a 00                	push   $0x0
80107041:	e8 47 f1 ff ff       	call   8010618d <argstr>
80107046:	83 c4 10             	add    $0x10,%esp
80107049:	85 c0                	test   %eax,%eax
8010704b:	78 18                	js     80107065 <sys_exec+0x36>
8010704d:	83 ec 08             	sub    $0x8,%esp
80107050:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107056:	50                   	push   %eax
80107057:	6a 01                	push   $0x1
80107059:	e8 aa f0 ff ff       	call   80106108 <argint>
8010705e:	83 c4 10             	add    $0x10,%esp
80107061:	85 c0                	test   %eax,%eax
80107063:	79 0a                	jns    8010706f <sys_exec+0x40>
        return -1;
80107065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010706a:	e9 c6 00 00 00       	jmp    80107135 <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
8010706f:	83 ec 04             	sub    $0x4,%esp
80107072:	68 80 00 00 00       	push   $0x80
80107077:	6a 00                	push   $0x0
80107079:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010707f:	50                   	push   %eax
80107080:	e8 5e ed ff ff       	call   80105de3 <memset>
80107085:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
80107088:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
8010708f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107092:	83 f8 1f             	cmp    $0x1f,%eax
80107095:	76 0a                	jbe    801070a1 <sys_exec+0x72>
            return -1;
80107097:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010709c:	e9 94 00 00 00       	jmp    80107135 <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
801070a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a4:	c1 e0 02             	shl    $0x2,%eax
801070a7:	89 c2                	mov    %eax,%edx
801070a9:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801070af:	01 c2                	add    %eax,%edx
801070b1:	83 ec 08             	sub    $0x8,%esp
801070b4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801070ba:	50                   	push   %eax
801070bb:	52                   	push   %edx
801070bc:	e8 ab ef ff ff       	call   8010606c <fetchint>
801070c1:	83 c4 10             	add    $0x10,%esp
801070c4:	85 c0                	test   %eax,%eax
801070c6:	79 07                	jns    801070cf <sys_exec+0xa0>
            return -1;
801070c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070cd:	eb 66                	jmp    80107135 <sys_exec+0x106>
        if (uarg == 0) {
801070cf:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801070d5:	85 c0                	test   %eax,%eax
801070d7:	75 27                	jne    80107100 <sys_exec+0xd1>
            argv[i] = 0;
801070d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070dc:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801070e3:	00 00 00 00 
            break;
801070e7:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
801070e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070eb:	83 ec 08             	sub    $0x8,%esp
801070ee:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801070f4:	52                   	push   %edx
801070f5:	50                   	push   %eax
801070f6:	e8 76 9a ff ff       	call   80100b71 <exec>
801070fb:	83 c4 10             	add    $0x10,%esp
801070fe:	eb 35                	jmp    80107135 <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80107100:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107106:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107109:	c1 e2 02             	shl    $0x2,%edx
8010710c:	01 c2                	add    %eax,%edx
8010710e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107114:	83 ec 08             	sub    $0x8,%esp
80107117:	52                   	push   %edx
80107118:	50                   	push   %eax
80107119:	e8 88 ef ff ff       	call   801060a6 <fetchstr>
8010711e:	83 c4 10             	add    $0x10,%esp
80107121:	85 c0                	test   %eax,%eax
80107123:	79 07                	jns    8010712c <sys_exec+0xfd>
            return -1;
80107125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010712a:	eb 09                	jmp    80107135 <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
8010712c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
80107130:	e9 5a ff ff ff       	jmp    8010708f <sys_exec+0x60>
    return exec(path, argv);
}
80107135:	c9                   	leave  
80107136:	c3                   	ret    

80107137 <sys_pipe>:

int sys_pipe(void)
{
80107137:	55                   	push   %ebp
80107138:	89 e5                	mov    %esp,%ebp
8010713a:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
8010713d:	83 ec 04             	sub    $0x4,%esp
80107140:	6a 08                	push   $0x8
80107142:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107145:	50                   	push   %eax
80107146:	6a 00                	push   $0x0
80107148:	e8 e3 ef ff ff       	call   80106130 <argptr>
8010714d:	83 c4 10             	add    $0x10,%esp
80107150:	85 c0                	test   %eax,%eax
80107152:	79 0a                	jns    8010715e <sys_pipe+0x27>
        return -1;
80107154:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107159:	e9 af 00 00 00       	jmp    8010720d <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
8010715e:	83 ec 08             	sub    $0x8,%esp
80107161:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107164:	50                   	push   %eax
80107165:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107168:	50                   	push   %eax
80107169:	e8 04 da ff ff       	call   80104b72 <pipealloc>
8010716e:	83 c4 10             	add    $0x10,%esp
80107171:	85 c0                	test   %eax,%eax
80107173:	79 0a                	jns    8010717f <sys_pipe+0x48>
        return -1;
80107175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010717a:	e9 8e 00 00 00       	jmp    8010720d <sys_pipe+0xd6>
    fd0 = -1;
8010717f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80107186:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107189:	83 ec 0c             	sub    $0xc,%esp
8010718c:	50                   	push   %eax
8010718d:	e8 27 f1 ff ff       	call   801062b9 <fdalloc>
80107192:	83 c4 10             	add    $0x10,%esp
80107195:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107198:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010719c:	78 18                	js     801071b6 <sys_pipe+0x7f>
8010719e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071a1:	83 ec 0c             	sub    $0xc,%esp
801071a4:	50                   	push   %eax
801071a5:	e8 0f f1 ff ff       	call   801062b9 <fdalloc>
801071aa:	83 c4 10             	add    $0x10,%esp
801071ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801071b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801071b4:	79 3f                	jns    801071f5 <sys_pipe+0xbe>
        if (fd0 >= 0)
801071b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071ba:	78 14                	js     801071d0 <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
801071bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071c5:	83 c2 08             	add    $0x8,%edx
801071c8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801071cf:	00 
        fileclose(rf);
801071d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071d3:	83 ec 0c             	sub    $0xc,%esp
801071d6:	50                   	push   %eax
801071d7:	e8 cd 9e ff ff       	call   801010a9 <fileclose>
801071dc:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
801071df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071e2:	83 ec 0c             	sub    $0xc,%esp
801071e5:	50                   	push   %eax
801071e6:	e8 be 9e ff ff       	call   801010a9 <fileclose>
801071eb:	83 c4 10             	add    $0x10,%esp
        return -1;
801071ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071f3:	eb 18                	jmp    8010720d <sys_pipe+0xd6>
    }
    fd[0] = fd0;
801071f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071fb:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
801071fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107200:	8d 50 04             	lea    0x4(%eax),%edx
80107203:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107206:	89 02                	mov    %eax,(%edx)
    return 0;
80107208:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010720d:	c9                   	leave  
8010720e:	c3                   	ret    

8010720f <sys_mount>:

int sys_mount(void)
{
8010720f:	55                   	push   %ebp
80107210:	89 e5                	mov    %esp,%ebp
80107212:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
80107215:	83 ec 08             	sub    $0x8,%esp
80107218:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010721b:	50                   	push   %eax
8010721c:	6a 00                	push   $0x0
8010721e:	e8 6a ef ff ff       	call   8010618d <argstr>
80107223:	83 c4 10             	add    $0x10,%esp
80107226:	85 c0                	test   %eax,%eax
80107228:	78 1d                	js     80107247 <sys_mount+0x38>
8010722a:	83 ec 08             	sub    $0x8,%esp
8010722d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107230:	50                   	push   %eax
80107231:	6a 01                	push   $0x1
80107233:	e8 d0 ee ff ff       	call   80106108 <argint>
80107238:	83 c4 10             	add    $0x10,%esp
8010723b:	85 c0                	test   %eax,%eax
8010723d:	78 08                	js     80107247 <sys_mount+0x38>
8010723f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107242:	83 f8 04             	cmp    $0x4,%eax
80107245:	76 0a                	jbe    80107251 <sys_mount+0x42>
        return -1;
80107247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010724c:	e9 a4 00 00 00       	jmp    801072f5 <sys_mount+0xe6>
    }
    //cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);

    i=nameiIgnoreMounts(path);
80107251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107254:	83 ec 0c             	sub    $0xc,%esp
80107257:	50                   	push   %eax
80107258:	e8 c2 ba ff ff       	call   80102d1f <nameiIgnoreMounts>
8010725d:	83 c4 10             	add    $0x10,%esp
80107260:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
80107263:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107267:	75 0a                	jne    80107273 <sys_mount+0x64>
        return -1;
80107269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010726e:	e9 82 00 00 00       	jmp    801072f5 <sys_mount+0xe6>
    }
    ilock(i);
80107273:	83 ec 0c             	sub    $0xc,%esp
80107276:	ff 75 f4             	pushl  -0xc(%ebp)
80107279:	e8 64 ac ff ff       	call   80101ee2 <ilock>
8010727e:	83 c4 10             	add    $0x10,%esp
    if(i->type!=T_DIR){
80107281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107284:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107288:	66 83 f8 01          	cmp    $0x1,%ax
8010728c:	74 07                	je     80107295 <sys_mount+0x86>
        return -1;
8010728e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107293:	eb 60                	jmp    801072f5 <sys_mount+0xe6>
    }
    i->major=MOUNTING_POINT;
80107295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107298:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
8010729e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072a1:	89 c2                	mov    %eax,%edx
801072a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a6:	66 89 50 14          	mov    %dx,0x14(%eax)
    begin_op(i->part->number);
801072aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ad:	8b 40 50             	mov    0x50(%eax),%eax
801072b0:	8b 40 14             	mov    0x14(%eax),%eax
801072b3:	83 ec 0c             	sub    $0xc,%esp
801072b6:	50                   	push   %eax
801072b7:	e8 e6 cb ff ff       	call   80103ea2 <begin_op>
801072bc:	83 c4 10             	add    $0x10,%esp
    iupdate(i);
801072bf:	83 ec 0c             	sub    $0xc,%esp
801072c2:	ff 75 f4             	pushl  -0xc(%ebp)
801072c5:	e8 ba a9 ff ff       	call   80101c84 <iupdate>
801072ca:	83 c4 10             	add    $0x10,%esp
    end_op(i->part->number);
801072cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d0:	8b 40 50             	mov    0x50(%eax),%eax
801072d3:	8b 40 14             	mov    0x14(%eax),%eax
801072d6:	83 ec 0c             	sub    $0xc,%esp
801072d9:	50                   	push   %eax
801072da:	e8 ca cc ff ff       	call   80103fa9 <end_op>
801072df:	83 c4 10             	add    $0x10,%esp
    iunlockput(i);
801072e2:	83 ec 0c             	sub    $0xc,%esp
801072e5:	ff 75 f4             	pushl  -0xc(%ebp)
801072e8:	e8 f8 ae ff ff       	call   801021e5 <iunlockput>
801072ed:	83 c4 10             	add    $0x10,%esp
   // cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);
    return 0;
801072f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072f5:	c9                   	leave  
801072f6:	c3                   	ret    

801072f7 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801072f7:	55                   	push   %ebp
801072f8:	89 e5                	mov    %esp,%ebp
801072fa:	83 ec 08             	sub    $0x8,%esp
  return fork();
801072fd:	e8 66 df ff ff       	call   80105268 <fork>
}
80107302:	c9                   	leave  
80107303:	c3                   	ret    

80107304 <sys_exit>:

int
sys_exit(void)
{
80107304:	55                   	push   %ebp
80107305:	89 e5                	mov    %esp,%ebp
80107307:	83 ec 08             	sub    $0x8,%esp
  exit();
8010730a:	e8 ea e0 ff ff       	call   801053f9 <exit>
  return 0;  // not reached
8010730f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107314:	c9                   	leave  
80107315:	c3                   	ret    

80107316 <sys_wait>:

int
sys_wait(void)
{
80107316:	55                   	push   %ebp
80107317:	89 e5                	mov    %esp,%ebp
80107319:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010731c:	e8 3c e2 ff ff       	call   8010555d <wait>
}
80107321:	c9                   	leave  
80107322:	c3                   	ret    

80107323 <sys_kill>:

int
sys_kill(void)
{
80107323:	55                   	push   %ebp
80107324:	89 e5                	mov    %esp,%ebp
80107326:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107329:	83 ec 08             	sub    $0x8,%esp
8010732c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010732f:	50                   	push   %eax
80107330:	6a 00                	push   $0x0
80107332:	e8 d1 ed ff ff       	call   80106108 <argint>
80107337:	83 c4 10             	add    $0x10,%esp
8010733a:	85 c0                	test   %eax,%eax
8010733c:	79 07                	jns    80107345 <sys_kill+0x22>
    return -1;
8010733e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107343:	eb 0f                	jmp    80107354 <sys_kill+0x31>
  return kill(pid);
80107345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107348:	83 ec 0c             	sub    $0xc,%esp
8010734b:	50                   	push   %eax
8010734c:	e8 58 e6 ff ff       	call   801059a9 <kill>
80107351:	83 c4 10             	add    $0x10,%esp
}
80107354:	c9                   	leave  
80107355:	c3                   	ret    

80107356 <sys_getpid>:

int
sys_getpid(void)
{
80107356:	55                   	push   %ebp
80107357:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107359:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010735f:	8b 40 10             	mov    0x10(%eax),%eax
}
80107362:	5d                   	pop    %ebp
80107363:	c3                   	ret    

80107364 <sys_sbrk>:

int
sys_sbrk(void)
{
80107364:	55                   	push   %ebp
80107365:	89 e5                	mov    %esp,%ebp
80107367:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010736a:	83 ec 08             	sub    $0x8,%esp
8010736d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107370:	50                   	push   %eax
80107371:	6a 00                	push   $0x0
80107373:	e8 90 ed ff ff       	call   80106108 <argint>
80107378:	83 c4 10             	add    $0x10,%esp
8010737b:	85 c0                	test   %eax,%eax
8010737d:	79 07                	jns    80107386 <sys_sbrk+0x22>
    return -1;
8010737f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107384:	eb 28                	jmp    801073ae <sys_sbrk+0x4a>
  addr = proc->sz;
80107386:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010738c:	8b 00                	mov    (%eax),%eax
8010738e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107394:	83 ec 0c             	sub    $0xc,%esp
80107397:	50                   	push   %eax
80107398:	e8 28 de ff ff       	call   801051c5 <growproc>
8010739d:	83 c4 10             	add    $0x10,%esp
801073a0:	85 c0                	test   %eax,%eax
801073a2:	79 07                	jns    801073ab <sys_sbrk+0x47>
    return -1;
801073a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073a9:	eb 03                	jmp    801073ae <sys_sbrk+0x4a>
  return addr;
801073ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801073ae:	c9                   	leave  
801073af:	c3                   	ret    

801073b0 <sys_sleep>:

int
sys_sleep(void)
{
801073b0:	55                   	push   %ebp
801073b1:	89 e5                	mov    %esp,%ebp
801073b3:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801073b6:	83 ec 08             	sub    $0x8,%esp
801073b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073bc:	50                   	push   %eax
801073bd:	6a 00                	push   $0x0
801073bf:	e8 44 ed ff ff       	call   80106108 <argint>
801073c4:	83 c4 10             	add    $0x10,%esp
801073c7:	85 c0                	test   %eax,%eax
801073c9:	79 07                	jns    801073d2 <sys_sleep+0x22>
    return -1;
801073cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d0:	eb 77                	jmp    80107449 <sys_sleep+0x99>
  acquire(&tickslock);
801073d2:	83 ec 0c             	sub    $0xc,%esp
801073d5:	68 c0 5d 11 80       	push   $0x80115dc0
801073da:	e8 a1 e7 ff ff       	call   80105b80 <acquire>
801073df:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801073e2:	a1 00 66 11 80       	mov    0x80116600,%eax
801073e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801073ea:	eb 39                	jmp    80107425 <sys_sleep+0x75>
    if(proc->killed){
801073ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073f2:	8b 40 24             	mov    0x24(%eax),%eax
801073f5:	85 c0                	test   %eax,%eax
801073f7:	74 17                	je     80107410 <sys_sleep+0x60>
      release(&tickslock);
801073f9:	83 ec 0c             	sub    $0xc,%esp
801073fc:	68 c0 5d 11 80       	push   $0x80115dc0
80107401:	e8 e1 e7 ff ff       	call   80105be7 <release>
80107406:	83 c4 10             	add    $0x10,%esp
      return -1;
80107409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010740e:	eb 39                	jmp    80107449 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107410:	83 ec 08             	sub    $0x8,%esp
80107413:	68 c0 5d 11 80       	push   $0x80115dc0
80107418:	68 00 66 11 80       	push   $0x80116600
8010741d:	e8 65 e4 ff ff       	call   80105887 <sleep>
80107422:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107425:	a1 00 66 11 80       	mov    0x80116600,%eax
8010742a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010742d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107430:	39 d0                	cmp    %edx,%eax
80107432:	72 b8                	jb     801073ec <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107434:	83 ec 0c             	sub    $0xc,%esp
80107437:	68 c0 5d 11 80       	push   $0x80115dc0
8010743c:	e8 a6 e7 ff ff       	call   80105be7 <release>
80107441:	83 c4 10             	add    $0x10,%esp
  return 0;
80107444:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107449:	c9                   	leave  
8010744a:	c3                   	ret    

8010744b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010744b:	55                   	push   %ebp
8010744c:	89 e5                	mov    %esp,%ebp
8010744e:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80107451:	83 ec 0c             	sub    $0xc,%esp
80107454:	68 c0 5d 11 80       	push   $0x80115dc0
80107459:	e8 22 e7 ff ff       	call   80105b80 <acquire>
8010745e:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107461:	a1 00 66 11 80       	mov    0x80116600,%eax
80107466:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107469:	83 ec 0c             	sub    $0xc,%esp
8010746c:	68 c0 5d 11 80       	push   $0x80115dc0
80107471:	e8 71 e7 ff ff       	call   80105be7 <release>
80107476:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107479:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010747c:	c9                   	leave  
8010747d:	c3                   	ret    

8010747e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010747e:	55                   	push   %ebp
8010747f:	89 e5                	mov    %esp,%ebp
80107481:	83 ec 08             	sub    $0x8,%esp
80107484:	8b 55 08             	mov    0x8(%ebp),%edx
80107487:	8b 45 0c             	mov    0xc(%ebp),%eax
8010748a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010748e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107491:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107495:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107499:	ee                   	out    %al,(%dx)
}
8010749a:	90                   	nop
8010749b:	c9                   	leave  
8010749c:	c3                   	ret    

8010749d <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010749d:	55                   	push   %ebp
8010749e:	89 e5                	mov    %esp,%ebp
801074a0:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801074a3:	6a 34                	push   $0x34
801074a5:	6a 43                	push   $0x43
801074a7:	e8 d2 ff ff ff       	call   8010747e <outb>
801074ac:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801074af:	68 9c 00 00 00       	push   $0x9c
801074b4:	6a 40                	push   $0x40
801074b6:	e8 c3 ff ff ff       	call   8010747e <outb>
801074bb:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801074be:	6a 2e                	push   $0x2e
801074c0:	6a 40                	push   $0x40
801074c2:	e8 b7 ff ff ff       	call   8010747e <outb>
801074c7:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801074ca:	83 ec 0c             	sub    $0xc,%esp
801074cd:	6a 00                	push   $0x0
801074cf:	e8 88 d5 ff ff       	call   80104a5c <picenable>
801074d4:	83 c4 10             	add    $0x10,%esp
}
801074d7:	90                   	nop
801074d8:	c9                   	leave  
801074d9:	c3                   	ret    

801074da <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801074da:	1e                   	push   %ds
  pushl %es
801074db:	06                   	push   %es
  pushl %fs
801074dc:	0f a0                	push   %fs
  pushl %gs
801074de:	0f a8                	push   %gs
  pushal
801074e0:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801074e1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801074e5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801074e7:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801074e9:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801074ed:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801074ef:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801074f1:	54                   	push   %esp
  call trap
801074f2:	e8 d7 01 00 00       	call   801076ce <trap>
  addl $4, %esp
801074f7:	83 c4 04             	add    $0x4,%esp

801074fa <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801074fa:	61                   	popa   
  popl %gs
801074fb:	0f a9                	pop    %gs
  popl %fs
801074fd:	0f a1                	pop    %fs
  popl %es
801074ff:	07                   	pop    %es
  popl %ds
80107500:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107501:	83 c4 08             	add    $0x8,%esp
  iret
80107504:	cf                   	iret   

80107505 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107505:	55                   	push   %ebp
80107506:	89 e5                	mov    %esp,%ebp
80107508:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010750b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010750e:	83 e8 01             	sub    $0x1,%eax
80107511:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107515:	8b 45 08             	mov    0x8(%ebp),%eax
80107518:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010751c:	8b 45 08             	mov    0x8(%ebp),%eax
8010751f:	c1 e8 10             	shr    $0x10,%eax
80107522:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107526:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107529:	0f 01 18             	lidtl  (%eax)
}
8010752c:	90                   	nop
8010752d:	c9                   	leave  
8010752e:	c3                   	ret    

8010752f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010752f:	55                   	push   %ebp
80107530:	89 e5                	mov    %esp,%ebp
80107532:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107535:	0f 20 d0             	mov    %cr2,%eax
80107538:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010753b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010753e:	c9                   	leave  
8010753f:	c3                   	ret    

80107540 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107540:	55                   	push   %ebp
80107541:	89 e5                	mov    %esp,%ebp
80107543:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010754d:	e9 c3 00 00 00       	jmp    80107615 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010755c:	89 c2                	mov    %eax,%edx
8010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107561:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
80107568:	80 
80107569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756c:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
80107573:	80 08 00 
80107576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107579:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107580:	80 
80107581:	83 e2 e0             	and    $0xffffffe0,%edx
80107584:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
8010758b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758e:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107595:	80 
80107596:	83 e2 1f             	and    $0x1f,%edx
80107599:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
801075a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a3:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075aa:	80 
801075ab:	83 e2 f0             	and    $0xfffffff0,%edx
801075ae:	83 ca 0e             	or     $0xe,%edx
801075b1:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bb:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075c2:	80 
801075c3:	83 e2 ef             	and    $0xffffffef,%edx
801075c6:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d0:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075d7:	80 
801075d8:	83 e2 9f             	and    $0xffffff9f,%edx
801075db:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075ec:	80 
801075ed:	83 ca 80             	or     $0xffffff80,%edx
801075f0:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fa:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
80107601:	c1 e8 10             	shr    $0x10,%eax
80107604:	89 c2                	mov    %eax,%edx
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
80107610:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107611:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107615:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010761c:	0f 8e 30 ff ff ff    	jle    80107552 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107622:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107627:	66 a3 00 60 11 80    	mov    %ax,0x80116000
8010762d:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
80107634:	08 00 
80107636:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
8010763d:	83 e0 e0             	and    $0xffffffe0,%eax
80107640:	a2 04 60 11 80       	mov    %al,0x80116004
80107645:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
8010764c:	83 e0 1f             	and    $0x1f,%eax
8010764f:	a2 04 60 11 80       	mov    %al,0x80116004
80107654:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010765b:	83 c8 0f             	or     $0xf,%eax
8010765e:	a2 05 60 11 80       	mov    %al,0x80116005
80107663:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010766a:	83 e0 ef             	and    $0xffffffef,%eax
8010766d:	a2 05 60 11 80       	mov    %al,0x80116005
80107672:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107679:	83 c8 60             	or     $0x60,%eax
8010767c:	a2 05 60 11 80       	mov    %al,0x80116005
80107681:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107688:	83 c8 80             	or     $0xffffff80,%eax
8010768b:	a2 05 60 11 80       	mov    %al,0x80116005
80107690:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107695:	c1 e8 10             	shr    $0x10,%eax
80107698:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
8010769e:	83 ec 08             	sub    $0x8,%esp
801076a1:	68 64 99 10 80       	push   $0x80109964
801076a6:	68 c0 5d 11 80       	push   $0x80115dc0
801076ab:	e8 ae e4 ff ff       	call   80105b5e <initlock>
801076b0:	83 c4 10             	add    $0x10,%esp
}
801076b3:	90                   	nop
801076b4:	c9                   	leave  
801076b5:	c3                   	ret    

801076b6 <idtinit>:

void
idtinit(void)
{
801076b6:	55                   	push   %ebp
801076b7:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801076b9:	68 00 08 00 00       	push   $0x800
801076be:	68 00 5e 11 80       	push   $0x80115e00
801076c3:	e8 3d fe ff ff       	call   80107505 <lidt>
801076c8:	83 c4 08             	add    $0x8,%esp
}
801076cb:	90                   	nop
801076cc:	c9                   	leave  
801076cd:	c3                   	ret    

801076ce <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801076ce:	55                   	push   %ebp
801076cf:	89 e5                	mov    %esp,%ebp
801076d1:	57                   	push   %edi
801076d2:	56                   	push   %esi
801076d3:	53                   	push   %ebx
801076d4:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801076d7:	8b 45 08             	mov    0x8(%ebp),%eax
801076da:	8b 40 30             	mov    0x30(%eax),%eax
801076dd:	83 f8 40             	cmp    $0x40,%eax
801076e0:	75 3e                	jne    80107720 <trap+0x52>
    if(proc->killed)
801076e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076e8:	8b 40 24             	mov    0x24(%eax),%eax
801076eb:	85 c0                	test   %eax,%eax
801076ed:	74 05                	je     801076f4 <trap+0x26>
      exit();
801076ef:	e8 05 dd ff ff       	call   801053f9 <exit>
    proc->tf = tf;
801076f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076fa:	8b 55 08             	mov    0x8(%ebp),%edx
801076fd:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107700:	e8 b9 ea ff ff       	call   801061be <syscall>
    if(proc->killed)
80107705:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010770b:	8b 40 24             	mov    0x24(%eax),%eax
8010770e:	85 c0                	test   %eax,%eax
80107710:	0f 84 1b 02 00 00    	je     80107931 <trap+0x263>
      exit();
80107716:	e8 de dc ff ff       	call   801053f9 <exit>
    return;
8010771b:	e9 11 02 00 00       	jmp    80107931 <trap+0x263>
  }

  switch(tf->trapno){
80107720:	8b 45 08             	mov    0x8(%ebp),%eax
80107723:	8b 40 30             	mov    0x30(%eax),%eax
80107726:	83 e8 20             	sub    $0x20,%eax
80107729:	83 f8 1f             	cmp    $0x1f,%eax
8010772c:	0f 87 c0 00 00 00    	ja     801077f2 <trap+0x124>
80107732:	8b 04 85 0c 9a 10 80 	mov    -0x7fef65f4(,%eax,4),%eax
80107739:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010773b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107741:	0f b6 00             	movzbl (%eax),%eax
80107744:	84 c0                	test   %al,%al
80107746:	75 3d                	jne    80107785 <trap+0xb7>
      acquire(&tickslock);
80107748:	83 ec 0c             	sub    $0xc,%esp
8010774b:	68 c0 5d 11 80       	push   $0x80115dc0
80107750:	e8 2b e4 ff ff       	call   80105b80 <acquire>
80107755:	83 c4 10             	add    $0x10,%esp
      ticks++;
80107758:	a1 00 66 11 80       	mov    0x80116600,%eax
8010775d:	83 c0 01             	add    $0x1,%eax
80107760:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
80107765:	83 ec 0c             	sub    $0xc,%esp
80107768:	68 00 66 11 80       	push   $0x80116600
8010776d:	e8 00 e2 ff ff       	call   80105972 <wakeup>
80107772:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107775:	83 ec 0c             	sub    $0xc,%esp
80107778:	68 c0 5d 11 80       	push   $0x80115dc0
8010777d:	e8 65 e4 ff ff       	call   80105be7 <release>
80107782:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107785:	e8 a0 c0 ff ff       	call   8010382a <lapiceoi>
    break;
8010778a:	e9 1c 01 00 00       	jmp    801078ab <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010778f:	e8 a9 b8 ff ff       	call   8010303d <ideintr>
    lapiceoi();
80107794:	e8 91 c0 ff ff       	call   8010382a <lapiceoi>
    break;
80107799:	e9 0d 01 00 00       	jmp    801078ab <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010779e:	e8 89 be ff ff       	call   8010362c <kbdintr>
    lapiceoi();
801077a3:	e8 82 c0 ff ff       	call   8010382a <lapiceoi>
    break;
801077a8:	e9 fe 00 00 00       	jmp    801078ab <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801077ad:	e8 60 03 00 00       	call   80107b12 <uartintr>
    lapiceoi();
801077b2:	e8 73 c0 ff ff       	call   8010382a <lapiceoi>
    break;
801077b7:	e9 ef 00 00 00       	jmp    801078ab <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077bc:	8b 45 08             	mov    0x8(%ebp),%eax
801077bf:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801077c2:	8b 45 08             	mov    0x8(%ebp),%eax
801077c5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077c9:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801077cc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077d2:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077d5:	0f b6 c0             	movzbl %al,%eax
801077d8:	51                   	push   %ecx
801077d9:	52                   	push   %edx
801077da:	50                   	push   %eax
801077db:	68 6c 99 10 80       	push   $0x8010996c
801077e0:	e8 e1 8b ff ff       	call   801003c6 <cprintf>
801077e5:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801077e8:	e8 3d c0 ff ff       	call   8010382a <lapiceoi>
    break;
801077ed:	e9 b9 00 00 00       	jmp    801078ab <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801077f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077f8:	85 c0                	test   %eax,%eax
801077fa:	74 11                	je     8010780d <trap+0x13f>
801077fc:	8b 45 08             	mov    0x8(%ebp),%eax
801077ff:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107803:	0f b7 c0             	movzwl %ax,%eax
80107806:	83 e0 03             	and    $0x3,%eax
80107809:	85 c0                	test   %eax,%eax
8010780b:	75 40                	jne    8010784d <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010780d:	e8 1d fd ff ff       	call   8010752f <rcr2>
80107812:	89 c3                	mov    %eax,%ebx
80107814:	8b 45 08             	mov    0x8(%ebp),%eax
80107817:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010781a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107820:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107823:	0f b6 d0             	movzbl %al,%edx
80107826:	8b 45 08             	mov    0x8(%ebp),%eax
80107829:	8b 40 30             	mov    0x30(%eax),%eax
8010782c:	83 ec 0c             	sub    $0xc,%esp
8010782f:	53                   	push   %ebx
80107830:	51                   	push   %ecx
80107831:	52                   	push   %edx
80107832:	50                   	push   %eax
80107833:	68 90 99 10 80       	push   $0x80109990
80107838:	e8 89 8b ff ff       	call   801003c6 <cprintf>
8010783d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107840:	83 ec 0c             	sub    $0xc,%esp
80107843:	68 c2 99 10 80       	push   $0x801099c2
80107848:	e8 19 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010784d:	e8 dd fc ff ff       	call   8010752f <rcr2>
80107852:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107855:	8b 45 08             	mov    0x8(%ebp),%eax
80107858:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010785b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107861:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107864:	0f b6 d8             	movzbl %al,%ebx
80107867:	8b 45 08             	mov    0x8(%ebp),%eax
8010786a:	8b 48 34             	mov    0x34(%eax),%ecx
8010786d:	8b 45 08             	mov    0x8(%ebp),%eax
80107870:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107873:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107879:	8d 78 6c             	lea    0x6c(%eax),%edi
8010787c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107882:	8b 40 10             	mov    0x10(%eax),%eax
80107885:	ff 75 e4             	pushl  -0x1c(%ebp)
80107888:	56                   	push   %esi
80107889:	53                   	push   %ebx
8010788a:	51                   	push   %ecx
8010788b:	52                   	push   %edx
8010788c:	57                   	push   %edi
8010788d:	50                   	push   %eax
8010788e:	68 c8 99 10 80       	push   $0x801099c8
80107893:	e8 2e 8b ff ff       	call   801003c6 <cprintf>
80107898:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010789b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078a1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801078a8:	eb 01                	jmp    801078ab <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801078aa:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801078ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078b1:	85 c0                	test   %eax,%eax
801078b3:	74 24                	je     801078d9 <trap+0x20b>
801078b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078bb:	8b 40 24             	mov    0x24(%eax),%eax
801078be:	85 c0                	test   %eax,%eax
801078c0:	74 17                	je     801078d9 <trap+0x20b>
801078c2:	8b 45 08             	mov    0x8(%ebp),%eax
801078c5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078c9:	0f b7 c0             	movzwl %ax,%eax
801078cc:	83 e0 03             	and    $0x3,%eax
801078cf:	83 f8 03             	cmp    $0x3,%eax
801078d2:	75 05                	jne    801078d9 <trap+0x20b>
    exit();
801078d4:	e8 20 db ff ff       	call   801053f9 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801078d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078df:	85 c0                	test   %eax,%eax
801078e1:	74 1e                	je     80107901 <trap+0x233>
801078e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078e9:	8b 40 0c             	mov    0xc(%eax),%eax
801078ec:	83 f8 04             	cmp    $0x4,%eax
801078ef:	75 10                	jne    80107901 <trap+0x233>
801078f1:	8b 45 08             	mov    0x8(%ebp),%eax
801078f4:	8b 40 30             	mov    0x30(%eax),%eax
801078f7:	83 f8 20             	cmp    $0x20,%eax
801078fa:	75 05                	jne    80107901 <trap+0x233>
    yield();
801078fc:	e8 e1 de ff ff       	call   801057e2 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107901:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107907:	85 c0                	test   %eax,%eax
80107909:	74 27                	je     80107932 <trap+0x264>
8010790b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107911:	8b 40 24             	mov    0x24(%eax),%eax
80107914:	85 c0                	test   %eax,%eax
80107916:	74 1a                	je     80107932 <trap+0x264>
80107918:	8b 45 08             	mov    0x8(%ebp),%eax
8010791b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010791f:	0f b7 c0             	movzwl %ax,%eax
80107922:	83 e0 03             	and    $0x3,%eax
80107925:	83 f8 03             	cmp    $0x3,%eax
80107928:	75 08                	jne    80107932 <trap+0x264>
    exit();
8010792a:	e8 ca da ff ff       	call   801053f9 <exit>
8010792f:	eb 01                	jmp    80107932 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107931:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107932:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107935:	5b                   	pop    %ebx
80107936:	5e                   	pop    %esi
80107937:	5f                   	pop    %edi
80107938:	5d                   	pop    %ebp
80107939:	c3                   	ret    

8010793a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010793a:	55                   	push   %ebp
8010793b:	89 e5                	mov    %esp,%ebp
8010793d:	83 ec 14             	sub    $0x14,%esp
80107940:	8b 45 08             	mov    0x8(%ebp),%eax
80107943:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107947:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010794b:	89 c2                	mov    %eax,%edx
8010794d:	ec                   	in     (%dx),%al
8010794e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107951:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107955:	c9                   	leave  
80107956:	c3                   	ret    

80107957 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107957:	55                   	push   %ebp
80107958:	89 e5                	mov    %esp,%ebp
8010795a:	83 ec 08             	sub    $0x8,%esp
8010795d:	8b 55 08             	mov    0x8(%ebp),%edx
80107960:	8b 45 0c             	mov    0xc(%ebp),%eax
80107963:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107967:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010796a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010796e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107972:	ee                   	out    %al,(%dx)
}
80107973:	90                   	nop
80107974:	c9                   	leave  
80107975:	c3                   	ret    

80107976 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107976:	55                   	push   %ebp
80107977:	89 e5                	mov    %esp,%ebp
80107979:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010797c:	6a 00                	push   $0x0
8010797e:	68 fa 03 00 00       	push   $0x3fa
80107983:	e8 cf ff ff ff       	call   80107957 <outb>
80107988:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010798b:	68 80 00 00 00       	push   $0x80
80107990:	68 fb 03 00 00       	push   $0x3fb
80107995:	e8 bd ff ff ff       	call   80107957 <outb>
8010799a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010799d:	6a 0c                	push   $0xc
8010799f:	68 f8 03 00 00       	push   $0x3f8
801079a4:	e8 ae ff ff ff       	call   80107957 <outb>
801079a9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801079ac:	6a 00                	push   $0x0
801079ae:	68 f9 03 00 00       	push   $0x3f9
801079b3:	e8 9f ff ff ff       	call   80107957 <outb>
801079b8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801079bb:	6a 03                	push   $0x3
801079bd:	68 fb 03 00 00       	push   $0x3fb
801079c2:	e8 90 ff ff ff       	call   80107957 <outb>
801079c7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801079ca:	6a 00                	push   $0x0
801079cc:	68 fc 03 00 00       	push   $0x3fc
801079d1:	e8 81 ff ff ff       	call   80107957 <outb>
801079d6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801079d9:	6a 01                	push   $0x1
801079db:	68 f9 03 00 00       	push   $0x3f9
801079e0:	e8 72 ff ff ff       	call   80107957 <outb>
801079e5:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801079e8:	68 fd 03 00 00       	push   $0x3fd
801079ed:	e8 48 ff ff ff       	call   8010793a <inb>
801079f2:	83 c4 04             	add    $0x4,%esp
801079f5:	3c ff                	cmp    $0xff,%al
801079f7:	74 6e                	je     80107a67 <uartinit+0xf1>
    return;
  uart = 1;
801079f9:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107a00:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107a03:	68 fa 03 00 00       	push   $0x3fa
80107a08:	e8 2d ff ff ff       	call   8010793a <inb>
80107a0d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107a10:	68 f8 03 00 00       	push   $0x3f8
80107a15:	e8 20 ff ff ff       	call   8010793a <inb>
80107a1a:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107a1d:	83 ec 0c             	sub    $0xc,%esp
80107a20:	6a 04                	push   $0x4
80107a22:	e8 35 d0 ff ff       	call   80104a5c <picenable>
80107a27:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107a2a:	83 ec 08             	sub    $0x8,%esp
80107a2d:	6a 00                	push   $0x0
80107a2f:	6a 04                	push   $0x4
80107a31:	e8 a9 b8 ff ff       	call   801032df <ioapicenable>
80107a36:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a39:	c7 45 f4 8c 9a 10 80 	movl   $0x80109a8c,-0xc(%ebp)
80107a40:	eb 19                	jmp    80107a5b <uartinit+0xe5>
    uartputc(*p);
80107a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a45:	0f b6 00             	movzbl (%eax),%eax
80107a48:	0f be c0             	movsbl %al,%eax
80107a4b:	83 ec 0c             	sub    $0xc,%esp
80107a4e:	50                   	push   %eax
80107a4f:	e8 16 00 00 00       	call   80107a6a <uartputc>
80107a54:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5e:	0f b6 00             	movzbl (%eax),%eax
80107a61:	84 c0                	test   %al,%al
80107a63:	75 dd                	jne    80107a42 <uartinit+0xcc>
80107a65:	eb 01                	jmp    80107a68 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107a67:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107a68:	c9                   	leave  
80107a69:	c3                   	ret    

80107a6a <uartputc>:

void
uartputc(int c)
{
80107a6a:	55                   	push   %ebp
80107a6b:	89 e5                	mov    %esp,%ebp
80107a6d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a70:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a75:	85 c0                	test   %eax,%eax
80107a77:	74 53                	je     80107acc <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a80:	eb 11                	jmp    80107a93 <uartputc+0x29>
    microdelay(10);
80107a82:	83 ec 0c             	sub    $0xc,%esp
80107a85:	6a 0a                	push   $0xa
80107a87:	e8 b9 bd ff ff       	call   80103845 <microdelay>
80107a8c:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a93:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a97:	7f 1a                	jg     80107ab3 <uartputc+0x49>
80107a99:	83 ec 0c             	sub    $0xc,%esp
80107a9c:	68 fd 03 00 00       	push   $0x3fd
80107aa1:	e8 94 fe ff ff       	call   8010793a <inb>
80107aa6:	83 c4 10             	add    $0x10,%esp
80107aa9:	0f b6 c0             	movzbl %al,%eax
80107aac:	83 e0 20             	and    $0x20,%eax
80107aaf:	85 c0                	test   %eax,%eax
80107ab1:	74 cf                	je     80107a82 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab6:	0f b6 c0             	movzbl %al,%eax
80107ab9:	83 ec 08             	sub    $0x8,%esp
80107abc:	50                   	push   %eax
80107abd:	68 f8 03 00 00       	push   $0x3f8
80107ac2:	e8 90 fe ff ff       	call   80107957 <outb>
80107ac7:	83 c4 10             	add    $0x10,%esp
80107aca:	eb 01                	jmp    80107acd <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107acc:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107acd:	c9                   	leave  
80107ace:	c3                   	ret    

80107acf <uartgetc>:

static int
uartgetc(void)
{
80107acf:	55                   	push   %ebp
80107ad0:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107ad2:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107ad7:	85 c0                	test   %eax,%eax
80107ad9:	75 07                	jne    80107ae2 <uartgetc+0x13>
    return -1;
80107adb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ae0:	eb 2e                	jmp    80107b10 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107ae2:	68 fd 03 00 00       	push   $0x3fd
80107ae7:	e8 4e fe ff ff       	call   8010793a <inb>
80107aec:	83 c4 04             	add    $0x4,%esp
80107aef:	0f b6 c0             	movzbl %al,%eax
80107af2:	83 e0 01             	and    $0x1,%eax
80107af5:	85 c0                	test   %eax,%eax
80107af7:	75 07                	jne    80107b00 <uartgetc+0x31>
    return -1;
80107af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107afe:	eb 10                	jmp    80107b10 <uartgetc+0x41>
  return inb(COM1+0);
80107b00:	68 f8 03 00 00       	push   $0x3f8
80107b05:	e8 30 fe ff ff       	call   8010793a <inb>
80107b0a:	83 c4 04             	add    $0x4,%esp
80107b0d:	0f b6 c0             	movzbl %al,%eax
}
80107b10:	c9                   	leave  
80107b11:	c3                   	ret    

80107b12 <uartintr>:

void
uartintr(void)
{
80107b12:	55                   	push   %ebp
80107b13:	89 e5                	mov    %esp,%ebp
80107b15:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107b18:	83 ec 0c             	sub    $0xc,%esp
80107b1b:	68 cf 7a 10 80       	push   $0x80107acf
80107b20:	e8 d4 8c ff ff       	call   801007f9 <consoleintr>
80107b25:	83 c4 10             	add    $0x10,%esp
}
80107b28:	90                   	nop
80107b29:	c9                   	leave  
80107b2a:	c3                   	ret    

80107b2b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $0
80107b2d:	6a 00                	push   $0x0
  jmp alltraps
80107b2f:	e9 a6 f9 ff ff       	jmp    801074da <alltraps>

80107b34 <vector1>:
.globl vector1
vector1:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $1
80107b36:	6a 01                	push   $0x1
  jmp alltraps
80107b38:	e9 9d f9 ff ff       	jmp    801074da <alltraps>

80107b3d <vector2>:
.globl vector2
vector2:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $2
80107b3f:	6a 02                	push   $0x2
  jmp alltraps
80107b41:	e9 94 f9 ff ff       	jmp    801074da <alltraps>

80107b46 <vector3>:
.globl vector3
vector3:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $3
80107b48:	6a 03                	push   $0x3
  jmp alltraps
80107b4a:	e9 8b f9 ff ff       	jmp    801074da <alltraps>

80107b4f <vector4>:
.globl vector4
vector4:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $4
80107b51:	6a 04                	push   $0x4
  jmp alltraps
80107b53:	e9 82 f9 ff ff       	jmp    801074da <alltraps>

80107b58 <vector5>:
.globl vector5
vector5:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $5
80107b5a:	6a 05                	push   $0x5
  jmp alltraps
80107b5c:	e9 79 f9 ff ff       	jmp    801074da <alltraps>

80107b61 <vector6>:
.globl vector6
vector6:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $6
80107b63:	6a 06                	push   $0x6
  jmp alltraps
80107b65:	e9 70 f9 ff ff       	jmp    801074da <alltraps>

80107b6a <vector7>:
.globl vector7
vector7:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $7
80107b6c:	6a 07                	push   $0x7
  jmp alltraps
80107b6e:	e9 67 f9 ff ff       	jmp    801074da <alltraps>

80107b73 <vector8>:
.globl vector8
vector8:
  pushl $8
80107b73:	6a 08                	push   $0x8
  jmp alltraps
80107b75:	e9 60 f9 ff ff       	jmp    801074da <alltraps>

80107b7a <vector9>:
.globl vector9
vector9:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $9
80107b7c:	6a 09                	push   $0x9
  jmp alltraps
80107b7e:	e9 57 f9 ff ff       	jmp    801074da <alltraps>

80107b83 <vector10>:
.globl vector10
vector10:
  pushl $10
80107b83:	6a 0a                	push   $0xa
  jmp alltraps
80107b85:	e9 50 f9 ff ff       	jmp    801074da <alltraps>

80107b8a <vector11>:
.globl vector11
vector11:
  pushl $11
80107b8a:	6a 0b                	push   $0xb
  jmp alltraps
80107b8c:	e9 49 f9 ff ff       	jmp    801074da <alltraps>

80107b91 <vector12>:
.globl vector12
vector12:
  pushl $12
80107b91:	6a 0c                	push   $0xc
  jmp alltraps
80107b93:	e9 42 f9 ff ff       	jmp    801074da <alltraps>

80107b98 <vector13>:
.globl vector13
vector13:
  pushl $13
80107b98:	6a 0d                	push   $0xd
  jmp alltraps
80107b9a:	e9 3b f9 ff ff       	jmp    801074da <alltraps>

80107b9f <vector14>:
.globl vector14
vector14:
  pushl $14
80107b9f:	6a 0e                	push   $0xe
  jmp alltraps
80107ba1:	e9 34 f9 ff ff       	jmp    801074da <alltraps>

80107ba6 <vector15>:
.globl vector15
vector15:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $15
80107ba8:	6a 0f                	push   $0xf
  jmp alltraps
80107baa:	e9 2b f9 ff ff       	jmp    801074da <alltraps>

80107baf <vector16>:
.globl vector16
vector16:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $16
80107bb1:	6a 10                	push   $0x10
  jmp alltraps
80107bb3:	e9 22 f9 ff ff       	jmp    801074da <alltraps>

80107bb8 <vector17>:
.globl vector17
vector17:
  pushl $17
80107bb8:	6a 11                	push   $0x11
  jmp alltraps
80107bba:	e9 1b f9 ff ff       	jmp    801074da <alltraps>

80107bbf <vector18>:
.globl vector18
vector18:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $18
80107bc1:	6a 12                	push   $0x12
  jmp alltraps
80107bc3:	e9 12 f9 ff ff       	jmp    801074da <alltraps>

80107bc8 <vector19>:
.globl vector19
vector19:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $19
80107bca:	6a 13                	push   $0x13
  jmp alltraps
80107bcc:	e9 09 f9 ff ff       	jmp    801074da <alltraps>

80107bd1 <vector20>:
.globl vector20
vector20:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $20
80107bd3:	6a 14                	push   $0x14
  jmp alltraps
80107bd5:	e9 00 f9 ff ff       	jmp    801074da <alltraps>

80107bda <vector21>:
.globl vector21
vector21:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $21
80107bdc:	6a 15                	push   $0x15
  jmp alltraps
80107bde:	e9 f7 f8 ff ff       	jmp    801074da <alltraps>

80107be3 <vector22>:
.globl vector22
vector22:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $22
80107be5:	6a 16                	push   $0x16
  jmp alltraps
80107be7:	e9 ee f8 ff ff       	jmp    801074da <alltraps>

80107bec <vector23>:
.globl vector23
vector23:
  pushl $0
80107bec:	6a 00                	push   $0x0
  pushl $23
80107bee:	6a 17                	push   $0x17
  jmp alltraps
80107bf0:	e9 e5 f8 ff ff       	jmp    801074da <alltraps>

80107bf5 <vector24>:
.globl vector24
vector24:
  pushl $0
80107bf5:	6a 00                	push   $0x0
  pushl $24
80107bf7:	6a 18                	push   $0x18
  jmp alltraps
80107bf9:	e9 dc f8 ff ff       	jmp    801074da <alltraps>

80107bfe <vector25>:
.globl vector25
vector25:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $25
80107c00:	6a 19                	push   $0x19
  jmp alltraps
80107c02:	e9 d3 f8 ff ff       	jmp    801074da <alltraps>

80107c07 <vector26>:
.globl vector26
vector26:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $26
80107c09:	6a 1a                	push   $0x1a
  jmp alltraps
80107c0b:	e9 ca f8 ff ff       	jmp    801074da <alltraps>

80107c10 <vector27>:
.globl vector27
vector27:
  pushl $0
80107c10:	6a 00                	push   $0x0
  pushl $27
80107c12:	6a 1b                	push   $0x1b
  jmp alltraps
80107c14:	e9 c1 f8 ff ff       	jmp    801074da <alltraps>

80107c19 <vector28>:
.globl vector28
vector28:
  pushl $0
80107c19:	6a 00                	push   $0x0
  pushl $28
80107c1b:	6a 1c                	push   $0x1c
  jmp alltraps
80107c1d:	e9 b8 f8 ff ff       	jmp    801074da <alltraps>

80107c22 <vector29>:
.globl vector29
vector29:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $29
80107c24:	6a 1d                	push   $0x1d
  jmp alltraps
80107c26:	e9 af f8 ff ff       	jmp    801074da <alltraps>

80107c2b <vector30>:
.globl vector30
vector30:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $30
80107c2d:	6a 1e                	push   $0x1e
  jmp alltraps
80107c2f:	e9 a6 f8 ff ff       	jmp    801074da <alltraps>

80107c34 <vector31>:
.globl vector31
vector31:
  pushl $0
80107c34:	6a 00                	push   $0x0
  pushl $31
80107c36:	6a 1f                	push   $0x1f
  jmp alltraps
80107c38:	e9 9d f8 ff ff       	jmp    801074da <alltraps>

80107c3d <vector32>:
.globl vector32
vector32:
  pushl $0
80107c3d:	6a 00                	push   $0x0
  pushl $32
80107c3f:	6a 20                	push   $0x20
  jmp alltraps
80107c41:	e9 94 f8 ff ff       	jmp    801074da <alltraps>

80107c46 <vector33>:
.globl vector33
vector33:
  pushl $0
80107c46:	6a 00                	push   $0x0
  pushl $33
80107c48:	6a 21                	push   $0x21
  jmp alltraps
80107c4a:	e9 8b f8 ff ff       	jmp    801074da <alltraps>

80107c4f <vector34>:
.globl vector34
vector34:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $34
80107c51:	6a 22                	push   $0x22
  jmp alltraps
80107c53:	e9 82 f8 ff ff       	jmp    801074da <alltraps>

80107c58 <vector35>:
.globl vector35
vector35:
  pushl $0
80107c58:	6a 00                	push   $0x0
  pushl $35
80107c5a:	6a 23                	push   $0x23
  jmp alltraps
80107c5c:	e9 79 f8 ff ff       	jmp    801074da <alltraps>

80107c61 <vector36>:
.globl vector36
vector36:
  pushl $0
80107c61:	6a 00                	push   $0x0
  pushl $36
80107c63:	6a 24                	push   $0x24
  jmp alltraps
80107c65:	e9 70 f8 ff ff       	jmp    801074da <alltraps>

80107c6a <vector37>:
.globl vector37
vector37:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $37
80107c6c:	6a 25                	push   $0x25
  jmp alltraps
80107c6e:	e9 67 f8 ff ff       	jmp    801074da <alltraps>

80107c73 <vector38>:
.globl vector38
vector38:
  pushl $0
80107c73:	6a 00                	push   $0x0
  pushl $38
80107c75:	6a 26                	push   $0x26
  jmp alltraps
80107c77:	e9 5e f8 ff ff       	jmp    801074da <alltraps>

80107c7c <vector39>:
.globl vector39
vector39:
  pushl $0
80107c7c:	6a 00                	push   $0x0
  pushl $39
80107c7e:	6a 27                	push   $0x27
  jmp alltraps
80107c80:	e9 55 f8 ff ff       	jmp    801074da <alltraps>

80107c85 <vector40>:
.globl vector40
vector40:
  pushl $0
80107c85:	6a 00                	push   $0x0
  pushl $40
80107c87:	6a 28                	push   $0x28
  jmp alltraps
80107c89:	e9 4c f8 ff ff       	jmp    801074da <alltraps>

80107c8e <vector41>:
.globl vector41
vector41:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $41
80107c90:	6a 29                	push   $0x29
  jmp alltraps
80107c92:	e9 43 f8 ff ff       	jmp    801074da <alltraps>

80107c97 <vector42>:
.globl vector42
vector42:
  pushl $0
80107c97:	6a 00                	push   $0x0
  pushl $42
80107c99:	6a 2a                	push   $0x2a
  jmp alltraps
80107c9b:	e9 3a f8 ff ff       	jmp    801074da <alltraps>

80107ca0 <vector43>:
.globl vector43
vector43:
  pushl $0
80107ca0:	6a 00                	push   $0x0
  pushl $43
80107ca2:	6a 2b                	push   $0x2b
  jmp alltraps
80107ca4:	e9 31 f8 ff ff       	jmp    801074da <alltraps>

80107ca9 <vector44>:
.globl vector44
vector44:
  pushl $0
80107ca9:	6a 00                	push   $0x0
  pushl $44
80107cab:	6a 2c                	push   $0x2c
  jmp alltraps
80107cad:	e9 28 f8 ff ff       	jmp    801074da <alltraps>

80107cb2 <vector45>:
.globl vector45
vector45:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $45
80107cb4:	6a 2d                	push   $0x2d
  jmp alltraps
80107cb6:	e9 1f f8 ff ff       	jmp    801074da <alltraps>

80107cbb <vector46>:
.globl vector46
vector46:
  pushl $0
80107cbb:	6a 00                	push   $0x0
  pushl $46
80107cbd:	6a 2e                	push   $0x2e
  jmp alltraps
80107cbf:	e9 16 f8 ff ff       	jmp    801074da <alltraps>

80107cc4 <vector47>:
.globl vector47
vector47:
  pushl $0
80107cc4:	6a 00                	push   $0x0
  pushl $47
80107cc6:	6a 2f                	push   $0x2f
  jmp alltraps
80107cc8:	e9 0d f8 ff ff       	jmp    801074da <alltraps>

80107ccd <vector48>:
.globl vector48
vector48:
  pushl $0
80107ccd:	6a 00                	push   $0x0
  pushl $48
80107ccf:	6a 30                	push   $0x30
  jmp alltraps
80107cd1:	e9 04 f8 ff ff       	jmp    801074da <alltraps>

80107cd6 <vector49>:
.globl vector49
vector49:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $49
80107cd8:	6a 31                	push   $0x31
  jmp alltraps
80107cda:	e9 fb f7 ff ff       	jmp    801074da <alltraps>

80107cdf <vector50>:
.globl vector50
vector50:
  pushl $0
80107cdf:	6a 00                	push   $0x0
  pushl $50
80107ce1:	6a 32                	push   $0x32
  jmp alltraps
80107ce3:	e9 f2 f7 ff ff       	jmp    801074da <alltraps>

80107ce8 <vector51>:
.globl vector51
vector51:
  pushl $0
80107ce8:	6a 00                	push   $0x0
  pushl $51
80107cea:	6a 33                	push   $0x33
  jmp alltraps
80107cec:	e9 e9 f7 ff ff       	jmp    801074da <alltraps>

80107cf1 <vector52>:
.globl vector52
vector52:
  pushl $0
80107cf1:	6a 00                	push   $0x0
  pushl $52
80107cf3:	6a 34                	push   $0x34
  jmp alltraps
80107cf5:	e9 e0 f7 ff ff       	jmp    801074da <alltraps>

80107cfa <vector53>:
.globl vector53
vector53:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $53
80107cfc:	6a 35                	push   $0x35
  jmp alltraps
80107cfe:	e9 d7 f7 ff ff       	jmp    801074da <alltraps>

80107d03 <vector54>:
.globl vector54
vector54:
  pushl $0
80107d03:	6a 00                	push   $0x0
  pushl $54
80107d05:	6a 36                	push   $0x36
  jmp alltraps
80107d07:	e9 ce f7 ff ff       	jmp    801074da <alltraps>

80107d0c <vector55>:
.globl vector55
vector55:
  pushl $0
80107d0c:	6a 00                	push   $0x0
  pushl $55
80107d0e:	6a 37                	push   $0x37
  jmp alltraps
80107d10:	e9 c5 f7 ff ff       	jmp    801074da <alltraps>

80107d15 <vector56>:
.globl vector56
vector56:
  pushl $0
80107d15:	6a 00                	push   $0x0
  pushl $56
80107d17:	6a 38                	push   $0x38
  jmp alltraps
80107d19:	e9 bc f7 ff ff       	jmp    801074da <alltraps>

80107d1e <vector57>:
.globl vector57
vector57:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $57
80107d20:	6a 39                	push   $0x39
  jmp alltraps
80107d22:	e9 b3 f7 ff ff       	jmp    801074da <alltraps>

80107d27 <vector58>:
.globl vector58
vector58:
  pushl $0
80107d27:	6a 00                	push   $0x0
  pushl $58
80107d29:	6a 3a                	push   $0x3a
  jmp alltraps
80107d2b:	e9 aa f7 ff ff       	jmp    801074da <alltraps>

80107d30 <vector59>:
.globl vector59
vector59:
  pushl $0
80107d30:	6a 00                	push   $0x0
  pushl $59
80107d32:	6a 3b                	push   $0x3b
  jmp alltraps
80107d34:	e9 a1 f7 ff ff       	jmp    801074da <alltraps>

80107d39 <vector60>:
.globl vector60
vector60:
  pushl $0
80107d39:	6a 00                	push   $0x0
  pushl $60
80107d3b:	6a 3c                	push   $0x3c
  jmp alltraps
80107d3d:	e9 98 f7 ff ff       	jmp    801074da <alltraps>

80107d42 <vector61>:
.globl vector61
vector61:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $61
80107d44:	6a 3d                	push   $0x3d
  jmp alltraps
80107d46:	e9 8f f7 ff ff       	jmp    801074da <alltraps>

80107d4b <vector62>:
.globl vector62
vector62:
  pushl $0
80107d4b:	6a 00                	push   $0x0
  pushl $62
80107d4d:	6a 3e                	push   $0x3e
  jmp alltraps
80107d4f:	e9 86 f7 ff ff       	jmp    801074da <alltraps>

80107d54 <vector63>:
.globl vector63
vector63:
  pushl $0
80107d54:	6a 00                	push   $0x0
  pushl $63
80107d56:	6a 3f                	push   $0x3f
  jmp alltraps
80107d58:	e9 7d f7 ff ff       	jmp    801074da <alltraps>

80107d5d <vector64>:
.globl vector64
vector64:
  pushl $0
80107d5d:	6a 00                	push   $0x0
  pushl $64
80107d5f:	6a 40                	push   $0x40
  jmp alltraps
80107d61:	e9 74 f7 ff ff       	jmp    801074da <alltraps>

80107d66 <vector65>:
.globl vector65
vector65:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $65
80107d68:	6a 41                	push   $0x41
  jmp alltraps
80107d6a:	e9 6b f7 ff ff       	jmp    801074da <alltraps>

80107d6f <vector66>:
.globl vector66
vector66:
  pushl $0
80107d6f:	6a 00                	push   $0x0
  pushl $66
80107d71:	6a 42                	push   $0x42
  jmp alltraps
80107d73:	e9 62 f7 ff ff       	jmp    801074da <alltraps>

80107d78 <vector67>:
.globl vector67
vector67:
  pushl $0
80107d78:	6a 00                	push   $0x0
  pushl $67
80107d7a:	6a 43                	push   $0x43
  jmp alltraps
80107d7c:	e9 59 f7 ff ff       	jmp    801074da <alltraps>

80107d81 <vector68>:
.globl vector68
vector68:
  pushl $0
80107d81:	6a 00                	push   $0x0
  pushl $68
80107d83:	6a 44                	push   $0x44
  jmp alltraps
80107d85:	e9 50 f7 ff ff       	jmp    801074da <alltraps>

80107d8a <vector69>:
.globl vector69
vector69:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $69
80107d8c:	6a 45                	push   $0x45
  jmp alltraps
80107d8e:	e9 47 f7 ff ff       	jmp    801074da <alltraps>

80107d93 <vector70>:
.globl vector70
vector70:
  pushl $0
80107d93:	6a 00                	push   $0x0
  pushl $70
80107d95:	6a 46                	push   $0x46
  jmp alltraps
80107d97:	e9 3e f7 ff ff       	jmp    801074da <alltraps>

80107d9c <vector71>:
.globl vector71
vector71:
  pushl $0
80107d9c:	6a 00                	push   $0x0
  pushl $71
80107d9e:	6a 47                	push   $0x47
  jmp alltraps
80107da0:	e9 35 f7 ff ff       	jmp    801074da <alltraps>

80107da5 <vector72>:
.globl vector72
vector72:
  pushl $0
80107da5:	6a 00                	push   $0x0
  pushl $72
80107da7:	6a 48                	push   $0x48
  jmp alltraps
80107da9:	e9 2c f7 ff ff       	jmp    801074da <alltraps>

80107dae <vector73>:
.globl vector73
vector73:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $73
80107db0:	6a 49                	push   $0x49
  jmp alltraps
80107db2:	e9 23 f7 ff ff       	jmp    801074da <alltraps>

80107db7 <vector74>:
.globl vector74
vector74:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $74
80107db9:	6a 4a                	push   $0x4a
  jmp alltraps
80107dbb:	e9 1a f7 ff ff       	jmp    801074da <alltraps>

80107dc0 <vector75>:
.globl vector75
vector75:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $75
80107dc2:	6a 4b                	push   $0x4b
  jmp alltraps
80107dc4:	e9 11 f7 ff ff       	jmp    801074da <alltraps>

80107dc9 <vector76>:
.globl vector76
vector76:
  pushl $0
80107dc9:	6a 00                	push   $0x0
  pushl $76
80107dcb:	6a 4c                	push   $0x4c
  jmp alltraps
80107dcd:	e9 08 f7 ff ff       	jmp    801074da <alltraps>

80107dd2 <vector77>:
.globl vector77
vector77:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $77
80107dd4:	6a 4d                	push   $0x4d
  jmp alltraps
80107dd6:	e9 ff f6 ff ff       	jmp    801074da <alltraps>

80107ddb <vector78>:
.globl vector78
vector78:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $78
80107ddd:	6a 4e                	push   $0x4e
  jmp alltraps
80107ddf:	e9 f6 f6 ff ff       	jmp    801074da <alltraps>

80107de4 <vector79>:
.globl vector79
vector79:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $79
80107de6:	6a 4f                	push   $0x4f
  jmp alltraps
80107de8:	e9 ed f6 ff ff       	jmp    801074da <alltraps>

80107ded <vector80>:
.globl vector80
vector80:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $80
80107def:	6a 50                	push   $0x50
  jmp alltraps
80107df1:	e9 e4 f6 ff ff       	jmp    801074da <alltraps>

80107df6 <vector81>:
.globl vector81
vector81:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $81
80107df8:	6a 51                	push   $0x51
  jmp alltraps
80107dfa:	e9 db f6 ff ff       	jmp    801074da <alltraps>

80107dff <vector82>:
.globl vector82
vector82:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $82
80107e01:	6a 52                	push   $0x52
  jmp alltraps
80107e03:	e9 d2 f6 ff ff       	jmp    801074da <alltraps>

80107e08 <vector83>:
.globl vector83
vector83:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $83
80107e0a:	6a 53                	push   $0x53
  jmp alltraps
80107e0c:	e9 c9 f6 ff ff       	jmp    801074da <alltraps>

80107e11 <vector84>:
.globl vector84
vector84:
  pushl $0
80107e11:	6a 00                	push   $0x0
  pushl $84
80107e13:	6a 54                	push   $0x54
  jmp alltraps
80107e15:	e9 c0 f6 ff ff       	jmp    801074da <alltraps>

80107e1a <vector85>:
.globl vector85
vector85:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $85
80107e1c:	6a 55                	push   $0x55
  jmp alltraps
80107e1e:	e9 b7 f6 ff ff       	jmp    801074da <alltraps>

80107e23 <vector86>:
.globl vector86
vector86:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $86
80107e25:	6a 56                	push   $0x56
  jmp alltraps
80107e27:	e9 ae f6 ff ff       	jmp    801074da <alltraps>

80107e2c <vector87>:
.globl vector87
vector87:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $87
80107e2e:	6a 57                	push   $0x57
  jmp alltraps
80107e30:	e9 a5 f6 ff ff       	jmp    801074da <alltraps>

80107e35 <vector88>:
.globl vector88
vector88:
  pushl $0
80107e35:	6a 00                	push   $0x0
  pushl $88
80107e37:	6a 58                	push   $0x58
  jmp alltraps
80107e39:	e9 9c f6 ff ff       	jmp    801074da <alltraps>

80107e3e <vector89>:
.globl vector89
vector89:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $89
80107e40:	6a 59                	push   $0x59
  jmp alltraps
80107e42:	e9 93 f6 ff ff       	jmp    801074da <alltraps>

80107e47 <vector90>:
.globl vector90
vector90:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $90
80107e49:	6a 5a                	push   $0x5a
  jmp alltraps
80107e4b:	e9 8a f6 ff ff       	jmp    801074da <alltraps>

80107e50 <vector91>:
.globl vector91
vector91:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $91
80107e52:	6a 5b                	push   $0x5b
  jmp alltraps
80107e54:	e9 81 f6 ff ff       	jmp    801074da <alltraps>

80107e59 <vector92>:
.globl vector92
vector92:
  pushl $0
80107e59:	6a 00                	push   $0x0
  pushl $92
80107e5b:	6a 5c                	push   $0x5c
  jmp alltraps
80107e5d:	e9 78 f6 ff ff       	jmp    801074da <alltraps>

80107e62 <vector93>:
.globl vector93
vector93:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $93
80107e64:	6a 5d                	push   $0x5d
  jmp alltraps
80107e66:	e9 6f f6 ff ff       	jmp    801074da <alltraps>

80107e6b <vector94>:
.globl vector94
vector94:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $94
80107e6d:	6a 5e                	push   $0x5e
  jmp alltraps
80107e6f:	e9 66 f6 ff ff       	jmp    801074da <alltraps>

80107e74 <vector95>:
.globl vector95
vector95:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $95
80107e76:	6a 5f                	push   $0x5f
  jmp alltraps
80107e78:	e9 5d f6 ff ff       	jmp    801074da <alltraps>

80107e7d <vector96>:
.globl vector96
vector96:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $96
80107e7f:	6a 60                	push   $0x60
  jmp alltraps
80107e81:	e9 54 f6 ff ff       	jmp    801074da <alltraps>

80107e86 <vector97>:
.globl vector97
vector97:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $97
80107e88:	6a 61                	push   $0x61
  jmp alltraps
80107e8a:	e9 4b f6 ff ff       	jmp    801074da <alltraps>

80107e8f <vector98>:
.globl vector98
vector98:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $98
80107e91:	6a 62                	push   $0x62
  jmp alltraps
80107e93:	e9 42 f6 ff ff       	jmp    801074da <alltraps>

80107e98 <vector99>:
.globl vector99
vector99:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $99
80107e9a:	6a 63                	push   $0x63
  jmp alltraps
80107e9c:	e9 39 f6 ff ff       	jmp    801074da <alltraps>

80107ea1 <vector100>:
.globl vector100
vector100:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $100
80107ea3:	6a 64                	push   $0x64
  jmp alltraps
80107ea5:	e9 30 f6 ff ff       	jmp    801074da <alltraps>

80107eaa <vector101>:
.globl vector101
vector101:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $101
80107eac:	6a 65                	push   $0x65
  jmp alltraps
80107eae:	e9 27 f6 ff ff       	jmp    801074da <alltraps>

80107eb3 <vector102>:
.globl vector102
vector102:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $102
80107eb5:	6a 66                	push   $0x66
  jmp alltraps
80107eb7:	e9 1e f6 ff ff       	jmp    801074da <alltraps>

80107ebc <vector103>:
.globl vector103
vector103:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $103
80107ebe:	6a 67                	push   $0x67
  jmp alltraps
80107ec0:	e9 15 f6 ff ff       	jmp    801074da <alltraps>

80107ec5 <vector104>:
.globl vector104
vector104:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $104
80107ec7:	6a 68                	push   $0x68
  jmp alltraps
80107ec9:	e9 0c f6 ff ff       	jmp    801074da <alltraps>

80107ece <vector105>:
.globl vector105
vector105:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $105
80107ed0:	6a 69                	push   $0x69
  jmp alltraps
80107ed2:	e9 03 f6 ff ff       	jmp    801074da <alltraps>

80107ed7 <vector106>:
.globl vector106
vector106:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $106
80107ed9:	6a 6a                	push   $0x6a
  jmp alltraps
80107edb:	e9 fa f5 ff ff       	jmp    801074da <alltraps>

80107ee0 <vector107>:
.globl vector107
vector107:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $107
80107ee2:	6a 6b                	push   $0x6b
  jmp alltraps
80107ee4:	e9 f1 f5 ff ff       	jmp    801074da <alltraps>

80107ee9 <vector108>:
.globl vector108
vector108:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $108
80107eeb:	6a 6c                	push   $0x6c
  jmp alltraps
80107eed:	e9 e8 f5 ff ff       	jmp    801074da <alltraps>

80107ef2 <vector109>:
.globl vector109
vector109:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $109
80107ef4:	6a 6d                	push   $0x6d
  jmp alltraps
80107ef6:	e9 df f5 ff ff       	jmp    801074da <alltraps>

80107efb <vector110>:
.globl vector110
vector110:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $110
80107efd:	6a 6e                	push   $0x6e
  jmp alltraps
80107eff:	e9 d6 f5 ff ff       	jmp    801074da <alltraps>

80107f04 <vector111>:
.globl vector111
vector111:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $111
80107f06:	6a 6f                	push   $0x6f
  jmp alltraps
80107f08:	e9 cd f5 ff ff       	jmp    801074da <alltraps>

80107f0d <vector112>:
.globl vector112
vector112:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $112
80107f0f:	6a 70                	push   $0x70
  jmp alltraps
80107f11:	e9 c4 f5 ff ff       	jmp    801074da <alltraps>

80107f16 <vector113>:
.globl vector113
vector113:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $113
80107f18:	6a 71                	push   $0x71
  jmp alltraps
80107f1a:	e9 bb f5 ff ff       	jmp    801074da <alltraps>

80107f1f <vector114>:
.globl vector114
vector114:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $114
80107f21:	6a 72                	push   $0x72
  jmp alltraps
80107f23:	e9 b2 f5 ff ff       	jmp    801074da <alltraps>

80107f28 <vector115>:
.globl vector115
vector115:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $115
80107f2a:	6a 73                	push   $0x73
  jmp alltraps
80107f2c:	e9 a9 f5 ff ff       	jmp    801074da <alltraps>

80107f31 <vector116>:
.globl vector116
vector116:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $116
80107f33:	6a 74                	push   $0x74
  jmp alltraps
80107f35:	e9 a0 f5 ff ff       	jmp    801074da <alltraps>

80107f3a <vector117>:
.globl vector117
vector117:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $117
80107f3c:	6a 75                	push   $0x75
  jmp alltraps
80107f3e:	e9 97 f5 ff ff       	jmp    801074da <alltraps>

80107f43 <vector118>:
.globl vector118
vector118:
  pushl $0
80107f43:	6a 00                	push   $0x0
  pushl $118
80107f45:	6a 76                	push   $0x76
  jmp alltraps
80107f47:	e9 8e f5 ff ff       	jmp    801074da <alltraps>

80107f4c <vector119>:
.globl vector119
vector119:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $119
80107f4e:	6a 77                	push   $0x77
  jmp alltraps
80107f50:	e9 85 f5 ff ff       	jmp    801074da <alltraps>

80107f55 <vector120>:
.globl vector120
vector120:
  pushl $0
80107f55:	6a 00                	push   $0x0
  pushl $120
80107f57:	6a 78                	push   $0x78
  jmp alltraps
80107f59:	e9 7c f5 ff ff       	jmp    801074da <alltraps>

80107f5e <vector121>:
.globl vector121
vector121:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $121
80107f60:	6a 79                	push   $0x79
  jmp alltraps
80107f62:	e9 73 f5 ff ff       	jmp    801074da <alltraps>

80107f67 <vector122>:
.globl vector122
vector122:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $122
80107f69:	6a 7a                	push   $0x7a
  jmp alltraps
80107f6b:	e9 6a f5 ff ff       	jmp    801074da <alltraps>

80107f70 <vector123>:
.globl vector123
vector123:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $123
80107f72:	6a 7b                	push   $0x7b
  jmp alltraps
80107f74:	e9 61 f5 ff ff       	jmp    801074da <alltraps>

80107f79 <vector124>:
.globl vector124
vector124:
  pushl $0
80107f79:	6a 00                	push   $0x0
  pushl $124
80107f7b:	6a 7c                	push   $0x7c
  jmp alltraps
80107f7d:	e9 58 f5 ff ff       	jmp    801074da <alltraps>

80107f82 <vector125>:
.globl vector125
vector125:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $125
80107f84:	6a 7d                	push   $0x7d
  jmp alltraps
80107f86:	e9 4f f5 ff ff       	jmp    801074da <alltraps>

80107f8b <vector126>:
.globl vector126
vector126:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $126
80107f8d:	6a 7e                	push   $0x7e
  jmp alltraps
80107f8f:	e9 46 f5 ff ff       	jmp    801074da <alltraps>

80107f94 <vector127>:
.globl vector127
vector127:
  pushl $0
80107f94:	6a 00                	push   $0x0
  pushl $127
80107f96:	6a 7f                	push   $0x7f
  jmp alltraps
80107f98:	e9 3d f5 ff ff       	jmp    801074da <alltraps>

80107f9d <vector128>:
.globl vector128
vector128:
  pushl $0
80107f9d:	6a 00                	push   $0x0
  pushl $128
80107f9f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107fa4:	e9 31 f5 ff ff       	jmp    801074da <alltraps>

80107fa9 <vector129>:
.globl vector129
vector129:
  pushl $0
80107fa9:	6a 00                	push   $0x0
  pushl $129
80107fab:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107fb0:	e9 25 f5 ff ff       	jmp    801074da <alltraps>

80107fb5 <vector130>:
.globl vector130
vector130:
  pushl $0
80107fb5:	6a 00                	push   $0x0
  pushl $130
80107fb7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107fbc:	e9 19 f5 ff ff       	jmp    801074da <alltraps>

80107fc1 <vector131>:
.globl vector131
vector131:
  pushl $0
80107fc1:	6a 00                	push   $0x0
  pushl $131
80107fc3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107fc8:	e9 0d f5 ff ff       	jmp    801074da <alltraps>

80107fcd <vector132>:
.globl vector132
vector132:
  pushl $0
80107fcd:	6a 00                	push   $0x0
  pushl $132
80107fcf:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107fd4:	e9 01 f5 ff ff       	jmp    801074da <alltraps>

80107fd9 <vector133>:
.globl vector133
vector133:
  pushl $0
80107fd9:	6a 00                	push   $0x0
  pushl $133
80107fdb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107fe0:	e9 f5 f4 ff ff       	jmp    801074da <alltraps>

80107fe5 <vector134>:
.globl vector134
vector134:
  pushl $0
80107fe5:	6a 00                	push   $0x0
  pushl $134
80107fe7:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107fec:	e9 e9 f4 ff ff       	jmp    801074da <alltraps>

80107ff1 <vector135>:
.globl vector135
vector135:
  pushl $0
80107ff1:	6a 00                	push   $0x0
  pushl $135
80107ff3:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107ff8:	e9 dd f4 ff ff       	jmp    801074da <alltraps>

80107ffd <vector136>:
.globl vector136
vector136:
  pushl $0
80107ffd:	6a 00                	push   $0x0
  pushl $136
80107fff:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108004:	e9 d1 f4 ff ff       	jmp    801074da <alltraps>

80108009 <vector137>:
.globl vector137
vector137:
  pushl $0
80108009:	6a 00                	push   $0x0
  pushl $137
8010800b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108010:	e9 c5 f4 ff ff       	jmp    801074da <alltraps>

80108015 <vector138>:
.globl vector138
vector138:
  pushl $0
80108015:	6a 00                	push   $0x0
  pushl $138
80108017:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010801c:	e9 b9 f4 ff ff       	jmp    801074da <alltraps>

80108021 <vector139>:
.globl vector139
vector139:
  pushl $0
80108021:	6a 00                	push   $0x0
  pushl $139
80108023:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108028:	e9 ad f4 ff ff       	jmp    801074da <alltraps>

8010802d <vector140>:
.globl vector140
vector140:
  pushl $0
8010802d:	6a 00                	push   $0x0
  pushl $140
8010802f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108034:	e9 a1 f4 ff ff       	jmp    801074da <alltraps>

80108039 <vector141>:
.globl vector141
vector141:
  pushl $0
80108039:	6a 00                	push   $0x0
  pushl $141
8010803b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108040:	e9 95 f4 ff ff       	jmp    801074da <alltraps>

80108045 <vector142>:
.globl vector142
vector142:
  pushl $0
80108045:	6a 00                	push   $0x0
  pushl $142
80108047:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010804c:	e9 89 f4 ff ff       	jmp    801074da <alltraps>

80108051 <vector143>:
.globl vector143
vector143:
  pushl $0
80108051:	6a 00                	push   $0x0
  pushl $143
80108053:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108058:	e9 7d f4 ff ff       	jmp    801074da <alltraps>

8010805d <vector144>:
.globl vector144
vector144:
  pushl $0
8010805d:	6a 00                	push   $0x0
  pushl $144
8010805f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108064:	e9 71 f4 ff ff       	jmp    801074da <alltraps>

80108069 <vector145>:
.globl vector145
vector145:
  pushl $0
80108069:	6a 00                	push   $0x0
  pushl $145
8010806b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108070:	e9 65 f4 ff ff       	jmp    801074da <alltraps>

80108075 <vector146>:
.globl vector146
vector146:
  pushl $0
80108075:	6a 00                	push   $0x0
  pushl $146
80108077:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010807c:	e9 59 f4 ff ff       	jmp    801074da <alltraps>

80108081 <vector147>:
.globl vector147
vector147:
  pushl $0
80108081:	6a 00                	push   $0x0
  pushl $147
80108083:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108088:	e9 4d f4 ff ff       	jmp    801074da <alltraps>

8010808d <vector148>:
.globl vector148
vector148:
  pushl $0
8010808d:	6a 00                	push   $0x0
  pushl $148
8010808f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108094:	e9 41 f4 ff ff       	jmp    801074da <alltraps>

80108099 <vector149>:
.globl vector149
vector149:
  pushl $0
80108099:	6a 00                	push   $0x0
  pushl $149
8010809b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801080a0:	e9 35 f4 ff ff       	jmp    801074da <alltraps>

801080a5 <vector150>:
.globl vector150
vector150:
  pushl $0
801080a5:	6a 00                	push   $0x0
  pushl $150
801080a7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801080ac:	e9 29 f4 ff ff       	jmp    801074da <alltraps>

801080b1 <vector151>:
.globl vector151
vector151:
  pushl $0
801080b1:	6a 00                	push   $0x0
  pushl $151
801080b3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801080b8:	e9 1d f4 ff ff       	jmp    801074da <alltraps>

801080bd <vector152>:
.globl vector152
vector152:
  pushl $0
801080bd:	6a 00                	push   $0x0
  pushl $152
801080bf:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801080c4:	e9 11 f4 ff ff       	jmp    801074da <alltraps>

801080c9 <vector153>:
.globl vector153
vector153:
  pushl $0
801080c9:	6a 00                	push   $0x0
  pushl $153
801080cb:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801080d0:	e9 05 f4 ff ff       	jmp    801074da <alltraps>

801080d5 <vector154>:
.globl vector154
vector154:
  pushl $0
801080d5:	6a 00                	push   $0x0
  pushl $154
801080d7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801080dc:	e9 f9 f3 ff ff       	jmp    801074da <alltraps>

801080e1 <vector155>:
.globl vector155
vector155:
  pushl $0
801080e1:	6a 00                	push   $0x0
  pushl $155
801080e3:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801080e8:	e9 ed f3 ff ff       	jmp    801074da <alltraps>

801080ed <vector156>:
.globl vector156
vector156:
  pushl $0
801080ed:	6a 00                	push   $0x0
  pushl $156
801080ef:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801080f4:	e9 e1 f3 ff ff       	jmp    801074da <alltraps>

801080f9 <vector157>:
.globl vector157
vector157:
  pushl $0
801080f9:	6a 00                	push   $0x0
  pushl $157
801080fb:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108100:	e9 d5 f3 ff ff       	jmp    801074da <alltraps>

80108105 <vector158>:
.globl vector158
vector158:
  pushl $0
80108105:	6a 00                	push   $0x0
  pushl $158
80108107:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010810c:	e9 c9 f3 ff ff       	jmp    801074da <alltraps>

80108111 <vector159>:
.globl vector159
vector159:
  pushl $0
80108111:	6a 00                	push   $0x0
  pushl $159
80108113:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108118:	e9 bd f3 ff ff       	jmp    801074da <alltraps>

8010811d <vector160>:
.globl vector160
vector160:
  pushl $0
8010811d:	6a 00                	push   $0x0
  pushl $160
8010811f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108124:	e9 b1 f3 ff ff       	jmp    801074da <alltraps>

80108129 <vector161>:
.globl vector161
vector161:
  pushl $0
80108129:	6a 00                	push   $0x0
  pushl $161
8010812b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108130:	e9 a5 f3 ff ff       	jmp    801074da <alltraps>

80108135 <vector162>:
.globl vector162
vector162:
  pushl $0
80108135:	6a 00                	push   $0x0
  pushl $162
80108137:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010813c:	e9 99 f3 ff ff       	jmp    801074da <alltraps>

80108141 <vector163>:
.globl vector163
vector163:
  pushl $0
80108141:	6a 00                	push   $0x0
  pushl $163
80108143:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108148:	e9 8d f3 ff ff       	jmp    801074da <alltraps>

8010814d <vector164>:
.globl vector164
vector164:
  pushl $0
8010814d:	6a 00                	push   $0x0
  pushl $164
8010814f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108154:	e9 81 f3 ff ff       	jmp    801074da <alltraps>

80108159 <vector165>:
.globl vector165
vector165:
  pushl $0
80108159:	6a 00                	push   $0x0
  pushl $165
8010815b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108160:	e9 75 f3 ff ff       	jmp    801074da <alltraps>

80108165 <vector166>:
.globl vector166
vector166:
  pushl $0
80108165:	6a 00                	push   $0x0
  pushl $166
80108167:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010816c:	e9 69 f3 ff ff       	jmp    801074da <alltraps>

80108171 <vector167>:
.globl vector167
vector167:
  pushl $0
80108171:	6a 00                	push   $0x0
  pushl $167
80108173:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108178:	e9 5d f3 ff ff       	jmp    801074da <alltraps>

8010817d <vector168>:
.globl vector168
vector168:
  pushl $0
8010817d:	6a 00                	push   $0x0
  pushl $168
8010817f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108184:	e9 51 f3 ff ff       	jmp    801074da <alltraps>

80108189 <vector169>:
.globl vector169
vector169:
  pushl $0
80108189:	6a 00                	push   $0x0
  pushl $169
8010818b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108190:	e9 45 f3 ff ff       	jmp    801074da <alltraps>

80108195 <vector170>:
.globl vector170
vector170:
  pushl $0
80108195:	6a 00                	push   $0x0
  pushl $170
80108197:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010819c:	e9 39 f3 ff ff       	jmp    801074da <alltraps>

801081a1 <vector171>:
.globl vector171
vector171:
  pushl $0
801081a1:	6a 00                	push   $0x0
  pushl $171
801081a3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801081a8:	e9 2d f3 ff ff       	jmp    801074da <alltraps>

801081ad <vector172>:
.globl vector172
vector172:
  pushl $0
801081ad:	6a 00                	push   $0x0
  pushl $172
801081af:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801081b4:	e9 21 f3 ff ff       	jmp    801074da <alltraps>

801081b9 <vector173>:
.globl vector173
vector173:
  pushl $0
801081b9:	6a 00                	push   $0x0
  pushl $173
801081bb:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801081c0:	e9 15 f3 ff ff       	jmp    801074da <alltraps>

801081c5 <vector174>:
.globl vector174
vector174:
  pushl $0
801081c5:	6a 00                	push   $0x0
  pushl $174
801081c7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801081cc:	e9 09 f3 ff ff       	jmp    801074da <alltraps>

801081d1 <vector175>:
.globl vector175
vector175:
  pushl $0
801081d1:	6a 00                	push   $0x0
  pushl $175
801081d3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801081d8:	e9 fd f2 ff ff       	jmp    801074da <alltraps>

801081dd <vector176>:
.globl vector176
vector176:
  pushl $0
801081dd:	6a 00                	push   $0x0
  pushl $176
801081df:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801081e4:	e9 f1 f2 ff ff       	jmp    801074da <alltraps>

801081e9 <vector177>:
.globl vector177
vector177:
  pushl $0
801081e9:	6a 00                	push   $0x0
  pushl $177
801081eb:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801081f0:	e9 e5 f2 ff ff       	jmp    801074da <alltraps>

801081f5 <vector178>:
.globl vector178
vector178:
  pushl $0
801081f5:	6a 00                	push   $0x0
  pushl $178
801081f7:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801081fc:	e9 d9 f2 ff ff       	jmp    801074da <alltraps>

80108201 <vector179>:
.globl vector179
vector179:
  pushl $0
80108201:	6a 00                	push   $0x0
  pushl $179
80108203:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108208:	e9 cd f2 ff ff       	jmp    801074da <alltraps>

8010820d <vector180>:
.globl vector180
vector180:
  pushl $0
8010820d:	6a 00                	push   $0x0
  pushl $180
8010820f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108214:	e9 c1 f2 ff ff       	jmp    801074da <alltraps>

80108219 <vector181>:
.globl vector181
vector181:
  pushl $0
80108219:	6a 00                	push   $0x0
  pushl $181
8010821b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108220:	e9 b5 f2 ff ff       	jmp    801074da <alltraps>

80108225 <vector182>:
.globl vector182
vector182:
  pushl $0
80108225:	6a 00                	push   $0x0
  pushl $182
80108227:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010822c:	e9 a9 f2 ff ff       	jmp    801074da <alltraps>

80108231 <vector183>:
.globl vector183
vector183:
  pushl $0
80108231:	6a 00                	push   $0x0
  pushl $183
80108233:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108238:	e9 9d f2 ff ff       	jmp    801074da <alltraps>

8010823d <vector184>:
.globl vector184
vector184:
  pushl $0
8010823d:	6a 00                	push   $0x0
  pushl $184
8010823f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108244:	e9 91 f2 ff ff       	jmp    801074da <alltraps>

80108249 <vector185>:
.globl vector185
vector185:
  pushl $0
80108249:	6a 00                	push   $0x0
  pushl $185
8010824b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108250:	e9 85 f2 ff ff       	jmp    801074da <alltraps>

80108255 <vector186>:
.globl vector186
vector186:
  pushl $0
80108255:	6a 00                	push   $0x0
  pushl $186
80108257:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010825c:	e9 79 f2 ff ff       	jmp    801074da <alltraps>

80108261 <vector187>:
.globl vector187
vector187:
  pushl $0
80108261:	6a 00                	push   $0x0
  pushl $187
80108263:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108268:	e9 6d f2 ff ff       	jmp    801074da <alltraps>

8010826d <vector188>:
.globl vector188
vector188:
  pushl $0
8010826d:	6a 00                	push   $0x0
  pushl $188
8010826f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108274:	e9 61 f2 ff ff       	jmp    801074da <alltraps>

80108279 <vector189>:
.globl vector189
vector189:
  pushl $0
80108279:	6a 00                	push   $0x0
  pushl $189
8010827b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108280:	e9 55 f2 ff ff       	jmp    801074da <alltraps>

80108285 <vector190>:
.globl vector190
vector190:
  pushl $0
80108285:	6a 00                	push   $0x0
  pushl $190
80108287:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010828c:	e9 49 f2 ff ff       	jmp    801074da <alltraps>

80108291 <vector191>:
.globl vector191
vector191:
  pushl $0
80108291:	6a 00                	push   $0x0
  pushl $191
80108293:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108298:	e9 3d f2 ff ff       	jmp    801074da <alltraps>

8010829d <vector192>:
.globl vector192
vector192:
  pushl $0
8010829d:	6a 00                	push   $0x0
  pushl $192
8010829f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801082a4:	e9 31 f2 ff ff       	jmp    801074da <alltraps>

801082a9 <vector193>:
.globl vector193
vector193:
  pushl $0
801082a9:	6a 00                	push   $0x0
  pushl $193
801082ab:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801082b0:	e9 25 f2 ff ff       	jmp    801074da <alltraps>

801082b5 <vector194>:
.globl vector194
vector194:
  pushl $0
801082b5:	6a 00                	push   $0x0
  pushl $194
801082b7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801082bc:	e9 19 f2 ff ff       	jmp    801074da <alltraps>

801082c1 <vector195>:
.globl vector195
vector195:
  pushl $0
801082c1:	6a 00                	push   $0x0
  pushl $195
801082c3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801082c8:	e9 0d f2 ff ff       	jmp    801074da <alltraps>

801082cd <vector196>:
.globl vector196
vector196:
  pushl $0
801082cd:	6a 00                	push   $0x0
  pushl $196
801082cf:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801082d4:	e9 01 f2 ff ff       	jmp    801074da <alltraps>

801082d9 <vector197>:
.globl vector197
vector197:
  pushl $0
801082d9:	6a 00                	push   $0x0
  pushl $197
801082db:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801082e0:	e9 f5 f1 ff ff       	jmp    801074da <alltraps>

801082e5 <vector198>:
.globl vector198
vector198:
  pushl $0
801082e5:	6a 00                	push   $0x0
  pushl $198
801082e7:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801082ec:	e9 e9 f1 ff ff       	jmp    801074da <alltraps>

801082f1 <vector199>:
.globl vector199
vector199:
  pushl $0
801082f1:	6a 00                	push   $0x0
  pushl $199
801082f3:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801082f8:	e9 dd f1 ff ff       	jmp    801074da <alltraps>

801082fd <vector200>:
.globl vector200
vector200:
  pushl $0
801082fd:	6a 00                	push   $0x0
  pushl $200
801082ff:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108304:	e9 d1 f1 ff ff       	jmp    801074da <alltraps>

80108309 <vector201>:
.globl vector201
vector201:
  pushl $0
80108309:	6a 00                	push   $0x0
  pushl $201
8010830b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108310:	e9 c5 f1 ff ff       	jmp    801074da <alltraps>

80108315 <vector202>:
.globl vector202
vector202:
  pushl $0
80108315:	6a 00                	push   $0x0
  pushl $202
80108317:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010831c:	e9 b9 f1 ff ff       	jmp    801074da <alltraps>

80108321 <vector203>:
.globl vector203
vector203:
  pushl $0
80108321:	6a 00                	push   $0x0
  pushl $203
80108323:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108328:	e9 ad f1 ff ff       	jmp    801074da <alltraps>

8010832d <vector204>:
.globl vector204
vector204:
  pushl $0
8010832d:	6a 00                	push   $0x0
  pushl $204
8010832f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108334:	e9 a1 f1 ff ff       	jmp    801074da <alltraps>

80108339 <vector205>:
.globl vector205
vector205:
  pushl $0
80108339:	6a 00                	push   $0x0
  pushl $205
8010833b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108340:	e9 95 f1 ff ff       	jmp    801074da <alltraps>

80108345 <vector206>:
.globl vector206
vector206:
  pushl $0
80108345:	6a 00                	push   $0x0
  pushl $206
80108347:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010834c:	e9 89 f1 ff ff       	jmp    801074da <alltraps>

80108351 <vector207>:
.globl vector207
vector207:
  pushl $0
80108351:	6a 00                	push   $0x0
  pushl $207
80108353:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108358:	e9 7d f1 ff ff       	jmp    801074da <alltraps>

8010835d <vector208>:
.globl vector208
vector208:
  pushl $0
8010835d:	6a 00                	push   $0x0
  pushl $208
8010835f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108364:	e9 71 f1 ff ff       	jmp    801074da <alltraps>

80108369 <vector209>:
.globl vector209
vector209:
  pushl $0
80108369:	6a 00                	push   $0x0
  pushl $209
8010836b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108370:	e9 65 f1 ff ff       	jmp    801074da <alltraps>

80108375 <vector210>:
.globl vector210
vector210:
  pushl $0
80108375:	6a 00                	push   $0x0
  pushl $210
80108377:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010837c:	e9 59 f1 ff ff       	jmp    801074da <alltraps>

80108381 <vector211>:
.globl vector211
vector211:
  pushl $0
80108381:	6a 00                	push   $0x0
  pushl $211
80108383:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108388:	e9 4d f1 ff ff       	jmp    801074da <alltraps>

8010838d <vector212>:
.globl vector212
vector212:
  pushl $0
8010838d:	6a 00                	push   $0x0
  pushl $212
8010838f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108394:	e9 41 f1 ff ff       	jmp    801074da <alltraps>

80108399 <vector213>:
.globl vector213
vector213:
  pushl $0
80108399:	6a 00                	push   $0x0
  pushl $213
8010839b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801083a0:	e9 35 f1 ff ff       	jmp    801074da <alltraps>

801083a5 <vector214>:
.globl vector214
vector214:
  pushl $0
801083a5:	6a 00                	push   $0x0
  pushl $214
801083a7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801083ac:	e9 29 f1 ff ff       	jmp    801074da <alltraps>

801083b1 <vector215>:
.globl vector215
vector215:
  pushl $0
801083b1:	6a 00                	push   $0x0
  pushl $215
801083b3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801083b8:	e9 1d f1 ff ff       	jmp    801074da <alltraps>

801083bd <vector216>:
.globl vector216
vector216:
  pushl $0
801083bd:	6a 00                	push   $0x0
  pushl $216
801083bf:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801083c4:	e9 11 f1 ff ff       	jmp    801074da <alltraps>

801083c9 <vector217>:
.globl vector217
vector217:
  pushl $0
801083c9:	6a 00                	push   $0x0
  pushl $217
801083cb:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801083d0:	e9 05 f1 ff ff       	jmp    801074da <alltraps>

801083d5 <vector218>:
.globl vector218
vector218:
  pushl $0
801083d5:	6a 00                	push   $0x0
  pushl $218
801083d7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801083dc:	e9 f9 f0 ff ff       	jmp    801074da <alltraps>

801083e1 <vector219>:
.globl vector219
vector219:
  pushl $0
801083e1:	6a 00                	push   $0x0
  pushl $219
801083e3:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801083e8:	e9 ed f0 ff ff       	jmp    801074da <alltraps>

801083ed <vector220>:
.globl vector220
vector220:
  pushl $0
801083ed:	6a 00                	push   $0x0
  pushl $220
801083ef:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801083f4:	e9 e1 f0 ff ff       	jmp    801074da <alltraps>

801083f9 <vector221>:
.globl vector221
vector221:
  pushl $0
801083f9:	6a 00                	push   $0x0
  pushl $221
801083fb:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108400:	e9 d5 f0 ff ff       	jmp    801074da <alltraps>

80108405 <vector222>:
.globl vector222
vector222:
  pushl $0
80108405:	6a 00                	push   $0x0
  pushl $222
80108407:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010840c:	e9 c9 f0 ff ff       	jmp    801074da <alltraps>

80108411 <vector223>:
.globl vector223
vector223:
  pushl $0
80108411:	6a 00                	push   $0x0
  pushl $223
80108413:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108418:	e9 bd f0 ff ff       	jmp    801074da <alltraps>

8010841d <vector224>:
.globl vector224
vector224:
  pushl $0
8010841d:	6a 00                	push   $0x0
  pushl $224
8010841f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108424:	e9 b1 f0 ff ff       	jmp    801074da <alltraps>

80108429 <vector225>:
.globl vector225
vector225:
  pushl $0
80108429:	6a 00                	push   $0x0
  pushl $225
8010842b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108430:	e9 a5 f0 ff ff       	jmp    801074da <alltraps>

80108435 <vector226>:
.globl vector226
vector226:
  pushl $0
80108435:	6a 00                	push   $0x0
  pushl $226
80108437:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010843c:	e9 99 f0 ff ff       	jmp    801074da <alltraps>

80108441 <vector227>:
.globl vector227
vector227:
  pushl $0
80108441:	6a 00                	push   $0x0
  pushl $227
80108443:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108448:	e9 8d f0 ff ff       	jmp    801074da <alltraps>

8010844d <vector228>:
.globl vector228
vector228:
  pushl $0
8010844d:	6a 00                	push   $0x0
  pushl $228
8010844f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108454:	e9 81 f0 ff ff       	jmp    801074da <alltraps>

80108459 <vector229>:
.globl vector229
vector229:
  pushl $0
80108459:	6a 00                	push   $0x0
  pushl $229
8010845b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108460:	e9 75 f0 ff ff       	jmp    801074da <alltraps>

80108465 <vector230>:
.globl vector230
vector230:
  pushl $0
80108465:	6a 00                	push   $0x0
  pushl $230
80108467:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010846c:	e9 69 f0 ff ff       	jmp    801074da <alltraps>

80108471 <vector231>:
.globl vector231
vector231:
  pushl $0
80108471:	6a 00                	push   $0x0
  pushl $231
80108473:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108478:	e9 5d f0 ff ff       	jmp    801074da <alltraps>

8010847d <vector232>:
.globl vector232
vector232:
  pushl $0
8010847d:	6a 00                	push   $0x0
  pushl $232
8010847f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108484:	e9 51 f0 ff ff       	jmp    801074da <alltraps>

80108489 <vector233>:
.globl vector233
vector233:
  pushl $0
80108489:	6a 00                	push   $0x0
  pushl $233
8010848b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108490:	e9 45 f0 ff ff       	jmp    801074da <alltraps>

80108495 <vector234>:
.globl vector234
vector234:
  pushl $0
80108495:	6a 00                	push   $0x0
  pushl $234
80108497:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010849c:	e9 39 f0 ff ff       	jmp    801074da <alltraps>

801084a1 <vector235>:
.globl vector235
vector235:
  pushl $0
801084a1:	6a 00                	push   $0x0
  pushl $235
801084a3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801084a8:	e9 2d f0 ff ff       	jmp    801074da <alltraps>

801084ad <vector236>:
.globl vector236
vector236:
  pushl $0
801084ad:	6a 00                	push   $0x0
  pushl $236
801084af:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801084b4:	e9 21 f0 ff ff       	jmp    801074da <alltraps>

801084b9 <vector237>:
.globl vector237
vector237:
  pushl $0
801084b9:	6a 00                	push   $0x0
  pushl $237
801084bb:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801084c0:	e9 15 f0 ff ff       	jmp    801074da <alltraps>

801084c5 <vector238>:
.globl vector238
vector238:
  pushl $0
801084c5:	6a 00                	push   $0x0
  pushl $238
801084c7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801084cc:	e9 09 f0 ff ff       	jmp    801074da <alltraps>

801084d1 <vector239>:
.globl vector239
vector239:
  pushl $0
801084d1:	6a 00                	push   $0x0
  pushl $239
801084d3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801084d8:	e9 fd ef ff ff       	jmp    801074da <alltraps>

801084dd <vector240>:
.globl vector240
vector240:
  pushl $0
801084dd:	6a 00                	push   $0x0
  pushl $240
801084df:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801084e4:	e9 f1 ef ff ff       	jmp    801074da <alltraps>

801084e9 <vector241>:
.globl vector241
vector241:
  pushl $0
801084e9:	6a 00                	push   $0x0
  pushl $241
801084eb:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801084f0:	e9 e5 ef ff ff       	jmp    801074da <alltraps>

801084f5 <vector242>:
.globl vector242
vector242:
  pushl $0
801084f5:	6a 00                	push   $0x0
  pushl $242
801084f7:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801084fc:	e9 d9 ef ff ff       	jmp    801074da <alltraps>

80108501 <vector243>:
.globl vector243
vector243:
  pushl $0
80108501:	6a 00                	push   $0x0
  pushl $243
80108503:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108508:	e9 cd ef ff ff       	jmp    801074da <alltraps>

8010850d <vector244>:
.globl vector244
vector244:
  pushl $0
8010850d:	6a 00                	push   $0x0
  pushl $244
8010850f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108514:	e9 c1 ef ff ff       	jmp    801074da <alltraps>

80108519 <vector245>:
.globl vector245
vector245:
  pushl $0
80108519:	6a 00                	push   $0x0
  pushl $245
8010851b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108520:	e9 b5 ef ff ff       	jmp    801074da <alltraps>

80108525 <vector246>:
.globl vector246
vector246:
  pushl $0
80108525:	6a 00                	push   $0x0
  pushl $246
80108527:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010852c:	e9 a9 ef ff ff       	jmp    801074da <alltraps>

80108531 <vector247>:
.globl vector247
vector247:
  pushl $0
80108531:	6a 00                	push   $0x0
  pushl $247
80108533:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108538:	e9 9d ef ff ff       	jmp    801074da <alltraps>

8010853d <vector248>:
.globl vector248
vector248:
  pushl $0
8010853d:	6a 00                	push   $0x0
  pushl $248
8010853f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108544:	e9 91 ef ff ff       	jmp    801074da <alltraps>

80108549 <vector249>:
.globl vector249
vector249:
  pushl $0
80108549:	6a 00                	push   $0x0
  pushl $249
8010854b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108550:	e9 85 ef ff ff       	jmp    801074da <alltraps>

80108555 <vector250>:
.globl vector250
vector250:
  pushl $0
80108555:	6a 00                	push   $0x0
  pushl $250
80108557:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010855c:	e9 79 ef ff ff       	jmp    801074da <alltraps>

80108561 <vector251>:
.globl vector251
vector251:
  pushl $0
80108561:	6a 00                	push   $0x0
  pushl $251
80108563:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108568:	e9 6d ef ff ff       	jmp    801074da <alltraps>

8010856d <vector252>:
.globl vector252
vector252:
  pushl $0
8010856d:	6a 00                	push   $0x0
  pushl $252
8010856f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108574:	e9 61 ef ff ff       	jmp    801074da <alltraps>

80108579 <vector253>:
.globl vector253
vector253:
  pushl $0
80108579:	6a 00                	push   $0x0
  pushl $253
8010857b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108580:	e9 55 ef ff ff       	jmp    801074da <alltraps>

80108585 <vector254>:
.globl vector254
vector254:
  pushl $0
80108585:	6a 00                	push   $0x0
  pushl $254
80108587:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010858c:	e9 49 ef ff ff       	jmp    801074da <alltraps>

80108591 <vector255>:
.globl vector255
vector255:
  pushl $0
80108591:	6a 00                	push   $0x0
  pushl $255
80108593:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108598:	e9 3d ef ff ff       	jmp    801074da <alltraps>

8010859d <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010859d:	55                   	push   %ebp
8010859e:	89 e5                	mov    %esp,%ebp
801085a0:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801085a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801085a6:	83 e8 01             	sub    $0x1,%eax
801085a9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801085ad:	8b 45 08             	mov    0x8(%ebp),%eax
801085b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801085b4:	8b 45 08             	mov    0x8(%ebp),%eax
801085b7:	c1 e8 10             	shr    $0x10,%eax
801085ba:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801085be:	8d 45 fa             	lea    -0x6(%ebp),%eax
801085c1:	0f 01 10             	lgdtl  (%eax)
}
801085c4:	90                   	nop
801085c5:	c9                   	leave  
801085c6:	c3                   	ret    

801085c7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801085c7:	55                   	push   %ebp
801085c8:	89 e5                	mov    %esp,%ebp
801085ca:	83 ec 04             	sub    $0x4,%esp
801085cd:	8b 45 08             	mov    0x8(%ebp),%eax
801085d0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801085d4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085d8:	0f 00 d8             	ltr    %ax
}
801085db:	90                   	nop
801085dc:	c9                   	leave  
801085dd:	c3                   	ret    

801085de <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801085de:	55                   	push   %ebp
801085df:	89 e5                	mov    %esp,%ebp
801085e1:	83 ec 04             	sub    $0x4,%esp
801085e4:	8b 45 08             	mov    0x8(%ebp),%eax
801085e7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801085eb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085ef:	8e e8                	mov    %eax,%gs
}
801085f1:	90                   	nop
801085f2:	c9                   	leave  
801085f3:	c3                   	ret    

801085f4 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801085f4:	55                   	push   %ebp
801085f5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801085f7:	8b 45 08             	mov    0x8(%ebp),%eax
801085fa:	0f 22 d8             	mov    %eax,%cr3
}
801085fd:	90                   	nop
801085fe:	5d                   	pop    %ebp
801085ff:	c3                   	ret    

80108600 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108600:	55                   	push   %ebp
80108601:	89 e5                	mov    %esp,%ebp
80108603:	8b 45 08             	mov    0x8(%ebp),%eax
80108606:	05 00 00 00 80       	add    $0x80000000,%eax
8010860b:	5d                   	pop    %ebp
8010860c:	c3                   	ret    

8010860d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010860d:	55                   	push   %ebp
8010860e:	89 e5                	mov    %esp,%ebp
80108610:	8b 45 08             	mov    0x8(%ebp),%eax
80108613:	05 00 00 00 80       	add    $0x80000000,%eax
80108618:	5d                   	pop    %ebp
80108619:	c3                   	ret    

8010861a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010861a:	55                   	push   %ebp
8010861b:	89 e5                	mov    %esp,%ebp
8010861d:	53                   	push   %ebx
8010861e:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108621:	e8 ab b1 ff ff       	call   801037d1 <cpunum>
80108626:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010862c:	05 80 38 11 80       	add    $0x80113880,%eax
80108631:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108637:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010863d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108640:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108649:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010864d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108650:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108654:	83 e2 f0             	and    $0xfffffff0,%edx
80108657:	83 ca 0a             	or     $0xa,%edx
8010865a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108660:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108664:	83 ca 10             	or     $0x10,%edx
80108667:	88 50 7d             	mov    %dl,0x7d(%eax)
8010866a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108671:	83 e2 9f             	and    $0xffffff9f,%edx
80108674:	88 50 7d             	mov    %dl,0x7d(%eax)
80108677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010867e:	83 ca 80             	or     $0xffffff80,%edx
80108681:	88 50 7d             	mov    %dl,0x7d(%eax)
80108684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108687:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010868b:	83 ca 0f             	or     $0xf,%edx
8010868e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108694:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108698:	83 e2 ef             	and    $0xffffffef,%edx
8010869b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010869e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086a5:	83 e2 df             	and    $0xffffffdf,%edx
801086a8:	88 50 7e             	mov    %dl,0x7e(%eax)
801086ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ae:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086b2:	83 ca 40             	or     $0x40,%edx
801086b5:	88 50 7e             	mov    %dl,0x7e(%eax)
801086b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086bf:	83 ca 80             	or     $0xffffff80,%edx
801086c2:	88 50 7e             	mov    %dl,0x7e(%eax)
801086c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c8:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801086cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cf:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801086d6:	ff ff 
801086d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086db:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801086e2:	00 00 
801086e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e7:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801086ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086f8:	83 e2 f0             	and    $0xfffffff0,%edx
801086fb:	83 ca 02             	or     $0x2,%edx
801086fe:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108707:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010870e:	83 ca 10             	or     $0x10,%edx
80108711:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108721:	83 e2 9f             	and    $0xffffff9f,%edx
80108724:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010872a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108734:	83 ca 80             	or     $0xffffff80,%edx
80108737:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010873d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108740:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108747:	83 ca 0f             	or     $0xf,%edx
8010874a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108753:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010875a:	83 e2 ef             	and    $0xffffffef,%edx
8010875d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108766:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010876d:	83 e2 df             	and    $0xffffffdf,%edx
80108770:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108779:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108780:	83 ca 40             	or     $0x40,%edx
80108783:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108793:	83 ca 80             	or     $0xffffff80,%edx
80108796:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010879c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801087a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a9:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801087b0:	ff ff 
801087b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b5:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801087bc:	00 00 
801087be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c1:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087d2:	83 e2 f0             	and    $0xfffffff0,%edx
801087d5:	83 ca 0a             	or     $0xa,%edx
801087d8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087e8:	83 ca 10             	or     $0x10,%edx
801087eb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087fb:	83 ca 60             	or     $0x60,%edx
801087fe:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108807:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010880e:	83 ca 80             	or     $0xffffff80,%edx
80108811:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108821:	83 ca 0f             	or     $0xf,%edx
80108824:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010882a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108834:	83 e2 ef             	and    $0xffffffef,%edx
80108837:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010883d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108840:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108847:	83 e2 df             	and    $0xffffffdf,%edx
8010884a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108853:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010885a:	83 ca 40             	or     $0x40,%edx
8010885d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108866:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010886d:	83 ca 80             	or     $0xffffff80,%edx
80108870:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108879:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108883:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010888a:	ff ff 
8010888c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108896:	00 00 
80108898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889b:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801088a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088ac:	83 e2 f0             	and    $0xfffffff0,%edx
801088af:	83 ca 02             	or     $0x2,%edx
801088b2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088c2:	83 ca 10             	or     $0x10,%edx
801088c5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ce:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088d5:	83 ca 60             	or     $0x60,%edx
801088d8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088e8:	83 ca 80             	or     $0xffffff80,%edx
801088eb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088fb:	83 ca 0f             	or     $0xf,%edx
801088fe:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108907:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010890e:	83 e2 ef             	and    $0xffffffef,%edx
80108911:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108921:	83 e2 df             	and    $0xffffffdf,%edx
80108924:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010892a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108934:	83 ca 40             	or     $0x40,%edx
80108937:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010893d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108940:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108947:	83 ca 80             	or     $0xffffff80,%edx
8010894a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108953:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010895a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895d:	05 b4 00 00 00       	add    $0xb4,%eax
80108962:	89 c3                	mov    %eax,%ebx
80108964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108967:	05 b4 00 00 00       	add    $0xb4,%eax
8010896c:	c1 e8 10             	shr    $0x10,%eax
8010896f:	89 c2                	mov    %eax,%edx
80108971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108974:	05 b4 00 00 00       	add    $0xb4,%eax
80108979:	c1 e8 18             	shr    $0x18,%eax
8010897c:	89 c1                	mov    %eax,%ecx
8010897e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108981:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108988:	00 00 
8010898a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108997:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010899d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089a7:	83 e2 f0             	and    $0xfffffff0,%edx
801089aa:	83 ca 02             	or     $0x2,%edx
801089ad:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089bd:	83 ca 10             	or     $0x10,%edx
801089c0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089d0:	83 e2 9f             	and    $0xffffff9f,%edx
801089d3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089dc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089e3:	83 ca 80             	or     $0xffffff80,%edx
801089e6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089f6:	83 e2 f0             	and    $0xfffffff0,%edx
801089f9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a02:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a09:	83 e2 ef             	and    $0xffffffef,%edx
80108a0c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a15:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a1c:	83 e2 df             	and    $0xffffffdf,%edx
80108a1f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a28:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a2f:	83 ca 40             	or     $0x40,%edx
80108a32:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a42:	83 ca 80             	or     $0xffffff80,%edx
80108a45:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4e:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a57:	83 c0 70             	add    $0x70,%eax
80108a5a:	83 ec 08             	sub    $0x8,%esp
80108a5d:	6a 38                	push   $0x38
80108a5f:	50                   	push   %eax
80108a60:	e8 38 fb ff ff       	call   8010859d <lgdt>
80108a65:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108a68:	83 ec 0c             	sub    $0xc,%esp
80108a6b:	6a 18                	push   $0x18
80108a6d:	e8 6c fb ff ff       	call   801085de <loadgs>
80108a72:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a78:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108a7e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a85:	00 00 00 00 
}
80108a89:	90                   	nop
80108a8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a8d:	c9                   	leave  
80108a8e:	c3                   	ret    

80108a8f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a8f:	55                   	push   %ebp
80108a90:	89 e5                	mov    %esp,%ebp
80108a92:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a95:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a98:	c1 e8 16             	shr    $0x16,%eax
80108a9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa5:	01 d0                	add    %edx,%eax
80108aa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aad:	8b 00                	mov    (%eax),%eax
80108aaf:	83 e0 01             	and    $0x1,%eax
80108ab2:	85 c0                	test   %eax,%eax
80108ab4:	74 18                	je     80108ace <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab9:	8b 00                	mov    (%eax),%eax
80108abb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ac0:	50                   	push   %eax
80108ac1:	e8 47 fb ff ff       	call   8010860d <p2v>
80108ac6:	83 c4 04             	add    $0x4,%esp
80108ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108acc:	eb 48                	jmp    80108b16 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108ace:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108ad2:	74 0e                	je     80108ae2 <walkpgdir+0x53>
80108ad4:	e8 92 a9 ff ff       	call   8010346b <kalloc>
80108ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108adc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108ae0:	75 07                	jne    80108ae9 <walkpgdir+0x5a>
      return 0;
80108ae2:	b8 00 00 00 00       	mov    $0x0,%eax
80108ae7:	eb 44                	jmp    80108b2d <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108ae9:	83 ec 04             	sub    $0x4,%esp
80108aec:	68 00 10 00 00       	push   $0x1000
80108af1:	6a 00                	push   $0x0
80108af3:	ff 75 f4             	pushl  -0xc(%ebp)
80108af6:	e8 e8 d2 ff ff       	call   80105de3 <memset>
80108afb:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108afe:	83 ec 0c             	sub    $0xc,%esp
80108b01:	ff 75 f4             	pushl  -0xc(%ebp)
80108b04:	e8 f7 fa ff ff       	call   80108600 <v2p>
80108b09:	83 c4 10             	add    $0x10,%esp
80108b0c:	83 c8 07             	or     $0x7,%eax
80108b0f:	89 c2                	mov    %eax,%edx
80108b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b14:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b19:	c1 e8 0c             	shr    $0xc,%eax
80108b1c:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2b:	01 d0                	add    %edx,%eax
}
80108b2d:	c9                   	leave  
80108b2e:	c3                   	ret    

80108b2f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108b2f:	55                   	push   %ebp
80108b30:	89 e5                	mov    %esp,%ebp
80108b32:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108b40:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b43:	8b 45 10             	mov    0x10(%ebp),%eax
80108b46:	01 d0                	add    %edx,%eax
80108b48:	83 e8 01             	sub    $0x1,%eax
80108b4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108b53:	83 ec 04             	sub    $0x4,%esp
80108b56:	6a 01                	push   $0x1
80108b58:	ff 75 f4             	pushl  -0xc(%ebp)
80108b5b:	ff 75 08             	pushl  0x8(%ebp)
80108b5e:	e8 2c ff ff ff       	call   80108a8f <walkpgdir>
80108b63:	83 c4 10             	add    $0x10,%esp
80108b66:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b69:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b6d:	75 07                	jne    80108b76 <mappages+0x47>
      return -1;
80108b6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b74:	eb 47                	jmp    80108bbd <mappages+0x8e>
    if(*pte & PTE_P)
80108b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b79:	8b 00                	mov    (%eax),%eax
80108b7b:	83 e0 01             	and    $0x1,%eax
80108b7e:	85 c0                	test   %eax,%eax
80108b80:	74 0d                	je     80108b8f <mappages+0x60>
      panic("remap");
80108b82:	83 ec 0c             	sub    $0xc,%esp
80108b85:	68 94 9a 10 80       	push   $0x80109a94
80108b8a:	e8 d7 79 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108b8f:	8b 45 18             	mov    0x18(%ebp),%eax
80108b92:	0b 45 14             	or     0x14(%ebp),%eax
80108b95:	83 c8 01             	or     $0x1,%eax
80108b98:	89 c2                	mov    %eax,%edx
80108b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b9d:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ba5:	74 10                	je     80108bb7 <mappages+0x88>
      break;
    a += PGSIZE;
80108ba7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108bae:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108bb5:	eb 9c                	jmp    80108b53 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108bb7:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108bb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bbd:	c9                   	leave  
80108bbe:	c3                   	ret    

80108bbf <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108bbf:	55                   	push   %ebp
80108bc0:	89 e5                	mov    %esp,%ebp
80108bc2:	53                   	push   %ebx
80108bc3:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108bc6:	e8 a0 a8 ff ff       	call   8010346b <kalloc>
80108bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108bce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108bd2:	75 0a                	jne    80108bde <setupkvm+0x1f>
    return 0;
80108bd4:	b8 00 00 00 00       	mov    $0x0,%eax
80108bd9:	e9 8e 00 00 00       	jmp    80108c6c <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108bde:	83 ec 04             	sub    $0x4,%esp
80108be1:	68 00 10 00 00       	push   $0x1000
80108be6:	6a 00                	push   $0x0
80108be8:	ff 75 f0             	pushl  -0x10(%ebp)
80108beb:	e8 f3 d1 ff ff       	call   80105de3 <memset>
80108bf0:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108bf3:	83 ec 0c             	sub    $0xc,%esp
80108bf6:	68 00 00 00 0e       	push   $0xe000000
80108bfb:	e8 0d fa ff ff       	call   8010860d <p2v>
80108c00:	83 c4 10             	add    $0x10,%esp
80108c03:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108c08:	76 0d                	jbe    80108c17 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108c0a:	83 ec 0c             	sub    $0xc,%esp
80108c0d:	68 9a 9a 10 80       	push   $0x80109a9a
80108c12:	e8 4f 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c17:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108c1e:	eb 40                	jmp    80108c60 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c23:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c29:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2f:	8b 58 08             	mov    0x8(%eax),%ebx
80108c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c35:	8b 40 04             	mov    0x4(%eax),%eax
80108c38:	29 c3                	sub    %eax,%ebx
80108c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3d:	8b 00                	mov    (%eax),%eax
80108c3f:	83 ec 0c             	sub    $0xc,%esp
80108c42:	51                   	push   %ecx
80108c43:	52                   	push   %edx
80108c44:	53                   	push   %ebx
80108c45:	50                   	push   %eax
80108c46:	ff 75 f0             	pushl  -0x10(%ebp)
80108c49:	e8 e1 fe ff ff       	call   80108b2f <mappages>
80108c4e:	83 c4 20             	add    $0x20,%esp
80108c51:	85 c0                	test   %eax,%eax
80108c53:	79 07                	jns    80108c5c <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108c55:	b8 00 00 00 00       	mov    $0x0,%eax
80108c5a:	eb 10                	jmp    80108c6c <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c5c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108c60:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108c67:	72 b7                	jb     80108c20 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108c6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c6f:	c9                   	leave  
80108c70:	c3                   	ret    

80108c71 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108c71:	55                   	push   %ebp
80108c72:	89 e5                	mov    %esp,%ebp
80108c74:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108c77:	e8 43 ff ff ff       	call   80108bbf <setupkvm>
80108c7c:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108c81:	e8 03 00 00 00       	call   80108c89 <switchkvm>
}
80108c86:	90                   	nop
80108c87:	c9                   	leave  
80108c88:	c3                   	ret    

80108c89 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108c89:	55                   	push   %ebp
80108c8a:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c8c:	a1 58 66 11 80       	mov    0x80116658,%eax
80108c91:	50                   	push   %eax
80108c92:	e8 69 f9 ff ff       	call   80108600 <v2p>
80108c97:	83 c4 04             	add    $0x4,%esp
80108c9a:	50                   	push   %eax
80108c9b:	e8 54 f9 ff ff       	call   801085f4 <lcr3>
80108ca0:	83 c4 04             	add    $0x4,%esp
}
80108ca3:	90                   	nop
80108ca4:	c9                   	leave  
80108ca5:	c3                   	ret    

80108ca6 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108ca6:	55                   	push   %ebp
80108ca7:	89 e5                	mov    %esp,%ebp
80108ca9:	56                   	push   %esi
80108caa:	53                   	push   %ebx
  pushcli();
80108cab:	e8 2d d0 ff ff       	call   80105cdd <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108cb0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108cb6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cbd:	83 c2 08             	add    $0x8,%edx
80108cc0:	89 d6                	mov    %edx,%esi
80108cc2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cc9:	83 c2 08             	add    $0x8,%edx
80108ccc:	c1 ea 10             	shr    $0x10,%edx
80108ccf:	89 d3                	mov    %edx,%ebx
80108cd1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cd8:	83 c2 08             	add    $0x8,%edx
80108cdb:	c1 ea 18             	shr    $0x18,%edx
80108cde:	89 d1                	mov    %edx,%ecx
80108ce0:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108ce7:	67 00 
80108ce9:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108cf0:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108cf6:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cfd:	83 e2 f0             	and    $0xfffffff0,%edx
80108d00:	83 ca 09             	or     $0x9,%edx
80108d03:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d09:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d10:	83 ca 10             	or     $0x10,%edx
80108d13:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d19:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d20:	83 e2 9f             	and    $0xffffff9f,%edx
80108d23:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d29:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d30:	83 ca 80             	or     $0xffffff80,%edx
80108d33:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d39:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d40:	83 e2 f0             	and    $0xfffffff0,%edx
80108d43:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d49:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d50:	83 e2 ef             	and    $0xffffffef,%edx
80108d53:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d59:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d60:	83 e2 df             	and    $0xffffffdf,%edx
80108d63:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d69:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d70:	83 ca 40             	or     $0x40,%edx
80108d73:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d79:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d80:	83 e2 7f             	and    $0x7f,%edx
80108d83:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d89:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d8f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d95:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d9c:	83 e2 ef             	and    $0xffffffef,%edx
80108d9f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108da5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108dab:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108db1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108db7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108dbe:	8b 52 08             	mov    0x8(%edx),%edx
80108dc1:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108dc7:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108dca:	83 ec 0c             	sub    $0xc,%esp
80108dcd:	6a 30                	push   $0x30
80108dcf:	e8 f3 f7 ff ff       	call   801085c7 <ltr>
80108dd4:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80108dda:	8b 40 04             	mov    0x4(%eax),%eax
80108ddd:	85 c0                	test   %eax,%eax
80108ddf:	75 0d                	jne    80108dee <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108de1:	83 ec 0c             	sub    $0xc,%esp
80108de4:	68 ab 9a 10 80       	push   $0x80109aab
80108de9:	e8 78 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108dee:	8b 45 08             	mov    0x8(%ebp),%eax
80108df1:	8b 40 04             	mov    0x4(%eax),%eax
80108df4:	83 ec 0c             	sub    $0xc,%esp
80108df7:	50                   	push   %eax
80108df8:	e8 03 f8 ff ff       	call   80108600 <v2p>
80108dfd:	83 c4 10             	add    $0x10,%esp
80108e00:	83 ec 0c             	sub    $0xc,%esp
80108e03:	50                   	push   %eax
80108e04:	e8 eb f7 ff ff       	call   801085f4 <lcr3>
80108e09:	83 c4 10             	add    $0x10,%esp
  popcli();
80108e0c:	e8 11 cf ff ff       	call   80105d22 <popcli>
}
80108e11:	90                   	nop
80108e12:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108e15:	5b                   	pop    %ebx
80108e16:	5e                   	pop    %esi
80108e17:	5d                   	pop    %ebp
80108e18:	c3                   	ret    

80108e19 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108e19:	55                   	push   %ebp
80108e1a:	89 e5                	mov    %esp,%ebp
80108e1c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108e1f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108e26:	76 0d                	jbe    80108e35 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108e28:	83 ec 0c             	sub    $0xc,%esp
80108e2b:	68 bf 9a 10 80       	push   $0x80109abf
80108e30:	e8 31 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108e35:	e8 31 a6 ff ff       	call   8010346b <kalloc>
80108e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108e3d:	83 ec 04             	sub    $0x4,%esp
80108e40:	68 00 10 00 00       	push   $0x1000
80108e45:	6a 00                	push   $0x0
80108e47:	ff 75 f4             	pushl  -0xc(%ebp)
80108e4a:	e8 94 cf ff ff       	call   80105de3 <memset>
80108e4f:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e52:	83 ec 0c             	sub    $0xc,%esp
80108e55:	ff 75 f4             	pushl  -0xc(%ebp)
80108e58:	e8 a3 f7 ff ff       	call   80108600 <v2p>
80108e5d:	83 c4 10             	add    $0x10,%esp
80108e60:	83 ec 0c             	sub    $0xc,%esp
80108e63:	6a 06                	push   $0x6
80108e65:	50                   	push   %eax
80108e66:	68 00 10 00 00       	push   $0x1000
80108e6b:	6a 00                	push   $0x0
80108e6d:	ff 75 08             	pushl  0x8(%ebp)
80108e70:	e8 ba fc ff ff       	call   80108b2f <mappages>
80108e75:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108e78:	83 ec 04             	sub    $0x4,%esp
80108e7b:	ff 75 10             	pushl  0x10(%ebp)
80108e7e:	ff 75 0c             	pushl  0xc(%ebp)
80108e81:	ff 75 f4             	pushl  -0xc(%ebp)
80108e84:	e8 19 d0 ff ff       	call   80105ea2 <memmove>
80108e89:	83 c4 10             	add    $0x10,%esp
}
80108e8c:	90                   	nop
80108e8d:	c9                   	leave  
80108e8e:	c3                   	ret    

80108e8f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e8f:	55                   	push   %ebp
80108e90:	89 e5                	mov    %esp,%ebp
80108e92:	53                   	push   %ebx
80108e93:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e96:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e99:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e9e:	85 c0                	test   %eax,%eax
80108ea0:	74 0d                	je     80108eaf <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108ea2:	83 ec 0c             	sub    $0xc,%esp
80108ea5:	68 dc 9a 10 80       	push   $0x80109adc
80108eaa:	e8 b7 76 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108eaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108eb6:	e9 95 00 00 00       	jmp    80108f50 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec1:	01 d0                	add    %edx,%eax
80108ec3:	83 ec 04             	sub    $0x4,%esp
80108ec6:	6a 00                	push   $0x0
80108ec8:	50                   	push   %eax
80108ec9:	ff 75 08             	pushl  0x8(%ebp)
80108ecc:	e8 be fb ff ff       	call   80108a8f <walkpgdir>
80108ed1:	83 c4 10             	add    $0x10,%esp
80108ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108ed7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108edb:	75 0d                	jne    80108eea <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108edd:	83 ec 0c             	sub    $0xc,%esp
80108ee0:	68 ff 9a 10 80       	push   $0x80109aff
80108ee5:	e8 7c 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eed:	8b 00                	mov    (%eax),%eax
80108eef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ef4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108ef7:	8b 45 18             	mov    0x18(%ebp),%eax
80108efa:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108efd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108f02:	77 0b                	ja     80108f0f <loaduvm+0x80>
      n = sz - i;
80108f04:	8b 45 18             	mov    0x18(%ebp),%eax
80108f07:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f0d:	eb 07                	jmp    80108f16 <loaduvm+0x87>
    else
      n = PGSIZE;
80108f0f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108f16:	8b 55 14             	mov    0x14(%ebp),%edx
80108f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108f1f:	83 ec 0c             	sub    $0xc,%esp
80108f22:	ff 75 e8             	pushl  -0x18(%ebp)
80108f25:	e8 e3 f6 ff ff       	call   8010860d <p2v>
80108f2a:	83 c4 10             	add    $0x10,%esp
80108f2d:	ff 75 f0             	pushl  -0x10(%ebp)
80108f30:	53                   	push   %ebx
80108f31:	50                   	push   %eax
80108f32:	ff 75 10             	pushl  0x10(%ebp)
80108f35:	e8 36 96 ff ff       	call   80102570 <readi>
80108f3a:	83 c4 10             	add    $0x10,%esp
80108f3d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108f40:	74 07                	je     80108f49 <loaduvm+0xba>
      return -1;
80108f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f47:	eb 18                	jmp    80108f61 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108f49:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f53:	3b 45 18             	cmp    0x18(%ebp),%eax
80108f56:	0f 82 5f ff ff ff    	jb     80108ebb <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108f5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f64:	c9                   	leave  
80108f65:	c3                   	ret    

80108f66 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f66:	55                   	push   %ebp
80108f67:	89 e5                	mov    %esp,%ebp
80108f69:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f6c:	8b 45 10             	mov    0x10(%ebp),%eax
80108f6f:	85 c0                	test   %eax,%eax
80108f71:	79 0a                	jns    80108f7d <allocuvm+0x17>
    return 0;
80108f73:	b8 00 00 00 00       	mov    $0x0,%eax
80108f78:	e9 b0 00 00 00       	jmp    8010902d <allocuvm+0xc7>
  if(newsz < oldsz)
80108f7d:	8b 45 10             	mov    0x10(%ebp),%eax
80108f80:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f83:	73 08                	jae    80108f8d <allocuvm+0x27>
    return oldsz;
80108f85:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f88:	e9 a0 00 00 00       	jmp    8010902d <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f90:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108f9d:	eb 7f                	jmp    8010901e <allocuvm+0xb8>
    mem = kalloc();
80108f9f:	e8 c7 a4 ff ff       	call   8010346b <kalloc>
80108fa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108fa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108fab:	75 2b                	jne    80108fd8 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108fad:	83 ec 0c             	sub    $0xc,%esp
80108fb0:	68 1d 9b 10 80       	push   $0x80109b1d
80108fb5:	e8 0c 74 ff ff       	call   801003c6 <cprintf>
80108fba:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108fbd:	83 ec 04             	sub    $0x4,%esp
80108fc0:	ff 75 0c             	pushl  0xc(%ebp)
80108fc3:	ff 75 10             	pushl  0x10(%ebp)
80108fc6:	ff 75 08             	pushl  0x8(%ebp)
80108fc9:	e8 61 00 00 00       	call   8010902f <deallocuvm>
80108fce:	83 c4 10             	add    $0x10,%esp
      return 0;
80108fd1:	b8 00 00 00 00       	mov    $0x0,%eax
80108fd6:	eb 55                	jmp    8010902d <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108fd8:	83 ec 04             	sub    $0x4,%esp
80108fdb:	68 00 10 00 00       	push   $0x1000
80108fe0:	6a 00                	push   $0x0
80108fe2:	ff 75 f0             	pushl  -0x10(%ebp)
80108fe5:	e8 f9 cd ff ff       	call   80105de3 <memset>
80108fea:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108fed:	83 ec 0c             	sub    $0xc,%esp
80108ff0:	ff 75 f0             	pushl  -0x10(%ebp)
80108ff3:	e8 08 f6 ff ff       	call   80108600 <v2p>
80108ff8:	83 c4 10             	add    $0x10,%esp
80108ffb:	89 c2                	mov    %eax,%edx
80108ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109000:	83 ec 0c             	sub    $0xc,%esp
80109003:	6a 06                	push   $0x6
80109005:	52                   	push   %edx
80109006:	68 00 10 00 00       	push   $0x1000
8010900b:	50                   	push   %eax
8010900c:	ff 75 08             	pushl  0x8(%ebp)
8010900f:	e8 1b fb ff ff       	call   80108b2f <mappages>
80109014:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109017:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010901e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109021:	3b 45 10             	cmp    0x10(%ebp),%eax
80109024:	0f 82 75 ff ff ff    	jb     80108f9f <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010902a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010902d:	c9                   	leave  
8010902e:	c3                   	ret    

8010902f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010902f:	55                   	push   %ebp
80109030:	89 e5                	mov    %esp,%ebp
80109032:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109035:	8b 45 10             	mov    0x10(%ebp),%eax
80109038:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010903b:	72 08                	jb     80109045 <deallocuvm+0x16>
    return oldsz;
8010903d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109040:	e9 a5 00 00 00       	jmp    801090ea <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109045:	8b 45 10             	mov    0x10(%ebp),%eax
80109048:	05 ff 0f 00 00       	add    $0xfff,%eax
8010904d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109052:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109055:	e9 81 00 00 00       	jmp    801090db <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010905a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905d:	83 ec 04             	sub    $0x4,%esp
80109060:	6a 00                	push   $0x0
80109062:	50                   	push   %eax
80109063:	ff 75 08             	pushl  0x8(%ebp)
80109066:	e8 24 fa ff ff       	call   80108a8f <walkpgdir>
8010906b:	83 c4 10             	add    $0x10,%esp
8010906e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109071:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109075:	75 09                	jne    80109080 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109077:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010907e:	eb 54                	jmp    801090d4 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109080:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109083:	8b 00                	mov    (%eax),%eax
80109085:	83 e0 01             	and    $0x1,%eax
80109088:	85 c0                	test   %eax,%eax
8010908a:	74 48                	je     801090d4 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010908c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010908f:	8b 00                	mov    (%eax),%eax
80109091:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109096:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109099:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010909d:	75 0d                	jne    801090ac <deallocuvm+0x7d>
        panic("kfree");
8010909f:	83 ec 0c             	sub    $0xc,%esp
801090a2:	68 35 9b 10 80       	push   $0x80109b35
801090a7:	e8 ba 74 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801090ac:	83 ec 0c             	sub    $0xc,%esp
801090af:	ff 75 ec             	pushl  -0x14(%ebp)
801090b2:	e8 56 f5 ff ff       	call   8010860d <p2v>
801090b7:	83 c4 10             	add    $0x10,%esp
801090ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801090bd:	83 ec 0c             	sub    $0xc,%esp
801090c0:	ff 75 e8             	pushl  -0x18(%ebp)
801090c3:	e8 06 a3 ff ff       	call   801033ce <kfree>
801090c8:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801090cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801090d4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090de:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090e1:	0f 82 73 ff ff ff    	jb     8010905a <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801090e7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090ea:	c9                   	leave  
801090eb:	c3                   	ret    

801090ec <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801090ec:	55                   	push   %ebp
801090ed:	89 e5                	mov    %esp,%ebp
801090ef:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801090f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801090f6:	75 0d                	jne    80109105 <freevm+0x19>
    panic("freevm: no pgdir");
801090f8:	83 ec 0c             	sub    $0xc,%esp
801090fb:	68 3b 9b 10 80       	push   $0x80109b3b
80109100:	e8 61 74 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109105:	83 ec 04             	sub    $0x4,%esp
80109108:	6a 00                	push   $0x0
8010910a:	68 00 00 00 80       	push   $0x80000000
8010910f:	ff 75 08             	pushl  0x8(%ebp)
80109112:	e8 18 ff ff ff       	call   8010902f <deallocuvm>
80109117:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010911a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109121:	eb 4f                	jmp    80109172 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109126:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010912d:	8b 45 08             	mov    0x8(%ebp),%eax
80109130:	01 d0                	add    %edx,%eax
80109132:	8b 00                	mov    (%eax),%eax
80109134:	83 e0 01             	and    $0x1,%eax
80109137:	85 c0                	test   %eax,%eax
80109139:	74 33                	je     8010916e <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010913b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109145:	8b 45 08             	mov    0x8(%ebp),%eax
80109148:	01 d0                	add    %edx,%eax
8010914a:	8b 00                	mov    (%eax),%eax
8010914c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109151:	83 ec 0c             	sub    $0xc,%esp
80109154:	50                   	push   %eax
80109155:	e8 b3 f4 ff ff       	call   8010860d <p2v>
8010915a:	83 c4 10             	add    $0x10,%esp
8010915d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109160:	83 ec 0c             	sub    $0xc,%esp
80109163:	ff 75 f0             	pushl  -0x10(%ebp)
80109166:	e8 63 a2 ff ff       	call   801033ce <kfree>
8010916b:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010916e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109172:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109179:	76 a8                	jbe    80109123 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010917b:	83 ec 0c             	sub    $0xc,%esp
8010917e:	ff 75 08             	pushl  0x8(%ebp)
80109181:	e8 48 a2 ff ff       	call   801033ce <kfree>
80109186:	83 c4 10             	add    $0x10,%esp
}
80109189:	90                   	nop
8010918a:	c9                   	leave  
8010918b:	c3                   	ret    

8010918c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010918c:	55                   	push   %ebp
8010918d:	89 e5                	mov    %esp,%ebp
8010918f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109192:	83 ec 04             	sub    $0x4,%esp
80109195:	6a 00                	push   $0x0
80109197:	ff 75 0c             	pushl  0xc(%ebp)
8010919a:	ff 75 08             	pushl  0x8(%ebp)
8010919d:	e8 ed f8 ff ff       	call   80108a8f <walkpgdir>
801091a2:	83 c4 10             	add    $0x10,%esp
801091a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801091a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801091ac:	75 0d                	jne    801091bb <clearpteu+0x2f>
    panic("clearpteu");
801091ae:	83 ec 0c             	sub    $0xc,%esp
801091b1:	68 4c 9b 10 80       	push   $0x80109b4c
801091b6:	e8 ab 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801091bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091be:	8b 00                	mov    (%eax),%eax
801091c0:	83 e0 fb             	and    $0xfffffffb,%eax
801091c3:	89 c2                	mov    %eax,%edx
801091c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c8:	89 10                	mov    %edx,(%eax)
}
801091ca:	90                   	nop
801091cb:	c9                   	leave  
801091cc:	c3                   	ret    

801091cd <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801091cd:	55                   	push   %ebp
801091ce:	89 e5                	mov    %esp,%ebp
801091d0:	53                   	push   %ebx
801091d1:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801091d4:	e8 e6 f9 ff ff       	call   80108bbf <setupkvm>
801091d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801091dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801091e0:	75 0a                	jne    801091ec <copyuvm+0x1f>
    return 0;
801091e2:	b8 00 00 00 00       	mov    $0x0,%eax
801091e7:	e9 f8 00 00 00       	jmp    801092e4 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801091ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091f3:	e9 c4 00 00 00       	jmp    801092bc <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801091f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fb:	83 ec 04             	sub    $0x4,%esp
801091fe:	6a 00                	push   $0x0
80109200:	50                   	push   %eax
80109201:	ff 75 08             	pushl  0x8(%ebp)
80109204:	e8 86 f8 ff ff       	call   80108a8f <walkpgdir>
80109209:	83 c4 10             	add    $0x10,%esp
8010920c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010920f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109213:	75 0d                	jne    80109222 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109215:	83 ec 0c             	sub    $0xc,%esp
80109218:	68 56 9b 10 80       	push   $0x80109b56
8010921d:	e8 44 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109225:	8b 00                	mov    (%eax),%eax
80109227:	83 e0 01             	and    $0x1,%eax
8010922a:	85 c0                	test   %eax,%eax
8010922c:	75 0d                	jne    8010923b <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010922e:	83 ec 0c             	sub    $0xc,%esp
80109231:	68 70 9b 10 80       	push   $0x80109b70
80109236:	e8 2b 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010923b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010923e:	8b 00                	mov    (%eax),%eax
80109240:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109245:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010924b:	8b 00                	mov    (%eax),%eax
8010924d:	25 ff 0f 00 00       	and    $0xfff,%eax
80109252:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109255:	e8 11 a2 ff ff       	call   8010346b <kalloc>
8010925a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010925d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109261:	74 6a                	je     801092cd <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109263:	83 ec 0c             	sub    $0xc,%esp
80109266:	ff 75 e8             	pushl  -0x18(%ebp)
80109269:	e8 9f f3 ff ff       	call   8010860d <p2v>
8010926e:	83 c4 10             	add    $0x10,%esp
80109271:	83 ec 04             	sub    $0x4,%esp
80109274:	68 00 10 00 00       	push   $0x1000
80109279:	50                   	push   %eax
8010927a:	ff 75 e0             	pushl  -0x20(%ebp)
8010927d:	e8 20 cc ff ff       	call   80105ea2 <memmove>
80109282:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109285:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109288:	83 ec 0c             	sub    $0xc,%esp
8010928b:	ff 75 e0             	pushl  -0x20(%ebp)
8010928e:	e8 6d f3 ff ff       	call   80108600 <v2p>
80109293:	83 c4 10             	add    $0x10,%esp
80109296:	89 c2                	mov    %eax,%edx
80109298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929b:	83 ec 0c             	sub    $0xc,%esp
8010929e:	53                   	push   %ebx
8010929f:	52                   	push   %edx
801092a0:	68 00 10 00 00       	push   $0x1000
801092a5:	50                   	push   %eax
801092a6:	ff 75 f0             	pushl  -0x10(%ebp)
801092a9:	e8 81 f8 ff ff       	call   80108b2f <mappages>
801092ae:	83 c4 20             	add    $0x20,%esp
801092b1:	85 c0                	test   %eax,%eax
801092b3:	78 1b                	js     801092d0 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801092b5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801092bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092c2:	0f 82 30 ff ff ff    	jb     801091f8 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801092c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092cb:	eb 17                	jmp    801092e4 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801092cd:	90                   	nop
801092ce:	eb 01                	jmp    801092d1 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801092d0:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801092d1:	83 ec 0c             	sub    $0xc,%esp
801092d4:	ff 75 f0             	pushl  -0x10(%ebp)
801092d7:	e8 10 fe ff ff       	call   801090ec <freevm>
801092dc:	83 c4 10             	add    $0x10,%esp
  return 0;
801092df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801092e7:	c9                   	leave  
801092e8:	c3                   	ret    

801092e9 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801092e9:	55                   	push   %ebp
801092ea:	89 e5                	mov    %esp,%ebp
801092ec:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801092ef:	83 ec 04             	sub    $0x4,%esp
801092f2:	6a 00                	push   $0x0
801092f4:	ff 75 0c             	pushl  0xc(%ebp)
801092f7:	ff 75 08             	pushl  0x8(%ebp)
801092fa:	e8 90 f7 ff ff       	call   80108a8f <walkpgdir>
801092ff:	83 c4 10             	add    $0x10,%esp
80109302:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109308:	8b 00                	mov    (%eax),%eax
8010930a:	83 e0 01             	and    $0x1,%eax
8010930d:	85 c0                	test   %eax,%eax
8010930f:	75 07                	jne    80109318 <uva2ka+0x2f>
    return 0;
80109311:	b8 00 00 00 00       	mov    $0x0,%eax
80109316:	eb 29                	jmp    80109341 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931b:	8b 00                	mov    (%eax),%eax
8010931d:	83 e0 04             	and    $0x4,%eax
80109320:	85 c0                	test   %eax,%eax
80109322:	75 07                	jne    8010932b <uva2ka+0x42>
    return 0;
80109324:	b8 00 00 00 00       	mov    $0x0,%eax
80109329:	eb 16                	jmp    80109341 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010932b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932e:	8b 00                	mov    (%eax),%eax
80109330:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109335:	83 ec 0c             	sub    $0xc,%esp
80109338:	50                   	push   %eax
80109339:	e8 cf f2 ff ff       	call   8010860d <p2v>
8010933e:	83 c4 10             	add    $0x10,%esp
}
80109341:	c9                   	leave  
80109342:	c3                   	ret    

80109343 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109343:	55                   	push   %ebp
80109344:	89 e5                	mov    %esp,%ebp
80109346:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109349:	8b 45 10             	mov    0x10(%ebp),%eax
8010934c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010934f:	eb 7f                	jmp    801093d0 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109351:	8b 45 0c             	mov    0xc(%ebp),%eax
80109354:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109359:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010935c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010935f:	83 ec 08             	sub    $0x8,%esp
80109362:	50                   	push   %eax
80109363:	ff 75 08             	pushl  0x8(%ebp)
80109366:	e8 7e ff ff ff       	call   801092e9 <uva2ka>
8010936b:	83 c4 10             	add    $0x10,%esp
8010936e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109371:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109375:	75 07                	jne    8010937e <copyout+0x3b>
      return -1;
80109377:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010937c:	eb 61                	jmp    801093df <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010937e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109381:	2b 45 0c             	sub    0xc(%ebp),%eax
80109384:	05 00 10 00 00       	add    $0x1000,%eax
80109389:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010938c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010938f:	3b 45 14             	cmp    0x14(%ebp),%eax
80109392:	76 06                	jbe    8010939a <copyout+0x57>
      n = len;
80109394:	8b 45 14             	mov    0x14(%ebp),%eax
80109397:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010939a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010939d:	2b 45 ec             	sub    -0x14(%ebp),%eax
801093a0:	89 c2                	mov    %eax,%edx
801093a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093a5:	01 d0                	add    %edx,%eax
801093a7:	83 ec 04             	sub    $0x4,%esp
801093aa:	ff 75 f0             	pushl  -0x10(%ebp)
801093ad:	ff 75 f4             	pushl  -0xc(%ebp)
801093b0:	50                   	push   %eax
801093b1:	e8 ec ca ff ff       	call   80105ea2 <memmove>
801093b6:	83 c4 10             	add    $0x10,%esp
    len -= n;
801093b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801093bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c2:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801093c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093c8:	05 00 10 00 00       	add    $0x1000,%eax
801093cd:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801093d0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801093d4:	0f 85 77 ff ff ff    	jne    80109351 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801093da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093df:	c9                   	leave  
801093e0:	c3                   	ret    
