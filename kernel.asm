
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
8010002d:	b8 f4 43 10 80       	mov    $0x801043f4,%eax
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
8010003d:	68 5c 94 10 80       	push   $0x8010945c
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 29 5b 00 00       	call   80105b75 <initlock>
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
801000c1:	e8 d1 5a 00 00       	call   80105b97 <acquire>
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
8010010c:	e8 ed 5a 00 00       	call   80105bfe <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 72 57 00 00       	call   8010589e <sleep>
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
80100188:	e8 71 5a 00 00       	call   80105bfe <release>
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
801001aa:	68 63 94 10 80       	push   $0x80109463
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
//cprintf("bread \n");
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
801001e2:	e8 42 2f 00 00       	call   80103129 <iderw>
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
80100204:	68 74 94 10 80       	push   $0x80109474
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
80100223:	e8 01 2f 00 00       	call   80103129 <iderw>
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
80100243:	68 7b 94 10 80       	push   $0x8010947b
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 3d 59 00 00       	call   80105b97 <acquire>
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
801002b9:	e8 cb 56 00 00       	call   80105989 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 30 59 00 00       	call   80105bfe <release>
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
801003e2:	e8 b0 57 00 00       	call   80105b97 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 82 94 10 80       	push   $0x80109482
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
801004cd:	c7 45 ec 8b 94 10 80 	movl   $0x8010948b,-0x14(%ebp)
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
8010055b:	e8 9e 56 00 00       	call   80105bfe <release>
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
8010058b:	68 92 94 10 80       	push   $0x80109492
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
801005aa:	68 a1 94 10 80       	push   $0x801094a1
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 89 56 00 00       	call   80105c50 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 a3 94 10 80       	push   $0x801094a3
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
801006ca:	68 a7 94 10 80       	push   $0x801094a7
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
801006f7:	e8 bd 57 00 00       	call   80105eb9 <memmove>
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
80100721:	e8 d4 56 00 00       	call   80105dfa <memset>
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
801007b6:	e8 28 73 00 00       	call   80107ae3 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 1b 73 00 00       	call   80107ae3 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 0e 73 00 00       	call   80107ae3 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 fe 72 00 00       	call   80107ae3 <uartputc>
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
8010080e:	e8 84 53 00 00       	call   80105b97 <acquire>
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
80100956:	e8 2e 50 00 00       	call   80105989 <wakeup>
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
80100979:	e8 80 52 00 00       	call   80105bfe <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 b8 50 00 00       	call   80105a44 <procdump>
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
801009b1:	e8 e1 51 00 00       	call   80105b97 <acquire>
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
801009d3:	e8 26 52 00 00       	call   80105bfe <release>
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
80100a00:	e8 99 4e 00 00       	call   8010589e <sleep>
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
80100a7e:	e8 7b 51 00 00       	call   80105bfe <release>
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
80100abc:	e8 d6 50 00 00       	call   80105b97 <acquire>
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
80100afe:	e8 fb 50 00 00       	call   80105bfe <release>
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
80100b22:	68 ba 94 10 80       	push   $0x801094ba
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 44 50 00 00       	call   80105b75 <initlock>
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
80100b57:	e8 17 3f 00 00       	call   80104a73 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 8b 27 00 00       	call   801032f6 <ioapicenable>
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
80100b8d:	e8 27 33 00 00       	call   80103eb9 <begin_op>
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
80100bbf:	e8 fc 33 00 00       	call   80103fc0 <end_op>
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
80100c16:	e8 1d 80 00 00       	call   80108c38 <setupkvm>
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
80100c9c:	e8 3e 83 00 00       	call   80108fdf <allocuvm>
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
80100ccf:	e8 34 82 00 00       	call   80108f08 <loaduvm>
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
80100d23:	e8 98 32 00 00       	call   80103fc0 <end_op>
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
80100d54:	e8 86 82 00 00       	call   80108fdf <allocuvm>
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
80100d78:	e8 88 84 00 00       	call   80109205 <clearpteu>
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
80100db1:	e8 91 52 00 00       	call   80106047 <strlen>
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
80100dde:	e8 64 52 00 00       	call   80106047 <strlen>
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
80100e04:	e8 b3 85 00 00       	call   801093bc <copyout>
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
80100ea0:	e8 17 85 00 00       	call   801093bc <copyout>
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
80100ef1:	e8 07 51 00 00       	call   80105ffd <safestrcpy>
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
80100f47:	e8 d3 7d 00 00       	call   80108d1f <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 0b 82 00 00       	call   80109165 <freevm>
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
80100f8f:	e8 d1 81 00 00       	call   80109165 <freevm>
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
80100fbe:	e8 fd 2f 00 00       	call   80103fc0 <end_op>
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
80100fd6:	68 c2 94 10 80       	push   $0x801094c2
80100fdb:	68 00 1b 11 80       	push   $0x80111b00
80100fe0:	e8 90 4b 00 00       	call   80105b75 <initlock>
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
80100ff9:	e8 99 4b 00 00       	call   80105b97 <acquire>
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
80101026:	e8 d3 4b 00 00       	call   80105bfe <release>
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
80101049:	e8 b0 4b 00 00       	call   80105bfe <release>
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
80101066:	e8 2c 4b 00 00       	call   80105b97 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 c9 94 10 80       	push   $0x801094c9
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
8010109c:	e8 5d 4b 00 00       	call   80105bfe <release>
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
801010b7:	e8 db 4a 00 00       	call   80105b97 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 d1 94 10 80       	push   $0x801094d1
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
801010f7:	e8 02 4b 00 00       	call   80105bfe <release>
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
80101147:	e8 b2 4a 00 00       	call   80105bfe <release>
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
80101166:	e8 71 3b 00 00       	call   80104cdc <pipeclose>
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
80101188:	e8 2c 2d 00 00       	call   80103eb9 <begin_op>
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
801011af:	e8 0c 2e 00 00       	call   80103fc0 <end_op>
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
80101245:	e8 3a 3c 00 00       	call   80104e84 <piperead>
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
801012bc:	68 db 94 10 80       	push   $0x801094db
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
801012fe:	e8 83 3a 00 00       	call   80104d86 <pipewrite>
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
80101353:	e8 61 2b 00 00       	call   80103eb9 <begin_op>
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
801013cc:	e8 ef 2b 00 00       	call   80103fc0 <end_op>
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
801013e5:	68 e4 94 10 80       	push   $0x801094e4
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
8010141b:	68 f4 94 10 80       	push   $0x801094f4
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
8010146c:	e8 48 4a 00 00       	call   80105eb9 <memmove>
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
801014d3:	e8 e1 49 00 00       	call   80105eb9 <memmove>
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
80101519:	e8 dc 48 00 00       	call   80105dfa <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp, partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 37 2d 00 00       	call   80104266 <log_write>
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
8010163f:	e8 22 2c 00 00       	call   80104266 <log_write>
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
801016ca:	68 00 95 10 80       	push   $0x80109500
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
80101787:	68 16 95 10 80       	push   $0x80109516
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
801017c3:	e8 9e 2a 00 00       	call   80104266 <log_write>
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
801017e5:	68 29 95 10 80       	push   $0x80109529
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
8010182a:	c7 45 f0 34 95 10 80 	movl   $0x80109534,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 38 95 10 80 	movl   $0x80109538,-0x10(%ebp)
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
80101889:	c7 45 ec 3b 95 10 80 	movl   $0x8010953b,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 3f 95 10 80       	push   $0x8010953f
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
801018e2:	68 54 95 10 80       	push   $0x80109554
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
80101909:	68 8a 95 10 80       	push   $0x8010958a
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
80101a3e:	68 95 95 10 80       	push   $0x80109595
80101a43:	e8 7e e9 ff ff       	call   801003c6 <cprintf>
80101a48:	83 c4 10             	add    $0x10,%esp
    initlock(&icache.lock, "icache");
80101a4b:	83 ec 08             	sub    $0x8,%esp
80101a4e:	68 b0 95 10 80       	push   $0x801095b0
80101a53:	68 60 24 11 80       	push   $0x80112460
80101a58:	e8 18 41 00 00       	call   80105b75 <initlock>
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
80101a90:	68 b7 95 10 80       	push   $0x801095b7
80101a95:	e8 2c e9 ff ff       	call   801003c6 <cprintf>
80101a9a:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a9d:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101aa2:	83 f8 ff             	cmp    $0xffffffff,%eax
80101aa5:	75 0d                	jne    80101ab4 <iinit+0x82>
        panic("no bootable partition");
80101aa7:	83 ec 0c             	sub    $0xc,%esp
80101aaa:	68 c9 95 10 80       	push   $0x801095c9
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
80101b53:	68 e0 95 10 80       	push   $0x801095e0
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
80101c1b:	e8 da 41 00 00       	call   80105dfa <memset>
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
80101c37:	e8 2a 26 00 00       	call   80104266 <log_write>
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
80101c88:	68 3d 96 10 80       	push   $0x8010963d
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
80101d71:	e8 43 41 00 00       	call   80105eb9 <memmove>
80101d76:	83 c4 10             	add    $0x10,%esp
    log_write(bp, ip->part->number);
80101d79:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7c:	8b 40 50             	mov    0x50(%eax),%eax
80101d7f:	8b 40 14             	mov    0x14(%eax),%eax
80101d82:	83 ec 08             	sub    $0x8,%esp
80101d85:	50                   	push   %eax
80101d86:	ff 75 f4             	pushl  -0xc(%ebp)
80101d89:	e8 d8 24 00 00       	call   80104266 <log_write>
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
80101db0:	e8 e2 3d 00 00       	call   80105b97 <acquire>
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
80101e16:	e8 e3 3d 00 00       	call   80105bfe <release>
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
80101e56:	68 4f 96 10 80       	push   $0x8010964f
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
80101eab:	e8 4e 3d 00 00       	call   80105bfe <release>
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
80101ec6:	e8 cc 3c 00 00       	call   80105b97 <acquire>
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
80101ee5:	e8 14 3d 00 00       	call   80105bfe <release>
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
80101f0b:	68 5f 96 10 80       	push   $0x8010965f
80101f10:	e8 51 e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101f15:	83 ec 0c             	sub    $0xc,%esp
80101f18:	68 60 24 11 80       	push   $0x80112460
80101f1d:	e8 75 3c 00 00       	call   80105b97 <acquire>
80101f22:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f25:	eb 13                	jmp    80101f3a <ilock+0x48>
        sleep(ip, &icache.lock);
80101f27:	83 ec 08             	sub    $0x8,%esp
80101f2a:	68 60 24 11 80       	push   $0x80112460
80101f2f:	ff 75 08             	pushl  0x8(%ebp)
80101f32:	e8 67 39 00 00       	call   8010589e <sleep>
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
80101f60:	e8 99 3c 00 00       	call   80105bfe <release>
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
80102050:	e8 64 3e 00 00       	call   80105eb9 <memmove>
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
80102086:	68 65 96 10 80       	push   $0x80109665
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
801020b9:	68 74 96 10 80       	push   $0x80109674
801020be:	e8 a3 e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020c3:	83 ec 0c             	sub    $0xc,%esp
801020c6:	68 60 24 11 80       	push   $0x80112460
801020cb:	e8 c7 3a 00 00       	call   80105b97 <acquire>
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
801020ea:	e8 9a 38 00 00       	call   80105989 <wakeup>
801020ef:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020f2:	83 ec 0c             	sub    $0xc,%esp
801020f5:	68 60 24 11 80       	push   $0x80112460
801020fa:	e8 ff 3a 00 00       	call   80105bfe <release>
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
80102113:	e8 7f 3a 00 00       	call   80105b97 <acquire>
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
8010215b:	68 7c 96 10 80       	push   $0x8010967c
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
8010217e:	e8 7b 3a 00 00       	call   80105bfe <release>
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
801021b3:	e8 df 39 00 00       	call   80105b97 <acquire>
801021b8:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801021bb:	8b 45 08             	mov    0x8(%ebp),%eax
801021be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021c5:	83 ec 0c             	sub    $0xc,%esp
801021c8:	ff 75 08             	pushl  0x8(%ebp)
801021cb:	e8 b9 37 00 00       	call   80105989 <wakeup>
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
801021ea:	e8 0f 3a 00 00       	call   80105bfe <release>
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
80102380:	e8 e1 1e 00 00       	call   80104266 <log_write>
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
8010239e:	68 86 96 10 80       	push   $0x80109686
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
801026e7:	e8 cd 37 00 00       	call   80105eb9 <memmove>
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
80102882:	e8 32 36 00 00       	call   80105eb9 <memmove>
80102887:	83 c4 10             	add    $0x10,%esp
        log_write(bp, ip->part->number);
8010288a:	8b 45 08             	mov    0x8(%ebp),%eax
8010288d:	8b 40 50             	mov    0x50(%eax),%eax
80102890:	8b 40 14             	mov    0x14(%eax),%eax
80102893:	83 ec 08             	sub    $0x8,%esp
80102896:	50                   	push   %eax
80102897:	ff 75 ec             	pushl  -0x14(%ebp)
8010289a:	e8 c7 19 00 00       	call   80104266 <log_write>
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
8010290c:	e8 3e 36 00 00       	call   80105f4f <strncmp>
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
8010292c:	68 99 96 10 80       	push   $0x80109699
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
8010295e:	68 ab 96 10 80       	push   $0x801096ab
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
80102a3d:	68 ab 96 10 80       	push   $0x801096ab
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
80102a78:	e8 28 35 00 00       	call   80105fa5 <strncpy>
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
80102aa4:	68 b8 96 10 80       	push   $0x801096b8
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
80102b1a:	e8 9a 33 00 00       	call   80105eb9 <memmove>
80102b1f:	83 c4 10             	add    $0x10,%esp
80102b22:	eb 26                	jmp    80102b4a <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b27:	83 ec 04             	sub    $0x4,%esp
80102b2a:	50                   	push   %eax
80102b2b:	ff 75 f4             	pushl  -0xc(%ebp)
80102b2e:	ff 75 0c             	pushl  0xc(%ebp)
80102b31:	e8 83 33 00 00       	call   80105eb9 <memmove>
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
80102e31:	68 ca 96 10 80       	push   $0x801096ca
80102e36:	68 00 c6 10 80       	push   $0x8010c600
80102e3b:	e8 35 2d 00 00       	call   80105b75 <initlock>
80102e40:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e43:	83 ec 0c             	sub    $0xc,%esp
80102e46:	6a 0e                	push   $0xe
80102e48:	e8 26 1c 00 00       	call   80104a73 <picenable>
80102e4d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e50:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102e55:	83 e8 01             	sub    $0x1,%eax
80102e58:	83 ec 08             	sub    $0x8,%esp
80102e5b:	50                   	push   %eax
80102e5c:	6a 0e                	push   $0xe
80102e5e:	e8 93 04 00 00       	call   801032f6 <ioapicenable>
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
80102ee5:	68 ce 96 10 80       	push   $0x801096ce
80102eea:	e8 77 d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE+mbrI.partitions[0].offset){
80102eef:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef2:	8b 40 08             	mov    0x8(%eax),%eax
80102ef5:	8b 15 c6 19 11 80    	mov    0x801119c6,%edx
80102efb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
80102f01:	39 d0                	cmp    %edx,%eax
80102f03:	72 24                	jb     80102f29 <idestart+0x53>
      cprintf("block %d \n",b->blockno);
80102f05:	8b 45 08             	mov    0x8(%ebp),%eax
80102f08:	8b 40 08             	mov    0x8(%eax),%eax
80102f0b:	83 ec 08             	sub    $0x8,%esp
80102f0e:	50                   	push   %eax
80102f0f:	68 d7 96 10 80       	push   $0x801096d7
80102f14:	e8 ad d4 ff ff       	call   801003c6 <cprintf>
80102f19:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102f1c:	83 ec 0c             	sub    $0xc,%esp
80102f1f:	68 e2 96 10 80       	push   $0x801096e2
80102f24:	e8 3d d6 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102f29:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102f30:	8b 45 08             	mov    0x8(%ebp),%eax
80102f33:	8b 50 08             	mov    0x8(%eax),%edx
80102f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f39:	0f af c2             	imul   %edx,%eax
80102f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f3f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f43:	7e 0d                	jle    80102f52 <idestart+0x7c>
80102f45:	83 ec 0c             	sub    $0xc,%esp
80102f48:	68 ce 96 10 80       	push   $0x801096ce
80102f4d:	e8 14 d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102f52:	83 ec 0c             	sub    $0xc,%esp
80102f55:	6a 00                	push   $0x0
80102f57:	e8 87 fe ff ff       	call   80102de3 <idewait>
80102f5c:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f5f:	83 ec 08             	sub    $0x8,%esp
80102f62:	6a 00                	push   $0x0
80102f64:	68 f6 03 00 00       	push   $0x3f6
80102f69:	e8 30 fe ff ff       	call   80102d9e <outb>
80102f6e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f74:	0f b6 c0             	movzbl %al,%eax
80102f77:	83 ec 08             	sub    $0x8,%esp
80102f7a:	50                   	push   %eax
80102f7b:	68 f2 01 00 00       	push   $0x1f2
80102f80:	e8 19 fe ff ff       	call   80102d9e <outb>
80102f85:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f8b:	0f b6 c0             	movzbl %al,%eax
80102f8e:	83 ec 08             	sub    $0x8,%esp
80102f91:	50                   	push   %eax
80102f92:	68 f3 01 00 00       	push   $0x1f3
80102f97:	e8 02 fe ff ff       	call   80102d9e <outb>
80102f9c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa2:	c1 f8 08             	sar    $0x8,%eax
80102fa5:	0f b6 c0             	movzbl %al,%eax
80102fa8:	83 ec 08             	sub    $0x8,%esp
80102fab:	50                   	push   %eax
80102fac:	68 f4 01 00 00       	push   $0x1f4
80102fb1:	e8 e8 fd ff ff       	call   80102d9e <outb>
80102fb6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	c1 f8 10             	sar    $0x10,%eax
80102fbf:	0f b6 c0             	movzbl %al,%eax
80102fc2:	83 ec 08             	sub    $0x8,%esp
80102fc5:	50                   	push   %eax
80102fc6:	68 f5 01 00 00       	push   $0x1f5
80102fcb:	e8 ce fd ff ff       	call   80102d9e <outb>
80102fd0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fd6:	8b 40 04             	mov    0x4(%eax),%eax
80102fd9:	83 e0 01             	and    $0x1,%eax
80102fdc:	c1 e0 04             	shl    $0x4,%eax
80102fdf:	89 c2                	mov    %eax,%edx
80102fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fe4:	c1 f8 18             	sar    $0x18,%eax
80102fe7:	83 e0 0f             	and    $0xf,%eax
80102fea:	09 d0                	or     %edx,%eax
80102fec:	83 c8 e0             	or     $0xffffffe0,%eax
80102fef:	0f b6 c0             	movzbl %al,%eax
80102ff2:	83 ec 08             	sub    $0x8,%esp
80102ff5:	50                   	push   %eax
80102ff6:	68 f6 01 00 00       	push   $0x1f6
80102ffb:	e8 9e fd ff ff       	call   80102d9e <outb>
80103000:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80103003:	8b 45 08             	mov    0x8(%ebp),%eax
80103006:	8b 00                	mov    (%eax),%eax
80103008:	83 e0 04             	and    $0x4,%eax
8010300b:	85 c0                	test   %eax,%eax
8010300d:	74 30                	je     8010303f <idestart+0x169>
    outb(0x1f7, IDE_CMD_WRITE);
8010300f:	83 ec 08             	sub    $0x8,%esp
80103012:	6a 30                	push   $0x30
80103014:	68 f7 01 00 00       	push   $0x1f7
80103019:	e8 80 fd ff ff       	call   80102d9e <outb>
8010301e:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80103021:	8b 45 08             	mov    0x8(%ebp),%eax
80103024:	83 c0 18             	add    $0x18,%eax
80103027:	83 ec 04             	sub    $0x4,%esp
8010302a:	68 80 00 00 00       	push   $0x80
8010302f:	50                   	push   %eax
80103030:	68 f0 01 00 00       	push   $0x1f0
80103035:	e8 83 fd ff ff       	call   80102dbd <outsl>
8010303a:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010303d:	eb 12                	jmp    80103051 <idestart+0x17b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010303f:	83 ec 08             	sub    $0x8,%esp
80103042:	6a 20                	push   $0x20
80103044:	68 f7 01 00 00       	push   $0x1f7
80103049:	e8 50 fd ff ff       	call   80102d9e <outb>
8010304e:	83 c4 10             	add    $0x10,%esp
  }
}
80103051:	90                   	nop
80103052:	c9                   	leave  
80103053:	c3                   	ret    

80103054 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80103054:	55                   	push   %ebp
80103055:	89 e5                	mov    %esp,%ebp
80103057:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010305a:	83 ec 0c             	sub    $0xc,%esp
8010305d:	68 00 c6 10 80       	push   $0x8010c600
80103062:	e8 30 2b 00 00       	call   80105b97 <acquire>
80103067:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010306a:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010306f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103072:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103076:	75 15                	jne    8010308d <ideintr+0x39>
    release(&idelock);
80103078:	83 ec 0c             	sub    $0xc,%esp
8010307b:	68 00 c6 10 80       	push   $0x8010c600
80103080:	e8 79 2b 00 00       	call   80105bfe <release>
80103085:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80103088:	e9 9a 00 00 00       	jmp    80103127 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010308d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103090:	8b 40 14             	mov    0x14(%eax),%eax
80103093:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010309b:	8b 00                	mov    (%eax),%eax
8010309d:	83 e0 04             	and    $0x4,%eax
801030a0:	85 c0                	test   %eax,%eax
801030a2:	75 2d                	jne    801030d1 <ideintr+0x7d>
801030a4:	83 ec 0c             	sub    $0xc,%esp
801030a7:	6a 01                	push   $0x1
801030a9:	e8 35 fd ff ff       	call   80102de3 <idewait>
801030ae:	83 c4 10             	add    $0x10,%esp
801030b1:	85 c0                	test   %eax,%eax
801030b3:	78 1c                	js     801030d1 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801030b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b8:	83 c0 18             	add    $0x18,%eax
801030bb:	83 ec 04             	sub    $0x4,%esp
801030be:	68 80 00 00 00       	push   $0x80
801030c3:	50                   	push   %eax
801030c4:	68 f0 01 00 00       	push   $0x1f0
801030c9:	e8 aa fc ff ff       	call   80102d78 <insl>
801030ce:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801030d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030d4:	8b 00                	mov    (%eax),%eax
801030d6:	83 c8 02             	or     $0x2,%eax
801030d9:	89 c2                	mov    %eax,%edx
801030db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030de:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030e3:	8b 00                	mov    (%eax),%eax
801030e5:	83 e0 fb             	and    $0xfffffffb,%eax
801030e8:	89 c2                	mov    %eax,%edx
801030ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030ed:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801030ef:	83 ec 0c             	sub    $0xc,%esp
801030f2:	ff 75 f4             	pushl  -0xc(%ebp)
801030f5:	e8 8f 28 00 00       	call   80105989 <wakeup>
801030fa:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
801030fd:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103102:	85 c0                	test   %eax,%eax
80103104:	74 11                	je     80103117 <ideintr+0xc3>
            //cprintf("ideintr \n");
                idestart(idequeue);
80103106:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010310b:	83 ec 0c             	sub    $0xc,%esp
8010310e:	50                   	push   %eax
8010310f:	e8 c2 fd ff ff       	call   80102ed6 <idestart>
80103114:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
80103117:	83 ec 0c             	sub    $0xc,%esp
8010311a:	68 00 c6 10 80       	push   $0x8010c600
8010311f:	e8 da 2a 00 00       	call   80105bfe <release>
80103124:	83 c4 10             	add    $0x10,%esp
}
80103127:	c9                   	leave  
80103128:	c3                   	ret    

80103129 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103129:	55                   	push   %ebp
8010312a:	89 e5                	mov    %esp,%ebp
8010312c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010312f:	8b 45 08             	mov    0x8(%ebp),%eax
80103132:	8b 00                	mov    (%eax),%eax
80103134:	83 e0 01             	and    $0x1,%eax
80103137:	85 c0                	test   %eax,%eax
80103139:	75 0d                	jne    80103148 <iderw+0x1f>
    panic("iderw: buf not busy");
8010313b:	83 ec 0c             	sub    $0xc,%esp
8010313e:	68 f4 96 10 80       	push   $0x801096f4
80103143:	e8 1e d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103148:	8b 45 08             	mov    0x8(%ebp),%eax
8010314b:	8b 00                	mov    (%eax),%eax
8010314d:	83 e0 06             	and    $0x6,%eax
80103150:	83 f8 02             	cmp    $0x2,%eax
80103153:	75 0d                	jne    80103162 <iderw+0x39>
    panic("iderw: nothing to do");
80103155:	83 ec 0c             	sub    $0xc,%esp
80103158:	68 08 97 10 80       	push   $0x80109708
8010315d:	e8 04 d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80103162:	8b 45 08             	mov    0x8(%ebp),%eax
80103165:	8b 40 04             	mov    0x4(%eax),%eax
80103168:	85 c0                	test   %eax,%eax
8010316a:	74 16                	je     80103182 <iderw+0x59>
8010316c:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80103171:	85 c0                	test   %eax,%eax
80103173:	75 0d                	jne    80103182 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80103175:	83 ec 0c             	sub    $0xc,%esp
80103178:	68 1d 97 10 80       	push   $0x8010971d
8010317d:	e8 e4 d3 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80103182:	83 ec 0c             	sub    $0xc,%esp
80103185:	68 00 c6 10 80       	push   $0x8010c600
8010318a:	e8 08 2a 00 00       	call   80105b97 <acquire>
8010318f:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80103192:	8b 45 08             	mov    0x8(%ebp),%eax
80103195:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010319c:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
801031a3:	eb 0b                	jmp    801031b0 <iderw+0x87>
801031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a8:	8b 00                	mov    (%eax),%eax
801031aa:	83 c0 14             	add    $0x14,%eax
801031ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801031b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b3:	8b 00                	mov    (%eax),%eax
801031b5:	85 c0                	test   %eax,%eax
801031b7:	75 ec                	jne    801031a5 <iderw+0x7c>
    ;
  *pp = b;
801031b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031bc:	8b 55 08             	mov    0x8(%ebp),%edx
801031bf:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
801031c1:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801031c6:	3b 45 08             	cmp    0x8(%ebp),%eax
801031c9:	75 23                	jne    801031ee <iderw+0xc5>
     // cprintf("iderw \n");
          idestart(b);
801031cb:	83 ec 0c             	sub    $0xc,%esp
801031ce:	ff 75 08             	pushl  0x8(%ebp)
801031d1:	e8 00 fd ff ff       	call   80102ed6 <idestart>
801031d6:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031d9:	eb 13                	jmp    801031ee <iderw+0xc5>
    sleep(b, &idelock);
801031db:	83 ec 08             	sub    $0x8,%esp
801031de:	68 00 c6 10 80       	push   $0x8010c600
801031e3:	ff 75 08             	pushl  0x8(%ebp)
801031e6:	e8 b3 26 00 00       	call   8010589e <sleep>
801031eb:	83 c4 10             	add    $0x10,%esp
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031ee:	8b 45 08             	mov    0x8(%ebp),%eax
801031f1:	8b 00                	mov    (%eax),%eax
801031f3:	83 e0 06             	and    $0x6,%eax
801031f6:	83 f8 02             	cmp    $0x2,%eax
801031f9:	75 e0                	jne    801031db <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801031fb:	83 ec 0c             	sub    $0xc,%esp
801031fe:	68 00 c6 10 80       	push   $0x8010c600
80103203:	e8 f6 29 00 00       	call   80105bfe <release>
80103208:	83 c4 10             	add    $0x10,%esp
}
8010320b:	90                   	nop
8010320c:	c9                   	leave  
8010320d:	c3                   	ret    

8010320e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010320e:	55                   	push   %ebp
8010320f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103211:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103216:	8b 55 08             	mov    0x8(%ebp),%edx
80103219:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010321b:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103220:	8b 40 10             	mov    0x10(%eax),%eax
}
80103223:	5d                   	pop    %ebp
80103224:	c3                   	ret    

80103225 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80103225:	55                   	push   %ebp
80103226:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103228:	a1 fc 34 11 80       	mov    0x801134fc,%eax
8010322d:	8b 55 08             	mov    0x8(%ebp),%edx
80103230:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80103232:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103237:	8b 55 0c             	mov    0xc(%ebp),%edx
8010323a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010323d:	90                   	nop
8010323e:	5d                   	pop    %ebp
8010323f:	c3                   	ret    

80103240 <ioapicinit>:

void
ioapicinit(void)
{
80103240:	55                   	push   %ebp
80103241:	89 e5                	mov    %esp,%ebp
80103243:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80103246:	a1 64 38 11 80       	mov    0x80113864,%eax
8010324b:	85 c0                	test   %eax,%eax
8010324d:	0f 84 a0 00 00 00    	je     801032f3 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80103253:	c7 05 fc 34 11 80 00 	movl   $0xfec00000,0x801134fc
8010325a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010325d:	6a 01                	push   $0x1
8010325f:	e8 aa ff ff ff       	call   8010320e <ioapicread>
80103264:	83 c4 04             	add    $0x4,%esp
80103267:	c1 e8 10             	shr    $0x10,%eax
8010326a:	25 ff 00 00 00       	and    $0xff,%eax
8010326f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80103272:	6a 00                	push   $0x0
80103274:	e8 95 ff ff ff       	call   8010320e <ioapicread>
80103279:	83 c4 04             	add    $0x4,%esp
8010327c:	c1 e8 18             	shr    $0x18,%eax
8010327f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80103282:	0f b6 05 60 38 11 80 	movzbl 0x80113860,%eax
80103289:	0f b6 c0             	movzbl %al,%eax
8010328c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010328f:	74 10                	je     801032a1 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80103291:	83 ec 0c             	sub    $0xc,%esp
80103294:	68 3c 97 10 80       	push   $0x8010973c
80103299:	e8 28 d1 ff ff       	call   801003c6 <cprintf>
8010329e:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032a8:	eb 3f                	jmp    801032e9 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801032aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ad:	83 c0 20             	add    $0x20,%eax
801032b0:	0d 00 00 01 00       	or     $0x10000,%eax
801032b5:	89 c2                	mov    %eax,%edx
801032b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ba:	83 c0 08             	add    $0x8,%eax
801032bd:	01 c0                	add    %eax,%eax
801032bf:	83 ec 08             	sub    $0x8,%esp
801032c2:	52                   	push   %edx
801032c3:	50                   	push   %eax
801032c4:	e8 5c ff ff ff       	call   80103225 <ioapicwrite>
801032c9:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801032cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032cf:	83 c0 08             	add    $0x8,%eax
801032d2:	01 c0                	add    %eax,%eax
801032d4:	83 c0 01             	add    $0x1,%eax
801032d7:	83 ec 08             	sub    $0x8,%esp
801032da:	6a 00                	push   $0x0
801032dc:	50                   	push   %eax
801032dd:	e8 43 ff ff ff       	call   80103225 <ioapicwrite>
801032e2:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801032ef:	7e b9                	jle    801032aa <ioapicinit+0x6a>
801032f1:	eb 01                	jmp    801032f4 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801032f3:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801032f4:	c9                   	leave  
801032f5:	c3                   	ret    

801032f6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801032f6:	55                   	push   %ebp
801032f7:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801032f9:	a1 64 38 11 80       	mov    0x80113864,%eax
801032fe:	85 c0                	test   %eax,%eax
80103300:	74 39                	je     8010333b <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80103302:	8b 45 08             	mov    0x8(%ebp),%eax
80103305:	83 c0 20             	add    $0x20,%eax
80103308:	89 c2                	mov    %eax,%edx
8010330a:	8b 45 08             	mov    0x8(%ebp),%eax
8010330d:	83 c0 08             	add    $0x8,%eax
80103310:	01 c0                	add    %eax,%eax
80103312:	52                   	push   %edx
80103313:	50                   	push   %eax
80103314:	e8 0c ff ff ff       	call   80103225 <ioapicwrite>
80103319:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010331c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010331f:	c1 e0 18             	shl    $0x18,%eax
80103322:	89 c2                	mov    %eax,%edx
80103324:	8b 45 08             	mov    0x8(%ebp),%eax
80103327:	83 c0 08             	add    $0x8,%eax
8010332a:	01 c0                	add    %eax,%eax
8010332c:	83 c0 01             	add    $0x1,%eax
8010332f:	52                   	push   %edx
80103330:	50                   	push   %eax
80103331:	e8 ef fe ff ff       	call   80103225 <ioapicwrite>
80103336:	83 c4 08             	add    $0x8,%esp
80103339:	eb 01                	jmp    8010333c <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
8010333b:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
8010333c:	c9                   	leave  
8010333d:	c3                   	ret    

8010333e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010333e:	55                   	push   %ebp
8010333f:	89 e5                	mov    %esp,%ebp
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	05 00 00 00 80       	add    $0x80000000,%eax
80103349:	5d                   	pop    %ebp
8010334a:	c3                   	ret    

8010334b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80103351:	83 ec 08             	sub    $0x8,%esp
80103354:	68 6e 97 10 80       	push   $0x8010976e
80103359:	68 00 35 11 80       	push   $0x80113500
8010335e:	e8 12 28 00 00       	call   80105b75 <initlock>
80103363:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80103366:	c7 05 34 35 11 80 00 	movl   $0x0,0x80113534
8010336d:	00 00 00 
  freerange(vstart, vend);
80103370:	83 ec 08             	sub    $0x8,%esp
80103373:	ff 75 0c             	pushl  0xc(%ebp)
80103376:	ff 75 08             	pushl  0x8(%ebp)
80103379:	e8 2a 00 00 00       	call   801033a8 <freerange>
8010337e:	83 c4 10             	add    $0x10,%esp
}
80103381:	90                   	nop
80103382:	c9                   	leave  
80103383:	c3                   	ret    

80103384 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80103384:	55                   	push   %ebp
80103385:	89 e5                	mov    %esp,%ebp
80103387:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010338a:	83 ec 08             	sub    $0x8,%esp
8010338d:	ff 75 0c             	pushl  0xc(%ebp)
80103390:	ff 75 08             	pushl  0x8(%ebp)
80103393:	e8 10 00 00 00       	call   801033a8 <freerange>
80103398:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
8010339b:	c7 05 34 35 11 80 01 	movl   $0x1,0x80113534
801033a2:	00 00 00 
}
801033a5:	90                   	nop
801033a6:	c9                   	leave  
801033a7:	c3                   	ret    

801033a8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801033a8:	55                   	push   %ebp
801033a9:	89 e5                	mov    %esp,%ebp
801033ab:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801033ae:	8b 45 08             	mov    0x8(%ebp),%eax
801033b1:	05 ff 0f 00 00       	add    $0xfff,%eax
801033b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801033bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033be:	eb 15                	jmp    801033d5 <freerange+0x2d>
    kfree(p);
801033c0:	83 ec 0c             	sub    $0xc,%esp
801033c3:	ff 75 f4             	pushl  -0xc(%ebp)
801033c6:	e8 1a 00 00 00       	call   801033e5 <kfree>
801033cb:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801033d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d8:	05 00 10 00 00       	add    $0x1000,%eax
801033dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801033e0:	76 de                	jbe    801033c0 <freerange+0x18>
    kfree(p);
}
801033e2:	90                   	nop
801033e3:	c9                   	leave  
801033e4:	c3                   	ret    

801033e5 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801033e5:	55                   	push   %ebp
801033e6:	89 e5                	mov    %esp,%ebp
801033e8:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801033eb:	8b 45 08             	mov    0x8(%ebp),%eax
801033ee:	25 ff 0f 00 00       	and    $0xfff,%eax
801033f3:	85 c0                	test   %eax,%eax
801033f5:	75 1b                	jne    80103412 <kfree+0x2d>
801033f7:	81 7d 08 5c 66 11 80 	cmpl   $0x8011665c,0x8(%ebp)
801033fe:	72 12                	jb     80103412 <kfree+0x2d>
80103400:	ff 75 08             	pushl  0x8(%ebp)
80103403:	e8 36 ff ff ff       	call   8010333e <v2p>
80103408:	83 c4 04             	add    $0x4,%esp
8010340b:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103410:	76 0d                	jbe    8010341f <kfree+0x3a>
    panic("kfree");
80103412:	83 ec 0c             	sub    $0xc,%esp
80103415:	68 73 97 10 80       	push   $0x80109773
8010341a:	e8 47 d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010341f:	83 ec 04             	sub    $0x4,%esp
80103422:	68 00 10 00 00       	push   $0x1000
80103427:	6a 01                	push   $0x1
80103429:	ff 75 08             	pushl  0x8(%ebp)
8010342c:	e8 c9 29 00 00       	call   80105dfa <memset>
80103431:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80103434:	a1 34 35 11 80       	mov    0x80113534,%eax
80103439:	85 c0                	test   %eax,%eax
8010343b:	74 10                	je     8010344d <kfree+0x68>
    acquire(&kmem.lock);
8010343d:	83 ec 0c             	sub    $0xc,%esp
80103440:	68 00 35 11 80       	push   $0x80113500
80103445:	e8 4d 27 00 00       	call   80105b97 <acquire>
8010344a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010344d:	8b 45 08             	mov    0x8(%ebp),%eax
80103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103453:	8b 15 38 35 11 80    	mov    0x80113538,%edx
80103459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010345c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103461:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
80103466:	a1 34 35 11 80       	mov    0x80113534,%eax
8010346b:	85 c0                	test   %eax,%eax
8010346d:	74 10                	je     8010347f <kfree+0x9a>
    release(&kmem.lock);
8010346f:	83 ec 0c             	sub    $0xc,%esp
80103472:	68 00 35 11 80       	push   $0x80113500
80103477:	e8 82 27 00 00       	call   80105bfe <release>
8010347c:	83 c4 10             	add    $0x10,%esp
}
8010347f:	90                   	nop
80103480:	c9                   	leave  
80103481:	c3                   	ret    

80103482 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103482:	55                   	push   %ebp
80103483:	89 e5                	mov    %esp,%ebp
80103485:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103488:	a1 34 35 11 80       	mov    0x80113534,%eax
8010348d:	85 c0                	test   %eax,%eax
8010348f:	74 10                	je     801034a1 <kalloc+0x1f>
    acquire(&kmem.lock);
80103491:	83 ec 0c             	sub    $0xc,%esp
80103494:	68 00 35 11 80       	push   $0x80113500
80103499:	e8 f9 26 00 00       	call   80105b97 <acquire>
8010349e:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801034a1:	a1 38 35 11 80       	mov    0x80113538,%eax
801034a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801034a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801034ad:	74 0a                	je     801034b9 <kalloc+0x37>
    kmem.freelist = r->next;
801034af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b2:	8b 00                	mov    (%eax),%eax
801034b4:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
801034b9:	a1 34 35 11 80       	mov    0x80113534,%eax
801034be:	85 c0                	test   %eax,%eax
801034c0:	74 10                	je     801034d2 <kalloc+0x50>
    release(&kmem.lock);
801034c2:	83 ec 0c             	sub    $0xc,%esp
801034c5:	68 00 35 11 80       	push   $0x80113500
801034ca:	e8 2f 27 00 00       	call   80105bfe <release>
801034cf:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801034d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801034d5:	c9                   	leave  
801034d6:	c3                   	ret    

801034d7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034d7:	55                   	push   %ebp
801034d8:	89 e5                	mov    %esp,%ebp
801034da:	83 ec 14             	sub    $0x14,%esp
801034dd:	8b 45 08             	mov    0x8(%ebp),%eax
801034e0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034e4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034e8:	89 c2                	mov    %eax,%edx
801034ea:	ec                   	in     (%dx),%al
801034eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034ee:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034f2:	c9                   	leave  
801034f3:	c3                   	ret    

801034f4 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801034f4:	55                   	push   %ebp
801034f5:	89 e5                	mov    %esp,%ebp
801034f7:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801034fa:	6a 64                	push   $0x64
801034fc:	e8 d6 ff ff ff       	call   801034d7 <inb>
80103501:	83 c4 04             	add    $0x4,%esp
80103504:	0f b6 c0             	movzbl %al,%eax
80103507:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010350a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010350d:	83 e0 01             	and    $0x1,%eax
80103510:	85 c0                	test   %eax,%eax
80103512:	75 0a                	jne    8010351e <kbdgetc+0x2a>
    return -1;
80103514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103519:	e9 23 01 00 00       	jmp    80103641 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010351e:	6a 60                	push   $0x60
80103520:	e8 b2 ff ff ff       	call   801034d7 <inb>
80103525:	83 c4 04             	add    $0x4,%esp
80103528:	0f b6 c0             	movzbl %al,%eax
8010352b:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010352e:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103535:	75 17                	jne    8010354e <kbdgetc+0x5a>
    shift |= E0ESC;
80103537:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010353c:	83 c8 40             	or     $0x40,%eax
8010353f:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103544:	b8 00 00 00 00       	mov    $0x0,%eax
80103549:	e9 f3 00 00 00       	jmp    80103641 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010354e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103551:	25 80 00 00 00       	and    $0x80,%eax
80103556:	85 c0                	test   %eax,%eax
80103558:	74 45                	je     8010359f <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010355a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010355f:	83 e0 40             	and    $0x40,%eax
80103562:	85 c0                	test   %eax,%eax
80103564:	75 08                	jne    8010356e <kbdgetc+0x7a>
80103566:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103569:	83 e0 7f             	and    $0x7f,%eax
8010356c:	eb 03                	jmp    80103571 <kbdgetc+0x7d>
8010356e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103571:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103574:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103577:	05 40 a0 10 80       	add    $0x8010a040,%eax
8010357c:	0f b6 00             	movzbl (%eax),%eax
8010357f:	83 c8 40             	or     $0x40,%eax
80103582:	0f b6 c0             	movzbl %al,%eax
80103585:	f7 d0                	not    %eax
80103587:	89 c2                	mov    %eax,%edx
80103589:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010358e:	21 d0                	and    %edx,%eax
80103590:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103595:	b8 00 00 00 00       	mov    $0x0,%eax
8010359a:	e9 a2 00 00 00       	jmp    80103641 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010359f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035a4:	83 e0 40             	and    $0x40,%eax
801035a7:	85 c0                	test   %eax,%eax
801035a9:	74 14                	je     801035bf <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801035ab:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801035b2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035b7:	83 e0 bf             	and    $0xffffffbf,%eax
801035ba:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
801035bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035c2:	05 40 a0 10 80       	add    $0x8010a040,%eax
801035c7:	0f b6 00             	movzbl (%eax),%eax
801035ca:	0f b6 d0             	movzbl %al,%edx
801035cd:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035d2:	09 d0                	or     %edx,%eax
801035d4:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801035d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035dc:	05 40 a1 10 80       	add    $0x8010a140,%eax
801035e1:	0f b6 00             	movzbl (%eax),%eax
801035e4:	0f b6 d0             	movzbl %al,%edx
801035e7:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035ec:	31 d0                	xor    %edx,%eax
801035ee:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801035f3:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035f8:	83 e0 03             	and    $0x3,%eax
801035fb:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
80103602:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103605:	01 d0                	add    %edx,%eax
80103607:	0f b6 00             	movzbl (%eax),%eax
8010360a:	0f b6 c0             	movzbl %al,%eax
8010360d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103610:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103615:	83 e0 08             	and    $0x8,%eax
80103618:	85 c0                	test   %eax,%eax
8010361a:	74 22                	je     8010363e <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010361c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103620:	76 0c                	jbe    8010362e <kbdgetc+0x13a>
80103622:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103626:	77 06                	ja     8010362e <kbdgetc+0x13a>
      c += 'A' - 'a';
80103628:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010362c:	eb 10                	jmp    8010363e <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010362e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103632:	76 0a                	jbe    8010363e <kbdgetc+0x14a>
80103634:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103638:	77 04                	ja     8010363e <kbdgetc+0x14a>
      c += 'a' - 'A';
8010363a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010363e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103641:	c9                   	leave  
80103642:	c3                   	ret    

80103643 <kbdintr>:

void
kbdintr(void)
{
80103643:	55                   	push   %ebp
80103644:	89 e5                	mov    %esp,%ebp
80103646:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103649:	83 ec 0c             	sub    $0xc,%esp
8010364c:	68 f4 34 10 80       	push   $0x801034f4
80103651:	e8 a3 d1 ff ff       	call   801007f9 <consoleintr>
80103656:	83 c4 10             	add    $0x10,%esp
}
80103659:	90                   	nop
8010365a:	c9                   	leave  
8010365b:	c3                   	ret    

8010365c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010365c:	55                   	push   %ebp
8010365d:	89 e5                	mov    %esp,%ebp
8010365f:	83 ec 14             	sub    $0x14,%esp
80103662:	8b 45 08             	mov    0x8(%ebp),%eax
80103665:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103669:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010366d:	89 c2                	mov    %eax,%edx
8010366f:	ec                   	in     (%dx),%al
80103670:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103673:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103677:	c9                   	leave  
80103678:	c3                   	ret    

80103679 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103679:	55                   	push   %ebp
8010367a:	89 e5                	mov    %esp,%ebp
8010367c:	83 ec 08             	sub    $0x8,%esp
8010367f:	8b 55 08             	mov    0x8(%ebp),%edx
80103682:	8b 45 0c             	mov    0xc(%ebp),%eax
80103685:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103689:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010368c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103690:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103694:	ee                   	out    %al,(%dx)
}
80103695:	90                   	nop
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010369e:	9c                   	pushf  
8010369f:	58                   	pop    %eax
801036a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801036a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801036a6:	c9                   	leave  
801036a7:	c3                   	ret    

801036a8 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801036a8:	55                   	push   %ebp
801036a9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801036ab:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036b0:	8b 55 08             	mov    0x8(%ebp),%edx
801036b3:	c1 e2 02             	shl    $0x2,%edx
801036b6:	01 c2                	add    %eax,%edx
801036b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801036bb:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801036bd:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036c2:	83 c0 20             	add    $0x20,%eax
801036c5:	8b 00                	mov    (%eax),%eax
}
801036c7:	90                   	nop
801036c8:	5d                   	pop    %ebp
801036c9:	c3                   	ret    

801036ca <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801036ca:	55                   	push   %ebp
801036cb:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801036cd:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036d2:	85 c0                	test   %eax,%eax
801036d4:	0f 84 0b 01 00 00    	je     801037e5 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801036da:	68 3f 01 00 00       	push   $0x13f
801036df:	6a 3c                	push   $0x3c
801036e1:	e8 c2 ff ff ff       	call   801036a8 <lapicw>
801036e6:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801036e9:	6a 0b                	push   $0xb
801036eb:	68 f8 00 00 00       	push   $0xf8
801036f0:	e8 b3 ff ff ff       	call   801036a8 <lapicw>
801036f5:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801036f8:	68 20 00 02 00       	push   $0x20020
801036fd:	68 c8 00 00 00       	push   $0xc8
80103702:	e8 a1 ff ff ff       	call   801036a8 <lapicw>
80103707:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
8010370a:	68 80 96 98 00       	push   $0x989680
8010370f:	68 e0 00 00 00       	push   $0xe0
80103714:	e8 8f ff ff ff       	call   801036a8 <lapicw>
80103719:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010371c:	68 00 00 01 00       	push   $0x10000
80103721:	68 d4 00 00 00       	push   $0xd4
80103726:	e8 7d ff ff ff       	call   801036a8 <lapicw>
8010372b:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010372e:	68 00 00 01 00       	push   $0x10000
80103733:	68 d8 00 00 00       	push   $0xd8
80103738:	e8 6b ff ff ff       	call   801036a8 <lapicw>
8010373d:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103740:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103745:	83 c0 30             	add    $0x30,%eax
80103748:	8b 00                	mov    (%eax),%eax
8010374a:	c1 e8 10             	shr    $0x10,%eax
8010374d:	0f b6 c0             	movzbl %al,%eax
80103750:	83 f8 03             	cmp    $0x3,%eax
80103753:	76 12                	jbe    80103767 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103755:	68 00 00 01 00       	push   $0x10000
8010375a:	68 d0 00 00 00       	push   $0xd0
8010375f:	e8 44 ff ff ff       	call   801036a8 <lapicw>
80103764:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103767:	6a 33                	push   $0x33
80103769:	68 dc 00 00 00       	push   $0xdc
8010376e:	e8 35 ff ff ff       	call   801036a8 <lapicw>
80103773:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103776:	6a 00                	push   $0x0
80103778:	68 a0 00 00 00       	push   $0xa0
8010377d:	e8 26 ff ff ff       	call   801036a8 <lapicw>
80103782:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103785:	6a 00                	push   $0x0
80103787:	68 a0 00 00 00       	push   $0xa0
8010378c:	e8 17 ff ff ff       	call   801036a8 <lapicw>
80103791:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103794:	6a 00                	push   $0x0
80103796:	6a 2c                	push   $0x2c
80103798:	e8 0b ff ff ff       	call   801036a8 <lapicw>
8010379d:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801037a0:	6a 00                	push   $0x0
801037a2:	68 c4 00 00 00       	push   $0xc4
801037a7:	e8 fc fe ff ff       	call   801036a8 <lapicw>
801037ac:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801037af:	68 00 85 08 00       	push   $0x88500
801037b4:	68 c0 00 00 00       	push   $0xc0
801037b9:	e8 ea fe ff ff       	call   801036a8 <lapicw>
801037be:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801037c1:	90                   	nop
801037c2:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801037c7:	05 00 03 00 00       	add    $0x300,%eax
801037cc:	8b 00                	mov    (%eax),%eax
801037ce:	25 00 10 00 00       	and    $0x1000,%eax
801037d3:	85 c0                	test   %eax,%eax
801037d5:	75 eb                	jne    801037c2 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801037d7:	6a 00                	push   $0x0
801037d9:	6a 20                	push   $0x20
801037db:	e8 c8 fe ff ff       	call   801036a8 <lapicw>
801037e0:	83 c4 08             	add    $0x8,%esp
801037e3:	eb 01                	jmp    801037e6 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801037e5:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801037e6:	c9                   	leave  
801037e7:	c3                   	ret    

801037e8 <cpunum>:

int
cpunum(void)
{
801037e8:	55                   	push   %ebp
801037e9:	89 e5                	mov    %esp,%ebp
801037eb:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801037ee:	e8 a5 fe ff ff       	call   80103698 <readeflags>
801037f3:	25 00 02 00 00       	and    $0x200,%eax
801037f8:	85 c0                	test   %eax,%eax
801037fa:	74 26                	je     80103822 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801037fc:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80103801:	8d 50 01             	lea    0x1(%eax),%edx
80103804:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
8010380a:	85 c0                	test   %eax,%eax
8010380c:	75 14                	jne    80103822 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010380e:	8b 45 04             	mov    0x4(%ebp),%eax
80103811:	83 ec 08             	sub    $0x8,%esp
80103814:	50                   	push   %eax
80103815:	68 7c 97 10 80       	push   $0x8010977c
8010381a:	e8 a7 cb ff ff       	call   801003c6 <cprintf>
8010381f:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103822:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103827:	85 c0                	test   %eax,%eax
80103829:	74 0f                	je     8010383a <cpunum+0x52>
    return lapic[ID]>>24;
8010382b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103830:	83 c0 20             	add    $0x20,%eax
80103833:	8b 00                	mov    (%eax),%eax
80103835:	c1 e8 18             	shr    $0x18,%eax
80103838:	eb 05                	jmp    8010383f <cpunum+0x57>
  return 0;
8010383a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010383f:	c9                   	leave  
80103840:	c3                   	ret    

80103841 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103841:	55                   	push   %ebp
80103842:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103844:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103849:	85 c0                	test   %eax,%eax
8010384b:	74 0c                	je     80103859 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010384d:	6a 00                	push   $0x0
8010384f:	6a 2c                	push   $0x2c
80103851:	e8 52 fe ff ff       	call   801036a8 <lapicw>
80103856:	83 c4 08             	add    $0x8,%esp
}
80103859:	90                   	nop
8010385a:	c9                   	leave  
8010385b:	c3                   	ret    

8010385c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010385c:	55                   	push   %ebp
8010385d:	89 e5                	mov    %esp,%ebp
}
8010385f:	90                   	nop
80103860:	5d                   	pop    %ebp
80103861:	c3                   	ret    

80103862 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103862:	55                   	push   %ebp
80103863:	89 e5                	mov    %esp,%ebp
80103865:	83 ec 14             	sub    $0x14,%esp
80103868:	8b 45 08             	mov    0x8(%ebp),%eax
8010386b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010386e:	6a 0f                	push   $0xf
80103870:	6a 70                	push   $0x70
80103872:	e8 02 fe ff ff       	call   80103679 <outb>
80103877:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010387a:	6a 0a                	push   $0xa
8010387c:	6a 71                	push   $0x71
8010387e:	e8 f6 fd ff ff       	call   80103679 <outb>
80103883:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103886:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010388d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103890:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103895:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103898:	83 c0 02             	add    $0x2,%eax
8010389b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010389e:	c1 ea 04             	shr    $0x4,%edx
801038a1:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801038a4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038a8:	c1 e0 18             	shl    $0x18,%eax
801038ab:	50                   	push   %eax
801038ac:	68 c4 00 00 00       	push   $0xc4
801038b1:	e8 f2 fd ff ff       	call   801036a8 <lapicw>
801038b6:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801038b9:	68 00 c5 00 00       	push   $0xc500
801038be:	68 c0 00 00 00       	push   $0xc0
801038c3:	e8 e0 fd ff ff       	call   801036a8 <lapicw>
801038c8:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801038cb:	68 c8 00 00 00       	push   $0xc8
801038d0:	e8 87 ff ff ff       	call   8010385c <microdelay>
801038d5:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801038d8:	68 00 85 00 00       	push   $0x8500
801038dd:	68 c0 00 00 00       	push   $0xc0
801038e2:	e8 c1 fd ff ff       	call   801036a8 <lapicw>
801038e7:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038ea:	6a 64                	push   $0x64
801038ec:	e8 6b ff ff ff       	call   8010385c <microdelay>
801038f1:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038fb:	eb 3d                	jmp    8010393a <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801038fd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103901:	c1 e0 18             	shl    $0x18,%eax
80103904:	50                   	push   %eax
80103905:	68 c4 00 00 00       	push   $0xc4
8010390a:	e8 99 fd ff ff       	call   801036a8 <lapicw>
8010390f:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103912:	8b 45 0c             	mov    0xc(%ebp),%eax
80103915:	c1 e8 0c             	shr    $0xc,%eax
80103918:	80 cc 06             	or     $0x6,%ah
8010391b:	50                   	push   %eax
8010391c:	68 c0 00 00 00       	push   $0xc0
80103921:	e8 82 fd ff ff       	call   801036a8 <lapicw>
80103926:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103929:	68 c8 00 00 00       	push   $0xc8
8010392e:	e8 29 ff ff ff       	call   8010385c <microdelay>
80103933:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103936:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010393a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010393e:	7e bd                	jle    801038fd <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103940:	90                   	nop
80103941:	c9                   	leave  
80103942:	c3                   	ret    

80103943 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103943:	55                   	push   %ebp
80103944:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103946:	8b 45 08             	mov    0x8(%ebp),%eax
80103949:	0f b6 c0             	movzbl %al,%eax
8010394c:	50                   	push   %eax
8010394d:	6a 70                	push   $0x70
8010394f:	e8 25 fd ff ff       	call   80103679 <outb>
80103954:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103957:	68 c8 00 00 00       	push   $0xc8
8010395c:	e8 fb fe ff ff       	call   8010385c <microdelay>
80103961:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103964:	6a 71                	push   $0x71
80103966:	e8 f1 fc ff ff       	call   8010365c <inb>
8010396b:	83 c4 04             	add    $0x4,%esp
8010396e:	0f b6 c0             	movzbl %al,%eax
}
80103971:	c9                   	leave  
80103972:	c3                   	ret    

80103973 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103973:	55                   	push   %ebp
80103974:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103976:	6a 00                	push   $0x0
80103978:	e8 c6 ff ff ff       	call   80103943 <cmos_read>
8010397d:	83 c4 04             	add    $0x4,%esp
80103980:	89 c2                	mov    %eax,%edx
80103982:	8b 45 08             	mov    0x8(%ebp),%eax
80103985:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103987:	6a 02                	push   $0x2
80103989:	e8 b5 ff ff ff       	call   80103943 <cmos_read>
8010398e:	83 c4 04             	add    $0x4,%esp
80103991:	89 c2                	mov    %eax,%edx
80103993:	8b 45 08             	mov    0x8(%ebp),%eax
80103996:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103999:	6a 04                	push   $0x4
8010399b:	e8 a3 ff ff ff       	call   80103943 <cmos_read>
801039a0:	83 c4 04             	add    $0x4,%esp
801039a3:	89 c2                	mov    %eax,%edx
801039a5:	8b 45 08             	mov    0x8(%ebp),%eax
801039a8:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801039ab:	6a 07                	push   $0x7
801039ad:	e8 91 ff ff ff       	call   80103943 <cmos_read>
801039b2:	83 c4 04             	add    $0x4,%esp
801039b5:	89 c2                	mov    %eax,%edx
801039b7:	8b 45 08             	mov    0x8(%ebp),%eax
801039ba:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801039bd:	6a 08                	push   $0x8
801039bf:	e8 7f ff ff ff       	call   80103943 <cmos_read>
801039c4:	83 c4 04             	add    $0x4,%esp
801039c7:	89 c2                	mov    %eax,%edx
801039c9:	8b 45 08             	mov    0x8(%ebp),%eax
801039cc:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801039cf:	6a 09                	push   $0x9
801039d1:	e8 6d ff ff ff       	call   80103943 <cmos_read>
801039d6:	83 c4 04             	add    $0x4,%esp
801039d9:	89 c2                	mov    %eax,%edx
801039db:	8b 45 08             	mov    0x8(%ebp),%eax
801039de:	89 50 14             	mov    %edx,0x14(%eax)
}
801039e1:	90                   	nop
801039e2:	c9                   	leave  
801039e3:	c3                   	ret    

801039e4 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039e4:	55                   	push   %ebp
801039e5:	89 e5                	mov    %esp,%ebp
801039e7:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039ea:	6a 0b                	push   $0xb
801039ec:	e8 52 ff ff ff       	call   80103943 <cmos_read>
801039f1:	83 c4 04             	add    $0x4,%esp
801039f4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fa:	83 e0 04             	and    $0x4,%eax
801039fd:	85 c0                	test   %eax,%eax
801039ff:	0f 94 c0             	sete   %al
80103a02:	0f b6 c0             	movzbl %al,%eax
80103a05:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103a08:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a0b:	50                   	push   %eax
80103a0c:	e8 62 ff ff ff       	call   80103973 <fill_rtcdate>
80103a11:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103a14:	6a 0a                	push   $0xa
80103a16:	e8 28 ff ff ff       	call   80103943 <cmos_read>
80103a1b:	83 c4 04             	add    $0x4,%esp
80103a1e:	25 80 00 00 00       	and    $0x80,%eax
80103a23:	85 c0                	test   %eax,%eax
80103a25:	75 27                	jne    80103a4e <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103a27:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a2a:	50                   	push   %eax
80103a2b:	e8 43 ff ff ff       	call   80103973 <fill_rtcdate>
80103a30:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a33:	83 ec 04             	sub    $0x4,%esp
80103a36:	6a 18                	push   $0x18
80103a38:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a3b:	50                   	push   %eax
80103a3c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a3f:	50                   	push   %eax
80103a40:	e8 1c 24 00 00       	call   80105e61 <memcmp>
80103a45:	83 c4 10             	add    $0x10,%esp
80103a48:	85 c0                	test   %eax,%eax
80103a4a:	74 05                	je     80103a51 <cmostime+0x6d>
80103a4c:	eb ba                	jmp    80103a08 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a4e:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a4f:	eb b7                	jmp    80103a08 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103a51:	90                   	nop
  }

  // convert
  if (bcd) {
80103a52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a56:	0f 84 b4 00 00 00    	je     80103b10 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a5f:	c1 e8 04             	shr    $0x4,%eax
80103a62:	89 c2                	mov    %eax,%edx
80103a64:	89 d0                	mov    %edx,%eax
80103a66:	c1 e0 02             	shl    $0x2,%eax
80103a69:	01 d0                	add    %edx,%eax
80103a6b:	01 c0                	add    %eax,%eax
80103a6d:	89 c2                	mov    %eax,%edx
80103a6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a72:	83 e0 0f             	and    $0xf,%eax
80103a75:	01 d0                	add    %edx,%eax
80103a77:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a7d:	c1 e8 04             	shr    $0x4,%eax
80103a80:	89 c2                	mov    %eax,%edx
80103a82:	89 d0                	mov    %edx,%eax
80103a84:	c1 e0 02             	shl    $0x2,%eax
80103a87:	01 d0                	add    %edx,%eax
80103a89:	01 c0                	add    %eax,%eax
80103a8b:	89 c2                	mov    %eax,%edx
80103a8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a90:	83 e0 0f             	and    $0xf,%eax
80103a93:	01 d0                	add    %edx,%eax
80103a95:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a9b:	c1 e8 04             	shr    $0x4,%eax
80103a9e:	89 c2                	mov    %eax,%edx
80103aa0:	89 d0                	mov    %edx,%eax
80103aa2:	c1 e0 02             	shl    $0x2,%eax
80103aa5:	01 d0                	add    %edx,%eax
80103aa7:	01 c0                	add    %eax,%eax
80103aa9:	89 c2                	mov    %eax,%edx
80103aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103aae:	83 e0 0f             	and    $0xf,%eax
80103ab1:	01 d0                	add    %edx,%eax
80103ab3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103ab6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ab9:	c1 e8 04             	shr    $0x4,%eax
80103abc:	89 c2                	mov    %eax,%edx
80103abe:	89 d0                	mov    %edx,%eax
80103ac0:	c1 e0 02             	shl    $0x2,%eax
80103ac3:	01 d0                	add    %edx,%eax
80103ac5:	01 c0                	add    %eax,%eax
80103ac7:	89 c2                	mov    %eax,%edx
80103ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103acc:	83 e0 0f             	and    $0xf,%eax
80103acf:	01 d0                	add    %edx,%eax
80103ad1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ad7:	c1 e8 04             	shr    $0x4,%eax
80103ada:	89 c2                	mov    %eax,%edx
80103adc:	89 d0                	mov    %edx,%eax
80103ade:	c1 e0 02             	shl    $0x2,%eax
80103ae1:	01 d0                	add    %edx,%eax
80103ae3:	01 c0                	add    %eax,%eax
80103ae5:	89 c2                	mov    %eax,%edx
80103ae7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103aea:	83 e0 0f             	and    $0xf,%eax
80103aed:	01 d0                	add    %edx,%eax
80103aef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af5:	c1 e8 04             	shr    $0x4,%eax
80103af8:	89 c2                	mov    %eax,%edx
80103afa:	89 d0                	mov    %edx,%eax
80103afc:	c1 e0 02             	shl    $0x2,%eax
80103aff:	01 d0                	add    %edx,%eax
80103b01:	01 c0                	add    %eax,%eax
80103b03:	89 c2                	mov    %eax,%edx
80103b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b08:	83 e0 0f             	and    $0xf,%eax
80103b0b:	01 d0                	add    %edx,%eax
80103b0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103b16:	89 10                	mov    %edx,(%eax)
80103b18:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103b1b:	89 50 04             	mov    %edx,0x4(%eax)
80103b1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103b21:	89 50 08             	mov    %edx,0x8(%eax)
80103b24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b27:	89 50 0c             	mov    %edx,0xc(%eax)
80103b2a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b2d:	89 50 10             	mov    %edx,0x10(%eax)
80103b30:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b33:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b36:	8b 45 08             	mov    0x8(%ebp),%eax
80103b39:	8b 40 14             	mov    0x14(%eax),%eax
80103b3c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b42:	8b 45 08             	mov    0x8(%ebp),%eax
80103b45:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b48:	90                   	nop
80103b49:	c9                   	leave  
80103b4a:	c3                   	ret    

80103b4b <initlog>:
static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
80103b4b:	55                   	push   %ebp
80103b4c:	89 e5                	mov    %esp,%ebp
80103b4e:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103b51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b58:	e9 b1 00 00 00       	jmp    80103c0e <initlog+0xc3>
    if(mbrI.partitions[i].size > 0){
80103b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b60:	83 c0 1b             	add    $0x1b,%eax
80103b63:	c1 e0 04             	shl    $0x4,%eax
80103b66:	05 00 18 11 80       	add    $0x80111800,%eax
80103b6b:	8b 40 1a             	mov    0x1a(%eax),%eax
80103b6e:	85 c0                	test   %eax,%eax
80103b70:	0f 84 94 00 00 00    	je     80103c0a <initlog+0xbf>
        initlock(&logs[i].lock, "log");
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b7f:	05 40 35 11 80       	add    $0x80113540,%eax
80103b84:	83 ec 08             	sub    $0x8,%esp
80103b87:	68 a8 97 10 80       	push   $0x801097a8
80103b8c:	50                   	push   %eax
80103b8d:	e8 e3 1f 00 00       	call   80105b75 <initlock>
80103b92:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b98:	c1 e0 05             	shl    $0x5,%eax
80103b9b:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103ba0:	8b 50 0c             	mov    0xc(%eax),%edx
80103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba6:	c1 e0 05             	shl    $0x5,%eax
80103ba9:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103bae:	8b 00                	mov    (%eax),%eax
80103bb0:	01 d0                	add    %edx,%eax
80103bb2:	89 c2                	mov    %eax,%edx
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bbd:	05 70 35 11 80       	add    $0x80113570,%eax
80103bc2:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc8:	c1 e0 05             	shl    $0x5,%eax
80103bcb:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103bd0:	8b 40 0c             	mov    0xc(%eax),%eax
80103bd3:	89 c2                	mov    %eax,%edx
80103bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bde:	05 70 35 11 80       	add    $0x80113570,%eax
80103be3:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bef:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf8:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfe:	83 ec 0c             	sub    $0xc,%esp
80103c01:	50                   	push   %eax
80103c02:	e8 6a 02 00 00       	call   80103e71 <recover_from_log>
80103c07:	83 c4 10             	add    $0x10,%esp
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103c0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c0e:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103c12:	0f 8e 45 ff ff ff    	jle    80103b5d <initlog+0x12>
  recover_from_log(i);
    }
     
}
 
}
80103c18:	90                   	nop
80103c19:	c9                   	leave  
80103c1a:	c3                   	ret    

80103c1b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103c1b:	55                   	push   %ebp
80103c1c:	89 e5                	mov    %esp,%ebp
80103c1e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103c21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c28:	e9 c0 00 00 00       	jmp    80103ced <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c30:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c36:	05 70 35 11 80       	add    $0x80113570,%eax
80103c3b:	8b 50 04             	mov    0x4(%eax),%edx
80103c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c41:	01 d0                	add    %edx,%eax
80103c43:	83 c0 01             	add    $0x1,%eax
80103c46:	89 c2                	mov    %eax,%edx
80103c48:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c51:	05 80 35 11 80       	add    $0x80113580,%eax
80103c56:	8b 40 04             	mov    0x4(%eax),%eax
80103c59:	83 ec 08             	sub    $0x8,%esp
80103c5c:	52                   	push   %edx
80103c5d:	50                   	push   %eax
80103c5e:	e8 53 c5 ff ff       	call   801001b6 <bread>
80103c63:	83 c4 10             	add    $0x10,%esp
80103c66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c69:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6c:	6b d0 31             	imul   $0x31,%eax,%edx
80103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c72:	01 d0                	add    %edx,%eax
80103c74:	83 c0 10             	add    $0x10,%eax
80103c77:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c7e:	89 c2                	mov    %eax,%edx
80103c80:	8b 45 08             	mov    0x8(%ebp),%eax
80103c83:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c89:	05 80 35 11 80       	add    $0x80113580,%eax
80103c8e:	8b 40 04             	mov    0x4(%eax),%eax
80103c91:	83 ec 08             	sub    $0x8,%esp
80103c94:	52                   	push   %edx
80103c95:	50                   	push   %eax
80103c96:	e8 1b c5 ff ff       	call   801001b6 <bread>
80103c9b:	83 c4 10             	add    $0x10,%esp
80103c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca4:	8d 50 18             	lea    0x18(%eax),%edx
80103ca7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103caa:	83 c0 18             	add    $0x18,%eax
80103cad:	83 ec 04             	sub    $0x4,%esp
80103cb0:	68 00 02 00 00       	push   $0x200
80103cb5:	52                   	push   %edx
80103cb6:	50                   	push   %eax
80103cb7:	e8 fd 21 00 00       	call   80105eb9 <memmove>
80103cbc:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103cbf:	83 ec 0c             	sub    $0xc,%esp
80103cc2:	ff 75 ec             	pushl  -0x14(%ebp)
80103cc5:	e8 25 c5 ff ff       	call   801001ef <bwrite>
80103cca:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103ccd:	83 ec 0c             	sub    $0xc,%esp
80103cd0:	ff 75 f0             	pushl  -0x10(%ebp)
80103cd3:	e8 56 c5 ff ff       	call   8010022e <brelse>
80103cd8:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103cdb:	83 ec 0c             	sub    $0xc,%esp
80103cde:	ff 75 ec             	pushl  -0x14(%ebp)
80103ce1:	e8 48 c5 ff ff       	call   8010022e <brelse>
80103ce6:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103ce9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ced:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cf6:	05 80 35 11 80       	add    $0x80113580,%eax
80103cfb:	8b 40 08             	mov    0x8(%eax),%eax
80103cfe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d01:	0f 8f 26 ff ff ff    	jg     80103c2d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103d07:	90                   	nop
80103d08:	c9                   	leave  
80103d09:	c3                   	ret    

80103d0a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103d0a:	55                   	push   %ebp
80103d0b:	89 e5                	mov    %esp,%ebp
80103d0d:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d19:	05 70 35 11 80       	add    $0x80113570,%eax
80103d1e:	8b 40 04             	mov    0x4(%eax),%eax
80103d21:	89 c2                	mov    %eax,%edx
80103d23:	8b 45 08             	mov    0x8(%ebp),%eax
80103d26:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d2c:	05 80 35 11 80       	add    $0x80113580,%eax
80103d31:	8b 40 04             	mov    0x4(%eax),%eax
80103d34:	83 ec 08             	sub    $0x8,%esp
80103d37:	52                   	push   %edx
80103d38:	50                   	push   %eax
80103d39:	e8 78 c4 ff ff       	call   801001b6 <bread>
80103d3e:	83 c4 10             	add    $0x10,%esp
80103d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d47:	83 c0 18             	add    $0x18,%eax
80103d4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d50:	8b 00                	mov    (%eax),%eax
80103d52:	8b 55 08             	mov    0x8(%ebp),%edx
80103d55:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d5b:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d61:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d6b:	eb 23                	jmp    80103d90 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d73:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d77:	8b 55 08             	mov    0x8(%ebp),%edx
80103d7a:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d80:	01 ca                	add    %ecx,%edx
80103d82:	83 c2 10             	add    $0x10,%edx
80103d85:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d90:	8b 45 08             	mov    0x8(%ebp),%eax
80103d93:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d99:	05 80 35 11 80       	add    $0x80113580,%eax
80103d9e:	8b 40 08             	mov    0x8(%eax),%eax
80103da1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103da4:	7f c7                	jg     80103d6d <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103da6:	83 ec 0c             	sub    $0xc,%esp
80103da9:	ff 75 f0             	pushl  -0x10(%ebp)
80103dac:	e8 7d c4 ff ff       	call   8010022e <brelse>
80103db1:	83 c4 10             	add    $0x10,%esp
}
80103db4:	90                   	nop
80103db5:	c9                   	leave  
80103db6:	c3                   	ret    

80103db7 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103db7:	55                   	push   %ebp
80103db8:	89 e5                	mov    %esp,%ebp
80103dba:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dc6:	05 70 35 11 80       	add    $0x80113570,%eax
80103dcb:	8b 40 04             	mov    0x4(%eax),%eax
80103dce:	89 c2                	mov    %eax,%edx
80103dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dd9:	05 80 35 11 80       	add    $0x80113580,%eax
80103dde:	8b 40 04             	mov    0x4(%eax),%eax
80103de1:	83 ec 08             	sub    $0x8,%esp
80103de4:	52                   	push   %edx
80103de5:	50                   	push   %eax
80103de6:	e8 cb c3 ff ff       	call   801001b6 <bread>
80103deb:	83 c4 10             	add    $0x10,%esp
80103dee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df4:	83 c0 18             	add    $0x18,%eax
80103df7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80103dfd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e03:	05 80 35 11 80       	add    $0x80113580,%eax
80103e08:	8b 50 08             	mov    0x8(%eax),%edx
80103e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e0e:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e17:	eb 23                	jmp    80103e3c <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103e19:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1c:	6b d0 31             	imul   $0x31,%eax,%edx
80103e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e22:	01 d0                	add    %edx,%eax
80103e24:	83 c0 10             	add    $0x10,%eax
80103e27:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103e2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e34:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e45:	05 80 35 11 80       	add    $0x80113580,%eax
80103e4a:	8b 40 08             	mov    0x8(%eax),%eax
80103e4d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e50:	7f c7                	jg     80103e19 <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e52:	83 ec 0c             	sub    $0xc,%esp
80103e55:	ff 75 f0             	pushl  -0x10(%ebp)
80103e58:	e8 92 c3 ff ff       	call   801001ef <bwrite>
80103e5d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e60:	83 ec 0c             	sub    $0xc,%esp
80103e63:	ff 75 f0             	pushl  -0x10(%ebp)
80103e66:	e8 c3 c3 ff ff       	call   8010022e <brelse>
80103e6b:	83 c4 10             	add    $0x10,%esp
}
80103e6e:	90                   	nop
80103e6f:	c9                   	leave  
80103e70:	c3                   	ret    

80103e71 <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e71:	55                   	push   %ebp
80103e72:	89 e5                	mov    %esp,%ebp
80103e74:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e77:	83 ec 0c             	sub    $0xc,%esp
80103e7a:	ff 75 08             	pushl  0x8(%ebp)
80103e7d:	e8 88 fe ff ff       	call   80103d0a <read_head>
80103e82:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e85:	83 ec 0c             	sub    $0xc,%esp
80103e88:	ff 75 08             	pushl  0x8(%ebp)
80103e8b:	e8 8b fd ff ff       	call   80103c1b <install_trans>
80103e90:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e93:	8b 45 08             	mov    0x8(%ebp),%eax
80103e96:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e9c:	05 80 35 11 80       	add    $0x80113580,%eax
80103ea1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103ea8:	83 ec 0c             	sub    $0xc,%esp
80103eab:	ff 75 08             	pushl  0x8(%ebp)
80103eae:	e8 04 ff ff ff       	call   80103db7 <write_head>
80103eb3:	83 c4 10             	add    $0x10,%esp
}
80103eb6:	90                   	nop
80103eb7:	c9                   	leave  
80103eb8:	c3                   	ret    

80103eb9 <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103eb9:	55                   	push   %ebp
80103eba:	89 e5                	mov    %esp,%ebp
80103ebc:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ec8:	05 40 35 11 80       	add    $0x80113540,%eax
80103ecd:	83 ec 0c             	sub    $0xc,%esp
80103ed0:	50                   	push   %eax
80103ed1:	e8 c1 1c 00 00       	call   80105b97 <acquire>
80103ed6:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80103edc:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ee2:	05 80 35 11 80       	add    $0x80113580,%eax
80103ee7:	8b 00                	mov    (%eax),%eax
80103ee9:	85 c0                	test   %eax,%eax
80103eeb:	74 2c                	je     80103f19 <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103eed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ef6:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103efc:	8b 45 08             	mov    0x8(%ebp),%eax
80103eff:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f05:	05 40 35 11 80       	add    $0x80113540,%eax
80103f0a:	83 ec 08             	sub    $0x8,%esp
80103f0d:	52                   	push   %edx
80103f0e:	50                   	push   %eax
80103f0f:	e8 8a 19 00 00       	call   8010589e <sleep>
80103f14:	83 c4 10             	add    $0x10,%esp
80103f17:	eb c0                	jmp    80103ed9 <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103f19:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f22:	05 80 35 11 80       	add    $0x80113580,%eax
80103f27:	8b 48 08             	mov    0x8(%eax),%ecx
80103f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f33:	05 70 35 11 80       	add    $0x80113570,%eax
80103f38:	8b 40 0c             	mov    0xc(%eax),%eax
80103f3b:	8d 50 01             	lea    0x1(%eax),%edx
80103f3e:	89 d0                	mov    %edx,%eax
80103f40:	c1 e0 02             	shl    $0x2,%eax
80103f43:	01 d0                	add    %edx,%eax
80103f45:	01 c0                	add    %eax,%eax
80103f47:	01 c8                	add    %ecx,%eax
80103f49:	83 f8 1e             	cmp    $0x1e,%eax
80103f4c:	7e 2f                	jle    80103f7d <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f51:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f57:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f60:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f66:	05 40 35 11 80       	add    $0x80113540,%eax
80103f6b:	83 ec 08             	sub    $0x8,%esp
80103f6e:	52                   	push   %edx
80103f6f:	50                   	push   %eax
80103f70:	e8 29 19 00 00       	call   8010589e <sleep>
80103f75:	83 c4 10             	add    $0x10,%esp
80103f78:	e9 5c ff ff ff       	jmp    80103ed9 <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f80:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f86:	05 70 35 11 80       	add    $0x80113570,%eax
80103f8b:	8b 40 0c             	mov    0xc(%eax),%eax
80103f8e:	8d 50 01             	lea    0x1(%eax),%edx
80103f91:	8b 45 08             	mov    0x8(%ebp),%eax
80103f94:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f9a:	05 70 35 11 80       	add    $0x80113570,%eax
80103f9f:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fab:	05 40 35 11 80       	add    $0x80113540,%eax
80103fb0:	83 ec 0c             	sub    $0xc,%esp
80103fb3:	50                   	push   %eax
80103fb4:	e8 45 1c 00 00       	call   80105bfe <release>
80103fb9:	83 c4 10             	add    $0x10,%esp
      break;
80103fbc:	90                   	nop
    }
  }
}
80103fbd:	90                   	nop
80103fbe:	c9                   	leave  
80103fbf:	c3                   	ret    

80103fc0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103fc0:	55                   	push   %ebp
80103fc1:	89 e5                	mov    %esp,%ebp
80103fc3:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103fc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fd6:	05 40 35 11 80       	add    $0x80113540,%eax
80103fdb:	83 ec 0c             	sub    $0xc,%esp
80103fde:	50                   	push   %eax
80103fdf:	e8 b3 1b 00 00       	call   80105b97 <acquire>
80103fe4:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fea:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ff0:	05 70 35 11 80       	add    $0x80113570,%eax
80103ff5:	8b 40 0c             	mov    0xc(%eax),%eax
80103ff8:	8d 50 ff             	lea    -0x1(%eax),%edx
80103ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffe:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104004:	05 70 35 11 80       	add    $0x80113570,%eax
80104009:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
8010400c:	8b 45 08             	mov    0x8(%ebp),%eax
8010400f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104015:	05 80 35 11 80       	add    $0x80113580,%eax
8010401a:	8b 00                	mov    (%eax),%eax
8010401c:	85 c0                	test   %eax,%eax
8010401e:	74 0d                	je     8010402d <end_op+0x6d>
    panic("log.committing");
80104020:	83 ec 0c             	sub    $0xc,%esp
80104023:	68 ac 97 10 80       	push   $0x801097ac
80104028:	e8 39 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
8010402d:	8b 45 08             	mov    0x8(%ebp),%eax
80104030:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104036:	05 70 35 11 80       	add    $0x80113570,%eax
8010403b:	8b 40 0c             	mov    0xc(%eax),%eax
8010403e:	85 c0                	test   %eax,%eax
80104040:	75 1d                	jne    8010405f <end_op+0x9f>
    do_commit = 1;
80104042:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80104049:	8b 45 08             	mov    0x8(%ebp),%eax
8010404c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104052:	05 80 35 11 80       	add    $0x80113580,%eax
80104057:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
8010405d:	eb 1a                	jmp    80104079 <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
8010405f:	8b 45 08             	mov    0x8(%ebp),%eax
80104062:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104068:	05 40 35 11 80       	add    $0x80113540,%eax
8010406d:	83 ec 0c             	sub    $0xc,%esp
80104070:	50                   	push   %eax
80104071:	e8 13 19 00 00       	call   80105989 <wakeup>
80104076:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
80104079:	8b 45 08             	mov    0x8(%ebp),%eax
8010407c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104082:	05 40 35 11 80       	add    $0x80113540,%eax
80104087:	83 ec 0c             	sub    $0xc,%esp
8010408a:	50                   	push   %eax
8010408b:	e8 6e 1b 00 00       	call   80105bfe <release>
80104090:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80104093:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104097:	74 70                	je     80104109 <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80104099:	83 ec 0c             	sub    $0xc,%esp
8010409c:	ff 75 08             	pushl  0x8(%ebp)
8010409f:	e8 57 01 00 00       	call   801041fb <commit>
801040a4:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040b0:	05 40 35 11 80       	add    $0x80113540,%eax
801040b5:	83 ec 0c             	sub    $0xc,%esp
801040b8:	50                   	push   %eax
801040b9:	e8 d9 1a 00 00       	call   80105b97 <acquire>
801040be:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
801040c1:	8b 45 08             	mov    0x8(%ebp),%eax
801040c4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040ca:	05 80 35 11 80       	add    $0x80113580,%eax
801040cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040de:	05 40 35 11 80       	add    $0x80113540,%eax
801040e3:	83 ec 0c             	sub    $0xc,%esp
801040e6:	50                   	push   %eax
801040e7:	e8 9d 18 00 00       	call   80105989 <wakeup>
801040ec:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040f8:	05 40 35 11 80       	add    $0x80113540,%eax
801040fd:	83 ec 0c             	sub    $0xc,%esp
80104100:	50                   	push   %eax
80104101:	e8 f8 1a 00 00       	call   80105bfe <release>
80104106:	83 c4 10             	add    $0x10,%esp
  }
}
80104109:	90                   	nop
8010410a:	c9                   	leave  
8010410b:	c3                   	ret    

8010410c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
8010410c:	55                   	push   %ebp
8010410d:	89 e5                	mov    %esp,%ebp
8010410f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80104112:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104119:	e9 c0 00 00 00       	jmp    801041de <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
8010411e:	8b 45 08             	mov    0x8(%ebp),%eax
80104121:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104127:	05 70 35 11 80       	add    $0x80113570,%eax
8010412c:	8b 50 04             	mov    0x4(%eax),%edx
8010412f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104132:	01 d0                	add    %edx,%eax
80104134:	83 c0 01             	add    $0x1,%eax
80104137:	89 c2                	mov    %eax,%edx
80104139:	8b 45 08             	mov    0x8(%ebp),%eax
8010413c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104142:	05 80 35 11 80       	add    $0x80113580,%eax
80104147:	8b 40 04             	mov    0x4(%eax),%eax
8010414a:	83 ec 08             	sub    $0x8,%esp
8010414d:	52                   	push   %edx
8010414e:	50                   	push   %eax
8010414f:	e8 62 c0 ff ff       	call   801001b6 <bread>
80104154:	83 c4 10             	add    $0x10,%esp
80104157:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
8010415a:	8b 45 08             	mov    0x8(%ebp),%eax
8010415d:	6b d0 31             	imul   $0x31,%eax,%edx
80104160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104163:	01 d0                	add    %edx,%eax
80104165:	83 c0 10             	add    $0x10,%eax
80104168:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
8010416f:	89 c2                	mov    %eax,%edx
80104171:	8b 45 08             	mov    0x8(%ebp),%eax
80104174:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010417a:	05 80 35 11 80       	add    $0x80113580,%eax
8010417f:	8b 40 04             	mov    0x4(%eax),%eax
80104182:	83 ec 08             	sub    $0x8,%esp
80104185:	52                   	push   %edx
80104186:	50                   	push   %eax
80104187:	e8 2a c0 ff ff       	call   801001b6 <bread>
8010418c:	83 c4 10             	add    $0x10,%esp
8010418f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80104192:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104195:	8d 50 18             	lea    0x18(%eax),%edx
80104198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419b:	83 c0 18             	add    $0x18,%eax
8010419e:	83 ec 04             	sub    $0x4,%esp
801041a1:	68 00 02 00 00       	push   $0x200
801041a6:	52                   	push   %edx
801041a7:	50                   	push   %eax
801041a8:	e8 0c 1d 00 00       	call   80105eb9 <memmove>
801041ad:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801041b0:	83 ec 0c             	sub    $0xc,%esp
801041b3:	ff 75 f0             	pushl  -0x10(%ebp)
801041b6:	e8 34 c0 ff ff       	call   801001ef <bwrite>
801041bb:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801041be:	83 ec 0c             	sub    $0xc,%esp
801041c1:	ff 75 ec             	pushl  -0x14(%ebp)
801041c4:	e8 65 c0 ff ff       	call   8010022e <brelse>
801041c9:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	ff 75 f0             	pushl  -0x10(%ebp)
801041d2:	e8 57 c0 ff ff       	call   8010022e <brelse>
801041d7:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801041da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041de:	8b 45 08             	mov    0x8(%ebp),%eax
801041e1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041e7:	05 80 35 11 80       	add    $0x80113580,%eax
801041ec:	8b 40 08             	mov    0x8(%eax),%eax
801041ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041f2:	0f 8f 26 ff ff ff    	jg     8010411e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041f8:	90                   	nop
801041f9:	c9                   	leave  
801041fa:	c3                   	ret    

801041fb <commit>:

static void
commit(uint partitionNumber)
{
801041fb:	55                   	push   %ebp
801041fc:	89 e5                	mov    %esp,%ebp
801041fe:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010420a:	05 80 35 11 80       	add    $0x80113580,%eax
8010420f:	8b 40 08             	mov    0x8(%eax),%eax
80104212:	85 c0                	test   %eax,%eax
80104214:	7e 4d                	jle    80104263 <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
80104216:	83 ec 0c             	sub    $0xc,%esp
80104219:	ff 75 08             	pushl  0x8(%ebp)
8010421c:	e8 eb fe ff ff       	call   8010410c <write_log>
80104221:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	ff 75 08             	pushl  0x8(%ebp)
8010422a:	e8 88 fb ff ff       	call   80103db7 <write_head>
8010422f:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
80104232:	83 ec 0c             	sub    $0xc,%esp
80104235:	ff 75 08             	pushl  0x8(%ebp)
80104238:	e8 de f9 ff ff       	call   80103c1b <install_trans>
8010423d:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104240:	8b 45 08             	mov    0x8(%ebp),%eax
80104243:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104249:	05 80 35 11 80       	add    $0x80113580,%eax
8010424e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
80104255:	83 ec 0c             	sub    $0xc,%esp
80104258:	ff 75 08             	pushl  0x8(%ebp)
8010425b:	e8 57 fb ff ff       	call   80103db7 <write_head>
80104260:	83 c4 10             	add    $0x10,%esp
  }
}
80104263:	90                   	nop
80104264:	c9                   	leave  
80104265:	c3                   	ret    

80104266 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
80104266:	55                   	push   %ebp
80104267:	89 e5                	mov    %esp,%ebp
80104269:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
8010426c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104275:	05 80 35 11 80       	add    $0x80113580,%eax
8010427a:	8b 40 08             	mov    0x8(%eax),%eax
8010427d:	83 f8 1d             	cmp    $0x1d,%eax
80104280:	7f 2a                	jg     801042ac <log_write+0x46>
80104282:	8b 45 0c             	mov    0xc(%ebp),%eax
80104285:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010428b:	05 80 35 11 80       	add    $0x80113580,%eax
80104290:	8b 40 08             	mov    0x8(%eax),%eax
80104293:	8b 55 0c             	mov    0xc(%ebp),%edx
80104296:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
8010429c:	81 c2 70 35 11 80    	add    $0x80113570,%edx
801042a2:	8b 52 08             	mov    0x8(%edx),%edx
801042a5:	83 ea 01             	sub    $0x1,%edx
801042a8:	39 d0                	cmp    %edx,%eax
801042aa:	7c 0d                	jl     801042b9 <log_write+0x53>
    panic("too big a transaction");
801042ac:	83 ec 0c             	sub    $0xc,%esp
801042af:	68 bb 97 10 80       	push   $0x801097bb
801042b4:	e8 ad c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
801042b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042bc:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042c2:	05 70 35 11 80       	add    $0x80113570,%eax
801042c7:	8b 40 0c             	mov    0xc(%eax),%eax
801042ca:	85 c0                	test   %eax,%eax
801042cc:	7f 0d                	jg     801042db <log_write+0x75>
    panic("log_write outside of trans");
801042ce:	83 ec 0c             	sub    $0xc,%esp
801042d1:	68 d1 97 10 80       	push   $0x801097d1
801042d6:	e8 8b c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
801042db:	8b 45 0c             	mov    0xc(%ebp),%eax
801042de:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042e4:	05 40 35 11 80       	add    $0x80113540,%eax
801042e9:	83 ec 0c             	sub    $0xc,%esp
801042ec:	50                   	push   %eax
801042ed:	e8 a5 18 00 00       	call   80105b97 <acquire>
801042f2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042fc:	eb 25                	jmp    80104323 <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104301:	6b d0 31             	imul   $0x31,%eax,%edx
80104304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104307:	01 d0                	add    %edx,%eax
80104309:	83 c0 10             	add    $0x10,%eax
8010430c:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104313:	89 c2                	mov    %eax,%edx
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	8b 40 08             	mov    0x8(%eax),%eax
8010431b:	39 c2                	cmp    %eax,%edx
8010431d:	74 1c                	je     8010433b <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
8010431f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104323:	8b 45 0c             	mov    0xc(%ebp),%eax
80104326:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010432c:	05 80 35 11 80       	add    $0x80113580,%eax
80104331:	8b 40 08             	mov    0x8(%eax),%eax
80104334:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104337:	7f c5                	jg     801042fe <log_write+0x98>
80104339:	eb 01                	jmp    8010433c <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
8010433b:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
8010433c:	8b 45 08             	mov    0x8(%ebp),%eax
8010433f:	8b 40 08             	mov    0x8(%eax),%eax
80104342:	89 c1                	mov    %eax,%ecx
80104344:	8b 45 0c             	mov    0xc(%ebp),%eax
80104347:	6b d0 31             	imul   $0x31,%eax,%edx
8010434a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434d:	01 d0                	add    %edx,%eax
8010434f:	83 c0 10             	add    $0x10,%eax
80104352:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
80104359:	8b 45 0c             	mov    0xc(%ebp),%eax
8010435c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104362:	05 80 35 11 80       	add    $0x80113580,%eax
80104367:	8b 40 08             	mov    0x8(%eax),%eax
8010436a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010436d:	75 25                	jne    80104394 <log_write+0x12e>
    logs[partitionNumber].lh.n++;
8010436f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104372:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104378:	05 80 35 11 80       	add    $0x80113580,%eax
8010437d:	8b 40 08             	mov    0x8(%eax),%eax
80104380:	8d 50 01             	lea    0x1(%eax),%edx
80104383:	8b 45 0c             	mov    0xc(%ebp),%eax
80104386:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010438c:	05 80 35 11 80       	add    $0x80113580,%eax
80104391:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
80104394:	8b 45 08             	mov    0x8(%ebp),%eax
80104397:	8b 00                	mov    (%eax),%eax
80104399:	83 c8 04             	or     $0x4,%eax
8010439c:	89 c2                	mov    %eax,%edx
8010439e:	8b 45 08             	mov    0x8(%ebp),%eax
801043a1:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
801043a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801043ac:	05 40 35 11 80       	add    $0x80113540,%eax
801043b1:	83 ec 0c             	sub    $0xc,%esp
801043b4:	50                   	push   %eax
801043b5:	e8 44 18 00 00       	call   80105bfe <release>
801043ba:	83 c4 10             	add    $0x10,%esp
}
801043bd:	90                   	nop
801043be:	c9                   	leave  
801043bf:	c3                   	ret    

801043c0 <v2p>:
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	8b 45 08             	mov    0x8(%ebp),%eax
801043c6:	05 00 00 00 80       	add    $0x80000000,%eax
801043cb:	5d                   	pop    %ebp
801043cc:	c3                   	ret    

801043cd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801043cd:	55                   	push   %ebp
801043ce:	89 e5                	mov    %esp,%ebp
801043d0:	8b 45 08             	mov    0x8(%ebp),%eax
801043d3:	05 00 00 00 80       	add    $0x80000000,%eax
801043d8:	5d                   	pop    %ebp
801043d9:	c3                   	ret    

801043da <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801043da:	55                   	push   %ebp
801043db:	89 e5                	mov    %esp,%ebp
801043dd:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043e0:	8b 55 08             	mov    0x8(%ebp),%edx
801043e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043e9:	f0 87 02             	lock xchg %eax,(%edx)
801043ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043f2:	c9                   	leave  
801043f3:	c3                   	ret    

801043f4 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043f4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043f8:	83 e4 f0             	and    $0xfffffff0,%esp
801043fb:	ff 71 fc             	pushl  -0x4(%ecx)
801043fe:	55                   	push   %ebp
801043ff:	89 e5                	mov    %esp,%ebp
80104401:	51                   	push   %ecx
80104402:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80104405:	83 ec 08             	sub    $0x8,%esp
80104408:	68 00 00 40 80       	push   $0x80400000
8010440d:	68 5c 66 11 80       	push   $0x8011665c
80104412:	e8 34 ef ff ff       	call   8010334b <kinit1>
80104417:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010441a:	e8 cb 48 00 00       	call   80108cea <kvmalloc>
  mpinit();        // collect info about this machine
8010441f:	e8 26 04 00 00       	call   8010484a <mpinit>
  lapicinit();
80104424:	e8 a1 f2 ff ff       	call   801036ca <lapicinit>
  seginit();       // set up segments
80104429:	e8 65 42 00 00       	call   80108693 <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
8010442e:	e8 6d 06 00 00       	call   80104aa0 <picinit>
  ioapicinit();    // another interrupt controller
80104433:	e8 08 ee ff ff       	call   80103240 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104438:	e8 dc c6 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
8010443d:	e8 ad 35 00 00       	call   801079ef <uartinit>
  pinit();         // process table
80104442:	e8 56 0b 00 00       	call   80104f9d <pinit>
  tvinit();        // trap vectors
80104447:	e8 6d 31 00 00       	call   801075b9 <tvinit>
  binit();         // buffer cache
8010444c:	e8 e3 bb ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80104451:	e8 77 cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
80104456:	e8 cd e9 ff ff       	call   80102e28 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
8010445b:	a1 64 38 11 80       	mov    0x80113864,%eax
80104460:	85 c0                	test   %eax,%eax
80104462:	75 05                	jne    80104469 <main+0x75>
    timerinit();   // uniprocessor timer
80104464:	e8 ad 30 00 00       	call   80107516 <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80104469:	e8 7f 00 00 00       	call   801044ed <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010446e:	83 ec 08             	sub    $0x8,%esp
80104471:	68 00 00 00 8e       	push   $0x8e000000
80104476:	68 00 00 40 80       	push   $0x80400000
8010447b:	e8 04 ef ff ff       	call   80103384 <kinit2>
80104480:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
80104483:	e8 39 0c 00 00       	call   801050c1 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
80104488:	e8 1a 00 00 00       	call   801044a7 <mpmain>

8010448d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010448d:	55                   	push   %ebp
8010448e:	89 e5                	mov    %esp,%ebp
80104490:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104493:	e8 6a 48 00 00       	call   80108d02 <switchkvm>
  seginit();
80104498:	e8 f6 41 00 00       	call   80108693 <seginit>
  lapicinit();
8010449d:	e8 28 f2 ff ff       	call   801036ca <lapicinit>
  mpmain();
801044a2:	e8 00 00 00 00       	call   801044a7 <mpmain>

801044a7 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801044a7:	55                   	push   %ebp
801044a8:	89 e5                	mov    %esp,%ebp
801044aa:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801044ad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044b3:	0f b6 00             	movzbl (%eax),%eax
801044b6:	0f b6 c0             	movzbl %al,%eax
801044b9:	83 ec 08             	sub    $0x8,%esp
801044bc:	50                   	push   %eax
801044bd:	68 ec 97 10 80       	push   $0x801097ec
801044c2:	e8 ff be ff ff       	call   801003c6 <cprintf>
801044c7:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801044ca:	e8 60 32 00 00       	call   8010772f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801044cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044d5:	05 a8 00 00 00       	add    $0xa8,%eax
801044da:	83 ec 08             	sub    $0x8,%esp
801044dd:	6a 01                	push   $0x1
801044df:	50                   	push   %eax
801044e0:	e8 f5 fe ff ff       	call   801043da <xchg>
801044e5:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044e8:	e8 ab 11 00 00       	call   80105698 <scheduler>

801044ed <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044ed:	55                   	push   %ebp
801044ee:	89 e5                	mov    %esp,%ebp
801044f0:	53                   	push   %ebx
801044f1:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044f4:	68 00 70 00 00       	push   $0x7000
801044f9:	e8 cf fe ff ff       	call   801043cd <p2v>
801044fe:	83 c4 04             	add    $0x4,%esp
80104501:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80104504:	b8 8a 00 00 00       	mov    $0x8a,%eax
80104509:	83 ec 04             	sub    $0x4,%esp
8010450c:	50                   	push   %eax
8010450d:	68 0c c5 10 80       	push   $0x8010c50c
80104512:	ff 75 f0             	pushl  -0x10(%ebp)
80104515:	e8 9f 19 00 00       	call   80105eb9 <memmove>
8010451a:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010451d:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
80104524:	e9 90 00 00 00       	jmp    801045b9 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80104529:	e8 ba f2 ff ff       	call   801037e8 <cpunum>
8010452e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104534:	05 80 38 11 80       	add    $0x80113880,%eax
80104539:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010453c:	74 73                	je     801045b1 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010453e:	e8 3f ef ff ff       	call   80103482 <kalloc>
80104543:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104549:	83 e8 04             	sub    $0x4,%eax
8010454c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010454f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104555:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010455a:	83 e8 08             	sub    $0x8,%eax
8010455d:	c7 00 8d 44 10 80    	movl   $0x8010448d,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104566:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104569:	83 ec 0c             	sub    $0xc,%esp
8010456c:	68 00 b0 10 80       	push   $0x8010b000
80104571:	e8 4a fe ff ff       	call   801043c0 <v2p>
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010457b:	83 ec 0c             	sub    $0xc,%esp
8010457e:	ff 75 f0             	pushl  -0x10(%ebp)
80104581:	e8 3a fe ff ff       	call   801043c0 <v2p>
80104586:	83 c4 10             	add    $0x10,%esp
80104589:	89 c2                	mov    %eax,%edx
8010458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458e:	0f b6 00             	movzbl (%eax),%eax
80104591:	0f b6 c0             	movzbl %al,%eax
80104594:	83 ec 08             	sub    $0x8,%esp
80104597:	52                   	push   %edx
80104598:	50                   	push   %eax
80104599:	e8 c4 f2 ff ff       	call   80103862 <lapicstartap>
8010459e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801045a1:	90                   	nop
801045a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045ab:	85 c0                	test   %eax,%eax
801045ad:	74 f3                	je     801045a2 <startothers+0xb5>
801045af:	eb 01                	jmp    801045b2 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801045b1:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801045b2:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801045b9:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801045be:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801045c4:	05 80 38 11 80       	add    $0x80113880,%eax
801045c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801045cc:	0f 87 57 ff ff ff    	ja     80104529 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801045d2:	90                   	nop
801045d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045d6:	c9                   	leave  
801045d7:	c3                   	ret    

801045d8 <p2v>:
801045d8:	55                   	push   %ebp
801045d9:	89 e5                	mov    %esp,%ebp
801045db:	8b 45 08             	mov    0x8(%ebp),%eax
801045de:	05 00 00 00 80       	add    $0x80000000,%eax
801045e3:	5d                   	pop    %ebp
801045e4:	c3                   	ret    

801045e5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045e5:	55                   	push   %ebp
801045e6:	89 e5                	mov    %esp,%ebp
801045e8:	83 ec 14             	sub    $0x14,%esp
801045eb:	8b 45 08             	mov    0x8(%ebp),%eax
801045ee:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045f2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045f6:	89 c2                	mov    %eax,%edx
801045f8:	ec                   	in     (%dx),%al
801045f9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045fc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80104600:	c9                   	leave  
80104601:	c3                   	ret    

80104602 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104602:	55                   	push   %ebp
80104603:	89 e5                	mov    %esp,%ebp
80104605:	83 ec 08             	sub    $0x8,%esp
80104608:	8b 55 08             	mov    0x8(%ebp),%edx
8010460b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010460e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104612:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104615:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104619:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010461d:	ee                   	out    %al,(%dx)
}
8010461e:	90                   	nop
8010461f:	c9                   	leave  
80104620:	c3                   	ret    

80104621 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80104621:	55                   	push   %ebp
80104622:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104624:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104629:	89 c2                	mov    %eax,%edx
8010462b:	b8 80 38 11 80       	mov    $0x80113880,%eax
80104630:	29 c2                	sub    %eax,%edx
80104632:	89 d0                	mov    %edx,%eax
80104634:	c1 f8 02             	sar    $0x2,%eax
80104637:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010463d:	5d                   	pop    %ebp
8010463e:	c3                   	ret    

8010463f <sum>:

static uchar
sum(uchar *addr, int len)
{
8010463f:	55                   	push   %ebp
80104640:	89 e5                	mov    %esp,%ebp
80104642:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104645:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010464c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104653:	eb 15                	jmp    8010466a <sum+0x2b>
    sum += addr[i];
80104655:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104658:	8b 45 08             	mov    0x8(%ebp),%eax
8010465b:	01 d0                	add    %edx,%eax
8010465d:	0f b6 00             	movzbl (%eax),%eax
80104660:	0f b6 c0             	movzbl %al,%eax
80104663:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104666:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010466a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010466d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104670:	7c e3                	jl     80104655 <sum+0x16>
    sum += addr[i];
  return sum;
80104672:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104675:	c9                   	leave  
80104676:	c3                   	ret    

80104677 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104677:	55                   	push   %ebp
80104678:	89 e5                	mov    %esp,%ebp
8010467a:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010467d:	ff 75 08             	pushl  0x8(%ebp)
80104680:	e8 53 ff ff ff       	call   801045d8 <p2v>
80104685:	83 c4 04             	add    $0x4,%esp
80104688:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010468b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010468e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104691:	01 d0                	add    %edx,%eax
80104693:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104699:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010469c:	eb 36                	jmp    801046d4 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010469e:	83 ec 04             	sub    $0x4,%esp
801046a1:	6a 04                	push   $0x4
801046a3:	68 00 98 10 80       	push   $0x80109800
801046a8:	ff 75 f4             	pushl  -0xc(%ebp)
801046ab:	e8 b1 17 00 00       	call   80105e61 <memcmp>
801046b0:	83 c4 10             	add    $0x10,%esp
801046b3:	85 c0                	test   %eax,%eax
801046b5:	75 19                	jne    801046d0 <mpsearch1+0x59>
801046b7:	83 ec 08             	sub    $0x8,%esp
801046ba:	6a 10                	push   $0x10
801046bc:	ff 75 f4             	pushl  -0xc(%ebp)
801046bf:	e8 7b ff ff ff       	call   8010463f <sum>
801046c4:	83 c4 10             	add    $0x10,%esp
801046c7:	84 c0                	test   %al,%al
801046c9:	75 05                	jne    801046d0 <mpsearch1+0x59>
      return (struct mp*)p;
801046cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ce:	eb 11                	jmp    801046e1 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801046d0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046da:	72 c2                	jb     8010469e <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801046dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046e1:	c9                   	leave  
801046e2:	c3                   	ret    

801046e3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046e3:	55                   	push   %ebp
801046e4:	89 e5                	mov    %esp,%ebp
801046e6:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046e9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f3:	83 c0 0f             	add    $0xf,%eax
801046f6:	0f b6 00             	movzbl (%eax),%eax
801046f9:	0f b6 c0             	movzbl %al,%eax
801046fc:	c1 e0 08             	shl    $0x8,%eax
801046ff:	89 c2                	mov    %eax,%edx
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	83 c0 0e             	add    $0xe,%eax
80104707:	0f b6 00             	movzbl (%eax),%eax
8010470a:	0f b6 c0             	movzbl %al,%eax
8010470d:	09 d0                	or     %edx,%eax
8010470f:	c1 e0 04             	shl    $0x4,%eax
80104712:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104715:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104719:	74 21                	je     8010473c <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010471b:	83 ec 08             	sub    $0x8,%esp
8010471e:	68 00 04 00 00       	push   $0x400
80104723:	ff 75 f0             	pushl  -0x10(%ebp)
80104726:	e8 4c ff ff ff       	call   80104677 <mpsearch1>
8010472b:	83 c4 10             	add    $0x10,%esp
8010472e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104731:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104735:	74 51                	je     80104788 <mpsearch+0xa5>
      return mp;
80104737:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010473a:	eb 61                	jmp    8010479d <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473f:	83 c0 14             	add    $0x14,%eax
80104742:	0f b6 00             	movzbl (%eax),%eax
80104745:	0f b6 c0             	movzbl %al,%eax
80104748:	c1 e0 08             	shl    $0x8,%eax
8010474b:	89 c2                	mov    %eax,%edx
8010474d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104750:	83 c0 13             	add    $0x13,%eax
80104753:	0f b6 00             	movzbl (%eax),%eax
80104756:	0f b6 c0             	movzbl %al,%eax
80104759:	09 d0                	or     %edx,%eax
8010475b:	c1 e0 0a             	shl    $0xa,%eax
8010475e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104761:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104764:	2d 00 04 00 00       	sub    $0x400,%eax
80104769:	83 ec 08             	sub    $0x8,%esp
8010476c:	68 00 04 00 00       	push   $0x400
80104771:	50                   	push   %eax
80104772:	e8 00 ff ff ff       	call   80104677 <mpsearch1>
80104777:	83 c4 10             	add    $0x10,%esp
8010477a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010477d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104781:	74 05                	je     80104788 <mpsearch+0xa5>
      return mp;
80104783:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104786:	eb 15                	jmp    8010479d <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104788:	83 ec 08             	sub    $0x8,%esp
8010478b:	68 00 00 01 00       	push   $0x10000
80104790:	68 00 00 0f 00       	push   $0xf0000
80104795:	e8 dd fe ff ff       	call   80104677 <mpsearch1>
8010479a:	83 c4 10             	add    $0x10,%esp
}
8010479d:	c9                   	leave  
8010479e:	c3                   	ret    

8010479f <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010479f:	55                   	push   %ebp
801047a0:	89 e5                	mov    %esp,%ebp
801047a2:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801047a5:	e8 39 ff ff ff       	call   801046e3 <mpsearch>
801047aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047b1:	74 0a                	je     801047bd <mpconfig+0x1e>
801047b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b6:	8b 40 04             	mov    0x4(%eax),%eax
801047b9:	85 c0                	test   %eax,%eax
801047bb:	75 0a                	jne    801047c7 <mpconfig+0x28>
    return 0;
801047bd:	b8 00 00 00 00       	mov    $0x0,%eax
801047c2:	e9 81 00 00 00       	jmp    80104848 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801047c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ca:	8b 40 04             	mov    0x4(%eax),%eax
801047cd:	83 ec 0c             	sub    $0xc,%esp
801047d0:	50                   	push   %eax
801047d1:	e8 02 fe ff ff       	call   801045d8 <p2v>
801047d6:	83 c4 10             	add    $0x10,%esp
801047d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801047dc:	83 ec 04             	sub    $0x4,%esp
801047df:	6a 04                	push   $0x4
801047e1:	68 05 98 10 80       	push   $0x80109805
801047e6:	ff 75 f0             	pushl  -0x10(%ebp)
801047e9:	e8 73 16 00 00       	call   80105e61 <memcmp>
801047ee:	83 c4 10             	add    $0x10,%esp
801047f1:	85 c0                	test   %eax,%eax
801047f3:	74 07                	je     801047fc <mpconfig+0x5d>
    return 0;
801047f5:	b8 00 00 00 00       	mov    $0x0,%eax
801047fa:	eb 4c                	jmp    80104848 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ff:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104803:	3c 01                	cmp    $0x1,%al
80104805:	74 12                	je     80104819 <mpconfig+0x7a>
80104807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010480a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010480e:	3c 04                	cmp    $0x4,%al
80104810:	74 07                	je     80104819 <mpconfig+0x7a>
    return 0;
80104812:	b8 00 00 00 00       	mov    $0x0,%eax
80104817:	eb 2f                	jmp    80104848 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010481c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104820:	0f b7 c0             	movzwl %ax,%eax
80104823:	83 ec 08             	sub    $0x8,%esp
80104826:	50                   	push   %eax
80104827:	ff 75 f0             	pushl  -0x10(%ebp)
8010482a:	e8 10 fe ff ff       	call   8010463f <sum>
8010482f:	83 c4 10             	add    $0x10,%esp
80104832:	84 c0                	test   %al,%al
80104834:	74 07                	je     8010483d <mpconfig+0x9e>
    return 0;
80104836:	b8 00 00 00 00       	mov    $0x0,%eax
8010483b:	eb 0b                	jmp    80104848 <mpconfig+0xa9>
  *pmp = mp;
8010483d:	8b 45 08             	mov    0x8(%ebp),%eax
80104840:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104843:	89 10                	mov    %edx,(%eax)
  return conf;
80104845:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104848:	c9                   	leave  
80104849:	c3                   	ret    

8010484a <mpinit>:

void
mpinit(void)
{
8010484a:	55                   	push   %ebp
8010484b:	89 e5                	mov    %esp,%ebp
8010484d:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104850:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
80104857:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010485a:	83 ec 0c             	sub    $0xc,%esp
8010485d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104860:	50                   	push   %eax
80104861:	e8 39 ff ff ff       	call   8010479f <mpconfig>
80104866:	83 c4 10             	add    $0x10,%esp
80104869:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010486c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104870:	0f 84 96 01 00 00    	je     80104a0c <mpinit+0x1c2>
    return;
  ismp = 1;
80104876:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
8010487d:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104883:	8b 40 24             	mov    0x24(%eax),%eax
80104886:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010488b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010488e:	83 c0 2c             	add    $0x2c,%eax
80104891:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104897:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010489b:	0f b7 d0             	movzwl %ax,%edx
8010489e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a1:	01 d0                	add    %edx,%eax
801048a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801048a6:	e9 f2 00 00 00       	jmp    8010499d <mpinit+0x153>
    switch(*p){
801048ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ae:	0f b6 00             	movzbl (%eax),%eax
801048b1:	0f b6 c0             	movzbl %al,%eax
801048b4:	83 f8 04             	cmp    $0x4,%eax
801048b7:	0f 87 bc 00 00 00    	ja     80104979 <mpinit+0x12f>
801048bd:	8b 04 85 48 98 10 80 	mov    -0x7fef67b8(,%eax,4),%eax
801048c4:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801048cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048cf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048d3:	0f b6 d0             	movzbl %al,%edx
801048d6:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048db:	39 c2                	cmp    %eax,%edx
801048dd:	74 2b                	je     8010490a <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048e2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048e6:	0f b6 d0             	movzbl %al,%edx
801048e9:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048ee:	83 ec 04             	sub    $0x4,%esp
801048f1:	52                   	push   %edx
801048f2:	50                   	push   %eax
801048f3:	68 0a 98 10 80       	push   $0x8010980a
801048f8:	e8 c9 ba ff ff       	call   801003c6 <cprintf>
801048fd:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80104900:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
80104907:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010490a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010490d:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104911:	0f b6 c0             	movzbl %al,%eax
80104914:	83 e0 02             	and    $0x2,%eax
80104917:	85 c0                	test   %eax,%eax
80104919:	74 15                	je     80104930 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
8010491b:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104920:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104926:	05 80 38 11 80       	add    $0x80113880,%eax
8010492b:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104930:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104935:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
8010493b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104941:	05 80 38 11 80       	add    $0x80113880,%eax
80104946:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104948:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010494d:	83 c0 01             	add    $0x1,%eax
80104950:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
80104955:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104959:	eb 42                	jmp    8010499d <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104961:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104964:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104968:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
8010496d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104971:	eb 2a                	jmp    8010499d <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104973:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104977:	eb 24                	jmp    8010499d <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497c:	0f b6 00             	movzbl (%eax),%eax
8010497f:	0f b6 c0             	movzbl %al,%eax
80104982:	83 ec 08             	sub    $0x8,%esp
80104985:	50                   	push   %eax
80104986:	68 28 98 10 80       	push   $0x80109828
8010498b:	e8 36 ba ff ff       	call   801003c6 <cprintf>
80104990:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104993:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
8010499a:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801049a3:	0f 82 02 ff ff ff    	jb     801048ab <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801049a9:	a1 64 38 11 80       	mov    0x80113864,%eax
801049ae:	85 c0                	test   %eax,%eax
801049b0:	75 1d                	jne    801049cf <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801049b2:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
801049b9:	00 00 00 
    lapic = 0;
801049bc:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
801049c3:	00 00 00 
    ioapicid = 0;
801049c6:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
801049cd:	eb 3e                	jmp    80104a0d <mpinit+0x1c3>
  }

  if(mp->imcrp){
801049cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049d2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801049d6:	84 c0                	test   %al,%al
801049d8:	74 33                	je     80104a0d <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801049da:	83 ec 08             	sub    $0x8,%esp
801049dd:	6a 70                	push   $0x70
801049df:	6a 22                	push   $0x22
801049e1:	e8 1c fc ff ff       	call   80104602 <outb>
801049e6:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049e9:	83 ec 0c             	sub    $0xc,%esp
801049ec:	6a 23                	push   $0x23
801049ee:	e8 f2 fb ff ff       	call   801045e5 <inb>
801049f3:	83 c4 10             	add    $0x10,%esp
801049f6:	83 c8 01             	or     $0x1,%eax
801049f9:	0f b6 c0             	movzbl %al,%eax
801049fc:	83 ec 08             	sub    $0x8,%esp
801049ff:	50                   	push   %eax
80104a00:	6a 23                	push   $0x23
80104a02:	e8 fb fb ff ff       	call   80104602 <outb>
80104a07:	83 c4 10             	add    $0x10,%esp
80104a0a:	eb 01                	jmp    80104a0d <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104a0c:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104a0d:	c9                   	leave  
80104a0e:	c3                   	ret    

80104a0f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104a0f:	55                   	push   %ebp
80104a10:	89 e5                	mov    %esp,%ebp
80104a12:	83 ec 08             	sub    $0x8,%esp
80104a15:	8b 55 08             	mov    0x8(%ebp),%edx
80104a18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a1b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104a1f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104a22:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104a26:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104a2a:	ee                   	out    %al,(%dx)
}
80104a2b:	90                   	nop
80104a2c:	c9                   	leave  
80104a2d:	c3                   	ret    

80104a2e <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104a2e:	55                   	push   %ebp
80104a2f:	89 e5                	mov    %esp,%ebp
80104a31:	83 ec 04             	sub    $0x4,%esp
80104a34:	8b 45 08             	mov    0x8(%ebp),%eax
80104a37:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104a3b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a3f:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a45:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a49:	0f b6 c0             	movzbl %al,%eax
80104a4c:	50                   	push   %eax
80104a4d:	6a 21                	push   $0x21
80104a4f:	e8 bb ff ff ff       	call   80104a0f <outb>
80104a54:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a57:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a5b:	66 c1 e8 08          	shr    $0x8,%ax
80104a5f:	0f b6 c0             	movzbl %al,%eax
80104a62:	50                   	push   %eax
80104a63:	68 a1 00 00 00       	push   $0xa1
80104a68:	e8 a2 ff ff ff       	call   80104a0f <outb>
80104a6d:	83 c4 08             	add    $0x8,%esp
}
80104a70:	90                   	nop
80104a71:	c9                   	leave  
80104a72:	c3                   	ret    

80104a73 <picenable>:

void
picenable(int irq)
{
80104a73:	55                   	push   %ebp
80104a74:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a76:	8b 45 08             	mov    0x8(%ebp),%eax
80104a79:	ba 01 00 00 00       	mov    $0x1,%edx
80104a7e:	89 c1                	mov    %eax,%ecx
80104a80:	d3 e2                	shl    %cl,%edx
80104a82:	89 d0                	mov    %edx,%eax
80104a84:	f7 d0                	not    %eax
80104a86:	89 c2                	mov    %eax,%edx
80104a88:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a8f:	21 d0                	and    %edx,%eax
80104a91:	0f b7 c0             	movzwl %ax,%eax
80104a94:	50                   	push   %eax
80104a95:	e8 94 ff ff ff       	call   80104a2e <picsetmask>
80104a9a:	83 c4 04             	add    $0x4,%esp
}
80104a9d:	90                   	nop
80104a9e:	c9                   	leave  
80104a9f:	c3                   	ret    

80104aa0 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104aa3:	68 ff 00 00 00       	push   $0xff
80104aa8:	6a 21                	push   $0x21
80104aaa:	e8 60 ff ff ff       	call   80104a0f <outb>
80104aaf:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104ab2:	68 ff 00 00 00       	push   $0xff
80104ab7:	68 a1 00 00 00       	push   $0xa1
80104abc:	e8 4e ff ff ff       	call   80104a0f <outb>
80104ac1:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104ac4:	6a 11                	push   $0x11
80104ac6:	6a 20                	push   $0x20
80104ac8:	e8 42 ff ff ff       	call   80104a0f <outb>
80104acd:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104ad0:	6a 20                	push   $0x20
80104ad2:	6a 21                	push   $0x21
80104ad4:	e8 36 ff ff ff       	call   80104a0f <outb>
80104ad9:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104adc:	6a 04                	push   $0x4
80104ade:	6a 21                	push   $0x21
80104ae0:	e8 2a ff ff ff       	call   80104a0f <outb>
80104ae5:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104ae8:	6a 03                	push   $0x3
80104aea:	6a 21                	push   $0x21
80104aec:	e8 1e ff ff ff       	call   80104a0f <outb>
80104af1:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104af4:	6a 11                	push   $0x11
80104af6:	68 a0 00 00 00       	push   $0xa0
80104afb:	e8 0f ff ff ff       	call   80104a0f <outb>
80104b00:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104b03:	6a 28                	push   $0x28
80104b05:	68 a1 00 00 00       	push   $0xa1
80104b0a:	e8 00 ff ff ff       	call   80104a0f <outb>
80104b0f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104b12:	6a 02                	push   $0x2
80104b14:	68 a1 00 00 00       	push   $0xa1
80104b19:	e8 f1 fe ff ff       	call   80104a0f <outb>
80104b1e:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104b21:	6a 03                	push   $0x3
80104b23:	68 a1 00 00 00       	push   $0xa1
80104b28:	e8 e2 fe ff ff       	call   80104a0f <outb>
80104b2d:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104b30:	6a 68                	push   $0x68
80104b32:	6a 20                	push   $0x20
80104b34:	e8 d6 fe ff ff       	call   80104a0f <outb>
80104b39:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104b3c:	6a 0a                	push   $0xa
80104b3e:	6a 20                	push   $0x20
80104b40:	e8 ca fe ff ff       	call   80104a0f <outb>
80104b45:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b48:	6a 68                	push   $0x68
80104b4a:	68 a0 00 00 00       	push   $0xa0
80104b4f:	e8 bb fe ff ff       	call   80104a0f <outb>
80104b54:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b57:	6a 0a                	push   $0xa
80104b59:	68 a0 00 00 00       	push   $0xa0
80104b5e:	e8 ac fe ff ff       	call   80104a0f <outb>
80104b63:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b66:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b6d:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b71:	74 13                	je     80104b86 <picinit+0xe6>
    picsetmask(irqmask);
80104b73:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b7a:	0f b7 c0             	movzwl %ax,%eax
80104b7d:	50                   	push   %eax
80104b7e:	e8 ab fe ff ff       	call   80104a2e <picsetmask>
80104b83:	83 c4 04             	add    $0x4,%esp
}
80104b86:	90                   	nop
80104b87:	c9                   	leave  
80104b88:	c3                   	ret    

80104b89 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b89:	55                   	push   %ebp
80104b8a:	89 e5                	mov    %esp,%ebp
80104b8c:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b96:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba2:	8b 10                	mov    (%eax),%edx
80104ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba7:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104ba9:	e8 3d c4 ff ff       	call   80100feb <filealloc>
80104bae:	89 c2                	mov    %eax,%edx
80104bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb3:	89 10                	mov    %edx,(%eax)
80104bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb8:	8b 00                	mov    (%eax),%eax
80104bba:	85 c0                	test   %eax,%eax
80104bbc:	0f 84 cb 00 00 00    	je     80104c8d <pipealloc+0x104>
80104bc2:	e8 24 c4 ff ff       	call   80100feb <filealloc>
80104bc7:	89 c2                	mov    %eax,%edx
80104bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bcc:	89 10                	mov    %edx,(%eax)
80104bce:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd1:	8b 00                	mov    (%eax),%eax
80104bd3:	85 c0                	test   %eax,%eax
80104bd5:	0f 84 b2 00 00 00    	je     80104c8d <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104bdb:	e8 a2 e8 ff ff       	call   80103482 <kalloc>
80104be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104be3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104be7:	0f 84 9f 00 00 00    	je     80104c8c <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104bf7:	00 00 00 
  p->writeopen = 1;
80104bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104c04:	00 00 00 
  p->nwrite = 0;
80104c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104c11:	00 00 00 
  p->nread = 0;
80104c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c17:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104c1e:	00 00 00 
  initlock(&p->lock, "pipe");
80104c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c24:	83 ec 08             	sub    $0x8,%esp
80104c27:	68 5c 98 10 80       	push   $0x8010985c
80104c2c:	50                   	push   %eax
80104c2d:	e8 43 0f 00 00       	call   80105b75 <initlock>
80104c32:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104c35:	8b 45 08             	mov    0x8(%ebp),%eax
80104c38:	8b 00                	mov    (%eax),%eax
80104c3a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	8b 00                	mov    (%eax),%eax
80104c45:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c49:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4c:	8b 00                	mov    (%eax),%eax
80104c4e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c52:	8b 45 08             	mov    0x8(%ebp),%eax
80104c55:	8b 00                	mov    (%eax),%eax
80104c57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c5a:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c60:	8b 00                	mov    (%eax),%eax
80104c62:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c68:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c6b:	8b 00                	mov    (%eax),%eax
80104c6d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c74:	8b 00                	mov    (%eax),%eax
80104c76:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c7d:	8b 00                	mov    (%eax),%eax
80104c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c82:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c85:	b8 00 00 00 00       	mov    $0x0,%eax
80104c8a:	eb 4e                	jmp    80104cda <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c8c:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c91:	74 0e                	je     80104ca1 <pipealloc+0x118>
    kfree((char*)p);
80104c93:	83 ec 0c             	sub    $0xc,%esp
80104c96:	ff 75 f4             	pushl  -0xc(%ebp)
80104c99:	e8 47 e7 ff ff       	call   801033e5 <kfree>
80104c9e:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca4:	8b 00                	mov    (%eax),%eax
80104ca6:	85 c0                	test   %eax,%eax
80104ca8:	74 11                	je     80104cbb <pipealloc+0x132>
    fileclose(*f0);
80104caa:	8b 45 08             	mov    0x8(%ebp),%eax
80104cad:	8b 00                	mov    (%eax),%eax
80104caf:	83 ec 0c             	sub    $0xc,%esp
80104cb2:	50                   	push   %eax
80104cb3:	e8 f1 c3 ff ff       	call   801010a9 <fileclose>
80104cb8:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cbe:	8b 00                	mov    (%eax),%eax
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	74 11                	je     80104cd5 <pipealloc+0x14c>
    fileclose(*f1);
80104cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cc7:	8b 00                	mov    (%eax),%eax
80104cc9:	83 ec 0c             	sub    $0xc,%esp
80104ccc:	50                   	push   %eax
80104ccd:	e8 d7 c3 ff ff       	call   801010a9 <fileclose>
80104cd2:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cda:	c9                   	leave  
80104cdb:	c3                   	ret    

80104cdc <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104cdc:	55                   	push   %ebp
80104cdd:	89 e5                	mov    %esp,%ebp
80104cdf:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce5:	83 ec 0c             	sub    $0xc,%esp
80104ce8:	50                   	push   %eax
80104ce9:	e8 a9 0e 00 00       	call   80105b97 <acquire>
80104cee:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104cf1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104cf5:	74 23                	je     80104d1a <pipeclose+0x3e>
    p->writeopen = 0;
80104cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfa:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104d01:	00 00 00 
    wakeup(&p->nread);
80104d04:	8b 45 08             	mov    0x8(%ebp),%eax
80104d07:	05 34 02 00 00       	add    $0x234,%eax
80104d0c:	83 ec 0c             	sub    $0xc,%esp
80104d0f:	50                   	push   %eax
80104d10:	e8 74 0c 00 00       	call   80105989 <wakeup>
80104d15:	83 c4 10             	add    $0x10,%esp
80104d18:	eb 21                	jmp    80104d3b <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104d24:	00 00 00 
    wakeup(&p->nwrite);
80104d27:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2a:	05 38 02 00 00       	add    $0x238,%eax
80104d2f:	83 ec 0c             	sub    $0xc,%esp
80104d32:	50                   	push   %eax
80104d33:	e8 51 0c 00 00       	call   80105989 <wakeup>
80104d38:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d44:	85 c0                	test   %eax,%eax
80104d46:	75 2c                	jne    80104d74 <pipeclose+0x98>
80104d48:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d51:	85 c0                	test   %eax,%eax
80104d53:	75 1f                	jne    80104d74 <pipeclose+0x98>
    release(&p->lock);
80104d55:	8b 45 08             	mov    0x8(%ebp),%eax
80104d58:	83 ec 0c             	sub    $0xc,%esp
80104d5b:	50                   	push   %eax
80104d5c:	e8 9d 0e 00 00       	call   80105bfe <release>
80104d61:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d64:	83 ec 0c             	sub    $0xc,%esp
80104d67:	ff 75 08             	pushl  0x8(%ebp)
80104d6a:	e8 76 e6 ff ff       	call   801033e5 <kfree>
80104d6f:	83 c4 10             	add    $0x10,%esp
80104d72:	eb 0f                	jmp    80104d83 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d74:	8b 45 08             	mov    0x8(%ebp),%eax
80104d77:	83 ec 0c             	sub    $0xc,%esp
80104d7a:	50                   	push   %eax
80104d7b:	e8 7e 0e 00 00       	call   80105bfe <release>
80104d80:	83 c4 10             	add    $0x10,%esp
}
80104d83:	90                   	nop
80104d84:	c9                   	leave  
80104d85:	c3                   	ret    

80104d86 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d86:	55                   	push   %ebp
80104d87:	89 e5                	mov    %esp,%ebp
80104d89:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8f:	83 ec 0c             	sub    $0xc,%esp
80104d92:	50                   	push   %eax
80104d93:	e8 ff 0d 00 00       	call   80105b97 <acquire>
80104d98:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104da2:	e9 ad 00 00 00       	jmp    80104e54 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104da7:	8b 45 08             	mov    0x8(%ebp),%eax
80104daa:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104db0:	85 c0                	test   %eax,%eax
80104db2:	74 0d                	je     80104dc1 <pipewrite+0x3b>
80104db4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dba:	8b 40 24             	mov    0x24(%eax),%eax
80104dbd:	85 c0                	test   %eax,%eax
80104dbf:	74 19                	je     80104dda <pipewrite+0x54>
        release(&p->lock);
80104dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc4:	83 ec 0c             	sub    $0xc,%esp
80104dc7:	50                   	push   %eax
80104dc8:	e8 31 0e 00 00       	call   80105bfe <release>
80104dcd:	83 c4 10             	add    $0x10,%esp
        return -1;
80104dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd5:	e9 a8 00 00 00       	jmp    80104e82 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104dda:	8b 45 08             	mov    0x8(%ebp),%eax
80104ddd:	05 34 02 00 00       	add    $0x234,%eax
80104de2:	83 ec 0c             	sub    $0xc,%esp
80104de5:	50                   	push   %eax
80104de6:	e8 9e 0b 00 00       	call   80105989 <wakeup>
80104deb:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104dee:	8b 45 08             	mov    0x8(%ebp),%eax
80104df1:	8b 55 08             	mov    0x8(%ebp),%edx
80104df4:	81 c2 38 02 00 00    	add    $0x238,%edx
80104dfa:	83 ec 08             	sub    $0x8,%esp
80104dfd:	50                   	push   %eax
80104dfe:	52                   	push   %edx
80104dff:	e8 9a 0a 00 00       	call   8010589e <sleep>
80104e04:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104e07:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0a:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104e10:	8b 45 08             	mov    0x8(%ebp),%eax
80104e13:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104e19:	05 00 02 00 00       	add    $0x200,%eax
80104e1e:	39 c2                	cmp    %eax,%edx
80104e20:	74 85                	je     80104da7 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104e22:	8b 45 08             	mov    0x8(%ebp),%eax
80104e25:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e2b:	8d 48 01             	lea    0x1(%eax),%ecx
80104e2e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e31:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104e37:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e3c:	89 c1                	mov    %eax,%ecx
80104e3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e44:	01 d0                	add    %edx,%eax
80104e46:	0f b6 10             	movzbl (%eax),%edx
80104e49:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e50:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e57:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e5a:	7c ab                	jl     80104e07 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5f:	05 34 02 00 00       	add    $0x234,%eax
80104e64:	83 ec 0c             	sub    $0xc,%esp
80104e67:	50                   	push   %eax
80104e68:	e8 1c 0b 00 00       	call   80105989 <wakeup>
80104e6d:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e70:	8b 45 08             	mov    0x8(%ebp),%eax
80104e73:	83 ec 0c             	sub    $0xc,%esp
80104e76:	50                   	push   %eax
80104e77:	e8 82 0d 00 00       	call   80105bfe <release>
80104e7c:	83 c4 10             	add    $0x10,%esp
  return n;
80104e7f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e82:	c9                   	leave  
80104e83:	c3                   	ret    

80104e84 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e84:	55                   	push   %ebp
80104e85:	89 e5                	mov    %esp,%ebp
80104e87:	53                   	push   %ebx
80104e88:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8e:	83 ec 0c             	sub    $0xc,%esp
80104e91:	50                   	push   %eax
80104e92:	e8 00 0d 00 00       	call   80105b97 <acquire>
80104e97:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e9a:	eb 3f                	jmp    80104edb <piperead+0x57>
    if(proc->killed){
80104e9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea2:	8b 40 24             	mov    0x24(%eax),%eax
80104ea5:	85 c0                	test   %eax,%eax
80104ea7:	74 19                	je     80104ec2 <piperead+0x3e>
      release(&p->lock);
80104ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80104eac:	83 ec 0c             	sub    $0xc,%esp
80104eaf:	50                   	push   %eax
80104eb0:	e8 49 0d 00 00       	call   80105bfe <release>
80104eb5:	83 c4 10             	add    $0x10,%esp
      return -1;
80104eb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ebd:	e9 bf 00 00 00       	jmp    80104f81 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec5:	8b 55 08             	mov    0x8(%ebp),%edx
80104ec8:	81 c2 34 02 00 00    	add    $0x234,%edx
80104ece:	83 ec 08             	sub    $0x8,%esp
80104ed1:	50                   	push   %eax
80104ed2:	52                   	push   %edx
80104ed3:	e8 c6 09 00 00       	call   8010589e <sleep>
80104ed8:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104edb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ede:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104eed:	39 c2                	cmp    %eax,%edx
80104eef:	75 0d                	jne    80104efe <piperead+0x7a>
80104ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104efa:	85 c0                	test   %eax,%eax
80104efc:	75 9e                	jne    80104e9c <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104efe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f05:	eb 49                	jmp    80104f50 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104f07:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104f10:	8b 45 08             	mov    0x8(%ebp),%eax
80104f13:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104f19:	39 c2                	cmp    %eax,%edx
80104f1b:	74 3d                	je     80104f5a <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104f1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f20:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f23:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104f26:	8b 45 08             	mov    0x8(%ebp),%eax
80104f29:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104f2f:	8d 48 01             	lea    0x1(%eax),%ecx
80104f32:	8b 55 08             	mov    0x8(%ebp),%edx
80104f35:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104f3b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f40:	89 c2                	mov    %eax,%edx
80104f42:	8b 45 08             	mov    0x8(%ebp),%eax
80104f45:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f4a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f4c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f56:	7c af                	jl     80104f07 <piperead+0x83>
80104f58:	eb 01                	jmp    80104f5b <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f5a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5e:	05 38 02 00 00       	add    $0x238,%eax
80104f63:	83 ec 0c             	sub    $0xc,%esp
80104f66:	50                   	push   %eax
80104f67:	e8 1d 0a 00 00       	call   80105989 <wakeup>
80104f6c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f72:	83 ec 0c             	sub    $0xc,%esp
80104f75:	50                   	push   %eax
80104f76:	e8 83 0c 00 00       	call   80105bfe <release>
80104f7b:	83 c4 10             	add    $0x10,%esp
  return i;
80104f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f84:	c9                   	leave  
80104f85:	c3                   	ret    

80104f86 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f86:	55                   	push   %ebp
80104f87:	89 e5                	mov    %esp,%ebp
80104f89:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f8c:	9c                   	pushf  
80104f8d:	58                   	pop    %eax
80104f8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f91:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f94:	c9                   	leave  
80104f95:	c3                   	ret    

80104f96 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f96:	55                   	push   %ebp
80104f97:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f99:	fb                   	sti    
}
80104f9a:	90                   	nop
80104f9b:	5d                   	pop    %ebp
80104f9c:	c3                   	ret    

80104f9d <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f9d:	55                   	push   %ebp
80104f9e:	89 e5                	mov    %esp,%ebp
80104fa0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104fa3:	83 ec 08             	sub    $0x8,%esp
80104fa6:	68 61 98 10 80       	push   $0x80109861
80104fab:	68 80 3e 11 80       	push   $0x80113e80
80104fb0:	e8 c0 0b 00 00       	call   80105b75 <initlock>
80104fb5:	83 c4 10             	add    $0x10,%esp
}
80104fb8:	90                   	nop
80104fb9:	c9                   	leave  
80104fba:	c3                   	ret    

80104fbb <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104fbb:	55                   	push   %ebp
80104fbc:	89 e5                	mov    %esp,%ebp
80104fbe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104fc1:	83 ec 0c             	sub    $0xc,%esp
80104fc4:	68 80 3e 11 80       	push   $0x80113e80
80104fc9:	e8 c9 0b 00 00       	call   80105b97 <acquire>
80104fce:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fd1:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104fd8:	eb 0e                	jmp    80104fe8 <allocproc+0x2d>
    if(p->state == UNUSED)
80104fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdd:	8b 40 0c             	mov    0xc(%eax),%eax
80104fe0:	85 c0                	test   %eax,%eax
80104fe2:	74 27                	je     8010500b <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fe4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fe8:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fef:	72 e9                	jb     80104fda <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104ff1:	83 ec 0c             	sub    $0xc,%esp
80104ff4:	68 80 3e 11 80       	push   $0x80113e80
80104ff9:	e8 00 0c 00 00       	call   80105bfe <release>
80104ffe:	83 c4 10             	add    $0x10,%esp
  return 0;
80105001:	b8 00 00 00 00       	mov    $0x0,%eax
80105006:	e9 b4 00 00 00       	jmp    801050bf <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010500b:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010500c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80105016:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010501b:	8d 50 01             	lea    0x1(%eax),%edx
8010501e:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80105024:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105027:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010502a:	83 ec 0c             	sub    $0xc,%esp
8010502d:	68 80 3e 11 80       	push   $0x80113e80
80105032:	e8 c7 0b 00 00       	call   80105bfe <release>
80105037:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010503a:	e8 43 e4 ff ff       	call   80103482 <kalloc>
8010503f:	89 c2                	mov    %eax,%edx
80105041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105044:	89 50 08             	mov    %edx,0x8(%eax)
80105047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504a:	8b 40 08             	mov    0x8(%eax),%eax
8010504d:	85 c0                	test   %eax,%eax
8010504f:	75 11                	jne    80105062 <allocproc+0xa7>
    p->state = UNUSED;
80105051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105054:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010505b:	b8 00 00 00 00       	mov    $0x0,%eax
80105060:	eb 5d                	jmp    801050bf <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80105062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105065:	8b 40 08             	mov    0x8(%eax),%eax
80105068:	05 00 10 00 00       	add    $0x1000,%eax
8010506d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105070:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80105074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105077:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010507a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010507d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80105081:	ba 73 75 10 80       	mov    $0x80107573,%edx
80105086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105089:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010508b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010508f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105092:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105095:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80105098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010509e:	83 ec 04             	sub    $0x4,%esp
801050a1:	6a 14                	push   $0x14
801050a3:	6a 00                	push   $0x0
801050a5:	50                   	push   %eax
801050a6:	e8 4f 0d 00 00       	call   80105dfa <memset>
801050ab:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801050ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b1:	8b 40 1c             	mov    0x1c(%eax),%eax
801050b4:	ba 34 58 10 80       	mov    $0x80105834,%edx
801050b9:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801050bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801050bf:	c9                   	leave  
801050c0:	c3                   	ret    

801050c1 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801050c1:	55                   	push   %ebp
801050c2:	89 e5                	mov    %esp,%ebp
801050c4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801050c7:	e8 ef fe ff ff       	call   80104fbb <allocproc>
801050cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801050cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d2:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801050d7:	e8 5c 3b 00 00       	call   80108c38 <setupkvm>
801050dc:	89 c2                	mov    %eax,%edx
801050de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e1:	89 50 04             	mov    %edx,0x4(%eax)
801050e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e7:	8b 40 04             	mov    0x4(%eax),%eax
801050ea:	85 c0                	test   %eax,%eax
801050ec:	75 0d                	jne    801050fb <userinit+0x3a>
    panic("userinit: out of memory?");
801050ee:	83 ec 0c             	sub    $0xc,%esp
801050f1:	68 68 98 10 80       	push   $0x80109868
801050f6:	e8 6b b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050fb:	ba 2c 00 00 00       	mov    $0x2c,%edx
80105100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105103:	8b 40 04             	mov    0x4(%eax),%eax
80105106:	83 ec 04             	sub    $0x4,%esp
80105109:	52                   	push   %edx
8010510a:	68 e0 c4 10 80       	push   $0x8010c4e0
8010510f:	50                   	push   %eax
80105110:	e8 7d 3d 00 00       	call   80108e92 <inituvm>
80105115:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80105118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80105121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105124:	8b 40 18             	mov    0x18(%eax),%eax
80105127:	83 ec 04             	sub    $0x4,%esp
8010512a:	6a 4c                	push   $0x4c
8010512c:	6a 00                	push   $0x0
8010512e:	50                   	push   %eax
8010512f:	e8 c6 0c 00 00       	call   80105dfa <memset>
80105134:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80105137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513a:	8b 40 18             	mov    0x18(%eax),%eax
8010513d:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105146:	8b 40 18             	mov    0x18(%eax),%eax
80105149:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010514f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105152:	8b 40 18             	mov    0x18(%eax),%eax
80105155:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105158:	8b 52 18             	mov    0x18(%edx),%edx
8010515b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010515f:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80105163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105166:	8b 40 18             	mov    0x18(%eax),%eax
80105169:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010516c:	8b 52 18             	mov    0x18(%edx),%edx
8010516f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105173:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80105177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517a:	8b 40 18             	mov    0x18(%eax),%eax
8010517d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80105184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105187:	8b 40 18             	mov    0x18(%eax),%eax
8010518a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80105191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105194:	8b 40 18             	mov    0x18(%eax),%eax
80105197:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010519e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a1:	83 c0 6c             	add    $0x6c,%eax
801051a4:	83 ec 04             	sub    $0x4,%esp
801051a7:	6a 10                	push   $0x10
801051a9:	68 81 98 10 80       	push   $0x80109881
801051ae:	50                   	push   %eax
801051af:	e8 49 0e 00 00       	call   80105ffd <safestrcpy>
801051b4:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801051b7:	83 ec 0c             	sub    $0xc,%esp
801051ba:	68 8a 98 10 80       	push   $0x8010988a
801051bf:	e8 47 db ff ff       	call   80102d0b <namei>
801051c4:	83 c4 10             	add    $0x10,%esp
801051c7:	89 c2                	mov    %eax,%edx
801051c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cc:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
801051cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801051d9:	90                   	nop
801051da:	c9                   	leave  
801051db:	c3                   	ret    

801051dc <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801051dc:	55                   	push   %ebp
801051dd:	89 e5                	mov    %esp,%ebp
801051df:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e8:	8b 00                	mov    (%eax),%eax
801051ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051f1:	7e 31                	jle    80105224 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051f3:	8b 55 08             	mov    0x8(%ebp),%edx
801051f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f9:	01 c2                	add    %eax,%edx
801051fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105201:	8b 40 04             	mov    0x4(%eax),%eax
80105204:	83 ec 04             	sub    $0x4,%esp
80105207:	52                   	push   %edx
80105208:	ff 75 f4             	pushl  -0xc(%ebp)
8010520b:	50                   	push   %eax
8010520c:	e8 ce 3d 00 00       	call   80108fdf <allocuvm>
80105211:	83 c4 10             	add    $0x10,%esp
80105214:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105217:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010521b:	75 3e                	jne    8010525b <growproc+0x7f>
      return -1;
8010521d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105222:	eb 59                	jmp    8010527d <growproc+0xa1>
  } else if(n < 0){
80105224:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105228:	79 31                	jns    8010525b <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010522a:	8b 55 08             	mov    0x8(%ebp),%edx
8010522d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105230:	01 c2                	add    %eax,%edx
80105232:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105238:	8b 40 04             	mov    0x4(%eax),%eax
8010523b:	83 ec 04             	sub    $0x4,%esp
8010523e:	52                   	push   %edx
8010523f:	ff 75 f4             	pushl  -0xc(%ebp)
80105242:	50                   	push   %eax
80105243:	e8 60 3e 00 00       	call   801090a8 <deallocuvm>
80105248:	83 c4 10             	add    $0x10,%esp
8010524b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010524e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105252:	75 07                	jne    8010525b <growproc+0x7f>
      return -1;
80105254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105259:	eb 22                	jmp    8010527d <growproc+0xa1>
  }
  proc->sz = sz;
8010525b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105261:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105264:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80105266:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010526c:	83 ec 0c             	sub    $0xc,%esp
8010526f:	50                   	push   %eax
80105270:	e8 aa 3a 00 00       	call   80108d1f <switchuvm>
80105275:	83 c4 10             	add    $0x10,%esp
  return 0;
80105278:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010527d:	c9                   	leave  
8010527e:	c3                   	ret    

8010527f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010527f:	55                   	push   %ebp
80105280:	89 e5                	mov    %esp,%ebp
80105282:	57                   	push   %edi
80105283:	56                   	push   %esi
80105284:	53                   	push   %ebx
80105285:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80105288:	e8 2e fd ff ff       	call   80104fbb <allocproc>
8010528d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105290:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80105294:	75 0a                	jne    801052a0 <fork+0x21>
    return -1;
80105296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529b:	e9 68 01 00 00       	jmp    80105408 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801052a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052a6:	8b 10                	mov    (%eax),%edx
801052a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ae:	8b 40 04             	mov    0x4(%eax),%eax
801052b1:	83 ec 08             	sub    $0x8,%esp
801052b4:	52                   	push   %edx
801052b5:	50                   	push   %eax
801052b6:	e8 8b 3f 00 00       	call   80109246 <copyuvm>
801052bb:	83 c4 10             	add    $0x10,%esp
801052be:	89 c2                	mov    %eax,%edx
801052c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052c3:	89 50 04             	mov    %edx,0x4(%eax)
801052c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052c9:	8b 40 04             	mov    0x4(%eax),%eax
801052cc:	85 c0                	test   %eax,%eax
801052ce:	75 30                	jne    80105300 <fork+0x81>
    kfree(np->kstack);
801052d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052d3:	8b 40 08             	mov    0x8(%eax),%eax
801052d6:	83 ec 0c             	sub    $0xc,%esp
801052d9:	50                   	push   %eax
801052da:	e8 06 e1 ff ff       	call   801033e5 <kfree>
801052df:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052ef:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fb:	e9 08 01 00 00       	jmp    80105408 <fork+0x189>
  }
  np->sz = proc->sz;
80105300:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105306:	8b 10                	mov    (%eax),%edx
80105308:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010530b:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010530d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105314:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105317:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010531a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010531d:	8b 50 18             	mov    0x18(%eax),%edx
80105320:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105326:	8b 40 18             	mov    0x18(%eax),%eax
80105329:	89 c3                	mov    %eax,%ebx
8010532b:	b8 13 00 00 00       	mov    $0x13,%eax
80105330:	89 d7                	mov    %edx,%edi
80105332:	89 de                	mov    %ebx,%esi
80105334:	89 c1                	mov    %eax,%ecx
80105336:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105338:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010533b:	8b 40 18             	mov    0x18(%eax),%eax
8010533e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105345:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010534c:	eb 43                	jmp    80105391 <fork+0x112>
    if(proc->ofile[i])
8010534e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105354:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105357:	83 c2 08             	add    $0x8,%edx
8010535a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010535e:	85 c0                	test   %eax,%eax
80105360:	74 2b                	je     8010538d <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80105362:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105368:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010536b:	83 c2 08             	add    $0x8,%edx
8010536e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105372:	83 ec 0c             	sub    $0xc,%esp
80105375:	50                   	push   %eax
80105376:	e8 dd bc ff ff       	call   80101058 <filedup>
8010537b:	83 c4 10             	add    $0x10,%esp
8010537e:	89 c1                	mov    %eax,%ecx
80105380:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105386:	83 c2 08             	add    $0x8,%edx
80105389:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010538d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105391:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105395:	7e b7                	jle    8010534e <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105397:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010539d:	8b 40 68             	mov    0x68(%eax),%eax
801053a0:	83 ec 0c             	sub    $0xc,%esp
801053a3:	50                   	push   %eax
801053a4:	e8 0f cb ff ff       	call   80101eb8 <idup>
801053a9:	83 c4 10             	add    $0x10,%esp
801053ac:	89 c2                	mov    %eax,%edx
801053ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053b1:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801053b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ba:	8d 50 6c             	lea    0x6c(%eax),%edx
801053bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053c0:	83 c0 6c             	add    $0x6c,%eax
801053c3:	83 ec 04             	sub    $0x4,%esp
801053c6:	6a 10                	push   $0x10
801053c8:	52                   	push   %edx
801053c9:	50                   	push   %eax
801053ca:	e8 2e 0c 00 00       	call   80105ffd <safestrcpy>
801053cf:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053d5:	8b 40 10             	mov    0x10(%eax),%eax
801053d8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053db:	83 ec 0c             	sub    $0xc,%esp
801053de:	68 80 3e 11 80       	push   $0x80113e80
801053e3:	e8 af 07 00 00       	call   80105b97 <acquire>
801053e8:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053ee:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053f5:	83 ec 0c             	sub    $0xc,%esp
801053f8:	68 80 3e 11 80       	push   $0x80113e80
801053fd:	e8 fc 07 00 00       	call   80105bfe <release>
80105402:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80105405:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105408:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010540b:	5b                   	pop    %ebx
8010540c:	5e                   	pop    %esi
8010540d:	5f                   	pop    %edi
8010540e:	5d                   	pop    %ebp
8010540f:	c3                   	ret    

80105410 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105416:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010541d:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105422:	39 c2                	cmp    %eax,%edx
80105424:	75 0d                	jne    80105433 <exit+0x23>
    panic("init exiting");
80105426:	83 ec 0c             	sub    $0xc,%esp
80105429:	68 8c 98 10 80       	push   $0x8010988c
8010542e:	e8 33 b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105433:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010543a:	eb 48                	jmp    80105484 <exit+0x74>
    if(proc->ofile[fd]){
8010543c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105442:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105445:	83 c2 08             	add    $0x8,%edx
80105448:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010544c:	85 c0                	test   %eax,%eax
8010544e:	74 30                	je     80105480 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105450:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105456:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105459:	83 c2 08             	add    $0x8,%edx
8010545c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105460:	83 ec 0c             	sub    $0xc,%esp
80105463:	50                   	push   %eax
80105464:	e8 40 bc ff ff       	call   801010a9 <fileclose>
80105469:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010546c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105472:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105475:	83 c2 08             	add    $0x8,%edx
80105478:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010547f:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105480:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105484:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105488:	7e b2                	jle    8010543c <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
8010548a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105490:	8b 40 68             	mov    0x68(%eax),%eax
80105493:	8b 40 50             	mov    0x50(%eax),%eax
80105496:	8b 40 14             	mov    0x14(%eax),%eax
80105499:	83 ec 0c             	sub    $0xc,%esp
8010549c:	50                   	push   %eax
8010549d:	e8 17 ea ff ff       	call   80103eb9 <begin_op>
801054a2:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801054a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ab:	8b 40 68             	mov    0x68(%eax),%eax
801054ae:	83 ec 0c             	sub    $0xc,%esp
801054b1:	50                   	push   %eax
801054b2:	e8 4e cc ff ff       	call   80102105 <iput>
801054b7:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
801054ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c0:	8b 40 68             	mov    0x68(%eax),%eax
801054c3:	8b 40 50             	mov    0x50(%eax),%eax
801054c6:	8b 40 14             	mov    0x14(%eax),%eax
801054c9:	83 ec 0c             	sub    $0xc,%esp
801054cc:	50                   	push   %eax
801054cd:	e8 ee ea ff ff       	call   80103fc0 <end_op>
801054d2:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
801054d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054db:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054e2:	83 ec 0c             	sub    $0xc,%esp
801054e5:	68 80 3e 11 80       	push   $0x80113e80
801054ea:	e8 a8 06 00 00       	call   80105b97 <acquire>
801054ef:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054f8:	8b 40 14             	mov    0x14(%eax),%eax
801054fb:	83 ec 0c             	sub    $0xc,%esp
801054fe:	50                   	push   %eax
801054ff:	e8 46 04 00 00       	call   8010594a <wakeup1>
80105504:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105507:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
8010550e:	eb 3c                	jmp    8010554c <exit+0x13c>
    if(p->parent == proc){
80105510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105513:	8b 50 14             	mov    0x14(%eax),%edx
80105516:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010551c:	39 c2                	cmp    %eax,%edx
8010551e:	75 28                	jne    80105548 <exit+0x138>
      p->parent = initproc;
80105520:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80105526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105529:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010552c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552f:	8b 40 0c             	mov    0xc(%eax),%eax
80105532:	83 f8 05             	cmp    $0x5,%eax
80105535:	75 11                	jne    80105548 <exit+0x138>
        wakeup1(initproc);
80105537:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010553c:	83 ec 0c             	sub    $0xc,%esp
8010553f:	50                   	push   %eax
80105540:	e8 05 04 00 00       	call   8010594a <wakeup1>
80105545:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105548:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010554c:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105553:	72 bb                	jb     80105510 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105555:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010555b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105562:	e8 d6 01 00 00       	call   8010573d <sched>
  panic("zombie exit");
80105567:	83 ec 0c             	sub    $0xc,%esp
8010556a:	68 99 98 10 80       	push   $0x80109899
8010556f:	e8 f2 af ff ff       	call   80100566 <panic>

80105574 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105574:	55                   	push   %ebp
80105575:	89 e5                	mov    %esp,%ebp
80105577:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010557a:	83 ec 0c             	sub    $0xc,%esp
8010557d:	68 80 3e 11 80       	push   $0x80113e80
80105582:	e8 10 06 00 00       	call   80105b97 <acquire>
80105587:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010558a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105591:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105598:	e9 a6 00 00 00       	jmp    80105643 <wait+0xcf>
      if(p->parent != proc)
8010559d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a0:	8b 50 14             	mov    0x14(%eax),%edx
801055a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a9:	39 c2                	cmp    %eax,%edx
801055ab:	0f 85 8d 00 00 00    	jne    8010563e <wait+0xca>
        continue;
      havekids = 1;
801055b1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bb:	8b 40 0c             	mov    0xc(%eax),%eax
801055be:	83 f8 05             	cmp    $0x5,%eax
801055c1:	75 7c                	jne    8010563f <wait+0xcb>
        // Found one.
        pid = p->pid;
801055c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c6:	8b 40 10             	mov    0x10(%eax),%eax
801055c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cf:	8b 40 08             	mov    0x8(%eax),%eax
801055d2:	83 ec 0c             	sub    $0xc,%esp
801055d5:	50                   	push   %eax
801055d6:	e8 0a de ff ff       	call   801033e5 <kfree>
801055db:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055eb:	8b 40 04             	mov    0x4(%eax),%eax
801055ee:	83 ec 0c             	sub    $0xc,%esp
801055f1:	50                   	push   %eax
801055f2:	e8 6e 3b 00 00       	call   80109165 <freevm>
801055f7:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105607:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010560e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105611:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010561f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105622:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105629:	83 ec 0c             	sub    $0xc,%esp
8010562c:	68 80 3e 11 80       	push   $0x80113e80
80105631:	e8 c8 05 00 00       	call   80105bfe <release>
80105636:	83 c4 10             	add    $0x10,%esp
        return pid;
80105639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010563c:	eb 58                	jmp    80105696 <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010563e:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010563f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105643:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010564a:	0f 82 4d ff ff ff    	jb     8010559d <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105650:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105654:	74 0d                	je     80105663 <wait+0xef>
80105656:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565c:	8b 40 24             	mov    0x24(%eax),%eax
8010565f:	85 c0                	test   %eax,%eax
80105661:	74 17                	je     8010567a <wait+0x106>
      release(&ptable.lock);
80105663:	83 ec 0c             	sub    $0xc,%esp
80105666:	68 80 3e 11 80       	push   $0x80113e80
8010566b:	e8 8e 05 00 00       	call   80105bfe <release>
80105670:	83 c4 10             	add    $0x10,%esp
      return -1;
80105673:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105678:	eb 1c                	jmp    80105696 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010567a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105680:	83 ec 08             	sub    $0x8,%esp
80105683:	68 80 3e 11 80       	push   $0x80113e80
80105688:	50                   	push   %eax
80105689:	e8 10 02 00 00       	call   8010589e <sleep>
8010568e:	83 c4 10             	add    $0x10,%esp
  }
80105691:	e9 f4 fe ff ff       	jmp    8010558a <wait+0x16>
}
80105696:	c9                   	leave  
80105697:	c3                   	ret    

80105698 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105698:	55                   	push   %ebp
80105699:	89 e5                	mov    %esp,%ebp
8010569b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010569e:	e8 f3 f8 ff ff       	call   80104f96 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801056a3:	83 ec 0c             	sub    $0xc,%esp
801056a6:	68 80 3e 11 80       	push   $0x80113e80
801056ab:	e8 e7 04 00 00       	call   80105b97 <acquire>
801056b0:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056b3:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801056ba:	eb 63                	jmp    8010571f <scheduler+0x87>
      if(p->state != RUNNABLE)
801056bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bf:	8b 40 0c             	mov    0xc(%eax),%eax
801056c2:	83 f8 03             	cmp    $0x3,%eax
801056c5:	75 53                	jne    8010571a <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ca:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056d0:	83 ec 0c             	sub    $0xc,%esp
801056d3:	ff 75 f4             	pushl  -0xc(%ebp)
801056d6:	e8 44 36 00 00       	call   80108d1f <switchuvm>
801056db:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801056f1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056f8:	83 c2 04             	add    $0x4,%edx
801056fb:	83 ec 08             	sub    $0x8,%esp
801056fe:	50                   	push   %eax
801056ff:	52                   	push   %edx
80105700:	e8 69 09 00 00       	call   8010606e <swtch>
80105705:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105708:	e8 f5 35 00 00       	call   80108d02 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010570d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105714:	00 00 00 00 
80105718:	eb 01                	jmp    8010571b <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010571a:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010571b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010571f:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105726:	72 94                	jb     801056bc <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105728:	83 ec 0c             	sub    $0xc,%esp
8010572b:	68 80 3e 11 80       	push   $0x80113e80
80105730:	e8 c9 04 00 00       	call   80105bfe <release>
80105735:	83 c4 10             	add    $0x10,%esp

  }
80105738:	e9 61 ff ff ff       	jmp    8010569e <scheduler+0x6>

8010573d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010573d:	55                   	push   %ebp
8010573e:	89 e5                	mov    %esp,%ebp
80105740:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105743:	83 ec 0c             	sub    $0xc,%esp
80105746:	68 80 3e 11 80       	push   $0x80113e80
8010574b:	e8 7a 05 00 00       	call   80105cca <holding>
80105750:	83 c4 10             	add    $0x10,%esp
80105753:	85 c0                	test   %eax,%eax
80105755:	75 0d                	jne    80105764 <sched+0x27>
    panic("sched ptable.lock");
80105757:	83 ec 0c             	sub    $0xc,%esp
8010575a:	68 a5 98 10 80       	push   $0x801098a5
8010575f:	e8 02 ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105764:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010576a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105770:	83 f8 01             	cmp    $0x1,%eax
80105773:	74 0d                	je     80105782 <sched+0x45>
   panic("sched locks");
80105775:	83 ec 0c             	sub    $0xc,%esp
80105778:	68 b7 98 10 80       	push   $0x801098b7
8010577d:	e8 e4 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105782:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105788:	8b 40 0c             	mov    0xc(%eax),%eax
8010578b:	83 f8 04             	cmp    $0x4,%eax
8010578e:	75 0d                	jne    8010579d <sched+0x60>
    panic("sched running");
80105790:	83 ec 0c             	sub    $0xc,%esp
80105793:	68 c3 98 10 80       	push   $0x801098c3
80105798:	e8 c9 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010579d:	e8 e4 f7 ff ff       	call   80104f86 <readeflags>
801057a2:	25 00 02 00 00       	and    $0x200,%eax
801057a7:	85 c0                	test   %eax,%eax
801057a9:	74 0d                	je     801057b8 <sched+0x7b>
    panic("sched interruptible");
801057ab:	83 ec 0c             	sub    $0xc,%esp
801057ae:	68 d1 98 10 80       	push   $0x801098d1
801057b3:	e8 ae ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057be:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057c7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057cd:	8b 40 04             	mov    0x4(%eax),%eax
801057d0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057d7:	83 c2 1c             	add    $0x1c,%edx
801057da:	83 ec 08             	sub    $0x8,%esp
801057dd:	50                   	push   %eax
801057de:	52                   	push   %edx
801057df:	e8 8a 08 00 00       	call   8010606e <swtch>
801057e4:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057f0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057f6:	90                   	nop
801057f7:	c9                   	leave  
801057f8:	c3                   	ret    

801057f9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057f9:	55                   	push   %ebp
801057fa:	89 e5                	mov    %esp,%ebp
801057fc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057ff:	83 ec 0c             	sub    $0xc,%esp
80105802:	68 80 3e 11 80       	push   $0x80113e80
80105807:	e8 8b 03 00 00       	call   80105b97 <acquire>
8010580c:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
8010580f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105815:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010581c:	e8 1c ff ff ff       	call   8010573d <sched>
  release(&ptable.lock);
80105821:	83 ec 0c             	sub    $0xc,%esp
80105824:	68 80 3e 11 80       	push   $0x80113e80
80105829:	e8 d0 03 00 00       	call   80105bfe <release>
8010582e:	83 c4 10             	add    $0x10,%esp
}
80105831:	90                   	nop
80105832:	c9                   	leave  
80105833:	c3                   	ret    

80105834 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105834:	55                   	push   %ebp
80105835:	89 e5                	mov    %esp,%ebp
80105837:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010583a:	83 ec 0c             	sub    $0xc,%esp
8010583d:	68 80 3e 11 80       	push   $0x80113e80
80105842:	e8 b7 03 00 00       	call   80105bfe <release>
80105847:	83 c4 10             	add    $0x10,%esp


  if (first) {
8010584a:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010584f:	85 c0                	test   %eax,%eax
80105851:	74 48                	je     8010589b <forkret+0x67>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105853:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
8010585a:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
8010585d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105863:	0f b6 00             	movzbl (%eax),%eax
80105866:	0f b6 c0             	movzbl %al,%eax
80105869:	83 ec 08             	sub    $0x8,%esp
8010586c:	50                   	push   %eax
8010586d:	68 e5 98 10 80       	push   $0x801098e5
80105872:	e8 4f ab ff ff       	call   801003c6 <cprintf>
80105877:	83 c4 10             	add    $0x10,%esp
iinit(proc,ROOTDEV);
8010587a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105880:	83 ec 08             	sub    $0x8,%esp
80105883:	6a 00                	push   $0x0
80105885:	50                   	push   %eax
80105886:	e8 a7 c1 ff ff       	call   80101a32 <iinit>
8010588b:	83 c4 10             	add    $0x10,%esp
    // iinitDone=1;
   // cprintf("boot from after iinit is %d \n",bootfrom);
    initlog(ROOTDEV);
8010588e:	83 ec 0c             	sub    $0xc,%esp
80105891:	6a 00                	push   $0x0
80105893:	e8 b3 e2 ff ff       	call   80103b4b <initlog>
80105898:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
8010589b:	90                   	nop
8010589c:	c9                   	leave  
8010589d:	c3                   	ret    

8010589e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010589e:	55                   	push   %ebp
8010589f:	89 e5                	mov    %esp,%ebp
801058a1:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801058a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058aa:	85 c0                	test   %eax,%eax
801058ac:	75 0d                	jne    801058bb <sleep+0x1d>
    panic("sleep");
801058ae:	83 ec 0c             	sub    $0xc,%esp
801058b1:	68 f4 98 10 80       	push   $0x801098f4
801058b6:	e8 ab ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058bf:	75 0d                	jne    801058ce <sleep+0x30>
    panic("sleep without lk");
801058c1:	83 ec 0c             	sub    $0xc,%esp
801058c4:	68 fa 98 10 80       	push   $0x801098fa
801058c9:	e8 98 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058ce:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058d5:	74 1e                	je     801058f5 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058d7:	83 ec 0c             	sub    $0xc,%esp
801058da:	68 80 3e 11 80       	push   $0x80113e80
801058df:	e8 b3 02 00 00       	call   80105b97 <acquire>
801058e4:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058e7:	83 ec 0c             	sub    $0xc,%esp
801058ea:	ff 75 0c             	pushl  0xc(%ebp)
801058ed:	e8 0c 03 00 00       	call   80105bfe <release>
801058f2:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058fb:	8b 55 08             	mov    0x8(%ebp),%edx
801058fe:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105901:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105907:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010590e:	e8 2a fe ff ff       	call   8010573d <sched>

  // Tidy up.
  proc->chan = 0;
80105913:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105919:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105920:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
80105927:	74 1e                	je     80105947 <sleep+0xa9>
    release(&ptable.lock);
80105929:	83 ec 0c             	sub    $0xc,%esp
8010592c:	68 80 3e 11 80       	push   $0x80113e80
80105931:	e8 c8 02 00 00       	call   80105bfe <release>
80105936:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105939:	83 ec 0c             	sub    $0xc,%esp
8010593c:	ff 75 0c             	pushl  0xc(%ebp)
8010593f:	e8 53 02 00 00       	call   80105b97 <acquire>
80105944:	83 c4 10             	add    $0x10,%esp
  }
}
80105947:	90                   	nop
80105948:	c9                   	leave  
80105949:	c3                   	ret    

8010594a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010594a:	55                   	push   %ebp
8010594b:	89 e5                	mov    %esp,%ebp
8010594d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105950:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105957:	eb 24                	jmp    8010597d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105959:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010595c:	8b 40 0c             	mov    0xc(%eax),%eax
8010595f:	83 f8 02             	cmp    $0x2,%eax
80105962:	75 15                	jne    80105979 <wakeup1+0x2f>
80105964:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105967:	8b 40 20             	mov    0x20(%eax),%eax
8010596a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010596d:	75 0a                	jne    80105979 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010596f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105972:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105979:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010597d:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
80105984:	72 d3                	jb     80105959 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105986:	90                   	nop
80105987:	c9                   	leave  
80105988:	c3                   	ret    

80105989 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105989:	55                   	push   %ebp
8010598a:	89 e5                	mov    %esp,%ebp
8010598c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	68 80 3e 11 80       	push   $0x80113e80
80105997:	e8 fb 01 00 00       	call   80105b97 <acquire>
8010599c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010599f:	83 ec 0c             	sub    $0xc,%esp
801059a2:	ff 75 08             	pushl  0x8(%ebp)
801059a5:	e8 a0 ff ff ff       	call   8010594a <wakeup1>
801059aa:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801059ad:	83 ec 0c             	sub    $0xc,%esp
801059b0:	68 80 3e 11 80       	push   $0x80113e80
801059b5:	e8 44 02 00 00       	call   80105bfe <release>
801059ba:	83 c4 10             	add    $0x10,%esp
}
801059bd:	90                   	nop
801059be:	c9                   	leave  
801059bf:	c3                   	ret    

801059c0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059c0:	55                   	push   %ebp
801059c1:	89 e5                	mov    %esp,%ebp
801059c3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059c6:	83 ec 0c             	sub    $0xc,%esp
801059c9:	68 80 3e 11 80       	push   $0x80113e80
801059ce:	e8 c4 01 00 00       	call   80105b97 <acquire>
801059d3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059d6:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059dd:	eb 45                	jmp    80105a24 <kill+0x64>
    if(p->pid == pid){
801059df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e2:	8b 40 10             	mov    0x10(%eax),%eax
801059e5:	3b 45 08             	cmp    0x8(%ebp),%eax
801059e8:	75 36                	jne    80105a20 <kill+0x60>
      p->killed = 1;
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f7:	8b 40 0c             	mov    0xc(%eax),%eax
801059fa:	83 f8 02             	cmp    $0x2,%eax
801059fd:	75 0a                	jne    80105a09 <kill+0x49>
        p->state = RUNNABLE;
801059ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a02:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a09:	83 ec 0c             	sub    $0xc,%esp
80105a0c:	68 80 3e 11 80       	push   $0x80113e80
80105a11:	e8 e8 01 00 00       	call   80105bfe <release>
80105a16:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a19:	b8 00 00 00 00       	mov    $0x0,%eax
80105a1e:	eb 22                	jmp    80105a42 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a20:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105a24:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105a2b:	72 b2                	jb     801059df <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a2d:	83 ec 0c             	sub    $0xc,%esp
80105a30:	68 80 3e 11 80       	push   $0x80113e80
80105a35:	e8 c4 01 00 00       	call   80105bfe <release>
80105a3a:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a42:	c9                   	leave  
80105a43:	c3                   	ret    

80105a44 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a44:	55                   	push   %ebp
80105a45:	89 e5                	mov    %esp,%ebp
80105a47:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a4a:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a51:	e9 d7 00 00 00       	jmp    80105b2d <procdump+0xe9>
    if(p->state == UNUSED)
80105a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a59:	8b 40 0c             	mov    0xc(%eax),%eax
80105a5c:	85 c0                	test   %eax,%eax
80105a5e:	0f 84 c4 00 00 00    	je     80105b28 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a67:	8b 40 0c             	mov    0xc(%eax),%eax
80105a6a:	83 f8 05             	cmp    $0x5,%eax
80105a6d:	77 23                	ja     80105a92 <procdump+0x4e>
80105a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a72:	8b 40 0c             	mov    0xc(%eax),%eax
80105a75:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a7c:	85 c0                	test   %eax,%eax
80105a7e:	74 12                	je     80105a92 <procdump+0x4e>
      state = states[p->state];
80105a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a83:	8b 40 0c             	mov    0xc(%eax),%eax
80105a86:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a90:	eb 07                	jmp    80105a99 <procdump+0x55>
    else
      state = "???";
80105a92:	c7 45 ec 0b 99 10 80 	movl   $0x8010990b,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9c:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa2:	8b 40 10             	mov    0x10(%eax),%eax
80105aa5:	52                   	push   %edx
80105aa6:	ff 75 ec             	pushl  -0x14(%ebp)
80105aa9:	50                   	push   %eax
80105aaa:	68 0f 99 10 80       	push   $0x8010990f
80105aaf:	e8 12 a9 ff ff       	call   801003c6 <cprintf>
80105ab4:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aba:	8b 40 0c             	mov    0xc(%eax),%eax
80105abd:	83 f8 02             	cmp    $0x2,%eax
80105ac0:	75 54                	jne    80105b16 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac5:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ac8:	8b 40 0c             	mov    0xc(%eax),%eax
80105acb:	83 c0 08             	add    $0x8,%eax
80105ace:	89 c2                	mov    %eax,%edx
80105ad0:	83 ec 08             	sub    $0x8,%esp
80105ad3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105ad6:	50                   	push   %eax
80105ad7:	52                   	push   %edx
80105ad8:	e8 73 01 00 00       	call   80105c50 <getcallerpcs>
80105add:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ae0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ae7:	eb 1c                	jmp    80105b05 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aec:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105af0:	83 ec 08             	sub    $0x8,%esp
80105af3:	50                   	push   %eax
80105af4:	68 18 99 10 80       	push   $0x80109918
80105af9:	e8 c8 a8 ff ff       	call   801003c6 <cprintf>
80105afe:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105b01:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b05:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105b09:	7f 0b                	jg     80105b16 <procdump+0xd2>
80105b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b12:	85 c0                	test   %eax,%eax
80105b14:	75 d3                	jne    80105ae9 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b16:	83 ec 0c             	sub    $0xc,%esp
80105b19:	68 1c 99 10 80       	push   $0x8010991c
80105b1e:	e8 a3 a8 ff ff       	call   801003c6 <cprintf>
80105b23:	83 c4 10             	add    $0x10,%esp
80105b26:	eb 01                	jmp    80105b29 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b28:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b29:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105b2d:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b34:	0f 82 1c ff ff ff    	jb     80105a56 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b3a:	90                   	nop
80105b3b:	c9                   	leave  
80105b3c:	c3                   	ret    

80105b3d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b3d:	55                   	push   %ebp
80105b3e:	89 e5                	mov    %esp,%ebp
80105b40:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b43:	9c                   	pushf  
80105b44:	58                   	pop    %eax
80105b45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b4b:	c9                   	leave  
80105b4c:	c3                   	ret    

80105b4d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b4d:	55                   	push   %ebp
80105b4e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b50:	fa                   	cli    
}
80105b51:	90                   	nop
80105b52:	5d                   	pop    %ebp
80105b53:	c3                   	ret    

80105b54 <sti>:

static inline void
sti(void)
{
80105b54:	55                   	push   %ebp
80105b55:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b57:	fb                   	sti    
}
80105b58:	90                   	nop
80105b59:	5d                   	pop    %ebp
80105b5a:	c3                   	ret    

80105b5b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b5b:	55                   	push   %ebp
80105b5c:	89 e5                	mov    %esp,%ebp
80105b5e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b61:	8b 55 08             	mov    0x8(%ebp),%edx
80105b64:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b67:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b6a:	f0 87 02             	lock xchg %eax,(%edx)
80105b6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b73:	c9                   	leave  
80105b74:	c3                   	ret    

80105b75 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b75:	55                   	push   %ebp
80105b76:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b78:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b7e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b81:	8b 45 08             	mov    0x8(%ebp),%eax
80105b84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b94:	90                   	nop
80105b95:	5d                   	pop    %ebp
80105b96:	c3                   	ret    

80105b97 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b97:	55                   	push   %ebp
80105b98:	89 e5                	mov    %esp,%ebp
80105b9a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b9d:	e8 52 01 00 00       	call   80105cf4 <pushcli>
  if(holding(lk))
80105ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba5:	83 ec 0c             	sub    $0xc,%esp
80105ba8:	50                   	push   %eax
80105ba9:	e8 1c 01 00 00       	call   80105cca <holding>
80105bae:	83 c4 10             	add    $0x10,%esp
80105bb1:	85 c0                	test   %eax,%eax
80105bb3:	74 0d                	je     80105bc2 <acquire+0x2b>
    panic("acquire");
80105bb5:	83 ec 0c             	sub    $0xc,%esp
80105bb8:	68 48 99 10 80       	push   $0x80109948
80105bbd:	e8 a4 a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bc2:	90                   	nop
80105bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc6:	83 ec 08             	sub    $0x8,%esp
80105bc9:	6a 01                	push   $0x1
80105bcb:	50                   	push   %eax
80105bcc:	e8 8a ff ff ff       	call   80105b5b <xchg>
80105bd1:	83 c4 10             	add    $0x10,%esp
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	75 eb                	jne    80105bc3 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bdb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105be2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105be5:	8b 45 08             	mov    0x8(%ebp),%eax
80105be8:	83 c0 0c             	add    $0xc,%eax
80105beb:	83 ec 08             	sub    $0x8,%esp
80105bee:	50                   	push   %eax
80105bef:	8d 45 08             	lea    0x8(%ebp),%eax
80105bf2:	50                   	push   %eax
80105bf3:	e8 58 00 00 00       	call   80105c50 <getcallerpcs>
80105bf8:	83 c4 10             	add    $0x10,%esp
}
80105bfb:	90                   	nop
80105bfc:	c9                   	leave  
80105bfd:	c3                   	ret    

80105bfe <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105bfe:	55                   	push   %ebp
80105bff:	89 e5                	mov    %esp,%ebp
80105c01:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105c04:	83 ec 0c             	sub    $0xc,%esp
80105c07:	ff 75 08             	pushl  0x8(%ebp)
80105c0a:	e8 bb 00 00 00       	call   80105cca <holding>
80105c0f:	83 c4 10             	add    $0x10,%esp
80105c12:	85 c0                	test   %eax,%eax
80105c14:	75 0d                	jne    80105c23 <release+0x25>
    panic("release");
80105c16:	83 ec 0c             	sub    $0xc,%esp
80105c19:	68 50 99 10 80       	push   $0x80109950
80105c1e:	e8 43 a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c23:	8b 45 08             	mov    0x8(%ebp),%eax
80105c26:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c30:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c37:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3a:	83 ec 08             	sub    $0x8,%esp
80105c3d:	6a 00                	push   $0x0
80105c3f:	50                   	push   %eax
80105c40:	e8 16 ff ff ff       	call   80105b5b <xchg>
80105c45:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c48:	e8 ec 00 00 00       	call   80105d39 <popcli>
}
80105c4d:	90                   	nop
80105c4e:	c9                   	leave  
80105c4f:	c3                   	ret    

80105c50 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c50:	55                   	push   %ebp
80105c51:	89 e5                	mov    %esp,%ebp
80105c53:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c56:	8b 45 08             	mov    0x8(%ebp),%eax
80105c59:	83 e8 08             	sub    $0x8,%eax
80105c5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c5f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c66:	eb 38                	jmp    80105ca0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c68:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c6c:	74 53                	je     80105cc1 <getcallerpcs+0x71>
80105c6e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c75:	76 4a                	jbe    80105cc1 <getcallerpcs+0x71>
80105c77:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c7b:	74 44                	je     80105cc1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c8a:	01 c2                	add    %eax,%edx
80105c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c8f:	8b 40 04             	mov    0x4(%eax),%eax
80105c92:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c97:	8b 00                	mov    (%eax),%eax
80105c99:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c9c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105ca0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105ca4:	7e c2                	jle    80105c68 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105ca6:	eb 19                	jmp    80105cc1 <getcallerpcs+0x71>
    pcs[i] = 0;
80105ca8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cb5:	01 d0                	add    %edx,%eax
80105cb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cbd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cc1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cc5:	7e e1                	jle    80105ca8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cc7:	90                   	nop
80105cc8:	c9                   	leave  
80105cc9:	c3                   	ret    

80105cca <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cca:	55                   	push   %ebp
80105ccb:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd0:	8b 00                	mov    (%eax),%eax
80105cd2:	85 c0                	test   %eax,%eax
80105cd4:	74 17                	je     80105ced <holding+0x23>
80105cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd9:	8b 50 08             	mov    0x8(%eax),%edx
80105cdc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ce2:	39 c2                	cmp    %eax,%edx
80105ce4:	75 07                	jne    80105ced <holding+0x23>
80105ce6:	b8 01 00 00 00       	mov    $0x1,%eax
80105ceb:	eb 05                	jmp    80105cf2 <holding+0x28>
80105ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf2:	5d                   	pop    %ebp
80105cf3:	c3                   	ret    

80105cf4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105cf4:	55                   	push   %ebp
80105cf5:	89 e5                	mov    %esp,%ebp
80105cf7:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105cfa:	e8 3e fe ff ff       	call   80105b3d <readeflags>
80105cff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d02:	e8 46 fe ff ff       	call   80105b4d <cli>
  if(cpu->ncli++ == 0)
80105d07:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d0e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d14:	8d 48 01             	lea    0x1(%eax),%ecx
80105d17:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d1d:	85 c0                	test   %eax,%eax
80105d1f:	75 15                	jne    80105d36 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d21:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d27:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d2a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d30:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d36:	90                   	nop
80105d37:	c9                   	leave  
80105d38:	c3                   	ret    

80105d39 <popcli>:

void
popcli(void)
{
80105d39:	55                   	push   %ebp
80105d3a:	89 e5                	mov    %esp,%ebp
80105d3c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d3f:	e8 f9 fd ff ff       	call   80105b3d <readeflags>
80105d44:	25 00 02 00 00       	and    $0x200,%eax
80105d49:	85 c0                	test   %eax,%eax
80105d4b:	74 0d                	je     80105d5a <popcli+0x21>
    panic("popcli - interruptible");
80105d4d:	83 ec 0c             	sub    $0xc,%esp
80105d50:	68 58 99 10 80       	push   $0x80109958
80105d55:	e8 0c a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d5a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d60:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d66:	83 ea 01             	sub    $0x1,%edx
80105d69:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d6f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d75:	85 c0                	test   %eax,%eax
80105d77:	79 0d                	jns    80105d86 <popcli+0x4d>
    panic("popcli");
80105d79:	83 ec 0c             	sub    $0xc,%esp
80105d7c:	68 6f 99 10 80       	push   $0x8010996f
80105d81:	e8 e0 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d86:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d8c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d92:	85 c0                	test   %eax,%eax
80105d94:	75 15                	jne    80105dab <popcli+0x72>
80105d96:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d9c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105da2:	85 c0                	test   %eax,%eax
80105da4:	74 05                	je     80105dab <popcli+0x72>
    sti();
80105da6:	e8 a9 fd ff ff       	call   80105b54 <sti>
}
80105dab:	90                   	nop
80105dac:	c9                   	leave  
80105dad:	c3                   	ret    

80105dae <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105dae:	55                   	push   %ebp
80105daf:	89 e5                	mov    %esp,%ebp
80105db1:	57                   	push   %edi
80105db2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105db6:	8b 55 10             	mov    0x10(%ebp),%edx
80105db9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dbc:	89 cb                	mov    %ecx,%ebx
80105dbe:	89 df                	mov    %ebx,%edi
80105dc0:	89 d1                	mov    %edx,%ecx
80105dc2:	fc                   	cld    
80105dc3:	f3 aa                	rep stos %al,%es:(%edi)
80105dc5:	89 ca                	mov    %ecx,%edx
80105dc7:	89 fb                	mov    %edi,%ebx
80105dc9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dcc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dcf:	90                   	nop
80105dd0:	5b                   	pop    %ebx
80105dd1:	5f                   	pop    %edi
80105dd2:	5d                   	pop    %ebp
80105dd3:	c3                   	ret    

80105dd4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dd4:	55                   	push   %ebp
80105dd5:	89 e5                	mov    %esp,%ebp
80105dd7:	57                   	push   %edi
80105dd8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ddc:	8b 55 10             	mov    0x10(%ebp),%edx
80105ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105de2:	89 cb                	mov    %ecx,%ebx
80105de4:	89 df                	mov    %ebx,%edi
80105de6:	89 d1                	mov    %edx,%ecx
80105de8:	fc                   	cld    
80105de9:	f3 ab                	rep stos %eax,%es:(%edi)
80105deb:	89 ca                	mov    %ecx,%edx
80105ded:	89 fb                	mov    %edi,%ebx
80105def:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105df2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105df5:	90                   	nop
80105df6:	5b                   	pop    %ebx
80105df7:	5f                   	pop    %edi
80105df8:	5d                   	pop    %ebp
80105df9:	c3                   	ret    

80105dfa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105dfa:	55                   	push   %ebp
80105dfb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80105e00:	83 e0 03             	and    $0x3,%eax
80105e03:	85 c0                	test   %eax,%eax
80105e05:	75 43                	jne    80105e4a <memset+0x50>
80105e07:	8b 45 10             	mov    0x10(%ebp),%eax
80105e0a:	83 e0 03             	and    $0x3,%eax
80105e0d:	85 c0                	test   %eax,%eax
80105e0f:	75 39                	jne    80105e4a <memset+0x50>
    c &= 0xFF;
80105e11:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e18:	8b 45 10             	mov    0x10(%ebp),%eax
80105e1b:	c1 e8 02             	shr    $0x2,%eax
80105e1e:	89 c1                	mov    %eax,%ecx
80105e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e23:	c1 e0 18             	shl    $0x18,%eax
80105e26:	89 c2                	mov    %eax,%edx
80105e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e2b:	c1 e0 10             	shl    $0x10,%eax
80105e2e:	09 c2                	or     %eax,%edx
80105e30:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e33:	c1 e0 08             	shl    $0x8,%eax
80105e36:	09 d0                	or     %edx,%eax
80105e38:	0b 45 0c             	or     0xc(%ebp),%eax
80105e3b:	51                   	push   %ecx
80105e3c:	50                   	push   %eax
80105e3d:	ff 75 08             	pushl  0x8(%ebp)
80105e40:	e8 8f ff ff ff       	call   80105dd4 <stosl>
80105e45:	83 c4 0c             	add    $0xc,%esp
80105e48:	eb 12                	jmp    80105e5c <memset+0x62>
  } else
    stosb(dst, c, n);
80105e4a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e4d:	50                   	push   %eax
80105e4e:	ff 75 0c             	pushl  0xc(%ebp)
80105e51:	ff 75 08             	pushl  0x8(%ebp)
80105e54:	e8 55 ff ff ff       	call   80105dae <stosb>
80105e59:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e5c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e5f:	c9                   	leave  
80105e60:	c3                   	ret    

80105e61 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e61:	55                   	push   %ebp
80105e62:	89 e5                	mov    %esp,%ebp
80105e64:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e67:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e70:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e73:	eb 30                	jmp    80105ea5 <memcmp+0x44>
    if(*s1 != *s2)
80105e75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e78:	0f b6 10             	movzbl (%eax),%edx
80105e7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e7e:	0f b6 00             	movzbl (%eax),%eax
80105e81:	38 c2                	cmp    %al,%dl
80105e83:	74 18                	je     80105e9d <memcmp+0x3c>
      return *s1 - *s2;
80105e85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e88:	0f b6 00             	movzbl (%eax),%eax
80105e8b:	0f b6 d0             	movzbl %al,%edx
80105e8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e91:	0f b6 00             	movzbl (%eax),%eax
80105e94:	0f b6 c0             	movzbl %al,%eax
80105e97:	29 c2                	sub    %eax,%edx
80105e99:	89 d0                	mov    %edx,%eax
80105e9b:	eb 1a                	jmp    80105eb7 <memcmp+0x56>
    s1++, s2++;
80105e9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ea1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105ea5:	8b 45 10             	mov    0x10(%ebp),%eax
80105ea8:	8d 50 ff             	lea    -0x1(%eax),%edx
80105eab:	89 55 10             	mov    %edx,0x10(%ebp)
80105eae:	85 c0                	test   %eax,%eax
80105eb0:	75 c3                	jne    80105e75 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105eb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105eb7:	c9                   	leave  
80105eb8:	c3                   	ret    

80105eb9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105eb9:	55                   	push   %ebp
80105eba:	89 e5                	mov    %esp,%ebp
80105ebc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ec2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ecb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ece:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ed1:	73 54                	jae    80105f27 <memmove+0x6e>
80105ed3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ed6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed9:	01 d0                	add    %edx,%eax
80105edb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ede:	76 47                	jbe    80105f27 <memmove+0x6e>
    s += n;
80105ee0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ee3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ee6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ee9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105eec:	eb 13                	jmp    80105f01 <memmove+0x48>
      *--d = *--s;
80105eee:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105ef2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ef6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ef9:	0f b6 10             	movzbl (%eax),%edx
80105efc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105eff:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f01:	8b 45 10             	mov    0x10(%ebp),%eax
80105f04:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f07:	89 55 10             	mov    %edx,0x10(%ebp)
80105f0a:	85 c0                	test   %eax,%eax
80105f0c:	75 e0                	jne    80105eee <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f0e:	eb 24                	jmp    80105f34 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f10:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f13:	8d 50 01             	lea    0x1(%eax),%edx
80105f16:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f19:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f1c:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f1f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f22:	0f b6 12             	movzbl (%edx),%edx
80105f25:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f27:	8b 45 10             	mov    0x10(%ebp),%eax
80105f2a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f2d:	89 55 10             	mov    %edx,0x10(%ebp)
80105f30:	85 c0                	test   %eax,%eax
80105f32:	75 dc                	jne    80105f10 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f34:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f37:	c9                   	leave  
80105f38:	c3                   	ret    

80105f39 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f39:	55                   	push   %ebp
80105f3a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f3c:	ff 75 10             	pushl  0x10(%ebp)
80105f3f:	ff 75 0c             	pushl  0xc(%ebp)
80105f42:	ff 75 08             	pushl  0x8(%ebp)
80105f45:	e8 6f ff ff ff       	call   80105eb9 <memmove>
80105f4a:	83 c4 0c             	add    $0xc,%esp
}
80105f4d:	c9                   	leave  
80105f4e:	c3                   	ret    

80105f4f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f4f:	55                   	push   %ebp
80105f50:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f52:	eb 0c                	jmp    80105f60 <strncmp+0x11>
    n--, p++, q++;
80105f54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f58:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f64:	74 1a                	je     80105f80 <strncmp+0x31>
80105f66:	8b 45 08             	mov    0x8(%ebp),%eax
80105f69:	0f b6 00             	movzbl (%eax),%eax
80105f6c:	84 c0                	test   %al,%al
80105f6e:	74 10                	je     80105f80 <strncmp+0x31>
80105f70:	8b 45 08             	mov    0x8(%ebp),%eax
80105f73:	0f b6 10             	movzbl (%eax),%edx
80105f76:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f79:	0f b6 00             	movzbl (%eax),%eax
80105f7c:	38 c2                	cmp    %al,%dl
80105f7e:	74 d4                	je     80105f54 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f84:	75 07                	jne    80105f8d <strncmp+0x3e>
    return 0;
80105f86:	b8 00 00 00 00       	mov    $0x0,%eax
80105f8b:	eb 16                	jmp    80105fa3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f90:	0f b6 00             	movzbl (%eax),%eax
80105f93:	0f b6 d0             	movzbl %al,%edx
80105f96:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f99:	0f b6 00             	movzbl (%eax),%eax
80105f9c:	0f b6 c0             	movzbl %al,%eax
80105f9f:	29 c2                	sub    %eax,%edx
80105fa1:	89 d0                	mov    %edx,%eax
}
80105fa3:	5d                   	pop    %ebp
80105fa4:	c3                   	ret    

80105fa5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105fa5:	55                   	push   %ebp
80105fa6:	89 e5                	mov    %esp,%ebp
80105fa8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fab:	8b 45 08             	mov    0x8(%ebp),%eax
80105fae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105fb1:	90                   	nop
80105fb2:	8b 45 10             	mov    0x10(%ebp),%eax
80105fb5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fb8:	89 55 10             	mov    %edx,0x10(%ebp)
80105fbb:	85 c0                	test   %eax,%eax
80105fbd:	7e 2c                	jle    80105feb <strncpy+0x46>
80105fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fc2:	8d 50 01             	lea    0x1(%eax),%edx
80105fc5:	89 55 08             	mov    %edx,0x8(%ebp)
80105fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fcb:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fce:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fd1:	0f b6 12             	movzbl (%edx),%edx
80105fd4:	88 10                	mov    %dl,(%eax)
80105fd6:	0f b6 00             	movzbl (%eax),%eax
80105fd9:	84 c0                	test   %al,%al
80105fdb:	75 d5                	jne    80105fb2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105fdd:	eb 0c                	jmp    80105feb <strncpy+0x46>
    *s++ = 0;
80105fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe2:	8d 50 01             	lea    0x1(%eax),%edx
80105fe5:	89 55 08             	mov    %edx,0x8(%ebp)
80105fe8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105feb:	8b 45 10             	mov    0x10(%ebp),%eax
80105fee:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ff1:	89 55 10             	mov    %edx,0x10(%ebp)
80105ff4:	85 c0                	test   %eax,%eax
80105ff6:	7f e7                	jg     80105fdf <strncpy+0x3a>
    *s++ = 0;
  return os;
80105ff8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ffb:	c9                   	leave  
80105ffc:	c3                   	ret    

80105ffd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105ffd:	55                   	push   %ebp
80105ffe:	89 e5                	mov    %esp,%ebp
80106000:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106003:	8b 45 08             	mov    0x8(%ebp),%eax
80106006:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106009:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010600d:	7f 05                	jg     80106014 <safestrcpy+0x17>
    return os;
8010600f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106012:	eb 31                	jmp    80106045 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106014:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106018:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010601c:	7e 1e                	jle    8010603c <safestrcpy+0x3f>
8010601e:	8b 45 08             	mov    0x8(%ebp),%eax
80106021:	8d 50 01             	lea    0x1(%eax),%edx
80106024:	89 55 08             	mov    %edx,0x8(%ebp)
80106027:	8b 55 0c             	mov    0xc(%ebp),%edx
8010602a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010602d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106030:	0f b6 12             	movzbl (%edx),%edx
80106033:	88 10                	mov    %dl,(%eax)
80106035:	0f b6 00             	movzbl (%eax),%eax
80106038:	84 c0                	test   %al,%al
8010603a:	75 d8                	jne    80106014 <safestrcpy+0x17>
    ;
  *s = 0;
8010603c:	8b 45 08             	mov    0x8(%ebp),%eax
8010603f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106042:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106045:	c9                   	leave  
80106046:	c3                   	ret    

80106047 <strlen>:

int
strlen(const char *s)
{
80106047:	55                   	push   %ebp
80106048:	89 e5                	mov    %esp,%ebp
8010604a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010604d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106054:	eb 04                	jmp    8010605a <strlen+0x13>
80106056:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010605a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010605d:	8b 45 08             	mov    0x8(%ebp),%eax
80106060:	01 d0                	add    %edx,%eax
80106062:	0f b6 00             	movzbl (%eax),%eax
80106065:	84 c0                	test   %al,%al
80106067:	75 ed                	jne    80106056 <strlen+0xf>
    ;
  return n;
80106069:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010606c:	c9                   	leave  
8010606d:	c3                   	ret    

8010606e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010606e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106072:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106076:	55                   	push   %ebp
  pushl %ebx
80106077:	53                   	push   %ebx
  pushl %esi
80106078:	56                   	push   %esi
  pushl %edi
80106079:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010607a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010607c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010607e:	5f                   	pop    %edi
  popl %esi
8010607f:	5e                   	pop    %esi
  popl %ebx
80106080:	5b                   	pop    %ebx
  popl %ebp
80106081:	5d                   	pop    %ebp
  ret
80106082:	c3                   	ret    

80106083 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106083:	55                   	push   %ebp
80106084:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106086:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010608c:	8b 00                	mov    (%eax),%eax
8010608e:	3b 45 08             	cmp    0x8(%ebp),%eax
80106091:	76 12                	jbe    801060a5 <fetchint+0x22>
80106093:	8b 45 08             	mov    0x8(%ebp),%eax
80106096:	8d 50 04             	lea    0x4(%eax),%edx
80106099:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010609f:	8b 00                	mov    (%eax),%eax
801060a1:	39 c2                	cmp    %eax,%edx
801060a3:	76 07                	jbe    801060ac <fetchint+0x29>
    return -1;
801060a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060aa:	eb 0f                	jmp    801060bb <fetchint+0x38>
  *ip = *(int*)(addr);
801060ac:	8b 45 08             	mov    0x8(%ebp),%eax
801060af:	8b 10                	mov    (%eax),%edx
801060b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b4:	89 10                	mov    %edx,(%eax)
  return 0;
801060b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060bb:	5d                   	pop    %ebp
801060bc:	c3                   	ret    

801060bd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060bd:	55                   	push   %ebp
801060be:	89 e5                	mov    %esp,%ebp
801060c0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c9:	8b 00                	mov    (%eax),%eax
801060cb:	3b 45 08             	cmp    0x8(%ebp),%eax
801060ce:	77 07                	ja     801060d7 <fetchstr+0x1a>
    return -1;
801060d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d5:	eb 46                	jmp    8010611d <fetchstr+0x60>
  *pp = (char*)addr;
801060d7:	8b 55 08             	mov    0x8(%ebp),%edx
801060da:	8b 45 0c             	mov    0xc(%ebp),%eax
801060dd:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060e5:	8b 00                	mov    (%eax),%eax
801060e7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ed:	8b 00                	mov    (%eax),%eax
801060ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060f2:	eb 1c                	jmp    80106110 <fetchstr+0x53>
    if(*s == 0)
801060f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060f7:	0f b6 00             	movzbl (%eax),%eax
801060fa:	84 c0                	test   %al,%al
801060fc:	75 0e                	jne    8010610c <fetchstr+0x4f>
      return s - *pp;
801060fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106101:	8b 45 0c             	mov    0xc(%ebp),%eax
80106104:	8b 00                	mov    (%eax),%eax
80106106:	29 c2                	sub    %eax,%edx
80106108:	89 d0                	mov    %edx,%eax
8010610a:	eb 11                	jmp    8010611d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010610c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106110:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106113:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106116:	72 dc                	jb     801060f4 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010611d:	c9                   	leave  
8010611e:	c3                   	ret    

8010611f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010611f:	55                   	push   %ebp
80106120:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106128:	8b 40 18             	mov    0x18(%eax),%eax
8010612b:	8b 40 44             	mov    0x44(%eax),%eax
8010612e:	8b 55 08             	mov    0x8(%ebp),%edx
80106131:	c1 e2 02             	shl    $0x2,%edx
80106134:	01 d0                	add    %edx,%eax
80106136:	83 c0 04             	add    $0x4,%eax
80106139:	ff 75 0c             	pushl  0xc(%ebp)
8010613c:	50                   	push   %eax
8010613d:	e8 41 ff ff ff       	call   80106083 <fetchint>
80106142:	83 c4 08             	add    $0x8,%esp
}
80106145:	c9                   	leave  
80106146:	c3                   	ret    

80106147 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106147:	55                   	push   %ebp
80106148:	89 e5                	mov    %esp,%ebp
8010614a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010614d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106150:	50                   	push   %eax
80106151:	ff 75 08             	pushl  0x8(%ebp)
80106154:	e8 c6 ff ff ff       	call   8010611f <argint>
80106159:	83 c4 08             	add    $0x8,%esp
8010615c:	85 c0                	test   %eax,%eax
8010615e:	79 07                	jns    80106167 <argptr+0x20>
    return -1;
80106160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106165:	eb 3b                	jmp    801061a2 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106167:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010616d:	8b 00                	mov    (%eax),%eax
8010616f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106172:	39 d0                	cmp    %edx,%eax
80106174:	76 16                	jbe    8010618c <argptr+0x45>
80106176:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106179:	89 c2                	mov    %eax,%edx
8010617b:	8b 45 10             	mov    0x10(%ebp),%eax
8010617e:	01 c2                	add    %eax,%edx
80106180:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106186:	8b 00                	mov    (%eax),%eax
80106188:	39 c2                	cmp    %eax,%edx
8010618a:	76 07                	jbe    80106193 <argptr+0x4c>
    return -1;
8010618c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106191:	eb 0f                	jmp    801061a2 <argptr+0x5b>
  *pp = (char*)i;
80106193:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106196:	89 c2                	mov    %eax,%edx
80106198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010619b:	89 10                	mov    %edx,(%eax)
  return 0;
8010619d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061a2:	c9                   	leave  
801061a3:	c3                   	ret    

801061a4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801061a4:	55                   	push   %ebp
801061a5:	89 e5                	mov    %esp,%ebp
801061a7:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801061aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061ad:	50                   	push   %eax
801061ae:	ff 75 08             	pushl  0x8(%ebp)
801061b1:	e8 69 ff ff ff       	call   8010611f <argint>
801061b6:	83 c4 08             	add    $0x8,%esp
801061b9:	85 c0                	test   %eax,%eax
801061bb:	79 07                	jns    801061c4 <argstr+0x20>
    return -1;
801061bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c2:	eb 0f                	jmp    801061d3 <argstr+0x2f>
  return fetchstr(addr, pp);
801061c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061c7:	ff 75 0c             	pushl  0xc(%ebp)
801061ca:	50                   	push   %eax
801061cb:	e8 ed fe ff ff       	call   801060bd <fetchstr>
801061d0:	83 c4 08             	add    $0x8,%esp
}
801061d3:	c9                   	leave  
801061d4:	c3                   	ret    

801061d5 <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061d5:	55                   	push   %ebp
801061d6:	89 e5                	mov    %esp,%ebp
801061d8:	53                   	push   %ebx
801061d9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e2:	8b 40 18             	mov    0x18(%eax),%eax
801061e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801061e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061ef:	7e 30                	jle    80106221 <syscall+0x4c>
801061f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f4:	83 f8 16             	cmp    $0x16,%eax
801061f7:	77 28                	ja     80106221 <syscall+0x4c>
801061f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fc:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106203:	85 c0                	test   %eax,%eax
80106205:	74 1a                	je     80106221 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106207:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010620d:	8b 58 18             	mov    0x18(%eax),%ebx
80106210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106213:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010621a:	ff d0                	call   *%eax
8010621c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010621f:	eb 34                	jmp    80106255 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106221:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106227:	8d 50 6c             	lea    0x6c(%eax),%edx
8010622a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106230:	8b 40 10             	mov    0x10(%eax),%eax
80106233:	ff 75 f4             	pushl  -0xc(%ebp)
80106236:	52                   	push   %edx
80106237:	50                   	push   %eax
80106238:	68 76 99 10 80       	push   $0x80109976
8010623d:	e8 84 a1 ff ff       	call   801003c6 <cprintf>
80106242:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106245:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010624b:	8b 40 18             	mov    0x18(%eax),%eax
8010624e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106255:	90                   	nop
80106256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106259:	c9                   	leave  
8010625a:	c3                   	ret    

8010625b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
8010625b:	55                   	push   %ebp
8010625c:	89 e5                	mov    %esp,%ebp
8010625e:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
80106261:	83 ec 08             	sub    $0x8,%esp
80106264:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106267:	50                   	push   %eax
80106268:	ff 75 08             	pushl  0x8(%ebp)
8010626b:	e8 af fe ff ff       	call   8010611f <argint>
80106270:	83 c4 10             	add    $0x10,%esp
80106273:	85 c0                	test   %eax,%eax
80106275:	79 07                	jns    8010627e <argfd+0x23>
        return -1;
80106277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627c:	eb 50                	jmp    801062ce <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
8010627e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106281:	85 c0                	test   %eax,%eax
80106283:	78 21                	js     801062a6 <argfd+0x4b>
80106285:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106288:	83 f8 0f             	cmp    $0xf,%eax
8010628b:	7f 19                	jg     801062a6 <argfd+0x4b>
8010628d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106293:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106296:	83 c2 08             	add    $0x8,%edx
80106299:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010629d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062a4:	75 07                	jne    801062ad <argfd+0x52>
        return -1;
801062a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ab:	eb 21                	jmp    801062ce <argfd+0x73>
    if (pfd)
801062ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062b1:	74 08                	je     801062bb <argfd+0x60>
        *pfd = fd;
801062b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801062b9:	89 10                	mov    %edx,(%eax)
    if (pf)
801062bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062bf:	74 08                	je     801062c9 <argfd+0x6e>
        *pf = f;
801062c1:	8b 45 10             	mov    0x10(%ebp),%eax
801062c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c7:	89 10                	mov    %edx,(%eax)
    return 0;
801062c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ce:	c9                   	leave  
801062cf:	c3                   	ret    

801062d0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062d0:	55                   	push   %ebp
801062d1:	89 e5                	mov    %esp,%ebp
801062d3:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062dd:	eb 30                	jmp    8010630f <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062e8:	83 c2 08             	add    $0x8,%edx
801062eb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062ef:	85 c0                	test   %eax,%eax
801062f1:	75 18                	jne    8010630b <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062fc:	8d 4a 08             	lea    0x8(%edx),%ecx
801062ff:	8b 55 08             	mov    0x8(%ebp),%edx
80106302:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
80106306:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106309:	eb 0f                	jmp    8010631a <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
8010630b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010630f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106313:	7e ca                	jle    801062df <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
80106315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010631a:	c9                   	leave  
8010631b:	c3                   	ret    

8010631c <sys_dup>:

int sys_dup(void)
{
8010631c:	55                   	push   %ebp
8010631d:	89 e5                	mov    %esp,%ebp
8010631f:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
80106322:	83 ec 04             	sub    $0x4,%esp
80106325:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106328:	50                   	push   %eax
80106329:	6a 00                	push   $0x0
8010632b:	6a 00                	push   $0x0
8010632d:	e8 29 ff ff ff       	call   8010625b <argfd>
80106332:	83 c4 10             	add    $0x10,%esp
80106335:	85 c0                	test   %eax,%eax
80106337:	79 07                	jns    80106340 <sys_dup+0x24>
        return -1;
80106339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633e:	eb 31                	jmp    80106371 <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106340:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106343:	83 ec 0c             	sub    $0xc,%esp
80106346:	50                   	push   %eax
80106347:	e8 84 ff ff ff       	call   801062d0 <fdalloc>
8010634c:	83 c4 10             	add    $0x10,%esp
8010634f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106352:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106356:	79 07                	jns    8010635f <sys_dup+0x43>
        return -1;
80106358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635d:	eb 12                	jmp    80106371 <sys_dup+0x55>
    filedup(f);
8010635f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106362:	83 ec 0c             	sub    $0xc,%esp
80106365:	50                   	push   %eax
80106366:	e8 ed ac ff ff       	call   80101058 <filedup>
8010636b:	83 c4 10             	add    $0x10,%esp
    return fd;
8010636e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106371:	c9                   	leave  
80106372:	c3                   	ret    

80106373 <sys_read>:

int sys_read(void)
{
80106373:	55                   	push   %ebp
80106374:	89 e5                	mov    %esp,%ebp
80106376:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106379:	83 ec 04             	sub    $0x4,%esp
8010637c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010637f:	50                   	push   %eax
80106380:	6a 00                	push   $0x0
80106382:	6a 00                	push   $0x0
80106384:	e8 d2 fe ff ff       	call   8010625b <argfd>
80106389:	83 c4 10             	add    $0x10,%esp
8010638c:	85 c0                	test   %eax,%eax
8010638e:	78 2e                	js     801063be <sys_read+0x4b>
80106390:	83 ec 08             	sub    $0x8,%esp
80106393:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106396:	50                   	push   %eax
80106397:	6a 02                	push   $0x2
80106399:	e8 81 fd ff ff       	call   8010611f <argint>
8010639e:	83 c4 10             	add    $0x10,%esp
801063a1:	85 c0                	test   %eax,%eax
801063a3:	78 19                	js     801063be <sys_read+0x4b>
801063a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a8:	83 ec 04             	sub    $0x4,%esp
801063ab:	50                   	push   %eax
801063ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063af:	50                   	push   %eax
801063b0:	6a 01                	push   $0x1
801063b2:	e8 90 fd ff ff       	call   80106147 <argptr>
801063b7:	83 c4 10             	add    $0x10,%esp
801063ba:	85 c0                	test   %eax,%eax
801063bc:	79 07                	jns    801063c5 <sys_read+0x52>
        return -1;
801063be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c3:	eb 17                	jmp    801063dc <sys_read+0x69>
    return fileread(f, p, n);
801063c5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ce:	83 ec 04             	sub    $0x4,%esp
801063d1:	51                   	push   %ecx
801063d2:	52                   	push   %edx
801063d3:	50                   	push   %eax
801063d4:	e8 37 ae ff ff       	call   80101210 <fileread>
801063d9:	83 c4 10             	add    $0x10,%esp
}
801063dc:	c9                   	leave  
801063dd:	c3                   	ret    

801063de <sys_write>:

int sys_write(void)
{
801063de:	55                   	push   %ebp
801063df:	89 e5                	mov    %esp,%ebp
801063e1:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063e4:	83 ec 04             	sub    $0x4,%esp
801063e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063ea:	50                   	push   %eax
801063eb:	6a 00                	push   $0x0
801063ed:	6a 00                	push   $0x0
801063ef:	e8 67 fe ff ff       	call   8010625b <argfd>
801063f4:	83 c4 10             	add    $0x10,%esp
801063f7:	85 c0                	test   %eax,%eax
801063f9:	78 2e                	js     80106429 <sys_write+0x4b>
801063fb:	83 ec 08             	sub    $0x8,%esp
801063fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106401:	50                   	push   %eax
80106402:	6a 02                	push   $0x2
80106404:	e8 16 fd ff ff       	call   8010611f <argint>
80106409:	83 c4 10             	add    $0x10,%esp
8010640c:	85 c0                	test   %eax,%eax
8010640e:	78 19                	js     80106429 <sys_write+0x4b>
80106410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106413:	83 ec 04             	sub    $0x4,%esp
80106416:	50                   	push   %eax
80106417:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010641a:	50                   	push   %eax
8010641b:	6a 01                	push   $0x1
8010641d:	e8 25 fd ff ff       	call   80106147 <argptr>
80106422:	83 c4 10             	add    $0x10,%esp
80106425:	85 c0                	test   %eax,%eax
80106427:	79 07                	jns    80106430 <sys_write+0x52>
        return -1;
80106429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642e:	eb 17                	jmp    80106447 <sys_write+0x69>
    return filewrite(f, p, n);
80106430:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106433:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106439:	83 ec 04             	sub    $0x4,%esp
8010643c:	51                   	push   %ecx
8010643d:	52                   	push   %edx
8010643e:	50                   	push   %eax
8010643f:	e8 84 ae ff ff       	call   801012c8 <filewrite>
80106444:	83 c4 10             	add    $0x10,%esp
}
80106447:	c9                   	leave  
80106448:	c3                   	ret    

80106449 <sys_close>:

int sys_close(void)
{
80106449:	55                   	push   %ebp
8010644a:	89 e5                	mov    %esp,%ebp
8010644c:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
8010644f:	83 ec 04             	sub    $0x4,%esp
80106452:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106455:	50                   	push   %eax
80106456:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106459:	50                   	push   %eax
8010645a:	6a 00                	push   $0x0
8010645c:	e8 fa fd ff ff       	call   8010625b <argfd>
80106461:	83 c4 10             	add    $0x10,%esp
80106464:	85 c0                	test   %eax,%eax
80106466:	79 07                	jns    8010646f <sys_close+0x26>
        return -1;
80106468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646d:	eb 28                	jmp    80106497 <sys_close+0x4e>
    proc->ofile[fd] = 0;
8010646f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106478:	83 c2 08             	add    $0x8,%edx
8010647b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106482:	00 
    fileclose(f);
80106483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106486:	83 ec 0c             	sub    $0xc,%esp
80106489:	50                   	push   %eax
8010648a:	e8 1a ac ff ff       	call   801010a9 <fileclose>
8010648f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106492:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106497:	c9                   	leave  
80106498:	c3                   	ret    

80106499 <sys_fstat>:

int sys_fstat(void)
{
80106499:	55                   	push   %ebp
8010649a:	89 e5                	mov    %esp,%ebp
8010649c:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010649f:	83 ec 04             	sub    $0x4,%esp
801064a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064a5:	50                   	push   %eax
801064a6:	6a 00                	push   $0x0
801064a8:	6a 00                	push   $0x0
801064aa:	e8 ac fd ff ff       	call   8010625b <argfd>
801064af:	83 c4 10             	add    $0x10,%esp
801064b2:	85 c0                	test   %eax,%eax
801064b4:	78 17                	js     801064cd <sys_fstat+0x34>
801064b6:	83 ec 04             	sub    $0x4,%esp
801064b9:	6a 14                	push   $0x14
801064bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064be:	50                   	push   %eax
801064bf:	6a 01                	push   $0x1
801064c1:	e8 81 fc ff ff       	call   80106147 <argptr>
801064c6:	83 c4 10             	add    $0x10,%esp
801064c9:	85 c0                	test   %eax,%eax
801064cb:	79 07                	jns    801064d4 <sys_fstat+0x3b>
        return -1;
801064cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d2:	eb 13                	jmp    801064e7 <sys_fstat+0x4e>
    return filestat(f, st);
801064d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064da:	83 ec 08             	sub    $0x8,%esp
801064dd:	52                   	push   %edx
801064de:	50                   	push   %eax
801064df:	e8 d5 ac ff ff       	call   801011b9 <filestat>
801064e4:	83 c4 10             	add    $0x10,%esp
}
801064e7:	c9                   	leave  
801064e8:	c3                   	ret    

801064e9 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064e9:	55                   	push   %ebp
801064ea:	89 e5                	mov    %esp,%ebp
801064ec:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064ef:	83 ec 08             	sub    $0x8,%esp
801064f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064f5:	50                   	push   %eax
801064f6:	6a 00                	push   $0x0
801064f8:	e8 a7 fc ff ff       	call   801061a4 <argstr>
801064fd:	83 c4 10             	add    $0x10,%esp
80106500:	85 c0                	test   %eax,%eax
80106502:	78 15                	js     80106519 <sys_link+0x30>
80106504:	83 ec 08             	sub    $0x8,%esp
80106507:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010650a:	50                   	push   %eax
8010650b:	6a 01                	push   $0x1
8010650d:	e8 92 fc ff ff       	call   801061a4 <argstr>
80106512:	83 c4 10             	add    $0x10,%esp
80106515:	85 c0                	test   %eax,%eax
80106517:	79 0a                	jns    80106523 <sys_link+0x3a>
        return -1;
80106519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651e:	e9 da 01 00 00       	jmp    801066fd <sys_link+0x214>

    begin_op(proc->cwd->part->number);
80106523:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106529:	8b 40 68             	mov    0x68(%eax),%eax
8010652c:	8b 40 50             	mov    0x50(%eax),%eax
8010652f:	8b 40 14             	mov    0x14(%eax),%eax
80106532:	83 ec 0c             	sub    $0xc,%esp
80106535:	50                   	push   %eax
80106536:	e8 7e d9 ff ff       	call   80103eb9 <begin_op>
8010653b:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
8010653e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106541:	83 ec 0c             	sub    $0xc,%esp
80106544:	50                   	push   %eax
80106545:	e8 c1 c7 ff ff       	call   80102d0b <namei>
8010654a:	83 c4 10             	add    $0x10,%esp
8010654d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106550:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106554:	75 25                	jne    8010657b <sys_link+0x92>
        end_op(proc->cwd->part->number);
80106556:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010655c:	8b 40 68             	mov    0x68(%eax),%eax
8010655f:	8b 40 50             	mov    0x50(%eax),%eax
80106562:	8b 40 14             	mov    0x14(%eax),%eax
80106565:	83 ec 0c             	sub    $0xc,%esp
80106568:	50                   	push   %eax
80106569:	e8 52 da ff ff       	call   80103fc0 <end_op>
8010656e:	83 c4 10             	add    $0x10,%esp
        return -1;
80106571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106576:	e9 82 01 00 00       	jmp    801066fd <sys_link+0x214>
    }

    ilock(ip);
8010657b:	83 ec 0c             	sub    $0xc,%esp
8010657e:	ff 75 f4             	pushl  -0xc(%ebp)
80106581:	e8 6c b9 ff ff       	call   80101ef2 <ilock>
80106586:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106590:	66 83 f8 01          	cmp    $0x1,%ax
80106594:	75 33                	jne    801065c9 <sys_link+0xe0>
        iunlockput(ip);
80106596:	83 ec 0c             	sub    $0xc,%esp
80106599:	ff 75 f4             	pushl  -0xc(%ebp)
8010659c:	e8 54 bc ff ff       	call   801021f5 <iunlockput>
801065a1:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
801065a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065aa:	8b 40 68             	mov    0x68(%eax),%eax
801065ad:	8b 40 50             	mov    0x50(%eax),%eax
801065b0:	8b 40 14             	mov    0x14(%eax),%eax
801065b3:	83 ec 0c             	sub    $0xc,%esp
801065b6:	50                   	push   %eax
801065b7:	e8 04 da ff ff       	call   80103fc0 <end_op>
801065bc:	83 c4 10             	add    $0x10,%esp
        return -1;
801065bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c4:	e9 34 01 00 00       	jmp    801066fd <sys_link+0x214>
    }

    ip->nlink++;
801065c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065d0:	83 c0 01             	add    $0x1,%eax
801065d3:	89 c2                	mov    %eax,%edx
801065d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065dc:	83 ec 0c             	sub    $0xc,%esp
801065df:	ff 75 f4             	pushl  -0xc(%ebp)
801065e2:	e8 ad b6 ff ff       	call   80101c94 <iupdate>
801065e7:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065ea:	83 ec 0c             	sub    $0xc,%esp
801065ed:	ff 75 f4             	pushl  -0xc(%ebp)
801065f0:	e8 9e ba ff ff       	call   80102093 <iunlock>
801065f5:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065fb:	83 ec 08             	sub    $0x8,%esp
801065fe:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106601:	52                   	push   %edx
80106602:	50                   	push   %eax
80106603:	e8 39 c7 ff ff       	call   80102d41 <nameiparent>
80106608:	83 c4 10             	add    $0x10,%esp
8010660b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010660e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106612:	0f 84 87 00 00 00    	je     8010669f <sys_link+0x1b6>
        goto bad;
    ilock(dp);
80106618:	83 ec 0c             	sub    $0xc,%esp
8010661b:	ff 75 f0             	pushl  -0x10(%ebp)
8010661e:	e8 cf b8 ff ff       	call   80101ef2 <ilock>
80106623:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
80106626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106629:	8b 10                	mov    (%eax),%edx
8010662b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662e:	8b 00                	mov    (%eax),%eax
80106630:	39 c2                	cmp    %eax,%edx
80106632:	75 1d                	jne    80106651 <sys_link+0x168>
80106634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106637:	8b 40 04             	mov    0x4(%eax),%eax
8010663a:	83 ec 04             	sub    $0x4,%esp
8010663d:	50                   	push   %eax
8010663e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106641:	50                   	push   %eax
80106642:	ff 75 f0             	pushl  -0x10(%ebp)
80106645:	e8 93 c3 ff ff       	call   801029dd <dirlink>
8010664a:	83 c4 10             	add    $0x10,%esp
8010664d:	85 c0                	test   %eax,%eax
8010664f:	79 10                	jns    80106661 <sys_link+0x178>
        iunlockput(dp);
80106651:	83 ec 0c             	sub    $0xc,%esp
80106654:	ff 75 f0             	pushl  -0x10(%ebp)
80106657:	e8 99 bb ff ff       	call   801021f5 <iunlockput>
8010665c:	83 c4 10             	add    $0x10,%esp
        goto bad;
8010665f:	eb 3f                	jmp    801066a0 <sys_link+0x1b7>
    }
    iunlockput(dp);
80106661:	83 ec 0c             	sub    $0xc,%esp
80106664:	ff 75 f0             	pushl  -0x10(%ebp)
80106667:	e8 89 bb ff ff       	call   801021f5 <iunlockput>
8010666c:	83 c4 10             	add    $0x10,%esp
    iput(ip);
8010666f:	83 ec 0c             	sub    $0xc,%esp
80106672:	ff 75 f4             	pushl  -0xc(%ebp)
80106675:	e8 8b ba ff ff       	call   80102105 <iput>
8010667a:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010667d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106683:	8b 40 68             	mov    0x68(%eax),%eax
80106686:	8b 40 50             	mov    0x50(%eax),%eax
80106689:	8b 40 14             	mov    0x14(%eax),%eax
8010668c:	83 ec 0c             	sub    $0xc,%esp
8010668f:	50                   	push   %eax
80106690:	e8 2b d9 ff ff       	call   80103fc0 <end_op>
80106695:	83 c4 10             	add    $0x10,%esp

    return 0;
80106698:	b8 00 00 00 00       	mov    $0x0,%eax
8010669d:	eb 5e                	jmp    801066fd <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
8010669f:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
801066a0:	83 ec 0c             	sub    $0xc,%esp
801066a3:	ff 75 f4             	pushl  -0xc(%ebp)
801066a6:	e8 47 b8 ff ff       	call   80101ef2 <ilock>
801066ab:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
801066ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066b5:	83 e8 01             	sub    $0x1,%eax
801066b8:	89 c2                	mov    %eax,%edx
801066ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bd:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801066c1:	83 ec 0c             	sub    $0xc,%esp
801066c4:	ff 75 f4             	pushl  -0xc(%ebp)
801066c7:	e8 c8 b5 ff ff       	call   80101c94 <iupdate>
801066cc:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066cf:	83 ec 0c             	sub    $0xc,%esp
801066d2:	ff 75 f4             	pushl  -0xc(%ebp)
801066d5:	e8 1b bb ff ff       	call   801021f5 <iunlockput>
801066da:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066e3:	8b 40 68             	mov    0x68(%eax),%eax
801066e6:	8b 40 50             	mov    0x50(%eax),%eax
801066e9:	8b 40 14             	mov    0x14(%eax),%eax
801066ec:	83 ec 0c             	sub    $0xc,%esp
801066ef:	50                   	push   %eax
801066f0:	e8 cb d8 ff ff       	call   80103fc0 <end_op>
801066f5:	83 c4 10             	add    $0x10,%esp
    return -1;
801066f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066fd:	c9                   	leave  
801066fe:	c3                   	ret    

801066ff <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066ff:	55                   	push   %ebp
80106700:	89 e5                	mov    %esp,%ebp
80106702:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80106705:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010670c:	eb 40                	jmp    8010674e <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010670e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106711:	6a 10                	push   $0x10
80106713:	50                   	push   %eax
80106714:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106717:	50                   	push   %eax
80106718:	ff 75 08             	pushl  0x8(%ebp)
8010671b:	e8 60 be ff ff       	call   80102580 <readi>
80106720:	83 c4 10             	add    $0x10,%esp
80106723:	83 f8 10             	cmp    $0x10,%eax
80106726:	74 0d                	je     80106735 <isdirempty+0x36>
            panic("isdirempty: readi");
80106728:	83 ec 0c             	sub    $0xc,%esp
8010672b:	68 92 99 10 80       	push   $0x80109992
80106730:	e8 31 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
80106735:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106739:	66 85 c0             	test   %ax,%ax
8010673c:	74 07                	je     80106745 <isdirempty+0x46>
            return 0;
8010673e:	b8 00 00 00 00       	mov    $0x0,%eax
80106743:	eb 1b                	jmp    80106760 <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80106745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106748:	83 c0 10             	add    $0x10,%eax
8010674b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010674e:	8b 45 08             	mov    0x8(%ebp),%eax
80106751:	8b 50 18             	mov    0x18(%eax),%edx
80106754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106757:	39 c2                	cmp    %eax,%edx
80106759:	77 b3                	ja     8010670e <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
8010675b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106760:	c9                   	leave  
80106761:	c3                   	ret    

80106762 <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
80106762:	55                   	push   %ebp
80106763:	89 e5                	mov    %esp,%ebp
80106765:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106768:	83 ec 08             	sub    $0x8,%esp
8010676b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010676e:	50                   	push   %eax
8010676f:	6a 00                	push   $0x0
80106771:	e8 2e fa ff ff       	call   801061a4 <argstr>
80106776:	83 c4 10             	add    $0x10,%esp
80106779:	85 c0                	test   %eax,%eax
8010677b:	79 0a                	jns    80106787 <sys_unlink+0x25>
        return -1;
8010677d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106782:	e9 14 02 00 00       	jmp    8010699b <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
80106787:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010678d:	8b 40 68             	mov    0x68(%eax),%eax
80106790:	8b 40 50             	mov    0x50(%eax),%eax
80106793:	8b 40 14             	mov    0x14(%eax),%eax
80106796:	83 ec 0c             	sub    $0xc,%esp
80106799:	50                   	push   %eax
8010679a:	e8 1a d7 ff ff       	call   80103eb9 <begin_op>
8010679f:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
801067a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801067a5:	83 ec 08             	sub    $0x8,%esp
801067a8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801067ab:	52                   	push   %edx
801067ac:	50                   	push   %eax
801067ad:	e8 8f c5 ff ff       	call   80102d41 <nameiparent>
801067b2:	83 c4 10             	add    $0x10,%esp
801067b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067bc:	75 25                	jne    801067e3 <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
801067be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067c4:	8b 40 68             	mov    0x68(%eax),%eax
801067c7:	8b 40 50             	mov    0x50(%eax),%eax
801067ca:	8b 40 14             	mov    0x14(%eax),%eax
801067cd:	83 ec 0c             	sub    $0xc,%esp
801067d0:	50                   	push   %eax
801067d1:	e8 ea d7 ff ff       	call   80103fc0 <end_op>
801067d6:	83 c4 10             	add    $0x10,%esp
        return -1;
801067d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067de:	e9 b8 01 00 00       	jmp    8010699b <sys_unlink+0x239>
    }

    ilock(dp);
801067e3:	83 ec 0c             	sub    $0xc,%esp
801067e6:	ff 75 f4             	pushl  -0xc(%ebp)
801067e9:	e8 04 b7 ff ff       	call   80101ef2 <ilock>
801067ee:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067f1:	83 ec 08             	sub    $0x8,%esp
801067f4:	68 a4 99 10 80       	push   $0x801099a4
801067f9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067fc:	50                   	push   %eax
801067fd:	e8 f9 c0 ff ff       	call   801028fb <namecmp>
80106802:	83 c4 10             	add    $0x10,%esp
80106805:	85 c0                	test   %eax,%eax
80106807:	0f 84 60 01 00 00    	je     8010696d <sys_unlink+0x20b>
8010680d:	83 ec 08             	sub    $0x8,%esp
80106810:	68 a6 99 10 80       	push   $0x801099a6
80106815:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106818:	50                   	push   %eax
80106819:	e8 dd c0 ff ff       	call   801028fb <namecmp>
8010681e:	83 c4 10             	add    $0x10,%esp
80106821:	85 c0                	test   %eax,%eax
80106823:	0f 84 44 01 00 00    	je     8010696d <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
80106829:	83 ec 04             	sub    $0x4,%esp
8010682c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010682f:	50                   	push   %eax
80106830:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106833:	50                   	push   %eax
80106834:	ff 75 f4             	pushl  -0xc(%ebp)
80106837:	e8 da c0 ff ff       	call   80102916 <dirlookup>
8010683c:	83 c4 10             	add    $0x10,%esp
8010683f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106842:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106846:	0f 84 20 01 00 00    	je     8010696c <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
8010684c:	83 ec 0c             	sub    $0xc,%esp
8010684f:	ff 75 f0             	pushl  -0x10(%ebp)
80106852:	e8 9b b6 ff ff       	call   80101ef2 <ilock>
80106857:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
8010685a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106861:	66 85 c0             	test   %ax,%ax
80106864:	7f 0d                	jg     80106873 <sys_unlink+0x111>
        panic("unlink: nlink < 1");
80106866:	83 ec 0c             	sub    $0xc,%esp
80106869:	68 a9 99 10 80       	push   $0x801099a9
8010686e:	e8 f3 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
80106873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106876:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010687a:	66 83 f8 01          	cmp    $0x1,%ax
8010687e:	75 25                	jne    801068a5 <sys_unlink+0x143>
80106880:	83 ec 0c             	sub    $0xc,%esp
80106883:	ff 75 f0             	pushl  -0x10(%ebp)
80106886:	e8 74 fe ff ff       	call   801066ff <isdirempty>
8010688b:	83 c4 10             	add    $0x10,%esp
8010688e:	85 c0                	test   %eax,%eax
80106890:	75 13                	jne    801068a5 <sys_unlink+0x143>
        iunlockput(ip);
80106892:	83 ec 0c             	sub    $0xc,%esp
80106895:	ff 75 f0             	pushl  -0x10(%ebp)
80106898:	e8 58 b9 ff ff       	call   801021f5 <iunlockput>
8010689d:	83 c4 10             	add    $0x10,%esp
        goto bad;
801068a0:	e9 c8 00 00 00       	jmp    8010696d <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
801068a5:	83 ec 04             	sub    $0x4,%esp
801068a8:	6a 10                	push   $0x10
801068aa:	6a 00                	push   $0x0
801068ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068af:	50                   	push   %eax
801068b0:	e8 45 f5 ff ff       	call   80105dfa <memset>
801068b5:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801068b8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801068bb:	6a 10                	push   $0x10
801068bd:	50                   	push   %eax
801068be:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068c1:	50                   	push   %eax
801068c2:	ff 75 f4             	pushl  -0xc(%ebp)
801068c5:	e8 56 be ff ff       	call   80102720 <writei>
801068ca:	83 c4 10             	add    $0x10,%esp
801068cd:	83 f8 10             	cmp    $0x10,%eax
801068d0:	74 0d                	je     801068df <sys_unlink+0x17d>
        panic("unlink: writei");
801068d2:	83 ec 0c             	sub    $0xc,%esp
801068d5:	68 bb 99 10 80       	push   $0x801099bb
801068da:	e8 87 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068e6:	66 83 f8 01          	cmp    $0x1,%ax
801068ea:	75 21                	jne    8010690d <sys_unlink+0x1ab>
        dp->nlink--;
801068ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ef:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068f3:	83 e8 01             	sub    $0x1,%eax
801068f6:	89 c2                	mov    %eax,%edx
801068f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fb:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068ff:	83 ec 0c             	sub    $0xc,%esp
80106902:	ff 75 f4             	pushl  -0xc(%ebp)
80106905:	e8 8a b3 ff ff       	call   80101c94 <iupdate>
8010690a:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
8010690d:	83 ec 0c             	sub    $0xc,%esp
80106910:	ff 75 f4             	pushl  -0xc(%ebp)
80106913:	e8 dd b8 ff ff       	call   801021f5 <iunlockput>
80106918:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
8010691b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010691e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106922:	83 e8 01             	sub    $0x1,%eax
80106925:	89 c2                	mov    %eax,%edx
80106927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010692a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
8010692e:	83 ec 0c             	sub    $0xc,%esp
80106931:	ff 75 f0             	pushl  -0x10(%ebp)
80106934:	e8 5b b3 ff ff       	call   80101c94 <iupdate>
80106939:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010693c:	83 ec 0c             	sub    $0xc,%esp
8010693f:	ff 75 f0             	pushl  -0x10(%ebp)
80106942:	e8 ae b8 ff ff       	call   801021f5 <iunlockput>
80106947:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010694a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106950:	8b 40 68             	mov    0x68(%eax),%eax
80106953:	8b 40 50             	mov    0x50(%eax),%eax
80106956:	8b 40 14             	mov    0x14(%eax),%eax
80106959:	83 ec 0c             	sub    $0xc,%esp
8010695c:	50                   	push   %eax
8010695d:	e8 5e d6 ff ff       	call   80103fc0 <end_op>
80106962:	83 c4 10             	add    $0x10,%esp

    return 0;
80106965:	b8 00 00 00 00       	mov    $0x0,%eax
8010696a:	eb 2f                	jmp    8010699b <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
8010696c:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
8010696d:	83 ec 0c             	sub    $0xc,%esp
80106970:	ff 75 f4             	pushl  -0xc(%ebp)
80106973:	e8 7d b8 ff ff       	call   801021f5 <iunlockput>
80106978:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
8010697b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106981:	8b 40 68             	mov    0x68(%eax),%eax
80106984:	8b 40 50             	mov    0x50(%eax),%eax
80106987:	8b 40 14             	mov    0x14(%eax),%eax
8010698a:	83 ec 0c             	sub    $0xc,%esp
8010698d:	50                   	push   %eax
8010698e:	e8 2d d6 ff ff       	call   80103fc0 <end_op>
80106993:	83 c4 10             	add    $0x10,%esp
    return -1;
80106996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010699b:	c9                   	leave  
8010699c:	c3                   	ret    

8010699d <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
8010699d:	55                   	push   %ebp
8010699e:	89 e5                	mov    %esp,%ebp
801069a0:	83 ec 38             	sub    $0x38,%esp
801069a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801069a6:	8b 55 10             	mov    0x10(%ebp),%edx
801069a9:	8b 45 14             	mov    0x14(%ebp),%eax
801069ac:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801069b0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801069b4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
     //cprintf("path %s\n",path);
    if ((dp = nameiparent(path, name)) == 0)
801069b8:	83 ec 08             	sub    $0x8,%esp
801069bb:	8d 45 de             	lea    -0x22(%ebp),%eax
801069be:	50                   	push   %eax
801069bf:	ff 75 08             	pushl  0x8(%ebp)
801069c2:	e8 7a c3 ff ff       	call   80102d41 <nameiparent>
801069c7:	83 c4 10             	add    $0x10,%esp
801069ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069d1:	75 0a                	jne    801069dd <create+0x40>
        return 0;
801069d3:	b8 00 00 00 00       	mov    $0x0,%eax
801069d8:	e9 fe 01 00 00       	jmp    80106bdb <create+0x23e>
        
             //cprintf("name %s  \n",name);

    ilock(dp);
801069dd:	83 ec 0c             	sub    $0xc,%esp
801069e0:	ff 75 f4             	pushl  -0xc(%ebp)
801069e3:	e8 0a b5 ff ff       	call   80101ef2 <ilock>
801069e8:	83 c4 10             	add    $0x10,%esp
    if(dp->part->number!=proc->cwd->part->number){
801069eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ee:	8b 40 50             	mov    0x50(%eax),%eax
801069f1:	8b 50 14             	mov    0x14(%eax),%edx
801069f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069fa:	8b 40 68             	mov    0x68(%eax),%eax
801069fd:	8b 40 50             	mov    0x50(%eax),%eax
80106a00:	8b 40 14             	mov    0x14(%eax),%eax
80106a03:	39 c2                	cmp    %eax,%edx
80106a05:	74 15                	je     80106a1c <create+0x7f>
        begin_op(dp->part->number);
80106a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0a:	8b 40 50             	mov    0x50(%eax),%eax
80106a0d:	8b 40 14             	mov    0x14(%eax),%eax
80106a10:	83 ec 0c             	sub    $0xc,%esp
80106a13:	50                   	push   %eax
80106a14:	e8 a0 d4 ff ff       	call   80103eb9 <begin_op>
80106a19:	83 c4 10             	add    $0x10,%esp
    }
    if ((ip = dirlookup(dp, name, &off)) != 0) {
80106a1c:	83 ec 04             	sub    $0x4,%esp
80106a1f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a22:	50                   	push   %eax
80106a23:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a26:	50                   	push   %eax
80106a27:	ff 75 f4             	pushl  -0xc(%ebp)
80106a2a:	e8 e7 be ff ff       	call   80102916 <dirlookup>
80106a2f:	83 c4 10             	add    $0x10,%esp
80106a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a39:	74 50                	je     80106a8b <create+0xee>
        iunlockput(dp);
80106a3b:	83 ec 0c             	sub    $0xc,%esp
80106a3e:	ff 75 f4             	pushl  -0xc(%ebp)
80106a41:	e8 af b7 ff ff       	call   801021f5 <iunlockput>
80106a46:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80106a49:	83 ec 0c             	sub    $0xc,%esp
80106a4c:	ff 75 f0             	pushl  -0x10(%ebp)
80106a4f:	e8 9e b4 ff ff       	call   80101ef2 <ilock>
80106a54:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
80106a57:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a5c:	75 15                	jne    80106a73 <create+0xd6>
80106a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a61:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a65:	66 83 f8 02          	cmp    $0x2,%ax
80106a69:	75 08                	jne    80106a73 <create+0xd6>
            return ip;
80106a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a6e:	e9 68 01 00 00       	jmp    80106bdb <create+0x23e>
        iunlockput(ip);
80106a73:	83 ec 0c             	sub    $0xc,%esp
80106a76:	ff 75 f0             	pushl  -0x10(%ebp)
80106a79:	e8 77 b7 ff ff       	call   801021f5 <iunlockput>
80106a7e:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a81:	b8 00 00 00 00       	mov    $0x0,%eax
80106a86:	e9 50 01 00 00       	jmp    80106bdb <create+0x23e>
    }
    //cprintf("dp is %d , %d \n",dp->inum, dp->part->number);
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8e:	8b 40 50             	mov    0x50(%eax),%eax
80106a91:	8b 40 14             	mov    0x14(%eax),%eax
80106a94:	89 c1                	mov    %eax,%ecx
80106a96:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9d:	8b 00                	mov    (%eax),%eax
80106a9f:	83 ec 04             	sub    $0x4,%esp
80106aa2:	51                   	push   %ecx
80106aa3:	52                   	push   %edx
80106aa4:	50                   	push   %eax
80106aa5:	e8 d1 b0 ff ff       	call   80101b7b <ialloc>
80106aaa:	83 c4 10             	add    $0x10,%esp
80106aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ab0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ab4:	75 0d                	jne    80106ac3 <create+0x126>
        panic("create: ialloc");
80106ab6:	83 ec 0c             	sub    $0xc,%esp
80106ab9:	68 ca 99 10 80       	push   $0x801099ca
80106abe:	e8 a3 9a ff ff       	call   80100566 <panic>

    ilock(ip);
80106ac3:	83 ec 0c             	sub    $0xc,%esp
80106ac6:	ff 75 f0             	pushl  -0x10(%ebp)
80106ac9:	e8 24 b4 ff ff       	call   80101ef2 <ilock>
80106ace:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ad4:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106ad8:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106adf:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106ae3:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aea:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
   // cprintf("ip is %d , %d \n",ip->inum,ip->part->number);
    iupdate(ip);
80106af0:	83 ec 0c             	sub    $0xc,%esp
80106af3:	ff 75 f0             	pushl  -0x10(%ebp)
80106af6:	e8 99 b1 ff ff       	call   80101c94 <iupdate>
80106afb:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106afe:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106b03:	75 6a                	jne    80106b6f <create+0x1d2>
        dp->nlink++;     // for ".."
80106b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b08:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b0c:	83 c0 01             	add    $0x1,%eax
80106b0f:	89 c2                	mov    %eax,%edx
80106b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b14:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106b18:	83 ec 0c             	sub    $0xc,%esp
80106b1b:	ff 75 f4             	pushl  -0xc(%ebp)
80106b1e:	e8 71 b1 ff ff       	call   80101c94 <iupdate>
80106b23:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b29:	8b 40 04             	mov    0x4(%eax),%eax
80106b2c:	83 ec 04             	sub    $0x4,%esp
80106b2f:	50                   	push   %eax
80106b30:	68 a4 99 10 80       	push   $0x801099a4
80106b35:	ff 75 f0             	pushl  -0x10(%ebp)
80106b38:	e8 a0 be ff ff       	call   801029dd <dirlink>
80106b3d:	83 c4 10             	add    $0x10,%esp
80106b40:	85 c0                	test   %eax,%eax
80106b42:	78 1e                	js     80106b62 <create+0x1c5>
80106b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b47:	8b 40 04             	mov    0x4(%eax),%eax
80106b4a:	83 ec 04             	sub    $0x4,%esp
80106b4d:	50                   	push   %eax
80106b4e:	68 a6 99 10 80       	push   $0x801099a6
80106b53:	ff 75 f0             	pushl  -0x10(%ebp)
80106b56:	e8 82 be ff ff       	call   801029dd <dirlink>
80106b5b:	83 c4 10             	add    $0x10,%esp
80106b5e:	85 c0                	test   %eax,%eax
80106b60:	79 0d                	jns    80106b6f <create+0x1d2>
            panic("create dots");
80106b62:	83 ec 0c             	sub    $0xc,%esp
80106b65:	68 d9 99 10 80       	push   $0x801099d9
80106b6a:	e8 f7 99 ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b72:	8b 40 04             	mov    0x4(%eax),%eax
80106b75:	83 ec 04             	sub    $0x4,%esp
80106b78:	50                   	push   %eax
80106b79:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b7c:	50                   	push   %eax
80106b7d:	ff 75 f4             	pushl  -0xc(%ebp)
80106b80:	e8 58 be ff ff       	call   801029dd <dirlink>
80106b85:	83 c4 10             	add    $0x10,%esp
80106b88:	85 c0                	test   %eax,%eax
80106b8a:	79 0d                	jns    80106b99 <create+0x1fc>
        panic("create: dirlink");
80106b8c:	83 ec 0c             	sub    $0xc,%esp
80106b8f:	68 e5 99 10 80       	push   $0x801099e5
80106b94:	e8 cd 99 ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b99:	83 ec 0c             	sub    $0xc,%esp
80106b9c:	ff 75 f4             	pushl  -0xc(%ebp)
80106b9f:	e8 51 b6 ff ff       	call   801021f5 <iunlockput>
80106ba4:	83 c4 10             	add    $0x10,%esp
    
     if(dp->part->number!=proc->cwd->part->number){
80106ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106baa:	8b 40 50             	mov    0x50(%eax),%eax
80106bad:	8b 50 14             	mov    0x14(%eax),%edx
80106bb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb6:	8b 40 68             	mov    0x68(%eax),%eax
80106bb9:	8b 40 50             	mov    0x50(%eax),%eax
80106bbc:	8b 40 14             	mov    0x14(%eax),%eax
80106bbf:	39 c2                	cmp    %eax,%edx
80106bc1:	74 15                	je     80106bd8 <create+0x23b>
        end_op(dp->part->number);
80106bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc6:	8b 40 50             	mov    0x50(%eax),%eax
80106bc9:	8b 40 14             	mov    0x14(%eax),%eax
80106bcc:	83 ec 0c             	sub    $0xc,%esp
80106bcf:	50                   	push   %eax
80106bd0:	e8 eb d3 ff ff       	call   80103fc0 <end_op>
80106bd5:	83 c4 10             	add    $0x10,%esp
    }
    return ip;
80106bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106bdb:	c9                   	leave  
80106bdc:	c3                   	ret    

80106bdd <sys_open>:

int sys_open(void)
{
80106bdd:	55                   	push   %ebp
80106bde:	89 e5                	mov    %esp,%ebp
80106be0:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106be3:	83 ec 08             	sub    $0x8,%esp
80106be6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106be9:	50                   	push   %eax
80106bea:	6a 00                	push   $0x0
80106bec:	e8 b3 f5 ff ff       	call   801061a4 <argstr>
80106bf1:	83 c4 10             	add    $0x10,%esp
80106bf4:	85 c0                	test   %eax,%eax
80106bf6:	78 15                	js     80106c0d <sys_open+0x30>
80106bf8:	83 ec 08             	sub    $0x8,%esp
80106bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bfe:	50                   	push   %eax
80106bff:	6a 01                	push   $0x1
80106c01:	e8 19 f5 ff ff       	call   8010611f <argint>
80106c06:	83 c4 10             	add    $0x10,%esp
80106c09:	85 c0                	test   %eax,%eax
80106c0b:	79 07                	jns    80106c14 <sys_open+0x37>
        return -1;
80106c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c12:	eb 13                	jmp    80106c27 <sys_open+0x4a>

    return openFile(path, omode);
80106c14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1a:	83 ec 08             	sub    $0x8,%esp
80106c1d:	52                   	push   %edx
80106c1e:	50                   	push   %eax
80106c1f:	e8 05 00 00 00       	call   80106c29 <openFile>
80106c24:	83 c4 10             	add    $0x10,%esp
}
80106c27:	c9                   	leave  
80106c28:	c3                   	ret    

80106c29 <openFile>:

int openFile(char* path, int omode)
{
80106c29:	55                   	push   %ebp
80106c2a:	89 e5                	mov    %esp,%ebp
80106c2c:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106c2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c35:	8b 40 68             	mov    0x68(%eax),%eax
80106c38:	8b 40 50             	mov    0x50(%eax),%eax
80106c3b:	8b 40 14             	mov    0x14(%eax),%eax
80106c3e:	83 ec 0c             	sub    $0xc,%esp
80106c41:	50                   	push   %eax
80106c42:	e8 72 d2 ff ff       	call   80103eb9 <begin_op>
80106c47:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c4d:	25 00 02 00 00       	and    $0x200,%eax
80106c52:	85 c0                	test   %eax,%eax
80106c54:	74 43                	je     80106c99 <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106c56:	6a 00                	push   $0x0
80106c58:	6a 00                	push   $0x0
80106c5a:	6a 02                	push   $0x2
80106c5c:	ff 75 08             	pushl  0x8(%ebp)
80106c5f:	e8 39 fd ff ff       	call   8010699d <create>
80106c64:	83 c4 10             	add    $0x10,%esp
80106c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106c6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c6e:	0f 85 b5 00 00 00    	jne    80106d29 <openFile+0x100>
            end_op(proc->cwd->part->number);
80106c74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c7a:	8b 40 68             	mov    0x68(%eax),%eax
80106c7d:	8b 40 50             	mov    0x50(%eax),%eax
80106c80:	8b 40 14             	mov    0x14(%eax),%eax
80106c83:	83 ec 0c             	sub    $0xc,%esp
80106c86:	50                   	push   %eax
80106c87:	e8 34 d3 ff ff       	call   80103fc0 <end_op>
80106c8c:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c94:	e9 7f 01 00 00       	jmp    80106e18 <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c99:	83 ec 0c             	sub    $0xc,%esp
80106c9c:	ff 75 08             	pushl  0x8(%ebp)
80106c9f:	e8 67 c0 ff ff       	call   80102d0b <namei>
80106ca4:	83 c4 10             	add    $0x10,%esp
80106ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106caa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cae:	75 25                	jne    80106cd5 <openFile+0xac>
            end_op(proc->cwd->part->number);
80106cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cb6:	8b 40 68             	mov    0x68(%eax),%eax
80106cb9:	8b 40 50             	mov    0x50(%eax),%eax
80106cbc:	8b 40 14             	mov    0x14(%eax),%eax
80106cbf:	83 ec 0c             	sub    $0xc,%esp
80106cc2:	50                   	push   %eax
80106cc3:	e8 f8 d2 ff ff       	call   80103fc0 <end_op>
80106cc8:	83 c4 10             	add    $0x10,%esp
            return -1;
80106ccb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cd0:	e9 43 01 00 00       	jmp    80106e18 <openFile+0x1ef>
        }
        ilock(ip);
80106cd5:	83 ec 0c             	sub    $0xc,%esp
80106cd8:	ff 75 f4             	pushl  -0xc(%ebp)
80106cdb:	e8 12 b2 ff ff       	call   80101ef2 <ilock>
80106ce0:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106cea:	66 83 f8 01          	cmp    $0x1,%ax
80106cee:	75 39                	jne    80106d29 <openFile+0x100>
80106cf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106cf4:	74 33                	je     80106d29 <openFile+0x100>
            iunlockput(ip);
80106cf6:	83 ec 0c             	sub    $0xc,%esp
80106cf9:	ff 75 f4             	pushl  -0xc(%ebp)
80106cfc:	e8 f4 b4 ff ff       	call   801021f5 <iunlockput>
80106d01:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106d04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0a:	8b 40 68             	mov    0x68(%eax),%eax
80106d0d:	8b 40 50             	mov    0x50(%eax),%eax
80106d10:	8b 40 14             	mov    0x14(%eax),%eax
80106d13:	83 ec 0c             	sub    $0xc,%esp
80106d16:	50                   	push   %eax
80106d17:	e8 a4 d2 ff ff       	call   80103fc0 <end_op>
80106d1c:	83 c4 10             	add    $0x10,%esp
            return -1;
80106d1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d24:	e9 ef 00 00 00       	jmp    80106e18 <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106d29:	e8 bd a2 ff ff       	call   80100feb <filealloc>
80106d2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d35:	74 17                	je     80106d4e <openFile+0x125>
80106d37:	83 ec 0c             	sub    $0xc,%esp
80106d3a:	ff 75 f0             	pushl  -0x10(%ebp)
80106d3d:	e8 8e f5 ff ff       	call   801062d0 <fdalloc>
80106d42:	83 c4 10             	add    $0x10,%esp
80106d45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106d48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106d4c:	79 47                	jns    80106d95 <openFile+0x16c>
        if (f)
80106d4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d52:	74 0e                	je     80106d62 <openFile+0x139>
            fileclose(f);
80106d54:	83 ec 0c             	sub    $0xc,%esp
80106d57:	ff 75 f0             	pushl  -0x10(%ebp)
80106d5a:	e8 4a a3 ff ff       	call   801010a9 <fileclose>
80106d5f:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106d62:	83 ec 0c             	sub    $0xc,%esp
80106d65:	ff 75 f4             	pushl  -0xc(%ebp)
80106d68:	e8 88 b4 ff ff       	call   801021f5 <iunlockput>
80106d6d:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106d70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d76:	8b 40 68             	mov    0x68(%eax),%eax
80106d79:	8b 40 50             	mov    0x50(%eax),%eax
80106d7c:	8b 40 14             	mov    0x14(%eax),%eax
80106d7f:	83 ec 0c             	sub    $0xc,%esp
80106d82:	50                   	push   %eax
80106d83:	e8 38 d2 ff ff       	call   80103fc0 <end_op>
80106d88:	83 c4 10             	add    $0x10,%esp
        return -1;
80106d8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d90:	e9 83 00 00 00       	jmp    80106e18 <openFile+0x1ef>
    }
    iunlock(ip);
80106d95:	83 ec 0c             	sub    $0xc,%esp
80106d98:	ff 75 f4             	pushl  -0xc(%ebp)
80106d9b:	e8 f3 b2 ff ff       	call   80102093 <iunlock>
80106da0:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106da3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106da9:	8b 40 68             	mov    0x68(%eax),%eax
80106dac:	8b 40 50             	mov    0x50(%eax),%eax
80106daf:	8b 40 14             	mov    0x14(%eax),%eax
80106db2:	83 ec 0c             	sub    $0xc,%esp
80106db5:	50                   	push   %eax
80106db6:	e8 05 d2 ff ff       	call   80103fc0 <end_op>
80106dbb:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106dcd:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dd3:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106dda:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ddd:	83 e0 01             	and    $0x1,%eax
80106de0:	85 c0                	test   %eax,%eax
80106de2:	0f 94 c0             	sete   %al
80106de5:	89 c2                	mov    %eax,%edx
80106de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dea:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106ded:	8b 45 0c             	mov    0xc(%ebp),%eax
80106df0:	83 e0 01             	and    $0x1,%eax
80106df3:	85 c0                	test   %eax,%eax
80106df5:	75 0a                	jne    80106e01 <openFile+0x1d8>
80106df7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dfa:	83 e0 02             	and    $0x2,%eax
80106dfd:	85 c0                	test   %eax,%eax
80106dff:	74 07                	je     80106e08 <openFile+0x1df>
80106e01:	b8 01 00 00 00       	mov    $0x1,%eax
80106e06:	eb 05                	jmp    80106e0d <openFile+0x1e4>
80106e08:	b8 00 00 00 00       	mov    $0x0,%eax
80106e0d:	89 c2                	mov    %eax,%edx
80106e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e12:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106e15:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106e18:	c9                   	leave  
80106e19:	c3                   	ret    

80106e1a <sys_mkdir>:

int sys_mkdir(void)
{
80106e1a:	55                   	push   %ebp
80106e1b:	89 e5                	mov    %esp,%ebp
80106e1d:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106e20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e26:	8b 40 68             	mov    0x68(%eax),%eax
80106e29:	8b 40 50             	mov    0x50(%eax),%eax
80106e2c:	8b 40 14             	mov    0x14(%eax),%eax
80106e2f:	83 ec 0c             	sub    $0xc,%esp
80106e32:	50                   	push   %eax
80106e33:	e8 81 d0 ff ff       	call   80103eb9 <begin_op>
80106e38:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106e3b:	83 ec 08             	sub    $0x8,%esp
80106e3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e41:	50                   	push   %eax
80106e42:	6a 00                	push   $0x0
80106e44:	e8 5b f3 ff ff       	call   801061a4 <argstr>
80106e49:	83 c4 10             	add    $0x10,%esp
80106e4c:	85 c0                	test   %eax,%eax
80106e4e:	78 1b                	js     80106e6b <sys_mkdir+0x51>
80106e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e53:	6a 00                	push   $0x0
80106e55:	6a 00                	push   $0x0
80106e57:	6a 01                	push   $0x1
80106e59:	50                   	push   %eax
80106e5a:	e8 3e fb ff ff       	call   8010699d <create>
80106e5f:	83 c4 10             	add    $0x10,%esp
80106e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e69:	75 22                	jne    80106e8d <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106e6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e71:	8b 40 68             	mov    0x68(%eax),%eax
80106e74:	8b 40 50             	mov    0x50(%eax),%eax
80106e77:	8b 40 14             	mov    0x14(%eax),%eax
80106e7a:	83 ec 0c             	sub    $0xc,%esp
80106e7d:	50                   	push   %eax
80106e7e:	e8 3d d1 ff ff       	call   80103fc0 <end_op>
80106e83:	83 c4 10             	add    $0x10,%esp
        return -1;
80106e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8b:	eb 2e                	jmp    80106ebb <sys_mkdir+0xa1>
    }
    //cprintf("returned \n");
    iunlockput(ip);
80106e8d:	83 ec 0c             	sub    $0xc,%esp
80106e90:	ff 75 f4             	pushl  -0xc(%ebp)
80106e93:	e8 5d b3 ff ff       	call   801021f5 <iunlockput>
80106e98:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ea1:	8b 40 68             	mov    0x68(%eax),%eax
80106ea4:	8b 40 50             	mov    0x50(%eax),%eax
80106ea7:	8b 40 14             	mov    0x14(%eax),%eax
80106eaa:	83 ec 0c             	sub    $0xc,%esp
80106ead:	50                   	push   %eax
80106eae:	e8 0d d1 ff ff       	call   80103fc0 <end_op>
80106eb3:	83 c4 10             	add    $0x10,%esp
    return 0;
80106eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ebb:	c9                   	leave  
80106ebc:	c3                   	ret    

80106ebd <sys_mknod>:

int sys_mknod(void)
{
80106ebd:	55                   	push   %ebp
80106ebe:	89 e5                	mov    %esp,%ebp
80106ec0:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec9:	8b 40 68             	mov    0x68(%eax),%eax
80106ecc:	8b 40 50             	mov    0x50(%eax),%eax
80106ecf:	8b 40 14             	mov    0x14(%eax),%eax
80106ed2:	83 ec 0c             	sub    $0xc,%esp
80106ed5:	50                   	push   %eax
80106ed6:	e8 de cf ff ff       	call   80103eb9 <begin_op>
80106edb:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106ede:	83 ec 08             	sub    $0x8,%esp
80106ee1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ee4:	50                   	push   %eax
80106ee5:	6a 00                	push   $0x0
80106ee7:	e8 b8 f2 ff ff       	call   801061a4 <argstr>
80106eec:	83 c4 10             	add    $0x10,%esp
80106eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ef2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ef6:	78 4f                	js     80106f47 <sys_mknod+0x8a>
80106ef8:	83 ec 08             	sub    $0x8,%esp
80106efb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106efe:	50                   	push   %eax
80106eff:	6a 01                	push   $0x1
80106f01:	e8 19 f2 ff ff       	call   8010611f <argint>
80106f06:	83 c4 10             	add    $0x10,%esp
80106f09:	85 c0                	test   %eax,%eax
80106f0b:	78 3a                	js     80106f47 <sys_mknod+0x8a>
80106f0d:	83 ec 08             	sub    $0x8,%esp
80106f10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f13:	50                   	push   %eax
80106f14:	6a 02                	push   $0x2
80106f16:	e8 04 f2 ff ff       	call   8010611f <argint>
80106f1b:	83 c4 10             	add    $0x10,%esp
80106f1e:	85 c0                	test   %eax,%eax
80106f20:	78 25                	js     80106f47 <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106f22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f25:	0f bf c8             	movswl %ax,%ecx
80106f28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f2b:	0f bf d0             	movswl %ax,%edx
80106f2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106f31:	51                   	push   %ecx
80106f32:	52                   	push   %edx
80106f33:	6a 03                	push   $0x3
80106f35:	50                   	push   %eax
80106f36:	e8 62 fa ff ff       	call   8010699d <create>
80106f3b:	83 c4 10             	add    $0x10,%esp
80106f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106f41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f45:	75 22                	jne    80106f69 <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106f47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f4d:	8b 40 68             	mov    0x68(%eax),%eax
80106f50:	8b 40 50             	mov    0x50(%eax),%eax
80106f53:	8b 40 14             	mov    0x14(%eax),%eax
80106f56:	83 ec 0c             	sub    $0xc,%esp
80106f59:	50                   	push   %eax
80106f5a:	e8 61 d0 ff ff       	call   80103fc0 <end_op>
80106f5f:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f67:	eb 2e                	jmp    80106f97 <sys_mknod+0xda>
    }
    iunlockput(ip);
80106f69:	83 ec 0c             	sub    $0xc,%esp
80106f6c:	ff 75 f0             	pushl  -0x10(%ebp)
80106f6f:	e8 81 b2 ff ff       	call   801021f5 <iunlockput>
80106f74:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106f77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f7d:	8b 40 68             	mov    0x68(%eax),%eax
80106f80:	8b 40 50             	mov    0x50(%eax),%eax
80106f83:	8b 40 14             	mov    0x14(%eax),%eax
80106f86:	83 ec 0c             	sub    $0xc,%esp
80106f89:	50                   	push   %eax
80106f8a:	e8 31 d0 ff ff       	call   80103fc0 <end_op>
80106f8f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f97:	c9                   	leave  
80106f98:	c3                   	ret    

80106f99 <sys_chdir>:

int sys_chdir(void)
{
80106f99:	55                   	push   %ebp
80106f9a:	89 e5                	mov    %esp,%ebp
80106f9c:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;


    begin_op(proc->cwd->part->number);
80106f9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fa5:	8b 40 68             	mov    0x68(%eax),%eax
80106fa8:	8b 40 50             	mov    0x50(%eax),%eax
80106fab:	8b 40 14             	mov    0x14(%eax),%eax
80106fae:	83 ec 0c             	sub    $0xc,%esp
80106fb1:	50                   	push   %eax
80106fb2:	e8 02 cf ff ff       	call   80103eb9 <begin_op>
80106fb7:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106fba:	83 ec 08             	sub    $0x8,%esp
80106fbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fc0:	50                   	push   %eax
80106fc1:	6a 00                	push   $0x0
80106fc3:	e8 dc f1 ff ff       	call   801061a4 <argstr>
80106fc8:	83 c4 10             	add    $0x10,%esp
80106fcb:	85 c0                	test   %eax,%eax
80106fcd:	78 18                	js     80106fe7 <sys_chdir+0x4e>
80106fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fd2:	83 ec 0c             	sub    $0xc,%esp
80106fd5:	50                   	push   %eax
80106fd6:	e8 30 bd ff ff       	call   80102d0b <namei>
80106fdb:	83 c4 10             	add    $0x10,%esp
80106fde:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fe1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fe5:	75 25                	jne    8010700c <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106fe7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fed:	8b 40 68             	mov    0x68(%eax),%eax
80106ff0:	8b 40 50             	mov    0x50(%eax),%eax
80106ff3:	8b 40 14             	mov    0x14(%eax),%eax
80106ff6:	83 ec 0c             	sub    $0xc,%esp
80106ff9:	50                   	push   %eax
80106ffa:	e8 c1 cf ff ff       	call   80103fc0 <end_op>
80106fff:	83 c4 10             	add    $0x10,%esp
        return -1;
80107002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107007:	e9 9a 00 00 00       	jmp    801070a6 <sys_chdir+0x10d>
    }
    //cprintf("cd path %s \n",path);
    ilock(ip);
8010700c:	83 ec 0c             	sub    $0xc,%esp
8010700f:	ff 75 f4             	pushl  -0xc(%ebp)
80107012:	e8 db ae ff ff       	call   80101ef2 <ilock>
80107017:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
8010701a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107021:	66 83 f8 01          	cmp    $0x1,%ax
80107025:	74 30                	je     80107057 <sys_chdir+0xbe>
        iunlockput(ip);
80107027:	83 ec 0c             	sub    $0xc,%esp
8010702a:	ff 75 f4             	pushl  -0xc(%ebp)
8010702d:	e8 c3 b1 ff ff       	call   801021f5 <iunlockput>
80107032:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80107035:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010703b:	8b 40 68             	mov    0x68(%eax),%eax
8010703e:	8b 40 50             	mov    0x50(%eax),%eax
80107041:	8b 40 14             	mov    0x14(%eax),%eax
80107044:	83 ec 0c             	sub    $0xc,%esp
80107047:	50                   	push   %eax
80107048:	e8 73 cf ff ff       	call   80103fc0 <end_op>
8010704d:	83 c4 10             	add    $0x10,%esp
        return -1;
80107050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107055:	eb 4f                	jmp    801070a6 <sys_chdir+0x10d>
    }
    iunlock(ip);
80107057:	83 ec 0c             	sub    $0xc,%esp
8010705a:	ff 75 f4             	pushl  -0xc(%ebp)
8010705d:	e8 31 b0 ff ff       	call   80102093 <iunlock>
80107062:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80107065:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010706b:	8b 40 68             	mov    0x68(%eax),%eax
8010706e:	83 ec 0c             	sub    $0xc,%esp
80107071:	50                   	push   %eax
80107072:	e8 8e b0 ff ff       	call   80102105 <iput>
80107077:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
8010707a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107080:	8b 40 68             	mov    0x68(%eax),%eax
80107083:	8b 40 50             	mov    0x50(%eax),%eax
80107086:	8b 40 14             	mov    0x14(%eax),%eax
80107089:	83 ec 0c             	sub    $0xc,%esp
8010708c:	50                   	push   %eax
8010708d:	e8 2e cf ff ff       	call   80103fc0 <end_op>
80107092:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
80107095:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010709b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010709e:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
801070a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070a6:	c9                   	leave  
801070a7:	c3                   	ret    

801070a8 <sys_exec>:

int sys_exec(void)
{
801070a8:	55                   	push   %ebp
801070a9:	89 e5                	mov    %esp,%ebp
801070ab:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
801070b1:	83 ec 08             	sub    $0x8,%esp
801070b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070b7:	50                   	push   %eax
801070b8:	6a 00                	push   $0x0
801070ba:	e8 e5 f0 ff ff       	call   801061a4 <argstr>
801070bf:	83 c4 10             	add    $0x10,%esp
801070c2:	85 c0                	test   %eax,%eax
801070c4:	78 18                	js     801070de <sys_exec+0x36>
801070c6:	83 ec 08             	sub    $0x8,%esp
801070c9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801070cf:	50                   	push   %eax
801070d0:	6a 01                	push   $0x1
801070d2:	e8 48 f0 ff ff       	call   8010611f <argint>
801070d7:	83 c4 10             	add    $0x10,%esp
801070da:	85 c0                	test   %eax,%eax
801070dc:	79 0a                	jns    801070e8 <sys_exec+0x40>
        return -1;
801070de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070e3:	e9 c6 00 00 00       	jmp    801071ae <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
801070e8:	83 ec 04             	sub    $0x4,%esp
801070eb:	68 80 00 00 00       	push   $0x80
801070f0:	6a 00                	push   $0x0
801070f2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801070f8:	50                   	push   %eax
801070f9:	e8 fc ec ff ff       	call   80105dfa <memset>
801070fe:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
80107101:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
80107108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710b:	83 f8 1f             	cmp    $0x1f,%eax
8010710e:	76 0a                	jbe    8010711a <sys_exec+0x72>
            return -1;
80107110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107115:	e9 94 00 00 00       	jmp    801071ae <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
8010711a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711d:	c1 e0 02             	shl    $0x2,%eax
80107120:	89 c2                	mov    %eax,%edx
80107122:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107128:	01 c2                	add    %eax,%edx
8010712a:	83 ec 08             	sub    $0x8,%esp
8010712d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107133:	50                   	push   %eax
80107134:	52                   	push   %edx
80107135:	e8 49 ef ff ff       	call   80106083 <fetchint>
8010713a:	83 c4 10             	add    $0x10,%esp
8010713d:	85 c0                	test   %eax,%eax
8010713f:	79 07                	jns    80107148 <sys_exec+0xa0>
            return -1;
80107141:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107146:	eb 66                	jmp    801071ae <sys_exec+0x106>
        if (uarg == 0) {
80107148:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010714e:	85 c0                	test   %eax,%eax
80107150:	75 27                	jne    80107179 <sys_exec+0xd1>
            argv[i] = 0;
80107152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107155:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010715c:	00 00 00 00 
            break;
80107160:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
80107161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107164:	83 ec 08             	sub    $0x8,%esp
80107167:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010716d:	52                   	push   %edx
8010716e:	50                   	push   %eax
8010716f:	e8 fd 99 ff ff       	call   80100b71 <exec>
80107174:	83 c4 10             	add    $0x10,%esp
80107177:	eb 35                	jmp    801071ae <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80107179:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010717f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107182:	c1 e2 02             	shl    $0x2,%edx
80107185:	01 c2                	add    %eax,%edx
80107187:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010718d:	83 ec 08             	sub    $0x8,%esp
80107190:	52                   	push   %edx
80107191:	50                   	push   %eax
80107192:	e8 26 ef ff ff       	call   801060bd <fetchstr>
80107197:	83 c4 10             	add    $0x10,%esp
8010719a:	85 c0                	test   %eax,%eax
8010719c:	79 07                	jns    801071a5 <sys_exec+0xfd>
            return -1;
8010719e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a3:	eb 09                	jmp    801071ae <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
801071a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
801071a9:	e9 5a ff ff ff       	jmp    80107108 <sys_exec+0x60>
    return exec(path, argv);
}
801071ae:	c9                   	leave  
801071af:	c3                   	ret    

801071b0 <sys_pipe>:

int sys_pipe(void)
{
801071b0:	55                   	push   %ebp
801071b1:	89 e5                	mov    %esp,%ebp
801071b3:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
801071b6:	83 ec 04             	sub    $0x4,%esp
801071b9:	6a 08                	push   $0x8
801071bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801071be:	50                   	push   %eax
801071bf:	6a 00                	push   $0x0
801071c1:	e8 81 ef ff ff       	call   80106147 <argptr>
801071c6:	83 c4 10             	add    $0x10,%esp
801071c9:	85 c0                	test   %eax,%eax
801071cb:	79 0a                	jns    801071d7 <sys_pipe+0x27>
        return -1;
801071cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071d2:	e9 af 00 00 00       	jmp    80107286 <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
801071d7:	83 ec 08             	sub    $0x8,%esp
801071da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801071dd:	50                   	push   %eax
801071de:	8d 45 e8             	lea    -0x18(%ebp),%eax
801071e1:	50                   	push   %eax
801071e2:	e8 a2 d9 ff ff       	call   80104b89 <pipealloc>
801071e7:	83 c4 10             	add    $0x10,%esp
801071ea:	85 c0                	test   %eax,%eax
801071ec:	79 0a                	jns    801071f8 <sys_pipe+0x48>
        return -1;
801071ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071f3:	e9 8e 00 00 00       	jmp    80107286 <sys_pipe+0xd6>
    fd0 = -1;
801071f8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
801071ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107202:	83 ec 0c             	sub    $0xc,%esp
80107205:	50                   	push   %eax
80107206:	e8 c5 f0 ff ff       	call   801062d0 <fdalloc>
8010720b:	83 c4 10             	add    $0x10,%esp
8010720e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107211:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107215:	78 18                	js     8010722f <sys_pipe+0x7f>
80107217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010721a:	83 ec 0c             	sub    $0xc,%esp
8010721d:	50                   	push   %eax
8010721e:	e8 ad f0 ff ff       	call   801062d0 <fdalloc>
80107223:	83 c4 10             	add    $0x10,%esp
80107226:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107229:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010722d:	79 3f                	jns    8010726e <sys_pipe+0xbe>
        if (fd0 >= 0)
8010722f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107233:	78 14                	js     80107249 <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
80107235:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010723b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010723e:	83 c2 08             	add    $0x8,%edx
80107241:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107248:	00 
        fileclose(rf);
80107249:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010724c:	83 ec 0c             	sub    $0xc,%esp
8010724f:	50                   	push   %eax
80107250:	e8 54 9e ff ff       	call   801010a9 <fileclose>
80107255:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
80107258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010725b:	83 ec 0c             	sub    $0xc,%esp
8010725e:	50                   	push   %eax
8010725f:	e8 45 9e ff ff       	call   801010a9 <fileclose>
80107264:	83 c4 10             	add    $0x10,%esp
        return -1;
80107267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010726c:	eb 18                	jmp    80107286 <sys_pipe+0xd6>
    }
    fd[0] = fd0;
8010726e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107271:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107274:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
80107276:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107279:	8d 50 04             	lea    0x4(%eax),%edx
8010727c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010727f:	89 02                	mov    %eax,(%edx)
    return 0;
80107281:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107286:	c9                   	leave  
80107287:	c3                   	ret    

80107288 <sys_mount>:

int sys_mount(void)
{
80107288:	55                   	push   %ebp
80107289:	89 e5                	mov    %esp,%ebp
8010728b:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
8010728e:	83 ec 08             	sub    $0x8,%esp
80107291:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107294:	50                   	push   %eax
80107295:	6a 00                	push   $0x0
80107297:	e8 08 ef ff ff       	call   801061a4 <argstr>
8010729c:	83 c4 10             	add    $0x10,%esp
8010729f:	85 c0                	test   %eax,%eax
801072a1:	78 1d                	js     801072c0 <sys_mount+0x38>
801072a3:	83 ec 08             	sub    $0x8,%esp
801072a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801072a9:	50                   	push   %eax
801072aa:	6a 01                	push   $0x1
801072ac:	e8 6e ee ff ff       	call   8010611f <argint>
801072b1:	83 c4 10             	add    $0x10,%esp
801072b4:	85 c0                	test   %eax,%eax
801072b6:	78 08                	js     801072c0 <sys_mount+0x38>
801072b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072bb:	83 f8 04             	cmp    $0x4,%eax
801072be:	76 0a                	jbe    801072ca <sys_mount+0x42>
        return -1;
801072c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072c5:	e9 a4 00 00 00       	jmp    8010736e <sys_mount+0xe6>
    }
    //cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);

    i=nameiIgnoreMounts(path);
801072ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072cd:	83 ec 0c             	sub    $0xc,%esp
801072d0:	50                   	push   %eax
801072d1:	e8 50 ba ff ff       	call   80102d26 <nameiIgnoreMounts>
801072d6:	83 c4 10             	add    $0x10,%esp
801072d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
801072dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072e0:	75 0a                	jne    801072ec <sys_mount+0x64>
        return -1;
801072e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072e7:	e9 82 00 00 00       	jmp    8010736e <sys_mount+0xe6>
    }
    ilock(i);
801072ec:	83 ec 0c             	sub    $0xc,%esp
801072ef:	ff 75 f4             	pushl  -0xc(%ebp)
801072f2:	e8 fb ab ff ff       	call   80101ef2 <ilock>
801072f7:	83 c4 10             	add    $0x10,%esp
    if(i->type!=T_DIR){
801072fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107301:	66 83 f8 01          	cmp    $0x1,%ax
80107305:	74 07                	je     8010730e <sys_mount+0x86>
        return -1;
80107307:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010730c:	eb 60                	jmp    8010736e <sys_mount+0xe6>
    }
    i->major=MOUNTING_POINT;
8010730e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107311:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
80107317:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010731a:	89 c2                	mov    %eax,%edx
8010731c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731f:	66 89 50 14          	mov    %dx,0x14(%eax)
    begin_op(i->part->number);
80107323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107326:	8b 40 50             	mov    0x50(%eax),%eax
80107329:	8b 40 14             	mov    0x14(%eax),%eax
8010732c:	83 ec 0c             	sub    $0xc,%esp
8010732f:	50                   	push   %eax
80107330:	e8 84 cb ff ff       	call   80103eb9 <begin_op>
80107335:	83 c4 10             	add    $0x10,%esp
    iupdate(i);
80107338:	83 ec 0c             	sub    $0xc,%esp
8010733b:	ff 75 f4             	pushl  -0xc(%ebp)
8010733e:	e8 51 a9 ff ff       	call   80101c94 <iupdate>
80107343:	83 c4 10             	add    $0x10,%esp
    end_op(i->part->number);
80107346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107349:	8b 40 50             	mov    0x50(%eax),%eax
8010734c:	8b 40 14             	mov    0x14(%eax),%eax
8010734f:	83 ec 0c             	sub    $0xc,%esp
80107352:	50                   	push   %eax
80107353:	e8 68 cc ff ff       	call   80103fc0 <end_op>
80107358:	83 c4 10             	add    $0x10,%esp
    iunlockput(i);
8010735b:	83 ec 0c             	sub    $0xc,%esp
8010735e:	ff 75 f4             	pushl  -0xc(%ebp)
80107361:	e8 8f ae ff ff       	call   801021f5 <iunlockput>
80107366:	83 c4 10             	add    $0x10,%esp
   // cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);
    return 0;
80107369:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010736e:	c9                   	leave  
8010736f:	c3                   	ret    

80107370 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80107370:	55                   	push   %ebp
80107371:	89 e5                	mov    %esp,%ebp
80107373:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107376:	e8 04 df ff ff       	call   8010527f <fork>
}
8010737b:	c9                   	leave  
8010737c:	c3                   	ret    

8010737d <sys_exit>:

int
sys_exit(void)
{
8010737d:	55                   	push   %ebp
8010737e:	89 e5                	mov    %esp,%ebp
80107380:	83 ec 08             	sub    $0x8,%esp
  exit();
80107383:	e8 88 e0 ff ff       	call   80105410 <exit>
  return 0;  // not reached
80107388:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010738d:	c9                   	leave  
8010738e:	c3                   	ret    

8010738f <sys_wait>:

int
sys_wait(void)
{
8010738f:	55                   	push   %ebp
80107390:	89 e5                	mov    %esp,%ebp
80107392:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107395:	e8 da e1 ff ff       	call   80105574 <wait>
}
8010739a:	c9                   	leave  
8010739b:	c3                   	ret    

8010739c <sys_kill>:

int
sys_kill(void)
{
8010739c:	55                   	push   %ebp
8010739d:	89 e5                	mov    %esp,%ebp
8010739f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801073a2:	83 ec 08             	sub    $0x8,%esp
801073a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073a8:	50                   	push   %eax
801073a9:	6a 00                	push   $0x0
801073ab:	e8 6f ed ff ff       	call   8010611f <argint>
801073b0:	83 c4 10             	add    $0x10,%esp
801073b3:	85 c0                	test   %eax,%eax
801073b5:	79 07                	jns    801073be <sys_kill+0x22>
    return -1;
801073b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073bc:	eb 0f                	jmp    801073cd <sys_kill+0x31>
  return kill(pid);
801073be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c1:	83 ec 0c             	sub    $0xc,%esp
801073c4:	50                   	push   %eax
801073c5:	e8 f6 e5 ff ff       	call   801059c0 <kill>
801073ca:	83 c4 10             	add    $0x10,%esp
}
801073cd:	c9                   	leave  
801073ce:	c3                   	ret    

801073cf <sys_getpid>:

int
sys_getpid(void)
{
801073cf:	55                   	push   %ebp
801073d0:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801073d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073d8:	8b 40 10             	mov    0x10(%eax),%eax
}
801073db:	5d                   	pop    %ebp
801073dc:	c3                   	ret    

801073dd <sys_sbrk>:

int
sys_sbrk(void)
{
801073dd:	55                   	push   %ebp
801073de:	89 e5                	mov    %esp,%ebp
801073e0:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801073e3:	83 ec 08             	sub    $0x8,%esp
801073e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073e9:	50                   	push   %eax
801073ea:	6a 00                	push   $0x0
801073ec:	e8 2e ed ff ff       	call   8010611f <argint>
801073f1:	83 c4 10             	add    $0x10,%esp
801073f4:	85 c0                	test   %eax,%eax
801073f6:	79 07                	jns    801073ff <sys_sbrk+0x22>
    return -1;
801073f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073fd:	eb 28                	jmp    80107427 <sys_sbrk+0x4a>
  addr = proc->sz;
801073ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107405:	8b 00                	mov    (%eax),%eax
80107407:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010740a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010740d:	83 ec 0c             	sub    $0xc,%esp
80107410:	50                   	push   %eax
80107411:	e8 c6 dd ff ff       	call   801051dc <growproc>
80107416:	83 c4 10             	add    $0x10,%esp
80107419:	85 c0                	test   %eax,%eax
8010741b:	79 07                	jns    80107424 <sys_sbrk+0x47>
    return -1;
8010741d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107422:	eb 03                	jmp    80107427 <sys_sbrk+0x4a>
  return addr;
80107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107427:	c9                   	leave  
80107428:	c3                   	ret    

80107429 <sys_sleep>:

int
sys_sleep(void)
{
80107429:	55                   	push   %ebp
8010742a:	89 e5                	mov    %esp,%ebp
8010742c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010742f:	83 ec 08             	sub    $0x8,%esp
80107432:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107435:	50                   	push   %eax
80107436:	6a 00                	push   $0x0
80107438:	e8 e2 ec ff ff       	call   8010611f <argint>
8010743d:	83 c4 10             	add    $0x10,%esp
80107440:	85 c0                	test   %eax,%eax
80107442:	79 07                	jns    8010744b <sys_sleep+0x22>
    return -1;
80107444:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107449:	eb 77                	jmp    801074c2 <sys_sleep+0x99>
  acquire(&tickslock);
8010744b:	83 ec 0c             	sub    $0xc,%esp
8010744e:	68 c0 5d 11 80       	push   $0x80115dc0
80107453:	e8 3f e7 ff ff       	call   80105b97 <acquire>
80107458:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010745b:	a1 00 66 11 80       	mov    0x80116600,%eax
80107460:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107463:	eb 39                	jmp    8010749e <sys_sleep+0x75>
    if(proc->killed){
80107465:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010746b:	8b 40 24             	mov    0x24(%eax),%eax
8010746e:	85 c0                	test   %eax,%eax
80107470:	74 17                	je     80107489 <sys_sleep+0x60>
      release(&tickslock);
80107472:	83 ec 0c             	sub    $0xc,%esp
80107475:	68 c0 5d 11 80       	push   $0x80115dc0
8010747a:	e8 7f e7 ff ff       	call   80105bfe <release>
8010747f:	83 c4 10             	add    $0x10,%esp
      return -1;
80107482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107487:	eb 39                	jmp    801074c2 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107489:	83 ec 08             	sub    $0x8,%esp
8010748c:	68 c0 5d 11 80       	push   $0x80115dc0
80107491:	68 00 66 11 80       	push   $0x80116600
80107496:	e8 03 e4 ff ff       	call   8010589e <sleep>
8010749b:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010749e:	a1 00 66 11 80       	mov    0x80116600,%eax
801074a3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801074a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801074a9:	39 d0                	cmp    %edx,%eax
801074ab:	72 b8                	jb     80107465 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801074ad:	83 ec 0c             	sub    $0xc,%esp
801074b0:	68 c0 5d 11 80       	push   $0x80115dc0
801074b5:	e8 44 e7 ff ff       	call   80105bfe <release>
801074ba:	83 c4 10             	add    $0x10,%esp
  return 0;
801074bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074c2:	c9                   	leave  
801074c3:	c3                   	ret    

801074c4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801074c4:	55                   	push   %ebp
801074c5:	89 e5                	mov    %esp,%ebp
801074c7:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801074ca:	83 ec 0c             	sub    $0xc,%esp
801074cd:	68 c0 5d 11 80       	push   $0x80115dc0
801074d2:	e8 c0 e6 ff ff       	call   80105b97 <acquire>
801074d7:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801074da:	a1 00 66 11 80       	mov    0x80116600,%eax
801074df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801074e2:	83 ec 0c             	sub    $0xc,%esp
801074e5:	68 c0 5d 11 80       	push   $0x80115dc0
801074ea:	e8 0f e7 ff ff       	call   80105bfe <release>
801074ef:	83 c4 10             	add    $0x10,%esp
  return xticks;
801074f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801074f5:	c9                   	leave  
801074f6:	c3                   	ret    

801074f7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801074f7:	55                   	push   %ebp
801074f8:	89 e5                	mov    %esp,%ebp
801074fa:	83 ec 08             	sub    $0x8,%esp
801074fd:	8b 55 08             	mov    0x8(%ebp),%edx
80107500:	8b 45 0c             	mov    0xc(%ebp),%eax
80107503:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107507:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010750a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010750e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107512:	ee                   	out    %al,(%dx)
}
80107513:	90                   	nop
80107514:	c9                   	leave  
80107515:	c3                   	ret    

80107516 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107516:	55                   	push   %ebp
80107517:	89 e5                	mov    %esp,%ebp
80107519:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010751c:	6a 34                	push   $0x34
8010751e:	6a 43                	push   $0x43
80107520:	e8 d2 ff ff ff       	call   801074f7 <outb>
80107525:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107528:	68 9c 00 00 00       	push   $0x9c
8010752d:	6a 40                	push   $0x40
8010752f:	e8 c3 ff ff ff       	call   801074f7 <outb>
80107534:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107537:	6a 2e                	push   $0x2e
80107539:	6a 40                	push   $0x40
8010753b:	e8 b7 ff ff ff       	call   801074f7 <outb>
80107540:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107543:	83 ec 0c             	sub    $0xc,%esp
80107546:	6a 00                	push   $0x0
80107548:	e8 26 d5 ff ff       	call   80104a73 <picenable>
8010754d:	83 c4 10             	add    $0x10,%esp
}
80107550:	90                   	nop
80107551:	c9                   	leave  
80107552:	c3                   	ret    

80107553 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107553:	1e                   	push   %ds
  pushl %es
80107554:	06                   	push   %es
  pushl %fs
80107555:	0f a0                	push   %fs
  pushl %gs
80107557:	0f a8                	push   %gs
  pushal
80107559:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010755a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010755e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107560:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107562:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107566:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107568:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010756a:	54                   	push   %esp
  call trap
8010756b:	e8 d7 01 00 00       	call   80107747 <trap>
  addl $4, %esp
80107570:	83 c4 04             	add    $0x4,%esp

80107573 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107573:	61                   	popa   
  popl %gs
80107574:	0f a9                	pop    %gs
  popl %fs
80107576:	0f a1                	pop    %fs
  popl %es
80107578:	07                   	pop    %es
  popl %ds
80107579:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010757a:	83 c4 08             	add    $0x8,%esp
  iret
8010757d:	cf                   	iret   

8010757e <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010757e:	55                   	push   %ebp
8010757f:	89 e5                	mov    %esp,%ebp
80107581:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107584:	8b 45 0c             	mov    0xc(%ebp),%eax
80107587:	83 e8 01             	sub    $0x1,%eax
8010758a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010758e:	8b 45 08             	mov    0x8(%ebp),%eax
80107591:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107595:	8b 45 08             	mov    0x8(%ebp),%eax
80107598:	c1 e8 10             	shr    $0x10,%eax
8010759b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010759f:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075a2:	0f 01 18             	lidtl  (%eax)
}
801075a5:	90                   	nop
801075a6:	c9                   	leave  
801075a7:	c3                   	ret    

801075a8 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801075a8:	55                   	push   %ebp
801075a9:	89 e5                	mov    %esp,%ebp
801075ab:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801075ae:	0f 20 d0             	mov    %cr2,%eax
801075b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801075b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801075b7:	c9                   	leave  
801075b8:	c3                   	ret    

801075b9 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801075b9:	55                   	push   %ebp
801075ba:	89 e5                	mov    %esp,%ebp
801075bc:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801075bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801075c6:	e9 c3 00 00 00       	jmp    8010768e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ce:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
801075d5:	89 c2                	mov    %eax,%edx
801075d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075da:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
801075e1:	80 
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
801075ec:	80 08 00 
801075ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f2:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
801075f9:	80 
801075fa:	83 e2 e0             	and    $0xffffffe0,%edx
801075fd:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
80107604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107607:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
8010760e:	80 
8010760f:	83 e2 1f             	and    $0x1f,%edx
80107612:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
80107619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761c:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107623:	80 
80107624:	83 e2 f0             	and    $0xfffffff0,%edx
80107627:	83 ca 0e             	or     $0xe,%edx
8010762a:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107634:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
8010763b:	80 
8010763c:	83 e2 ef             	and    $0xffffffef,%edx
8010763f:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107649:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107650:	80 
80107651:	83 e2 9f             	and    $0xffffff9f,%edx
80107654:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
8010765b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765e:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107665:	80 
80107666:	83 ca 80             	or     $0xffffff80,%edx
80107669:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107673:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010767a:	c1 e8 10             	shr    $0x10,%eax
8010767d:	89 c2                	mov    %eax,%edx
8010767f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107682:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
80107689:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010768a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010768e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107695:	0f 8e 30 ff ff ff    	jle    801075cb <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010769b:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
801076a0:	66 a3 00 60 11 80    	mov    %ax,0x80116000
801076a6:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
801076ad:	08 00 
801076af:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801076b6:	83 e0 e0             	and    $0xffffffe0,%eax
801076b9:	a2 04 60 11 80       	mov    %al,0x80116004
801076be:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801076c5:	83 e0 1f             	and    $0x1f,%eax
801076c8:	a2 04 60 11 80       	mov    %al,0x80116004
801076cd:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076d4:	83 c8 0f             	or     $0xf,%eax
801076d7:	a2 05 60 11 80       	mov    %al,0x80116005
801076dc:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076e3:	83 e0 ef             	and    $0xffffffef,%eax
801076e6:	a2 05 60 11 80       	mov    %al,0x80116005
801076eb:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
801076f2:	83 c8 60             	or     $0x60,%eax
801076f5:	a2 05 60 11 80       	mov    %al,0x80116005
801076fa:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107701:	83 c8 80             	or     $0xffffff80,%eax
80107704:	a2 05 60 11 80       	mov    %al,0x80116005
80107709:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
8010770e:	c1 e8 10             	shr    $0x10,%eax
80107711:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
80107717:	83 ec 08             	sub    $0x8,%esp
8010771a:	68 f8 99 10 80       	push   $0x801099f8
8010771f:	68 c0 5d 11 80       	push   $0x80115dc0
80107724:	e8 4c e4 ff ff       	call   80105b75 <initlock>
80107729:	83 c4 10             	add    $0x10,%esp
}
8010772c:	90                   	nop
8010772d:	c9                   	leave  
8010772e:	c3                   	ret    

8010772f <idtinit>:

void
idtinit(void)
{
8010772f:	55                   	push   %ebp
80107730:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107732:	68 00 08 00 00       	push   $0x800
80107737:	68 00 5e 11 80       	push   $0x80115e00
8010773c:	e8 3d fe ff ff       	call   8010757e <lidt>
80107741:	83 c4 08             	add    $0x8,%esp
}
80107744:	90                   	nop
80107745:	c9                   	leave  
80107746:	c3                   	ret    

80107747 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107747:	55                   	push   %ebp
80107748:	89 e5                	mov    %esp,%ebp
8010774a:	57                   	push   %edi
8010774b:	56                   	push   %esi
8010774c:	53                   	push   %ebx
8010774d:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107750:	8b 45 08             	mov    0x8(%ebp),%eax
80107753:	8b 40 30             	mov    0x30(%eax),%eax
80107756:	83 f8 40             	cmp    $0x40,%eax
80107759:	75 3e                	jne    80107799 <trap+0x52>
    if(proc->killed)
8010775b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107761:	8b 40 24             	mov    0x24(%eax),%eax
80107764:	85 c0                	test   %eax,%eax
80107766:	74 05                	je     8010776d <trap+0x26>
      exit();
80107768:	e8 a3 dc ff ff       	call   80105410 <exit>
    proc->tf = tf;
8010776d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107773:	8b 55 08             	mov    0x8(%ebp),%edx
80107776:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107779:	e8 57 ea ff ff       	call   801061d5 <syscall>
    if(proc->killed)
8010777e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107784:	8b 40 24             	mov    0x24(%eax),%eax
80107787:	85 c0                	test   %eax,%eax
80107789:	0f 84 1b 02 00 00    	je     801079aa <trap+0x263>
      exit();
8010778f:	e8 7c dc ff ff       	call   80105410 <exit>
    return;
80107794:	e9 11 02 00 00       	jmp    801079aa <trap+0x263>
  }

  switch(tf->trapno){
80107799:	8b 45 08             	mov    0x8(%ebp),%eax
8010779c:	8b 40 30             	mov    0x30(%eax),%eax
8010779f:	83 e8 20             	sub    $0x20,%eax
801077a2:	83 f8 1f             	cmp    $0x1f,%eax
801077a5:	0f 87 c0 00 00 00    	ja     8010786b <trap+0x124>
801077ab:	8b 04 85 a0 9a 10 80 	mov    -0x7fef6560(,%eax,4),%eax
801077b2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801077b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077ba:	0f b6 00             	movzbl (%eax),%eax
801077bd:	84 c0                	test   %al,%al
801077bf:	75 3d                	jne    801077fe <trap+0xb7>
      acquire(&tickslock);
801077c1:	83 ec 0c             	sub    $0xc,%esp
801077c4:	68 c0 5d 11 80       	push   $0x80115dc0
801077c9:	e8 c9 e3 ff ff       	call   80105b97 <acquire>
801077ce:	83 c4 10             	add    $0x10,%esp
      ticks++;
801077d1:	a1 00 66 11 80       	mov    0x80116600,%eax
801077d6:	83 c0 01             	add    $0x1,%eax
801077d9:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
801077de:	83 ec 0c             	sub    $0xc,%esp
801077e1:	68 00 66 11 80       	push   $0x80116600
801077e6:	e8 9e e1 ff ff       	call   80105989 <wakeup>
801077eb:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801077ee:	83 ec 0c             	sub    $0xc,%esp
801077f1:	68 c0 5d 11 80       	push   $0x80115dc0
801077f6:	e8 03 e4 ff ff       	call   80105bfe <release>
801077fb:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801077fe:	e8 3e c0 ff ff       	call   80103841 <lapiceoi>
    break;
80107803:	e9 1c 01 00 00       	jmp    80107924 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107808:	e8 47 b8 ff ff       	call   80103054 <ideintr>
    lapiceoi();
8010780d:	e8 2f c0 ff ff       	call   80103841 <lapiceoi>
    break;
80107812:	e9 0d 01 00 00       	jmp    80107924 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107817:	e8 27 be ff ff       	call   80103643 <kbdintr>
    lapiceoi();
8010781c:	e8 20 c0 ff ff       	call   80103841 <lapiceoi>
    break;
80107821:	e9 fe 00 00 00       	jmp    80107924 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107826:	e8 60 03 00 00       	call   80107b8b <uartintr>
    lapiceoi();
8010782b:	e8 11 c0 ff ff       	call   80103841 <lapiceoi>
    break;
80107830:	e9 ef 00 00 00       	jmp    80107924 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107835:	8b 45 08             	mov    0x8(%ebp),%eax
80107838:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010783b:	8b 45 08             	mov    0x8(%ebp),%eax
8010783e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107842:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107845:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010784b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010784e:	0f b6 c0             	movzbl %al,%eax
80107851:	51                   	push   %ecx
80107852:	52                   	push   %edx
80107853:	50                   	push   %eax
80107854:	68 00 9a 10 80       	push   $0x80109a00
80107859:	e8 68 8b ff ff       	call   801003c6 <cprintf>
8010785e:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107861:	e8 db bf ff ff       	call   80103841 <lapiceoi>
    break;
80107866:	e9 b9 00 00 00       	jmp    80107924 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010786b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107871:	85 c0                	test   %eax,%eax
80107873:	74 11                	je     80107886 <trap+0x13f>
80107875:	8b 45 08             	mov    0x8(%ebp),%eax
80107878:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010787c:	0f b7 c0             	movzwl %ax,%eax
8010787f:	83 e0 03             	and    $0x3,%eax
80107882:	85 c0                	test   %eax,%eax
80107884:	75 40                	jne    801078c6 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107886:	e8 1d fd ff ff       	call   801075a8 <rcr2>
8010788b:	89 c3                	mov    %eax,%ebx
8010788d:	8b 45 08             	mov    0x8(%ebp),%eax
80107890:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107893:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107899:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010789c:	0f b6 d0             	movzbl %al,%edx
8010789f:	8b 45 08             	mov    0x8(%ebp),%eax
801078a2:	8b 40 30             	mov    0x30(%eax),%eax
801078a5:	83 ec 0c             	sub    $0xc,%esp
801078a8:	53                   	push   %ebx
801078a9:	51                   	push   %ecx
801078aa:	52                   	push   %edx
801078ab:	50                   	push   %eax
801078ac:	68 24 9a 10 80       	push   $0x80109a24
801078b1:	e8 10 8b ff ff       	call   801003c6 <cprintf>
801078b6:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801078b9:	83 ec 0c             	sub    $0xc,%esp
801078bc:	68 56 9a 10 80       	push   $0x80109a56
801078c1:	e8 a0 8c ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078c6:	e8 dd fc ff ff       	call   801075a8 <rcr2>
801078cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801078ce:	8b 45 08             	mov    0x8(%ebp),%eax
801078d1:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078d4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078da:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078dd:	0f b6 d8             	movzbl %al,%ebx
801078e0:	8b 45 08             	mov    0x8(%ebp),%eax
801078e3:	8b 48 34             	mov    0x34(%eax),%ecx
801078e6:	8b 45 08             	mov    0x8(%ebp),%eax
801078e9:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078f2:	8d 78 6c             	lea    0x6c(%eax),%edi
801078f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078fb:	8b 40 10             	mov    0x10(%eax),%eax
801078fe:	ff 75 e4             	pushl  -0x1c(%ebp)
80107901:	56                   	push   %esi
80107902:	53                   	push   %ebx
80107903:	51                   	push   %ecx
80107904:	52                   	push   %edx
80107905:	57                   	push   %edi
80107906:	50                   	push   %eax
80107907:	68 5c 9a 10 80       	push   $0x80109a5c
8010790c:	e8 b5 8a ff ff       	call   801003c6 <cprintf>
80107911:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107914:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010791a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107921:	eb 01                	jmp    80107924 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107923:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107924:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010792a:	85 c0                	test   %eax,%eax
8010792c:	74 24                	je     80107952 <trap+0x20b>
8010792e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107934:	8b 40 24             	mov    0x24(%eax),%eax
80107937:	85 c0                	test   %eax,%eax
80107939:	74 17                	je     80107952 <trap+0x20b>
8010793b:	8b 45 08             	mov    0x8(%ebp),%eax
8010793e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107942:	0f b7 c0             	movzwl %ax,%eax
80107945:	83 e0 03             	and    $0x3,%eax
80107948:	83 f8 03             	cmp    $0x3,%eax
8010794b:	75 05                	jne    80107952 <trap+0x20b>
    exit();
8010794d:	e8 be da ff ff       	call   80105410 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107952:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107958:	85 c0                	test   %eax,%eax
8010795a:	74 1e                	je     8010797a <trap+0x233>
8010795c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107962:	8b 40 0c             	mov    0xc(%eax),%eax
80107965:	83 f8 04             	cmp    $0x4,%eax
80107968:	75 10                	jne    8010797a <trap+0x233>
8010796a:	8b 45 08             	mov    0x8(%ebp),%eax
8010796d:	8b 40 30             	mov    0x30(%eax),%eax
80107970:	83 f8 20             	cmp    $0x20,%eax
80107973:	75 05                	jne    8010797a <trap+0x233>
    yield();
80107975:	e8 7f de ff ff       	call   801057f9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010797a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107980:	85 c0                	test   %eax,%eax
80107982:	74 27                	je     801079ab <trap+0x264>
80107984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010798a:	8b 40 24             	mov    0x24(%eax),%eax
8010798d:	85 c0                	test   %eax,%eax
8010798f:	74 1a                	je     801079ab <trap+0x264>
80107991:	8b 45 08             	mov    0x8(%ebp),%eax
80107994:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107998:	0f b7 c0             	movzwl %ax,%eax
8010799b:	83 e0 03             	and    $0x3,%eax
8010799e:	83 f8 03             	cmp    $0x3,%eax
801079a1:	75 08                	jne    801079ab <trap+0x264>
    exit();
801079a3:	e8 68 da ff ff       	call   80105410 <exit>
801079a8:	eb 01                	jmp    801079ab <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801079aa:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801079ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801079ae:	5b                   	pop    %ebx
801079af:	5e                   	pop    %esi
801079b0:	5f                   	pop    %edi
801079b1:	5d                   	pop    %ebp
801079b2:	c3                   	ret    

801079b3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801079b3:	55                   	push   %ebp
801079b4:	89 e5                	mov    %esp,%ebp
801079b6:	83 ec 14             	sub    $0x14,%esp
801079b9:	8b 45 08             	mov    0x8(%ebp),%eax
801079bc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801079c0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801079c4:	89 c2                	mov    %eax,%edx
801079c6:	ec                   	in     (%dx),%al
801079c7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801079ca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801079ce:	c9                   	leave  
801079cf:	c3                   	ret    

801079d0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801079d0:	55                   	push   %ebp
801079d1:	89 e5                	mov    %esp,%ebp
801079d3:	83 ec 08             	sub    $0x8,%esp
801079d6:	8b 55 08             	mov    0x8(%ebp),%edx
801079d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801079dc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801079e0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801079e3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801079e7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801079eb:	ee                   	out    %al,(%dx)
}
801079ec:	90                   	nop
801079ed:	c9                   	leave  
801079ee:	c3                   	ret    

801079ef <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801079ef:	55                   	push   %ebp
801079f0:	89 e5                	mov    %esp,%ebp
801079f2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801079f5:	6a 00                	push   $0x0
801079f7:	68 fa 03 00 00       	push   $0x3fa
801079fc:	e8 cf ff ff ff       	call   801079d0 <outb>
80107a01:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107a04:	68 80 00 00 00       	push   $0x80
80107a09:	68 fb 03 00 00       	push   $0x3fb
80107a0e:	e8 bd ff ff ff       	call   801079d0 <outb>
80107a13:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107a16:	6a 0c                	push   $0xc
80107a18:	68 f8 03 00 00       	push   $0x3f8
80107a1d:	e8 ae ff ff ff       	call   801079d0 <outb>
80107a22:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107a25:	6a 00                	push   $0x0
80107a27:	68 f9 03 00 00       	push   $0x3f9
80107a2c:	e8 9f ff ff ff       	call   801079d0 <outb>
80107a31:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107a34:	6a 03                	push   $0x3
80107a36:	68 fb 03 00 00       	push   $0x3fb
80107a3b:	e8 90 ff ff ff       	call   801079d0 <outb>
80107a40:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107a43:	6a 00                	push   $0x0
80107a45:	68 fc 03 00 00       	push   $0x3fc
80107a4a:	e8 81 ff ff ff       	call   801079d0 <outb>
80107a4f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107a52:	6a 01                	push   $0x1
80107a54:	68 f9 03 00 00       	push   $0x3f9
80107a59:	e8 72 ff ff ff       	call   801079d0 <outb>
80107a5e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107a61:	68 fd 03 00 00       	push   $0x3fd
80107a66:	e8 48 ff ff ff       	call   801079b3 <inb>
80107a6b:	83 c4 04             	add    $0x4,%esp
80107a6e:	3c ff                	cmp    $0xff,%al
80107a70:	74 6e                	je     80107ae0 <uartinit+0xf1>
    return;
  uart = 1;
80107a72:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107a79:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107a7c:	68 fa 03 00 00       	push   $0x3fa
80107a81:	e8 2d ff ff ff       	call   801079b3 <inb>
80107a86:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107a89:	68 f8 03 00 00       	push   $0x3f8
80107a8e:	e8 20 ff ff ff       	call   801079b3 <inb>
80107a93:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107a96:	83 ec 0c             	sub    $0xc,%esp
80107a99:	6a 04                	push   $0x4
80107a9b:	e8 d3 cf ff ff       	call   80104a73 <picenable>
80107aa0:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107aa3:	83 ec 08             	sub    $0x8,%esp
80107aa6:	6a 00                	push   $0x0
80107aa8:	6a 04                	push   $0x4
80107aaa:	e8 47 b8 ff ff       	call   801032f6 <ioapicenable>
80107aaf:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107ab2:	c7 45 f4 20 9b 10 80 	movl   $0x80109b20,-0xc(%ebp)
80107ab9:	eb 19                	jmp    80107ad4 <uartinit+0xe5>
    uartputc(*p);
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	0f b6 00             	movzbl (%eax),%eax
80107ac1:	0f be c0             	movsbl %al,%eax
80107ac4:	83 ec 0c             	sub    $0xc,%esp
80107ac7:	50                   	push   %eax
80107ac8:	e8 16 00 00 00       	call   80107ae3 <uartputc>
80107acd:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	0f b6 00             	movzbl (%eax),%eax
80107ada:	84 c0                	test   %al,%al
80107adc:	75 dd                	jne    80107abb <uartinit+0xcc>
80107ade:	eb 01                	jmp    80107ae1 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107ae0:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107ae1:	c9                   	leave  
80107ae2:	c3                   	ret    

80107ae3 <uartputc>:

void
uartputc(int c)
{
80107ae3:	55                   	push   %ebp
80107ae4:	89 e5                	mov    %esp,%ebp
80107ae6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107ae9:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107aee:	85 c0                	test   %eax,%eax
80107af0:	74 53                	je     80107b45 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107af9:	eb 11                	jmp    80107b0c <uartputc+0x29>
    microdelay(10);
80107afb:	83 ec 0c             	sub    $0xc,%esp
80107afe:	6a 0a                	push   $0xa
80107b00:	e8 57 bd ff ff       	call   8010385c <microdelay>
80107b05:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b0c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b10:	7f 1a                	jg     80107b2c <uartputc+0x49>
80107b12:	83 ec 0c             	sub    $0xc,%esp
80107b15:	68 fd 03 00 00       	push   $0x3fd
80107b1a:	e8 94 fe ff ff       	call   801079b3 <inb>
80107b1f:	83 c4 10             	add    $0x10,%esp
80107b22:	0f b6 c0             	movzbl %al,%eax
80107b25:	83 e0 20             	and    $0x20,%eax
80107b28:	85 c0                	test   %eax,%eax
80107b2a:	74 cf                	je     80107afb <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b2f:	0f b6 c0             	movzbl %al,%eax
80107b32:	83 ec 08             	sub    $0x8,%esp
80107b35:	50                   	push   %eax
80107b36:	68 f8 03 00 00       	push   $0x3f8
80107b3b:	e8 90 fe ff ff       	call   801079d0 <outb>
80107b40:	83 c4 10             	add    $0x10,%esp
80107b43:	eb 01                	jmp    80107b46 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107b45:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107b46:	c9                   	leave  
80107b47:	c3                   	ret    

80107b48 <uartgetc>:

static int
uartgetc(void)
{
80107b48:	55                   	push   %ebp
80107b49:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107b4b:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107b50:	85 c0                	test   %eax,%eax
80107b52:	75 07                	jne    80107b5b <uartgetc+0x13>
    return -1;
80107b54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b59:	eb 2e                	jmp    80107b89 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107b5b:	68 fd 03 00 00       	push   $0x3fd
80107b60:	e8 4e fe ff ff       	call   801079b3 <inb>
80107b65:	83 c4 04             	add    $0x4,%esp
80107b68:	0f b6 c0             	movzbl %al,%eax
80107b6b:	83 e0 01             	and    $0x1,%eax
80107b6e:	85 c0                	test   %eax,%eax
80107b70:	75 07                	jne    80107b79 <uartgetc+0x31>
    return -1;
80107b72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b77:	eb 10                	jmp    80107b89 <uartgetc+0x41>
  return inb(COM1+0);
80107b79:	68 f8 03 00 00       	push   $0x3f8
80107b7e:	e8 30 fe ff ff       	call   801079b3 <inb>
80107b83:	83 c4 04             	add    $0x4,%esp
80107b86:	0f b6 c0             	movzbl %al,%eax
}
80107b89:	c9                   	leave  
80107b8a:	c3                   	ret    

80107b8b <uartintr>:

void
uartintr(void)
{
80107b8b:	55                   	push   %ebp
80107b8c:	89 e5                	mov    %esp,%ebp
80107b8e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107b91:	83 ec 0c             	sub    $0xc,%esp
80107b94:	68 48 7b 10 80       	push   $0x80107b48
80107b99:	e8 5b 8c ff ff       	call   801007f9 <consoleintr>
80107b9e:	83 c4 10             	add    $0x10,%esp
}
80107ba1:	90                   	nop
80107ba2:	c9                   	leave  
80107ba3:	c3                   	ret    

80107ba4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $0
80107ba6:	6a 00                	push   $0x0
  jmp alltraps
80107ba8:	e9 a6 f9 ff ff       	jmp    80107553 <alltraps>

80107bad <vector1>:
.globl vector1
vector1:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $1
80107baf:	6a 01                	push   $0x1
  jmp alltraps
80107bb1:	e9 9d f9 ff ff       	jmp    80107553 <alltraps>

80107bb6 <vector2>:
.globl vector2
vector2:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $2
80107bb8:	6a 02                	push   $0x2
  jmp alltraps
80107bba:	e9 94 f9 ff ff       	jmp    80107553 <alltraps>

80107bbf <vector3>:
.globl vector3
vector3:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $3
80107bc1:	6a 03                	push   $0x3
  jmp alltraps
80107bc3:	e9 8b f9 ff ff       	jmp    80107553 <alltraps>

80107bc8 <vector4>:
.globl vector4
vector4:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $4
80107bca:	6a 04                	push   $0x4
  jmp alltraps
80107bcc:	e9 82 f9 ff ff       	jmp    80107553 <alltraps>

80107bd1 <vector5>:
.globl vector5
vector5:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $5
80107bd3:	6a 05                	push   $0x5
  jmp alltraps
80107bd5:	e9 79 f9 ff ff       	jmp    80107553 <alltraps>

80107bda <vector6>:
.globl vector6
vector6:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $6
80107bdc:	6a 06                	push   $0x6
  jmp alltraps
80107bde:	e9 70 f9 ff ff       	jmp    80107553 <alltraps>

80107be3 <vector7>:
.globl vector7
vector7:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $7
80107be5:	6a 07                	push   $0x7
  jmp alltraps
80107be7:	e9 67 f9 ff ff       	jmp    80107553 <alltraps>

80107bec <vector8>:
.globl vector8
vector8:
  pushl $8
80107bec:	6a 08                	push   $0x8
  jmp alltraps
80107bee:	e9 60 f9 ff ff       	jmp    80107553 <alltraps>

80107bf3 <vector9>:
.globl vector9
vector9:
  pushl $0
80107bf3:	6a 00                	push   $0x0
  pushl $9
80107bf5:	6a 09                	push   $0x9
  jmp alltraps
80107bf7:	e9 57 f9 ff ff       	jmp    80107553 <alltraps>

80107bfc <vector10>:
.globl vector10
vector10:
  pushl $10
80107bfc:	6a 0a                	push   $0xa
  jmp alltraps
80107bfe:	e9 50 f9 ff ff       	jmp    80107553 <alltraps>

80107c03 <vector11>:
.globl vector11
vector11:
  pushl $11
80107c03:	6a 0b                	push   $0xb
  jmp alltraps
80107c05:	e9 49 f9 ff ff       	jmp    80107553 <alltraps>

80107c0a <vector12>:
.globl vector12
vector12:
  pushl $12
80107c0a:	6a 0c                	push   $0xc
  jmp alltraps
80107c0c:	e9 42 f9 ff ff       	jmp    80107553 <alltraps>

80107c11 <vector13>:
.globl vector13
vector13:
  pushl $13
80107c11:	6a 0d                	push   $0xd
  jmp alltraps
80107c13:	e9 3b f9 ff ff       	jmp    80107553 <alltraps>

80107c18 <vector14>:
.globl vector14
vector14:
  pushl $14
80107c18:	6a 0e                	push   $0xe
  jmp alltraps
80107c1a:	e9 34 f9 ff ff       	jmp    80107553 <alltraps>

80107c1f <vector15>:
.globl vector15
vector15:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $15
80107c21:	6a 0f                	push   $0xf
  jmp alltraps
80107c23:	e9 2b f9 ff ff       	jmp    80107553 <alltraps>

80107c28 <vector16>:
.globl vector16
vector16:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $16
80107c2a:	6a 10                	push   $0x10
  jmp alltraps
80107c2c:	e9 22 f9 ff ff       	jmp    80107553 <alltraps>

80107c31 <vector17>:
.globl vector17
vector17:
  pushl $17
80107c31:	6a 11                	push   $0x11
  jmp alltraps
80107c33:	e9 1b f9 ff ff       	jmp    80107553 <alltraps>

80107c38 <vector18>:
.globl vector18
vector18:
  pushl $0
80107c38:	6a 00                	push   $0x0
  pushl $18
80107c3a:	6a 12                	push   $0x12
  jmp alltraps
80107c3c:	e9 12 f9 ff ff       	jmp    80107553 <alltraps>

80107c41 <vector19>:
.globl vector19
vector19:
  pushl $0
80107c41:	6a 00                	push   $0x0
  pushl $19
80107c43:	6a 13                	push   $0x13
  jmp alltraps
80107c45:	e9 09 f9 ff ff       	jmp    80107553 <alltraps>

80107c4a <vector20>:
.globl vector20
vector20:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $20
80107c4c:	6a 14                	push   $0x14
  jmp alltraps
80107c4e:	e9 00 f9 ff ff       	jmp    80107553 <alltraps>

80107c53 <vector21>:
.globl vector21
vector21:
  pushl $0
80107c53:	6a 00                	push   $0x0
  pushl $21
80107c55:	6a 15                	push   $0x15
  jmp alltraps
80107c57:	e9 f7 f8 ff ff       	jmp    80107553 <alltraps>

80107c5c <vector22>:
.globl vector22
vector22:
  pushl $0
80107c5c:	6a 00                	push   $0x0
  pushl $22
80107c5e:	6a 16                	push   $0x16
  jmp alltraps
80107c60:	e9 ee f8 ff ff       	jmp    80107553 <alltraps>

80107c65 <vector23>:
.globl vector23
vector23:
  pushl $0
80107c65:	6a 00                	push   $0x0
  pushl $23
80107c67:	6a 17                	push   $0x17
  jmp alltraps
80107c69:	e9 e5 f8 ff ff       	jmp    80107553 <alltraps>

80107c6e <vector24>:
.globl vector24
vector24:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $24
80107c70:	6a 18                	push   $0x18
  jmp alltraps
80107c72:	e9 dc f8 ff ff       	jmp    80107553 <alltraps>

80107c77 <vector25>:
.globl vector25
vector25:
  pushl $0
80107c77:	6a 00                	push   $0x0
  pushl $25
80107c79:	6a 19                	push   $0x19
  jmp alltraps
80107c7b:	e9 d3 f8 ff ff       	jmp    80107553 <alltraps>

80107c80 <vector26>:
.globl vector26
vector26:
  pushl $0
80107c80:	6a 00                	push   $0x0
  pushl $26
80107c82:	6a 1a                	push   $0x1a
  jmp alltraps
80107c84:	e9 ca f8 ff ff       	jmp    80107553 <alltraps>

80107c89 <vector27>:
.globl vector27
vector27:
  pushl $0
80107c89:	6a 00                	push   $0x0
  pushl $27
80107c8b:	6a 1b                	push   $0x1b
  jmp alltraps
80107c8d:	e9 c1 f8 ff ff       	jmp    80107553 <alltraps>

80107c92 <vector28>:
.globl vector28
vector28:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $28
80107c94:	6a 1c                	push   $0x1c
  jmp alltraps
80107c96:	e9 b8 f8 ff ff       	jmp    80107553 <alltraps>

80107c9b <vector29>:
.globl vector29
vector29:
  pushl $0
80107c9b:	6a 00                	push   $0x0
  pushl $29
80107c9d:	6a 1d                	push   $0x1d
  jmp alltraps
80107c9f:	e9 af f8 ff ff       	jmp    80107553 <alltraps>

80107ca4 <vector30>:
.globl vector30
vector30:
  pushl $0
80107ca4:	6a 00                	push   $0x0
  pushl $30
80107ca6:	6a 1e                	push   $0x1e
  jmp alltraps
80107ca8:	e9 a6 f8 ff ff       	jmp    80107553 <alltraps>

80107cad <vector31>:
.globl vector31
vector31:
  pushl $0
80107cad:	6a 00                	push   $0x0
  pushl $31
80107caf:	6a 1f                	push   $0x1f
  jmp alltraps
80107cb1:	e9 9d f8 ff ff       	jmp    80107553 <alltraps>

80107cb6 <vector32>:
.globl vector32
vector32:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $32
80107cb8:	6a 20                	push   $0x20
  jmp alltraps
80107cba:	e9 94 f8 ff ff       	jmp    80107553 <alltraps>

80107cbf <vector33>:
.globl vector33
vector33:
  pushl $0
80107cbf:	6a 00                	push   $0x0
  pushl $33
80107cc1:	6a 21                	push   $0x21
  jmp alltraps
80107cc3:	e9 8b f8 ff ff       	jmp    80107553 <alltraps>

80107cc8 <vector34>:
.globl vector34
vector34:
  pushl $0
80107cc8:	6a 00                	push   $0x0
  pushl $34
80107cca:	6a 22                	push   $0x22
  jmp alltraps
80107ccc:	e9 82 f8 ff ff       	jmp    80107553 <alltraps>

80107cd1 <vector35>:
.globl vector35
vector35:
  pushl $0
80107cd1:	6a 00                	push   $0x0
  pushl $35
80107cd3:	6a 23                	push   $0x23
  jmp alltraps
80107cd5:	e9 79 f8 ff ff       	jmp    80107553 <alltraps>

80107cda <vector36>:
.globl vector36
vector36:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $36
80107cdc:	6a 24                	push   $0x24
  jmp alltraps
80107cde:	e9 70 f8 ff ff       	jmp    80107553 <alltraps>

80107ce3 <vector37>:
.globl vector37
vector37:
  pushl $0
80107ce3:	6a 00                	push   $0x0
  pushl $37
80107ce5:	6a 25                	push   $0x25
  jmp alltraps
80107ce7:	e9 67 f8 ff ff       	jmp    80107553 <alltraps>

80107cec <vector38>:
.globl vector38
vector38:
  pushl $0
80107cec:	6a 00                	push   $0x0
  pushl $38
80107cee:	6a 26                	push   $0x26
  jmp alltraps
80107cf0:	e9 5e f8 ff ff       	jmp    80107553 <alltraps>

80107cf5 <vector39>:
.globl vector39
vector39:
  pushl $0
80107cf5:	6a 00                	push   $0x0
  pushl $39
80107cf7:	6a 27                	push   $0x27
  jmp alltraps
80107cf9:	e9 55 f8 ff ff       	jmp    80107553 <alltraps>

80107cfe <vector40>:
.globl vector40
vector40:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $40
80107d00:	6a 28                	push   $0x28
  jmp alltraps
80107d02:	e9 4c f8 ff ff       	jmp    80107553 <alltraps>

80107d07 <vector41>:
.globl vector41
vector41:
  pushl $0
80107d07:	6a 00                	push   $0x0
  pushl $41
80107d09:	6a 29                	push   $0x29
  jmp alltraps
80107d0b:	e9 43 f8 ff ff       	jmp    80107553 <alltraps>

80107d10 <vector42>:
.globl vector42
vector42:
  pushl $0
80107d10:	6a 00                	push   $0x0
  pushl $42
80107d12:	6a 2a                	push   $0x2a
  jmp alltraps
80107d14:	e9 3a f8 ff ff       	jmp    80107553 <alltraps>

80107d19 <vector43>:
.globl vector43
vector43:
  pushl $0
80107d19:	6a 00                	push   $0x0
  pushl $43
80107d1b:	6a 2b                	push   $0x2b
  jmp alltraps
80107d1d:	e9 31 f8 ff ff       	jmp    80107553 <alltraps>

80107d22 <vector44>:
.globl vector44
vector44:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $44
80107d24:	6a 2c                	push   $0x2c
  jmp alltraps
80107d26:	e9 28 f8 ff ff       	jmp    80107553 <alltraps>

80107d2b <vector45>:
.globl vector45
vector45:
  pushl $0
80107d2b:	6a 00                	push   $0x0
  pushl $45
80107d2d:	6a 2d                	push   $0x2d
  jmp alltraps
80107d2f:	e9 1f f8 ff ff       	jmp    80107553 <alltraps>

80107d34 <vector46>:
.globl vector46
vector46:
  pushl $0
80107d34:	6a 00                	push   $0x0
  pushl $46
80107d36:	6a 2e                	push   $0x2e
  jmp alltraps
80107d38:	e9 16 f8 ff ff       	jmp    80107553 <alltraps>

80107d3d <vector47>:
.globl vector47
vector47:
  pushl $0
80107d3d:	6a 00                	push   $0x0
  pushl $47
80107d3f:	6a 2f                	push   $0x2f
  jmp alltraps
80107d41:	e9 0d f8 ff ff       	jmp    80107553 <alltraps>

80107d46 <vector48>:
.globl vector48
vector48:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $48
80107d48:	6a 30                	push   $0x30
  jmp alltraps
80107d4a:	e9 04 f8 ff ff       	jmp    80107553 <alltraps>

80107d4f <vector49>:
.globl vector49
vector49:
  pushl $0
80107d4f:	6a 00                	push   $0x0
  pushl $49
80107d51:	6a 31                	push   $0x31
  jmp alltraps
80107d53:	e9 fb f7 ff ff       	jmp    80107553 <alltraps>

80107d58 <vector50>:
.globl vector50
vector50:
  pushl $0
80107d58:	6a 00                	push   $0x0
  pushl $50
80107d5a:	6a 32                	push   $0x32
  jmp alltraps
80107d5c:	e9 f2 f7 ff ff       	jmp    80107553 <alltraps>

80107d61 <vector51>:
.globl vector51
vector51:
  pushl $0
80107d61:	6a 00                	push   $0x0
  pushl $51
80107d63:	6a 33                	push   $0x33
  jmp alltraps
80107d65:	e9 e9 f7 ff ff       	jmp    80107553 <alltraps>

80107d6a <vector52>:
.globl vector52
vector52:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $52
80107d6c:	6a 34                	push   $0x34
  jmp alltraps
80107d6e:	e9 e0 f7 ff ff       	jmp    80107553 <alltraps>

80107d73 <vector53>:
.globl vector53
vector53:
  pushl $0
80107d73:	6a 00                	push   $0x0
  pushl $53
80107d75:	6a 35                	push   $0x35
  jmp alltraps
80107d77:	e9 d7 f7 ff ff       	jmp    80107553 <alltraps>

80107d7c <vector54>:
.globl vector54
vector54:
  pushl $0
80107d7c:	6a 00                	push   $0x0
  pushl $54
80107d7e:	6a 36                	push   $0x36
  jmp alltraps
80107d80:	e9 ce f7 ff ff       	jmp    80107553 <alltraps>

80107d85 <vector55>:
.globl vector55
vector55:
  pushl $0
80107d85:	6a 00                	push   $0x0
  pushl $55
80107d87:	6a 37                	push   $0x37
  jmp alltraps
80107d89:	e9 c5 f7 ff ff       	jmp    80107553 <alltraps>

80107d8e <vector56>:
.globl vector56
vector56:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $56
80107d90:	6a 38                	push   $0x38
  jmp alltraps
80107d92:	e9 bc f7 ff ff       	jmp    80107553 <alltraps>

80107d97 <vector57>:
.globl vector57
vector57:
  pushl $0
80107d97:	6a 00                	push   $0x0
  pushl $57
80107d99:	6a 39                	push   $0x39
  jmp alltraps
80107d9b:	e9 b3 f7 ff ff       	jmp    80107553 <alltraps>

80107da0 <vector58>:
.globl vector58
vector58:
  pushl $0
80107da0:	6a 00                	push   $0x0
  pushl $58
80107da2:	6a 3a                	push   $0x3a
  jmp alltraps
80107da4:	e9 aa f7 ff ff       	jmp    80107553 <alltraps>

80107da9 <vector59>:
.globl vector59
vector59:
  pushl $0
80107da9:	6a 00                	push   $0x0
  pushl $59
80107dab:	6a 3b                	push   $0x3b
  jmp alltraps
80107dad:	e9 a1 f7 ff ff       	jmp    80107553 <alltraps>

80107db2 <vector60>:
.globl vector60
vector60:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $60
80107db4:	6a 3c                	push   $0x3c
  jmp alltraps
80107db6:	e9 98 f7 ff ff       	jmp    80107553 <alltraps>

80107dbb <vector61>:
.globl vector61
vector61:
  pushl $0
80107dbb:	6a 00                	push   $0x0
  pushl $61
80107dbd:	6a 3d                	push   $0x3d
  jmp alltraps
80107dbf:	e9 8f f7 ff ff       	jmp    80107553 <alltraps>

80107dc4 <vector62>:
.globl vector62
vector62:
  pushl $0
80107dc4:	6a 00                	push   $0x0
  pushl $62
80107dc6:	6a 3e                	push   $0x3e
  jmp alltraps
80107dc8:	e9 86 f7 ff ff       	jmp    80107553 <alltraps>

80107dcd <vector63>:
.globl vector63
vector63:
  pushl $0
80107dcd:	6a 00                	push   $0x0
  pushl $63
80107dcf:	6a 3f                	push   $0x3f
  jmp alltraps
80107dd1:	e9 7d f7 ff ff       	jmp    80107553 <alltraps>

80107dd6 <vector64>:
.globl vector64
vector64:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $64
80107dd8:	6a 40                	push   $0x40
  jmp alltraps
80107dda:	e9 74 f7 ff ff       	jmp    80107553 <alltraps>

80107ddf <vector65>:
.globl vector65
vector65:
  pushl $0
80107ddf:	6a 00                	push   $0x0
  pushl $65
80107de1:	6a 41                	push   $0x41
  jmp alltraps
80107de3:	e9 6b f7 ff ff       	jmp    80107553 <alltraps>

80107de8 <vector66>:
.globl vector66
vector66:
  pushl $0
80107de8:	6a 00                	push   $0x0
  pushl $66
80107dea:	6a 42                	push   $0x42
  jmp alltraps
80107dec:	e9 62 f7 ff ff       	jmp    80107553 <alltraps>

80107df1 <vector67>:
.globl vector67
vector67:
  pushl $0
80107df1:	6a 00                	push   $0x0
  pushl $67
80107df3:	6a 43                	push   $0x43
  jmp alltraps
80107df5:	e9 59 f7 ff ff       	jmp    80107553 <alltraps>

80107dfa <vector68>:
.globl vector68
vector68:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $68
80107dfc:	6a 44                	push   $0x44
  jmp alltraps
80107dfe:	e9 50 f7 ff ff       	jmp    80107553 <alltraps>

80107e03 <vector69>:
.globl vector69
vector69:
  pushl $0
80107e03:	6a 00                	push   $0x0
  pushl $69
80107e05:	6a 45                	push   $0x45
  jmp alltraps
80107e07:	e9 47 f7 ff ff       	jmp    80107553 <alltraps>

80107e0c <vector70>:
.globl vector70
vector70:
  pushl $0
80107e0c:	6a 00                	push   $0x0
  pushl $70
80107e0e:	6a 46                	push   $0x46
  jmp alltraps
80107e10:	e9 3e f7 ff ff       	jmp    80107553 <alltraps>

80107e15 <vector71>:
.globl vector71
vector71:
  pushl $0
80107e15:	6a 00                	push   $0x0
  pushl $71
80107e17:	6a 47                	push   $0x47
  jmp alltraps
80107e19:	e9 35 f7 ff ff       	jmp    80107553 <alltraps>

80107e1e <vector72>:
.globl vector72
vector72:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $72
80107e20:	6a 48                	push   $0x48
  jmp alltraps
80107e22:	e9 2c f7 ff ff       	jmp    80107553 <alltraps>

80107e27 <vector73>:
.globl vector73
vector73:
  pushl $0
80107e27:	6a 00                	push   $0x0
  pushl $73
80107e29:	6a 49                	push   $0x49
  jmp alltraps
80107e2b:	e9 23 f7 ff ff       	jmp    80107553 <alltraps>

80107e30 <vector74>:
.globl vector74
vector74:
  pushl $0
80107e30:	6a 00                	push   $0x0
  pushl $74
80107e32:	6a 4a                	push   $0x4a
  jmp alltraps
80107e34:	e9 1a f7 ff ff       	jmp    80107553 <alltraps>

80107e39 <vector75>:
.globl vector75
vector75:
  pushl $0
80107e39:	6a 00                	push   $0x0
  pushl $75
80107e3b:	6a 4b                	push   $0x4b
  jmp alltraps
80107e3d:	e9 11 f7 ff ff       	jmp    80107553 <alltraps>

80107e42 <vector76>:
.globl vector76
vector76:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $76
80107e44:	6a 4c                	push   $0x4c
  jmp alltraps
80107e46:	e9 08 f7 ff ff       	jmp    80107553 <alltraps>

80107e4b <vector77>:
.globl vector77
vector77:
  pushl $0
80107e4b:	6a 00                	push   $0x0
  pushl $77
80107e4d:	6a 4d                	push   $0x4d
  jmp alltraps
80107e4f:	e9 ff f6 ff ff       	jmp    80107553 <alltraps>

80107e54 <vector78>:
.globl vector78
vector78:
  pushl $0
80107e54:	6a 00                	push   $0x0
  pushl $78
80107e56:	6a 4e                	push   $0x4e
  jmp alltraps
80107e58:	e9 f6 f6 ff ff       	jmp    80107553 <alltraps>

80107e5d <vector79>:
.globl vector79
vector79:
  pushl $0
80107e5d:	6a 00                	push   $0x0
  pushl $79
80107e5f:	6a 4f                	push   $0x4f
  jmp alltraps
80107e61:	e9 ed f6 ff ff       	jmp    80107553 <alltraps>

80107e66 <vector80>:
.globl vector80
vector80:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $80
80107e68:	6a 50                	push   $0x50
  jmp alltraps
80107e6a:	e9 e4 f6 ff ff       	jmp    80107553 <alltraps>

80107e6f <vector81>:
.globl vector81
vector81:
  pushl $0
80107e6f:	6a 00                	push   $0x0
  pushl $81
80107e71:	6a 51                	push   $0x51
  jmp alltraps
80107e73:	e9 db f6 ff ff       	jmp    80107553 <alltraps>

80107e78 <vector82>:
.globl vector82
vector82:
  pushl $0
80107e78:	6a 00                	push   $0x0
  pushl $82
80107e7a:	6a 52                	push   $0x52
  jmp alltraps
80107e7c:	e9 d2 f6 ff ff       	jmp    80107553 <alltraps>

80107e81 <vector83>:
.globl vector83
vector83:
  pushl $0
80107e81:	6a 00                	push   $0x0
  pushl $83
80107e83:	6a 53                	push   $0x53
  jmp alltraps
80107e85:	e9 c9 f6 ff ff       	jmp    80107553 <alltraps>

80107e8a <vector84>:
.globl vector84
vector84:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $84
80107e8c:	6a 54                	push   $0x54
  jmp alltraps
80107e8e:	e9 c0 f6 ff ff       	jmp    80107553 <alltraps>

80107e93 <vector85>:
.globl vector85
vector85:
  pushl $0
80107e93:	6a 00                	push   $0x0
  pushl $85
80107e95:	6a 55                	push   $0x55
  jmp alltraps
80107e97:	e9 b7 f6 ff ff       	jmp    80107553 <alltraps>

80107e9c <vector86>:
.globl vector86
vector86:
  pushl $0
80107e9c:	6a 00                	push   $0x0
  pushl $86
80107e9e:	6a 56                	push   $0x56
  jmp alltraps
80107ea0:	e9 ae f6 ff ff       	jmp    80107553 <alltraps>

80107ea5 <vector87>:
.globl vector87
vector87:
  pushl $0
80107ea5:	6a 00                	push   $0x0
  pushl $87
80107ea7:	6a 57                	push   $0x57
  jmp alltraps
80107ea9:	e9 a5 f6 ff ff       	jmp    80107553 <alltraps>

80107eae <vector88>:
.globl vector88
vector88:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $88
80107eb0:	6a 58                	push   $0x58
  jmp alltraps
80107eb2:	e9 9c f6 ff ff       	jmp    80107553 <alltraps>

80107eb7 <vector89>:
.globl vector89
vector89:
  pushl $0
80107eb7:	6a 00                	push   $0x0
  pushl $89
80107eb9:	6a 59                	push   $0x59
  jmp alltraps
80107ebb:	e9 93 f6 ff ff       	jmp    80107553 <alltraps>

80107ec0 <vector90>:
.globl vector90
vector90:
  pushl $0
80107ec0:	6a 00                	push   $0x0
  pushl $90
80107ec2:	6a 5a                	push   $0x5a
  jmp alltraps
80107ec4:	e9 8a f6 ff ff       	jmp    80107553 <alltraps>

80107ec9 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ec9:	6a 00                	push   $0x0
  pushl $91
80107ecb:	6a 5b                	push   $0x5b
  jmp alltraps
80107ecd:	e9 81 f6 ff ff       	jmp    80107553 <alltraps>

80107ed2 <vector92>:
.globl vector92
vector92:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $92
80107ed4:	6a 5c                	push   $0x5c
  jmp alltraps
80107ed6:	e9 78 f6 ff ff       	jmp    80107553 <alltraps>

80107edb <vector93>:
.globl vector93
vector93:
  pushl $0
80107edb:	6a 00                	push   $0x0
  pushl $93
80107edd:	6a 5d                	push   $0x5d
  jmp alltraps
80107edf:	e9 6f f6 ff ff       	jmp    80107553 <alltraps>

80107ee4 <vector94>:
.globl vector94
vector94:
  pushl $0
80107ee4:	6a 00                	push   $0x0
  pushl $94
80107ee6:	6a 5e                	push   $0x5e
  jmp alltraps
80107ee8:	e9 66 f6 ff ff       	jmp    80107553 <alltraps>

80107eed <vector95>:
.globl vector95
vector95:
  pushl $0
80107eed:	6a 00                	push   $0x0
  pushl $95
80107eef:	6a 5f                	push   $0x5f
  jmp alltraps
80107ef1:	e9 5d f6 ff ff       	jmp    80107553 <alltraps>

80107ef6 <vector96>:
.globl vector96
vector96:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $96
80107ef8:	6a 60                	push   $0x60
  jmp alltraps
80107efa:	e9 54 f6 ff ff       	jmp    80107553 <alltraps>

80107eff <vector97>:
.globl vector97
vector97:
  pushl $0
80107eff:	6a 00                	push   $0x0
  pushl $97
80107f01:	6a 61                	push   $0x61
  jmp alltraps
80107f03:	e9 4b f6 ff ff       	jmp    80107553 <alltraps>

80107f08 <vector98>:
.globl vector98
vector98:
  pushl $0
80107f08:	6a 00                	push   $0x0
  pushl $98
80107f0a:	6a 62                	push   $0x62
  jmp alltraps
80107f0c:	e9 42 f6 ff ff       	jmp    80107553 <alltraps>

80107f11 <vector99>:
.globl vector99
vector99:
  pushl $0
80107f11:	6a 00                	push   $0x0
  pushl $99
80107f13:	6a 63                	push   $0x63
  jmp alltraps
80107f15:	e9 39 f6 ff ff       	jmp    80107553 <alltraps>

80107f1a <vector100>:
.globl vector100
vector100:
  pushl $0
80107f1a:	6a 00                	push   $0x0
  pushl $100
80107f1c:	6a 64                	push   $0x64
  jmp alltraps
80107f1e:	e9 30 f6 ff ff       	jmp    80107553 <alltraps>

80107f23 <vector101>:
.globl vector101
vector101:
  pushl $0
80107f23:	6a 00                	push   $0x0
  pushl $101
80107f25:	6a 65                	push   $0x65
  jmp alltraps
80107f27:	e9 27 f6 ff ff       	jmp    80107553 <alltraps>

80107f2c <vector102>:
.globl vector102
vector102:
  pushl $0
80107f2c:	6a 00                	push   $0x0
  pushl $102
80107f2e:	6a 66                	push   $0x66
  jmp alltraps
80107f30:	e9 1e f6 ff ff       	jmp    80107553 <alltraps>

80107f35 <vector103>:
.globl vector103
vector103:
  pushl $0
80107f35:	6a 00                	push   $0x0
  pushl $103
80107f37:	6a 67                	push   $0x67
  jmp alltraps
80107f39:	e9 15 f6 ff ff       	jmp    80107553 <alltraps>

80107f3e <vector104>:
.globl vector104
vector104:
  pushl $0
80107f3e:	6a 00                	push   $0x0
  pushl $104
80107f40:	6a 68                	push   $0x68
  jmp alltraps
80107f42:	e9 0c f6 ff ff       	jmp    80107553 <alltraps>

80107f47 <vector105>:
.globl vector105
vector105:
  pushl $0
80107f47:	6a 00                	push   $0x0
  pushl $105
80107f49:	6a 69                	push   $0x69
  jmp alltraps
80107f4b:	e9 03 f6 ff ff       	jmp    80107553 <alltraps>

80107f50 <vector106>:
.globl vector106
vector106:
  pushl $0
80107f50:	6a 00                	push   $0x0
  pushl $106
80107f52:	6a 6a                	push   $0x6a
  jmp alltraps
80107f54:	e9 fa f5 ff ff       	jmp    80107553 <alltraps>

80107f59 <vector107>:
.globl vector107
vector107:
  pushl $0
80107f59:	6a 00                	push   $0x0
  pushl $107
80107f5b:	6a 6b                	push   $0x6b
  jmp alltraps
80107f5d:	e9 f1 f5 ff ff       	jmp    80107553 <alltraps>

80107f62 <vector108>:
.globl vector108
vector108:
  pushl $0
80107f62:	6a 00                	push   $0x0
  pushl $108
80107f64:	6a 6c                	push   $0x6c
  jmp alltraps
80107f66:	e9 e8 f5 ff ff       	jmp    80107553 <alltraps>

80107f6b <vector109>:
.globl vector109
vector109:
  pushl $0
80107f6b:	6a 00                	push   $0x0
  pushl $109
80107f6d:	6a 6d                	push   $0x6d
  jmp alltraps
80107f6f:	e9 df f5 ff ff       	jmp    80107553 <alltraps>

80107f74 <vector110>:
.globl vector110
vector110:
  pushl $0
80107f74:	6a 00                	push   $0x0
  pushl $110
80107f76:	6a 6e                	push   $0x6e
  jmp alltraps
80107f78:	e9 d6 f5 ff ff       	jmp    80107553 <alltraps>

80107f7d <vector111>:
.globl vector111
vector111:
  pushl $0
80107f7d:	6a 00                	push   $0x0
  pushl $111
80107f7f:	6a 6f                	push   $0x6f
  jmp alltraps
80107f81:	e9 cd f5 ff ff       	jmp    80107553 <alltraps>

80107f86 <vector112>:
.globl vector112
vector112:
  pushl $0
80107f86:	6a 00                	push   $0x0
  pushl $112
80107f88:	6a 70                	push   $0x70
  jmp alltraps
80107f8a:	e9 c4 f5 ff ff       	jmp    80107553 <alltraps>

80107f8f <vector113>:
.globl vector113
vector113:
  pushl $0
80107f8f:	6a 00                	push   $0x0
  pushl $113
80107f91:	6a 71                	push   $0x71
  jmp alltraps
80107f93:	e9 bb f5 ff ff       	jmp    80107553 <alltraps>

80107f98 <vector114>:
.globl vector114
vector114:
  pushl $0
80107f98:	6a 00                	push   $0x0
  pushl $114
80107f9a:	6a 72                	push   $0x72
  jmp alltraps
80107f9c:	e9 b2 f5 ff ff       	jmp    80107553 <alltraps>

80107fa1 <vector115>:
.globl vector115
vector115:
  pushl $0
80107fa1:	6a 00                	push   $0x0
  pushl $115
80107fa3:	6a 73                	push   $0x73
  jmp alltraps
80107fa5:	e9 a9 f5 ff ff       	jmp    80107553 <alltraps>

80107faa <vector116>:
.globl vector116
vector116:
  pushl $0
80107faa:	6a 00                	push   $0x0
  pushl $116
80107fac:	6a 74                	push   $0x74
  jmp alltraps
80107fae:	e9 a0 f5 ff ff       	jmp    80107553 <alltraps>

80107fb3 <vector117>:
.globl vector117
vector117:
  pushl $0
80107fb3:	6a 00                	push   $0x0
  pushl $117
80107fb5:	6a 75                	push   $0x75
  jmp alltraps
80107fb7:	e9 97 f5 ff ff       	jmp    80107553 <alltraps>

80107fbc <vector118>:
.globl vector118
vector118:
  pushl $0
80107fbc:	6a 00                	push   $0x0
  pushl $118
80107fbe:	6a 76                	push   $0x76
  jmp alltraps
80107fc0:	e9 8e f5 ff ff       	jmp    80107553 <alltraps>

80107fc5 <vector119>:
.globl vector119
vector119:
  pushl $0
80107fc5:	6a 00                	push   $0x0
  pushl $119
80107fc7:	6a 77                	push   $0x77
  jmp alltraps
80107fc9:	e9 85 f5 ff ff       	jmp    80107553 <alltraps>

80107fce <vector120>:
.globl vector120
vector120:
  pushl $0
80107fce:	6a 00                	push   $0x0
  pushl $120
80107fd0:	6a 78                	push   $0x78
  jmp alltraps
80107fd2:	e9 7c f5 ff ff       	jmp    80107553 <alltraps>

80107fd7 <vector121>:
.globl vector121
vector121:
  pushl $0
80107fd7:	6a 00                	push   $0x0
  pushl $121
80107fd9:	6a 79                	push   $0x79
  jmp alltraps
80107fdb:	e9 73 f5 ff ff       	jmp    80107553 <alltraps>

80107fe0 <vector122>:
.globl vector122
vector122:
  pushl $0
80107fe0:	6a 00                	push   $0x0
  pushl $122
80107fe2:	6a 7a                	push   $0x7a
  jmp alltraps
80107fe4:	e9 6a f5 ff ff       	jmp    80107553 <alltraps>

80107fe9 <vector123>:
.globl vector123
vector123:
  pushl $0
80107fe9:	6a 00                	push   $0x0
  pushl $123
80107feb:	6a 7b                	push   $0x7b
  jmp alltraps
80107fed:	e9 61 f5 ff ff       	jmp    80107553 <alltraps>

80107ff2 <vector124>:
.globl vector124
vector124:
  pushl $0
80107ff2:	6a 00                	push   $0x0
  pushl $124
80107ff4:	6a 7c                	push   $0x7c
  jmp alltraps
80107ff6:	e9 58 f5 ff ff       	jmp    80107553 <alltraps>

80107ffb <vector125>:
.globl vector125
vector125:
  pushl $0
80107ffb:	6a 00                	push   $0x0
  pushl $125
80107ffd:	6a 7d                	push   $0x7d
  jmp alltraps
80107fff:	e9 4f f5 ff ff       	jmp    80107553 <alltraps>

80108004 <vector126>:
.globl vector126
vector126:
  pushl $0
80108004:	6a 00                	push   $0x0
  pushl $126
80108006:	6a 7e                	push   $0x7e
  jmp alltraps
80108008:	e9 46 f5 ff ff       	jmp    80107553 <alltraps>

8010800d <vector127>:
.globl vector127
vector127:
  pushl $0
8010800d:	6a 00                	push   $0x0
  pushl $127
8010800f:	6a 7f                	push   $0x7f
  jmp alltraps
80108011:	e9 3d f5 ff ff       	jmp    80107553 <alltraps>

80108016 <vector128>:
.globl vector128
vector128:
  pushl $0
80108016:	6a 00                	push   $0x0
  pushl $128
80108018:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010801d:	e9 31 f5 ff ff       	jmp    80107553 <alltraps>

80108022 <vector129>:
.globl vector129
vector129:
  pushl $0
80108022:	6a 00                	push   $0x0
  pushl $129
80108024:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108029:	e9 25 f5 ff ff       	jmp    80107553 <alltraps>

8010802e <vector130>:
.globl vector130
vector130:
  pushl $0
8010802e:	6a 00                	push   $0x0
  pushl $130
80108030:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108035:	e9 19 f5 ff ff       	jmp    80107553 <alltraps>

8010803a <vector131>:
.globl vector131
vector131:
  pushl $0
8010803a:	6a 00                	push   $0x0
  pushl $131
8010803c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108041:	e9 0d f5 ff ff       	jmp    80107553 <alltraps>

80108046 <vector132>:
.globl vector132
vector132:
  pushl $0
80108046:	6a 00                	push   $0x0
  pushl $132
80108048:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010804d:	e9 01 f5 ff ff       	jmp    80107553 <alltraps>

80108052 <vector133>:
.globl vector133
vector133:
  pushl $0
80108052:	6a 00                	push   $0x0
  pushl $133
80108054:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108059:	e9 f5 f4 ff ff       	jmp    80107553 <alltraps>

8010805e <vector134>:
.globl vector134
vector134:
  pushl $0
8010805e:	6a 00                	push   $0x0
  pushl $134
80108060:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108065:	e9 e9 f4 ff ff       	jmp    80107553 <alltraps>

8010806a <vector135>:
.globl vector135
vector135:
  pushl $0
8010806a:	6a 00                	push   $0x0
  pushl $135
8010806c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108071:	e9 dd f4 ff ff       	jmp    80107553 <alltraps>

80108076 <vector136>:
.globl vector136
vector136:
  pushl $0
80108076:	6a 00                	push   $0x0
  pushl $136
80108078:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010807d:	e9 d1 f4 ff ff       	jmp    80107553 <alltraps>

80108082 <vector137>:
.globl vector137
vector137:
  pushl $0
80108082:	6a 00                	push   $0x0
  pushl $137
80108084:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108089:	e9 c5 f4 ff ff       	jmp    80107553 <alltraps>

8010808e <vector138>:
.globl vector138
vector138:
  pushl $0
8010808e:	6a 00                	push   $0x0
  pushl $138
80108090:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108095:	e9 b9 f4 ff ff       	jmp    80107553 <alltraps>

8010809a <vector139>:
.globl vector139
vector139:
  pushl $0
8010809a:	6a 00                	push   $0x0
  pushl $139
8010809c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801080a1:	e9 ad f4 ff ff       	jmp    80107553 <alltraps>

801080a6 <vector140>:
.globl vector140
vector140:
  pushl $0
801080a6:	6a 00                	push   $0x0
  pushl $140
801080a8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801080ad:	e9 a1 f4 ff ff       	jmp    80107553 <alltraps>

801080b2 <vector141>:
.globl vector141
vector141:
  pushl $0
801080b2:	6a 00                	push   $0x0
  pushl $141
801080b4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801080b9:	e9 95 f4 ff ff       	jmp    80107553 <alltraps>

801080be <vector142>:
.globl vector142
vector142:
  pushl $0
801080be:	6a 00                	push   $0x0
  pushl $142
801080c0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801080c5:	e9 89 f4 ff ff       	jmp    80107553 <alltraps>

801080ca <vector143>:
.globl vector143
vector143:
  pushl $0
801080ca:	6a 00                	push   $0x0
  pushl $143
801080cc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801080d1:	e9 7d f4 ff ff       	jmp    80107553 <alltraps>

801080d6 <vector144>:
.globl vector144
vector144:
  pushl $0
801080d6:	6a 00                	push   $0x0
  pushl $144
801080d8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801080dd:	e9 71 f4 ff ff       	jmp    80107553 <alltraps>

801080e2 <vector145>:
.globl vector145
vector145:
  pushl $0
801080e2:	6a 00                	push   $0x0
  pushl $145
801080e4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801080e9:	e9 65 f4 ff ff       	jmp    80107553 <alltraps>

801080ee <vector146>:
.globl vector146
vector146:
  pushl $0
801080ee:	6a 00                	push   $0x0
  pushl $146
801080f0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801080f5:	e9 59 f4 ff ff       	jmp    80107553 <alltraps>

801080fa <vector147>:
.globl vector147
vector147:
  pushl $0
801080fa:	6a 00                	push   $0x0
  pushl $147
801080fc:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108101:	e9 4d f4 ff ff       	jmp    80107553 <alltraps>

80108106 <vector148>:
.globl vector148
vector148:
  pushl $0
80108106:	6a 00                	push   $0x0
  pushl $148
80108108:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010810d:	e9 41 f4 ff ff       	jmp    80107553 <alltraps>

80108112 <vector149>:
.globl vector149
vector149:
  pushl $0
80108112:	6a 00                	push   $0x0
  pushl $149
80108114:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108119:	e9 35 f4 ff ff       	jmp    80107553 <alltraps>

8010811e <vector150>:
.globl vector150
vector150:
  pushl $0
8010811e:	6a 00                	push   $0x0
  pushl $150
80108120:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108125:	e9 29 f4 ff ff       	jmp    80107553 <alltraps>

8010812a <vector151>:
.globl vector151
vector151:
  pushl $0
8010812a:	6a 00                	push   $0x0
  pushl $151
8010812c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108131:	e9 1d f4 ff ff       	jmp    80107553 <alltraps>

80108136 <vector152>:
.globl vector152
vector152:
  pushl $0
80108136:	6a 00                	push   $0x0
  pushl $152
80108138:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010813d:	e9 11 f4 ff ff       	jmp    80107553 <alltraps>

80108142 <vector153>:
.globl vector153
vector153:
  pushl $0
80108142:	6a 00                	push   $0x0
  pushl $153
80108144:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108149:	e9 05 f4 ff ff       	jmp    80107553 <alltraps>

8010814e <vector154>:
.globl vector154
vector154:
  pushl $0
8010814e:	6a 00                	push   $0x0
  pushl $154
80108150:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108155:	e9 f9 f3 ff ff       	jmp    80107553 <alltraps>

8010815a <vector155>:
.globl vector155
vector155:
  pushl $0
8010815a:	6a 00                	push   $0x0
  pushl $155
8010815c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108161:	e9 ed f3 ff ff       	jmp    80107553 <alltraps>

80108166 <vector156>:
.globl vector156
vector156:
  pushl $0
80108166:	6a 00                	push   $0x0
  pushl $156
80108168:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010816d:	e9 e1 f3 ff ff       	jmp    80107553 <alltraps>

80108172 <vector157>:
.globl vector157
vector157:
  pushl $0
80108172:	6a 00                	push   $0x0
  pushl $157
80108174:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108179:	e9 d5 f3 ff ff       	jmp    80107553 <alltraps>

8010817e <vector158>:
.globl vector158
vector158:
  pushl $0
8010817e:	6a 00                	push   $0x0
  pushl $158
80108180:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108185:	e9 c9 f3 ff ff       	jmp    80107553 <alltraps>

8010818a <vector159>:
.globl vector159
vector159:
  pushl $0
8010818a:	6a 00                	push   $0x0
  pushl $159
8010818c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108191:	e9 bd f3 ff ff       	jmp    80107553 <alltraps>

80108196 <vector160>:
.globl vector160
vector160:
  pushl $0
80108196:	6a 00                	push   $0x0
  pushl $160
80108198:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010819d:	e9 b1 f3 ff ff       	jmp    80107553 <alltraps>

801081a2 <vector161>:
.globl vector161
vector161:
  pushl $0
801081a2:	6a 00                	push   $0x0
  pushl $161
801081a4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801081a9:	e9 a5 f3 ff ff       	jmp    80107553 <alltraps>

801081ae <vector162>:
.globl vector162
vector162:
  pushl $0
801081ae:	6a 00                	push   $0x0
  pushl $162
801081b0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801081b5:	e9 99 f3 ff ff       	jmp    80107553 <alltraps>

801081ba <vector163>:
.globl vector163
vector163:
  pushl $0
801081ba:	6a 00                	push   $0x0
  pushl $163
801081bc:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801081c1:	e9 8d f3 ff ff       	jmp    80107553 <alltraps>

801081c6 <vector164>:
.globl vector164
vector164:
  pushl $0
801081c6:	6a 00                	push   $0x0
  pushl $164
801081c8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801081cd:	e9 81 f3 ff ff       	jmp    80107553 <alltraps>

801081d2 <vector165>:
.globl vector165
vector165:
  pushl $0
801081d2:	6a 00                	push   $0x0
  pushl $165
801081d4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801081d9:	e9 75 f3 ff ff       	jmp    80107553 <alltraps>

801081de <vector166>:
.globl vector166
vector166:
  pushl $0
801081de:	6a 00                	push   $0x0
  pushl $166
801081e0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801081e5:	e9 69 f3 ff ff       	jmp    80107553 <alltraps>

801081ea <vector167>:
.globl vector167
vector167:
  pushl $0
801081ea:	6a 00                	push   $0x0
  pushl $167
801081ec:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801081f1:	e9 5d f3 ff ff       	jmp    80107553 <alltraps>

801081f6 <vector168>:
.globl vector168
vector168:
  pushl $0
801081f6:	6a 00                	push   $0x0
  pushl $168
801081f8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801081fd:	e9 51 f3 ff ff       	jmp    80107553 <alltraps>

80108202 <vector169>:
.globl vector169
vector169:
  pushl $0
80108202:	6a 00                	push   $0x0
  pushl $169
80108204:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108209:	e9 45 f3 ff ff       	jmp    80107553 <alltraps>

8010820e <vector170>:
.globl vector170
vector170:
  pushl $0
8010820e:	6a 00                	push   $0x0
  pushl $170
80108210:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108215:	e9 39 f3 ff ff       	jmp    80107553 <alltraps>

8010821a <vector171>:
.globl vector171
vector171:
  pushl $0
8010821a:	6a 00                	push   $0x0
  pushl $171
8010821c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108221:	e9 2d f3 ff ff       	jmp    80107553 <alltraps>

80108226 <vector172>:
.globl vector172
vector172:
  pushl $0
80108226:	6a 00                	push   $0x0
  pushl $172
80108228:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010822d:	e9 21 f3 ff ff       	jmp    80107553 <alltraps>

80108232 <vector173>:
.globl vector173
vector173:
  pushl $0
80108232:	6a 00                	push   $0x0
  pushl $173
80108234:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108239:	e9 15 f3 ff ff       	jmp    80107553 <alltraps>

8010823e <vector174>:
.globl vector174
vector174:
  pushl $0
8010823e:	6a 00                	push   $0x0
  pushl $174
80108240:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108245:	e9 09 f3 ff ff       	jmp    80107553 <alltraps>

8010824a <vector175>:
.globl vector175
vector175:
  pushl $0
8010824a:	6a 00                	push   $0x0
  pushl $175
8010824c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108251:	e9 fd f2 ff ff       	jmp    80107553 <alltraps>

80108256 <vector176>:
.globl vector176
vector176:
  pushl $0
80108256:	6a 00                	push   $0x0
  pushl $176
80108258:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010825d:	e9 f1 f2 ff ff       	jmp    80107553 <alltraps>

80108262 <vector177>:
.globl vector177
vector177:
  pushl $0
80108262:	6a 00                	push   $0x0
  pushl $177
80108264:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108269:	e9 e5 f2 ff ff       	jmp    80107553 <alltraps>

8010826e <vector178>:
.globl vector178
vector178:
  pushl $0
8010826e:	6a 00                	push   $0x0
  pushl $178
80108270:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108275:	e9 d9 f2 ff ff       	jmp    80107553 <alltraps>

8010827a <vector179>:
.globl vector179
vector179:
  pushl $0
8010827a:	6a 00                	push   $0x0
  pushl $179
8010827c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108281:	e9 cd f2 ff ff       	jmp    80107553 <alltraps>

80108286 <vector180>:
.globl vector180
vector180:
  pushl $0
80108286:	6a 00                	push   $0x0
  pushl $180
80108288:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010828d:	e9 c1 f2 ff ff       	jmp    80107553 <alltraps>

80108292 <vector181>:
.globl vector181
vector181:
  pushl $0
80108292:	6a 00                	push   $0x0
  pushl $181
80108294:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108299:	e9 b5 f2 ff ff       	jmp    80107553 <alltraps>

8010829e <vector182>:
.globl vector182
vector182:
  pushl $0
8010829e:	6a 00                	push   $0x0
  pushl $182
801082a0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801082a5:	e9 a9 f2 ff ff       	jmp    80107553 <alltraps>

801082aa <vector183>:
.globl vector183
vector183:
  pushl $0
801082aa:	6a 00                	push   $0x0
  pushl $183
801082ac:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801082b1:	e9 9d f2 ff ff       	jmp    80107553 <alltraps>

801082b6 <vector184>:
.globl vector184
vector184:
  pushl $0
801082b6:	6a 00                	push   $0x0
  pushl $184
801082b8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801082bd:	e9 91 f2 ff ff       	jmp    80107553 <alltraps>

801082c2 <vector185>:
.globl vector185
vector185:
  pushl $0
801082c2:	6a 00                	push   $0x0
  pushl $185
801082c4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801082c9:	e9 85 f2 ff ff       	jmp    80107553 <alltraps>

801082ce <vector186>:
.globl vector186
vector186:
  pushl $0
801082ce:	6a 00                	push   $0x0
  pushl $186
801082d0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801082d5:	e9 79 f2 ff ff       	jmp    80107553 <alltraps>

801082da <vector187>:
.globl vector187
vector187:
  pushl $0
801082da:	6a 00                	push   $0x0
  pushl $187
801082dc:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801082e1:	e9 6d f2 ff ff       	jmp    80107553 <alltraps>

801082e6 <vector188>:
.globl vector188
vector188:
  pushl $0
801082e6:	6a 00                	push   $0x0
  pushl $188
801082e8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801082ed:	e9 61 f2 ff ff       	jmp    80107553 <alltraps>

801082f2 <vector189>:
.globl vector189
vector189:
  pushl $0
801082f2:	6a 00                	push   $0x0
  pushl $189
801082f4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801082f9:	e9 55 f2 ff ff       	jmp    80107553 <alltraps>

801082fe <vector190>:
.globl vector190
vector190:
  pushl $0
801082fe:	6a 00                	push   $0x0
  pushl $190
80108300:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108305:	e9 49 f2 ff ff       	jmp    80107553 <alltraps>

8010830a <vector191>:
.globl vector191
vector191:
  pushl $0
8010830a:	6a 00                	push   $0x0
  pushl $191
8010830c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108311:	e9 3d f2 ff ff       	jmp    80107553 <alltraps>

80108316 <vector192>:
.globl vector192
vector192:
  pushl $0
80108316:	6a 00                	push   $0x0
  pushl $192
80108318:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010831d:	e9 31 f2 ff ff       	jmp    80107553 <alltraps>

80108322 <vector193>:
.globl vector193
vector193:
  pushl $0
80108322:	6a 00                	push   $0x0
  pushl $193
80108324:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108329:	e9 25 f2 ff ff       	jmp    80107553 <alltraps>

8010832e <vector194>:
.globl vector194
vector194:
  pushl $0
8010832e:	6a 00                	push   $0x0
  pushl $194
80108330:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108335:	e9 19 f2 ff ff       	jmp    80107553 <alltraps>

8010833a <vector195>:
.globl vector195
vector195:
  pushl $0
8010833a:	6a 00                	push   $0x0
  pushl $195
8010833c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108341:	e9 0d f2 ff ff       	jmp    80107553 <alltraps>

80108346 <vector196>:
.globl vector196
vector196:
  pushl $0
80108346:	6a 00                	push   $0x0
  pushl $196
80108348:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010834d:	e9 01 f2 ff ff       	jmp    80107553 <alltraps>

80108352 <vector197>:
.globl vector197
vector197:
  pushl $0
80108352:	6a 00                	push   $0x0
  pushl $197
80108354:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108359:	e9 f5 f1 ff ff       	jmp    80107553 <alltraps>

8010835e <vector198>:
.globl vector198
vector198:
  pushl $0
8010835e:	6a 00                	push   $0x0
  pushl $198
80108360:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108365:	e9 e9 f1 ff ff       	jmp    80107553 <alltraps>

8010836a <vector199>:
.globl vector199
vector199:
  pushl $0
8010836a:	6a 00                	push   $0x0
  pushl $199
8010836c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108371:	e9 dd f1 ff ff       	jmp    80107553 <alltraps>

80108376 <vector200>:
.globl vector200
vector200:
  pushl $0
80108376:	6a 00                	push   $0x0
  pushl $200
80108378:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010837d:	e9 d1 f1 ff ff       	jmp    80107553 <alltraps>

80108382 <vector201>:
.globl vector201
vector201:
  pushl $0
80108382:	6a 00                	push   $0x0
  pushl $201
80108384:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108389:	e9 c5 f1 ff ff       	jmp    80107553 <alltraps>

8010838e <vector202>:
.globl vector202
vector202:
  pushl $0
8010838e:	6a 00                	push   $0x0
  pushl $202
80108390:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108395:	e9 b9 f1 ff ff       	jmp    80107553 <alltraps>

8010839a <vector203>:
.globl vector203
vector203:
  pushl $0
8010839a:	6a 00                	push   $0x0
  pushl $203
8010839c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801083a1:	e9 ad f1 ff ff       	jmp    80107553 <alltraps>

801083a6 <vector204>:
.globl vector204
vector204:
  pushl $0
801083a6:	6a 00                	push   $0x0
  pushl $204
801083a8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801083ad:	e9 a1 f1 ff ff       	jmp    80107553 <alltraps>

801083b2 <vector205>:
.globl vector205
vector205:
  pushl $0
801083b2:	6a 00                	push   $0x0
  pushl $205
801083b4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801083b9:	e9 95 f1 ff ff       	jmp    80107553 <alltraps>

801083be <vector206>:
.globl vector206
vector206:
  pushl $0
801083be:	6a 00                	push   $0x0
  pushl $206
801083c0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801083c5:	e9 89 f1 ff ff       	jmp    80107553 <alltraps>

801083ca <vector207>:
.globl vector207
vector207:
  pushl $0
801083ca:	6a 00                	push   $0x0
  pushl $207
801083cc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801083d1:	e9 7d f1 ff ff       	jmp    80107553 <alltraps>

801083d6 <vector208>:
.globl vector208
vector208:
  pushl $0
801083d6:	6a 00                	push   $0x0
  pushl $208
801083d8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801083dd:	e9 71 f1 ff ff       	jmp    80107553 <alltraps>

801083e2 <vector209>:
.globl vector209
vector209:
  pushl $0
801083e2:	6a 00                	push   $0x0
  pushl $209
801083e4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801083e9:	e9 65 f1 ff ff       	jmp    80107553 <alltraps>

801083ee <vector210>:
.globl vector210
vector210:
  pushl $0
801083ee:	6a 00                	push   $0x0
  pushl $210
801083f0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801083f5:	e9 59 f1 ff ff       	jmp    80107553 <alltraps>

801083fa <vector211>:
.globl vector211
vector211:
  pushl $0
801083fa:	6a 00                	push   $0x0
  pushl $211
801083fc:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108401:	e9 4d f1 ff ff       	jmp    80107553 <alltraps>

80108406 <vector212>:
.globl vector212
vector212:
  pushl $0
80108406:	6a 00                	push   $0x0
  pushl $212
80108408:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010840d:	e9 41 f1 ff ff       	jmp    80107553 <alltraps>

80108412 <vector213>:
.globl vector213
vector213:
  pushl $0
80108412:	6a 00                	push   $0x0
  pushl $213
80108414:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108419:	e9 35 f1 ff ff       	jmp    80107553 <alltraps>

8010841e <vector214>:
.globl vector214
vector214:
  pushl $0
8010841e:	6a 00                	push   $0x0
  pushl $214
80108420:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108425:	e9 29 f1 ff ff       	jmp    80107553 <alltraps>

8010842a <vector215>:
.globl vector215
vector215:
  pushl $0
8010842a:	6a 00                	push   $0x0
  pushl $215
8010842c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108431:	e9 1d f1 ff ff       	jmp    80107553 <alltraps>

80108436 <vector216>:
.globl vector216
vector216:
  pushl $0
80108436:	6a 00                	push   $0x0
  pushl $216
80108438:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010843d:	e9 11 f1 ff ff       	jmp    80107553 <alltraps>

80108442 <vector217>:
.globl vector217
vector217:
  pushl $0
80108442:	6a 00                	push   $0x0
  pushl $217
80108444:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108449:	e9 05 f1 ff ff       	jmp    80107553 <alltraps>

8010844e <vector218>:
.globl vector218
vector218:
  pushl $0
8010844e:	6a 00                	push   $0x0
  pushl $218
80108450:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108455:	e9 f9 f0 ff ff       	jmp    80107553 <alltraps>

8010845a <vector219>:
.globl vector219
vector219:
  pushl $0
8010845a:	6a 00                	push   $0x0
  pushl $219
8010845c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108461:	e9 ed f0 ff ff       	jmp    80107553 <alltraps>

80108466 <vector220>:
.globl vector220
vector220:
  pushl $0
80108466:	6a 00                	push   $0x0
  pushl $220
80108468:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010846d:	e9 e1 f0 ff ff       	jmp    80107553 <alltraps>

80108472 <vector221>:
.globl vector221
vector221:
  pushl $0
80108472:	6a 00                	push   $0x0
  pushl $221
80108474:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108479:	e9 d5 f0 ff ff       	jmp    80107553 <alltraps>

8010847e <vector222>:
.globl vector222
vector222:
  pushl $0
8010847e:	6a 00                	push   $0x0
  pushl $222
80108480:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108485:	e9 c9 f0 ff ff       	jmp    80107553 <alltraps>

8010848a <vector223>:
.globl vector223
vector223:
  pushl $0
8010848a:	6a 00                	push   $0x0
  pushl $223
8010848c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108491:	e9 bd f0 ff ff       	jmp    80107553 <alltraps>

80108496 <vector224>:
.globl vector224
vector224:
  pushl $0
80108496:	6a 00                	push   $0x0
  pushl $224
80108498:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010849d:	e9 b1 f0 ff ff       	jmp    80107553 <alltraps>

801084a2 <vector225>:
.globl vector225
vector225:
  pushl $0
801084a2:	6a 00                	push   $0x0
  pushl $225
801084a4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801084a9:	e9 a5 f0 ff ff       	jmp    80107553 <alltraps>

801084ae <vector226>:
.globl vector226
vector226:
  pushl $0
801084ae:	6a 00                	push   $0x0
  pushl $226
801084b0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801084b5:	e9 99 f0 ff ff       	jmp    80107553 <alltraps>

801084ba <vector227>:
.globl vector227
vector227:
  pushl $0
801084ba:	6a 00                	push   $0x0
  pushl $227
801084bc:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801084c1:	e9 8d f0 ff ff       	jmp    80107553 <alltraps>

801084c6 <vector228>:
.globl vector228
vector228:
  pushl $0
801084c6:	6a 00                	push   $0x0
  pushl $228
801084c8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801084cd:	e9 81 f0 ff ff       	jmp    80107553 <alltraps>

801084d2 <vector229>:
.globl vector229
vector229:
  pushl $0
801084d2:	6a 00                	push   $0x0
  pushl $229
801084d4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801084d9:	e9 75 f0 ff ff       	jmp    80107553 <alltraps>

801084de <vector230>:
.globl vector230
vector230:
  pushl $0
801084de:	6a 00                	push   $0x0
  pushl $230
801084e0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801084e5:	e9 69 f0 ff ff       	jmp    80107553 <alltraps>

801084ea <vector231>:
.globl vector231
vector231:
  pushl $0
801084ea:	6a 00                	push   $0x0
  pushl $231
801084ec:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801084f1:	e9 5d f0 ff ff       	jmp    80107553 <alltraps>

801084f6 <vector232>:
.globl vector232
vector232:
  pushl $0
801084f6:	6a 00                	push   $0x0
  pushl $232
801084f8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801084fd:	e9 51 f0 ff ff       	jmp    80107553 <alltraps>

80108502 <vector233>:
.globl vector233
vector233:
  pushl $0
80108502:	6a 00                	push   $0x0
  pushl $233
80108504:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108509:	e9 45 f0 ff ff       	jmp    80107553 <alltraps>

8010850e <vector234>:
.globl vector234
vector234:
  pushl $0
8010850e:	6a 00                	push   $0x0
  pushl $234
80108510:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108515:	e9 39 f0 ff ff       	jmp    80107553 <alltraps>

8010851a <vector235>:
.globl vector235
vector235:
  pushl $0
8010851a:	6a 00                	push   $0x0
  pushl $235
8010851c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108521:	e9 2d f0 ff ff       	jmp    80107553 <alltraps>

80108526 <vector236>:
.globl vector236
vector236:
  pushl $0
80108526:	6a 00                	push   $0x0
  pushl $236
80108528:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010852d:	e9 21 f0 ff ff       	jmp    80107553 <alltraps>

80108532 <vector237>:
.globl vector237
vector237:
  pushl $0
80108532:	6a 00                	push   $0x0
  pushl $237
80108534:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108539:	e9 15 f0 ff ff       	jmp    80107553 <alltraps>

8010853e <vector238>:
.globl vector238
vector238:
  pushl $0
8010853e:	6a 00                	push   $0x0
  pushl $238
80108540:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108545:	e9 09 f0 ff ff       	jmp    80107553 <alltraps>

8010854a <vector239>:
.globl vector239
vector239:
  pushl $0
8010854a:	6a 00                	push   $0x0
  pushl $239
8010854c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108551:	e9 fd ef ff ff       	jmp    80107553 <alltraps>

80108556 <vector240>:
.globl vector240
vector240:
  pushl $0
80108556:	6a 00                	push   $0x0
  pushl $240
80108558:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010855d:	e9 f1 ef ff ff       	jmp    80107553 <alltraps>

80108562 <vector241>:
.globl vector241
vector241:
  pushl $0
80108562:	6a 00                	push   $0x0
  pushl $241
80108564:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108569:	e9 e5 ef ff ff       	jmp    80107553 <alltraps>

8010856e <vector242>:
.globl vector242
vector242:
  pushl $0
8010856e:	6a 00                	push   $0x0
  pushl $242
80108570:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108575:	e9 d9 ef ff ff       	jmp    80107553 <alltraps>

8010857a <vector243>:
.globl vector243
vector243:
  pushl $0
8010857a:	6a 00                	push   $0x0
  pushl $243
8010857c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108581:	e9 cd ef ff ff       	jmp    80107553 <alltraps>

80108586 <vector244>:
.globl vector244
vector244:
  pushl $0
80108586:	6a 00                	push   $0x0
  pushl $244
80108588:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010858d:	e9 c1 ef ff ff       	jmp    80107553 <alltraps>

80108592 <vector245>:
.globl vector245
vector245:
  pushl $0
80108592:	6a 00                	push   $0x0
  pushl $245
80108594:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108599:	e9 b5 ef ff ff       	jmp    80107553 <alltraps>

8010859e <vector246>:
.globl vector246
vector246:
  pushl $0
8010859e:	6a 00                	push   $0x0
  pushl $246
801085a0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801085a5:	e9 a9 ef ff ff       	jmp    80107553 <alltraps>

801085aa <vector247>:
.globl vector247
vector247:
  pushl $0
801085aa:	6a 00                	push   $0x0
  pushl $247
801085ac:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801085b1:	e9 9d ef ff ff       	jmp    80107553 <alltraps>

801085b6 <vector248>:
.globl vector248
vector248:
  pushl $0
801085b6:	6a 00                	push   $0x0
  pushl $248
801085b8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801085bd:	e9 91 ef ff ff       	jmp    80107553 <alltraps>

801085c2 <vector249>:
.globl vector249
vector249:
  pushl $0
801085c2:	6a 00                	push   $0x0
  pushl $249
801085c4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801085c9:	e9 85 ef ff ff       	jmp    80107553 <alltraps>

801085ce <vector250>:
.globl vector250
vector250:
  pushl $0
801085ce:	6a 00                	push   $0x0
  pushl $250
801085d0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801085d5:	e9 79 ef ff ff       	jmp    80107553 <alltraps>

801085da <vector251>:
.globl vector251
vector251:
  pushl $0
801085da:	6a 00                	push   $0x0
  pushl $251
801085dc:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801085e1:	e9 6d ef ff ff       	jmp    80107553 <alltraps>

801085e6 <vector252>:
.globl vector252
vector252:
  pushl $0
801085e6:	6a 00                	push   $0x0
  pushl $252
801085e8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801085ed:	e9 61 ef ff ff       	jmp    80107553 <alltraps>

801085f2 <vector253>:
.globl vector253
vector253:
  pushl $0
801085f2:	6a 00                	push   $0x0
  pushl $253
801085f4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801085f9:	e9 55 ef ff ff       	jmp    80107553 <alltraps>

801085fe <vector254>:
.globl vector254
vector254:
  pushl $0
801085fe:	6a 00                	push   $0x0
  pushl $254
80108600:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108605:	e9 49 ef ff ff       	jmp    80107553 <alltraps>

8010860a <vector255>:
.globl vector255
vector255:
  pushl $0
8010860a:	6a 00                	push   $0x0
  pushl $255
8010860c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108611:	e9 3d ef ff ff       	jmp    80107553 <alltraps>

80108616 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108616:	55                   	push   %ebp
80108617:	89 e5                	mov    %esp,%ebp
80108619:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010861c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010861f:	83 e8 01             	sub    $0x1,%eax
80108622:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108626:	8b 45 08             	mov    0x8(%ebp),%eax
80108629:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010862d:	8b 45 08             	mov    0x8(%ebp),%eax
80108630:	c1 e8 10             	shr    $0x10,%eax
80108633:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108637:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010863a:	0f 01 10             	lgdtl  (%eax)
}
8010863d:	90                   	nop
8010863e:	c9                   	leave  
8010863f:	c3                   	ret    

80108640 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108640:	55                   	push   %ebp
80108641:	89 e5                	mov    %esp,%ebp
80108643:	83 ec 04             	sub    $0x4,%esp
80108646:	8b 45 08             	mov    0x8(%ebp),%eax
80108649:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010864d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108651:	0f 00 d8             	ltr    %ax
}
80108654:	90                   	nop
80108655:	c9                   	leave  
80108656:	c3                   	ret    

80108657 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108657:	55                   	push   %ebp
80108658:	89 e5                	mov    %esp,%ebp
8010865a:	83 ec 04             	sub    $0x4,%esp
8010865d:	8b 45 08             	mov    0x8(%ebp),%eax
80108660:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108664:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108668:	8e e8                	mov    %eax,%gs
}
8010866a:	90                   	nop
8010866b:	c9                   	leave  
8010866c:	c3                   	ret    

8010866d <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010866d:	55                   	push   %ebp
8010866e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108670:	8b 45 08             	mov    0x8(%ebp),%eax
80108673:	0f 22 d8             	mov    %eax,%cr3
}
80108676:	90                   	nop
80108677:	5d                   	pop    %ebp
80108678:	c3                   	ret    

80108679 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108679:	55                   	push   %ebp
8010867a:	89 e5                	mov    %esp,%ebp
8010867c:	8b 45 08             	mov    0x8(%ebp),%eax
8010867f:	05 00 00 00 80       	add    $0x80000000,%eax
80108684:	5d                   	pop    %ebp
80108685:	c3                   	ret    

80108686 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108686:	55                   	push   %ebp
80108687:	89 e5                	mov    %esp,%ebp
80108689:	8b 45 08             	mov    0x8(%ebp),%eax
8010868c:	05 00 00 00 80       	add    $0x80000000,%eax
80108691:	5d                   	pop    %ebp
80108692:	c3                   	ret    

80108693 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108693:	55                   	push   %ebp
80108694:	89 e5                	mov    %esp,%ebp
80108696:	53                   	push   %ebx
80108697:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010869a:	e8 49 b1 ff ff       	call   801037e8 <cpunum>
8010869f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801086a5:	05 80 38 11 80       	add    $0x80113880,%eax
801086aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801086ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801086b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801086bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086cd:	83 e2 f0             	and    $0xfffffff0,%edx
801086d0:	83 ca 0a             	or     $0xa,%edx
801086d3:	88 50 7d             	mov    %dl,0x7d(%eax)
801086d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086dd:	83 ca 10             	or     $0x10,%edx
801086e0:	88 50 7d             	mov    %dl,0x7d(%eax)
801086e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086ea:	83 e2 9f             	and    $0xffffff9f,%edx
801086ed:	88 50 7d             	mov    %dl,0x7d(%eax)
801086f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086f7:	83 ca 80             	or     $0xffffff80,%edx
801086fa:	88 50 7d             	mov    %dl,0x7d(%eax)
801086fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108700:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108704:	83 ca 0f             	or     $0xf,%edx
80108707:	88 50 7e             	mov    %dl,0x7e(%eax)
8010870a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108711:	83 e2 ef             	and    $0xffffffef,%edx
80108714:	88 50 7e             	mov    %dl,0x7e(%eax)
80108717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010871e:	83 e2 df             	and    $0xffffffdf,%edx
80108721:	88 50 7e             	mov    %dl,0x7e(%eax)
80108724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108727:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010872b:	83 ca 40             	or     $0x40,%edx
8010872e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108734:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108738:	83 ca 80             	or     $0xffffff80,%edx
8010873b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108748:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010874f:	ff ff 
80108751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108754:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010875b:	00 00 
8010875d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108760:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108771:	83 e2 f0             	and    $0xfffffff0,%edx
80108774:	83 ca 02             	or     $0x2,%edx
80108777:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010877d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108780:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108787:	83 ca 10             	or     $0x10,%edx
8010878a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108793:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010879a:	83 e2 9f             	and    $0xffffff9f,%edx
8010879d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087ad:	83 ca 80             	or     $0xffffff80,%edx
801087b0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087c0:	83 ca 0f             	or     $0xf,%edx
801087c3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087d3:	83 e2 ef             	and    $0xffffffef,%edx
801087d6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087df:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087e6:	83 e2 df             	and    $0xffffffdf,%edx
801087e9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087f9:	83 ca 40             	or     $0x40,%edx
801087fc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108805:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010880c:	83 ca 80             	or     $0xffffff80,%edx
8010880f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108818:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010881f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108822:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108829:	ff ff 
8010882b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108835:	00 00 
80108837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108844:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010884b:	83 e2 f0             	and    $0xfffffff0,%edx
8010884e:	83 ca 0a             	or     $0xa,%edx
80108851:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108861:	83 ca 10             	or     $0x10,%edx
80108864:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010886a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108874:	83 ca 60             	or     $0x60,%edx
80108877:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108887:	83 ca 80             	or     $0xffffff80,%edx
8010888a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108893:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010889a:	83 ca 0f             	or     $0xf,%edx
8010889d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088ad:	83 e2 ef             	and    $0xffffffef,%edx
801088b0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088c0:	83 e2 df             	and    $0xffffffdf,%edx
801088c3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088d3:	83 ca 40             	or     $0x40,%edx
801088d6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088df:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088e6:	83 ca 80             	or     $0xffffff80,%edx
801088e9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f2:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801088f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fc:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108903:	ff ff 
80108905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108908:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010890f:	00 00 
80108911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108914:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108925:	83 e2 f0             	and    $0xfffffff0,%edx
80108928:	83 ca 02             	or     $0x2,%edx
8010892b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108934:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010893b:	83 ca 10             	or     $0x10,%edx
8010893e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108947:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010894e:	83 ca 60             	or     $0x60,%edx
80108951:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108961:	83 ca 80             	or     $0xffffff80,%edx
80108964:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010896a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108974:	83 ca 0f             	or     $0xf,%edx
80108977:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010897d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108980:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108987:	83 e2 ef             	and    $0xffffffef,%edx
8010898a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108993:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010899a:	83 e2 df             	and    $0xffffffdf,%edx
8010899d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089ad:	83 ca 40             	or     $0x40,%edx
801089b0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089c0:	83 ca 80             	or     $0xffffff80,%edx
801089c3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cc:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801089d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d6:	05 b4 00 00 00       	add    $0xb4,%eax
801089db:	89 c3                	mov    %eax,%ebx
801089dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e0:	05 b4 00 00 00       	add    $0xb4,%eax
801089e5:	c1 e8 10             	shr    $0x10,%eax
801089e8:	89 c2                	mov    %eax,%edx
801089ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ed:	05 b4 00 00 00       	add    $0xb4,%eax
801089f2:	c1 e8 18             	shr    $0x18,%eax
801089f5:	89 c1                	mov    %eax,%ecx
801089f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fa:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108a01:	00 00 
80108a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a06:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a10:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a19:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a20:	83 e2 f0             	and    $0xfffffff0,%edx
80108a23:	83 ca 02             	or     $0x2,%edx
80108a26:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a36:	83 ca 10             	or     $0x10,%edx
80108a39:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a42:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a49:	83 e2 9f             	and    $0xffffff9f,%edx
80108a4c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a55:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a5c:	83 ca 80             	or     $0xffffff80,%edx
80108a5f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a68:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a6f:	83 e2 f0             	and    $0xfffffff0,%edx
80108a72:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a82:	83 e2 ef             	and    $0xffffffef,%edx
80108a85:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a95:	83 e2 df             	and    $0xffffffdf,%edx
80108a98:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108aa8:	83 ca 40             	or     $0x40,%edx
80108aab:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108abb:	83 ca 80             	or     $0xffffff80,%edx
80108abe:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac7:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad0:	83 c0 70             	add    $0x70,%eax
80108ad3:	83 ec 08             	sub    $0x8,%esp
80108ad6:	6a 38                	push   $0x38
80108ad8:	50                   	push   %eax
80108ad9:	e8 38 fb ff ff       	call   80108616 <lgdt>
80108ade:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108ae1:	83 ec 0c             	sub    $0xc,%esp
80108ae4:	6a 18                	push   $0x18
80108ae6:	e8 6c fb ff ff       	call   80108657 <loadgs>
80108aeb:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af1:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108af7:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108afe:	00 00 00 00 
}
80108b02:	90                   	nop
80108b03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b06:	c9                   	leave  
80108b07:	c3                   	ret    

80108b08 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108b08:	55                   	push   %ebp
80108b09:	89 e5                	mov    %esp,%ebp
80108b0b:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b11:	c1 e8 16             	shr    $0x16,%eax
80108b14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b1e:	01 d0                	add    %edx,%eax
80108b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b26:	8b 00                	mov    (%eax),%eax
80108b28:	83 e0 01             	and    $0x1,%eax
80108b2b:	85 c0                	test   %eax,%eax
80108b2d:	74 18                	je     80108b47 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b32:	8b 00                	mov    (%eax),%eax
80108b34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b39:	50                   	push   %eax
80108b3a:	e8 47 fb ff ff       	call   80108686 <p2v>
80108b3f:	83 c4 04             	add    $0x4,%esp
80108b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b45:	eb 48                	jmp    80108b8f <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108b47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108b4b:	74 0e                	je     80108b5b <walkpgdir+0x53>
80108b4d:	e8 30 a9 ff ff       	call   80103482 <kalloc>
80108b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108b59:	75 07                	jne    80108b62 <walkpgdir+0x5a>
      return 0;
80108b5b:	b8 00 00 00 00       	mov    $0x0,%eax
80108b60:	eb 44                	jmp    80108ba6 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108b62:	83 ec 04             	sub    $0x4,%esp
80108b65:	68 00 10 00 00       	push   $0x1000
80108b6a:	6a 00                	push   $0x0
80108b6c:	ff 75 f4             	pushl  -0xc(%ebp)
80108b6f:	e8 86 d2 ff ff       	call   80105dfa <memset>
80108b74:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108b77:	83 ec 0c             	sub    $0xc,%esp
80108b7a:	ff 75 f4             	pushl  -0xc(%ebp)
80108b7d:	e8 f7 fa ff ff       	call   80108679 <v2p>
80108b82:	83 c4 10             	add    $0x10,%esp
80108b85:	83 c8 07             	or     $0x7,%eax
80108b88:	89 c2                	mov    %eax,%edx
80108b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b8d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b92:	c1 e8 0c             	shr    $0xc,%eax
80108b95:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba4:	01 d0                	add    %edx,%eax
}
80108ba6:	c9                   	leave  
80108ba7:	c3                   	ret    

80108ba8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108ba8:	55                   	push   %ebp
80108ba9:	89 e5                	mov    %esp,%ebp
80108bab:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bbc:	8b 45 10             	mov    0x10(%ebp),%eax
80108bbf:	01 d0                	add    %edx,%eax
80108bc1:	83 e8 01             	sub    $0x1,%eax
80108bc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108bcc:	83 ec 04             	sub    $0x4,%esp
80108bcf:	6a 01                	push   $0x1
80108bd1:	ff 75 f4             	pushl  -0xc(%ebp)
80108bd4:	ff 75 08             	pushl  0x8(%ebp)
80108bd7:	e8 2c ff ff ff       	call   80108b08 <walkpgdir>
80108bdc:	83 c4 10             	add    $0x10,%esp
80108bdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108be2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108be6:	75 07                	jne    80108bef <mappages+0x47>
      return -1;
80108be8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bed:	eb 47                	jmp    80108c36 <mappages+0x8e>
    if(*pte & PTE_P)
80108bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf2:	8b 00                	mov    (%eax),%eax
80108bf4:	83 e0 01             	and    $0x1,%eax
80108bf7:	85 c0                	test   %eax,%eax
80108bf9:	74 0d                	je     80108c08 <mappages+0x60>
      panic("remap");
80108bfb:	83 ec 0c             	sub    $0xc,%esp
80108bfe:	68 28 9b 10 80       	push   $0x80109b28
80108c03:	e8 5e 79 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108c08:	8b 45 18             	mov    0x18(%ebp),%eax
80108c0b:	0b 45 14             	or     0x14(%ebp),%eax
80108c0e:	83 c8 01             	or     $0x1,%eax
80108c11:	89 c2                	mov    %eax,%edx
80108c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c16:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c1e:	74 10                	je     80108c30 <mappages+0x88>
      break;
    a += PGSIZE;
80108c20:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108c27:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108c2e:	eb 9c                	jmp    80108bcc <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108c30:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108c31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c36:	c9                   	leave  
80108c37:	c3                   	ret    

80108c38 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108c38:	55                   	push   %ebp
80108c39:	89 e5                	mov    %esp,%ebp
80108c3b:	53                   	push   %ebx
80108c3c:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108c3f:	e8 3e a8 ff ff       	call   80103482 <kalloc>
80108c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c4b:	75 0a                	jne    80108c57 <setupkvm+0x1f>
    return 0;
80108c4d:	b8 00 00 00 00       	mov    $0x0,%eax
80108c52:	e9 8e 00 00 00       	jmp    80108ce5 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108c57:	83 ec 04             	sub    $0x4,%esp
80108c5a:	68 00 10 00 00       	push   $0x1000
80108c5f:	6a 00                	push   $0x0
80108c61:	ff 75 f0             	pushl  -0x10(%ebp)
80108c64:	e8 91 d1 ff ff       	call   80105dfa <memset>
80108c69:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108c6c:	83 ec 0c             	sub    $0xc,%esp
80108c6f:	68 00 00 00 0e       	push   $0xe000000
80108c74:	e8 0d fa ff ff       	call   80108686 <p2v>
80108c79:	83 c4 10             	add    $0x10,%esp
80108c7c:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108c81:	76 0d                	jbe    80108c90 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108c83:	83 ec 0c             	sub    $0xc,%esp
80108c86:	68 2e 9b 10 80       	push   $0x80109b2e
80108c8b:	e8 d6 78 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c90:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108c97:	eb 40                	jmp    80108cd9 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca2:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca8:	8b 58 08             	mov    0x8(%eax),%ebx
80108cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cae:	8b 40 04             	mov    0x4(%eax),%eax
80108cb1:	29 c3                	sub    %eax,%ebx
80108cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb6:	8b 00                	mov    (%eax),%eax
80108cb8:	83 ec 0c             	sub    $0xc,%esp
80108cbb:	51                   	push   %ecx
80108cbc:	52                   	push   %edx
80108cbd:	53                   	push   %ebx
80108cbe:	50                   	push   %eax
80108cbf:	ff 75 f0             	pushl  -0x10(%ebp)
80108cc2:	e8 e1 fe ff ff       	call   80108ba8 <mappages>
80108cc7:	83 c4 20             	add    $0x20,%esp
80108cca:	85 c0                	test   %eax,%eax
80108ccc:	79 07                	jns    80108cd5 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108cce:	b8 00 00 00 00       	mov    $0x0,%eax
80108cd3:	eb 10                	jmp    80108ce5 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108cd5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108cd9:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108ce0:	72 b7                	jb     80108c99 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108ce5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ce8:	c9                   	leave  
80108ce9:	c3                   	ret    

80108cea <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108cea:	55                   	push   %ebp
80108ceb:	89 e5                	mov    %esp,%ebp
80108ced:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108cf0:	e8 43 ff ff ff       	call   80108c38 <setupkvm>
80108cf5:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108cfa:	e8 03 00 00 00       	call   80108d02 <switchkvm>
}
80108cff:	90                   	nop
80108d00:	c9                   	leave  
80108d01:	c3                   	ret    

80108d02 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108d02:	55                   	push   %ebp
80108d03:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108d05:	a1 58 66 11 80       	mov    0x80116658,%eax
80108d0a:	50                   	push   %eax
80108d0b:	e8 69 f9 ff ff       	call   80108679 <v2p>
80108d10:	83 c4 04             	add    $0x4,%esp
80108d13:	50                   	push   %eax
80108d14:	e8 54 f9 ff ff       	call   8010866d <lcr3>
80108d19:	83 c4 04             	add    $0x4,%esp
}
80108d1c:	90                   	nop
80108d1d:	c9                   	leave  
80108d1e:	c3                   	ret    

80108d1f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108d1f:	55                   	push   %ebp
80108d20:	89 e5                	mov    %esp,%ebp
80108d22:	56                   	push   %esi
80108d23:	53                   	push   %ebx
  pushcli();
80108d24:	e8 cb cf ff ff       	call   80105cf4 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108d29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d2f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d36:	83 c2 08             	add    $0x8,%edx
80108d39:	89 d6                	mov    %edx,%esi
80108d3b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d42:	83 c2 08             	add    $0x8,%edx
80108d45:	c1 ea 10             	shr    $0x10,%edx
80108d48:	89 d3                	mov    %edx,%ebx
80108d4a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d51:	83 c2 08             	add    $0x8,%edx
80108d54:	c1 ea 18             	shr    $0x18,%edx
80108d57:	89 d1                	mov    %edx,%ecx
80108d59:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108d60:	67 00 
80108d62:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108d69:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108d6f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d76:	83 e2 f0             	and    $0xfffffff0,%edx
80108d79:	83 ca 09             	or     $0x9,%edx
80108d7c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d82:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d89:	83 ca 10             	or     $0x10,%edx
80108d8c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d92:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d99:	83 e2 9f             	and    $0xffffff9f,%edx
80108d9c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108da2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108da9:	83 ca 80             	or     $0xffffff80,%edx
80108dac:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108db2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108db9:	83 e2 f0             	and    $0xfffffff0,%edx
80108dbc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dc2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108dc9:	83 e2 ef             	and    $0xffffffef,%edx
80108dcc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dd2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108dd9:	83 e2 df             	and    $0xffffffdf,%edx
80108ddc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108de2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108de9:	83 ca 40             	or     $0x40,%edx
80108dec:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108df2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108df9:	83 e2 7f             	and    $0x7f,%edx
80108dfc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e02:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108e08:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e0e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e15:	83 e2 ef             	and    $0xffffffef,%edx
80108e18:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108e1e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e24:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108e2a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e30:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e37:	8b 52 08             	mov    0x8(%edx),%edx
80108e3a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108e40:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108e43:	83 ec 0c             	sub    $0xc,%esp
80108e46:	6a 30                	push   $0x30
80108e48:	e8 f3 f7 ff ff       	call   80108640 <ltr>
80108e4d:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108e50:	8b 45 08             	mov    0x8(%ebp),%eax
80108e53:	8b 40 04             	mov    0x4(%eax),%eax
80108e56:	85 c0                	test   %eax,%eax
80108e58:	75 0d                	jne    80108e67 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108e5a:	83 ec 0c             	sub    $0xc,%esp
80108e5d:	68 3f 9b 10 80       	push   $0x80109b3f
80108e62:	e8 ff 76 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108e67:	8b 45 08             	mov    0x8(%ebp),%eax
80108e6a:	8b 40 04             	mov    0x4(%eax),%eax
80108e6d:	83 ec 0c             	sub    $0xc,%esp
80108e70:	50                   	push   %eax
80108e71:	e8 03 f8 ff ff       	call   80108679 <v2p>
80108e76:	83 c4 10             	add    $0x10,%esp
80108e79:	83 ec 0c             	sub    $0xc,%esp
80108e7c:	50                   	push   %eax
80108e7d:	e8 eb f7 ff ff       	call   8010866d <lcr3>
80108e82:	83 c4 10             	add    $0x10,%esp
  popcli();
80108e85:	e8 af ce ff ff       	call   80105d39 <popcli>
}
80108e8a:	90                   	nop
80108e8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108e8e:	5b                   	pop    %ebx
80108e8f:	5e                   	pop    %esi
80108e90:	5d                   	pop    %ebp
80108e91:	c3                   	ret    

80108e92 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108e92:	55                   	push   %ebp
80108e93:	89 e5                	mov    %esp,%ebp
80108e95:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108e98:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108e9f:	76 0d                	jbe    80108eae <inituvm+0x1c>
    panic("inituvm: more than a page");
80108ea1:	83 ec 0c             	sub    $0xc,%esp
80108ea4:	68 53 9b 10 80       	push   $0x80109b53
80108ea9:	e8 b8 76 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108eae:	e8 cf a5 ff ff       	call   80103482 <kalloc>
80108eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108eb6:	83 ec 04             	sub    $0x4,%esp
80108eb9:	68 00 10 00 00       	push   $0x1000
80108ebe:	6a 00                	push   $0x0
80108ec0:	ff 75 f4             	pushl  -0xc(%ebp)
80108ec3:	e8 32 cf ff ff       	call   80105dfa <memset>
80108ec8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ecb:	83 ec 0c             	sub    $0xc,%esp
80108ece:	ff 75 f4             	pushl  -0xc(%ebp)
80108ed1:	e8 a3 f7 ff ff       	call   80108679 <v2p>
80108ed6:	83 c4 10             	add    $0x10,%esp
80108ed9:	83 ec 0c             	sub    $0xc,%esp
80108edc:	6a 06                	push   $0x6
80108ede:	50                   	push   %eax
80108edf:	68 00 10 00 00       	push   $0x1000
80108ee4:	6a 00                	push   $0x0
80108ee6:	ff 75 08             	pushl  0x8(%ebp)
80108ee9:	e8 ba fc ff ff       	call   80108ba8 <mappages>
80108eee:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108ef1:	83 ec 04             	sub    $0x4,%esp
80108ef4:	ff 75 10             	pushl  0x10(%ebp)
80108ef7:	ff 75 0c             	pushl  0xc(%ebp)
80108efa:	ff 75 f4             	pushl  -0xc(%ebp)
80108efd:	e8 b7 cf ff ff       	call   80105eb9 <memmove>
80108f02:	83 c4 10             	add    $0x10,%esp
}
80108f05:	90                   	nop
80108f06:	c9                   	leave  
80108f07:	c3                   	ret    

80108f08 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108f08:	55                   	push   %ebp
80108f09:	89 e5                	mov    %esp,%ebp
80108f0b:	53                   	push   %ebx
80108f0c:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f12:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f17:	85 c0                	test   %eax,%eax
80108f19:	74 0d                	je     80108f28 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108f1b:	83 ec 0c             	sub    $0xc,%esp
80108f1e:	68 70 9b 10 80       	push   $0x80109b70
80108f23:	e8 3e 76 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108f28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f2f:	e9 95 00 00 00       	jmp    80108fc9 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108f34:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3a:	01 d0                	add    %edx,%eax
80108f3c:	83 ec 04             	sub    $0x4,%esp
80108f3f:	6a 00                	push   $0x0
80108f41:	50                   	push   %eax
80108f42:	ff 75 08             	pushl  0x8(%ebp)
80108f45:	e8 be fb ff ff       	call   80108b08 <walkpgdir>
80108f4a:	83 c4 10             	add    $0x10,%esp
80108f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f54:	75 0d                	jne    80108f63 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108f56:	83 ec 0c             	sub    $0xc,%esp
80108f59:	68 93 9b 10 80       	push   $0x80109b93
80108f5e:	e8 03 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f66:	8b 00                	mov    (%eax),%eax
80108f68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108f70:	8b 45 18             	mov    0x18(%ebp),%eax
80108f73:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f76:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108f7b:	77 0b                	ja     80108f88 <loaduvm+0x80>
      n = sz - i;
80108f7d:	8b 45 18             	mov    0x18(%ebp),%eax
80108f80:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f83:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f86:	eb 07                	jmp    80108f8f <loaduvm+0x87>
    else
      n = PGSIZE;
80108f88:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108f8f:	8b 55 14             	mov    0x14(%ebp),%edx
80108f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f95:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108f98:	83 ec 0c             	sub    $0xc,%esp
80108f9b:	ff 75 e8             	pushl  -0x18(%ebp)
80108f9e:	e8 e3 f6 ff ff       	call   80108686 <p2v>
80108fa3:	83 c4 10             	add    $0x10,%esp
80108fa6:	ff 75 f0             	pushl  -0x10(%ebp)
80108fa9:	53                   	push   %ebx
80108faa:	50                   	push   %eax
80108fab:	ff 75 10             	pushl  0x10(%ebp)
80108fae:	e8 cd 95 ff ff       	call   80102580 <readi>
80108fb3:	83 c4 10             	add    $0x10,%esp
80108fb6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108fb9:	74 07                	je     80108fc2 <loaduvm+0xba>
      return -1;
80108fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fc0:	eb 18                	jmp    80108fda <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108fc2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fcc:	3b 45 18             	cmp    0x18(%ebp),%eax
80108fcf:	0f 82 5f ff ff ff    	jb     80108f34 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108fd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108fdd:	c9                   	leave  
80108fde:	c3                   	ret    

80108fdf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fdf:	55                   	push   %ebp
80108fe0:	89 e5                	mov    %esp,%ebp
80108fe2:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108fe5:	8b 45 10             	mov    0x10(%ebp),%eax
80108fe8:	85 c0                	test   %eax,%eax
80108fea:	79 0a                	jns    80108ff6 <allocuvm+0x17>
    return 0;
80108fec:	b8 00 00 00 00       	mov    $0x0,%eax
80108ff1:	e9 b0 00 00 00       	jmp    801090a6 <allocuvm+0xc7>
  if(newsz < oldsz)
80108ff6:	8b 45 10             	mov    0x10(%ebp),%eax
80108ff9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ffc:	73 08                	jae    80109006 <allocuvm+0x27>
    return oldsz;
80108ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
80109001:	e9 a0 00 00 00       	jmp    801090a6 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109006:	8b 45 0c             	mov    0xc(%ebp),%eax
80109009:	05 ff 0f 00 00       	add    $0xfff,%eax
8010900e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109013:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109016:	eb 7f                	jmp    80109097 <allocuvm+0xb8>
    mem = kalloc();
80109018:	e8 65 a4 ff ff       	call   80103482 <kalloc>
8010901d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109020:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109024:	75 2b                	jne    80109051 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109026:	83 ec 0c             	sub    $0xc,%esp
80109029:	68 b1 9b 10 80       	push   $0x80109bb1
8010902e:	e8 93 73 ff ff       	call   801003c6 <cprintf>
80109033:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109036:	83 ec 04             	sub    $0x4,%esp
80109039:	ff 75 0c             	pushl  0xc(%ebp)
8010903c:	ff 75 10             	pushl  0x10(%ebp)
8010903f:	ff 75 08             	pushl  0x8(%ebp)
80109042:	e8 61 00 00 00       	call   801090a8 <deallocuvm>
80109047:	83 c4 10             	add    $0x10,%esp
      return 0;
8010904a:	b8 00 00 00 00       	mov    $0x0,%eax
8010904f:	eb 55                	jmp    801090a6 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109051:	83 ec 04             	sub    $0x4,%esp
80109054:	68 00 10 00 00       	push   $0x1000
80109059:	6a 00                	push   $0x0
8010905b:	ff 75 f0             	pushl  -0x10(%ebp)
8010905e:	e8 97 cd ff ff       	call   80105dfa <memset>
80109063:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109066:	83 ec 0c             	sub    $0xc,%esp
80109069:	ff 75 f0             	pushl  -0x10(%ebp)
8010906c:	e8 08 f6 ff ff       	call   80108679 <v2p>
80109071:	83 c4 10             	add    $0x10,%esp
80109074:	89 c2                	mov    %eax,%edx
80109076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109079:	83 ec 0c             	sub    $0xc,%esp
8010907c:	6a 06                	push   $0x6
8010907e:	52                   	push   %edx
8010907f:	68 00 10 00 00       	push   $0x1000
80109084:	50                   	push   %eax
80109085:	ff 75 08             	pushl  0x8(%ebp)
80109088:	e8 1b fb ff ff       	call   80108ba8 <mappages>
8010908d:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109090:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010909d:	0f 82 75 ff ff ff    	jb     80109018 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801090a3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090a6:	c9                   	leave  
801090a7:	c3                   	ret    

801090a8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801090a8:	55                   	push   %ebp
801090a9:	89 e5                	mov    %esp,%ebp
801090ab:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801090ae:	8b 45 10             	mov    0x10(%ebp),%eax
801090b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090b4:	72 08                	jb     801090be <deallocuvm+0x16>
    return oldsz;
801090b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801090b9:	e9 a5 00 00 00       	jmp    80109163 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801090be:	8b 45 10             	mov    0x10(%ebp),%eax
801090c1:	05 ff 0f 00 00       	add    $0xfff,%eax
801090c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801090ce:	e9 81 00 00 00       	jmp    80109154 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801090d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d6:	83 ec 04             	sub    $0x4,%esp
801090d9:	6a 00                	push   $0x0
801090db:	50                   	push   %eax
801090dc:	ff 75 08             	pushl  0x8(%ebp)
801090df:	e8 24 fa ff ff       	call   80108b08 <walkpgdir>
801090e4:	83 c4 10             	add    $0x10,%esp
801090e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801090ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801090ee:	75 09                	jne    801090f9 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801090f0:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801090f7:	eb 54                	jmp    8010914d <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801090f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090fc:	8b 00                	mov    (%eax),%eax
801090fe:	83 e0 01             	and    $0x1,%eax
80109101:	85 c0                	test   %eax,%eax
80109103:	74 48                	je     8010914d <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109108:	8b 00                	mov    (%eax),%eax
8010910a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010910f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109112:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109116:	75 0d                	jne    80109125 <deallocuvm+0x7d>
        panic("kfree");
80109118:	83 ec 0c             	sub    $0xc,%esp
8010911b:	68 c9 9b 10 80       	push   $0x80109bc9
80109120:	e8 41 74 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109125:	83 ec 0c             	sub    $0xc,%esp
80109128:	ff 75 ec             	pushl  -0x14(%ebp)
8010912b:	e8 56 f5 ff ff       	call   80108686 <p2v>
80109130:	83 c4 10             	add    $0x10,%esp
80109133:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109136:	83 ec 0c             	sub    $0xc,%esp
80109139:	ff 75 e8             	pushl  -0x18(%ebp)
8010913c:	e8 a4 a2 ff ff       	call   801033e5 <kfree>
80109141:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109147:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010914d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109157:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010915a:	0f 82 73 ff ff ff    	jb     801090d3 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109160:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109163:	c9                   	leave  
80109164:	c3                   	ret    

80109165 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109165:	55                   	push   %ebp
80109166:	89 e5                	mov    %esp,%ebp
80109168:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010916b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010916f:	75 0d                	jne    8010917e <freevm+0x19>
    panic("freevm: no pgdir");
80109171:	83 ec 0c             	sub    $0xc,%esp
80109174:	68 cf 9b 10 80       	push   $0x80109bcf
80109179:	e8 e8 73 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010917e:	83 ec 04             	sub    $0x4,%esp
80109181:	6a 00                	push   $0x0
80109183:	68 00 00 00 80       	push   $0x80000000
80109188:	ff 75 08             	pushl  0x8(%ebp)
8010918b:	e8 18 ff ff ff       	call   801090a8 <deallocuvm>
80109190:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010919a:	eb 4f                	jmp    801091eb <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010919c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091a6:	8b 45 08             	mov    0x8(%ebp),%eax
801091a9:	01 d0                	add    %edx,%eax
801091ab:	8b 00                	mov    (%eax),%eax
801091ad:	83 e0 01             	and    $0x1,%eax
801091b0:	85 c0                	test   %eax,%eax
801091b2:	74 33                	je     801091e7 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801091b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091be:	8b 45 08             	mov    0x8(%ebp),%eax
801091c1:	01 d0                	add    %edx,%eax
801091c3:	8b 00                	mov    (%eax),%eax
801091c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091ca:	83 ec 0c             	sub    $0xc,%esp
801091cd:	50                   	push   %eax
801091ce:	e8 b3 f4 ff ff       	call   80108686 <p2v>
801091d3:	83 c4 10             	add    $0x10,%esp
801091d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801091d9:	83 ec 0c             	sub    $0xc,%esp
801091dc:	ff 75 f0             	pushl  -0x10(%ebp)
801091df:	e8 01 a2 ff ff       	call   801033e5 <kfree>
801091e4:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801091e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091eb:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801091f2:	76 a8                	jbe    8010919c <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801091f4:	83 ec 0c             	sub    $0xc,%esp
801091f7:	ff 75 08             	pushl  0x8(%ebp)
801091fa:	e8 e6 a1 ff ff       	call   801033e5 <kfree>
801091ff:	83 c4 10             	add    $0x10,%esp
}
80109202:	90                   	nop
80109203:	c9                   	leave  
80109204:	c3                   	ret    

80109205 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109205:	55                   	push   %ebp
80109206:	89 e5                	mov    %esp,%ebp
80109208:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010920b:	83 ec 04             	sub    $0x4,%esp
8010920e:	6a 00                	push   $0x0
80109210:	ff 75 0c             	pushl  0xc(%ebp)
80109213:	ff 75 08             	pushl  0x8(%ebp)
80109216:	e8 ed f8 ff ff       	call   80108b08 <walkpgdir>
8010921b:	83 c4 10             	add    $0x10,%esp
8010921e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109221:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109225:	75 0d                	jne    80109234 <clearpteu+0x2f>
    panic("clearpteu");
80109227:	83 ec 0c             	sub    $0xc,%esp
8010922a:	68 e0 9b 10 80       	push   $0x80109be0
8010922f:	e8 32 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109237:	8b 00                	mov    (%eax),%eax
80109239:	83 e0 fb             	and    $0xfffffffb,%eax
8010923c:	89 c2                	mov    %eax,%edx
8010923e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109241:	89 10                	mov    %edx,(%eax)
}
80109243:	90                   	nop
80109244:	c9                   	leave  
80109245:	c3                   	ret    

80109246 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109246:	55                   	push   %ebp
80109247:	89 e5                	mov    %esp,%ebp
80109249:	53                   	push   %ebx
8010924a:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010924d:	e8 e6 f9 ff ff       	call   80108c38 <setupkvm>
80109252:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109255:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109259:	75 0a                	jne    80109265 <copyuvm+0x1f>
    return 0;
8010925b:	b8 00 00 00 00       	mov    $0x0,%eax
80109260:	e9 f8 00 00 00       	jmp    8010935d <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010926c:	e9 c4 00 00 00       	jmp    80109335 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109274:	83 ec 04             	sub    $0x4,%esp
80109277:	6a 00                	push   $0x0
80109279:	50                   	push   %eax
8010927a:	ff 75 08             	pushl  0x8(%ebp)
8010927d:	e8 86 f8 ff ff       	call   80108b08 <walkpgdir>
80109282:	83 c4 10             	add    $0x10,%esp
80109285:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109288:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010928c:	75 0d                	jne    8010929b <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010928e:	83 ec 0c             	sub    $0xc,%esp
80109291:	68 ea 9b 10 80       	push   $0x80109bea
80109296:	e8 cb 72 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010929b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010929e:	8b 00                	mov    (%eax),%eax
801092a0:	83 e0 01             	and    $0x1,%eax
801092a3:	85 c0                	test   %eax,%eax
801092a5:	75 0d                	jne    801092b4 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801092a7:	83 ec 0c             	sub    $0xc,%esp
801092aa:	68 04 9c 10 80       	push   $0x80109c04
801092af:	e8 b2 72 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801092b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092b7:	8b 00                	mov    (%eax),%eax
801092b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092be:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801092c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092c4:	8b 00                	mov    (%eax),%eax
801092c6:	25 ff 0f 00 00       	and    $0xfff,%eax
801092cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801092ce:	e8 af a1 ff ff       	call   80103482 <kalloc>
801092d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801092d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801092da:	74 6a                	je     80109346 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801092dc:	83 ec 0c             	sub    $0xc,%esp
801092df:	ff 75 e8             	pushl  -0x18(%ebp)
801092e2:	e8 9f f3 ff ff       	call   80108686 <p2v>
801092e7:	83 c4 10             	add    $0x10,%esp
801092ea:	83 ec 04             	sub    $0x4,%esp
801092ed:	68 00 10 00 00       	push   $0x1000
801092f2:	50                   	push   %eax
801092f3:	ff 75 e0             	pushl  -0x20(%ebp)
801092f6:	e8 be cb ff ff       	call   80105eb9 <memmove>
801092fb:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801092fe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109301:	83 ec 0c             	sub    $0xc,%esp
80109304:	ff 75 e0             	pushl  -0x20(%ebp)
80109307:	e8 6d f3 ff ff       	call   80108679 <v2p>
8010930c:	83 c4 10             	add    $0x10,%esp
8010930f:	89 c2                	mov    %eax,%edx
80109311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109314:	83 ec 0c             	sub    $0xc,%esp
80109317:	53                   	push   %ebx
80109318:	52                   	push   %edx
80109319:	68 00 10 00 00       	push   $0x1000
8010931e:	50                   	push   %eax
8010931f:	ff 75 f0             	pushl  -0x10(%ebp)
80109322:	e8 81 f8 ff ff       	call   80108ba8 <mappages>
80109327:	83 c4 20             	add    $0x20,%esp
8010932a:	85 c0                	test   %eax,%eax
8010932c:	78 1b                	js     80109349 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010932e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109338:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010933b:	0f 82 30 ff ff ff    	jb     80109271 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109341:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109344:	eb 17                	jmp    8010935d <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109346:	90                   	nop
80109347:	eb 01                	jmp    8010934a <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109349:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010934a:	83 ec 0c             	sub    $0xc,%esp
8010934d:	ff 75 f0             	pushl  -0x10(%ebp)
80109350:	e8 10 fe ff ff       	call   80109165 <freevm>
80109355:	83 c4 10             	add    $0x10,%esp
  return 0;
80109358:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010935d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109360:	c9                   	leave  
80109361:	c3                   	ret    

80109362 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109362:	55                   	push   %ebp
80109363:	89 e5                	mov    %esp,%ebp
80109365:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109368:	83 ec 04             	sub    $0x4,%esp
8010936b:	6a 00                	push   $0x0
8010936d:	ff 75 0c             	pushl  0xc(%ebp)
80109370:	ff 75 08             	pushl  0x8(%ebp)
80109373:	e8 90 f7 ff ff       	call   80108b08 <walkpgdir>
80109378:	83 c4 10             	add    $0x10,%esp
8010937b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010937e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109381:	8b 00                	mov    (%eax),%eax
80109383:	83 e0 01             	and    $0x1,%eax
80109386:	85 c0                	test   %eax,%eax
80109388:	75 07                	jne    80109391 <uva2ka+0x2f>
    return 0;
8010938a:	b8 00 00 00 00       	mov    $0x0,%eax
8010938f:	eb 29                	jmp    801093ba <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109394:	8b 00                	mov    (%eax),%eax
80109396:	83 e0 04             	and    $0x4,%eax
80109399:	85 c0                	test   %eax,%eax
8010939b:	75 07                	jne    801093a4 <uva2ka+0x42>
    return 0;
8010939d:	b8 00 00 00 00       	mov    $0x0,%eax
801093a2:	eb 16                	jmp    801093ba <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801093a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a7:	8b 00                	mov    (%eax),%eax
801093a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093ae:	83 ec 0c             	sub    $0xc,%esp
801093b1:	50                   	push   %eax
801093b2:	e8 cf f2 ff ff       	call   80108686 <p2v>
801093b7:	83 c4 10             	add    $0x10,%esp
}
801093ba:	c9                   	leave  
801093bb:	c3                   	ret    

801093bc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801093bc:	55                   	push   %ebp
801093bd:	89 e5                	mov    %esp,%ebp
801093bf:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801093c2:	8b 45 10             	mov    0x10(%ebp),%eax
801093c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801093c8:	eb 7f                	jmp    80109449 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801093ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801093cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801093d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093d8:	83 ec 08             	sub    $0x8,%esp
801093db:	50                   	push   %eax
801093dc:	ff 75 08             	pushl  0x8(%ebp)
801093df:	e8 7e ff ff ff       	call   80109362 <uva2ka>
801093e4:	83 c4 10             	add    $0x10,%esp
801093e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801093ea:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801093ee:	75 07                	jne    801093f7 <copyout+0x3b>
      return -1;
801093f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093f5:	eb 61                	jmp    80109458 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801093f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093fa:	2b 45 0c             	sub    0xc(%ebp),%eax
801093fd:	05 00 10 00 00       	add    $0x1000,%eax
80109402:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109408:	3b 45 14             	cmp    0x14(%ebp),%eax
8010940b:	76 06                	jbe    80109413 <copyout+0x57>
      n = len;
8010940d:	8b 45 14             	mov    0x14(%ebp),%eax
80109410:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109413:	8b 45 0c             	mov    0xc(%ebp),%eax
80109416:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109419:	89 c2                	mov    %eax,%edx
8010941b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010941e:	01 d0                	add    %edx,%eax
80109420:	83 ec 04             	sub    $0x4,%esp
80109423:	ff 75 f0             	pushl  -0x10(%ebp)
80109426:	ff 75 f4             	pushl  -0xc(%ebp)
80109429:	50                   	push   %eax
8010942a:	e8 8a ca ff ff       	call   80105eb9 <memmove>
8010942f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109432:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109435:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010943b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010943e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109441:	05 00 10 00 00       	add    $0x1000,%eax
80109446:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109449:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010944d:	0f 85 77 ff ff ff    	jne    801093ca <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109453:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109458:	c9                   	leave  
80109459:	c3                   	ret    
